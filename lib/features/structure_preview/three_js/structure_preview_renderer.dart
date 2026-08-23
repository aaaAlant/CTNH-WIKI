import 'dart:convert';
import 'dart:math' as math;

import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_scene_builder.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_texture_cache.dart';
import 'package:three_js/three_js.dart' as three;

class StructurePreviewRenderer {
  StructurePreviewRenderer(this.threeJs);

  final three.ThreeJS threeJs;
  final Map<String, List<three.Mesh>> _partMeshes = {};
  final Map<String, List<three.Mesh>> _layerMeshes = {};
  final List<three.Object3D> _interactiveObjects = [];
  final List<three.Object3D> _hitObjects = [];
  final Set<String> _focusedPartIds = <String>{};
  final StructureTextureCache _textureCache = StructureTextureCache();

  three.Group? _selectionRoot;
  three.OrbitControls? _controls;
  String? _selectedPartId;
  String? _hoveredPartId;

  List<three.Object3D> get interactiveObjects =>
      List.unmodifiable(_hitObjects);

  Future<void> initialize(
    StructurePreviewSceneBuildResult buildResult, {
    bool useOrthographic = false,
    double orthographicHalfWidth = 1,
    double orthographicHalfHeight = 1,
  }) async {
    final sceneData = buildResult.scene;

    _partMeshes.clear();
    _layerMeshes.clear();
    _interactiveObjects.clear();
    _hitObjects.clear();
    _focusedPartIds.clear();
    _selectedPartId = null;
    _hoveredPartId = null;

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(sceneData.backgroundColor);

    if (useOrthographic) {
      threeJs.camera = three.OrthographicCamera(
        -orthographicHalfWidth,
        orthographicHalfWidth,
        orthographicHalfHeight,
        -orthographicHalfHeight,
        0.1,
        100,
      );
    } else {
      threeJs.camera = three.PerspectiveCamera(
        sceneData.camera.fov,
        threeJs.width / threeJs.height,
        0.1,
        100,
      );
    }
    threeJs.camera.position.setValues(
      sceneData.camera.position.x,
      sceneData.camera.position.y,
      sceneData.camera.position.z,
    );
    threeJs.camera.lookAt(_toThreeVector(sceneData.camera.target));

    _controls = three.OrbitControls(threeJs.camera, threeJs.globalKey)
      ..target.setValues(
        sceneData.camera.target.x,
        sceneData.camera.target.y,
        sceneData.camera.target.z,
      )
      ..enableDamping = true
      ..dampingFactor = 0.08
      ..screenSpacePanning = false
      ..minDistance = sceneData.camera.minDistance
      ..maxDistance = sceneData.camera.maxDistance
      ..maxPolarAngle = sceneData.camera.maxPolarAngle
      ..autoRotate = sceneData.camera.autoRotate
      ..autoRotateSpeed = sceneData.camera.autoRotateSpeed
      ..enableRotate = false
      ..update();

    final ambientLight = three.AmbientLight(
      sceneData.ambientLightColor,
      sceneData.ambientLightIntensity,
    );
    threeJs.scene.add(ambientLight);

    final keyLight = three.DirectionalLight(
      sceneData.keyLightColor,
      sceneData.keyLightIntensity,
    );
    keyLight.position.setValues(
      sceneData.keyLightPosition.x,
      sceneData.keyLightPosition.y,
      sceneData.keyLightPosition.z,
    );
    threeJs.scene.add(keyLight);

    final fillLight = three.DirectionalLight(
      sceneData.fillLightColor,
      sceneData.fillLightIntensity,
    );
    fillLight.position.setValues(
      sceneData.fillLightPosition.x,
      sceneData.fillLightPosition.y,
      sceneData.fillLightPosition.z,
    );
    threeJs.scene.add(fillLight);

    final texturePaths = <String>{};
    for (final primitive in sceneData.primitives) {
      final material = primitive.material;
      if (material.mapAsset != null) {
        texturePaths.add(material.mapAsset!);
      }
      texturePaths.addAll(material.objTextures.values);
      final faceTextures = material.faceTextures;
      if (faceTextures != null) {
        for (final path in <String?>[
          faceTextures.all,
          faceTextures.right,
          faceTextures.left,
          faceTextures.top,
          faceTextures.bottom,
          faceTextures.front,
          faceTextures.back,
        ].whereType<String>()) {
          texturePaths.add(path);
        }
      }
    }
    await Future.wait(
      texturePaths.map(
        (path) => _textureCache.loadAssetTexture(path),
      ),
    );

    _selectionRoot = three.Group()
      ..name = 'selection-hit-proxies'
      ..visible = false;
    threeJs.scene.add(_selectionRoot!);

    final root = three.Group();
    for (final primitive in sceneData.primitives) {
      root.add(
        await _buildPrimitive(
          primitive,
          buildResult.primitivePartMap[primitive.id],
        ),
      );
    }
    threeJs.scene.add(root);

    threeJs.addAnimationEvent((_) {
      _controls?.update();
    });
  }

