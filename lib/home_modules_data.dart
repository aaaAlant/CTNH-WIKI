import 'package:flutter/material.dart';

class HomeModuleSection {
  const HomeModuleSection({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class HomeModule {
  const HomeModule({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
    required this.sections,
  });

  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color tint;
  final List<HomeModuleSection> sections;
}

const homeModules = [
  HomeModule(
    label: '科技',
    title: '科技主线',
    description: '围绕发电、机器、物流和自动化展开，适合做长期基地建设与产线推进。',
    icon: Icons.precision_manufacturing_rounded,
    tint: Color(0xFFCAD9C4),
    sections: [
      HomeModuleSection(
        title: '发电与储能',
        description: '整理早中期发电方案、燃料替代路径和储能升级顺序。',
      ),
      HomeModuleSection(
        title: '机器与处理链',
        description: '覆盖矿物处理、倍线、自动合成和核心机器的前置条件。',
      ),
      HomeModuleSection(
        title: '物流与自动化',
        description: '归档仓储、管道、物流网络和跨模组自动化骨架。',
      ),
    ],
  ),
  HomeModule(
    label: '魔法',
    title: '魔法体系',
    description: '梳理祭坛、法术、材料与跨模组联动，方便从入门到中后期推进。',
    icon: Icons.auto_fix_high_rounded,
    tint: Color(0xFFD6CCE9),
    sections: [
      HomeModuleSection(
        title: '仪式与结构',
        description: '集中说明多方块祭坛、仪式摆放规则和常见结构错误。',
      ),
      HomeModuleSection(
        title: '材料与资源',
        description: '整理魔法材料来源、刷取方式和关键资源闭环。',
      ),
      HomeModuleSection(
        title: '跨模组联动',
        description: '记录魔法与科技、任务线之间的依赖关系和捷径。',
      ),
    ],
  ),
  HomeModule(
    label: '冒险',
    title: '冒险与探索',
    description: '把开荒、生存、任务和战斗内容收束到一条清晰的探索路线里。',
    icon: Icons.explore_rounded,
    tint: Color(0xFFE6D0A8),
    sections: [
      HomeModuleSection(
        title: '开荒与生存',
        description: '说明前几小时的目标、基础工具过渡和生存资源优先级。',
      ),
      HomeModuleSection(
        title: '任务与章节',
        description: '按任务书的章节结构拆解阶段目标和推荐阅读顺序。',
      ),
      HomeModuleSection(
        title: '探索与排错',
        description: '汇总地牢、维度、常见卡点与推进过程中的排错说明。',
      ),
    ],
  ),
];
