import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final options = _GeneratorOptions.fromArgs(args);
  final root = Directory.current;
  final questsDir = Directory(_join(root.path, ['data', 'quests']));
  if (!questsDir.existsSync()) {
    stderr.writeln('quests directory not found: ${questsDir.path}');
    exitCode = 1;
    return;
  }

  final langDir = Directory(_join(root.path, ['data', 'lang']));
  final localizations = _LocalizationStore.load(
    langDir,
    primaryLocale: options.primaryLocale,
    fallbackLocale: options.fallbackLocale,
  );

  final parser = _SnbtParser();
  final dataFile = File(_join(questsDir.path, ['data.snbt']));
  final chapterGroupsFile = File(
    _join(questsDir.path, ['chapter_groups.snbt']),
  );
  final chaptersDir = Directory(_join(questsDir.path, ['chapters']));
  final rewardTablesDir = Directory(_join(questsDir.path, ['reward_tables']));

  final globalData = _asMap(parser.parse(_readTextFile(dataFile)));
  final rawChapterGroups = _asMap(
    parser.parse(_readTextFile(chapterGroupsFile)),
  );

  final rewardTables = <String, Map<String, dynamic>>{};
  final rewardTableFiles =
      rewardTablesDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.snbt'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  for (final file in rewardTableFiles) {
    final raw = _asMap(parser.parse(_readTextFile(file)));
    final normalized = _normalizeRewardTable(raw, file, localizations);
    rewardTables[normalized['tableId'] as String] = normalized;
  }

  final chapters = <Map<String, dynamic>>[];
  final chapterFiles =
      chaptersDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.snbt'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  for (final file in chapterFiles) {
    final raw = _asMap(parser.parse(_readTextFile(file)));
    chapters.add(_normalizeChapter(raw, file, rewardTables, localizations));
  }

  chapters.sort((left, right) {
    final orderCompare = (left['orderIndex'] as int).compareTo(
      right['orderIndex'] as int,
    );
    if (orderCompare != 0) {
      return orderCompare;
    }
    return (left['filename'] as String).compareTo(right['filename'] as String);
  });

  final chaptersByGroup = <String, List<Map<String, dynamic>>>{};
  for (final chapter in chapters) {
    final groupId = chapter['groupId'] as String?;
    if (groupId == null || groupId.isEmpty) {
      continue;
    }
    chaptersByGroup.putIfAbsent(groupId, () => []).add(chapter);
  }

  final chapterGroups = <Map<String, dynamic>>[];
  final rawGroups = _asList(rawChapterGroups['chapter_groups']);
  for (var index = 0; index < rawGroups.length; index++) {
    final group = _asMap(rawGroups[index]);
    final id = _asString(group['id']) ?? 'group-$index';
    final children = chaptersByGroup[id] ?? const <Map<String, dynamic>>[];
    chapterGroups.add(
      _normalizeChapterGroup(
        id: id,
        rawTitle: _asString(group['title']),
        index: index,
        chapters: children,
        localizations: localizations,
      ),
    );
  }

  final groupedChapterIds = chapterGroups
      .expand((group) => _asStringList(group['chapterIds']))
      .toSet();

  final ungroupedChapters = chapters
      .where((chapter) => !groupedChapterIds.contains(chapter['id']))
      .toList();
  if (ungroupedChapters.isNotEmpty) {
    chapterGroups.add(
      _normalizeChapterGroup(
        id: 'ungrouped',
        rawTitle: null,
        index: chapterGroups.length,
        chapters: ungroupedChapters,
        localizations: localizations,
      ),
    );
  }

  final sourceTitleResolution = localizations.resolveText(
    _asString(globalData['title']),
  );

  final output = <String, dynamic>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'localization': {
      'primaryLocale': localizations.primaryLocale,
      'fallbackLocale': localizations.fallbackLocale,
      'availableLocales': localizations.availableLocales,
    },
    'source': {
      'title': sourceTitleResolution.text ?? 'FTB Quests',
      'titleKey': sourceTitleResolution.unresolvedKey,
      'version': _asInt(globalData['version']) ?? 0,
      'progressionMode': _asString(globalData['progression_mode']) ?? '',
      'gridScale': _asDouble(globalData['grid_scale']) ?? 1.0,
      'icon': _extractIconId(globalData['icon']),
    },
    'chapterGroups': chapterGroups,
    'chapters': chapters,
  };

  final outputDir = Directory(
    _join(root.path, ['assets', 'generated', 'quests']),
  );
  outputDir.createSync(recursive: true);
  final outputFile = File(_join(outputDir.path, ['quest_catalog.json']));
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(output),
    encoding: utf8,
  );

  stdout.writeln(
    'Generated ${outputFile.path} with ${chapterGroups.length} groups and ${chapters.length} chapters using ${localizations.primaryLocale}.',
  );
}

