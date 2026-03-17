import 'dart:math' as math;

import 'package:ctnh_wiki/app/web_ctrl_wheel_listener.dart';
import 'package:ctnh_wiki/features/tasks/models/quest_catalog.dart';
import 'package:ctnh_wiki/features/tasks/view/widgets/quest_item_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestGraphPanel extends StatefulWidget {
  const QuestGraphPanel({
    super.key,
    required this.chapter,
    required this.selectedQuest,
    required this.onQuestSelected,
  });

  final QuestChapter chapter;
  final QuestDefinition? selectedQuest;
  final ValueChanged<QuestDefinition> onQuestSelected;

  @override
  State<QuestGraphPanel> createState() => _QuestGraphPanelState();
}

class _QuestGraphPanelState extends State<QuestGraphPanel> {
  static const _minScale = 0.35;
  static const _maxScale = 2.4;

  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _viewportKey = GlobalKey();
  final FocusNode _focusNode = FocusNode(debugLabel: 'quest-graph-panel');

  bool _isCtrlPressed = false;
  bool _isHoveringGraph = false;
  Object? _webWheelListener;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    if (kIsWeb) {
      _webWheelListener = WebCtrlWheelListener.add(_handleWebCtrlWheel);
    }
  }

  @override
  void didUpdateWidget(covariant QuestGraphPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    WebCtrlWheelListener.remove(_webWheelListener);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _focusNode.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cellSize = 116.0;
    const padding = 160.0;

    final graphWidth =
        ((widget.chapter.bounds.maxX - widget.chapter.bounds.minX) + 1.4) *
            cellSize +
        padding * 2;
    final graphHeight =
        ((widget.chapter.bounds.maxY - widget.chapter.bounds.minY) + 1.4) *
            cellSize +
        padding * 2;

    final centers = <String, Offset>{};
    for (final quest in widget.chapter.quests) {
      final nodeSize = _nodeSize(quest.size);
      final origin = _questOffset(
        quest.x,
        quest.y,
        widget.chapter.bounds,
        cellSize,
        padding,
      );
      centers[quest.id] = Offset(
        origin.dx + nodeSize / 2,
        origin.dy + nodeSize / 2,
      );
    }

    return Container(
      height: 760,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1A0C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFB98B44), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chapter.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF4E2C3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.chapter.subtitle.isEmpty
                          ? '当前章节包含 ${widget.chapter.questCount} 个任务节点和 ${widget.chapter.questLinkCount} 个跳转标签。'
                          : widget.chapter.subtitle.join(' '),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFFE1C7A0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _GraphHintChip(
                label: _isCtrlPressed ? '松开 Ctrl 退出缩放模式' : '按住 Ctrl + 滚轮缩放',
              ),
              if (widget.selectedQuest != null) ...[
                const SizedBox(width: 12),
                _GraphSelectionBadge(title: widget.selectedQuest!.title),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Focus(
              focusNode: _focusNode,
              child: MouseRegion(
                onEnter: (_) => _setGraphHovering(true),
                onExit: (_) => _setGraphHovering(false),
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) {
                    _focusNode.requestFocus();
                    _setGraphHovering(true);
                  },
                  onPointerHover: (_) {
                    if (!_focusNode.hasFocus) {
                      _focusNode.requestFocus();
                    }
                    if (!_isHoveringGraph) {
                      _setGraphHovering(true);
                    }
                  },
                  onPointerSignal: _handlePointerSignal,
                  child: Container(
                    key: _viewportKey,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A210F),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF865428)),
                    ),
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      boundaryMargin: const EdgeInsets.all(220),
                      constrained: false,
                      scaleEnabled: false,
                      child: SizedBox(
                        width: graphWidth,
                        height: graphHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _QuestDependencyPainter(
                                  quests: widget.chapter.quests,
                                  centers: centers,
                                  selectedQuestId: widget.selectedQuest?.id,
                                ),
                              ),
                            ),
                            ...widget.chapter.questLinks.map((link) {
                              final offset = _questOffset(
                                link.x,
                                link.y,
                                widget.chapter.bounds,
                                cellSize,
                                padding,
                              );
                              return Positioned(
                                left: offset.dx - 46,
                                top: offset.dy - 18,
                                child: GestureDetector(
                                  onTap: () {
                                    final linkedQuest = widget.chapter
                                        .questById(link.linkedQuestId);
                                    if (linkedQuest != null) {
                                      widget.onQuestSelected(linkedQuest);
                                    }
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 120,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6B4020),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFFD0A768),
                                      ),
                                    ),
                                    child: Text(
                                      link.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFFF0D0),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            ...widget.chapter.quests.map((quest) {
                              final size = _nodeSize(quest.size);
                              final offset = _questOffset(
                                quest.x,
                                quest.y,
                                widget.chapter.bounds,
                                cellSize,
                                padding,
                              );
                              return Positioned(
                                left: offset.dx,
                                top: offset.dy,
                                child: _QuestNode(
                                  quest: quest,
                                  size: size,
                                  selected:
                                      quest.id == widget.selectedQuest?.id,
                                  onTap: () => widget.onQuestSelected(quest),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _handleKeyEvent(KeyEvent event) {
    final nextValue = HardwareKeyboard.instance.isControlPressed;
    if (nextValue != _isCtrlPressed && mounted) {
      setState(() {
        _isCtrlPressed = nextValue;
      });
    }
    return false;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || kIsWeb) {
      return;
    }

    final ctrlPressed =
        _isCtrlPressed || HardwareKeyboard.instance.isControlPressed;
    if (!ctrlPressed) {
      return;
    }

    _applyZoom(globalPosition: event.position, deltaY: event.scrollDelta.dy);
  }

  bool _handleWebCtrlWheel({
    required double deltaY,
    required double clientX,
    required double clientY,
    required bool ctrlKey,
  }) {
    if (!mounted || !_isHoveringGraph || !ctrlKey) {
      return false;
    }

    final globalPosition = Offset(clientX, clientY);
    if (!_containsGlobalPoint(globalPosition)) {
      return false;
    }

    _applyZoom(globalPosition: globalPosition, deltaY: deltaY);
    return true;
  }

  void _applyZoom({required Offset globalPosition, required double deltaY}) {
    final renderBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final pointerPosition = renderBox.globalToLocal(globalPosition);
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final nextScale = (currentScale * math.exp(-deltaY / 280))
        .clamp(_minScale, _maxScale)
        .toDouble();
    final scaleChange = nextScale / currentScale;
    if ((scaleChange - 1).abs() < 0.001) {
      return;
    }

    final focalPoint = _transformationController.toScene(pointerPosition);
    final nextMatrix = _transformationController.value.clone()
      ..translateByDouble(focalPoint.dx, focalPoint.dy, 0, 1)
      ..scaleByDouble(scaleChange, scaleChange, 1, 1)
      ..translateByDouble(-focalPoint.dx, -focalPoint.dy, 0, 1);
    _transformationController.value = nextMatrix;
  }

  bool _containsGlobalPoint(Offset globalPoint) {
    final renderBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return false;
    }

    final origin = renderBox.localToGlobal(Offset.zero);
    final rect = origin & renderBox.size;
    return rect.contains(globalPoint);
  }

  void _setGraphHovering(bool hovering) {
    if (_isHoveringGraph == hovering) {
      return;
    }

    setState(() {
      _isHoveringGraph = hovering;
    });
  }

  static Offset _questOffset(
    double x,
    double y,
    QuestGraphBounds bounds,
    double cellSize,
    double padding,
  ) {
    return Offset(
      (x - bounds.minX) * cellSize + padding,
      (y - bounds.minY) * cellSize + padding,
    );
  }

  static double _nodeSize(double size) {
    return switch (size) {
      >= 2 => 94,
      >= 1.5 => 82,
      >= 1.2 => 74,
      _ => 62,
    };
  }
}

class _GraphHintChip extends StatelessWidget {
  const _GraphHintChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF56311A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBC8E52)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF6D8A7),
        ),
      ),
    );
  }
}

