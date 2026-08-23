import 'dart:convert';
import 'dart:io';

import 'forge_model_parser.dart';

const _moduleRoots = <String, String>{
  'ctnhcore': 'modules/CTNH-Core',
  'ctnhenergy': 'modules/CTNH-Energy',
  'ctnhbio': 'modules/CTNH-Bio',
  'ctnhmana': 'modules/CTNH-Mana',
  'ctnhastral': 'modules/CTNH-Astral',
  'ctpp': 'modules/CTPP',
  'gtceu': 'modules/GregTech-Modern',
};

const _catalogFiles = <String>[
  'lib/features/structure_preview/data/structure_preview_catalog.dart',
  'lib/features/home/data/tech_structure_preview_data.dart',
];

void main() {
  final modulesRoot = Platform.environment['CTNH_MODULES_ROOT'] ?? '${Directory.current.parent.path}/CTNH-Modules';
  final resourceRoot = Platform.environment['FORGE_RESOURCE_CACHE'] ?? '$modulesRoot/.wiki-build/forge-resources';
  final assetRoot = Directory('$modulesRoot/../CTNH-WIKI/assets/textures/modules/auto');
  final modelRoot = Directory('$modulesRoot/../CTNH-WIKI/assets/models/modules/auto');
  assetRoot.createSync(recursive: true);
  modelRoot.createSync(recursive: true);
  _clearGenerated(assetRoot, modelRoot);

  final store = ForgeResourceStore(
    modulesRoot: modulesRoot,
    resourceRoot: resourceRoot,
    moduleRoots: _moduleRoots,
  );
  final parser = ForgeModelParser(store);
  final blockIds = _collectTargetBlockIds();
  final entries = <String, Map<String, Object?>>{};
  final missing = <String>{};

  for (final blockId in blockIds) {
    final entry = _resolveBlock(
      blockId,
      store,
      parser,
      assetRoot,
      modelRoot,
      missing,
    );
    if (entry != null) entries[blockId] = entry;
  }

  final output = File('lib/features/structure_preview/data/structure_texture_manifest.g.dart');
  output.writeAsStringSync(_generateDart(entries));
  print('generated ${entries.length} texture entries');
  print('missing resources ${missing.length}');
  for (final item in missing) {
    stderr.writeln('missing resource: $item');
  }
  print(output.absolute.path);
}

Set<String> _collectTargetBlockIds() {
  final ids = _collectCatalogBlockIds();
  ids.remove('minecraft:air');
  return ids;
}

Set<String> _collectCatalogBlockIds() {
  final ids = <String>{};
  const marker = "blockId: '";
  for (final path in _catalogFiles) {
    final file = File(path);
    if (!file.existsSync()) continue;
    for (final line in file.readAsLinesSync()) {
      final start = line.indexOf(marker);
      if (start < 0) continue;
      final end = line.indexOf("'", start + marker.length);
      if (end > start) ids.add(line.substring(start + marker.length, end));
    }
  }
  return ids;
}

void _clearGenerated(Directory assetRoot, Directory modelRoot) {
  final iconDir = Directory('${assetRoot.path}/icons');
  final iconBackup = Directory('${assetRoot.path}/.icons-backup');
  if (iconDir.existsSync()) {
    if (iconBackup.existsSync()) iconBackup.deleteSync(recursive: true);
    iconDir.renameSync(iconBackup.path);
  }
  if (assetRoot.existsSync()) assetRoot.deleteSync(recursive: true);
  if (modelRoot.existsSync()) modelRoot.deleteSync(recursive: true);
  assetRoot.createSync(recursive: true);
  modelRoot.createSync(recursive: true);
  if (iconBackup.existsSync()) {
    iconBackup.renameSync(iconDir.path);
  }
}

