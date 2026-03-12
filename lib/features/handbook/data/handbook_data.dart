import 'package:flutter/material.dart';

class HandbookEntry {
  const HandbookEntry({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const handbookTitle = '图鉴';
const handbookDescription = '图鉴页用于沉淀物品、机器、法术和结构说明，适合做标准词条和索引入口。';

const handbookEntries = [
  HandbookEntry(
    title: '材料图鉴',
    description: '按来源和用途整理矿物、魔法材料、流体与中间件。',
    icon: Icons.category_rounded,
  ),
  HandbookEntry(
    title: '机器图鉴',
    description: '为核心机器建立单页，记录作用、配方、输入输出与升级路线。',
    icon: Icons.memory_rounded,
  ),
  HandbookEntry(
    title: '结构图鉴',
    description: '集中维护多方块结构、摆放方向与常见搭建错误。',
    icon: Icons.account_tree_rounded,
  ),
];