  void rotateBy(double deltaX, double deltaY) {
    final controls = _controls;
    if (controls == null) return;
    controls.rotateLeft(deltaX * 0.005);
    controls.rotateUp(deltaY * 0.005);
    controls.update();
  }

  void setVisibleLayers(Set<String>? layerIds) {
    for (final entry in _layerMeshes.entries) {
      final visible = layerIds == null || layerIds.contains(entry.key);
      for (final mesh in entry.value) {
        mesh.visible = visible;
      }
    }
  }

  void setVisibleParts(Set<String>? partIds) {
    for (final entry in _partMeshes.entries) {
      final visible = partIds == null || partIds.contains(entry.key);
      for (final mesh in entry.value) {
        mesh.visible = visible;
      }
    }
  }

  void setSelectedPart(String? partId) {
    if (_selectedPartId == partId) {
      return;
    }

    final changedIds = <String>{..._focusedPartIds};
    if (_hoveredPartId != null) {
      changedIds.add(_hoveredPartId!);
    }
    if (_selectedPartId != null) {
      changedIds.add(_selectedPartId!);
    }
    if (partId != null) {
      changedIds.add(partId);
    }

    _selectedPartId = partId;

    for (final id in changedIds) {
      _refreshPartVisual(id);
    }
  }

  void setFocusedParts(Set<String> partIds) {
    if (_samePartSets(_focusedPartIds, partIds)) {
      return;
    }

    final changedIds = <String>{..._focusedPartIds, ...partIds};
    if (_hoveredPartId != null) {
      changedIds.add(_hoveredPartId!);
    }
    if (_selectedPartId != null) {
      changedIds.add(_selectedPartId!);
    }

    _focusedPartIds
      ..clear()
      ..addAll(partIds);

    for (final id in changedIds) {
      _refreshPartVisual(id);
    }
  }

  void setHoveredPart(String? partId) {
    if (_hoveredPartId == partId) {
      return;
    }

    final changedIds = <String>{..._focusedPartIds};
    if (_selectedPartId != null) {
      changedIds.add(_selectedPartId!);
    }
    if (_hoveredPartId != null) {
      changedIds.add(_hoveredPartId!);
    }
    if (partId != null) {
      changedIds.add(partId);
    }

    _hoveredPartId = partId;

    for (final id in changedIds) {
      _refreshPartVisual(id);
    }
  }

  void dispose() {
    _selectionRoot?.clear();
    _selectionRoot = null;
    _controls?.dispose();
    _controls = null;
    _partMeshes.clear();
    _layerMeshes.clear();
    _interactiveObjects.clear();
    _hitObjects.clear();
    _focusedPartIds.clear();
    _hoveredPartId = null;
    _textureCache.dispose();
    three.loading.clear();
  }

