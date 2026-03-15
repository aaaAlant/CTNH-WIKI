import 'package:three_js/three_js.dart' as three;

class StructureTextureCache {
  final Map<String, Future<three.Texture?>> _assetTextures = {};
  final Map<String, three.Texture> _resolvedTextures = {};

  Future<three.Texture?> loadAssetTexture(
    String assetPath, {
    bool pixelated = true,
  }) {
    return _assetTextures.putIfAbsent(assetPath, () async {
      final texture = await three.TextureLoader().fromAsset(assetPath);
      if (texture == null) {
        return null;
      }

      if (pixelated) {
        texture.magFilter = three.NearestFilter;
        texture.minFilter = three.NearestFilter;
        texture.generateMipmaps = false;
      }

      texture.colorSpace = three.SRGBColorSpace;
      texture.needsUpdate = true;
      _resolvedTextures[assetPath] = texture;
      return texture;
    });
  }

  void dispose() {
    for (final texture in _resolvedTextures.values) {
      texture.dispose();
    }
    _resolvedTextures.clear();
    _assetTextures.clear();
  }
}
