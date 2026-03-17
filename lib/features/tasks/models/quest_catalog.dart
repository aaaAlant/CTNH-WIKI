class QuestCatalog {
  const QuestCatalog({
    required this.sourceTitle,
    required this.version,
    required this.progressionMode,
    required this.chapterGroups,
    required this.chapters,
  });

  factory QuestCatalog.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>? ?? const {};
    return QuestCatalog(
      sourceTitle: source['title'] as String? ?? 'FTB Quests',
      version: source['version'] as int? ?? 0,
      progressionMode: source['progressionMode'] as String? ?? '',
      chapterGroups: (json['chapterGroups'] as List<dynamic>? ?? const [])
          .map(
            (group) =>
                QuestChapterGroup.fromJson(group as Map<String, dynamic>),
          )
          .toList(growable: false),
      chapters: (json['chapters'] as List<dynamic>? ?? const [])
          .map(
            (chapter) => QuestChapter.fromJson(chapter as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String sourceTitle;
  final int version;
  final String progressionMode;
  final List<QuestChapterGroup> chapterGroups;
  final List<QuestChapter> chapters;

  QuestChapter? chapterById(String? id) {
    if (id == null) {
      return null;
    }
    for (final chapter in chapters) {
      if (chapter.id == id) {
        return chapter;
      }
    }
    return null;
  }
}

class QuestChapterGroup {
  const QuestChapterGroup({
    required this.id,
    required this.title,
    required this.chapterIds,
    this.titleKey,
  });

  factory QuestChapterGroup.fromJson(Map<String, dynamic> json) {
    return QuestChapterGroup(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Chapter Group',
      titleKey: json['titleKey'] as String?,
      chapterIds: (json['chapterIds'] as List<dynamic>? ?? const [])
          .map((id) => id.toString())
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String? titleKey;
  final List<String> chapterIds;
}

class QuestChapter {
  const QuestChapter({
    required this.id,
    required this.filename,
    required this.title,
    required this.subtitle,
    required this.orderIndex,
    required this.questCount,
    required this.questLinkCount,
    required this.bounds,
    required this.quests,
    required this.questLinks,
    this.groupId,
    this.icon,
    this.titleKey,
  });

  factory QuestChapter.fromJson(Map<String, dynamic> json) {
    return QuestChapter(
      id: json['id'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      groupId: json['groupId'] as String?,
      title: json['title'] as String? ?? '',
      titleKey: json['titleKey'] as String?,
      subtitle: (json['subtitle'] as List<dynamic>? ?? const [])
          .map((line) => line.toString())
          .toList(growable: false),
      icon: json['icon'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      questCount: json['questCount'] as int? ?? 0,
      questLinkCount: json['questLinkCount'] as int? ?? 0,
      bounds: QuestGraphBounds.fromJson(
        json['bounds'] as Map<String, dynamic>? ?? const {},
      ),
      quests: (json['quests'] as List<dynamic>? ?? const [])
          .map(
            (quest) => QuestDefinition.fromJson(quest as Map<String, dynamic>),
          )
          .toList(growable: false),
      questLinks: (json['questLinks'] as List<dynamic>? ?? const [])
          .map((link) => QuestLink.fromJson(link as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String id;
  final String filename;
  final String? groupId;
  final String title;
  final String? titleKey;
  final List<String> subtitle;
  final String? icon;
  final int orderIndex;
  final int questCount;
  final int questLinkCount;
  final QuestGraphBounds bounds;
  final List<QuestDefinition> quests;
  final List<QuestLink> questLinks;

  QuestDefinition? questById(String? id) {
    if (id == null) {
      return null;
    }
    for (final quest in quests) {
      if (quest.id == id) {
        return quest;
      }
    }
    return null;
  }
}

class QuestGraphBounds {
  const QuestGraphBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  factory QuestGraphBounds.fromJson(Map<String, dynamic> json) {
    return QuestGraphBounds(
      minX: (json['minX'] as num?)?.toDouble() ?? 0,
      maxX: (json['maxX'] as num?)?.toDouble() ?? 0,
      minY: (json['minY'] as num?)?.toDouble() ?? 0,
      maxY: (json['maxY'] as num?)?.toDouble() ?? 0,
    );
  }

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
}

class QuestDefinition {
  const QuestDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.shape,
    required this.size,
    required this.x,
    required this.y,
    required this.dependencies,
    required this.tasks,
    required this.rewards,
    this.subtitle,
    this.subtitleKey,
    this.titleKey,
    this.icon,
    this.iconAssetPath,
    this.iconLabel,
    this.descriptionKeys = const [],
  });

  factory QuestDefinition.fromJson(Map<String, dynamic> json) {
    return QuestDefinition(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Quest',
      titleKey: json['titleKey'] as String?,
      subtitle: json['subtitle'] as String?,
      subtitleKey: json['subtitleKey'] as String?,
      description: (json['description'] as List<dynamic>? ?? const [])
          .map((line) => line.toString())
          .toList(growable: false),
      descriptionKeys: (json['descriptionKeys'] as List<dynamic>? ?? const [])
          .map((line) => line.toString())
          .toList(growable: false),
      icon: json['icon'] as String?,
      iconAssetPath: json['iconAssetPath'] as String?,
      iconLabel: json['iconLabel'] as String?,
      shape: json['shape'] as String? ?? 'circle',
      size: (json['size'] as num?)?.toDouble() ?? 1,
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      dependencies: (json['dependencies'] as List<dynamic>? ?? const [])
          .map((dependency) => dependency.toString())
          .toList(growable: false),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .map((task) => QuestTask.fromJson(task as Map<String, dynamic>))
          .toList(growable: false),
      rewards: (json['rewards'] as List<dynamic>? ?? const [])
          .map((reward) => QuestReward.fromJson(reward as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String? titleKey;
  final String? subtitle;
  final String? subtitleKey;
  final List<String> description;
  final List<String> descriptionKeys;
  final String? icon;
  final String? iconAssetPath;
  final String? iconLabel;
  final String shape;
  final double size;
  final double x;
  final double y;
  final List<String> dependencies;
  final List<QuestTask> tasks;
  final List<QuestReward> rewards;

  bool get hasUnresolvedText {
    return titleKey != null ||
        subtitleKey != null ||
        descriptionKeys.isNotEmpty;
  }
}

class QuestTask {
  const QuestTask({
    required this.id,
    required this.type,
    required this.title,
    required this.itemIds,
    required this.count,
    this.primaryItemId,
    this.primaryItemLabel,
    this.primaryItemIconAssetPath,
    this.titleKey,
    this.target,
  });

  factory QuestTask.fromJson(Map<String, dynamic> json) {
    return QuestTask(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Objective',
      titleKey: json['titleKey'] as String?,
      itemIds: (json['itemIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      primaryItemId: json['primaryItemId'] as String?,
      primaryItemLabel: json['primaryItemLabel'] as String?,
      primaryItemIconAssetPath: json['primaryItemIconAssetPath'] as String?,
      count: json['count'] as int? ?? 1,
      target: json['target'] as String?,
    );
  }

  final String id;
  final String type;
  final String title;
  final String? titleKey;
  final List<String> itemIds;
  final String? primaryItemId;
  final String? primaryItemLabel;
  final String? primaryItemIconAssetPath;
  final int count;
  final String? target;
}

class QuestReward {
  const QuestReward({
    required this.id,
    required this.type,
    required this.label,
    required this.count,
    required this.itemIds,
    required this.tableEntries,
    this.primaryItemId,
    this.primaryItemLabel,
    this.primaryItemIconAssetPath,
    this.tableId,
    this.tableTitle,
    this.tableTitleKey,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) {
    return QuestReward(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'item',
      label: json['label'] as String? ?? 'Reward',
      count: json['count'] as int? ?? 1,
      itemIds: (json['itemIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      primaryItemId: json['primaryItemId'] as String?,
      primaryItemLabel: json['primaryItemLabel'] as String?,
      primaryItemIconAssetPath: json['primaryItemIconAssetPath'] as String?,
      tableId: json['tableId'] as String?,
      tableTitle: json['tableTitle'] as String?,
      tableTitleKey: json['tableTitleKey'] as String?,
      tableEntries: (json['tableEntries'] as List<dynamic>? ?? const [])
          .map(
            (entry) => QuestRewardEntry.fromJson(entry as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String type;
  final String label;
  final int count;
  final List<String> itemIds;
  final String? primaryItemId;
  final String? primaryItemLabel;
  final String? primaryItemIconAssetPath;
  final String? tableId;
  final String? tableTitle;
  final String? tableTitleKey;
  final List<QuestRewardEntry> tableEntries;
}

class QuestRewardEntry {
  const QuestRewardEntry({
    required this.itemIds,
    required this.label,
    required this.count,
    this.primaryItemId,
    this.primaryItemLabel,
    this.primaryItemIconAssetPath,
    this.weight,
  });

  factory QuestRewardEntry.fromJson(Map<String, dynamic> json) {
    return QuestRewardEntry(
      itemIds: (json['itemIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      primaryItemId: json['primaryItemId'] as String?,
      primaryItemLabel: json['primaryItemLabel'] as String?,
      primaryItemIconAssetPath: json['primaryItemIconAssetPath'] as String?,
      label: json['label'] as String? ?? 'Reward Entry',
      count: json['count'] as int? ?? 1,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  final List<String> itemIds;
  final String? primaryItemId;
  final String? primaryItemLabel;
  final String? primaryItemIconAssetPath;
  final String label;
  final int count;
  final double? weight;
}

class QuestLink {
  const QuestLink({
    required this.id,
    required this.linkedQuestId,
    required this.title,
    required this.x,
    required this.y,
  });

  factory QuestLink.fromJson(Map<String, dynamic> json) {
    return QuestLink(
      id: json['id'] as String? ?? '',
      linkedQuestId: json['linkedQuestId'] as String? ?? '',
      title: json['title'] as String? ?? 'Jump',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
    );
  }

  final String id;
  final String linkedQuestId;
  final String title;
  final double x;
  final double y;
}