  Future<three.Object3D> _buildPrimitive(
    StructurePrimitive primitive,
    String? partId,
  ) async {
    await _registerHitProxy(primitive, partId);
    if (primitive.material.objAsset != null) {
      return _buildObjPrimitive(primitive, partId);
    }
    if (primitive.material.modelData != null) {
      return _buildForgeModelPrimitive(primitive, partId);
    }
    final faceTextures = primitive.material.faceTextures;
    if (primitive.type == StructurePrimitiveType.cuboid &&
        faceTextures != null &&
        _hasFrontOverlay(faceTextures)) {
      return _buildOverlayCuboid(primitive, partId);
    }

    final geometry = switch (primitive.type) {
      StructurePrimitiveType.cuboid => three.BoxGeometry(
        primitive.size!.x,
        primitive.size!.y,
        primitive.size!.z,
      ),
      StructurePrimitiveType.cylinder => three.CylinderGeometry(
        primitive.radiusTop!,
        primitive.radiusBottom!,
        primitive.height!,
        primitive.radialSegments,
      ),
    };

    final material = await _buildMaterial(primitive.material, primitive.type);

    final mesh = three.Mesh(geometry, material);
    mesh.name = primitive.id;
    mesh.position.setValues(
      primitive.position.x,
      primitive.position.y,
      primitive.position.z,
    );
    mesh.rotation.x = _degreesToRadians(primitive.rotation.x);
    mesh.rotation.y = _degreesToRadians(primitive.rotation.y);
    mesh.rotation.z = _degreesToRadians(primitive.rotation.z);

    final resolvedPartId = primitive.partId ?? partId;
    if (resolvedPartId != null) {
      mesh.userData['partId'] = resolvedPartId;
      mesh.userData['layerId'] = primitive.layerId;
      mesh.userData['gridPosition'] = primitive.gridPosition;
      mesh.userData['baseColor'] = primitive.material.color;
      mesh.userData['baseColors'] = _extractBaseColors(material);
      _partMeshes.putIfAbsent(resolvedPartId, () => []).add(mesh);
      final layerId = primitive.layerId;
      if (layerId != null) {
        _layerMeshes.putIfAbsent(layerId, () => []).add(mesh);
      }
    }

    return mesh;
  }

  Future<three.Object3D> _buildForgeModelPrimitive(
    StructurePrimitive primitive,
    String? partId,
  ) async {
    final data = jsonDecode(primitive.material.modelData!) as Map<String, dynamic>;
    final elements = data['elements'];
    if (elements is! List) return three.Group();

    final orderedElements = <Map>[
      for (final element in elements)
        if (element is Map && !_isOverlayElement(element)) element,
      for (final element in elements)
        if (element is Map && _isOverlayElement(element)) element,
    ];

    final positions = <double>[];
    final normals = <double>[];
    final uvs = <double>[];
    final groupStarts = <int>[];
    final groupMaterialIndices = <int>[];
    final materialAssets = <String>[];
    final materialIndices = <String, int>{};

    for (final rawElement in orderedElements) {
      final from = _doubleList(rawElement['from']);
      final to = _doubleList(rawElement['to']);
      if (from.length != 3 || to.length != 3) continue;
      final faces = rawElement['faces'];
      if (faces is! Map) continue;
      for (final faceEntry in faces.entries) {
        final face = faceEntry.value;
        if (face is! Map) continue;
        final uv = _doubleList(face['uv']);
        final resolvedUv = uv.length == 4
            ? uv
            : const <double>[0, 0, 16, 16];
        final textureReference =
            face['texture'] is String ? face['texture'] as String : null;
        final assetPath = _modelFaceAsset(
          primitive.material,
          textureReference,
        );
        final materialIndex = materialIndices.putIfAbsent(
          assetPath,
          () {
            materialAssets.add(assetPath);
            return materialAssets.length - 1;
          },
        );
        final groupStart = positions.length ~/ 3;
        _addForgeFace(
          positions,
          normals,
          uvs,
          primitive.size!,
          faceEntry.key.toString(),
          from,
          to,
          resolvedUv,
          rawElement['rotation'],
        );
        groupStarts.add(groupStart);
        groupMaterialIndices.add(materialIndex);
      }
    }
    if (positions.isEmpty) return three.Group();

    final geometry = three.BufferGeometry()
      ..setAttributeFromString(
        'position',
        three.Float32BufferAttribute.fromList(positions, 3, false),
      )
      ..setAttributeFromString(
        'normal',
        three.Float32BufferAttribute.fromList(normals, 3, false),
      )
      ..setAttributeFromString(
        'uv',
        three.Float32BufferAttribute.fromList(uvs, 2, false),
      );
    for (var index = 0; index < groupStarts.length; index++) {
      geometry.addGroup(
        groupStarts[index],
        6,
        groupMaterialIndices[index],
      );
    }

    final modelStyle = StructureMaterialStyle(
      color: 0xFFFFFFFF,
      metalness: primitive.material.metalness,
      roughness: primitive.material.roughness,
      opacity: primitive.material.opacity,
      alphaTest: primitive.material.alphaTest,
      doubleSided: true,
      pixelated: true,
    );
    final materials = await Future.wait(
      materialAssets.map(
        (assetPath) => _buildSingleMaterial(
          modelStyle,
          assetPath: assetPath,
        ),
      ),
    );
    final material = three.GroupMaterial(materials);
    final mesh = three.Mesh(geometry, material);
    mesh.name = primitive.id;
    mesh.position.setValues(
      primitive.position.x,
      primitive.position.y,
      primitive.position.z,
    );
    mesh.rotation.x = _degreesToRadians(
      primitive.rotation.x + primitive.material.modelRotationX,
    );
    mesh.rotation.y = _degreesToRadians(
      primitive.rotation.y + primitive.material.modelRotationY,
    );
    mesh.rotation.z = _degreesToRadians(
      primitive.rotation.z + primitive.material.modelRotationZ,
    );
    _registerMesh(mesh, primitive.partId ?? partId, primitive, material);
    return mesh;
  }

