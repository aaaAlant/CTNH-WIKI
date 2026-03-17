from __future__ import annotations

import argparse
import json
import re
import shutil
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
import zipfile

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

NAMESPACED_ID_RE = re.compile(r'"(#?[a-z0-9_.-]+:[a-z0-9_./-]+)"')
LANG_KEY_RE = re.compile(r'^(item|block)\.([a-z0-9_.-]+)\.([a-z0-9_./-]+)$')
ITEM_TEXTURE_PRIORITY = (
    'layer0',
    'layer1',
    'particle',
    'all',
    'side',
    'top',
)
BLOCK_TEXTURE_PRIORITY = (
    'particle',
    'all',
    'side',
    'top',
    'front',
    'end',
    'bottom',
    'north',
    'south',
    'east',
    'west',
    'up',
    'down',
)


def parse_args() -> argparse.Namespace:
    root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(
        description='Extract mod language and icon resources for the quest preview pipeline.'
    )
    parser.add_argument('--root', type=Path, default=root)
    parser.add_argument('--mods-dir', type=Path)
    parser.add_argument('--quests-dir', type=Path)
    parser.add_argument('--output-dir', type=Path)
    parser.add_argument('--locales', default='zh_cn,en_us')
    parser.add_argument('--include-all', action='store_true')
    parser.add_argument('--clean-icons', action='store_true')
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root = args.root.resolve()
    mods_dir = (args.mods_dir or root / 'data' / 'mods').resolve()
    quests_dir = (args.quests_dir or root / 'data' / 'quests').resolve()
    output_dir = (args.output_dir or root / 'assets' / 'generated' / 'quests').resolve()
    locales = [part.strip().lower() for part in args.locales.split(',') if part.strip()]
    if not locales:
        locales = ['zh_cn', 'en_us']

    if not mods_dir.exists():
        raise SystemExit(f'mods directory not found: {mods_dir}')
    if not quests_dir.exists():
        raise SystemExit(f'quests directory not found: {quests_dir}')

    icons_dir = output_dir / 'icons' / 'mods'
    web_icons_dir = root / 'web' / 'assets' / 'generated' / 'quests' / 'icons' / 'mods'
    output_dir.mkdir(parents=True, exist_ok=True)
    if args.clean_icons and icons_dir.exists():
        shutil.rmtree(icons_dir)
    if args.clean_icons and web_icons_dir.exists():
        shutil.rmtree(web_icons_dir)
    icons_dir.mkdir(parents=True, exist_ok=True)
    web_icons_dir.mkdir(parents=True, exist_ok=True)

    quest_references = collect_quest_references(quests_dir)
    quest_references_by_namespace = group_references_by_namespace(quest_references)

    resources: dict[str, dict[str, Any]] = {}
    namespaces_summary: dict[str, dict[str, Any]] = {}
    duplicate_namespaces: dict[str, list[str]] = {}
    stats = Counter()

    jar_files = sorted(mods_dir.glob('*.jar'))
    stats['jarFiles'] = len(jar_files)
    stats['questReferences'] = len(quest_references)

    for jar_path in jar_files:
        try:
            with zipfile.ZipFile(jar_path) as archive:
                resolver = JarAssetResolver(archive)
                namespaces = resolver.discover_namespaces()
                metadata = parse_mod_metadata(archive)
                stats['namespacesDiscovered'] += len(namespaces)

                for namespace in namespaces:
                    referenced_ids = quest_references_by_namespace.get(namespace, set())
                    if not referenced_ids and not args.include_all:
                        continue

                    namespace_result = process_namespace(
                        resolver=resolver,
                        jar_path=jar_path,
                        namespace=namespace,
                        metadata=metadata,
                        locales=locales,
                        referenced_ids=referenced_ids,
                        icon_roots=(icons_dir, web_icons_dir),
                        include_all=args.include_all,
                    )
                    if not namespace_result['resources'] and not namespace_result['referencedIds']:
                        continue

                    if namespace in namespaces_summary:
                        duplicate_namespaces.setdefault(namespace, []).append(jar_path.name)
                    summary = namespaces_summary.setdefault(
                        namespace,
                        {
                            'namespace': namespace,
                            'jarFiles': [],
                            'mods': [],
                            'resourceCount': 0,
                            'referencedIds': [],
                            'unresolvedIds': [],
                        },
                    )
                    summary['jarFiles'].append(jar_path.name)
                    summary['mods'] = merge_mod_metadata(summary['mods'], namespace_result['mods'])
                    summary['resourceCount'] += len(namespace_result['resources'])
                    summary['referencedIds'] = sorted(
                        set(summary['referencedIds']) | set(namespace_result['referencedIds'])
                    )
                    summary['unresolvedIds'] = sorted(
                        set(summary['unresolvedIds']) | set(namespace_result['unresolvedIds'])
                    )

                    for resource in namespace_result['resources'].values():
                        merge_resource(resources, resource)

                    stats['resourcesResolved'] += len(namespace_result['resources'])
                    stats['iconsCopied'] += namespace_result['iconsCopied']
                    stats['unresolvedReferences'] += len(namespace_result['unresolvedIds'])
        except zipfile.BadZipFile:
            stats['badZipFiles'] += 1

    resolved_ids = set(resources.keys())
    missing_references = sorted(quest_references - resolved_ids)
    missing_namespaces = sorted({ref.split(':', 1)[0] for ref in missing_references})

    index = {
        'generatedAt': datetime.now(timezone.utc).isoformat(),
        'source': {
            'modsDir': relative_to_root(mods_dir, root),
            'questsDir': relative_to_root(quests_dir, root),
            'outputDir': relative_to_root(output_dir, root),
            'locales': locales,
            'referencedOnly': not args.include_all,
        },
        'stats': dict(stats),
        'resources': dict(sorted(resources.items())),
        'namespaces': dict(sorted(namespaces_summary.items())),
    }

    report = {
        'generatedAt': index['generatedAt'],
        'stats': index['stats'],
        'questReferences': sorted(quest_references),
        'missingReferences': missing_references,
        'missingNamespaces': missing_namespaces,
        'duplicateNamespaces': duplicate_namespaces,
        'notes': [
            'minecraft namespace resources are not included unless the Minecraft client jar or a vanilla resource pack is provided.',
            'Icons are resolved with best-effort heuristics from models and textures, and may not match complex dynamic in-game renders.',
        ],
    }

    write_json(output_dir / 'quest_assets_index.json', index)
    write_json(output_dir / 'build_report.json', report)

    print(
        f'Extracted {len(resources)} resources from {len(jar_files)} jar files. '
        f'Missing references: {len(missing_references)}.'
    )


