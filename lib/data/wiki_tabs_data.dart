import 'package:flutter/material.dart';

class WikiTabItem {
  const WikiTabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const wikiTabs = [
  WikiTabItem(label: '首页', icon: Icons.home_rounded),
  WikiTabItem(label: '图鉴', icon: Icons.collections_bookmark_rounded),
  WikiTabItem(label: '任务概览', icon: Icons.checklist_rounded),
  WikiTabItem(label: '攻略教程', icon: Icons.school_rounded),
  WikiTabItem(label: '版本列表', icon: Icons.history_rounded),
];
