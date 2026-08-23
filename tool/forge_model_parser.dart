import 'dart:convert';
import 'dart:io';

const forgeTextureKeys = <String>{
  'all',
  'side',
  'top',
  'bottom',
  'front',
  'back',
  'left',
  'right',
  'overlay_front',
  'overlay_back',
  'overlay_side',
  'overlay_top',
  'overlay_bottom',
  'overlay_front_emissive',
  'overlay_side_emissive',
  'overlay_top_emissive',
  'particle',
  'axis',
  'axis_top',
  'plates',
  'insert',
  'spruce_log_top',
};

class ForgeResourceStore {
  ForgeResourceStore({
    required this.modulesRoot,
    required this.resourceRoot,
    required this.moduleRoots,
  });

  final String modulesRoot;
  final String resourceRoot;
  final Map<String, String> moduleRoots;

  String? readResource(String namespace, String relativePath) {
    final relative = normalizeRelative(relativePath);
    if (relative.isEmpty) return null;
    final module = moduleRoots[namespace];
    if (module != null) {
      final generated = File(join(
        modulesRoot,
        module,
        'src/generated/resources/assets',
        namespace,
        relative,
      ));
      if (generated.existsSync()) return generated.readAsStringSync();
      final main = File(join(
        modulesRoot,
        module,
        'src/main/resources/assets',
        namespace,
        relative,
      ));
      if (main.existsSync()) return main.readAsStringSync();
    }
    final jar =
        File(join(resourceRoot, 'assets', namespace, relative));
    if (jar.existsSync()) return jar.readAsStringSync();
    return null;
  }

  String? readModel(String resource) {
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    var path = ref.path;
    if (path.startsWith('block/')) path = path.substring(6);
    final relative = 'models/$path.json';
    return readResource(ref.namespace, relative) ??
        readResource(ref.namespace, 'models/block/$path.json');
  }

  String? readBlockstate(String namespace, String block) {
    final relative = 'blockstates/$block.json';
    return readResource(namespace, relative);
  }

  String? readTexture(String resource) {
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    var path = ref.path.endsWith('.png') ? ref.path : ref.path + '.png';
    final shortPath = path.startsWith('block/')
        ? path.substring(6)
        : path;
    return readResource(ref.namespace, 'textures/$path') ??
        readResource(ref.namespace, 'textures/blocks/$shortPath') ??
        readResource(ref.namespace, 'textures/block/$shortPath');
  }

  String? readMcmeta(String resource) {
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    final path = ref.path.endsWith('.png')
        ? ref.path + '.mcmeta'
        : ref.path + '.png.mcmeta';
    final shortPath = path.startsWith('block/')
        ? path.substring(6)
        : path;
    return readResource(ref.namespace, 'textures/$path') ??
        readResource(ref.namespace, 'textures/blocks/$shortPath') ??
        readResource(ref.namespace, 'textures/block/$shortPath');
  }

  String? copyResource(
    String resource,
    String destinationPath, {
    String? sourcePath,
  }) {
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    final module = moduleRoots[ref.namespace];
    if (module != null) {
      for (final suffix in <String>[
        'src/generated/resources/assets',
        'src/main/resources/assets',
      ]) {
        final source = File(
          join(modulesRoot, module, suffix, ref.namespace, sourcePath ?? ref.path),
        );
        if (source.existsSync()) {
          final target = File(destinationPath);
          target.parent.createSync(recursive: true);
          source.copySync(target.path);
          return target.path;
        }
      }
    }
    final source = File(join(
      resourceRoot,
      'assets',
      ref.namespace,
      sourcePath ?? ref.path,
    ));
    if (source.existsSync()) {
      final target = File(destinationPath);
      target.parent.createSync(recursive: true);
      source.copySync(target.path);
      return target.path;
    }
    return null;
  }

  bool existsResource(String namespace, String relativePath) {
    return readResource(namespace, relativePath) != null;
  }

