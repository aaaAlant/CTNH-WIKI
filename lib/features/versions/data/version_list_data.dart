import 'package:flutter/material.dart';

enum ReleaseChangeType {
  modUpdate,
  modAdded,
  modRemoved,
  bugFix,
  balance,
  content,
}

extension ReleaseChangeTypePresentation on ReleaseChangeType {
  String get label {
    switch (this) {
      case ReleaseChangeType.modUpdate:
        return 'MOD更新';
      case ReleaseChangeType.modAdded:
        return '新增MOD';
      case ReleaseChangeType.modRemoved:
        return '删除MOD';
      case ReleaseChangeType.bugFix:
        return 'BUG修复';
      case ReleaseChangeType.balance:
        return '数值调整';
      case ReleaseChangeType.content:
        return '内容更新';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ReleaseChangeType.modUpdate:
        return const Color(0xFFD7E8FF);
      case ReleaseChangeType.modAdded:
        return const Color(0xFFD7F0DE);
      case ReleaseChangeType.modRemoved:
        return const Color(0xFFF7DDD6);
      case ReleaseChangeType.bugFix:
        return const Color(0xFFF6E7BE);
      case ReleaseChangeType.balance:
        return const Color(0xFFE8DCF8);
      case ReleaseChangeType.content:
        return const Color(0xFFE6E1D7);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case ReleaseChangeType.modUpdate:
        return const Color(0xFF194A8D);
      case ReleaseChangeType.modAdded:
        return const Color(0xFF1E6A3B);
      case ReleaseChangeType.modRemoved:
        return const Color(0xFF8A2C1F);
      case ReleaseChangeType.bugFix:
        return const Color(0xFF8A5A00);
      case ReleaseChangeType.balance:
        return const Color(0xFF5D2F86);
      case ReleaseChangeType.content:
        return const Color(0xFF5F554D);
    }
  }
}

class ReleaseChangeEntry {
  const ReleaseChangeEntry({
    required this.type,
    required this.title,
    this.details,
    this.scope,
  });

  final ReleaseChangeType type;
  final String title;
  final String? details;
  final String? scope;
}

class VersionRelease {
  const VersionRelease({
    required this.version,
    required this.publishedAt,
    required this.summary,
    required this.highlights,
    required this.changes,
    this.isLatest = false,
  });

  final String version;
  final DateTime publishedAt;
  final String summary;
  final List<String> highlights;
  final List<ReleaseChangeEntry> changes;
  final bool isLatest;
}

const versionListTitle = '版本列表';

final versionReleases = [
  VersionRelease(
    version: 'v1.4.1b',
    publishedAt: DateTime(2026, 3, 12),
    summary: 'CTNH v1.4.1b 整合包核心模组维护版本，重点修复配方、电路、EMI 显示和跨模组兼容问题。',
    isLatest: true,
    highlights: const [
      '修复多条 GregTech 与附属模组配方错误。',
      '回收部分异常副产物与冗余配方，降低误导成本。',
      '补齐 EMI 页面与空间站相关显示缺失。',
    ],
    changes: const [
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: 'GregTech',
        title: '修复氧化铝相关电解配方电路问题。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.balance,
        scope: '矿物处理',
        title: '完全清除矿产副产物中的金粉为贵金属粉。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.balance,
        scope: '矿物处理',
        title: '完全清除红宝石矿处理副产物中的铬粉为铬铁矿粉。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: 'Ad Astra',
        title: '修复发射台、工作台、空间站配方缺失问题。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: 'EMI',
        title: '修复 EMI 配方页面可能重复显示的问题。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: '渲染',
        title: '修复中子素光晕不渲染的问题。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: 'FTB Chunks',
        title: '修复一个 FTB Chunks 的兼容性问题。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.content,
        scope: '贴图',
        title: '添加共振、高纯共振、回响、高纯回响四种水晶的贴图。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.modRemoved,
        scope: '配方',
        title: '移除原版四氟化钛配方并修复相关替代配方。',
      ),
    ],
  ),
];
