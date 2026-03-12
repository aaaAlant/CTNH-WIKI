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
    required this.relativeTimeLabel,
    required this.summary,
    required this.highlights,
    required this.changes,
    this.isLatest = false,
    this.author = 'CTNH Wiki Team',
  });

  final String version;
  final String publishedAt;
  final String relativeTimeLabel;
  final String summary;
  final List<String> highlights;
  final List<ReleaseChangeEntry> changes;
  final bool isLatest;
  final String author;
}

const versionListTitle = '版本列表';
const versionListDescription =
    '参考 GitHub Releases 的结构整理版本信息。左侧时间轴用于快速跳转，右侧版本块展示发布时间、摘要和详细更新记录。';

const versionReleases = [
  VersionRelease(
    version: 'v1.4.1b',
    publishedAt: '2026-03-12',
    relativeTimeLabel: '4 小时前',
    summary: 'CTNH v1.4.1b 整合包核心模组维护版本，重点修复配方、电路、EMI 显示和跨模组兼容问题。',
    isLatest: true,
    highlights: [
      '修复多条 GregTech 与附属模组配方错误。',
      '回收部分异常副产物与冗余配方，降低误导成本。',
      '补齐 EMI 页面与空间站相关显示缺失。',
    ],
    changes: [
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
  VersionRelease(
    version: 'v1.4.0',
    publishedAt: '2026-02-28',
    relativeTimeLabel: '12 天前',
    summary: '一次偏功能性的大版本，补齐了若干中期推进节点，并引入新的模组联动内容。',
    highlights: [
      '增加任务线与图鉴的基础映射。',
      '整理中期科技推进的几条常见断点。',
    ],
    changes: [
      ReleaseChangeEntry(
        type: ReleaseChangeType.modAdded,
        scope: '探索内容',
        title: '新增一组辅助探索的结构与掉落联动。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.modUpdate,
        scope: 'GregTech',
        title: '同步核心脚本，更新若干机器前置与合成链。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.balance,
        scope: '任务线',
        title: '调整中期章节奖励，降低卡任务时的资源惩罚。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: '多方块',
        title: '修复部分多方块结构在旋转后无法识别的问题。',
      ),
    ],
  ),
  VersionRelease(
    version: 'v1.3.8',
    publishedAt: '2026-02-05',
    relativeTimeLabel: '1 个月前',
    summary: '稳定性维护版本，重点清理旧脚本残留和冲突内容。',
    highlights: [
      '以兼容性和清理为主，不引入新系统。',
    ],
    changes: [
      ReleaseChangeEntry(
        type: ReleaseChangeType.modRemoved,
        scope: '旧脚本',
        title: '移除一批已失效的旧版脚本注入内容。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.modUpdate,
        scope: '兼容层',
        title: '更新兼容层配置，减少配方覆盖冲突。',
      ),
      ReleaseChangeEntry(
        type: ReleaseChangeType.bugFix,
        scope: '客户端',
        title: '修复若干启动阶段的资源加载异常。',
      ),
    ],
  ),
];