  List<String> listBlockstateIds(Iterable<String> namespaces) {
    final ids = <String>{};
    for (final namespace in namespaces) {
      final module = moduleRoots[namespace];
      if (module != null) {
        for (final suffix in <String>[
          'src/generated/resources/assets',
          'src/main/resources/assets',
        ]) {
          final directory = Directory(join(
            modulesRoot,
            module,
            suffix,
            namespace,
            'blockstates',
          ));
          if (!directory.existsSync()) continue;
          for (final file in directory.listSync(recursive: true)) {
            if (file is! File || !file.path.endsWith('.json')) continue;
            final block = file.path
                .split('/blockstates/')
                .last
                .replaceFirst('.json', '');
            ids.add('$namespace:$block');
          }
        }
      }
      final jarDirectory = Directory(
        join(resourceRoot, 'assets', namespace, 'blockstates'),
      );
      if (!jarDirectory.existsSync()) continue;
      for (final file in jarDirectory.listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.json')) continue;
        final block = file.path
            .split('/blockstates/')
            .last
            .replaceFirst('.json', '');
        ids.add('$namespace:$block');
      }
    }
    return ids.toList()..sort();
  }

  List<String> listModelResources(String namespace) {
    final resources = <String>{};
    void scan(Directory directory) {
      if (!directory.existsSync()) return;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        final relative = entity.path.split('/models/block/').last;
        final path = relative.substring(0, relative.length - 5);
        resources.add(resourceFor(namespace, 'block/' + path));
      }
    }
    final module = moduleRoots[namespace];
    if (module != null) {
      scan(Directory(join(
        modulesRoot,
        module,
        'src/generated/resources/assets',
        namespace,
        'models/block',
      )));
      scan(Directory(join(
        modulesRoot,
        module,
        'src/main/resources/assets',
        namespace,
        'models/block',
      )));
    }
    scan(Directory(join(resourceRoot, 'assets', namespace, 'models/block')));
    return resources.toList()..sort();
  }

  String? findModelResourceByBlock(String namespace, String block) {
    final target = normalizeResourceName(block);
    for (final resource in listModelResources(namespace)) {
      if (normalizeResourceName(resource) == target) return resource;
      final source = resolveModelSource(resource);
      if (source == null) continue;
      try {
        final data = jsonDecode(File(source).readAsStringSync());
        if (data is Map &&
            data['machine'] is String &&
            normalizeResourceName(data['machine'] as String) == target) {
          return resource;
        }
      } catch (_) {
        continue;
      }
    }
    if (block.toLowerCase().contains('battery')) {
      return _findBatteryModelResource(namespace);
    }
    return null;
  }

  String? _findBatteryModelResource(String namespace) {
    final resources = listModelResources(namespace)
        .where((resource) {
          final path = resource.split(':').last.toLowerCase();
          return path.contains('battery') &&
              !path.contains('buffer') &&
              !path.contains('empty');
        })
        .toList()
      ..sort((a, b) => _batteryTierRank(a).compareTo(_batteryTierRank(b)));
    if (resources.isEmpty) return null;
    return resources.first;
  }

  String? resolveObjSource(String resource) {
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    final candidates = <String>[
      ref.path,
      if (!ref.path.startsWith('models/')) 'models/' + ref.path,
      if (!ref.path.startsWith('models/block/')) 'models/block/' + ref.path,
    ];
    for (final candidate in candidates) {
      final module = moduleRoots[ref.namespace];
      if (module != null) {
        for (final suffix in <String>[
          'src/generated/resources/assets',
          'src/main/resources/assets',
        ]) {
          final source = File(join(
            modulesRoot,
            module,
            suffix,
            ref.namespace,
            candidate,
          ));
          if (source.existsSync()) return source.path;
        }
      }
      final source = File(join(resourceRoot, 'assets', ref.namespace, candidate));
      if (source.existsSync()) return source.path;
    }
    return null;
  }

  String? findTextureByBlock(String blockId) {
    final target = _textureName(blockId);
    String? match;
    for (final resource in listAllTextureResources()) {
      final name = _textureName(resource);
      if (name == target) {
        if (match != null && match != resource) return null;
        match = resource;
      }
    }
    return match;
  }

  List<String> listAllTextureResources() {
    final resources = <String>{};
    void scan(String namespace, Directory directory) {
      if (!directory.existsSync()) return;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.png')) continue;
        final parts = entity.path.split('/textures/');
        if (parts.length < 2) continue;
        resources.add(resourceFor(namespace, parts.last));
      }
    }
    final namespaces = <String>{...moduleRoots.keys};
    final cache = Directory('$resourceRoot/assets');
    if (cache.existsSync()) {
      for (final entity in cache.listSync()) {
        if (entity is! Directory) continue;
        namespaces.add(entity.path.split('/').last);
      }
    }
    for (final namespace in namespaces) {
      final module = moduleRoots[namespace];
      if (module != null) {
        scan(
          namespace,
          Directory(join(
            modulesRoot,
            module,
            'src/generated/resources/assets',
            namespace,
            'textures',
          )),
        );
        scan(
          namespace,
          Directory(join(
            modulesRoot,
            module,
            'src/main/resources/assets',
            namespace,
            'textures',
          )),
        );
      }
      scan(namespace, Directory(join(resourceRoot, 'assets', namespace, 'textures')));
    }
    return resources.toList()..sort();
  }

  String? resolveModelSource(String resource) {
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    var path = ref.path;
    if (path.startsWith('block/')) path = path.substring(6);
    final candidates = <String>[
      'models/$path.json',
      'models/block/$path.json',
      'models/item/$path.json',
    ];
    for (final candidate in candidates) {
      final module = moduleRoots[ref.namespace];
      if (module != null) {
        for (final suffix in <String>[
          'src/generated/resources/assets',
          'src/main/resources/assets',
        ]) {
          final source = File(join(
            modulesRoot,
            module,
            suffix,
            ref.namespace,
            candidate,
          ));
          if (source.existsSync()) return source.path;
        }
      }
      final source = File(join(resourceRoot, 'assets', ref.namespace, candidate));
      if (source.existsSync()) return source.path;
    }
    return null;
  }
}

