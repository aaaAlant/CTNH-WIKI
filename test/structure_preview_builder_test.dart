import 'package:ctnh_wiki/features/structure_preview/controllers/structure_layer_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/data/structure_preview_catalog.dart';
import 'package:ctnh_wiki/features/structure_preview/data/structure_texture_manifest.g.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_block_candidate.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/services/multiblock_pattern_builder.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_scene_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pattern builder preserves dimensions, coordinates and candidates', () {
    const candidate = StructureBlockCandidate(
      id: 'test:alternative',
      blockId: 'test:alternative',
      displayName: 'Alternative',
      description: 'Candidate block',
      category: StructurePartCategory.casing,
      state: StructurePartState.optional,
      partIds: [],
    );

    final result = MultiblockPatternBuilder(
      aisles: const [
        ['AB', 'BA'],
        ['BA', 'AB'],
      ],
      symbols: {
        'A': const MultiblockPatternSymbolDefinition.part(
          blockId: 'test:casing',
          displayName: 'Casing',
          description: 'Casing',
          category: StructurePartCategory.casing,
          candidates: [candidate],
        ),
        'B': const MultiblockPatternSymbolDefinition.part(
          blockId: 'test:controller',
          displayName: 'Controller',
          description: 'Controller',
          category: StructurePartCategory.controller,
        ),
      },
    ).build();

    expect(result.width, 2);
    expect(result.height, 2);
    expect(result.depth, 2);
    expect(result.parts, hasLength(8));
    expect(result.parts.first.tags, contains('grid:0-0-0'));
    expect(result.parts.where((part) => part.blockId == 'test:casing').first.candidates, hasLength(1));
  });

  test('scene builder resolves module texture assets for every catalog entry', () {
    const sceneBuilder = StructurePreviewSceneBuilder();
    for (final entry in structurePreviewCatalog) {
      final result = sceneBuilder.build(entry.definition);
      expect(
        result.scene.primitives.any(
          (primitive) =>
              primitive.material.faceTextures?.hasAnyTexture == true ||
              primitive.material.mapAsset != null,
        ),
        isTrue,
        reason: '${entry.id} should resolve at least one texture asset',
      );
    }
  });

  test('catalog uses static cameras and source machine overlays', () {
    const expectedOverlays = <String, String>{
      'ctnhcore:primitive-blast-furnace': 'steam_oven_overlay_front.png',
      'ctnhenergy:power-substation': 'power_substation_overlay_front.png',
      'ctnhbio:great-flesh': 'assembly_line_overlay_front.png',
      'ctnhmana:gem-inlay': 'manamachine_overlay_front.png',
      'ctnhastral:rocket-assembly-platform': 'large_steam_turbine_overlay_front.png',
      'ctpp:smashing-factory': 'large_chemical_reactor_overlay_front.png',
    };
    const sceneBuilder = StructurePreviewSceneBuilder();

    for (final entry in structurePreviewCatalog) {
      expect(entry.definition.camera.autoRotate, isFalse);
      final result = sceneBuilder.build(entry.definition);
      final assetPaths = <String>{
        for (final primitive in result.scene.primitives)
          if (primitive.material.mapAsset != null)
            primitive.material.mapAsset!,
        for (final primitive in result.scene.primitives)
          for (final path in <String?>[
            primitive.material.faceTextures?.all,
            primitive.material.faceTextures?.right,
            primitive.material.faceTextures?.left,
            primitive.material.faceTextures?.top,
            primitive.material.faceTextures?.bottom,
            primitive.material.faceTextures?.front,
            primitive.material.faceTextures?.back,
          ].whereType<String>())
            path,
      };
      final expectedOverlay = expectedOverlays[entry.id];
      if (expectedOverlay != null) {
        expect(
          assetPaths.any((path) => path.endsWith(expectedOverlay)),
          isTrue,
          reason: '${entry.id} should use its source machine overlay',
        );
      }
    }
  });

  test('generated Forge manifest includes texture-only and OBJ resources', () {
  final primitiveBricks = structureTextureManifest['ctnhcore:machine_primitive_bricks'];
  expect(primitiveBricks, isNotNull);
  expect(primitiveBricks?.textures['all'], contains('machine_primitive_bricks'));
  final crushingWheel = structureTextureManifest['create:crushing_wheel'];
  expect(crushingWheel, isNotNull);
  expect(crushingWheel?.obj, endsWith('.obj'));
  expect(crushingWheel?.base, contains('crushing_wheel_plates'));
  final gemTable = structureTextureManifest['apotheosis:gem_cutting_table'];
  expect(gemTable?.modelData, contains('elements'));
  final battery = structureTextureManifest['gtceu:substation_battery'];
  expect(battery, isNotNull);
  expect(battery?.base, contains('ev_lapotronic_side'));
  final furnace = structureTextureManifest['ctnhcore:industrial_primitive_blast_furnace'];
  expect(furnace?.front, contains('steam_oven_overlay_front'));
});

test('generated Forge manifest omits void placeholder faces', () {
    for (final definition in structureTextureManifest.values) {
      expect(
        definition.textures.values.any((path) => path.contains('_void')),
        isFalse,
        reason: definition.base + ' must not keep GT void placeholder faces',
      );
      expect(definition.connection?.contains('_void'), isNot(true));
    }
  });

  test('generated Forge manifest preserves face and connection relations', () {
    final mana = structureTextureManifest['ctnhmana:gem_inlay']!;
    expect(mana.textures['all'], isNotNull);
    expect(mana.textures['overlay_front'], isNotNull);
    expect(mana.connection, isNotNull);

    final table = structureTextureManifest['apotheosis:gem_cutting_table']!;
    expect(table.textures['all'], isNotNull);
    expect(table.textures['side'], isNotNull);
    expect(table.textures['particle'], isNotNull);
    expect(table.model, isNotNull);
    expect(table.blockstate, isNotNull);
  });

  test('layer controller exposes ALL and selected layer ids', () {
    final result = MultiblockPatternBuilder(
      aisles: const [
        ['A'],
        ['A'],
      ],
      symbols: const {
        'A': MultiblockPatternSymbolDefinition.part(
          blockId: 'test:casing',
          displayName: 'Casing',
          description: 'Casing',
          category: StructurePartCategory.casing,
        ),
      },
    ).build();
    final controller = StructureLayerController(parts: result.parts);
    addTearDown(controller.dispose);

    expect(controller.isAllSelected, isTrue);
    expect(controller.visiblePartIds, isNull);
    controller.selectLayer(1);
    expect(controller.visiblePartIds, isNotNull);
    expect(controller.visiblePartIds, hasLength(2));
  });

  test('texture resolver keeps manifest textures untinted', () {
    const builder = StructurePreviewSceneBuilder();
    const tinted = StructureMaterialStyle(
      color: 0xFF8BC6C5,
      opacity: 0.72,
    );
    final resolved = builder.textureResolver.resolve(
      tinted,
      'create:andesite_casing',
      'body',
    );
    expect(resolved.color, 0xFFFFFFFF);
    expect(
      resolved.mapAsset ?? resolved.faceTextures?.all,
      contains('andesite_casing'),
    );
    final missing = builder.textureResolver.resolve(
      tinted,
      'test:missing-block',
      'body',
    );
    expect(missing.color, tinted.color);
  });
}