Map<String, Object?>? _resolveBlock(
  String blockId,
  ForgeResourceStore store,
  ForgeModelParser parser,
  Directory assetRoot,
  Directory modelRoot,
  Set<String> missing,
) {
  final parts = blockId.split(':');
  if (parts.length != 2) return null;
  final namespace = parts[0];
  final blockPath = parts[1];
  final blockstate = parser.resolveBlockstate(namespace, blockPath);
  final discoveredModel = blockstate?.modelResource ??
      resourceFor(namespace, blockPath);
  final modelResource = _candidateModelResource(blockId, discoveredModel);

  final resolved = parser.resolveModel(modelResource);
  final textures = <String, String>{
    ...resolved?.textures ?? const <String, String>{},
    ...resolved?.textureOverrides ?? const <String, String>{},
  };

  final baseResource = _textureResource(textures, 'all') ??
      _textureResource(textures, 'side') ??
      _textureResource(textures, 'top') ??
      _textureResource(textures, 'bottom') ??
      (resolved?.objResource == null
          ? null
          : _textureResource(textures, 'plates') ??
              _textureResource(textures, 'insert'));
  if (baseResource == null) {
    final textureResource = store.findTextureByBlock(blockId);
    if (textureResource != null) {
      final textureAsset = _copyTexture(store, textureResource, assetRoot);
      if (textureAsset != null) {
        return {
          'base': textureAsset,
          'faces': {'all': textureAsset},
          'rotationX': 0,
          'rotationY': 0,
          'rotationZ': 0,
          'source': 'generated:texture-only:$textureResource',
        };
      }
      missing.add('$blockId:texture:$textureResource');
    } else {
      missing.add('$blockId:base');
    }
    return null;
  }

  final faceSources = <String, String>{...textures};
  if (!faceSources.containsKey('all')) faceSources['all'] = baseResource;
  final faceAssets = <String, String>{};
  for (final entry in faceSources.entries) {
    final asset = _copyTexture(store, entry.value, assetRoot);
    if (asset != null) {
      faceAssets[entry.key] = asset;
    } else {
      missing.add('$blockId:${entry.key}:${entry.value}');
    }
  }

  final baseAsset = faceAssets['all'];
  final front = faceSources['overlay_front'];
  final frontAsset = front == null ? null : _copyTexture(store, front, assetRoot);
  if (front != null && frontAsset == null) missing.add('$blockId:overlay_front:$front');

  final connectionResource = _connectionResource(store, baseResource);
  final connectionAsset = connectionResource == null
      ? null
      : _copyTexture(store, connectionResource, assetRoot);
  if (connectionResource != null && connectionAsset == null) {
    missing.add('$blockId:connection:$connectionResource');
  }

  final objResource = resolved?.objResource;
  final objAsset = objResource == null
      ? null
      : _copyObjResource(store, objResource, modelRoot);
  if (objResource != null && objAsset == null) {
    missing.add('$blockId:obj:$objResource');
  }

  final modelAsset = _copyModelResource(store, modelResource, modelRoot);
  final blockstateAsset = _copyBlockstateResource(
    store,
    namespace,
    blockPath,
    modelRoot,
  );
  if (modelAsset == null && blockstate != null) {
    missing.add('$blockId:model:$modelResource');
  }

  return {
    'base': baseAsset,
    if (frontAsset != null) 'front': frontAsset,
    if (connectionAsset != null) 'connection': connectionAsset,
    'faces': faceAssets,
    if (objAsset != null) 'obj': objAsset,
    if (modelAsset != null) 'model': modelAsset,
    if (blockstateAsset != null) 'blockstate': blockstateAsset,
    if (modelAsset != null) 'modelData': _modelData(store, modelResource, parser),
    'rotationX': blockstate?.rotationX ?? 0,
    'rotationY': blockstate?.rotationY ?? 0,
    'rotationZ': blockstate?.rotationZ ?? 0,
    'source': blockstate?.source ?? resolved?.source ?? 'generated:resource-location',
  };
}