class _GeneratorOptions {
  const _GeneratorOptions({
    required this.primaryLocale,
    required this.fallbackLocale,
  });

  factory _GeneratorOptions.fromArgs(List<String> args) {
    var primaryLocale = 'zh_cn';
    var fallbackLocale = 'en_us';

    for (final arg in args) {
      if (arg.startsWith('--locale=')) {
        primaryLocale = arg.substring('--locale='.length).trim().toLowerCase();
      } else if (arg.startsWith('--fallback-locale=')) {
        fallbackLocale = arg
            .substring('--fallback-locale='.length)
            .trim()
            .toLowerCase();
      }
    }

    return _GeneratorOptions(
      primaryLocale: primaryLocale,
      fallbackLocale: fallbackLocale,
    );
  }

  final String primaryLocale;
  final String fallbackLocale;
}

class _LocalizationStore {
  const _LocalizationStore({
    required this.primaryLocale,
    required this.fallbackLocale,
    required this.bundles,
  });

  factory _LocalizationStore.load(
    Directory langDir, {
    required String primaryLocale,
    required String fallbackLocale,
  }) {
    final bundles = <String, Map<String, String>>{};

    if (langDir.existsSync()) {
      final files =
          langDir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList()
            ..sort((left, right) => left.path.compareTo(right.path));

      for (final file in files) {
        final locale = file.uri.pathSegments.last
            .replaceAll('.json', '')
            .toLowerCase();
        final payload = jsonDecode(_readTextFile(file));
        if (payload is! Map) {
          continue;
        }
        bundles[locale] = payload.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    return _LocalizationStore(
      primaryLocale: primaryLocale,
      fallbackLocale: fallbackLocale,
      bundles: bundles,
    );
  }

  final String primaryLocale;
  final String fallbackLocale;
  final Map<String, Map<String, String>> bundles;

  List<String> get availableLocales {
    final locales = bundles.keys.toList()..sort();
    return List.unmodifiable(locales);
  }

  String? lookup(String key) {
    for (final locale in _resolutionOrder()) {
      final value = bundles[locale]?[key];
      final cleaned = _cleanDisplayText(value);
      if (cleaned != null && cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return null;
  }

  _ResolvedText resolveText(String? raw, {String? inferredKey}) {
    final explicitKey = _translationKey(raw);
    if (explicitKey != null) {
      final translated = lookup(explicitKey);
      if (translated != null) {
        return _ResolvedText(text: translated);
      }
    }

    if (inferredKey != null) {
      final translated = lookup(inferredKey);
      if (translated != null) {
        return _ResolvedText(text: translated);
      }
    }

    final cleanedRaw = _cleanDisplayText(raw);
    if (cleanedRaw != null && cleanedRaw.isNotEmpty) {
      return _ResolvedText(text: cleanedRaw);
    }

    return _ResolvedText(unresolvedKey: explicitKey ?? inferredKey);
  }

  _ResolvedLines resolveLines(
    List<String> rawLines, {
    String? indexedPrefix,
    int indexedStart = 1,
  }) {
    if (rawLines.isNotEmpty) {
      final lines = <String>[];
      final unresolvedKeys = <String>[];
      for (final rawLine in rawLines) {
        final resolved = resolveText(rawLine);
        if (resolved.text != null && resolved.text!.isNotEmpty) {
          lines.add(resolved.text!);
        } else if (resolved.unresolvedKey != null) {
          unresolvedKeys.add(resolved.unresolvedKey!);
        }
      }
      return _ResolvedLines(lines: lines, unresolvedKeys: unresolvedKeys);
    }

    if (indexedPrefix == null || indexedPrefix.isEmpty) {
      return const _ResolvedLines();
    }

    final lines = <String>[];
    final unresolvedKeys = <String>[];
    for (var index = indexedStart; index < indexedStart + 128; index++) {
      final key = '$indexedPrefix$index';
      final translated = lookup(key);
      if (translated == null) {
        if (lines.isNotEmpty) {
          break;
        }
        continue;
      }
      lines.add(translated);
    }

    if (lines.isEmpty) {
      unresolvedKeys.add('$indexedPrefix$indexedStart');
    }

    return _ResolvedLines(lines: lines, unresolvedKeys: unresolvedKeys);
  }

  Iterable<String> _resolutionOrder() sync* {
    final emitted = <String>{};
    for (final locale in [primaryLocale, fallbackLocale, ...bundles.keys]) {
      if (!bundles.containsKey(locale) || !emitted.add(locale)) {
        continue;
      }
      yield locale;
    }
  }
}

class _ResolvedText {
  const _ResolvedText({this.text, this.unresolvedKey});

  final String? text;
  final String? unresolvedKey;
}

class _ResolvedLines {
  const _ResolvedLines({
    this.lines = const <String>[],
    this.unresolvedKeys = const <String>[],
  });

  final List<String> lines;
  final List<String> unresolvedKeys;
}

class _QuestLocalizationContext {
  const _QuestLocalizationContext({required this.chapterKey, this.questKeyId});

  final String chapterKey;
  final String? questKeyId;

  String get chapterTitleKey => 'ftbquests.chapter.$chapterKey.title';
  String get chapterSubtitlePrefix => 'ftbquests.chapter.$chapterKey.subtitle';

  String? get questTitleKey => questKeyId == null
      ? null
      : 'ftbquests.chapter.$chapterKey.quest$questKeyId.title';

  String? get questSubtitleKey => questKeyId == null
      ? null
      : 'ftbquests.chapter.$chapterKey.quest$questKeyId.subtitle';

  String? get questDescriptionPrefix => questKeyId == null
      ? null
      : 'ftbquests.chapter.$chapterKey.quest$questKeyId.description';

  _QuestLocalizationContext forQuest(String? questId) {
    return _QuestLocalizationContext(
      chapterKey: chapterKey,
      questKeyId: _decimalId(questId),
    );
  }

  String? taskTitleKey(String? taskId) {
    final decimalTaskId = _decimalId(taskId);
    if (questKeyId == null || decimalTaskId == null) {
      return null;
    }
    return 'ftbquests.chapter.$chapterKey.quest$questKeyId.task.$decimalTaskId.title';
  }

  String? rewardTitleKey(String? rewardId) {
    final decimalRewardId = _decimalId(rewardId);
    if (questKeyId == null || decimalRewardId == null) {
      return null;
    }
    return 'ftbquests.chapter.$chapterKey.quest$questKeyId.reward.$decimalRewardId.title';
  }
}

Map<String, dynamic> _normalizeChapter(
  Map<String, dynamic> raw,
  File file,
  Map<String, Map<String, dynamic>> rewardTables,
  _LocalizationStore localizations,
) {
  final fileStem = file.uri.pathSegments.last.replaceAll('.snbt', '');
  final chapterKey = _asString(raw['filename']) ?? fileStem;
  final context = _QuestLocalizationContext(chapterKey: chapterKey);
  final rawQuests = _asList(raw['quests']);
  final quests = rawQuests
      .map(
        (quest) => _normalizeQuest(
          _asMap(quest),
          rewardTables,
          localizations,
          context,
        ),
      )
      .toList();
  final questLinks = _asList(
    raw['quest_links'],
  ).map((link) => _normalizeQuestLink(_asMap(link), localizations)).toList();

  final positions = <PointData>[
    ...quests.map(
      (quest) => PointData(quest['x'] as double, quest['y'] as double),
    ),
    ...questLinks.map(
      (link) => PointData(link['x'] as double, link['y'] as double),
    ),
  ];
  final bounds = _buildBounds(positions);

  final titleResolution = localizations.resolveText(
    _asString(raw['title']),
    inferredKey: context.chapterTitleKey,
  );
  final subtitleResolution = localizations.resolveLines(
    _stringListFromValue(raw['subtitle']),
    indexedPrefix: context.chapterSubtitlePrefix,
    indexedStart: 0,
  );

  return <String, dynamic>{
    'id': _asString(raw['id']) ?? chapterKey,
    'filename': chapterKey,
    'groupId': _asString(raw['group']),
    'title': titleResolution.text ?? _guessChapterTitle(chapterKey),
    'titleKey': titleResolution.unresolvedKey,
    'subtitle': subtitleResolution.lines,
    'icon': _extractIconId(raw['icon']),
    'orderIndex': _asInt(raw['order_index']) ?? 0,
    'defaultQuestShape': _asString(raw['default_quest_shape']) ?? '',
    'questCount': quests.length,
    'questLinkCount': questLinks.length,
    'bounds': bounds,
    'quests': quests,
    'questLinks': questLinks,
  };
}

Map<String, dynamic> _normalizeQuest(
  Map<String, dynamic> raw,
  Map<String, Map<String, dynamic>> rewardTables,
  _LocalizationStore localizations,
  _QuestLocalizationContext chapterContext,
) {
  final questId = _asString(raw['id']) ?? '';
  final context = chapterContext.forQuest(questId);
  final tasks = _asList(raw['tasks'])
      .map((task) => _normalizeTask(_asMap(task), localizations, context))
      .toList();
  final rewards = _asList(raw['rewards'])
      .map(
        (reward) => _normalizeReward(
          _asMap(reward),
          rewardTables,
          localizations,
          context,
        ),
      )
      .toList();

  final titleResolution = localizations.resolveText(
    _asString(raw['title']),
    inferredKey: context.questTitleKey,
  );
  final subtitleResolution = localizations.resolveText(
    _asString(raw['subtitle']),
    inferredKey: context.questSubtitleKey,
  );
  final descriptionResolution = localizations.resolveLines(
    _stringListFromValue(raw['description']),
    indexedPrefix: context.questDescriptionPrefix,
    indexedStart: 1,
  );

  final icon = _extractIconId(raw['icon']) ?? _pickQuestIcon(tasks, rewards);

  return <String, dynamic>{
    'id': questId,
    'title':
        titleResolution.text ??
        _resolveQuestTitleFallback(
          subtitle: subtitleResolution.text,
          tasks: tasks,
          id: questId,
        ),
    'titleKey': titleResolution.unresolvedKey,
    'subtitle': subtitleResolution.text,
    'subtitleKey': subtitleResolution.unresolvedKey,
    'description': descriptionResolution.lines,
    'descriptionKeys': descriptionResolution.unresolvedKeys,
    'icon': icon,
    'shape': _asString(raw['shape']) ?? 'circle',
    'size': _asDouble(raw['size']) ?? 1.0,
    'x': _asDouble(raw['x']) ?? 0.0,
    'y': _asDouble(raw['y']) ?? 0.0,
    'dependencies': _asStringList(raw['dependencies']),
    'tasks': tasks,
    'rewards': rewards,
  };
}

Map<String, dynamic> _normalizeTask(
  Map<String, dynamic> raw,
  _LocalizationStore localizations,
  _QuestLocalizationContext context,
) {
  final type = _asString(raw['type']) ?? 'unknown';
  final itemIds = _extractItemIds(raw['item']);
  final titleResolution = localizations.resolveText(
    _asString(raw['title']),
    inferredKey: context.taskTitleKey(_asString(raw['id'])),
  );

  return <String, dynamic>{
    'id': _asString(raw['id']) ?? '',
    'type': type,
    'title':
        titleResolution.text ??
        _resolveTaskTitleFallback(type: type, raw: raw, itemIds: itemIds),
    'titleKey': titleResolution.unresolvedKey,
    'itemIds': itemIds,
    'primaryItemId': itemIds.isEmpty ? null : itemIds.first,
    'count': _resolveCount(raw),
    'target': _resolveTaskTarget(type, raw),
  };
}

Map<String, dynamic> _normalizeReward(
  Map<String, dynamic> raw,
  Map<String, Map<String, dynamic>> rewardTables,
  _LocalizationStore localizations,
  _QuestLocalizationContext context,
) {
  final type = _asString(raw['type']) ?? 'item';
  final tableId = _normalizeTableId(raw['table_id']);
  final resolvedTable = tableId == null ? null : rewardTables[tableId];
  final itemIds = _extractItemIds(raw['item']);
  final count = _resolveCount(raw);
  final titleResolution = localizations.resolveText(
    _asString(raw['title']),
    inferredKey: context.rewardTitleKey(_asString(raw['id'])),
  );

  return <String, dynamic>{
    'id': _asString(raw['id']) ?? '',
    'type': type,
    'count': count,
    'itemIds': itemIds,
    'primaryItemId': itemIds.isEmpty ? null : itemIds.first,
    'tableId': tableId,
    'tableTitle': resolvedTable?['title'],
    'tableTitleKey': resolvedTable?['titleKey'],
    'tableEntries': resolvedTable?['entries'],
    'label': _resolveRewardLabel(
      type: type,
      explicitLabel: titleResolution.text,
      itemIds: itemIds,
      count: count,
      table: resolvedTable,
    ),
    'labelKey': titleResolution.unresolvedKey,
  };
}

Map<String, dynamic> _normalizeRewardTable(
  Map<String, dynamic> raw,
  File file,
  _LocalizationStore localizations,
) {
  final entries = _asList(raw['rewards']).map((entry) {
    final entryMap = _asMap(entry);
    final itemIds = _extractItemIds(entryMap['item']);
    return <String, dynamic>{
      'itemIds': itemIds,
      'primaryItemId': itemIds.isEmpty ? null : itemIds.first,
      'count': _resolveCount(entryMap),
      'weight': _asDouble(entryMap['weight']),
      'label': _resolveItemLabel(itemIds, _resolveCount(entryMap)),
    };
  }).toList();

  final fileKey = file.uri.pathSegments.last.replaceAll('.snbt', '');
  final titleRaw = _asString(raw['title']);
  final titleKeyParts =
      _translationKey(titleRaw)?.split('.') ?? const <String>[];
  final tableId = titleKeyParts.length > 2 ? titleKeyParts[2] : fileKey;
  final titleResolution = localizations.resolveText(titleRaw);

  return <String, dynamic>{
    'id': _asString(raw['id']) ?? fileKey,
    'tableId': tableId,
    'title': titleResolution.text ?? '濂栧姳姹?$fileKey',
    'titleKey': titleResolution.unresolvedKey,
    'lootSize': _asInt(raw['loot_size']) ?? 1,
    'orderIndex': _asInt(raw['order_index']) ?? 0,
    'entries': entries,
  };
}

Map<String, dynamic> _normalizeQuestLink(
  Map<String, dynamic> raw,
  _LocalizationStore localizations,
) {
  final titleResolution = localizations.resolveText(_asString(raw['title']));
  final rawTitle = _asString(raw['title']);
  return <String, dynamic>{
    'id': _asString(raw['id']) ?? '',
    'linkedQuestId': _asString(raw['linked_quest']) ?? '',
    'title': titleResolution.text ?? _translationKey(rawTitle) ?? '璺宠浆',
    'x': _asDouble(raw['x']) ?? 0.0,
    'y': _asDouble(raw['y']) ?? 0.0,
  };
}

Map<String, dynamic> _normalizeChapterGroup({
  required String id,
  required String? rawTitle,
  required int index,
  required List<Map<String, dynamic>> chapters,
  required _LocalizationStore localizations,
}) {
  final titleResolution = localizations.resolveText(rawTitle);
  return <String, dynamic>{
    'id': id,
    'title': titleResolution.text ?? _guessGroupTitle(chapters, index),
    'titleKey': titleResolution.unresolvedKey,
    'chapterIds': chapters.map((chapter) => chapter['id']).toList(),
  };
}

Map<String, dynamic> _buildBounds(List<PointData> points) {
  if (points.isEmpty) {
    return const <String, dynamic>{
      'minX': 0.0,
      'maxX': 0.0,
      'minY': 0.0,
      'maxY': 0.0,
    };
  }

  var minX = points.first.x;
  var maxX = points.first.x;
  var minY = points.first.y;
  var maxY = points.first.y;

  for (final point in points.skip(1)) {
    if (point.x < minX) minX = point.x;
    if (point.x > maxX) maxX = point.x;
    if (point.y < minY) minY = point.y;
    if (point.y > maxY) maxY = point.y;
  }

  return <String, dynamic>{
    'minX': minX,
    'maxX': maxX,
    'minY': minY,
    'maxY': maxY,
  };
}

String _resolveQuestTitleFallback({
  required String? subtitle,
  required List<Map<String, dynamic>> tasks,
  required String id,
}) {
  if (subtitle != null && subtitle.isNotEmpty) {
    return subtitle;
  }

  for (final task in tasks) {
    final taskTitle = _asString(task['title']);
    if (taskTitle != null && taskTitle.isNotEmpty) {
      return taskTitle;
    }
  }

  final shortId = id.isEmpty
      ? 'unknown'
      : id.substring(0, id.length < 6 ? id.length : 6);
  return '浠诲姟 $shortId';
}

String _resolveTaskTitleFallback({
  required String type,
  required Map<String, dynamic> raw,
  required List<String> itemIds,
}) {
  final count = _resolveCount(raw);
  final itemLabel = _resolveItemLabel(itemIds, count);

  switch (type) {
    case 'item':
    case 'loot':
      return itemLabel;
    case 'kill':
      return '鍑绘潃 ${_stripNamespace(_asString(raw['entity']) ?? '鐩爣')}';
    case 'dimension':
      return '鍓嶅線 ${_stripNamespace(_asString(raw['dimension']) ?? '缁村害')}';
    case 'structure':
      return '鎵惧埌 ${_stripNamespace(_asString(raw['structure']) ?? '缁撴瀯')}';
    case 'biome':
      return '鍓嶅線 ${_stripNamespace(_asString(raw['biome']) ?? '缇ょ郴')}';
    case 'xp':
      return '鑾峰緱缁忛獙 $count';
    case 'xp_levels':
      return '鑾峰緱绛夌骇 $count';
    case 'checkmark':
      return '鎵嬪姩纭';
    case 'observation':
      return '闃呰璇存槑';
    case 'choice':
      return '浜岄€変竴鐩爣';
    case 'command':
      return '鎵ц鍛戒护';
    case 'random':
      return '闅忔満鐩爣';
    case 'cherry':
      return '鐗规畩浠诲姟';
    default:
      return type;
  }
}

String? _resolveTaskTarget(String type, Map<String, dynamic> raw) {
  switch (type) {
    case 'item':
    case 'loot':
      final items = _extractItemIds(raw['item']);
      return items.isEmpty ? null : items.map(_stripNamespace).join(' / ');
    case 'kill':
      return _asString(raw['entity']);
    case 'dimension':
      return _asString(raw['dimension']);
    case 'structure':
      return _asString(raw['structure']);
    case 'biome':
      return _asString(raw['biome']);
    case 'command':
      return _asString(raw['command']);
    default:
      return null;
  }
}

String _resolveRewardLabel({
  required String type,
  required String? explicitLabel,
  required List<String> itemIds,
  required int count,
  required Map<String, dynamic>? table,
}) {
  if (explicitLabel != null && explicitLabel.isNotEmpty) {
    return explicitLabel;
  }
  if (type == 'random' && table != null) {
    return table['title'] as String? ?? 'Random reward';
  }
  if (itemIds.isNotEmpty) {
    return _resolveItemLabel(itemIds, count);
  }
  return type;
}

String _resolveItemLabel(List<String> itemIds, int count) {
  if (itemIds.isEmpty) {
    return 'Unspecified item';
  }
  final joined = itemIds.take(3).map(_stripNamespace).join(' / ');
  return count > 1 ? '$joined x$count' : joined;
}

String? _pickQuestIcon(
  List<Map<String, dynamic>> tasks,
  List<Map<String, dynamic>> rewards,
) {
  for (final task in tasks) {
    final itemId = _asString(task['primaryItemId']);
    if (itemId != null && itemId.isNotEmpty) {
      return itemId;
    }
  }
  for (final reward in rewards) {
    final itemId = _asString(reward['primaryItemId']);
    if (itemId != null && itemId.isNotEmpty) {
      return itemId;
    }
  }
  return null;
}

String _guessChapterTitle(String filename) {
  const known = {
    'lv': 'LV Stage',
    'mv': 'MV Stage',
    'hv': 'HV Stage',
    'ev': 'EV Stage',
    'iv': 'IV Stage',
    'luv': 'LuV Stage',
    'zpm': 'ZPM Stage',
    'uv': 'UV Stage',
    'uhv': 'UHV Stage',
    'ae2': 'AE2',
    'too_many_items': 'Too Many Items',
  };
  return known[filename] ?? filename.toUpperCase();
}

String _guessGroupTitle(List<Map<String, dynamic>> chapters, int index) {
  final filenames = chapters
      .map((chapter) => _asString(chapter['filename']) ?? '')
      .toSet();
  const tierNames = {'lv', 'mv', 'hv', 'ev', 'iv', 'luv', 'zpm', 'uv', 'uhv'};
  final tierCount = filenames.where(tierNames.contains).length;
  if (tierCount >= 3) {
    return 'Power Era';
  }
  if (chapters.length == 1) {
    return _asString(chapters.first['title']) ?? 'Chapter';
  }
  if (chapters.isNotEmpty) {
    return '${_asString(chapters.first['title']) ?? 'Group'} etc';
  }
  return 'Group ${index + 1}';
}
String? _extractIconId(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is String) {
    return raw;
  }
  if (raw is Map) {
    return _asString(raw['id']);
  }
  if (raw is Map<String, dynamic>) {
    return _asString(raw['id']);
  }
  return null;
}

List<String> _extractItemIds(dynamic raw) {
  if (raw == null) {
    return const [];
  }
  if (raw is String) {
    return [raw];
  }
  if (raw is Map) {
    final map = _asMap(raw);
    final items = <String>[];
    final id = _asString(map['id']);
    if (id != null && id != 'itemfilters:or' && id.isNotEmpty) {
      items.add(id);
    }
    final tag = map['tag'];
    if (tag is Map || tag is Map<String, dynamic>) {
      final tagMap = _asMap(tag);
      final nested = _asList(tagMap['items']);
      for (final item in nested) {
        items.addAll(_extractItemIds(item));
      }
    }
    return items.toSet().toList();
  }
  return const [];
}

int _resolveCount(Map<String, dynamic> raw) {
  final direct = _asInt(raw['count']);
  if (direct != null) {
    return direct;
  }
  final item = raw['item'];
  if (item is Map || item is Map<String, dynamic>) {
    final map = _asMap(item);
    final nested = _asInt(map['Count']);
    if (nested != null) {
      return nested;
    }
  }
  return 1;
}

String? _normalizeTableId(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}

String? _translationKey(String? raw) {
  if (!_isTranslationKey(raw)) {
    return null;
  }
  return raw!.substring(1, raw.length - 1);
}

bool _isTranslationKey(String? raw) {
  if (raw == null) {
    return false;
  }
  final trimmed = raw.trim();
  return trimmed.startsWith('{') && trimmed.endsWith('}');
}

String? _cleanDisplayText(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty || _isTranslationKey(trimmed)) {
    return null;
  }
  return trimmed
      .replaceAll(RegExp(r'[&§][0-9a-fk-or]', caseSensitive: false), '')
      .replaceAll('%%', '%')
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

List<String> _stringListFromValue(dynamic raw) {
  if (raw == null) {
    return const [];
  }
  if (raw is String) {
    return [raw];
  }
  if (raw is List) {
    return raw.map((item) => item.toString()).toList(growable: false);
  }
  return [raw.toString()];
}

Map<String, dynamic> _asMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

List<dynamic> _asList(dynamic raw) {
  if (raw is List) {
    return raw;
  }
  return const <dynamic>[];
}

String? _asString(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is String) {
    return raw;
  }
  return raw.toString();
}

int? _asInt(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is int) {
    return raw;
  }
  if (raw is double) {
    return raw.round();
  }
  return int.tryParse(raw.toString());
}

double? _asDouble(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is double) {
    return raw;
  }
  if (raw is int) {
    return raw.toDouble();
  }
  return double.tryParse(raw.toString());
}

