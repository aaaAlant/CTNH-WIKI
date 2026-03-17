class QuestAssetIndex {
  const QuestAssetIndex({required this.resources});

  factory QuestAssetIndex.fromJson(Map<String, dynamic> json) {
    final rawResources = json['resources'] as Map<String, dynamic>? ?? const {};
    return QuestAssetIndex(
      resources: rawResources.map(
        (key, value) => MapEntry(
          key,
          QuestAssetResource.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  final Map<String, QuestAssetResource> resources;

  QuestAssetResource? lookup(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    return resources[id];
  }

  QuestAssetResource? lookupFirst(Iterable<String?> candidates) {
    for (final candidate in candidates) {
      final resource = lookup(candidate);
      if (resource != null) {
        return resource;
      }
    }
    return null;
  }
}

class QuestAssetResource {
  const QuestAssetResource({
    required this.id,
    required this.namespace,
    required this.path,
    required this.kind,
    required this.displayName,
    required this.localizedNames,
    this.iconAssetPath,
    this.iconTextureId,
    this.iconResolution,
  });

  factory QuestAssetResource.fromJson(Map<String, dynamic> json) {
    return QuestAssetResource(
      id: json['id'] as String? ?? '',
      namespace: json['namespace'] as String? ?? '',
      path: json['path'] as String? ?? '',
      kind: json['kind'] as String? ?? 'unknown',
      displayName: json['displayName'] as String? ?? '',
      localizedNames: (json['localizedNames'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value.toString())),
      iconAssetPath: json['iconAssetPath'] as String?,
      iconTextureId: json['iconTextureId'] as String?,
      iconResolution: json['iconResolution'] as String?,
    );
  }

  final String id;
  final String namespace;
  final String path;
  final String kind;
  final String displayName;
  final Map<String, String> localizedNames;
  final String? iconAssetPath;
  final String? iconTextureId;
  final String? iconResolution;

  bool get hasIcon => iconAssetPath != null && iconAssetPath!.isNotEmpty;

  bool get hasDisplayName => displayName.isNotEmpty;
}
