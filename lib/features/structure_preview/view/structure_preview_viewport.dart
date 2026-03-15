import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_hit_test_service.dart';
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
    this.selectionController,
    this.stepController,
    this.onHoveredPartChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  final StructurePreviewDefinition structure;
  final Size size;
  final StructureSelectionController? selectionController;
  final StructureStepController? stepController;
  final ValueChanged<String?>? onHoveredPartChanged;
  final BorderRadius borderRadius;

  @override
  State<StructurePreviewViewport> createState() =>
      _StructurePreviewViewportState();
}

class _StructurePreviewViewportState extends State<StructurePreviewViewport> {
  static const _sceneBuilder = StructurePreviewSceneBuilder();

  final StructureHitTestService _hitTestService = StructureHitTestService();

  late final StructureSelectionController _ownedSelectionController;

  three.ThreeJS? _threeJs;
  StructurePreviewRenderer? _renderer;
  bool _pointerListenerBound = false;
  Set<String>? _appliedVisiblePartIds;
  String? _hoveredPartId;

  StructureSelectionController get _selectionController {
    return widget.selectionController ?? _ownedSelectionController;
  }

  StructureStepController? get _stepController => widget.stepController;

  Set<String>? get _visiblePartIds {
    final visiblePartIds = _stepController?.visiblePartIds;
    return visiblePartIds == null ? null : {...visiblePartIds};
  }

  Set<String> get _focusedPartIds {
    return {...?_stepController?.focusedPartIds};
  }

  @override
  void initState() {
    super.initState();
    _ownedSelectionController = StructureSelectionController();
    _selectionController.addListener(_handleSelectionChanged);
    _stepController?.addListener(_handleStepChanged);
    _normalizeSelection();
    if (!_shouldUseFallback) {
      _createViewer();
    }
  }

  @override
  void didUpdateWidget(covariant StructurePreviewViewport oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldSelectionController =
        oldWidget.selectionController ?? _ownedSelectionController;
    final newSelectionController =
        widget.selectionController ?? _ownedSelectionController;

    if (oldSelectionController != newSelectionController) {
      oldSelectionController.removeListener(_handleSelectionChanged);
      newSelectionController.addListener(_handleSelectionChanged);
      _normalizeSelection();
      _handleSelectionChanged();
    }

    if (oldWidget.stepController != widget.stepController) {
      oldWidget.stepController?.removeListener(_handleStepChanged);
      widget.stepController?.addListener(_handleStepChanged);
    }

    if (oldWidget.structure != widget.structure) {
      _normalizeSelection();
      _normalizeHoveredPart();
    }

    if (_shouldUseFallback) {
      _disposeViewer();
      return;
    }

    if (oldWidget.size != widget.size ||
        oldWidget.structure != widget.structure ||
        oldSelectionController != newSelectionController ||
        oldWidget.stepController != widget.stepController) {
      _disposeViewer();
      _createViewer();
    }
  }

  @override
  void dispose() {
    _selectionController.removeListener(_handleSelectionChanged);
    _stepController?.removeListener(_handleStepChanged);
    _ownedSelectionController.dispose();
    _disposeViewer();
    super.dispose();
  }

  bool get _shouldUseFallback {
    return _isFlutterTest || widget.size.width <= 0 || widget.size.height <= 0;
  }

  void _createViewer() {
    _appliedVisiblePartIds = _visiblePartIds;
    final buildResult = _sceneBuilder.build(
      widget.structure,
      visiblePartIds: _appliedVisiblePartIds,
    );

    final threeJs = three.ThreeJS(
      size: widget.size,
      settings: three.Settings(
        antialias: true,
        enableShadowMap: false,
        screenResolution: kIsWeb ? 1 : 1.25,
      ),
      setup: () async {
        await _renderer?.initialize(buildResult);
        _handleFocusedPartsChanged();
        _handleSelectionChanged();
        _handleHoveredPartChanged(_hoveredPartId);
      },
      onSetupComplete: () {
        _bindPointerListener();
        if (mounted) {
          setState(() {});
        }
      },
      loadingWidget: _PreviewFallback(
        size: widget.size,
        borderRadius: widget.borderRadius,
        label: '正在初始化 3D 结构预览',
      ),
    );

    _threeJs = threeJs;
    _renderer = StructurePreviewRenderer(threeJs);
  }

  void _disposeViewer() {
    _unbindPointerListener();
    _renderer?.dispose();
    _renderer = null;
    _appliedVisiblePartIds = null;
    _updateHoveredPart(null);

    if (_threeJs != null) {
      try {
        _threeJs!.dispose();
      } catch (_) {
        // three_js may dispose before setup completes.
      }
      _threeJs = null;
    }
  }

