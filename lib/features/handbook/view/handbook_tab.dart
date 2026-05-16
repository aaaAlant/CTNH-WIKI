import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/features/handbook/view/widgets/mod_catalog_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
// Hidden for now. Keep the original implementation for later restoration.
// import 'package:ctnh_wiki/features/tasks/view/widgets/tasks_overview_board.dart';
import 'package:flutter/material.dart';

class HandbookTab extends StatelessWidget {
  const HandbookTab({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(eyebrow: 'Entries', title: '图鉴'),
        const SizedBox(height: 12),
        const Text(
          '图鉴页当前先展示 MOD 列表，机器图鉴和任务概览的实现代码已保留，后续需要时可以直接恢复。',
          style: TextStyle(fontSize: 16, color: Color(0xFF5F554D), height: 1.6),
        ),
        SizedBox(height: responsive.pageSectionGap),
        const ContentPanel(child: ModCatalogPanel(framed: false)),
        // Hidden for now. Keep the original section code instead of deleting it.
        // SizedBox(height: 24),
        // ContentPanel(child: _MachineHandbookPanel()),
        // SizedBox(height: 24),
        // ContentPanel(child: TasksOverviewBoard(framed: false)),
      ],
    );
  }
}

// ignore: unused_element
class _MachineHandbookPanel extends StatelessWidget {
  const _MachineHandbookPanel();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 920;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '机器图鉴',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF201A16),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '这一块预留给单机说明、核心用途、升级路线和多方块结构关联。当前先把信息框架立起来，后续可以继续接机器索引、配方摘要和结构预览入口。',
          style: TextStyle(
            fontSize: 14,
            height: 1.65,
            color: Color(0xFF5F554D),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _MachineStatChip(label: '状态 规划中'),
            _MachineStatChip(label: '内容 单机 / 多方块 / 结构说明'),
            _MachineStatChip(label: '联动 任务 / 版本 / 3D 预览'),
          ],
        ),
        const SizedBox(height: 18),
        isCompact
            ? const Column(
                children: [
                  _MachineFeatureCard(
                    icon: Icons.precision_manufacturing_rounded,
                    title: '单机页',
                    description: '记录基础用途、配方方向、输入输出和上下游衔接。',
                  ),
                  SizedBox(height: 12),
                  _MachineFeatureCard(
                    icon: Icons.view_in_ar_rounded,
                    title: '结构预览',
                    description: '把多方块结构、摆放方向和常见错误集中到一处说明。',
                  ),
                  SizedBox(height: 12),
                  _MachineFeatureCard(
                    icon: Icons.alt_route_rounded,
                    title: '页面联动',
                    description: '后续把机器图鉴和任务概览、版本记录以及 3D 结构预览连起来。',
                  ),
                ],
              )
            : const Row(
                children: [
                  Expanded(
                    child: _MachineFeatureCard(
                      icon: Icons.precision_manufacturing_rounded,
                      title: '单机页',
                      description: '记录基础用途、配方方向、输入输出和上下游衔接。',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MachineFeatureCard(
                      icon: Icons.view_in_ar_rounded,
                      title: '结构预览',
                      description: '把多方块结构、摆放方向和常见错误集中到一处说明。',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MachineFeatureCard(
                      icon: Icons.alt_route_rounded,
                      title: '页面联动',
                      description: '后续把机器图鉴和任务概览、版本记录以及 3D 结构预览连起来。',
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class _MachineFeatureCard extends StatelessWidget {
  const _MachineFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF201A16)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF5F554D),
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineStatChip extends StatelessWidget {
  const _MachineStatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8D8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6A5030),
        ),
      ),
    );
  }
}
