import 'package:ctnh_wiki/features/structure_preview/data/structure_block_registry.dart';
import 'package:ctnh_wiki/features/structure_preview/data/structure_texture_resolver.dart';
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
    this.textureResolver = structureForgeTextureResolver,
  });

  final StructureBlockRegistry blockRegistry;
  final StructureForgeTextureResolver textureResolver;

  StructurePreviewSceneBuildResult build(
    StructurePreviewDefinition definition, {
    Set<String>? visiblePartIds,
  }) {
    final primitives = <StructurePrimitive>[];
    final primitivePartMap = <String, String>{};
    final connectedPartIds = _connectedPartIds(definition.parts);

    for (final part in definition.parts) {
      if (visiblePartIds != null && !visiblePartIds.contains(part.id)) {
        continue;
      }

      final visuals = part.visuals.isNotEmpty
          ? part.visuals
          : (blockRegistry.find(part.blockId)?.visuals ??
                const <StructurePartVisual>[]);

      for (final visual in visuals) {
        final primitive = _buildPrimitive(
          part,
          visual,
          connectedPartIds.contains(part.id),
        );
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
    bool hasConnectedNeighbor,
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
    final material = textureResolver.resolve(
      visual.material,
      part.blockId,
      visual.id,
      connected: hasConnectedNeighbor,
    );

    return switch (visual.type) {
      StructurePrimitiveType.cuboid => StructurePrimitive.cuboid(
        id: '${part.id}/${visual.id}',
        position: position,
        size: visual.size!,
        rotation: rotation,
        material: material,
        partId: part.id,
        layerId: 'layer-' + part.position.y.round().toString(),
        gridPosition: part.position,
      ),
      StructurePrimitiveType.cylinder => StructurePrimitive.cylinder(
        id: '${part.id}/${visual.id}',
        position: position,
        radiusTop: visual.radiusTop!,
        radiusBottom: visual.radiusBottom!,
        height: visual.height!,
        radialSegments: visual.radialSegments,
        rotation: rotation,
        material: material,
        partId: part.id,
        layerId: 'layer-' + part.position.y.round().toString(),
        gridPosition: part.position,
      ),
    };
  }

  Set<String> _connectedPartIds(List<StructurePreviewPart> parts) {
    final byPosition = <String, List<StructurePreviewPart>>{};
    for (final part in parts) {
      final key =
          '${part.position.x.round()}:${part.position.y.round()}:${part.position.z.round()}';
      byPosition.putIfAbsent(key, () => <StructurePreviewPart>[]).add(part);
    }

    final connected = <String>{};
    const neighbors = <List<int>>[
      [1, 0, 0],
      [-1, 0, 0],
      [0, 1, 0],
      [0, -1, 0],
      [0, 0, 1],
      [0, 0, -1],
    ];
    for (final part in parts) {
      for (final offset in neighbors) {
        final key = '${part.position.x.round() + offset[0]}:${part.position.y.round() + offset[1]}:${part.position.z.round() + offset[2]}';
        final matches = byPosition[key];
        if (matches != null &&
            matches.any((neighbor) => neighbor.blockId == part.blockId)) {
          connected.add(part.id);
          break;
        }
      }
    }
    return connected;
  }
}
