import 'dart:convert';

import 'package:ctnh_wiki/features/handbook/models/mod_catalog_entry.dart';
import 'package:flutter/services.dart';

class ModCatalogRepository {
  const ModCatalogRepository({
    this.assetPath = 'assets/ModsList.json',
    this.bundle,
    this.parser = const ModCatalogParser(),
  });

  final String assetPath;
  final AssetBundle? bundle;
  final ModCatalogParser parser;

  Future<ModCatalogDocument> loadCatalog() async {
    final rawText = await (bundle ?? rootBundle).loadString(assetPath);
    return parser.parseCatalog(rawText);
  }

  Future<List<ModCatalogEntry>> loadEntries() async {
    return (await loadCatalog()).mods;
  }

  Future<List<Map<String, dynamic>>> loadJsonList() async {
    final catalog = await loadCatalog();
    return catalog.mods.map((entry) => entry.toJson()).toList();
  }

  Future<String> loadJsonString({bool pretty = false}) async {
    final rawText = await (bundle ?? rootBundle).loadString(assetPath);
    if (!pretty) {
      return rawText;
    }

    final decoded = jsonDecode(rawText);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  }
}

class ModCatalogParser {
  const ModCatalogParser();

  static final RegExp _jarExtensionPattern = RegExp(
    r'\.jar$',
    caseSensitive: false,
  );
  static final RegExp _splitPattern = RegExp(r'[-_+]');
  static final RegExp _compactVersionPattern = RegExp(
    r'^[vV]?\d+(?:\.\d+)*(?:[a-zA-Z]+\d*)?(?:\.[xX])?$',
  );
  static final RegExp _minecraftVersionPattern = RegExp(
    r'^1\.(?:1[6-9]|[2-9]\d)(?:\.\d+|\.x|\.X)?(?:-1\.(?:1[6-9]|[2-9]\d)(?:\.\d+|\.x|\.X)?)?$',
  );
  static const Map<String, String> _loaderLabels = {
    'neoforge': 'NeoForge',
    'forge': 'Forge',
    'fabric': 'Fabric',
    'quilt': 'Quilt',
    'universal': 'Universal',
  };

