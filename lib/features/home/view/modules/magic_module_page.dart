import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:flutter/material.dart';

class MagicModulePage extends StatelessWidget {
  const MagicModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModulePageFrame(
      icon: magicHomeModule.icon,
      tint: magicHomeModule.tint,
      title: magicHomeModule.title,
      description: magicHomeModule.description,
      children: const [
        _HighlightTile(
          title: '仪式与结构',
          description: '为祭坛、法阵和结构类玩法预留独立说明区，方便后续拆成专题内容。',
        ),
        _HighlightTile(
          title: '资源与材料',
          description: '集中梳理魔法资源获取、产出闭环和与科技线共享的关键材料。',
        ),
        _HighlightTile(
          title: '法术与联动',
          description: '后续可以扩展成完整法术页面、跨模组联动说明和阶段性任务入口。',
        ),
      ],
    );
  }
}

class _ModulePageFrame extends StatelessWidget {
  const _ModulePageFrame({
    required this.icon,
    required this.tint,
    required this.title,
    required this.description,
    required this.children,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String description;
  final List<Widget> children;

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
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.title,
    required this.description,
  });

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