class _QuestNode extends StatelessWidget {
  const _QuestNode({
    required this.quest,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final QuestDefinition quest;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? const Color(0xFF966027)
        : const Color(0xFF646464);
    final borderColor = selected
        ? const Color(0xFFFFE2A6)
        : const Color(0xFFD8D8D8);

    Widget surface = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: _shapeIsCircular(quest.shape)
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: _shapeIsCircular(quest.shape)
            ? null
            : BorderRadius.circular(_shapeRadius(quest.shape)),
        border: Border.all(color: borderColor, width: selected ? 2.6 : 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _QuestNodeContent(quest: quest, selected: selected, size: size),
    );

    if (_shapeNeedsPolygonClip(quest.shape)) {
      surface = ClipPath(
        clipper: _PolygonClipper(sides: _polygonSides(quest.shape)),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: borderColor, width: selected ? 2.6 : 1.6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: _QuestNodeContent(quest: quest, selected: selected, size: size),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: surface),
            Positioned(
              right: -6,
              bottom: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1F1814)
                      : const Color(0xFF37312B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shapeIsCircular(String shape) {
    return shape == 'circle' || shape == 'heart';
  }

  bool _shapeNeedsPolygonClip(String shape) {
    return switch (shape) {
      'hexagon' || 'octagon' || 'pentagon' || 'gear' => true,
      _ => false,
    };
  }

  int _polygonSides(String shape) {
    return switch (shape) {
      'hexagon' => 6,
      'octagon' => 8,
      'pentagon' => 5,
      'gear' => 8,
      _ => 6,
    };
  }

  double _shapeRadius(String shape) {
    return switch (shape) {
      'square' => 18,
      'rsquare' => 14,
      'diamond' => 8,
      _ => 20,
    };
  }
}

class _QuestNodeContent extends StatelessWidget {
  const _QuestNodeContent({
    required this.quest,
    required this.selected,
    required this.size,
  });

  final QuestDefinition quest;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = _nodeLabel(quest);
    final hasIcon =
        quest.iconAssetPath != null && quest.iconAssetPath!.isNotEmpty;
    final isCompact = size <= 62;
    final isMedium = size > 62 && size < 82;
    final padding = isCompact ? 4.0 : isMedium ? 6.0 : 8.0;
    final iconSize = hasIcon
        ? isCompact
            ? 20.0
            : isMedium
                ? 24.0
                : selected
                    ? 34.0
                    : 30.0
        : 0.0;
    final textSize = isCompact
        ? 9.0
        : isMedium
            ? 10.0
            : selected
                ? 12.0
                : 11.0;
    final maxLines = hasIcon
        ? isCompact
            ? 1
            : 2
        : isCompact
            ? 2
            : 3;
    final gap = hasIcon ? (isCompact ? 3.0 : 6.0) : 0.0;
    final showHeartAccent = quest.shape == 'heart' && size >= 74 && !hasIcon;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon) ...[
              QuestItemIcon(
                size: iconSize,
                assetPath: quest.iconAssetPath,
                framed: false,
                fallbackIcon: Icons.inventory_2_rounded,
                iconColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              SizedBox(height: gap),
            ],
            Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            if (showHeartAccent) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.favorite_rounded,
                size: 12,
                color: Color(0xFFFFD7D7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _nodeLabel(QuestDefinition quest) {
    final assetLabel = quest.iconLabel;
    if (assetLabel != null && assetLabel.isNotEmpty) {
      return assetLabel;
    }

    final icon = quest.icon;
    if (icon != null && icon.isNotEmpty) {
      final name = prettyItemLabel(icon);
      if (name.length <= 12) {
        return name;
      }
    }
    return quest.title;
  }
}

class _QuestDependencyPainter extends CustomPainter {
  const _QuestDependencyPainter({
    required this.quests,
    required this.centers,
    required this.selectedQuestId,
  });

  final List<QuestDefinition> quests;
  final Map<String, Offset> centers;
  final String? selectedQuestId;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = const Color(0xFF8A6654)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = const Color(0xFFD6B57B)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    for (final quest in quests) {
      final to = centers[quest.id];
      if (to == null) {
        continue;
      }

      for (final dependency in quest.dependencies) {
        final from = centers[dependency];
        if (from == null) {
          continue;
        }

        final isHighlighted =
            selectedQuestId != null &&
            (quest.id == selectedQuestId || dependency == selectedQuestId);
        canvas.drawLine(from, to, isHighlighted ? highlightPaint : basePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QuestDependencyPainter oldDelegate) {
    return oldDelegate.selectedQuestId != selectedQuestId ||
        oldDelegate.quests != quests ||
        oldDelegate.centers != centers;
  }
}

class _GraphSelectionBadge extends StatelessWidget {
  const _GraphSelectionBadge({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6E4320),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0D39E)),
      ),
      child: Text(
        '当前任务：$title',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFFFFF0D0),
        ),
      ),
    );
  }
}

class _PolygonClipper extends CustomClipper<Path> {
  const _PolygonClipper({required this.sides});

  final int sides;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = (-math.pi / 2) + (2 * math.pi * i / sides);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _PolygonClipper oldClipper) {
    return oldClipper.sides != sides;
  }
}

String prettyItemLabel(String itemId) {
  final raw = itemId.contains(':') ? itemId.split(':').last : itemId;
  return raw
      .split('_')
      .where((segment) => segment.isNotEmpty)
      .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
      .join(' ');
}






