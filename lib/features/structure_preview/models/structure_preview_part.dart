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
    required this.visuals,
    this.rotation = const StructureRotation.zero(),
    this.facing = StructureFacing.north,
    this.state = StructurePartState.required,
    this.tags = const [],
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
  final List<StructurePartVisual> visuals;
}
