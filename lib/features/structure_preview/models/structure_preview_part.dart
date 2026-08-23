import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';

enum StructurePartCategory {
  foundation,
  casing,
  power,
  machine,
  controller,
  display,
  transport,
  decoration,
}

enum StructurePartState { required, optional, previewOnly }

enum StructureFacing { north, south, east, west, up, down }

class StructurePartVisual {
  const StructurePartVisual.cuboid({
    required this.id,
    required this.material,
    required this.size,
    this.localOffset = const StructureVector3(0, 0, 0),
    this.rotation = const StructureRotation.zero(),
  }) : type = StructurePrimitiveType.cuboid,
       radiusTop = null,
       radiusBottom = null,
       height = null,
       radialSegments = 0;

  const StructurePartVisual.cylinder({
    required this.id,
    required this.material,
    required this.radiusTop,
    required this.radiusBottom,
    required this.height,
    this.localOffset = const StructureVector3(0, 0, 0),
    this.rotation = const StructureRotation.zero(),
    this.radialSegments = 18,
  }) : type = StructurePrimitiveType.cylinder,
       size = null;

  final String id;
  final StructurePrimitiveType type;
  final StructureVector3 localOffset;
  final StructureRotation rotation;
  final StructureVector3? size;
  final double? radiusTop;
  final double? radiusBottom;
  final double? height;
  final int radialSegments;
  final StructureMaterialStyle material;
}

class StructurePreviewPart {
  const StructurePreviewPart({
    required this.id,
    required this.blockId,
    required this.displayName,
    required this.description,
    required this.category,
    required this.position,
    this.visuals = const [],
    this.rotation = const StructureRotation.zero(),
    this.facing = StructureFacing.north,
    this.state = StructurePartState.required,
    this.tags = const [],
    this.candidates = const [],
  });

  final String id;
  final String blockId;
  final String displayName;
  final String description;
  final StructurePartCategory category;
  final StructureVector3 position;
  final StructureRotation rotation;
  final StructureFacing facing;
  final StructurePartState state;
  final List<String> tags;
  final List<StructureBlockCandidate> candidates;
  final List<StructurePartVisual> visuals;
}

/// A block type used by one or more positions in a structure definition.
class StructureBlockCandidate {
  const StructureBlockCandidate({
    required this.id,
    required this.blockId,
    required this.displayName,
    required this.description,
    required this.category,
    required this.state,
    required this.partIds,
    this.tags = const [],
  });

  final String id;
  final String blockId;
  final String displayName;
  final String description;
  final StructurePartCategory category;
  final StructurePartState state;
  final List<String> partIds;
  final List<String> tags;

  int get count => partIds.length;

  bool containsPart(String partId) => partIds.contains(partId);

  StructureBlockCandidate forPart(String partId) {
    if (containsPart(partId)) {
      return this;
    }
    return StructureBlockCandidate(
      id: id,
      blockId: blockId,
      displayName: displayName,
      description: description,
      category: category,
      state: state,
      partIds: [...partIds, partId],
      tags: tags,
    );
  }
}

/// A stable group of block candidates for a pattern slot or category.
class StructureBlockCandidateGroup {
  const StructureBlockCandidateGroup({
    required this.id,
    required this.label,
    required this.candidates,
  });

  final String id;
  final String label;
  final List<StructureBlockCandidate> candidates;

  int get count => candidates.length;

  int get partCount => candidates.fold(
    0,
    (total, candidate) => total + candidate.count,
  );

  List<String> get candidateIds => List.unmodifiable(
    candidates.map((candidate) => candidate.id),
  );

  Set<String> get partIds => {
    for (final candidate in candidates) ...candidate.partIds,
  };

  bool containsCandidate(String candidateId) {
    return candidates.any((candidate) => candidate.id == candidateId);
  }
}
