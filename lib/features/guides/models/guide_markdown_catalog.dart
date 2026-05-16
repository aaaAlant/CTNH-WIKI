import 'package:ctnh_wiki/features/guides/models/guide_markdown_document.dart';

class GuideMarkdownCatalog {
  const GuideMarkdownCatalog({required this.documents});

  final List<GuideMarkdownDocument> documents;

  List<String> get allTags {
    final tags = <String>{};
    for (final document in documents) {
      tags.addAll(document.tags);
    }
    final sortedTags = tags.toList()..sort();
    return sortedTags;
  }
}
