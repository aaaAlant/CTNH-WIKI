
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ctnh_wiki/features/structure_preview/data/structure_texture_manifest.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StructureStaticIconRenderer {
  StructureStaticIconRenderer();

  Future<ui.Image> render(
    String blockId,
    StructureTextureDefinition definition,
  ) async {
    final images = await _loadImages(definition);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    _draw(canvas, definition, images);
    final picture = recorder.endRecording();
    return picture.toImage(64, 64);
  }

  Future<_IconImages> _loadImages(
    StructureTextureDefinition definition,
  ) async {
    final textures = definition.textures;
    final sidePath =
        textures['side'] ?? textures['right'] ?? textures['left'] ?? definition.base;
    final frontPath = definition.front ??
        textures['overlay_front'] ??
        textures['front'];
    final overlayPaths = <String>[
      if (frontPath != null) frontPath,
      if (textures['overlay_tint'] != null) textures['overlay_tint']!,
      if (textures['overlay_in'] != null) textures['overlay_in']!,
      if (textures['overlay_in_emissive'] != null)
        textures['overlay_in_emissive']!,
      if (textures['overlay_out_emissive'] != null)
        textures['overlay_out_emissive']!,
      if (textures['overlay_pipe'] != null) textures['overlay_pipe']!,
      if (textures['overlay_emissive'] != null)
        textures['overlay_emissive']!,
    ].toSet().toList(growable: false);
    return _IconImages(
      side: await _load(sidePath),
      top: await _load(textures['top'] ?? sidePath),
      bottom: await _load(textures['bottom'] ?? sidePath),
      front: frontPath == null ? null : await _load(frontPath),
      overlays: await Future.wait(overlayPaths.map(_load)),
    );
  }

  Future<ui.Image?> _load(String path) async {
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _draw(
    ui.Canvas canvas,
    StructureTextureDefinition definition,
    _IconImages images,
  ) {
    final projected = <_ProjectedFace>[];
    for (final face in _cubeFaces()) {
      final image = _baseImage(face.direction, images);
      if (image == null) continue;
      projected.add(
        _ProjectedFace(
          image: image,
          points: [
            for (final point in face.points)
              _project(point, const ui.Offset(32, 33), 1.35),
          ],
          uv: const [0, 0, 16, 16],
          brightness: _brightness(face.direction),
          depth: _depth(face.points),
        ),
      );
    }
    projected.sort((a, b) => a.depth.compareTo(b.depth));
    for (final face in projected) {
      _drawFace(canvas, face);
    }

    for (final overlayImage in images.overlays) {
      if (overlayImage == null) continue;
      final face = _cubeFaces().firstWhere(
        (face) => face.direction == 'north',
      );
      _drawFace(
        canvas,
        _ProjectedFace(
          image: overlayImage,
          points: [
            for (final point in face.points)
              _project(point, const ui.Offset(32, 33), 1.35),
          ],
          uv: const [0, 0, 16, 16],
          brightness: 1,
          depth: _depth(face.points),
        ),
      );
    }
  }

  ui.Image? _baseImage(String direction, _IconImages images) {
    return switch (direction) {
      'up' => images.top ?? images.side,
      'down' => images.bottom ?? images.side,
      _ => images.side,
    };
  }

  List<_CubeFace> _cubeFaces() {
    return [
      _CubeFace('north', _cubeFacePoints('north')),
      _CubeFace('south', _cubeFacePoints('south')),
      _CubeFace('east', _cubeFacePoints('east')),
      _CubeFace('west', _cubeFacePoints('west')),
      _CubeFace('up', _cubeFacePoints('up')),
      _CubeFace('down', _cubeFacePoints('down')),
    ];
  }

  List<List<double>> _cubeFacePoints(String direction) {
    return switch (direction) {
      'north' => [
        [0, 0, 0],
        [16, 0, 0],
        [16, 16, 0],
        [0, 16, 0],
      ],
      'south' => [
        [16, 0, 16],
        [0, 0, 16],
        [0, 16, 16],
        [16, 16, 16],
      ],
      'east' => [
        [16, 0, 16],
        [16, 0, 0],
        [16, 16, 0],
        [16, 16, 16],
      ],
      'west' => [
        [0, 0, 0],
        [0, 0, 16],
        [0, 16, 16],
        [0, 16, 0],
      ],
      'up' => [
        [0, 16, 16],
        [16, 16, 16],
        [16, 16, 0],
        [0, 16, 0],
      ],
      'down' => [
        [0, 0, 0],
        [16, 0, 0],
        [16, 0, 16],
        [0, 0, 16],
      ],
      _ => const [],
    };
  }

  ui.Offset _project(List<double> point, ui.Offset center, double scale) {
    final x = point[0] - 8;
    final y = point[1] - 8;
    final z = point[2] - 8;
    final rotatedX = x * -0.70710678 - z * 0.70710678;
    final rotatedZ = x * 0.70710678 - z * 0.70710678;
    final rotatedY = y * 0.8660254 - rotatedZ * 0.5;
    return ui.Offset(
      center.dx + rotatedX * scale,
      center.dy - rotatedY * scale,
    );
  }

  double _depth(List<List<double>> points) {
    final center = [
      (points[0][0] + points[1][0] + points[2][0] + points[3][0]) / 4,
      (points[0][1] + points[1][1] + points[2][1] + points[3][1]) / 4,
      (points[0][2] + points[1][2] + points[2][2] + points[3][2]) / 4,
    ];
    final x = center[0] - 8;
    final y = center[1] - 8;
    final z = center[2] - 8;
    final rotatedZ = x * 0.70710678 - z * 0.70710678;
    return y * 0.5 + rotatedZ * 0.8660254;
  }

  double _brightness(String direction) {
    return switch (direction) {
      'up' => 1.0,
      'north' || 'south' => 0.88,
      'east' || 'west' => 0.72,
      _ => 0.62,
    };
  }

  void _drawFace(ui.Canvas canvas, _ProjectedFace face) {
    if (face.points.length != 4) return;
    final textureSize = math.min(face.image.width, face.image.height).toDouble();
    final positions = Float32List(12);
    final trianglePoints = <int>[0, 1, 2, 0, 2, 3];
    for (var index = 0; index < trianglePoints.length; index++) {
      final point = face.points[trianglePoints[index]];
      positions[index * 2] = point.dx;
      positions[index * 2 + 1] = point.dy;
    }
    final textureWidth = face.image.width.toDouble();
    final textureHeight = face.image.height.toDouble();
    final textureCoordinates = Float32List.fromList([
      0, 0,
      textureWidth, 0,
      textureWidth, textureHeight,
      0, 0,
      textureWidth, textureHeight,
      0, textureHeight,
    ]);
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
    );
    final paint = ui.Paint()
      ..isAntiAlias = false
      ..filterQuality = ui.FilterQuality.none
      ..shader = ui.ImageShader(
        face.image,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        Matrix4.identity().storage,
      );
    canvas.drawVertices(vertices, ui.BlendMode.srcOver, paint);
    final path = ui.Path()..addPolygon(face.points, true);

    if (face.brightness < 1) {
      final dark = (255 * (1 - face.brightness)).round();
      canvas.save();
      canvas.clipPath(path);
      canvas.drawRect(
        path.getBounds(),
        ui.Paint()
          ..color = ui.Color.fromARGB(dark, 0, 0, 0)
          ..blendMode = ui.BlendMode.srcOver,
      );
      canvas.restore();
    }
  }
}

class _IconImages {
  const _IconImages({
    required this.side,
    required this.top,
    required this.bottom,
    this.front,
    this.overlays = const [],
  });

  final ui.Image? side;
  final ui.Image? top;
  final ui.Image? bottom;
  final ui.Image? front;
  final List<ui.Image?> overlays;
}

class _CubeFace {
  const _CubeFace(this.direction, this.points);

  final String direction;
  final List<List<double>> points;
}

class _ProjectedFace {
  const _ProjectedFace({
    required this.image,
    required this.points,
    required this.uv,
    required this.brightness,
    required this.depth,
  });

  final ui.Image image;
  final List<ui.Offset> points;
  final List<double> uv;
  final double brightness;
  final double depth;
}
