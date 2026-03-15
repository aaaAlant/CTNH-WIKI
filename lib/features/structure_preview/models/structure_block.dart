import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';

class StructureBlockDefinition {
  const StructureBlockDefinition({
    required this.blockId,
    required this.visuals,
    this.displayName,
  });

  final String blockId;
  final String? displayName;
  final List<StructurePartVisual> visuals;
}