class JarAssetResolver:
    def __init__(self, archive: zipfile.ZipFile) -> None:
        self.archive = archive
        self.entry_names = {info.filename for info in archive.infolist()}
        self._json_cache: dict[str, Any] = {}
        self._lang_cache: dict[str, dict[str, str]] = {}
        self._model_texture_cache: dict[tuple[str, str], dict[str, str]] = {}
        self.texture_entries: dict[str, str] = {}
        for entry_name in self.entry_names:
            if not entry_name.startswith('assets/'):
                continue
            if not entry_name.endswith('.png'):
                continue
            texture_id = texture_id_from_entry(entry_name)
            if texture_id:
                self.texture_entries[texture_id] = entry_name

    def discover_namespaces(self) -> list[str]:
        namespaces: set[str] = set()
        for entry_name in self.entry_names:
            if not entry_name.startswith('assets/'):
                continue
            parts = entry_name.split('/')
            if len(parts) >= 3 and parts[1]:
                namespaces.add(parts[1])
        return sorted(namespaces)

    def has_entry(self, entry_name: str) -> bool:
        return entry_name in self.entry_names

    def read_text(self, entry_name: str) -> str | None:
        if entry_name not in self.entry_names:
            return None
        with self.archive.open(entry_name) as handle:
            return handle.read().decode('utf-8', errors='replace')

    def read_json(self, entry_name: str) -> Any:
        if entry_name in self._json_cache:
            return self._json_cache[entry_name]
        payload = self.read_text(entry_name)
        if payload is None:
            self._json_cache[entry_name] = None
            return None
        try:
            data = json.loads(payload)
        except json.JSONDecodeError:
            data = None
        self._json_cache[entry_name] = data
        return data

    def load_lang_bundle(self, namespace: str, locale: str) -> dict[str, str]:
        cache_key = f'{namespace}:{locale}'
        if cache_key in self._lang_cache:
            return self._lang_cache[cache_key]

        for suffix in ('.json', '.lang'):
            entry_name = f'assets/{namespace}/lang/{locale}{suffix}'
            payload = self.read_text(entry_name)
            if payload is None:
                continue
            bundle = parse_lang_payload(payload, suffix)
            self._lang_cache[cache_key] = bundle
            return bundle

        self._lang_cache[cache_key] = {}
        return {}

    def has_item_resource(self, namespace: str, path: str) -> bool:
        return (
            self.has_entry(f'assets/{namespace}/models/item/{path}.json')
            or f'{namespace}:item/{path}' in self.texture_entries
            or self.has_entry(f'assets/{namespace}/models/block/{path}.json')
        )

    def has_block_resource(self, namespace: str, path: str) -> bool:
        return (
            self.has_entry(f'assets/{namespace}/blockstates/{path}.json')
            or self.has_entry(f'assets/{namespace}/models/block/{path}.json')
            or f'{namespace}:block/{path}' in self.texture_entries
        )

    def resolve_item_icon(self, namespace: str, path: str) -> tuple[str | None, str | None]:
        item_model = f'assets/{namespace}/models/item/{path}.json'
        if self.has_entry(item_model):
            texture_id = self._resolve_texture_from_model_entry(
                entry_name=item_model,
                default_namespace=namespace,
                priority=ITEM_TEXTURE_PRIORITY,
            )
            if texture_id:
                return texture_id, 'item_model'

        direct_texture = f'{namespace}:item/{path}'
        if direct_texture in self.texture_entries:
            return direct_texture, 'direct_item_texture'

        block_texture, resolution = self.resolve_block_icon(namespace, path)
        if block_texture:
            return block_texture, resolution or 'block_fallback'

        return None, None

    def resolve_block_icon(self, namespace: str, path: str) -> tuple[str | None, str | None]:
        blockstate_entry = f'assets/{namespace}/blockstates/{path}.json'
        if self.has_entry(blockstate_entry):
            blockstate = self.read_json(blockstate_entry)
            for model_ref in extract_blockstate_models(blockstate):
                texture_id = self._resolve_texture_from_model_ref(
                    model_ref=model_ref,
                    default_namespace=namespace,
                    priority=BLOCK_TEXTURE_PRIORITY,
                )
                if texture_id:
                    return texture_id, 'blockstate_model'

        block_model = f'assets/{namespace}/models/block/{path}.json'
        if self.has_entry(block_model):
            texture_id = self._resolve_texture_from_model_entry(
                entry_name=block_model,
                default_namespace=namespace,
                priority=BLOCK_TEXTURE_PRIORITY,
            )
            if texture_id:
                return texture_id, 'block_model'

        direct_texture = f'{namespace}:block/{path}'
        if direct_texture in self.texture_entries:
            return direct_texture, 'direct_block_texture'

        return None, None

    def copy_texture(
        self,
        texture_id: str,
        destination_roots: tuple[Path, ...],
        namespace: str,
        kind: str,
        path: str,
    ) -> str | None:
        entry_name = self.texture_entries.get(texture_id)
        if entry_name is None:
            return None

        asset_path: str | None = None
        for destination_root in destination_roots:
            destination = destination_root / namespace / f'{kind}s' / f'{path}.png'
            destination.parent.mkdir(parents=True, exist_ok=True)
            with self.archive.open(entry_name) as source, destination.open('wb') as target:
                shutil.copyfileobj(source, target)
            if asset_path is None:
                asset_path = as_asset_path(destination)
        return asset_path

    def _resolve_texture_from_model_ref(
        self,
        model_ref: str,
        default_namespace: str,
        priority: tuple[str, ...],
    ) -> str | None:
        namespace, model_path = qualify_resource_id(model_ref, default_namespace)
        return self._resolve_texture_from_model_entry(
            entry_name=f'assets/{namespace}/models/{model_path}.json',
            default_namespace=namespace,
            priority=priority,
        )

    def _resolve_texture_from_model_entry(
        self,
        entry_name: str,
        default_namespace: str,
        priority: tuple[str, ...],
    ) -> str | None:
        if not self.has_entry(entry_name):
            return None
        model_key = (default_namespace, entry_name)
        textures = self._model_texture_cache.get(model_key)
        if textures is None:
            textures = self._load_model_textures(entry_name=entry_name, default_namespace=default_namespace, seen=set())
            self._model_texture_cache[model_key] = textures
        return pick_texture_from_map(textures, priority, self.texture_entries)

    def _load_model_textures(
        self,
        entry_name: str,
        default_namespace: str,
        seen: set[str],
    ) -> dict[str, str]:
        cache_key = (default_namespace, entry_name)
        if cache_key in self._model_texture_cache:
            return dict(self._model_texture_cache[cache_key])
        if entry_name in seen:
            return {}
        seen.add(entry_name)

        model = self.read_json(entry_name)
        if not isinstance(model, dict):
            return {}

        textures: dict[str, str] = {}
        parent = model.get('parent')
        if isinstance(parent, str):
            parent_namespace, parent_model_path = qualify_resource_id(parent, default_namespace)
            parent_entry = f'assets/{parent_namespace}/models/{parent_model_path}.json'
            textures.update(
                self._load_model_textures(
                    entry_name=parent_entry,
                    default_namespace=parent_namespace,
                    seen=seen,
                )
            )

        raw_textures = model.get('textures')
        if isinstance(raw_textures, dict):
            for key, value in raw_textures.items():
                if not isinstance(key, str) or not isinstance(value, str):
                    continue
                if value.startswith('#'):
                    textures[key] = value
                else:
                    texture_namespace, texture_path = qualify_resource_id(value, default_namespace)
                    textures[key] = f'{texture_namespace}:{texture_path}'

        return textures


