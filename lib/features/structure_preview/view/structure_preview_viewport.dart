import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_hit_result.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_hit_test_service.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_scene_builder.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_candidate_overlay.dart';
import 'package:ctnh_wiki/features/structure_preview/three_js/structure_preview_renderer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class StructurePreviewViewport extends StatefulWidget {
  const StructurePreviewViewport({
    super.key,
    required this.structure,
    required this.size,
    this.visiblePartIds,
    this.selectionController,
    this.stepController,
    this.onHoveredPartChanged,
    this.onHitChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  final StructurePreviewDefinition structure;
  final Size size;
  final Set<String>? visiblePartIds;
  final StructureSelectionController? selectionController;
  final StructureStepController? stepController;
  final ValueChanged<String?>? onHoveredPartChanged;
  final ValueChanged<StructurePreviewHitResult?>? onHitChanged;
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
  StructurePreviewHitResult? _pendingHit;
  Offset? _pointerDownPosition;
  Offset? _lastPointerPosition;
  bool _pointerDragging = false;

  StructureSelectionController get _selectionController {
    return widget.selectionController ?? _ownedSelectionController;
  }

  StructureStepController? get _stepController => widget.stepController;

  Set<String>? get _visiblePartIds {
    final stepVisiblePartIds = _stepController?.visiblePartIds;
    final widgetVisiblePartIds = widget.visiblePartIds;

    if (stepVisiblePartIds == null && widgetVisiblePartIds == null) {
      return null;
    }
    if (stepVisiblePartIds == null) {
      return {...widgetVisiblePartIds!};
    }
    if (widgetVisiblePartIds == null) {
      return {...stepVisiblePartIds};
    }

    return stepVisiblePartIds.where(widgetVisiblePartIds.contains).toSet();
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

    final visiblePartIdsChanged = !_samePartSets(
      oldWidget.visiblePartIds,
      widget.visiblePartIds,
    );

    if (oldWidget.size != widget.size ||
        oldWidget.structure != widget.structure ||
        oldSelectionController != newSelectionController ||
        oldWidget.stepController != widget.stepController ||
        visiblePartIdsChanged) {
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
        toneMapping: three.ACESFilmicToneMapping,
        toneMappingExposure: 0.9,
      ),
      setup: () async {
        await _renderer?.initialize(buildResult);
        _handleFocusedPartsChanged();
        _handleSelectionChanged();
        _handleHoveredPartChanged(_hoveredPartId);
      },
      onSetupComplete: () {
        _pointerListenerBound = true;
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
    listenable.addEventListener(three.PeripheralType.pointerup, _onPointerUp);
    listenable.addEventListener(
      three.PeripheralType.pointercancel,
      _onPointerCancel,
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
        three.PeripheralType.pointerup,
        _onPointerUp,
      );
      listenable.removeEventListener(
        three.PeripheralType.pointercancel,
        _onPointerCancel,
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
    _beginPointer(
      Offset(
        (event.clientX as num).toDouble(),
        (event.clientY as num).toDouble(),
      ),
      _pickHit(event),
    );
  }

  void _onRawPointerDown(PointerDownEvent event) {
    _beginPointer(event.localPosition, _pickHitAt(event.localPosition));
  }

  void _beginPointer(Offset position, StructurePreviewHitResult? hit) {
    _pointerDownPosition = position;
    _lastPointerPosition = position;
    _pointerDragging = false;
    _pendingHit = hit;
    _updateHoveredPart(hit?.partId);
  }

  void _onPointerMove(dynamic event) {
    _movePointer(
      Offset(
        (event.clientX as num).toDouble(),
        (event.clientY as num).toDouble(),
      ),
      event.pointerType?.toString() ?? 'mouse',
      _pickHit(event),
      event.buttons,
    );
  }

  void _onRawPointerMove(PointerMoveEvent event) {
    _movePointer(
      event.localPosition,
      _pointerTypeName(event.kind),
      _pickHitAt(event.localPosition),
      event.buttons,
    );
  }

  void _movePointer(
    Offset position,
    String pointerType,
    StructurePreviewHitResult? hit,
    Object? buttons,
  ) {
    if (buttons is num && buttons.toInt() & 1 == 0) {
      _resetPointerState();
    }
    if (_pointerDownPosition != null) {
      final totalDelta = position - _pointerDownPosition!;
      if (totalDelta.distance > 8) {
        _pointerDragging = true;
      }
      final delta = position - (_lastPointerPosition ?? _pointerDownPosition!);
      _lastPointerPosition = position;
      if (_pointerDragging && delta.distance > 0) {
        _renderer?.rotateBy(delta.dx, delta.dy);
      }
      if (_pointerDragging) {
        return;
      }
    }

    if (pointerType != 'mouse' &&
        pointerType != 'pen' &&
        pointerType != 'stylus') {
      _updateHoveredPart(null);
      return;
    }
    _updateHoveredPart(hit?.partId);
  }

  void _onPointerUp(dynamic event) {
    _finishPointer();
  }

  void _onRawPointerUp(PointerUpEvent event) {
    _finishPointer();
  }

  void _finishPointer() {
    final hit = _pendingHit;
    final wasDragging = _pointerDragging;
    _resetPointerState();
    if (wasDragging || hit == null) {
      return;
    }
    widget.onHitChanged?.call(hit);
    _selectionController.selectPart(hit.partId);
  }

  void _onRawPointerHover(PointerHoverEvent event) {
    _updateHoveredPart(_pickHitAt(event.localPosition)?.partId);
  }

  void _onPointerCancel(dynamic _) {
    _resetPointerState();
  }

  void _onRawPointerCancel(PointerCancelEvent event) {
    _resetPointerState();
  }

  void _onPointerLeave(dynamic _) {
    _resetPointerState();
    _updateHoveredPart(null);
  }

  String _pointerTypeName(PointerDeviceKind kind) {
    return switch (kind) {
      PointerDeviceKind.mouse => 'mouse',
      PointerDeviceKind.stylus => 'stylus',
      PointerDeviceKind.invertedStylus => 'stylus',
      PointerDeviceKind.touch => 'touch',
      _ => 'other',
    };
  }

  StructurePreviewHitResult? _pickHit(dynamic event) {
    final viewer = _threeJs;
    final renderer = _renderer;
    if (viewer == null || renderer == null) {
      return null;
    }
    final listenable = viewer.globalKey.currentState;
    if (listenable == null) {
      return null;
    }
    return _hitTestService.pickHit(
      event: event,
      listenableKey: viewer.globalKey,
      camera: viewer.camera,
      objects: renderer.interactiveObjects,
    );
  }

  StructurePreviewHitResult? _pickHitAt(Offset localPosition) {
    final viewer = _threeJs;
    final renderer = _renderer;
    if (viewer == null || renderer == null) {
      return null;
    }
    final listenable = viewer.globalKey.currentState;
    if (listenable == null) {
      return null;
    }
    return _hitTestService.pickHitAt(
      localPosition: localPosition,
      listenableKey: viewer.globalKey,
      camera: viewer.camera,
      objects: renderer.interactiveObjects,
    );
  }

  void _resetPointerState() {
    _pendingHit = null;
    _pointerDownPosition = null;
    _lastPointerPosition = null;
    _pointerDragging = false;
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
      child: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _onRawPointerDown,
            onPointerMove: _onRawPointerMove,
            onPointerUp: _onRawPointerUp,
            onPointerCancel: _onRawPointerCancel,
            onPointerHover: _onRawPointerHover,
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(event, (
                  signalEvent,
                ) {
                  signalEvent.respond(allowPlatformDefault: false);
                });
              }
            },
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: viewer.build(),
            ),
          ),
          AnimatedBuilder(
            animation: _selectionController,
            builder: (context, _) {
              final part = widget.structure.partById(
                _selectionController.selectedPartId,
              );
              if (part == null || part.candidates.isEmpty) {
                return const SizedBox.shrink();
              }
              return StructureCandidateOverlay(candidates: part.candidates);
            },
          ),
        ],
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
