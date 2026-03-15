import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:ctnh_wiki/features/home/data/tech_structure_preview_data.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/view/structure_preview_viewport.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_part_detail_card.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_step_timeline.dart';
import 'package:flutter/material.dart';

class TechModulePage extends StatefulWidget {
  const TechModulePage({super.key});

  @override
  State<TechModulePage> createState() => _TechModulePageState();
}

class _TechModulePageState extends State<TechModulePage> {
  late final StructureSelectionController _selectionController;
  late final StructureStepController _stepController;

  @override
  void initState() {
    super.initState();
    _stepController = StructureStepController(
      steps: techStructurePreviewDefinition.steps,
      initialIndex: techStructurePreviewDefinition.steps.isEmpty
          ? 0
          : techStructurePreviewDefinition.steps.length - 1,
    );
    _selectionController = StructureSelectionController(
      initialPartId: _resolveStepSelection(),
    );
    _stepController.addListener(_syncSelectionWithStep);
  }

  @override
  void dispose() {
    _stepController.removeListener(_syncSelectionWithStep);
    _selectionController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _syncSelectionWithStep() {
    final visiblePartIds = _stepController.visiblePartIds;
    final currentPartId = _selectionController.selectedPartId;
    if (currentPartId != null &&
        visiblePartIds != null &&
        visiblePartIds.contains(currentPartId)) {
      return;
    }

    _selectionController.selectPart(_resolveStepSelection());
  }

  String? _resolveStepSelection() {
    final focusedPartIds = _stepController.focusedPartIds;
    if (focusedPartIds.isNotEmpty) {
      return focusedPartIds.first;
    }

    final visiblePartIds = _stepController.visiblePartIds;
    if (visiblePartIds != null && visiblePartIds.isNotEmpty) {
      return visiblePartIds.first;
    }

    if (techStructurePreviewDefinition.parts.isEmpty) {
      return null;
    }

    return techStructurePreviewDefinition.parts.first.id;
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
          selectionController: _selectionController,
          stepController: _stepController,
        ),
        const SizedBox(height: 20),
        const _HighlightTile(
          title: '结构预览已接入步骤系统',
          description: '科技模块示例现在会按步骤逐层展示底座、动力、机器和显示单元，并同步控制 3D 结构里的可见部件。',
        ),
        const _HighlightTile(
          title: '悬停、选中与说明联动',
          description: '鼠标悬停部件时会先给出轻量高亮提示，点击后再固定选中并在右侧展示详细说明，交互层级已经拆开。',
        ),
        const _HighlightTile(
          title: '已具备继续扩展的骨架',
          description:
              '当前结构数据、步骤控制、点击命中、悬停高亮和 block 渲染映射都已经接通，后续可以继续往图层过滤与更多方块外观扩展。',
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
    required this.selectionController,
    required this.stepController,
  });

  final bool isCompact;
  final StructureSelectionController selectionController;
  final StructureStepController stepController;

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
                        'three_js 原生预览',
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
                  animation: widget.stepController,
                  builder: (context, _) {
                    final currentStep = widget.stepController.currentStep;
                    final label = hoveredPart != null
                        ? '悬停部件：${hoveredPart.displayName}。点击后可在右侧固定查看详情。'
                        : currentStep == null
                        ? '悬停或点击结构中的部件，右侧会同步显示该部件的说明。'
                        : '当前步骤：${currentStep.title}。可切换下方步骤条查看逐步搭建过程。';

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
                        label,
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

    final notesCard = AnimatedBuilder(
      animation: Listenable.merge([
        widget.selectionController,
        widget.stepController,
      ]),
      builder: (context, _) {
        final selectedPart = techStructurePreviewDefinition.partById(
          widget.selectionController.selectedPartId,
        );
        final currentStep = widget.stepController.currentStep;
        final visiblePartCount =
            widget.stepController.visiblePartIds?.length ??
            techStructurePreviewDefinition.parts.length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7DCCB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '多方块结构预览',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF201A16),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                techStructurePreviewDefinition.metadata.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF5F554D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                techStructurePreviewDefinition.metadata.summary,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF7A6D63),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _PreviewTag(
                    label: '${techStructurePreviewDefinition.parts.length} 个部件',
                  ),
                  _PreviewTag(label: '$visiblePartCount 个已显示'),
                  _PreviewTag(
                    label:
                        '步骤 ${widget.stepController.currentIndex + 1}/${widget.stepController.stepCount}',
                  ),
                  if (hoveredPart != null)
                    _PreviewTag(label: '悬停 ${hoveredPart.displayName}'),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionLabel(label: '当前步骤'),
              const SizedBox(height: 10),
              _StepSummaryCard(
                currentIndex: widget.stepController.currentIndex,
                totalCount: widget.stepController.stepCount,
                stepTitle: currentStep?.title ?? '未配置步骤',
                stepDescription: currentStep?.description ?? '当前结构还没有步骤说明。',
              ),
              const SizedBox(height: 18),
              const _SectionLabel(label: '当前选中部件'),
              const SizedBox(height: 10),
              StructurePartDetailCard(part: selectedPart),
              const SizedBox(height: 18),
              const _SectionLabel(label: '当前已落地能力'),
              const SizedBox(height: 10),
              ...[
                ...techPreviewApiBullets,
                '支持鼠标悬停高亮，与点击选中和步骤焦点分离处理。',
                '已接入步骤控制器，支持按阶段控制结构显示范围和当前焦点。',
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BulletRow(text: item),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionLabel(label: '下一步扩展'),
              const SizedBox(height: 10),
              ...[
                ...techPreviewRoadmap,
                '继续补齐图层过滤、更多 block 外观注册和更完整的结构说明面板。',
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BulletRow(text: item),
                ),
              ),
            ],
          ),
        );
      },
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
}

class _StepSummaryCard extends StatelessWidget {
  const _StepSummaryCard({
    required this.currentIndex,
    required this.totalCount,
    required this.stepTitle,
    required this.stepDescription,
  });

  final int currentIndex;
  final int totalCount;
  final String stepTitle;
  final String stepDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6D9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '步骤 ${currentIndex + 1}/$totalCount',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xFF9C6A2B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stepTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stepDescription,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF4E443D),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Color(0xFF9C6A2B),
      ),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C4531),
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 7, color: Color(0xFFC88A3D)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF4E443D),
            ),
          ),
        ),
      ],
    );
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