def process_namespace(
    *,
    resolver: JarAssetResolver,
    jar_path: Path,
    namespace: str,
    metadata: list[dict[str, Any]],
    locales: list[str],
    referenced_ids: set[str],
    icon_roots: tuple[Path, ...],
    include_all: bool,
) -> dict[str, Any]:
    lang_bundles = {locale: resolver.load_lang_bundle(namespace, locale) for locale in locales}
    resources = collect_resource_records(
        namespace=namespace,
        lang_bundles=lang_bundles,
        referenced_ids=referenced_ids,
        include_all=include_all,
        resolver=resolver,
        locales=locales,
    )

    icons_copied = 0
    unresolved_ids: list[str] = []
    for resource in resources.values():
        path = resource['path']
        kind = resource['kind']
        texture_id = None
        resolution = None
        if kind == 'item':
            texture_id, resolution = resolver.resolve_item_icon(namespace, path)
        elif kind == 'block':
            texture_id, resolution = resolver.resolve_block_icon(namespace, path)
        else:
            texture_id, resolution = resolver.resolve_item_icon(namespace, path)
            if texture_id:
                kind = 'item'
            else:
                texture_id, resolution = resolver.resolve_block_icon(namespace, path)
                if texture_id:
                    kind = 'block'

        resource['kind'] = kind
        if texture_id:
            asset_path = resolver.copy_texture(texture_id, icon_roots, namespace, kind, path)
            if asset_path:
                icons_copied += 1
                resource['iconAssetPath'] = asset_path
                resource['iconTextureId'] = texture_id
                resource['iconResolution'] = resolution
        else:
            unresolved_ids.append(resource['id'])

        resource['sourceJar'] = jar_path.name
        resource['sourceMods'] = metadata

    return {
        'mods': metadata,
        'resources': resources,
        'referencedIds': sorted(referenced_ids),
        'unresolvedIds': sorted(set(unresolved_ids)),
        'iconsCopied': icons_copied,
    }