String _candidateModelResource(String blockId, String fallback) {
  return switch (blockId) {
    'ctpp:kinetic_input_box' => 'ctpp:block/machine/lv_kinetic_input_box',
    'ctpp:mechanical_upgrade_bus' => 'ctpp:block/machine/mechanical_upgrade_bus',
    'gtceu:item_import_bus' => 'gtceu:block/machine/lv_input_bus',
    'gtceu:item_export_bus' => 'gtceu:block/machine/lv_output_bus',
    'gtceu:energy_input_hatch' => 'gtceu:block/machine/lv_energy_input_hatch',
    'gtceu:energy_output_hatch' => 'gtceu:block/machine/lv_energy_output_hatch',
    'gtceu:hv_energy_input_hatch' => 'gtceu:block/machine/hv_energy_input_hatch',
    'gtceu:hv_energy_output_hatch' => 'gtceu:block/machine/hv_energy_output_hatch',
    'gtceu:ev_substation_input_hatch_64a' =>
        'gtceu:block/machine/ev_substation_input_hatch_64a',
    'gtceu:ev_substation_output_hatch_64a' =>
        'gtceu:block/machine/ev_substation_output_hatch_64a',
    'gtceu:maintenance_hatch' => 'gtceu:block/machine/maintenance_hatch',
    'gtceu:iv_256a_laser_source_hatch' =>
        'gtceu:block/machine/iv_256a_laser_source_hatch',
    'gtceu:iv_256a_laser_target_hatch' =>
        'gtceu:block/machine/iv_256a_laser_target_hatch',
    _ => fallback,
  };
}

String? _textureResource(Map<String, String> textures, String key) {
  if (textures.containsKey(key) && textures[key]!.isNotEmpty) {
    return textures[key];
  }
  return null;
}

String? _connectionResource(ForgeResourceStore store, String baseResource) {
  final meta = store.readMcmeta(baseResource);
  if (meta == null) return null;
  try {
    final data = jsonDecode(meta) as Map<String, dynamic>;
    final ldlib = data['ldlib'];
    if (ldlib is Map && ldlib['connection'] is String) {
      return ldlib['connection'] as String;
    }
  } catch (error) {
    stderr.writeln('failed to parse mcmeta $baseResource: $error');
  }
  return null;
}

String? _copyTexture(
  ForgeResourceStore store,
  String resource,
  Directory assetRoot,
) {
  final ref = parseResourceLocation(resource, 'minecraft');
  if (ref == null) return null;
  final path = ref.path.endsWith('.png') ? ref.path : ref.path + '.png';
  final baseName = ref.namespace + '_' + ref.path.replaceAll('/', '_');
  final fileName = baseName + (ref.path.endsWith('.png') ? '' : '.png');
  final target = assetRoot.path + '/' + fileName;
  final shortPath = path.startsWith('block/')
      ? path.substring(6)
      : path;
  final sourcePaths = <String>[
    'textures/' + path,
    'textures/blocks/' + shortPath,
    'textures/block/' + shortPath,
  ];
  String? copied;
  for (final sourcePath in sourcePaths) {
    copied = store.copyResource(resource, target, sourcePath: sourcePath);
    if (copied != null) break;
  }
  if (copied == null) return null;
  return 'assets/textures/modules/auto/' + fileName;
}

String? _modelData(
  ForgeResourceStore store,
  String resource,
  ForgeModelParser parser,
) {
  final resolved = parser.resolveModel(resource);
  if (resolved == null || resolved.elements.isEmpty) return null;
  final source = store.resolveModelSource(resource);
  try {
    final data = source == null ? null : jsonDecode(File(source).readAsStringSync());
    return jsonEncode({
      'texture_size': data is Map ? data['texture_size'] : <int>[16, 16],
      'textures': resolved.textures,
      'elements': resolved.elements,
    });
  } catch (_) {
    return null;
  }
}

String? _copyObjResource(
  ForgeResourceStore store,
  String resource,
  Directory modelRoot,
) {
  final source = store.resolveObjSource(resource);
  if (source == null) return null;
  final ref = parseResourceLocation(resource, 'minecraft');
  if (ref == null) return null;
  final sourcePath = ref.path.endsWith('.obj')
      ? ref.path.substring(0, ref.path.length - 4)
      : ref.path;
  final fileName = ref.namespace + '_' + sourcePath.replaceAll('/', '_') + '.obj';
  final target = File(modelRoot.path + '/' + fileName);
  File(source).copySync(target.path);
  return 'assets/models/modules/auto/' + fileName;
}

String? _copyModelResource(
  ForgeResourceStore store,
  String resource,
  Directory modelRoot,
) {
  final source = store.resolveModelSource(resource);
  if (source == null) return null;
  final ref = parseResourceLocation(resource, 'minecraft');
  if (ref == null) return null;
  final fileName = ref.namespace + '_' + ref.path.replaceAll('/', '_') + '.json';
  final target = File(modelRoot.path + '/' + fileName);
  File(source).copySync(target.path);
  return 'assets/models/modules/auto/' + fileName;
}

