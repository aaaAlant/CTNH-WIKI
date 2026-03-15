import 'dart:math' as math;

import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_scene_builder.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_texture_cache.dart';
import 'package:three_js/three_js.dart' as three;

class StructurePreviewRenderer {
  StructurePreviewRenderer(this.threeJs);

  final three.ThreeJS threeJs;
  final Map<String, List<three.Mesh>> _partMeshes = {};
  final List<three.Object3D> _interactiveObjects = [];
  final Set<String> _focusedPartIds = <String>{};
  final StructureTextureCache _textureCache = StructureTextureCache();

  three.OrbitControls? _controls;
  String? _selectedPartId;
  String? _hoveredPartId;

  List<three.Object3D> get interactiveObjects =>
      List.unmodifiable(_interactiveObjects);

  Future<void> initialize(StructurePreviewSceneBuildResult buildResult) async {
    final sceneData = buildResult.scene;

    _partMeshes.clear();
    _interactiveObjects.clear();
    _focusedPartIds.clear();
    _selectedPartId = null;
    _hoveredPartId = null;

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(sceneData.backgroundColor);

    threeJs.camera = three.PerspectiveCamera(
      sceneData.camera.fov,
      threeJs.width / threeJs.height,
      0.1,
      100,
    );
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
    _controls?.dispose();
    _controls = null;
    _partMeshes.clear();
    _interactiveObjects.clear();
    _focusedPartIds.clear();
    _hoveredPartId = null;
    _textureCache.dispose();
    three.loading.clear();
  }

  Future<three.Object3D> _buildPrimitive(
    StructurePrimitive primitive,
    String? partId,
  ) async {
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

    if (partId != null) {
      mesh.userData['partId'] = partId;
      mesh.userData['baseColor'] = primitive.material.color;
      mesh.userData['baseColors'] = _extractBaseColors(material);
      _partMeshes.putIfAbsent(partId, () => []).add(mesh);
      _interactiveObjects.add(mesh);
    }

    return mesh;
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