def collect_resource_records(
    *,
    namespace: str,
    lang_bundles: dict[str, dict[str, str]],
    referenced_ids: set[str],
    include_all: bool,
    resolver: JarAssetResolver,
    locales: list[str],
) -> dict[str, dict[str, Any]]:
    resources: dict[str, dict[str, Any]] = {}

    for locale, bundle in lang_bundles.items():
        for key, value in bundle.items():
            match = LANG_KEY_RE.match(key)
            if match is None:
                continue
            kind, key_namespace, path = match.groups()
            if key_namespace != namespace:
                continue
            resource_id = f'{namespace}:{path}'
            if not include_all and resource_id not in referenced_ids:
                continue
            record = resources.setdefault(resource_id, make_resource_record(resource_id, namespace, path, kind))
            record['kind'] = kind
            record['localizedNames'][locale] = value
            record['translationKeys'].append(key)

    for resource_id in sorted(referenced_ids):
        if resource_id in resources:
            continue
        _, path = resource_id.split(':', 1)
        kind = 'item' if resolver.has_item_resource(namespace, path) else 'block' if resolver.has_block_resource(namespace, path) else 'unknown'
        resources[resource_id] = make_resource_record(resource_id, namespace, path, kind)

    for record in resources.values():
        record['translationKeys'] = sorted(set(record['translationKeys']))
        record['displayName'] = pick_display_name(record['localizedNames'], locales, record['path'])

    return resources


