enum StructurePreviewModule { tech, magic, adventure, shared }

enum StructurePreviewStatus { draft, inProgress, published }

class StructureVersionRange {
  const StructureVersionRange({this.minVersion, this.maxVersion, this.note});

  final String? minVersion;
  final String? maxVersion;
  final String? note;
}

class StructurePreviewMetadata {
  const StructurePreviewMetadata({
    required this.title,
    required this.summary,
    required this.description,
    required this.module,
    this.status = StructurePreviewStatus.draft,
    this.tags = const [],
    this.versionRange,
    this.source,
  });

  final String title;
  final String summary;
  final String description;
  final StructurePreviewModule module;
  final StructurePreviewStatus status;
  final List<String> tags;
  final StructureVersionRange? versionRange;
  final String? source;
}
