import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:flutter/material.dart';

class AdventureModulePage extends StatelessWidget {
  const AdventureModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModulePageFrame(
      icon: adventureHomeModule.icon,
      tint: adventureHomeModule.tint,
      title: adventureHomeModule.title,
      description: adventureHomeModule.description,
      children: const [
        _HighlightTile(
          title: '维度探索',
          description: '预留给维度、结构、地下城和阶段性探索目标的独立区块。',
        ),
        _HighlightTile(
          title: '战斗与生存',
          description: '后续可以拓展为装备、怪物、挑战路线和重要战斗节点说明。',
        ),
        _HighlightTile(
          title: '地图推进',
          description: '把冒险路线、关键地标和跨阶段任务串成更完整的推进页面。',
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
