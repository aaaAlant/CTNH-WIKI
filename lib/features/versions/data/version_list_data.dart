class VersionTimelineEntry {
  const VersionTimelineEntry({required this.version, required this.summary});

  final String version;
  final String summary;
}

const versionListTitle = '版本列表';
const versionListDescription =
    '版本列表页用于记录站点内容建设节奏，而不是模组包更新日志本身，便于追踪 Wiki 信息覆盖率。';

const versionTimeline = [
  VersionTimelineEntry(version: 'v0.1', summary: '完成首页结构重组，拆分模块数据和四个主标签页骨架。'),
  VersionTimelineEntry(version: 'v0.2', summary: '计划补充任务概览的章节树与关键前置说明。'),
  VersionTimelineEntry(version: 'v0.3', summary: '计划建设图鉴词条模板与版本差异标注。'),
];