  bool _isOverlayElement(Map element) {
    final faces = element['faces'];
    if (faces is! Map) return false;
    for (final face in faces.values) {
      if (face is Map &&
          face['texture'] is String &&
          (face['texture'] as String).contains('overlay')) {
        return true;
      }
    }
    return false;
  }

  String _modelFaceAsset(
    StructureMaterialStyle style,
    String? textureReference,
  ) {
    if (textureReference == null) return style.mapAsset ?? '';
    var key = textureReference.startsWith('#')
        ? textureReference.substring(1)
        : textureReference;
    key = switch (key) {
      'down' => 'bottom',
      'up' => 'top',
      'north' || 'south' || 'east' || 'west' => 'side',
      'overlay' || 'overlay_tinted' => 'overlay_tint',
      _ => key,
    };
    return style.objTextures[key] ?? style.mapAsset ?? '';
  }

  void _addForgeFace(
    List<double> positions,
    List<double> normals,
    List<double> uvs,
    StructureVector3 size,
    String face,
    List<double> from,
    List<double> to,
    List<double> uv,
    Object? rotation,
  ) {
    final x1 = from[0];
    final x2 = to[0];
    final y1 = from[1];
    final y2 = to[1];
    final z1 = from[2];
    final z2 = to[2];
    final points = switch (face) {
      'north' => [
        [x2, y1, z1],
        [x1, y1, z1],
        [x1, y2, z1],
        [x2, y2, z1],
      ],
      'south' => [
        [x1, y1, z2],
        [x2, y1, z2],
        [x2, y2, z2],
        [x1, y2, z2],
      ],
      'east' => [
        [x2, y1, z2],
        [x2, y1, z1],
        [x2, y2, z1],
        [x2, y2, z2],
      ],
      'west' => [
        [x1, y1, z1],
        [x1, y1, z2],
        [x1, y2, z2],
        [x1, y2, z1],
      ],
      'up' => [
        [x1, y2, z2],
        [x2, y2, z2],
        [x2, y2, z1],
        [x1, y2, z1],
      ],
      'down' => [
        [x1, y1, z1],
        [x2, y1, z1],
        [x2, y1, z2],
        [x1, y1, z2],
      ],
      _ => null,
    };
    if (points == null) return;

    final normal = switch (face) {
      'north' => [0.0, 0.0, -1.0],
      'south' => [0.0, 0.0, 1.0],
      'east' => [1.0, 0.0, 0.0],
      'west' => [-1.0, 0.0, 0.0],
      'up' => [0.0, 1.0, 0.0],
      'down' => [0.0, -1.0, 0.0],
      _ => [0.0, 0.0, 0.0],
    };
    final u0 = uv[0] / 16.0;
    final v0 = uv[1] / 16.0;
    final u1 = uv[2] / 16.0;
    final v1 = uv[3] / 16.0;
    final faceUvs = [
      [u0, v0],
      [u1, v0],
      [u1, v1],
      [u0, v1],
    ];
    for (final index in <int>[0, 1, 2, 0, 2, 3]) {
      final point = _rotateModelPoint(points[index], rotation);
      positions.addAll([
        _modelCoordinate(point[0], size.x),
        _modelCoordinate(point[1], size.y),
        _modelCoordinate(point[2], size.z),
      ]);
      normals.addAll(_rotateModelPoint(normal, rotation));
      uvs.addAll(faceUvs[index]);
    }
  }