List<String> _asStringList(dynamic raw) {
  if (raw is List) {
    return raw.map((item) => item.toString()).toList(growable: false);
  }
  return const [];
}

String _stripNamespace(String value) {
  final index = value.indexOf(':');
  return index == -1 ? value : value.substring(index + 1);
}

String _join(String root, List<String> parts) {
  final allParts = [root, ...parts];
  return allParts.join(Platform.pathSeparator);
}

String _readTextFile(File file) {
  const bom = '\uFEFF';
  final text = utf8.decode(file.readAsBytesSync(), allowMalformed: false);
  return text.startsWith(bom) ? text.substring(1) : text.replaceFirst(bom, '');
}

String? _decimalId(String? raw) {
  if (raw == null) {
    return null;
  }
  final normalized = raw.trim();
  if (normalized.isEmpty) {
    return null;
  }
  if (RegExp(r'^[0-9]+$').hasMatch(normalized)) {
    return normalized;
  }
  if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(normalized)) {
    return BigInt.parse(normalized, radix: 16).toString();
  }
  return null;
}

class PointData {
  const PointData(this.x, this.y);

  final double x;
  final double y;
}

class _SnbtParser {
  late String _input;
  late int _length;
  int _index = 0;

  dynamic parse(String input) {
    _input = input;
    _length = input.length;
    _index = 0;
    final value = _parseValue();
    _skipIgnored();
    if (_index < _length) {
      throw FormatException('Unexpected trailing content at $_index');
    }
    return value;
  }