class ForgeResourceReference {
  const ForgeResourceReference(this.namespace, this.path);

  final String namespace;
  final String path;
}

bool isVoidTexture(String value) {
  final path = value.split(':').last;
  return path == 'void' || path.endsWith('/void');
}

String _textureName(String value) {
  var path = value.split(':').last;
  path = path.replaceFirst(RegExp('^textures/'), '');
  path = path.replaceFirst(RegExp('^block/'), '');
  if (path.contains('/')) path = path.split('/').last;
  if (path.endsWith('.png')) path = path.substring(0, path.length - 4);
  if (path.contains('_ctm') ||
      path.contains('_connected') ||
      path.contains('_active') ||
      path.contains('_emissive')) {
    return '';
  }
  return path.replaceAll('_', '');
}

int _batteryTierRank(String resource) {
  const order = <String>[
    'ulv',
    'lv',
    'mv',
    'hv',
    'ev',
    'iv',
    'luv',
    'zpm',
    'uv',
    'uhv',
    'uxv',
    'opv',
    'max',
  ];
  final path = resource.split(':').last.toLowerCase();
  for (var index = 0; index < order.length; index++) {
    if (RegExp('(^|_)' + order[index] + '(_|\$)').hasMatch(path)) {
      return index;
    }
  }
  return order.length;
}

String normalizeResourceName(String value) {
  var path = value.split(':').last;
  path = path.replaceFirst(RegExp('^block/'), '');
  path = path.replaceFirst(RegExp('^machine/'), '');
  final compact = path.replaceAll('_', '');
  for (final suffix in <String>[
    'block',
    'casing',
    'battery',
    'frame',
    'hatch',
    'box',
    'machine',
  ]) {
    if (compact.endsWith(suffix) && compact.length > suffix.length) {
      return compact.substring(0, compact.length - suffix.length);
    }
  }
  return compact;
}

ForgeResourceReference? parseResourceLocation(
  String value,
  String defaultNamespace,
) {
  if (value.isEmpty || value.startsWith('#')) return null;
  final parts = value.split(':');
  if (parts.length == 2) {
    return ForgeResourceReference(parts[0], parts[1]);
  }
  if (parts.length == 1) {
    return ForgeResourceReference(defaultNamespace, parts[0]);
  }
  return null;
}

