class ModCatalogDocument {
  const ModCatalogDocument({
    required this.taxonomyVersion,
    required this.source,
    required this.summaryCounts,
    required this.mods,
  });

  final String taxonomyVersion;
  final String source;
  final Map<String, int> summaryCounts;
  final List<ModCatalogEntry> mods;
}

class ModCatalogEntry {
  const ModCatalogEntry({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.modId,
    required this.loader,
    required this.primaryCategory,
    required this.subcategories,
    required this.tags,
    this.gameVersion,
    this.modVersion,
    this.note,
    this.description,
  });

  final String id;
  final String displayName;
  final String fileName;
  final String modId;
  final String loader;
  final String primaryCategory;
  final List<String> subcategories;
  final List<String> tags;
  final String? gameVersion;
  final String? modVersion;
  final String? note;
  final String? description;

  factory ModCatalogEntry.fromJson(Map<String, dynamic> json) {
    return ModCatalogEntry(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      modId: json['modId'] as String? ?? '',
      loader: json['loader'] as String? ?? '未标注',
      primaryCategory: json['primaryCategory'] as String? ?? '未分类',
      subcategories: (json['subcategories'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      gameVersion: json['gameVersion'] as String?,
      modVersion: json['modVersion'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'fileName': fileName,
      'modId': modId,
      'loader': loader,
      'primaryCategory': primaryCategory,
      'subcategories': subcategories,
      'tags': tags,
      'gameVersion': gameVersion,
      'modVersion': modVersion,
      'note': note,
      'description': description,
    };
  }

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return displayName.toLowerCase().contains(normalized) ||
        fileName.toLowerCase().contains(normalized) ||
        modId.toLowerCase().contains(normalized) ||
        loader.toLowerCase().contains(normalized) ||
        primaryCategory.toLowerCase().contains(normalized) ||
        subcategories.any((item) => item.toLowerCase().contains(normalized)) ||
        tags.any((item) => item.toLowerCase().contains(normalized)) ||
        (gameVersion?.toLowerCase().contains(normalized) ?? false) ||
        (modVersion?.toLowerCase().contains(normalized) ?? false) ||
        (description?.toLowerCase().contains(normalized) ?? false) ||
        (note?.toLowerCase().contains(normalized) ?? false);
  }
}