  dynamic _parseValue() {
    _skipIgnored();
    if (_index >= _length) {
      throw const FormatException('Unexpected end of input');
    }

    final char = _input[_index];
    if (char == '{') {
      return _parseCompound();
    }
    if (char == '[') {
      return _parseListOrTypedArray();
    }
    if (char == '"') {
      return _parseQuotedString();
    }

    return _parseScalar();
  }

  Map<String, dynamic> _parseCompound() {
    _expect('{');
    final result = <String, dynamic>{};
    while (true) {
      _skipIgnored();
      if (_peek('}')) {
        _index++;
        break;
      }

      final key = _parseKey();
      _skipIgnored();
      _expect(':');
      final value = _parseValue();
      result[key] = value;

      _skipIgnored();
      if (_peek(',')) {
        _index++;
      }
    }
    return result;
  }

  List<dynamic> _parseListOrTypedArray() {
    _expect('[');
    _skipIgnored();

    if (_index + 1 < _length &&
        (_input[_index] == 'I' ||
            _input[_index] == 'B' ||
            _input[_index] == 'L') &&
        _input[_index + 1] == ';') {
      _index += 2;
      return _parseListBody();
    }

    return _parseListBody();
  }

  List<dynamic> _parseListBody() {
    final result = <dynamic>[];
    while (true) {
      _skipIgnored();
      if (_peek(']')) {
        _index++;
        break;
      }
      result.add(_parseValue());
      _skipIgnored();
      if (_peek(',')) {
        _index++;
      }
    }
    return result;
  }

