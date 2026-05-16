import 'package:ctnh_wiki/features/home/models/home_module.dart';
import 'package:flutter/material.dart';

const techHomeModule = HomeModule(
  label: '科技',
  title: '科技主线',
  subTitle: '机械动力、格雷科技、血肉重铸、应用能源等',
  description: '围绕产线、发电、自动化与中后期机器链推进，适合作为长期发展的主干路线。',
  cursorTheme: HomeCursorTheme.tech,
  icon: Icons.precision_manufacturing_rounded,
  tint: Color(0xFFCAD9C4),
);

const magicHomeModule = HomeModule(
  label: '魔法',
  title: '魔法体系',
  subTitle: '植物魔法、血魔法、血肉重铸等',
  description: '聚焦魔法资源、仪式结构与跨模组联动，作为独立于科技主线的特色推进分支。',
  cursorTheme: HomeCursorTheme.magic,
  icon: Icons.auto_fix_high_rounded,
  tint: Color(0xFFD6CCE9),
);

const logisticsHomeModule = HomeModule(
  label: '物流',
  title: '物流与存储',
  subTitle: '应用能源2、无线传电、样板工作站与多方块结构',
  description: '集中整理 AE2 及附属扩展的物流、存储、电力传输与多方块体系。',
  cursorTheme: HomeCursorTheme.adventure,
  icon: Icons.hub_rounded,
  tint: Color(0xFFE6D0A8),
);

const homeModules = [techHomeModule, magicHomeModule, logisticsHomeModule];
