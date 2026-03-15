import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:flutter/material.dart';

class StructurePartDetailCard extends StatelessWidget {
  const StructurePartDetailCard({
    super.key,
    required this.part,
    this.emptyLabel = '点击左侧结构中的部件后，这里会显示详细说明。',
  });

  final StructurePreviewPart? part;
  final String emptyLabel;

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
      child: part == null
          ? Text(
              emptyLabel,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF6B625A),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        part!.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF201A16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _MetaChip(label: _categoryLabel(part!.category)),
                  ],
                ),
                const SizedBox(height: 8),
                _FieldLine(label: 'Block ID', value: part!.blockId),
                const SizedBox(height: 6),
                _FieldLine(label: '朝向', value: _facingLabel(part!.facing)),
                const SizedBox(height: 6),
                _FieldLine(label: '状态', value: _stateLabel(part!.state)),
                const SizedBox(height: 12),
                Text(
                  part!.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Color(0xFF4E443D),
                  ),
                ),
                if (part!.tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: part!.tags
                        .map((tag) => _MetaChip(label: tag))
                        .toList(),
                  ),
                ],
              ],
            ),
    );
  }

  String _categoryLabel(StructurePartCategory category) {
    return switch (category) {
      StructurePartCategory.foundation => '基础底座',
      StructurePartCategory.casing => '框架外壳',
      StructurePartCategory.power => '动力传输',
      StructurePartCategory.machine => '核心机器',
      StructurePartCategory.controller => '控制单元',
      StructurePartCategory.display => '显示部件',
      StructurePartCategory.transport => '支撑连接',
      StructurePartCategory.decoration => '装饰部件',
    };
  }

  String _facingLabel(StructureFacing facing) {
    return switch (facing) {
      StructureFacing.north => '北',
      StructureFacing.south => '南',
      StructureFacing.east => '东',
      StructureFacing.west => '西',
      StructureFacing.up => '上',
      StructureFacing.down => '下',
    };
  }

  String _stateLabel(StructurePartState state) {
    return switch (state) {
      StructurePartState.required => '必需',
      StructurePartState.optional => '可选',
      StructurePartState.previewOnly => '仅预览',
    };
  }
}

class _FieldLine extends StatelessWidget {
  const _FieldLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Color(0xFF5F554D),
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE3D2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B4F2D),
        ),
      ),
    );
  }
}