  String _parseKey() {
    _skipIgnored();
    if (_peek('"')) {
      return _parseQuotedString();
    }

    final start = _index;
    while (_index < _length) {
      final char = _input[_index];
      if (char == ':' || _isWhitespace(char)) {
        break;
      }
      _index++;
    }
    return _input.substring(start, _index);
  }

  String _parseQuotedString() {
    _expect('"');
    final buffer = StringBuffer();
    while (_index < _length) {
      final char = _input[_index++];
      if (char == '"') {
        return buffer.toString();
      }
      if (char == r'\') {
        if (_index >= _length) {
          throw const FormatException('Unexpected end of string');
        }
        final escaped = _input[_index++];
        switch (escaped) {
          case '"':
          case r'\':
          case '/':
            buffer.write(escaped);
            break;
          case 'b':
            buffer.write('\b');
            break;
          case 'f':
            buffer.write('\f');
            break;
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'u':
            final hex = _input.substring(_index, _index + 4);
            buffer.write(String.fromCharCode(int.parse(hex, radix: 16)));
            _index += 4;
            break;
          default:
            buffer.write(escaped);
            break;
        }
      } else {
        buffer.write(char);
      }
    }
    throw const FormatException('Unterminated string');
  }

  dynamic _parseScalar() {
    final start = _index;
    while (_index < _length) {
      final char = _input[_index];
      if (_isTerminator(char)) {
        break;
      }
      _index++;
    }

    final token = _input.substring(start, _index).trim();
    if (token == 'true') {
      return true;
    }
    if (token == 'false') {
      return false;
    }

    final normalized = _parseNumber(token);
    if (normalized != null) {
      return normalized;
    }

    return token;
  }