def make_resource_record(resource_id: str, namespace: str, path: str, kind: str) -> dict[str, Any]:
    return {
        'id': resource_id,
        'namespace': namespace,
        'path': path,
        'kind': kind,
        'displayName': path,
        'localizedNames': {},
        'translationKeys': [],
        'iconAssetPath': None,
        'iconTextureId': None,
        'iconResolution': None,
        'sourceJar': None,
        'sourceMods': [],
    }


def merge_resource(resources: dict[str, dict[str, Any]], incoming: dict[str, Any]) -> None:
    resource_id = incoming['id']
    existing = resources.get(resource_id)
    if existing is None:
        resources[resource_id] = incoming
        return

    existing['localizedNames'].update(incoming.get('localizedNames', {}))
    existing['translationKeys'] = sorted(
        set(existing.get('translationKeys', [])) | set(incoming.get('translationKeys', []))
    )
    if not existing.get('iconAssetPath') and incoming.get('iconAssetPath'):
        existing['iconAssetPath'] = incoming['iconAssetPath']
        existing['iconTextureId'] = incoming['iconTextureId']
        existing['iconResolution'] = incoming['iconResolution']
    if existing.get('kind') == 'unknown' and incoming.get('kind') != 'unknown':
        existing['kind'] = incoming['kind']
    if not existing.get('displayName') or existing.get('displayName') == existing.get('path'):
        existing['displayName'] = incoming.get('displayName', existing.get('displayName'))
    existing['sourceMods'] = merge_mod_metadata(existing.get('sourceMods', []), incoming.get('sourceMods', []))
    if not existing.get('sourceJar') and incoming.get('sourceJar'):
        existing['sourceJar'] = incoming['sourceJar']


