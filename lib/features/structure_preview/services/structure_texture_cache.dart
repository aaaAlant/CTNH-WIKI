import 'package:flutter/foundation.dart' show kIsWasm, kIsWeb;
import 'package:three_js/three_js.dart' as three;

class StructureTextureCache {
  final Map<String, Future<three.Texture?>> _assetTextures = {};
  final Map<String, three.Texture> _resolvedTextures = {};

  Future<three.Texture?> loadAssetTexture(
    String assetPath, {
    bool pixelated = true,
  }) {
    return _assetTextures.putIfAbsent(assetPath, () async {
      try {
        final texture = await three
            .TextureLoader()
            .fromAsset(_runtimeAssetPath(assetPath))
            .timeout(const Duration(seconds: 4));
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
      } catch (_) {
        return null;
      }
    });
  }

  Future<three.Group?> loadObjAsset(String assetPath) async {
    try {
      return await three
          .OBJLoader()
          .fromAsset(assetPath)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
  }

  String _runtimeAssetPath(String assetPath) {
    if (kIsWeb && !kIsWasm) {
      return 'assets/$assetPath';
    }
    return assetPath;
  }

  void dispose() {
    for (final texture in _resolvedTextures.values) {
      texture.dispose();
    }
    _resolvedTextures.clear();
    _assetTextures.clear();
  }
}
