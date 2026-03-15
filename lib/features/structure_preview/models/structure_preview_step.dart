class StructurePreviewStep {
  const StructurePreviewStep({
    required this.id,
    required this.title,
    required this.description,
    required this.revealedPartIds,
    this.focusedPartIds = const [],
  });

  final String id;
  final String title;
  final String description;
  final List<String> revealedPartIds;
  final List<String> focusedPartIds;
}
