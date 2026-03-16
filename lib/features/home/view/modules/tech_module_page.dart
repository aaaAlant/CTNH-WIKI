import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:ctnh_wiki/features/home/data/tech_structure_preview_data.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_filter_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_filter_resolver.dart';
import 'package:ctnh_wiki/features/structure_preview/view/structure_preview_viewport.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_insight_panel.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_step_timeline.dart';
import 'package:flutter/material.dart';

class TechModulePage extends StatefulWidget {
  const TechModulePage({super.key});

  @override
  State<TechModulePage> createState() => _TechModulePageState();
}

class _TechModulePageState extends State<TechModulePage> {
  static const _filterResolver = StructurePreviewFilterResolver();

  late final StructureSelectionController _selectionController;
  late final StructureStepController _stepController;
  late final StructureFilterController _filterController;

  Set<String> get _visiblePartIds {
    return _filterResolver.resolveVisiblePartIds(
      definition: techStructurePreviewDefinition,
      stepController: _stepController,
      filterController: _filterController,
    );
  }

  @override
  void initState() {
    super.initState();
    _stepController = StructureStepController(
      steps: techStructurePreviewDefinition.steps,
      initialIndex: techStructurePreviewDefinition.steps.isEmpty
          ? 0
          : techStructurePreviewDefinition.steps.length - 1,
    );
    _filterController = StructureFilterController(
      parts: techStructurePreviewDefinition.parts,
    );
    _selectionController = StructureSelectionController(
      initialPartId: _resolveVisibleSelection(_visiblePartIds),
    );
    _stepController.addListener(_handlePresentationChanged);
    _filterController.addListener(_handlePresentationChanged);
  }

  @override
  void dispose() {
    _stepController.removeListener(_handlePresentationChanged);
    _filterController.removeListener(_handlePresentationChanged);
    _selectionController.dispose();
    _stepController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _handlePresentationChanged() {
    _syncSelectionWithVisibility();
    if (mounted) {
      setState(() {});
    }
  }

  void _syncSelectionWithVisibility() {
    final visiblePartIds = _visiblePartIds;
    final currentPartId = _selectionController.selectedPartId;
    if (currentPartId != null && visiblePartIds.contains(currentPartId)) {
      return;
    }

    _selectionController.selectPart(_resolveVisibleSelection(visiblePartIds));
  }

  String? _resolveVisibleSelection(Set<String> visiblePartIds) {
    final focusedPartIds = _stepController.focusedPartIds;
    for (final partId in focusedPartIds) {
      if (visiblePartIds.contains(partId)) {
        return partId;
      }
    }

    final currentStepPartIds = _filterResolver.resolveCurrentStepPartIds(
      _stepController,
    );
    if (_filterController.showOnlyCurrentStepParts) {
      for (final partId in currentStepPartIds) {
        if (visiblePartIds.contains(partId)) {
          return partId;
        }
      }
    }

    for (final part in techStructurePreviewDefinition.parts) {
      if (visiblePartIds.contains(part.id)) {
        return part.id;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 920;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModuleHeader(
          icon: techHomeModule.icon,
          tint: techHomeModule.tint,
          title: techHomeModule.title,
          description: techHomeModule.description,
        ),
        const SizedBox(height: 24),
        _TechPreviewShowcase(
          isCompact: isCompact,
          visiblePartIds: _visiblePartIds,
          selectionController: _selectionController,
          stepController: _stepController,
          filterController: _filterController,
        ),
        const SizedBox(height: 20),
        const _HighlightTile(
          title: '正式结构模型',
          description: '科技示例现在通过正式的结构定义驱动，部件、步骤、筛选和说明面板都围绕同一套数据组织。',
        ),
        const _HighlightTile(
          title: '交互链路已接通',
          description: '左侧 3D 预览已经支持悬停、选中、步骤切换和分类过滤，右侧说明区会同步展示当前结构状态。',
        ),
        const _HighlightTile(
          title: '下一步进入真实渲染',
          description: '说明面板已经成型，接下来可以继续扩展 block 注册表、六面贴图和特殊模型，让结构外观更接近真实方块。',
        ),
      ],
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.icon,
    required this.tint,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: const Color(0xFF201A16)),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF201A16),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Color(0xFF5F554D),
          ),
        ),
      ],
    );
  }
}

class _TechPreviewShowcase extends StatefulWidget {
  const _TechPreviewShowcase({
    required this.isCompact,
    required this.visiblePartIds,
    required this.selectionController,
    required this.stepController,
    required this.filterController,
  });

  final bool isCompact;
  final Set<String> visiblePartIds;
  final StructureSelectionController selectionController;
  final StructureStepController stepController;
  final StructureFilterController filterController;

  @override
  State<_TechPreviewShowcase> createState() => _TechPreviewShowcaseState();
}

class _TechPreviewShowcaseState extends State<_TechPreviewShowcase> {
  String? _hoveredPartId;

  void _handleHoveredPartChanged(String? partId) {
    if (!mounted || _hoveredPartId == partId) {
      return;
    }

    setState(() {
      _hoveredPartId = partId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hoveredPart = techStructurePreviewDefinition.partById(_hoveredPartId);

    final previewCard = LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final previewHeight = widget.isCompact ? 280.0 : 360.0;

        return Stack(
          children: [
            StructurePreviewViewport(
              structure: techStructurePreviewDefinition,
              size: Size(maxWidth, previewHeight),
              visiblePartIds: widget.visiblePartIds,
              selectionController: widget.selectionController,
              stepController: widget.stepController,
              onHoveredPartChanged: _handleHoveredPartChanged,
            ),
            Positioned(
              top: 14,
              left: 14,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.46),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.view_in_ar_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'three_js 原型预览',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    widget.stepController,
                    widget.filterController,
                  ]),
                  builder: (context, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _buildPreviewHint(
                          hoveredPart: hoveredPart,
                          stepController: widget.stepController,
                          filterController: widget.filterController,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    final notesCard = StructureInsightPanel(
      structure: techStructurePreviewDefinition,
      selectionController: widget.selectionController,
      stepController: widget.stepController,
      filterController: widget.filterController,
      visiblePartCount: widget.visiblePartIds.length,
      hoveredPartId: _hoveredPartId,
      capabilityBullets: techPreviewApiBullets,
      roadmapBullets: techPreviewRoadmap,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.isCompact ? 18 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EEE1), Color(0xFFF5EBE0), Color(0xFFEDE4D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE3D7C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    previewCard,
                    const SizedBox(height: 16),
                    notesCard,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: previewCard),
                    const SizedBox(width: 18),
                    Expanded(flex: 9, child: notesCard),
                  ],
                ),
          const SizedBox(height: 18),
          StructureStepTimeline(controller: widget.stepController),
        ],
      ),
    );
  }

  String _buildPreviewHint({
    required StructureStepController stepController,
    required StructureFilterController filterController,
    required hoveredPart,
  }) {
    final currentStep = stepController.currentStep;

    if (hoveredPart != null) {
      return '悬停：${hoveredPart.displayName}。点击可锁定该部件，并在右侧查看详细说明。';
    }

    if (filterController.showOnlyCurrentStepParts && currentStep != null) {
      return '当前仅显示步骤“${currentStep.title}”相关部件，可配合右侧过滤面板查看不同分类。';
    }

    if (currentStep == null) {
      return '拖动可旋转视角，滚轮可缩放。点击部件后，右侧说明面板会同步展示详细信息。';
    }

    return '当前处于步骤“${currentStep.title}”。可拖动视角或点击部件，查看对应的结构说明。';
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7DCCB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF201A16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF5F554D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
