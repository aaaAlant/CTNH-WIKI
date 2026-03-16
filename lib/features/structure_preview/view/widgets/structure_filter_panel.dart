import 'package:ctnh_wiki/features/structure_preview/controllers/structure_filter_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:flutter/material.dart';

class StructureFilterPanel extends StatelessWidget {
  const StructureFilterPanel({
    super.key,
    required this.structure,
    required this.controller,
    required this.visiblePartCount,
    this.stepController,
  });

  final StructurePreviewDefinition structure;
  final StructureFilterController controller;
  final int visiblePartCount;
  final StructureStepController? stepController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, stepController]),
      builder: (context, _) {
        final sortedCategories = controller.availableCategories.toList()
          ..sort(
            (left, right) =>
                _categoryLabel(left).compareTo(_categoryLabel(right)),
          );

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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '视图过滤',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.hasActiveFilter
                        ? controller.reset
                        : null,
                    child: const Text('重置'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _buildSummaryLabel(),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF5F554D),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => controller.setShowOnlyCurrentStepParts(
                  !controller.showOnlyCurrentStepParts,
                ),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7DCCB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.showOnlyCurrentStepParts
                            ? Icons.visibility_rounded
                            : Icons.layers_clear_rounded,
                        size: 18,
                        color: const Color(0xFF6B4F2D),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '只看当前步骤相关部件',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF201A16),
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: controller.showOnlyCurrentStepParts,
                        onChanged: controller.setShowOnlyCurrentStepParts,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: sortedCategories.map((category) {
                  final count = structure.parts
                      .where((part) => part.category == category)
                      .length;

                  return FilterChip(
                    label: Text('${_categoryLabel(category)} $count'),
                    selected: controller.isCategoryVisible(category),
                    onSelected: (_) => controller.toggleCategory(category),
                    selectedColor: const Color(0xFFF3E2C6),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2D6C3)),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E443D),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildSummaryLabel() {
    final totalCount = structure.parts.length;
    final currentStep = stepController?.currentStep;
    final stepLabel = controller.showOnlyCurrentStepParts && currentStep != null
        ? '当前仅显示步骤“${currentStep.title}”相关部件。'
        : '当前显示 $visiblePartCount / $totalCount 个部件。';

    final categoryLabel = controller.hasCategoryFilter
        ? '已启用分类过滤。'
        : '当前分类全部可见。';

    return '$stepLabel $categoryLabel';
  }

  String _categoryLabel(StructurePartCategory category) {
    return switch (category) {
      StructurePartCategory.foundation => '基础',
      StructurePartCategory.casing => '外壳',
      StructurePartCategory.power => '动力',
      StructurePartCategory.machine => '机器',
      StructurePartCategory.controller => '控制',
      StructurePartCategory.display => '显示',
      StructurePartCategory.transport => '连接',
      StructurePartCategory.decoration => '装饰',
    };
  }
}