  void _recreateViewer() {
    _disposeViewer();
    _createViewer();
    if (mounted) {
      setState(() {});
    }
  }

  void _bindPointerListener() {
    if (_pointerListenerBound) {
      return;
    }

    final listenable = _threeJs?.globalKey.currentState;
    if (listenable == null) {
      return;
    }

    listenable.addEventListener(
      three.PeripheralType.pointermove,
      _onPointerMove,
    );
    listenable.addEventListener(
      three.PeripheralType.pointerdown,
      _onPointerDown,
    );
    listenable.addEventListener(
      three.PeripheralType.pointerleave,
      _onPointerLeave,
    );
    _pointerListenerBound = true;
  }

  void _unbindPointerListener() {
    if (!_pointerListenerBound) {
      return;
    }

    final listenable = _threeJs?.globalKey.currentState;
    if (listenable != null) {
      listenable.removeEventListener(
        three.PeripheralType.pointermove,
        _onPointerMove,
      );
      listenable.removeEventListener(
        three.PeripheralType.pointerdown,
        _onPointerDown,
      );
      listenable.removeEventListener(
        three.PeripheralType.pointerleave,
        _onPointerLeave,
      );
    }
    _pointerListenerBound = false;
  }

  void _handleSelectionChanged() {
    final selectedPartId = widget.structure
        .partById(_selectionController.selectedPartId)
        ?.id;
    _renderer?.setSelectedPart(selectedPartId);
  }

  void _handleStepChanged() {
    final currentVisiblePartIds = _visiblePartIds;
    if (!_samePartSets(_appliedVisiblePartIds, currentVisiblePartIds)) {
      if (!_shouldUseFallback) {
        _recreateViewer();
      }
      return;
    }

    _handleFocusedPartsChanged();
  }

  void _handleFocusedPartsChanged() {
    _renderer?.setFocusedParts(_focusedPartIds);
  }

  void _handleHoveredPartChanged(String? partId) {
    final normalizedPartId = widget.structure.partById(partId)?.id;
    _renderer?.setHoveredPart(normalizedPartId);
  }

  void _normalizeSelection() {
    final currentPartId = _selectionController.selectedPartId;
    if (currentPartId == null) {
      return;
    }

    if (widget.structure.partById(currentPartId) == null) {
      _selectionController.selectPart(null);
    }
  }

  void _normalizeHoveredPart() {
    final currentPartId = _hoveredPartId;
    if (currentPartId == null) {
      return;
    }

    if (widget.structure.partById(currentPartId) == null) {
      _updateHoveredPart(null);
    }
  }

  void _onPointerDown(dynamic event) {
    final viewer = _threeJs;
    final renderer = _renderer;
    if (viewer == null || renderer == null) {
      return;
    }

    final listenable = viewer.globalKey.currentState;
    if (listenable == null) {
      return;
    }

    final partId = _hitTestService.pickPartId(
      event: event,
      listenableKey: viewer.globalKey,
      camera: viewer.camera,
      objects: renderer.interactiveObjects,
    );
    _selectionController.selectPart(partId);
  }

  void _onPointerMove(dynamic event) {
    if (event.pointerType != 'mouse' && event.pointerType != 'pen') {
      _updateHoveredPart(null);
      return;
    }

    final viewer = _threeJs;
    final renderer = _renderer;
    if (viewer == null || renderer == null) {
      return;
    }

    final listenable = viewer.globalKey.currentState;
    if (listenable == null) {
      return;
    }

    final partId = _hitTestService.pickPartId(
      event: event,
      listenableKey: viewer.globalKey,
      camera: viewer.camera,
      objects: renderer.interactiveObjects,
    );
    _updateHoveredPart(partId);
  }

  void _onPointerLeave(dynamic _) {
    _updateHoveredPart(null);
  }

  void _updateHoveredPart(String? partId) {
    if (_hoveredPartId == partId) {
      return;
    }

    _hoveredPartId = partId;
    _handleHoveredPartChanged(partId);
    widget.onHoveredPartChanged?.call(partId);
  }

  bool _samePartSets(Set<String>? a, Set<String>? b) {
    if (a == null || b == null) {
      return a == null && b == null;
    }
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

  @override
  Widget build(BuildContext context) {
    if (_shouldUseFallback) {
      return _PreviewFallback(
        size: widget.size,
        borderRadius: widget.borderRadius,
        label: '3D 结构预览占位',
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
