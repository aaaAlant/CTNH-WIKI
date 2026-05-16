class GuideMarkdownDocument {
  const GuideMarkdownDocument({
    required this.assetPath,
    required this.fileName,
    required this.slug,
    required this.title,
    required this.summary,
    required this.order,
    required this.tags,
    required this.markdownBody,
  });

  final String assetPath;
  final String fileName;
  final String slug;
  final String title;
  final String summary;
  final int order;
  final List<String> tags;
  final String markdownBody;
}
