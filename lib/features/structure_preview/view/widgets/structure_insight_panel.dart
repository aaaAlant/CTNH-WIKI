import 'package:ctnh_wiki/features/structure_preview/controllers/structure_filter_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_metadata.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_filter_panel.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_part_detail_card.dart';
import 'package:flutter/material.dart';

class StructureInsightPanel extends StatelessWidget {
  const StructureInsightPanel({
    super.key,
    required this.structure,
    required this.selectionController,
    required this.stepController,
    required this.filterController,
    required this.visiblePartCount,
    this.hoveredPartId,
    this.hoveredPartNotifier,
  });

  final StructurePreviewDefinition structure;
  final StructureSelectionController selectionController;
  final StructureStepController stepController;
  final StructureFilterController filterController;
  final int visiblePartCount;
  final String? hoveredPartId;
  final ValueNotifier<String?>? hoveredPartNotifier;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        selectionController,
        stepController,
        filterController,
        if (hoveredPartNotifier != null) hoveredPartNotifier!,
      ]),
      builder: (context, _) {
        final metadata = structure.metadata;
        final currentStep = stepController.currentStep;
        final selectedPart = structure.partById(
          selectionController.selectedPartId,
        );
        final hoveredPart = structure.partById(
          hoveredPartNotifier?.value ?? hoveredPartId,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7DCCB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '结构说明',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF201A16),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                metadata.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF5F554D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                metadata.summary,
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
                  _PreviewTag(label: '${structure.parts.length} 个方块'),
                  _PreviewTag(label: '$visiblePartCount 个已显示'),
                  _PreviewTag(
                    label:
                        '第 ${stepController.currentIndex + 1}/${stepController.stepCount} 步',
                  ),
                  if (filterController.hasActiveFilter)
                    const _PreviewTag(label: '已启用过滤'),
                  if (hoveredPart != null)
                    _PreviewTag(label: '当前指向 ${hoveredPart.displayName}'),
                ],
              ),
              const SizedBox(height: 18),
              _SectionLabel(label: '结构信息'),
              const SizedBox(height: 10),
              _OverviewCard(
                metadata: metadata,
                partCount: structure.parts.length,
              ),
              const SizedBox(height: 18),
              StructureFilterPanel(
                structure: structure,
                controller: filterController,
                stepController: stepController,
                visiblePartCount: visiblePartCount,
              ),
              const SizedBox(height: 18),
              _SectionLabel(label: '当前视图'),
              const SizedBox(height: 10),
              _StepSummaryCard(
                currentIndex: stepController.currentIndex,
                totalCount: stepController.stepCount,
                stepTitle: currentStep?.title ?? '完整结构',
                stepDescription: currentStep?.description ?? '查看多方块整体结构。',
                focusedPartCount: stepController.focusedPartIds.length,
              ),
              const SizedBox(height: 18),
              _SectionLabel(label: '当前方块'),
              const SizedBox(height: 10),
              StructurePartDetailCard(part: selectedPart),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.metadata, required this.partCount});

  final StructurePreviewMetadata metadata;
  final int partCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6D9C8)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _OverviewChip(label: '模块', value: _moduleLabel(metadata.module)),
          _OverviewChip(label: '方块', value: '$partCount'),
          if (metadata.versionRange != null)
            _OverviewChip(label: '版本', value: _versionLabel(metadata)),
        ],
      ),
    );
  }

  String _moduleLabel(StructurePreviewModule module) {
    return switch (module) {
      StructurePreviewModule.tech => '科技',
      StructurePreviewModule.magic => '魔法',
      StructurePreviewModule.adventure => '冒险',
      StructurePreviewModule.shared => '通用',
    };
  }

  String _versionLabel(StructurePreviewMetadata metadata) {
    final range = metadata.versionRange;
    if (range == null) {
      return '未指定';
    }

    if (range.minVersion != null && range.maxVersion != null) {
      return '${range.minVersion} - ${range.maxVersion}';
    }
    if (range.minVersion != null) {
      return '${range.minVersion}+';
    }
    if (range.maxVersion != null) {
      return '<= ${range.maxVersion}';
    }
    return range.note ?? '未指定';
  }
}

class _StepSummaryCard extends StatelessWidget {
  const _StepSummaryCard({
    required this.currentIndex,
    required this.totalCount,
    required this.stepTitle,
    required this.stepDescription,
    required this.focusedPartCount,
  });

  final int currentIndex;
  final int totalCount;
  final String stepTitle;
  final String stepDescription;
  final int focusedPartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6D9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '第 ${currentIndex + 1}/$totalCount 步',
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
          const SizedBox(height: 12),
          Text(
            '当前聚焦 $focusedPartCount 个核心方块，可在左侧结构图中点击查看详细信息。',
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF6B625A),
            ),
          ),
        ],
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

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF5F554D),
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
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
