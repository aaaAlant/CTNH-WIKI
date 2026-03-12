import 'package:ctnh_wiki/features/home/models/home_module.dart';
import 'package:flutter/material.dart';

const homeModules = [
  HomeModule(
    label: '科技',
    title: '科技主线',
    subTitle: '机械动力、格雷科技、血肉重铸2、应用能源等',
    description: '描述文本1',
    icon: Icons.precision_manufacturing_rounded,
    tint: Color(0xFFCAD9C4),
  ),
  HomeModule(
    label: '魔法',
    title: '魔法体系',
    subTitle: '植物魔法、血魔法3、新生魔艺等',
    description: '描述文本2',
    icon: Icons.auto_fix_high_rounded,
    tint: Color(0xFFD6CCE9),
  ),
  HomeModule(
    label: '冒险',
    title: '冒险与探索',
    subTitle: '''Alex的洞穴、暮色森林、天境、星际等''',
    description: '描述文本3',
    icon: Icons.explore_rounded,
    tint: Color(0xFFE6D0A8),
  ),
];
