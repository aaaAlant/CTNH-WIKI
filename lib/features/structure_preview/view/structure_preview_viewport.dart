import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_scene_builder.dart';
import 'package:ctnh_wiki/features/structure_preview/three_js/structure_preview_renderer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class StructurePreviewViewport extends StatefulWidget {
  const StructurePreviewViewport({
    super.key,
    required this.structure,
    required this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  final StructurePreviewDefinition structure;
  final Size size;
  final BorderRadius borderRadius;

  @override
  State<StructurePreviewViewport> createState() =>
      _StructurePreviewViewportState();
}

class _StructurePreviewViewportState extends State<StructurePreviewViewport> {
  static const _sceneBuilder = StructurePreviewSceneBuilder();

  three.ThreeJS? _threeJs;
  StructurePreviewRenderer? _renderer;

  @override
  void initState() {
    super.initState();
    if (!_shouldUseFallback) {
      _createViewer();
    }
  }

  @override
  void didUpdateWidget(covariant StructurePreviewViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldUseFallback) {
      return;
    }
    if (oldWidget.size != widget.size ||
        !identical(oldWidget.structure, widget.structure)) {
      _disposeViewer();
      _createViewer();
    }
  }

  @override
  void dispose() {
    _disposeViewer();
    super.dispose();
  }

  bool get _shouldUseFallback {
    return _isFlutterTest || widget.size.width <= 0 || widget.size.height <= 0;
  }

  void _createViewer() {
    final threeJs = three.ThreeJS(
      size: widget.size,
      settings: three.Settings(
        antialias: true,
        enableShadowMap: false,
        screenResolution: kIsWeb ? 1 : 1.25,
      ),
      setup: () async {
        await _renderer?.initialize(_sceneBuilder.build(widget.structure));
      },
      onSetupComplete: () {
        if (mounted) {
          setState(() {});
        }
      },
      loadingWidget: _PreviewFallback(
        size: widget.size,
        borderRadius: widget.borderRadius,
        label: '正在初始化 3D 预览',
      ),
    );

    _threeJs = threeJs;
    _renderer = StructurePreviewRenderer(threeJs);
  }

  void _disposeViewer() {
    _renderer?.dispose();
    _renderer = null;
    if (_threeJs != null) {
      try {
        _threeJs!.dispose();
      } catch (_) {
        // three_js 在未完成 setup 前提前 dispose 时可能抛出 late init 异常。
      }
      _threeJs = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldUseFallback) {
      return _PreviewFallback(
        size: widget.size,
        borderRadius: widget.borderRadius,
        label: '3D 预览占位',
      );
    }

    final viewer = _threeJs;
    if (viewer == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: viewer.build(),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({
    required this.size,
    required this.borderRadius,
    required this.label,
  });

  final Size size;
  final BorderRadius borderRadius;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: [Color(0xFF273039), Color(0xFF151A1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.view_in_ar_rounded, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
