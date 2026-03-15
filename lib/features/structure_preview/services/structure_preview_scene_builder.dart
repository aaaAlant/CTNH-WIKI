import 'package:ctnh_wiki/features/structure_preview/data/structure_block_registry.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';

class StructurePreviewSceneBuildResult {
  const StructurePreviewSceneBuildResult({
    required this.scene,
    required this.primitivePartMap,
  });

  final StructurePreviewSceneData scene;
  final Map<String, String> primitivePartMap;
}

class StructurePreviewSceneBuilder {
  const StructurePreviewSceneBuilder({
    this.blockRegistry = structureBlockRegistry,
  });

  final StructureBlockRegistry blockRegistry;

  StructurePreviewSceneBuildResult build(
    StructurePreviewDefinition definition, {
    Set<String>? visiblePartIds,
  }) {
    final primitives = <StructurePrimitive>[];
    final primitivePartMap = <String, String>{};

    for (final part in definition.parts) {
      if (visiblePartIds != null && !visiblePartIds.contains(part.id)) {
        continue;
      }

      final visuals = part.visuals.isNotEmpty
          ? part.visuals
          : (blockRegistry.find(part.blockId)?.visuals ??
                const <StructurePartVisual>[]);

      for (final visual in visuals) {
        final primitive = _buildPrimitive(part, visual);
        primitives.add(primitive);
        primitivePartMap[primitive.id] = part.id;
      }
    }

    return StructurePreviewSceneBuildResult(
      scene: StructurePreviewSceneData(
        id: definition.id,
        camera: definition.camera,
        primitives: primitives,
        backgroundColor: definition.stage.backgroundColor,
        ambientLightColor: definition.stage.ambientLightColor,
        ambientLightIntensity: definition.stage.ambientLightIntensity,
        keyLightColor: definition.stage.keyLightColor,
        keyLightIntensity: definition.stage.keyLightIntensity,
        keyLightPosition: definition.stage.keyLightPosition,
        fillLightColor: definition.stage.fillLightColor,
        fillLightIntensity: definition.stage.fillLightIntensity,
        fillLightPosition: definition.stage.fillLightPosition,
      ),
      primitivePartMap: primitivePartMap,
    );
  }

  StructurePrimitive _buildPrimitive(
    StructurePreviewPart part,
    StructurePartVisual visual,
  ) {
    final position = StructureVector3(
      part.position.x + visual.localOffset.x,
      part.position.y + visual.localOffset.y,
      part.position.z + visual.localOffset.z,
    );
    final rotation = StructureRotation(
      part.rotation.x + visual.rotation.x,
      part.rotation.y + visual.rotation.y,
      part.rotation.z + visual.rotation.z,
    );

    return switch (visual.type) {
      StructurePrimitiveType.cuboid => StructurePrimitive.cuboid(
        id: '${part.id}/${visual.id}',
        position: position,
        size: visual.size!,
        rotation: rotation,
        material: visual.material,
      ),
      StructurePrimitiveType.cylinder => StructurePrimitive.cylinder(
        id: '${part.id}/${visual.id}',
        position: position,
        radiusTop: visual.radiusTop!,
        radiusBottom: visual.radiusBottom!,
        height: visual.height!,
        radialSegments: visual.radialSegments,
        rotation: rotation,
        material: visual.material,
      ),
    };
  }
}