  List<double> _rotateModelPoint(List<double> point, Object? rawRotation) {
    if (rawRotation is! Map) return point;
    final angle = rawRotation['angle'];
    final axis = rawRotation['axis'];
    if (angle is! num || axis is! String) return point;
    final origin = _doubleList(rawRotation['origin']);
    final radians = angle.toDouble() * math.pi / 180.0;
    final cosine = math.cos(radians);
    final sine = math.sin(radians);
    final ox = origin.length > 0 ? origin[0] : 0.0;
    final oy = origin.length > 1 ? origin[1] : 0.0;
    final oz = origin.length > 2 ? origin[2] : 0.0;
    final x = point[0] - ox;
    final y = point[1] - oy;
    final z = point[2] - oz;
    return switch (axis) {
      'x' => [
        ox + x,
        oy + y * cosine - z * sine,
        oz + y * sine + z * cosine,
      ],
      'y' => [
        ox + x * cosine + z * sine,
        oy + y,
        oz + -x * sine + z * cosine,
      ],
      'z' => [
        ox + x * cosine - y * sine,
        oy + x * sine + y * cosine,
        oz + z,
      ],
      _ => point,
    };
  }

  double _modelCoordinate(double value, double size) {
    final scale = size / 16.0;
    return value * scale - size / 2.0;
  }

