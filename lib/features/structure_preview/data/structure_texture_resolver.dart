import 'package:ctnh_wiki/features/structure_preview/data/structure_texture_manifest.g.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';

class StructureForgeTextureResolver {
  const StructureForgeTextureResolver({
    this.catalog = structureTextureManifest,
  });

  final Map<String, StructureTextureDefinition> catalog;

  StructureMaterialStyle resolve(
    StructureMaterialStyle material,
    String blockId,
    String visualId, {
    bool connected = false,
  }) {
    final definition = catalog[blockId];
    if (definition == null) {
      return material;
    }

    if (visualId == 'front-overlay') {
      return _withMapAsset(
        material,
        definition.front ?? definition.textures['overlay_front'] ?? definition.base,
      );
    }

    return _withFaceTextures(material, definition, connected);
  }

  StructureMaterialStyle _withMapAsset(
    StructureMaterialStyle material,
    String assetPath,
  ) {
    return StructureMaterialStyle(
      // 清单纹理自带颜色，tint 必须保持白色，否则占位颜色会把贴图染色。
      color: 0xFFFFFFFF,
      metalness: material.metalness,
      roughness: material.roughness,
      opacity: material.opacity,
      mapAsset: assetPath,
      faceTextures: null,
      pixelated: true,
      alphaTest: _alphaTestForOverlay(material.alphaTest, assetPath),
      doubleSided: material.doubleSided,
    );
  }

  StructureMaterialStyle _withFaceTextures(
    StructureMaterialStyle material,
    StructureTextureDefinition definition,
    bool connected,
  ) {
    final textures = definition.textures;
    final side = textures['side'] ?? textures['right'] ?? textures['left'];
    final front =
        definition.front ?? textures['overlay_front'] ?? textures['front'];

    return StructureMaterialStyle(
      // 清单纹理自带颜色，tint 必须保持白色，否则占位颜色会把贴图染色。
      color: 0xFFFFFFFF,
      metalness: material.metalness,
      roughness: material.roughness,
      opacity: material.opacity,
      mapAsset: definition.base,
      faceTextures: StructureFaceTextureSet(
        all: textures['all'] ?? definition.base,
        right: textures['right'] ?? side,
        left: textures['left'] ?? side,
        top: textures['top'],
        bottom: textures['bottom'],
        front: front,
        back: textures['back'],
      ),
      objAsset: definition.obj,
      objTextures: definition.textures,
      modelData: definition.modelData,
      modelRotationX: definition.rotationX,
      modelRotationY: definition.rotationY,
      modelRotationZ: definition.rotationZ,
      pixelated: true,
      alphaTest: _alphaTestForOverlay(material.alphaTest, front),
      doubleSided: material.doubleSided,
    );
  }
}

const structureForgeTextureResolver = StructureForgeTextureResolver();
double _alphaTestForOverlay(double original, String? assetPath) {
  if (assetPath == null || !assetPath.contains('overlay')) return original;
  return original >= 0.08 ? original : 0.08;
}
