import 'package:flutter/material.dart';

class WikiModuleSectionData {
  const WikiModuleSectionData({
    required this.title,
    required this.summary,
    required this.accent,
    required this.topics,
  });

  final String title;
  final String summary;
  final Color accent;
  final List<WikiTopicSectionData> topics;
}

class WikiTopicSectionData {
  const WikiTopicSectionData({
    required this.title,
    required this.paragraphs,
    required this.groups,
  });

  final String title;
  final List<String> paragraphs;
  final List<WikiFigureGroupData> groups;
}

class WikiFigureGroupData {
  const WikiFigureGroupData({
    required this.title,
    this.description,
    required this.figures,
  });

  final String title;
  final String? description;
  final List<WikiFigureData> figures;
}

class WikiFigureData {
  const WikiFigureData({required this.caption, required this.assetPath});

  final String caption;
  final String assetPath;
}

const wikiGuidesTitle = '正式 Wiki 内容';
const wikiGuidesDescription =
    '以下内容已经从正式整理文档录入本地项目，按科技、魔法与物流存储三条主线组织。配图会根据屏幕宽度自动换列，尽量减少空白并保持阅读节奏。';

const wikiModuleSections = [
  WikiModuleSectionData(
    title: '科技模块',
    summary: '围绕机械动力与格雷科技主线整理配方、产线和多方块结构内容。',
    accent: Color(0xFF566A83),
    topics: [
      WikiTopicSectionData(
        title: '机械动力（Create）',
        paragraphs: [
          '整合包基于 6.0+ 版本的机械动力及诸多附属模组（经典改进、冶金学、电气时代、矿石开掘等），设计了独具特色的齿轮风格科技玩法与序列配方合成。',
        ],
        groups: [
          WikiFigureGroupData(
            title: '部分配方展示',
            figures: [
              WikiFigureData(
                caption: '精密构件',
                assetPath: 'assets/images/wiki/formal/image1.png',
              ),
              WikiFigureData(
                caption: '水泥砖块',
                assetPath: 'assets/images/wiki/formal/image2.png',
              ),
              WikiFigureData(
                caption: '基础电子电路',
                assetPath: 'assets/images/wiki/formal/image3.png',
              ),
            ],
          ),
          WikiFigureGroupData(
            title: '特色结构',
            description: '同时基于自研模组 CT++ 让机械动力和格雷科技深度融合，锻造出了应力多方块结构。',
            figures: [
              WikiFigureData(
                caption: '应力多方块结构展示 01',
                assetPath: 'assets/images/wiki/formal/image4.png',
              ),
              WikiFigureData(
                caption: '应力多方块结构展示 02',
                assetPath: 'assets/images/wiki/formal/image5.png',
              ),
              WikiFigureData(
                caption: '应力多方块结构展示 03',
                assetPath: 'assets/images/wiki/formal/image6.png',
              ),
            ],
          ),
        ],
      ),
      WikiTopicSectionData(
        title: '格雷科技（GregTech）',
        paragraphs: [
          '我们以格雷原本的十五级电压（LV ~ MAX）为基础，重制、修改并扩容了原版 GTM 的核心内容。',
          '整合包使用机械动力的特色内容替换了原本蒸汽时代的推进方式，让玩家前期进程更有趣也更轻松，但依然保留挑战性。',
          '同时我们也融合了其他模组的风格，为血肉重铸、植物魔法等内容制作了可自动化版本的特色机器与结构，并对原版格雷流程进行了深度魔改。',
        ],
        groups: [
          WikiFigureGroupData(
            title: '部分特色产线展示',
            figures: [
              WikiFigureData(
                caption: '超级矿物处理',
                assetPath: 'assets/images/wiki/formal/image7.png',
              ),
              WikiFigureData(
                caption: '幽匿电路产线',
                assetPath: 'assets/images/wiki/formal/image8.png',
              ),
            ],
          ),
          WikiFigureGroupData(
            title: '特色结构',
            figures: [
              WikiFigureData(
                caption: '格雷科技结构展示 01',
                assetPath: 'assets/images/wiki/formal/image9.png',
              ),
              WikiFigureData(
                caption: '格雷科技结构展示 02',
                assetPath: 'assets/images/wiki/formal/image10.png',
              ),
              WikiFigureData(
                caption: '格雷科技结构展示 03',
                assetPath: 'assets/images/wiki/formal/image11.png',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  WikiModuleSectionData(
    title: '魔法模块',
    summary: '聚焦植物魔法、血肉重铸与血魔法的配方改造、结构联动和自动化体系。',
    accent: Color(0xFF8158A8),
    topics: [
      WikiTopicSectionData(
        title: '植物魔法（Botania）',
        paragraphs: [
          '我们对植物魔法的产能花做了一些修改与机制重构，还额外加入神话植物学和自制的 CTNH ManaMachines 模组，为其补充更多风味。',
          '整合包以此为基础制作了融合格雷科技风格的自动化魔力机器，并添加了天顶机器研究与究极魔力产线，旨在保留原有植物魔法风味的前提下进一步完善整条链路。',
        ],
        groups: [
          WikiFigureGroupData(
            title: '部分配方展示',
            figures: [
              WikiFigureData(
                caption: '泰拉钢锭在盖亚反应器中的反应',
                assetPath: 'assets/images/wiki/formal/image12.png',
              ),
              WikiFigureData(
                caption: '特色的饰品配方',
                assetPath: 'assets/images/wiki/formal/image13.png',
              ),
              WikiFigureData(
                caption: '特殊的电子元件',
                assetPath: 'assets/images/wiki/formal/image14.png',
              ),
              WikiFigureData(
                caption: '工业配方',
                assetPath: 'assets/images/wiki/formal/image15.png',
              ),
              WikiFigureData(
                caption: '特别的魔力电路板',
                assetPath: 'assets/images/wiki/formal/image16.png',
              ),
            ],
          ),
          WikiFigureGroupData(
            title: '特色结构',
            figures: [
              WikiFigureData(
                caption: '植物魔法结构展示 01',
                assetPath: 'assets/images/wiki/formal/image17.png',
              ),
              WikiFigureData(
                caption: '植物魔法结构展示 02',
                assetPath: 'assets/images/wiki/formal/image18.png',
              ),
              WikiFigureData(
                caption: '植物魔法结构展示 03',
                assetPath: 'assets/images/wiki/formal/image19.png',
              ),
            ],
          ),
        ],
      ),
      WikiTopicSectionData(
        title: '血肉重铸（Biomancy）',
        paragraphs: [
          '我们对血肉重铸的原本内容进行了几乎彻底性的重制，制作了许多具有血肉机械融合感的机器与多方块结构，也设计了许多有趣且独特的配方。',
          '同时这些内容被融入了主进程中，给重复冗杂的机械推进增添了不同的节奏与体验。',
        ],
        groups: [
          WikiFigureGroupData(
            title: '部分配方展示',
            figures: [
              WikiFigureData(
                caption: '在反应腔内进行核心复制操作',
                assetPath: 'assets/images/wiki/formal/image20.png',
              ),
              WikiFigureData(
                caption: '在生物电炉内制作电路板',
                assetPath: 'assets/images/wiki/formal/image21.png',
              ),
              WikiFigureData(
                caption: '在意识装配机内进行电路板的有序装配流程',
                assetPath: 'assets/images/wiki/formal/image22.png',
              ),
            ],
          ),
          WikiFigureGroupData(
            title: '特色结构',
            description: '由于生物大机器的制作流程类似于生物分化，这里展示分化前与分化后的一种情况。',
            figures: [
              WikiFigureData(
                caption: '小机器展示',
                assetPath: 'assets/images/wiki/formal/image23.png',
              ),
              WikiFigureData(
                caption: '分化前',
                assetPath: 'assets/images/wiki/formal/image24.png',
              ),
              WikiFigureData(
                caption: '分化后',
                assetPath: 'assets/images/wiki/formal/image25.png',
              ),
            ],
          ),
        ],
      ),
      WikiTopicSectionData(
        title: '血魔法（Blood Magic）',
        paragraphs: [
          '我们以血魔法本身的内容为主题，制作了具有格雷风格的产线、电路板，以及对原格雷科技铂金产线的省略步骤。',
          '同时内容还与植物魔法联动，加入了部分产能花与许多格雷风格的结构和自动化机器，使得血液产出更便捷也更有趣。',
        ],
        groups: [
          WikiFigureGroupData(
            title: '部分配方展示',
            figures: [
              WikiFigureData(
                caption: '在工业狱火锻炉中制作恶魔坩埚',
                assetPath: 'assets/images/wiki/formal/image26.png',
              ),
              WikiFigureData(
                caption: '在工业血之祭坛中制作终焉石板',
                assetPath: 'assets/images/wiki/formal/image27.png',
              ),
              WikiFigureData(
                caption: '在工业狱火锻炉中制作困惑增生电容',
                assetPath: 'assets/images/wiki/formal/image28.png',
              ),
            ],
          ),
          WikiFigureGroupData(
            title: '特色结构',
            figures: [
              WikiFigureData(
                caption: '血魔法结构展示 01',
                assetPath: 'assets/images/wiki/formal/image29.png',
              ),
              WikiFigureData(
                caption: '血魔法结构展示 02',
                assetPath: 'assets/images/wiki/formal/image30.png',
              ),
              WikiFigureData(
                caption: '血魔法结构展示 03',
                assetPath: 'assets/images/wiki/formal/image31.png',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  WikiModuleSectionData(
    title: '物流 / 存储模块',
    summary: '围绕 AE2 及附属扩展整理物流、存储、电力传输与多方块结构内容。',
    accent: Color(0xFF5D7F74),
    topics: [
      WikiTopicSectionData(
        title: '应用能源 2（AE2）',
        paragraphs: [
          '我们加入了许多高性能且体验良好的 AE 附属，比如 Omni Cells（全能存储器）、ExtendedAE（装配矩阵）等。',
          '同时自制了 AE2 Pattern Workstation、CTNH-Energy 与 AE2-FTB 任务检测器三个模组，用于提升整合包中的物流与存储体验。',
          '在电力传输方面，我们使用 AE 网络存储和传递 EU，实现了更贴合整合包环境的无线传电方案。',
        ],
        groups: [
          WikiFigureGroupData(
            title: '核心内容展示',
            figures: [
              WikiFigureData(
                caption: 'ME 库存三件套',
                assetPath: 'assets/images/wiki/formal/image32.png',
              ),
              WikiFigureData(
                caption: 'ME 样板总成',
                assetPath: 'assets/images/wiki/formal/image33.png',
              ),
              WikiFigureData(
                caption: 'AE 引导章节',
                assetPath: 'assets/images/wiki/formal/image34.png',
              ),
              WikiFigureData(
                caption: 'AE 多方块结构展示 01',
                assetPath: 'assets/images/wiki/formal/image35.png',
              ),
              WikiFigureData(
                caption: 'AE 多方块结构展示 02',
                assetPath: 'assets/images/wiki/formal/image36.png',
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