  List<double> _doubleList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => (item as num).toDouble()).toList();
  }

  Future<three.Object3D> _buildOverlayCuboid(
    StructurePrimitive primitive,
    String? partId,
  ) async {
    final original = primitive.material;
    final overlayPath = original.faceTextures!.front!;
    final baseTextures = StructureFaceTextureSet(
      all: original.faceTextures!.all,
      right: original.faceTextures!.right,
      left: original.faceTextures!.left,
      top: original.faceTextures!.top,
      bottom: original.faceTextures!.bottom,
      front:
          original.faceTextures!.right ??
          original.faceTextures!.left ??
          original.faceTextures!.all,
      back: original.faceTextures!.back,
    );
    final baseStyle = StructureMaterialStyle(
      color: original.color,
      metalness: original.metalness,
      roughness: original.roughness,
      opacity: original.opacity,
      faceTextures: baseTextures,
      pixelated: true,
      alphaTest: original.alphaTest,
      doubleSided: original.doubleSided,
    );
    final baseMaterial = await _buildMaterial(baseStyle, StructurePrimitiveType.cuboid);
    final baseMesh = three.Mesh(
      three.BoxGeometry(
        primitive.size!.x,
        primitive.size!.y,
        primitive.size!.z,
      ),
      baseMaterial,
    );

    final overlayMaterials = <three.Material>[];
    for (final face in <StructureCubeFace>[
      StructureCubeFace.right,
      StructureCubeFace.left,
      StructureCubeFace.top,
      StructureCubeFace.bottom,
      StructureCubeFace.front,
      StructureCubeFace.back,
    ]) {
      if (face == StructureCubeFace.front ||
          face == StructureCubeFace.back) {
        overlayMaterials.add(
          await _buildSingleMaterial(
            StructureMaterialStyle(
              color: 0xFFFFFFFF,
              metalness: 0.02,
              roughness: 0.58,
              opacity: 1,
              alphaTest: 0.08,
              doubleSided: true,
            ),
            assetPath: overlayPath,
          ),
        );
      } else {
        final invisible = await _buildSingleMaterial(
          StructureMaterialStyle(
            color: 0,
            opacity: 0,
            metalness: 0,
            roughness: 1,
          ),
        );
        invisible.depthWrite = false;
        overlayMaterials.add(invisible);
      }
    }
    final overlayFrontMaterial = overlayMaterials[4];
    final overlayMesh = three.Mesh(
      three.BoxGeometry(
        primitive.size!.x + 0.025,
        primitive.size!.y + 0.025,
        primitive.size!.z + 0.025,
      ),
      three.GroupMaterial(overlayMaterials),
    );

    final group = three.Group();
    group.name = primitive.id;
    group.position.setValues(
      primitive.position.x,
      primitive.position.y,
      primitive.position.z,
    );
    group.rotation.x = _degreesToRadians(primitive.rotation.x);
    group.rotation.y = _degreesToRadians(primitive.rotation.y);
    group.rotation.z = _degreesToRadians(primitive.rotation.z);
    group.add(baseMesh);
    group.add(overlayMesh);
    group.updateMatrixWorld(true);

    final resolvedPartId = primitive.partId ?? partId;
    _registerMesh(baseMesh, resolvedPartId, primitive, baseMaterial);
    _registerMesh(overlayMesh, resolvedPartId, primitive, overlayFrontMaterial);
    overlayMesh.userData['partId'] = resolvedPartId;
    overlayMesh.userData['layerId'] = primitive.layerId;
    overlayMesh.userData['gridPosition'] = primitive.gridPosition;
    overlayMesh.userData['selectionPriority'] = 1;
    overlayMesh.updateMatrixWorld(true);
    _hitObjects.add(overlayMesh);
    return group;
  }

  void _registerMesh(
    three.Mesh mesh,
    String? resolvedPartId,
    StructurePrimitive primitive,
    three.Material material,
  ) {
    if (resolvedPartId == null) return;
    mesh.userData['partId'] = resolvedPartId;
    mesh.userData['layerId'] = primitive.layerId;
    mesh.userData['gridPosition'] = primitive.gridPosition;
    mesh.userData['baseColor'] = primitive.material.color;
    mesh.userData['baseColors'] = [material.color.getHex()];
    _partMeshes.putIfAbsent(resolvedPartId, () => []).add(mesh);
    final layerId = primitive.layerId;
    if (layerId != null) {
      _layerMeshes.putIfAbsent(layerId, () => []).add(mesh);
    }
  }

  Future<void> _registerHitProxy(
    StructurePrimitive primitive,
    String? partId,
  ) async {
    final resolvedPartId = primitive.partId ?? partId;
    if (resolvedPartId == null) return;
    final material = await _buildSingleMaterial(
      StructureMaterialStyle(
        color: 0,
        opacity: 0,
        metalness: 0,
        roughness: 1,
      ),
    );
    material.depthWrite = false;
    material.side = three.DoubleSide;
    final width = primitive.size?.x ?? 1.0;
    final height = primitive.size?.y ?? 1.0;
    final depth = primitive.size?.z ?? 1.0;
    final mesh = three.Mesh(
      three.BoxGeometry(width + 0.02, height + 0.02, depth + 0.02),
      material,
    );
    mesh.position.setValues(
      primitive.position.x,
      primitive.position.y,
      primitive.position.z,
    );
    mesh.rotation.x = _degreesToRadians(
      primitive.rotation.x + primitive.material.modelRotationX,
    );
    mesh.rotation.y = _degreesToRadians(
      primitive.rotation.y + primitive.material.modelRotationY,
    );
    mesh.rotation.z = _degreesToRadians(
      primitive.rotation.z + primitive.material.modelRotationZ,
    );
    mesh.name = primitive.id;
    mesh.userData['partId'] = resolvedPartId;
    mesh.userData['layerId'] = primitive.layerId;
    mesh.userData['gridPosition'] = primitive.gridPosition;
    mesh.updateMatrixWorld(true);
    _hitObjects.add(mesh);
    _selectionRoot?.add(mesh);
  }

  bool _hasFrontOverlay(StructureFaceTextureSet faceTextures) {
    final front = faceTextures.front;
    return front != null && front.contains('overlay');
  }

  Future<three.Object3D> _buildObjPrimitive(
    StructurePrimitive primitive,
    String? partId,
  ) async {
    final loaded = await _textureCache.loadObjAsset(primitive.material.objAsset!);
    if (loaded == null) return three.Group();

    await _applyObjTextures(loaded, primitive.material);
    final bounds = three.BoundingBox().setFromObject(loaded);
    final center = bounds.getCenter(three.Vector3());
    loaded.position.sub(center);

    final container = three.Group();
    container.name = primitive.id;
    container.position.setValues(
      primitive.position.x,
      primitive.position.y,
      primitive.position.z,
    );
    container.rotation.x = _degreesToRadians(
      primitive.rotation.x + primitive.material.modelRotationX,
    );
    container.rotation.y = _degreesToRadians(
      primitive.rotation.y + primitive.material.modelRotationY,
    );
    container.rotation.z = _degreesToRadians(
      primitive.rotation.z + primitive.material.modelRotationZ,
    );
    container.add(loaded);

    final resolvedPartId = primitive.partId ?? partId;
    final meshes = <three.Mesh>[];
    _collectMeshes(loaded, meshes);
    for (final mesh in meshes) {
      mesh.name = primitive.id + '-' + mesh.name;
      _registerMesh(
        mesh,
        resolvedPartId,
        primitive,
        _firstMaterial(mesh.material),
      );
    }

    return container;
  }

  Future<void> _applyObjTextures(
    three.Object3D object,
    StructureMaterialStyle style,
  ) async {
    final meshes = <three.Mesh>[];
    _collectMeshes(object, meshes);
    for (final mesh in meshes) {
      final current = mesh.material;
      if (current is three.GroupMaterial) {
        final children = <three.Material>[];
        for (final child in current.children) {
          final assetPath = _findObjTexturePath(
            child.name,
            style.objTextures,
          ) ??
              style.mapAsset;
          final textureMaterial = await _buildObjTextureMaterial(style, assetPath);
          textureMaterial.name = child.name;
          children.add(textureMaterial);
        }
        mesh.material = three.GroupMaterial(children);
      } else {
        final materialName = current!.name;
        final assetPath = _findObjTexturePath(
          materialName,
          style.objTextures,
        ) ??
            style.mapAsset;
        final textureMaterial = await _buildObjTextureMaterial(style, assetPath);
        textureMaterial.name = materialName;
        mesh.material = textureMaterial;
      }
    }
  }

  Future<three.Material> _buildObjTextureMaterial(
    StructureMaterialStyle style,
    String? assetPath,
  ) {
    return _buildSingleMaterial(
      StructureMaterialStyle(
        color: 0xFFFFFFFF,
        metalness: style.metalness,
        roughness: style.roughness,
        opacity: style.opacity,
        alphaTest: style.alphaTest,
        doubleSided: true,
      ),
      assetPath: assetPath,
    );
  }

  String? _findObjTexturePath(
    String? materialName,
    Map<String, String> textures,
  ) {
    if (materialName == null) return null;
    final source = materialName.toLowerCase().replaceAll('_', '');
    String? path;
    var bestLength = -1;
    for (final entry in textures.entries) {
      final key = entry.key.toLowerCase().replaceAll('_', '');
      if (source.contains(key) && key.length > bestLength) {
        path = entry.value;
        bestLength = key.length;
      }
    }
    return path;
  }

  three.Material _firstMaterial(three.Material? material) {
    if (material is three.GroupMaterial && material.children.isNotEmpty) {
      return material.children.first;
    }
    return material!;
  }

  void _collectMeshes(three.Object3D object, List<three.Mesh> result) {
    if (object is three.Mesh) result.add(object);
    for (final child in object.children) {
      _collectMeshes(child, result);
    }
  }

  Future<three.Material> _buildMaterial(
    StructureMaterialStyle style,
    StructurePrimitiveType primitiveType,
  ) async {
    if (primitiveType == StructurePrimitiveType.cuboid &&
        style.faceTextures != null &&
        style.faceTextures!.hasAnyTexture) {
      final faces = [
        StructureCubeFace.right,
        StructureCubeFace.left,
        StructureCubeFace.top,
        StructureCubeFace.bottom,
        StructureCubeFace.front,
        StructureCubeFace.back,
      ];

      final materials = <three.Material>[];
      for (final face in faces) {
        materials.add(
          await _buildSingleMaterial(
            style,
            assetPath: style.faceTextures!.textureFor(face),
          ),
        );
      }
      return three.GroupMaterial(materials);
    }

    return _buildSingleMaterial(style, assetPath: style.mapAsset);
  }

  Future<three.Material> _buildSingleMaterial(
    StructureMaterialStyle style, {
    String? assetPath,
  }) async {
    final texture = assetPath == null
        ? null
        : await _textureCache.loadAssetTexture(
            assetPath,
            pixelated: style.pixelated,
          );

    final materialConfig = <String, dynamic>{
      'color': style.color,
      'metalness': style.metalness,
      'roughness': style.roughness,
      'transparent': style.opacity < 1 || style.alphaTest > 0,
      'opacity': style.opacity,
      'alphaTest': style.alphaTest,
      'side': style.doubleSided ? three.DoubleSide : three.FrontSide,
      'map': texture,
    }..removeWhere((_, value) => value == null);

    return three.MeshStandardMaterial.fromMap(materialConfig);
  }

  void _refreshPartVisual(String partId) {
    final meshes = _partMeshes[partId];
    if (meshes == null) {
      return;
    }

    final isSelected = _selectedPartId == partId;
    final isHovered = _hoveredPartId == partId;
    final isFocused = _focusedPartIds.contains(partId);

    for (final mesh in meshes) {
      final materials = _collectHighlightMaterials(mesh.material);
      final baseColors =
          (mesh.userData['baseColors'] as List<int>?) ??
          [mesh.userData['baseColor'] as int? ?? 0xFFFFFF];

      for (var i = 0; i < materials.length; i++) {
        final material = materials[i];
        final baseColor = i < baseColors.length
            ? baseColors[i]
            : baseColors.first;
        final color = isSelected
            ? _blendColor(baseColor, 0xFFF2C57D, 0.36)
            : isHovered
            ? _blendColor(baseColor, 0xFF9BE7C4, 0.24)
            : isFocused
            ? _blendColor(baseColor, 0xFFB5D9FF, 0.22)
            : baseColor;

        material.color = three.Color.fromHex32(color);
        material.emissive = three.Color.fromHex32(
          isSelected
              ? 0x2B1B08
              : isHovered
              ? 0x0D2A1A
              : isFocused
              ? 0x0C223A
              : 0x000000,
        );
        material.emissiveIntensity = isSelected
            ? 0.9
            : isHovered
            ? 0.28
            : isFocused
            ? 0.35
            : 0.0;
      }
    }
  }

  List<int> _extractBaseColors(three.Material material) {
    if (material is three.GroupMaterial) {
      return material.children
          .whereType<three.MeshStandardMaterial>()
          .map((child) => child.color.getHex())
          .toList();
    }
    if (material is three.MeshStandardMaterial) {
      return [material.color.getHex()];
    }
    return const [0xFFFFFF];
  }

  List<three.MeshStandardMaterial> _collectHighlightMaterials(
    three.Material? material,
  ) {
    if (material is three.GroupMaterial) {
      return material.children.whereType<three.MeshStandardMaterial>().toList();
    }
    if (material is three.MeshStandardMaterial) {
      return [material];
    }
    return const [];
  }

  bool _samePartSets(Set<String> a, Set<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final item in a) {
      if (!b.contains(item)) {
        return false;
      }
    }
    return true;
  }

  int _blendColor(int baseColor, int overlayColor, double ratio) {
    final clampedRatio = ratio.clamp(0, 1);

    final baseR = (baseColor >> 16) & 0xFF;
    final baseG = (baseColor >> 8) & 0xFF;
    final baseB = baseColor & 0xFF;

    final overlayR = (overlayColor >> 16) & 0xFF;
    final overlayG = (overlayColor >> 8) & 0xFF;
    final overlayB = overlayColor & 0xFF;

    final r = (baseR + (overlayR - baseR) * clampedRatio).round();
    final g = (baseG + (overlayG - baseG) * clampedRatio).round();
    final b = (baseB + (overlayB - baseB) * clampedRatio).round();

    return (r << 16) | (g << 8) | b;
  }

  three.Vector3 _toThreeVector(StructureVector3 value) {
    return three.Vector3(value.x, value.y, value.z);
  }

  double _degreesToRadians(double value) {
    return value * (math.pi / 180);
  }
}