  ModCatalogDocument parseCatalog(String rawText) {
    final decoded = jsonDecode(rawText) as Map<String, dynamic>;
    final mods =
        (decoded['mods'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_parseModEntry)
            .toList()
          ..sort(
            (left, right) => left.displayName.toLowerCase().compareTo(
              right.displayName.toLowerCase(),
            ),
          );

    final summaryCounts =
        (decoded['summary_counts'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );

    return ModCatalogDocument(
      taxonomyVersion: decoded['taxonomy_version'] as String? ?? '',
      source: decoded['source'] as String? ?? '未标注来源',
      summaryCounts: summaryCounts,
      mods: mods,
    );
  }

  ModCatalogEntry _parseModEntry(Map<String, dynamic> json) {
    final fileName = json['filename'] as String? ?? '';
    final derived = _deriveFromFilename(fileName);

    return ModCatalogEntry(
      id: derived['id'] as String,
      displayName:
          _readString(json['display_name']) ??
          _readString(json['displayName']) ??
          derived['displayName'] as String,
      fileName: fileName,
      modId:
          _readString(json['mod_id']) ??
          _readString(json['modId']) ??
          derived['modId'] as String,
      loader:
          _readString(json['loader']) ?? derived['loader'] as String? ?? '未标注',
      primaryCategory:
          _readString(json['primary']) ??
          _readString(json['primaryCategory']) ??
          '未分类',
      subcategories: _readStringList(json['subcategories']),
      tags: _readStringList(json['tags']),
      gameVersion:
          _readString(json['game_version']) ??
          _readString(json['gameVersion']) ??
          derived['gameVersion'] as String?,
      modVersion:
          _readString(json['mod_version']) ??
          _readString(json['modVersion']) ??
          derived['modVersion'] as String?,
      note: _readString(json['note']),
      description: _readString(json['description']),
    );
  }

  List<String> _readStringList(Object? value) {
    return (value as List<dynamic>? ?? const [])
        .whereType<String>()
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  String? _readString(Object? value) {
    final stringValue = value as String?;
    if (stringValue == null) {
      return null;
    }
    final trimmed = stringValue.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, Object?> _deriveFromFilename(String fileName) {
    final baseName = fileName.replaceFirst(_jarExtensionPattern, '');
    final tokens = baseName
        .split(_splitPattern)
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList();

    final firstMetaIndex = _findFirstMetaIndex(tokens);
    final nameTokens = firstMetaIndex > 0
        ? tokens.sublist(0, firstMetaIndex)
        : [if (tokens.isNotEmpty) tokens.first];
    final metaTokens = firstMetaIndex < tokens.length
        ? tokens.sublist(firstMetaIndex)
        : const <String>[];

    final displayName = _buildDisplayName(nameTokens, baseName);
    final modId = _slugify(
      nameTokens.isEmpty ? baseName : nameTokens.join('_'),
    );
    final gameVersion = _extractGameVersion(metaTokens);
    final loader = _extractLoader(tokens);
    final modVersion = _extractModVersion(
      metaTokens,
      loaderLabel: loader,
      gameVersion: gameVersion,
    );

    return {
      'id': modId.isEmpty ? _slugify(baseName) : modId,
      'displayName': displayName,
      'modId': modId.isEmpty ? _slugify(baseName) : modId,
      'loader': loader,
      'gameVersion': gameVersion,
      'modVersion': modVersion,
    };
  }

  int _findFirstMetaIndex(List<String> tokens) {
    final index = tokens.indexWhere((token) {
      final normalized = token.toLowerCase();
      return _loaderLabels.containsKey(normalized) ||
          normalized.startsWith('mc') ||
          _looksLikeVersionToken(token);
    });
    return index == -1 ? tokens.length : index;
  }

  String _extractLoader(List<String> tokens) {
    for (final token in tokens) {
      final loader = _loaderLabels[token.toLowerCase()];
      if (loader != null) {
        return loader;
      }
    }
    return '未标注';
  }

  String? _extractGameVersion(List<String> metaTokens) {
    for (final token in metaTokens) {
      final normalized = token.toLowerCase();
      if (normalized.startsWith('mc')) {
        final candidate = normalized.substring(2);
        if (_minecraftVersionPattern.hasMatch(candidate)) {
          return candidate.toUpperCase();
        }
      }
    }

    for (final token in metaTokens) {
      if (_minecraftVersionPattern.hasMatch(token)) {
        return token.toUpperCase();
      }
    }

    return null;
  }

  String? _extractModVersion(
    List<String> metaTokens, {
    required String loaderLabel,
    required String? gameVersion,
  }) {
    final normalizedGameVersion = gameVersion?.toLowerCase();
    final versionTokens = metaTokens.where((token) {
      final normalized = token.toLowerCase();
      if (_loaderLabels[normalized] == loaderLabel) {
        return false;
      }
      if (normalizedGameVersion != null &&
          (normalized == normalizedGameVersion ||
              normalized == 'mc$normalizedGameVersion')) {
        return false;
      }
      return _looksLikeVersionToken(token) || _looksLikeReleaseToken(token);
    }).toList();

    if (versionTokens.isEmpty) {
      return null;
    }

    return versionTokens.join('-');
  }

  bool _looksLikeVersionToken(String token) {
    final normalized = token.toLowerCase();
    if (normalized.startsWith('mc')) {
      return _minecraftVersionPattern.hasMatch(normalized.substring(2));
    }
    return _compactVersionPattern.hasMatch(normalized) ||
        _minecraftVersionPattern.hasMatch(normalized);
  }

  bool _looksLikeReleaseToken(String token) {
    final normalized = token.toLowerCase();
    return normalized.startsWith('alpha') ||
        normalized.startsWith('beta') ||
        normalized == 'release' ||
        normalized == 'snapshot' ||
        normalized == 'merged' ||
        normalized == 'all';
  }

  String _buildDisplayName(List<String> nameTokens, String fallback) {
    final source = nameTokens.isEmpty ? fallback : nameTokens.join(' ');
    return source
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
