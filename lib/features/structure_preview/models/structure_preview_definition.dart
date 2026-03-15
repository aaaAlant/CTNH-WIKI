import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_metadata.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_step.dart';

class StructurePreviewStage {
  const StructurePreviewStage({
    this.backgroundColor = 0xFF2A3139,
    this.ambientLightColor = 0xFFF4E7CB,
    this.ambientLightIntensity = 1.8,
    this.keyLightColor = 0xFFFFF3DA,
    this.keyLightIntensity = 2.6,
    this.keyLightPosition = const StructureVector3(5.5, 8, 5),
    this.fillLightColor = 0xFF8AA8C4,
    this.fillLightIntensity = 1.4,
    this.fillLightPosition = const StructureVector3(-5.5, 4, -3.5),
  });

  final int backgroundColor;
  final int ambientLightColor;
  final double ambientLightIntensity;
  final int keyLightColor;
  final double keyLightIntensity;
  final StructureVector3 keyLightPosition;
  final int fillLightColor;
  final double fillLightIntensity;
  final StructureVector3 fillLightPosition;
}

class StructurePreviewDefinition {
  const StructurePreviewDefinition({
    required this.id,
    required this.metadata,
    required this.camera,
    required this.parts,
    this.steps = const [],
    this.stage = const StructurePreviewStage(),
  });

  final String id;
  final StructurePreviewMetadata metadata;
  final StructureCameraConfig camera;
  final List<StructurePreviewPart> parts;
  final List<StructurePreviewStep> steps;
  final StructurePreviewStage stage;

  StructurePreviewPart? partById(String? id) {
    if (id == null) {
      return null;
    }

    for (final part in parts) {
      if (part.id == id) {
        return part;
      }
    }

    return null;
  }
}