  dynamic _parseNumber(String token) {
    if (token.isEmpty) {
      return null;
    }

    final match = RegExp(
      r'^([-+]?\d+(?:\.\d+)?)([bBsSlLfFdD]?)$',
    ).firstMatch(token);
    if (match == null) {
      return null;
    }

    final number = match.group(1)!;
    final suffix = match.group(2)?.toLowerCase() ?? '';

    if (suffix == 'l') {
      return number;
    }
    if (number.contains('.')) {
      return double.parse(number);
    }
    return int.parse(number);
  }

  void _skipIgnored() {
    while (_index < _length) {
      final char = _input[_index];
      if (_isWhitespace(char)) {
        _index++;
        continue;
      }
      if (char == '/' && _index + 1 < _length) {
        final next = _input[_index + 1];
        if (next == '/') {
          _index += 2;
          while (_index < _length && _input[_index] != '\n') {
            _index++;
          }
          continue;
        }
      }
      break;
    }
  }

  void _expect(String expected) {
    if (_index >= _length || _input[_index] != expected) {
      throw FormatException('Expected $expected at $_index');
    }
    _index++;
  }

  bool _peek(String char) {
    return _index < _length && _input[_index] == char;
  }

  bool _isWhitespace(String char) {
    return char == ' ' || char == '\n' || char == '\r' || char == '\t';
  }

  bool _isTerminator(String char) {
    return _isWhitespace(char) ||
        char == ',' ||
        char == ']' ||
        char == '}' ||
        char == ':';
  }
}