String normalizeRelative(String value) {
  while (value.startsWith('/')) {
    value = value.substring(1);
  }
  while (value.contains('..')) {
    value = value.replaceAll('..', '');
  }
  return value;
}

String join(
  String a,
  String b,
  String c,
  String d, [
  String? e,
]) {
  return e == null ? '$a/$b/$c/$d' : '$a/$b/$c/$d/$e';
}

class ResolvedForgeModel {
  const ResolvedForgeModel({
    required this.resource,
    this.source,
    this.parent,
    this.textures = const {},
    this.textureOverrides = const {},
    this.chain = const [],
    this.objResource,
    this.elements = const [],
  });

  final String? resource;
  final String? source;
  final String? parent;
  final Map<String, String> textures;
  final Map<String, String> textureOverrides;
  final List<String> chain;
  final String? objResource;
  final List<Map<String, dynamic>> elements;
}

class ForgeBlockstate {
  const ForgeBlockstate({
    this.modelResource,
    this.inlineModel,
    this.source,
    this.rotationX = 0,
    this.rotationY = 0,
    this.rotationZ = 0,
  });

  final String? modelResource;
  final Map<String, dynamic>? inlineModel;
  final String? source;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
}

class ForgeModelParser {
  ForgeModelParser(this.store);

  final ForgeResourceStore store;
  final Map<String, ResolvedForgeModel> _modelCache = {};

  ForgeBlockstate? resolveBlockstate(String namespace, String block) {
    final source = store.readBlockstate(namespace, block);
    if (source == null) {
      final modelResource = store.findModelResourceByBlock(namespace, block);
      if (modelResource != null) {
        return ForgeBlockstate(
          modelResource: modelResource,
          source: store.resolveModelSource(modelResource),
        );
      }
      return null;
    }
    final data = jsonDecode(source) as Map<String, dynamic>;
    final variant = selectVariant(
      data['variants'],
      _preferredVariantKey(block, data['variants']),
    );
    if (variant != null) {
      final rotation = _variantRotation(variant);
      final model = variant['model'];
      if (model is String && model.isNotEmpty) {
        return ForgeBlockstate(
          modelResource: model,
          source: store.resolveModelSource(resourceFor(namespace, model)),
          rotationX: rotation['x']!,
          rotationY: rotation['y']!,
          rotationZ: rotation['z']!,
        );
      }
      if (model is Map<String, dynamic>) {
        return ForgeBlockstate(
          inlineModel: model,
          source: store.resolveModelSource(resourceFor(namespace, '')),
          rotationX: rotation['x']!,
          rotationY: rotation['y']!,
          rotationZ: rotation['z']!,
        );
      }
      final modelList = variant['model'];
      if (modelList is List && modelList.isNotEmpty) {
        final first = modelList.first;
        if (first is String) {
          return ForgeBlockstate(
            modelResource: first,
            source: store.resolveModelSource(resourceFor(namespace, first)),
            rotationX: rotation['x']!,
            rotationY: rotation['y']!,
            rotationZ: rotation['z']!,
          );
        }
      }
    }
    final multipart = data['multipart'];
    if (multipart is List) {
      for (final part in multipart) {
        if (part is! Map) continue;
        final model = part['model'];
        if (model is String && model.isNotEmpty) {
          return ForgeBlockstate(
            modelResource: model,
            source: store.resolveModelSource(resourceFor(namespace, model)),
          );
        }
      }
    }
    return null;
  }

  ResolvedForgeModel? resolveModel(
    String resource, {
    Set<String>? visited,
  }) {
    if (resource.isEmpty || resource.startsWith('#')) return null;
    final cached = _modelCache[resource];
    if (cached != null) return cached;
    final ref = parseResourceLocation(resource, 'minecraft');
    if (ref == null) return null;
    final source = store.readModel(resource);
    if (source == null) {
      if (resource.contains('minecraft:block/')) {
        return const ResolvedForgeModel(resource: '');
      }
      return null;
    }
    final data = jsonDecode(source) as Map<String, dynamic>;
    final nextVisited = <String>{...?visited, resource};
    final resolved = _resolveJson(resource, data, nextVisited);
    _modelCache[resource] = resolved;
    return resolved;
  }

