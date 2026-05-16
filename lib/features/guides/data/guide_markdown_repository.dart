import 'dart:convert';

import 'package:ctnh_wiki/features/guides/models/guide_markdown_catalog.dart';
import 'package:ctnh_wiki/features/guides/models/guide_markdown_document.dart';
import 'package:flutter/services.dart';

class GuideMarkdownRepository {
  const GuideMarkdownRepository();

  static const _registryPath = 'assets/docs/guides/index.json';

  Future<GuideMarkdownCatalog> loadCatalog() async {
    final registryRaw = await rootBundle.loadString(_registryPath);
    final registryJson = jsonDecode(registryRaw);
    if (registryJson is! Map<String, dynamic>) {
      throw const FormatException('攻略教程注册表格式无效。');
    }

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final registeredAssets = manifest.listAssets().toSet();

    final rawDocuments = registryJson['documents'];
    if (rawDocuments is! List) {
      throw const FormatException('攻略教程注册表缺少 documents 列表。');
    }

    final documents = <GuideMarkdownDocument>[];
    for (final item in rawDocuments) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('攻略教程注册项格式无效。');
      }

      final assetPath = (item['assetPath'] as String?)?.trim() ?? '';
      if (assetPath.isEmpty) {
        throw const FormatException('攻略教程注册项缺少 assetPath。');
      }
      if (!registeredAssets.contains(assetPath)) {
        throw StateError('攻略教程资源未注册或不存在：$assetPath');
      }

      final markdownRaw = await rootBundle.loadString(assetPath);
      final markdownBody = _stripFrontMatter(markdownRaw);
      final fileName = assetPath.split('/').last;
      final slug = ((item['slug'] as String?)?.trim().isNotEmpty ?? false)
          ? (item['slug'] as String).trim()
          : fileName.replaceAll(RegExp(r'\.md$', caseSensitive: false), '');

      final title = (item['title'] as String?)?.trim();
      if (title == null || title.isEmpty) {
        throw StateError('攻略教程 "$assetPath" 缺少 title。');
      }

      documents.add(
        GuideMarkdownDocument(
          assetPath: assetPath,
          fileName: fileName,
          slug: slug,
          title: title,
          summary: ((item['summary'] as String?) ?? '').trim(),
          order: _parseOrder(item['order']),
          tags: _parseTags(item['tags']),
          markdownBody: markdownBody,
        ),
      );
    }

    documents.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return a.title.compareTo(b.title);
    });

    return GuideMarkdownCatalog(documents: documents);
  }

  String _stripFrontMatter(String raw) {
    var body = raw.trim();
    if (!(body.startsWith('---\n') || body.startsWith('---\r\n'))) {
      return body;
    }

    final lines = const LineSplitter().convert(body);
    final closingIndex = lines.indexOf('---', 1);
    if (closingIndex <= 0) {
      return body;
    }

    return lines.sublist(closingIndex + 1).join('\n').trim();
  }

  List<String> _parseTags(Object? rawTags) {
    if (rawTags is! List) {
      return const [];
    }

    final tags =
        rawTags
            .whereType<String>()
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return tags;
  }

  int _parseOrder(Object? rawOrder) {
    if (rawOrder is int) {
      return rawOrder;
    }
    if (rawOrder is String) {
      return int.tryParse(rawOrder.trim()) ?? 9999;
    }
    return 9999;
  }
}
