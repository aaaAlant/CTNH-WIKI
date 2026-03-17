import 'dart:convert';

import 'package:ctnh_wiki/features/tasks/models/quest_asset_index.dart';
import 'package:ctnh_wiki/features/tasks/models/quest_catalog.dart';
import 'package:flutter/services.dart';

class QuestCatalogRepository {
  const QuestCatalogRepository({
    this.assetPath = 'assets/generated/quests/quest_catalog.json',
    this.assetIndexPath = 'assets/generated/quests/quest_assets_index.json',
  });

  final String assetPath;
  final String assetIndexPath;

  Future<QuestCatalog> loadCatalog() async {
    final rawCatalog = jsonDecode(
      await rootBundle.loadString(assetPath),
    ) as Map<String, dynamic>;

    QuestAssetIndex? assetIndex;
    try {
      final rawAssetIndex = jsonDecode(
        await rootBundle.loadString(assetIndexPath),
      ) as Map<String, dynamic>;
      assetIndex = QuestAssetIndex.fromJson(rawAssetIndex);
    } catch (_) {
      assetIndex = null;
    }

    final enrichedCatalog = assetIndex == null
        ? rawCatalog
        : _enrichCatalog(rawCatalog, assetIndex);
    return QuestCatalog.fromJson(enrichedCatalog);
  }
}

Map<String, dynamic> _enrichCatalog(
  Map<String, dynamic> rawCatalog,
  QuestAssetIndex assetIndex,
) {
  final chapters = rawCatalog['chapters'];
  if (chapters is! List) {
    return rawCatalog;
  }

  for (final chapterEntry in chapters) {
    if (chapterEntry is! Map<String, dynamic>) {
      continue;
    }
    final chapterTitle = chapterEntry['title'] as String? ?? '';
    final quests = chapterEntry['quests'];
    if (quests is! List) {
      continue;
    }
    for (final questEntry in quests) {
      if (questEntry is! Map<String, dynamic>) {
        continue;
      }
      _enrichQuest(questEntry, chapterTitle, assetIndex);
    }
  }

  return rawCatalog;
}

void _enrichQuest(
  Map<String, dynamic> quest,
  String chapterTitle,
  QuestAssetIndex assetIndex,
) {
  final tasks = (quest['tasks'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
  final rewards = (quest['rewards'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);

  for (final task in tasks) {
    _enrichTask(task, assetIndex);
  }
  for (final reward in rewards) {
    _enrichReward(reward, assetIndex);
  }

  final questResource = assetIndex.lookupFirst([
    quest['icon'] as String?,
    for (final task in tasks) task['primaryItemId'] as String?,
    for (final reward in rewards) reward['primaryItemId'] as String?,
  ]);

  if (questResource != null) {
    quest['iconAssetPath'] ??= questResource.iconAssetPath;
    quest['iconLabel'] ??= questResource.displayName;
    if (_shouldReplaceWithResourceName(
      currentText: quest['title'] as String?,
      resource: questResource,
      titleKey: quest['titleKey'] as String?,
    )) {
      quest['title'] = questResource.displayName;
    }
  }

  quest['subtitle'] ??= '所属章节：$chapterTitle';
}

void _enrichTask(Map<String, dynamic> task, QuestAssetIndex assetIndex) {
  final itemIds = (task['itemIds'] as List<dynamic>? ?? const [])
      .map((item) => item.toString())
      .toList(growable: false);
  final primaryItemId = task['primaryItemId'] as String?;
  final primaryResource = assetIndex.lookupFirst([primaryItemId, ...itemIds]);
  if (primaryResource == null) {
    return;
  }

  task['primaryItemLabel'] ??= primaryResource.displayName;
  task['primaryItemIconAssetPath'] ??= primaryResource.iconAssetPath;

  final count = task['count'] as int? ?? 1;
  if (_shouldReplaceWithResourceName(
    currentText: task['title'] as String?,
    resource: primaryResource,
    titleKey: task['titleKey'] as String?,
  )) {
    task['title'] = _formatResourceLabel(primaryResource.displayName, count);
  }

  final currentTarget = task['target'] as String?;
  if (currentTarget == null ||
      _looksLikeFallbackValue(currentTarget, primaryResource.id)) {
    task['target'] = primaryResource.displayName;
  }
}

void _enrichReward(Map<String, dynamic> reward, QuestAssetIndex assetIndex) {
  final itemIds = (reward['itemIds'] as List<dynamic>? ?? const [])
      .map((item) => item.toString())
      .toList(growable: false);
  final primaryItemId = reward['primaryItemId'] as String?;
  final primaryResource = assetIndex.lookupFirst([primaryItemId, ...itemIds]);
  if (primaryResource != null) {
    reward['primaryItemLabel'] ??= primaryResource.displayName;
    reward['primaryItemIconAssetPath'] ??= primaryResource.iconAssetPath;
    if (_shouldReplaceWithResourceName(
      currentText: reward['label'] as String?,
      resource: primaryResource,
      titleKey: reward['labelKey'] as String?,
    )) {
      reward['label'] = _formatResourceLabel(
        primaryResource.displayName,
        reward['count'] as int? ?? 1,
      );
    }
  }

  final entries = (reward['tableEntries'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
  for (final entry in entries) {
    _enrichRewardEntry(entry, assetIndex);
  }
}

void _enrichRewardEntry(
  Map<String, dynamic> entry,
  QuestAssetIndex assetIndex,
) {
  final itemIds = (entry['itemIds'] as List<dynamic>? ?? const [])
      .map((item) => item.toString())
      .toList(growable: false);
  final primaryItemId = entry['primaryItemId'] as String?;
  final primaryResource = assetIndex.lookupFirst([primaryItemId, ...itemIds]);
  if (primaryResource == null) {
    return;
  }

  entry['primaryItemLabel'] ??= primaryResource.displayName;
  entry['primaryItemIconAssetPath'] ??= primaryResource.iconAssetPath;
  if (_looksLikeFallbackValue(entry['label'] as String?, primaryResource.id)) {
    entry['label'] = _formatResourceLabel(
      primaryResource.displayName,
      entry['count'] as int? ?? 1,
    );
  }
}

bool _shouldReplaceWithResourceName({
  required String? currentText,
  required QuestAssetResource resource,
  required String? titleKey,
}) {
  if (!resource.hasDisplayName) {
    return false;
  }
  if (currentText == null || currentText.isEmpty) {
    return true;
  }
  if (titleKey != null && titleKey.isNotEmpty) {
    return true;
  }
  return _looksLikeFallbackValue(currentText, resource.id);
}

bool _looksLikeFallbackValue(String? currentText, String resourceId) {
  if (currentText == null || currentText.isEmpty) {
    return true;
  }
  final normalized = currentText.trim();
  final rawName = resourceId.contains(':')
      ? resourceId.split(':').last
      : resourceId;
  final prettyName = _prettifyResourceName(rawName);
  return normalized == rawName ||
      normalized == prettyName ||
      normalized.startsWith('$rawName x') ||
      normalized.startsWith('$prettyName x') ||
      normalized.toLowerCase() == rawName.toLowerCase() ||
      normalized.replaceAll(' ', '_').toLowerCase() == rawName.toLowerCase();
}

String _formatResourceLabel(String label, int count) {
  return count > 1 ? '$label x$count' : label;
}

String _prettifyResourceName(String rawName) {
  return rawName
      .split('_')
      .where((segment) => segment.isNotEmpty)
      .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
      .join(' ');
}