String? _copyBlockstateResource(
  ForgeResourceStore store,
  String namespace,
  String block,
  Directory modelRoot,
) {
  final sourcePath = 'blockstates/' + block + '.json';
  if (!store.existsResource(namespace, sourcePath)) return null;
  final fileName = namespace + '_blockstate_' + block.replaceAll('/', '_') + '.json';
  final target = modelRoot.path + '/' + fileName;
  final copied = store.copyResource(
    resourceFor(namespace, block),
    target,
    sourcePath: sourcePath,
  );
  return copied == null ? null : 'assets/models/modules/auto/' + fileName;
}

String _generateDart(Map<String, Map<String, Object?>> entries) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED by tool/generate_structure_texture_manifest.dart.')
    ..writeln('// Do not edit manually; rerun the generator after resource changes.')
    ..writeln()
    ..writeln('class StructureTextureDefinition {')
    ..writeln('  const StructureTextureDefinition({')
    ..writeln('    required this.base,')
    ..writeln('    this.front,')
    ..writeln('    this.connection,')
    ..writeln('    this.textures = const {},')
    ..writeln('    this.model,')
    ..writeln('    this.blockstate,')
    ..writeln('    this.obj,')
    ..writeln('    this.modelData,')
    ..writeln('    this.rotationX = 0,')
    ..writeln('    this.rotationY = 0,')
    ..writeln('    this.rotationZ = 0,')
    ..writeln('    required this.source,')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String base;')
    ..writeln('  final String? front;')
    ..writeln('  final String? connection;')
    ..writeln('  final Map<String, String> textures;')
    ..writeln('  final String? model;')
    ..writeln('  final String? blockstate;')
    ..writeln('  final String? obj;')
    ..writeln('  final String? modelData;')
    ..writeln('  final double rotationX;')
    ..writeln('  final double rotationY;')
    ..writeln('  final double rotationZ;')
    ..writeln('  final String source;')
    ..writeln('}')
    ..writeln()
    ..writeln('const structureTextureManifest = <String, StructureTextureDefinition>{');
  final sorted = entries.keys.toList()..sort();
  for (final blockId in sorted) {
    final entry = entries[blockId]!;
    buffer
      ..writeln("  '$blockId': StructureTextureDefinition(")
      ..writeln("    base: '" + entry['base'].toString() + "',")
      ..writeln("    front: " + _quoteNullable(entry['front']) + ",")
      ..writeln("    connection: " + _quoteNullable(entry['connection']) + ",")
      ..writeln('    textures: {')
      ..writeln(_generateFaces(entry['faces']))
      ..writeln('    },')
      ..writeln("    model: " + _quoteNullable(entry['model']) + ",")
      ..writeln("    blockstate: " + _quoteNullable(entry['blockstate']) + ",")
      ..writeln("    obj: " + _quoteNullable(entry['obj']) + ",")
      ..writeln("    modelData: " + _quoteJson(entry['modelData']) + ",")
      ..writeln("    rotationX: " + entry['rotationX'].toString() + ",")
      ..writeln("    rotationY: " + entry['rotationY'].toString() + ",")
      ..writeln("    rotationZ: " + entry['rotationZ'].toString() + ",")
      ..writeln("    source: '" + entry['source'].toString() + "',")
      ..writeln('  ),');
  }
  buffer.writeln('};');
  return buffer.toString();
}

String _generateFaces(Object? faces) {
  if (faces is! Map || faces.isEmpty) return '';
  final buffer = StringBuffer();
  final keys = faces.keys.map((key) => key.toString()).toList()..sort();
  for (final key in keys) {
    buffer.writeln("      '" + key + "': '" + faces[key].toString() + "',");
  }
  return buffer.toString().trimRight();
}

String _quoteNullable(Object? value) =>
    value == null ? 'null' : "'" + value.toString() + "'";

String _quoteJson(Object? value) =>
    value == null ? 'null' : jsonEncode(value as String);
