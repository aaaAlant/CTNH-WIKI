import 'dart:convert';

import 'package:ctnh_wiki/features/guides/models/guide_markdown_document.dart';
import 'package:flutter/services.dart';

class GuideMarkdownRepository {
  const GuideMarkdownRepository();

  static const _assetPrefix = 'assets/docs/guides/';

  Future<List<GuideMarkdownDocument>> loadDocuments() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final markdownAssets =
        manifest
            .listAssets()
            .where(
              (path) =>
                  path.startsWith(_assetPrefix) &&
                  path.toLowerCase().endsWith('.md'),
            )
            .toList()
          ..sort();

    final documents = <GuideMarkdownDocument>[];
    for (final assetPath in markdownAssets) {
      final raw = await rootBundle.loadString(assetPath);
      documents.add(_parseDocument(assetPath, raw));
    }

    documents.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return a.fileName.compareTo(b.fileName);
    });

    return documents;
  }

  GuideMarkdownDocument _parseDocument(String assetPath, String raw) {
    final fileName = assetPath.split('/').last;
    final slug = fileName.replaceAll(
      RegExp(r'\.md$', caseSensitive: false),
      '',
    );

    final metadata = <String, String>{};
    var body = raw.trim();

    if (body.startsWith('---\n') || body.startsWith('---\r\n')) {
      final lines = const LineSplitter().convert(body);
      final closingIndex = lines.indexOf('---', 1);
      if (closingIndex > 0) {
        for (final line in lines.sublist(1, closingIndex)) {
          final separatorIndex = line.indexOf(':');
          if (separatorIndex <= 0) {
            continue;
          }
          final key = line.substring(0, separatorIndex).trim();
          final value = line.substring(separatorIndex + 1).trim();
          metadata[key] = value;
        }
        body = lines.sublist(closingIndex + 1).join('\n').trim();
      }
    }

    final title = metadata['title']?.trim().isNotEmpty == true
        ? metadata['title']!.trim()
        : _extractFirstHeading(body) ?? _titleFromFileName(fileName);

    final summary = metadata['summary']?.trim().isNotEmpty == true
        ? metadata['summary']!.trim()
        : _extractSummary(body);

    final order = int.tryParse(metadata['order'] ?? '') ?? 9999;

    return GuideMarkdownDocument(
      assetPath: assetPath,
      fileName: fileName,
      slug: slug,
      title: title,
      summary: summary,
      order: order,
      markdownBody: body,
    );
  }

  String? _extractFirstHeading(String body) {
    for (final line in const LineSplitter().convert(body)) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        return trimmed.substring(2).trim();
      }
    }
    return null;
  }

  String _extractSummary(String body) {
    for (final line in const LineSplitter().convert(body)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      return trimmed;
    }
    return '暂无摘要。';
  }

  String _titleFromFileName(String fileName) {
    final withoutExtension = fileName.replaceAll(
      RegExp(r'\.md$', caseSensitive: false),
      '',
    );
    return withoutExtension
        .replaceFirst(RegExp(r'^\d+[-_ ]*'), '')
        .replaceAll('-', ' ')
        .trim();
  }
}
