import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:flutter/material.dart';

class TechModulePage extends StatelessWidget {
  const TechModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModulePageFrame(
      icon: techHomeModule.icon,
      tint: techHomeModule.tint,
      title: techHomeModule.title,
      description: techHomeModule.description,
      children: const [
        _HighlightTile(
          title: '产线与倍线',
          description: '围绕矿物处理、多方块机器和自动化倍线整理核心推进顺序。',
        ),
        _HighlightTile(
          title: '能源与发电',
          description: '从早期过渡电力到中后期能源网络，预留完整的发电体系入口。',
        ),
        _HighlightTile(
          title: '物流与自动化',
          description: '聚焦仓储、管道和自动合成，让科技内容逐步形成稳定闭环。',
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
