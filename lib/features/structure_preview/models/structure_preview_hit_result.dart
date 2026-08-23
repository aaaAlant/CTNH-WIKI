import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';

class StructurePreviewHitResult {
  const StructurePreviewHitResult({
    required this.partId,
    required this.primitiveId,
    this.layerId,
    this.gridPosition,
  });

  final String partId;
  final String primitiveId;
  final String? layerId;
  final StructureVector3? gridPosition;
}