  ResolvedForgeModel _resolveJson(
    String resource,
    Map<String, dynamic> data,
    Set<String> visited,
  ) {
    final variants = data['variants'];
    if (variants is Map && variants.isNotEmpty) {
      final model = _selectedInlineModel(variants);
      if (model is Map) {
        final inline = Map<String, dynamic>.from(model);
        final topOverrides = data['texture_overrides'];
        if (topOverrides is Map) {
          inline['texture_overrides'] = topOverrides;
        }
        return _resolveInline(resource, inline, visited);
      }
    }
    return _resolveInline(resource, data, visited);
  }

  ResolvedForgeModel _resolveInline(
    String resource,
    Map<String, dynamic> data,
    Set<String> visited,
  ) {
    final parentValue = data['parent'];
    final parent = parentValue is String ? parentValue : null;
    var textures = <String, String>{};
    var overrides = <String, String>{};
    var elements = <Map<String, dynamic>>[];
    if (parent != null && !visited.contains(parent)) {
      final resolvedParent = resolveModel(parent, visited: visited);
      if (resolvedParent != null) {
        textures = Map<String, String>.from(resolvedParent.textures);
        overrides = Map<String, String>.from(resolvedParent.textureOverrides);
        elements.addAll(resolvedParent.elements);
      }
    }
    final localTextures = stringMap(data['textures']);
    for (final entry in localTextures.entries) {
      final value = resolveTextureReference(entry.value, textures, 'minecraft');
      if (value != null) textures[entry.key] = value;
    }
    _inferElementTextures(data, textures, 'minecraft');
    final children = data['children'];
    if (children is Map && children.isNotEmpty) {
      for (final childEntry in children.entries) {
        final child = childEntry.value;
        if (child is! Map) continue;
        final childResolved = _resolveInline(
          resource + '/child/' + childEntry.key.toString(),
          Map<String, dynamic>.from(child),
          visited,
        );
        textures.addAll(childResolved.textures);
        overrides.addAll(childResolved.textureOverrides);
      }
    }
    final localOverrides = stringMap(data['texture_overrides']);
    overrides.addAll(localOverrides);
    final resolvedOverrides = <String, String>{};
    for (final entry in overrides.entries) {
      final value = resolveTextureReference(entry.value, textures, 'minecraft');
      if (value != null && !isVoidTexture(value)) {
        resolvedOverrides[entry.key] = value;
      }
    }
    final filtered = <String, String>{};
    for (final entry in textures.entries) {
      if ((forgeTextureKeys.contains(entry.key) ||
              entry.key.startsWith('overlay_')) &&
          !isVoidTexture(entry.value)) {
        filtered[entry.key] = entry.value;
      }
    }
    final source = store.resolveModelSource(resource);
    elements.addAll(_modelElements(data));
    return ResolvedForgeModel(
      resource: resource,
      source: source,
      parent: parent,
      textures: filtered,
      textureOverrides: resolvedOverrides,
      chain: [...resolveModelChain(parent, visited)],
      objResource: _objResource(data),
      elements: elements,
    );
  }

  List<Map<String, dynamic>> _modelElements(Map<String, dynamic> data) {
    final raw = data['elements'];
    if (raw is! List) return const [];
    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      }
    }
    return result;
  }

  String? _objResource(Map<String, dynamic> data) {
  final model = data['model'];
  if (model is! String || !model.toLowerCase().endsWith('.obj')) return null;
  return model;
}

Map<String, double> _variantRotation(dynamic variant) {
  if (variant is! Map) return {'x': 0, 'y': 0, 'z': 0};
  double read(String key) {
    final value = variant[key];
    return value is num ? value.toDouble() : 0;
  }
  return {'x': read('x'), 'y': read('y'), 'z': read('z')};
}