def merge_mod_metadata(
    current: list[dict[str, Any]],
    incoming: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    merged: dict[str, dict[str, Any]] = {}
    for entry in current + incoming:
        mod_id = entry.get('modId') or entry.get('displayName') or repr(entry)
        merged[mod_id] = entry
    return [merged[key] for key in sorted(merged)]


def collect_quest_references(quests_dir: Path) -> set[str]:
    references: set[str] = set()
    for file_path in sorted(quests_dir.rglob('*.snbt')):
        content = file_path.read_text(encoding='utf-8', errors='replace')
        for match in NAMESPACED_ID_RE.finditer(content):
            raw_value = match.group(1)
            normalized = normalize_reference(raw_value)
            if normalized:
                references.add(normalized)
    return references


def group_references_by_namespace(references: set[str]) -> dict[str, set[str]]:
    grouped: dict[str, set[str]] = {}
    for reference in references:
        namespace, _ = reference.split(':', 1)
        grouped.setdefault(namespace, set()).add(reference)
    return grouped


def normalize_reference(raw_value: str) -> str | None:
    value = raw_value.strip().lstrip('#')
    if ':' not in value:
        return None
    namespace, path = value.split(':', 1)
    if not namespace or not path:
        return None
    return f'{namespace}:{path}'


def parse_mod_metadata(archive: zipfile.ZipFile) -> list[dict[str, Any]]:
    try:
        with archive.open('META-INF/mods.toml') as handle:
            payload = handle.read().decode('utf-8', errors='replace')
    except KeyError:
        return []

    try:
        data = tomllib.loads(payload)
    except Exception:
        return []

    mods = data.get('mods')
    if not isinstance(mods, list):
        return []

    metadata: list[dict[str, Any]] = []
    for entry in mods:
        if not isinstance(entry, dict):
            continue
        metadata.append(
            {
                'modId': entry.get('modId'),
                'displayName': entry.get('displayName'),
                'version': entry.get('version'),
                'authors': entry.get('authors'),
                'displayUrl': entry.get('displayURL'),
            }
        )
    return metadata


def parse_lang_payload(payload: str, suffix: str) -> dict[str, str]:
    if suffix == '.json':
        try:
            data = json.loads(payload)
        except json.JSONDecodeError:
            return {}
        if not isinstance(data, dict):
            return {}
        return {
            str(key): str(value)
            for key, value in data.items()
            if isinstance(key, str) and isinstance(value, (str, int, float))
        }

    bundle: dict[str, str] = {}
    for line in payload.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith('#') or '=' not in stripped:
            continue
        key, value = stripped.split('=', 1)
        bundle[key.strip()] = value.strip()
    return bundle


def extract_blockstate_models(blockstate: Any) -> list[str]:
    if not isinstance(blockstate, dict):
        return []
    models: list[str] = []

    variants = blockstate.get('variants')
    if isinstance(variants, dict):
        for candidate in variants.values():
            models.extend(extract_model_refs(candidate))

    multipart = blockstate.get('multipart')
    if isinstance(multipart, list):
        for entry in multipart:
            if isinstance(entry, dict):
                models.extend(extract_model_refs(entry.get('apply')))

    seen: set[str] = set()
    deduped: list[str] = []
    for model_ref in models:
        if model_ref not in seen:
            seen.add(model_ref)
            deduped.append(model_ref)
    return deduped


def extract_model_refs(candidate: Any) -> list[str]:
    if isinstance(candidate, dict):
        model = candidate.get('model')
        if isinstance(model, str):
            return [model]
        return []
    if isinstance(candidate, list):
        refs: list[str] = []
        for entry in candidate:
            refs.extend(extract_model_refs(entry))
        return refs
    return []


def qualify_resource_id(raw_value: str, default_namespace: str) -> tuple[str, str]:
    if ':' in raw_value:
        namespace, path = raw_value.split(':', 1)
        return namespace, path
    return default_namespace, raw_value


def pick_texture_from_map(
    textures: dict[str, str],
    priority: tuple[str, ...],
    texture_entries: dict[str, str],
) -> str | None:
    for key in priority:
        resolved = resolve_texture_reference(textures.get(key), textures)
        if resolved and resolved in texture_entries:
            return resolved
    for raw_value in textures.values():
        resolved = resolve_texture_reference(raw_value, textures)
        if resolved and resolved in texture_entries:
            return resolved
    return None


def resolve_texture_reference(value: str | None, textures: dict[str, str]) -> str | None:
    current = value
    visited: set[str] = set()
    while isinstance(current, str) and current.startswith('#'):
        alias = current[1:]
        if alias in visited:
            return None
        visited.add(alias)
        current = textures.get(alias)
    return current


def texture_id_from_entry(entry_name: str) -> str | None:
    if not entry_name.startswith('assets/') or '/textures/' not in entry_name or not entry_name.endswith('.png'):
        return None
    parts = entry_name.split('/')
    if len(parts) < 5:
        return None
    namespace = parts[1]
    texture_path = '/'.join(parts[3:])[:-4]
    return f'{namespace}:{texture_path}'


def pick_display_name(localized_names: dict[str, str], locales: list[str], fallback_path: str) -> str:
    for locale in locales:
        value = localized_names.get(locale)
        if value:
            return value
    if localized_names:
        first_key = sorted(localized_names)[0]
        return localized_names[first_key]
    return fallback_path.split('/')[-1]


def relative_to_root(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def as_asset_path(path: Path) -> str:
    marker = 'assets'
    parts = [part for part in path.parts if part]
    if marker in parts:
        index = parts.index(marker)
        return '/'.join(parts[index:])
    return path.as_posix()


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()

