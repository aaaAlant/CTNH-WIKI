import 'package:flutter/material.dart';

class WikiTabItem {
  const WikiTabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const wikiTabs = [
  WikiTabItem(label: '首页', icon: Icons.home_rounded),
  WikiTabItem(label: '攻略教程', icon: Icons.school_rounded),
  WikiTabItem(label: '多方块预览', icon: Icons.view_in_ar_rounded),
];
