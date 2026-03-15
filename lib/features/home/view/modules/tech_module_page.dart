import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:ctnh_wiki/features/home/data/tech_structure_preview_data.dart';
import 'package:ctnh_wiki/features/structure_preview/view/structure_preview_viewport.dart';
import 'package:flutter/material.dart';

class TechModulePage extends StatelessWidget {
  const TechModulePage({super.key});

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
        _TechPreviewShowcase(isCompact: isCompact),
        const SizedBox(height: 20),
        ...const [
          _HighlightTile(
            title: '产线与倍线',
            description: '围绕矿物处理、多方块机器和自动化倍线，整理科技主线的关键推进顺序。',
          ),
          _HighlightTile(
            title: '能源与发电',
            description: '从早期过渡电力到中后期能源网络，预留完整的发电体系说明入口。',
          ),
          _HighlightTile(
            title: '物流与自动化',
            description: '聚焦仓储、管道和自动合成，让科技内容逐步形成稳定闭环。',
          ),
        ],
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

class _TechPreviewShowcase extends StatelessWidget {
  const _TechPreviewShowcase({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final previewCard = LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final previewHeight = isCompact ? 280.0 : 360.0;

        return Stack(
          children: [
            StructurePreviewViewport(
              structure: techStructurePreviewDefinition,
              size: Size(maxWidth, previewHeight),
            ),
            Positioned(
              top: 14,
              left: 14,
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
                      'three_js API 预览',
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
          ],
        );
      },
    );

    final notesCard = Container(
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
          const Text(
            '先用原生几何体把科技结构预览链路搭起来，确认场景数据、相机、轨道控制和页面嵌入方式都可用。后面再把方块材质、部件说明和步骤动画逐层补上。',
            style: TextStyle(
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
          const _SectionLabel(label: '这轮已经接上'),
          const SizedBox(height: 10),
          ...techPreviewApiBullets.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BulletRow(text: item),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _PreviewTag(label: '拖拽旋转'),
              _PreviewTag(label: '滚轮缩放'),
              _PreviewTag(label: '场景数据驱动'),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionLabel(label: '下一步扩展'),
          const SizedBox(height: 10),
          ...techPreviewRoadmap.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BulletRow(text: item),
            ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 18 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EEE1), Color(0xFFF5EBE0), Color(0xFFEDE4D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE3D7C7)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [previewCard, const SizedBox(height: 16), notesCard],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: previewCard),
                const SizedBox(width: 18),
                Expanded(flex: 9, child: notesCard),
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