String? _preferredVariantKey(String block, dynamic variants) {
  if (block == 'crushing_wheel' && variants is Map) {
    for (final key in variants.keys) {
      if (key.toString().startsWith('axis=z')) return key.toString();
    }
  }
  if (variants is Map) {
    for (final key in variants.keys) {
      final value = key.toString();
      if (value.contains('facing=south') &&
          value.contains('upwards_facing=north')) {
        return key.toString();
      }
    }
    for (final key in variants.keys) {
      final value = key.toString();
      if (value.contains('facing=south') &&
          !value.contains('upwards_facing=')) {
        return key.toString();
      }
    }
    for (final key in variants.keys) {
      if (key.toString().contains('facing=south')) return key.toString();
    }
  }
  return null;
}

dynamic _selectedInlineModel(Map variants) {
    for (final key in variantKeys(variants)) {
      final value = variants[key];
      if (value is Map && value['model'] is Map) {
        return value['model'];
      }
    }
    return null;
  }
}

void _inferElementTextures(
  Map<String, dynamic> data,
  Map<String, String> textures,
  String defaultNamespace,
) {
  final elements = data['elements'];
  if (elements is! List) return;
  final variables = stringMap(data['textures']);
  for (final element in elements) {
    if (element is! Map) continue;
    final faces = element['faces'];
    if (faces is! Map) continue;
    for (final faceName in faces.keys) {
      final face = faces[faceName];
      if (face is! Map || face['texture'] is! String) continue;
      final reference = face['texture'] as String;
      if (!reference.startsWith('#')) continue;
      final key = reference.substring(1);
      final raw = variables[key];
      if (raw == null) continue;
      final resolved = resolveTextureReference(raw, textures, defaultNamespace);
      if (resolved == null) continue;
      textures.putIfAbsent('all', () => resolved);
      final direction = faceName.toString();
      if (direction == 'north' || direction == 'south' || direction == 'east' || direction == 'west') {
        textures.putIfAbsent('side', () => resolved);
        if (direction == 'north') textures.putIfAbsent('front', () => resolved);
        if (direction == 'south') textures.putIfAbsent('back', () => resolved);
      } else if (direction == 'up') {
        textures.putIfAbsent('top', () => resolved);
      } else if (direction == 'down') {
        textures.putIfAbsent('bottom', () => resolved);
      }
    }
  }
}

String? resolveTextureReference(
  String value,
  Map<String, String> textures,
  String defaultNamespace,
) {
  if (value.startsWith('#')) {
    return textures[value.substring(1)];
  }
  final ref = parseResourceLocation(value, defaultNamespace);
  return ref == null ? null : resourceFor(ref.namespace, ref.path);
}

String resourceFor(String namespace, String path) {
  return '$namespace:$path';
}

List<String> resolveModelChain(String? parent, Set<String> visited) {
  if (parent == null || parent.startsWith('#') || parent.startsWith('minecraft:')) {
    return const [];
  }
  return [parent];
}

dynamic selectVariant(dynamic variants, [String? preferredKey]) {
  if (preferredKey != null && variants is Map && variants[preferredKey] != null) {
    return variants[preferredKey];
  }
  if (variants == null) return null;
  if (variants is List) {
    for (final value in variants) {
      if (value is Map && value['model'] != null) return value;
    }
    return null;
  }
  if (variants is! Map || variants.isEmpty) return null;
  for (final key in variantKeys(variants)) {
    final value = variants[key];
    if (value is Map && value['model'] != null) return value;
    if (value is List && value.isNotEmpty) return value;
  }
  return variants.values.first;
}

List<String> variantKeys(Map variants) {
  final keys = variants.keys.map((key) => key.toString()).toList();
  keys.sort((a, b) {
    final rankA = variantRank(a);
    final rankB = variantRank(b);
    if (rankA != rankB) return rankA.compareTo(rankB);
    return a.compareTo(b);
  });
  return keys;
}

int variantRank(String key) {
  if (key.isEmpty) return 0;
  if (key.contains('idle')) return 1;
  if (key.contains('false')) return 2;
  if (key.contains('true')) return 3;
  return 4;
}

Map<String, String> stringMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map(
    (key, item) => MapEntry(key.toString(), item.toString()),
  );
}
