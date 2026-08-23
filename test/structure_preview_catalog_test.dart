import 'package:ctnh_wiki/features/structure_preview/data/structure_preview_catalog.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog covers current CTNH submodules and pages', () {
    final moduleKeys = structurePreviewCatalog
        .map((entry) => entry.moduleKey)
        .toSet();
    expect(
      moduleKeys,
      containsAll(<String>[
        'ctnhcore',
        'ctnhenergy',
        'ctnhmana',
        'ctnhbio',
        'ctnhastral',
        'ctpp',
      ]),
    );
    expect(structurePreviewCatalog, hasLength(greaterThanOrEqualTo(6)));

    final powerSubstation = structurePreviewCatalog.firstWhere(
      (entry) => entry.id == 'ctnhenergy:power-substation',
    );
    expect(powerSubstation.allPages, hasLength(2));
    expect(
      powerSubstation.definition.parts.any(
        (part) => part.candidates.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('manual Core catalog entries preserve source dimensions', () {
    const coreDimensions = <String, List<int>>{
      'ctnhcore:underfloor-heating-system': [16, 1, 16],
      'ctnhcore:astronomical-observatory': [9, 9, 9],
      'ctnhcore:photovoltaic-power-station-energetic': [9, 7, 9],
      'ctnhcore:slaughter-house': [5, 7, 5],
      'ctnhcore:coke-tower': [5, 17, 5],
      'ctnhcore:bedrock-drilling-rigs': [7, 8, 7],
      'ctnhcore:plasma-condenser': [13, 3, 13],
      'ctnhcore:meadow': [11, 6, 11],
      'ctnhcore:fermenting-tank': [5, 7, 5],
      'ctnhcore:digestion-tank': [5, 3, 3],
    };
    for (final entry in structurePreviewCatalog.where(
      (entry) => coreDimensions.containsKey(entry.id),
    )) {
      final parts = entry.definition.parts;
      final xs = parts.map((part) => part.position.x).toList();
      final ys = parts.map((part) => part.position.y).toList();
      final zs = parts.map((part) => part.position.z).toList();
      final actual = [
        (xs.reduce((a, b) => a > b ? a : b) -
                xs.reduce((a, b) => a < b ? a : b) +
                1)
            .round(),
        (ys.reduce((a, b) => a > b ? a : b) -
                ys.reduce((a, b) => a < b ? a : b) +
                1)
            .round(),
        (zs.reduce((a, b) => a > b ? a : b) -
                zs.reduce((a, b) => a < b ? a : b) +
                1)
            .round(),
      ];
      expect(actual, coreDimensions[entry.id]);
      expect(entry.sourceRef, contains('MultiblocksA.'));
      expect(
        parts.any((part) => part.category == StructurePartCategory.controller),
        isTrue,
      );
    }
  });

  test('metal girder preview uses the vertical pole model', () {
    final girderVisuals = <StructurePartVisual>[
      for (final entry in structurePreviewCatalog)
        for (final part in entry.definition.parts)
          for (final visual in part.visuals)
            if (visual.material.objTextures['1']?.endsWith('girder_pole.png') ??
                false)
              visual,
    ];
    expect(girderVisuals, isNotEmpty);
    expect(girderVisuals.first.material.modelData, contains('"from":[4,0,4]'));
  });

  test('meadow uses real natural textures and a fence model', () {
    final meadow = structurePreviewCatalog.firstWhere(
      (entry) => entry.id == 'ctnhcore:meadow',
    );
    final grass = meadow.definition.parts
        .firstWhere((part) => part.blockId == 'minecraft:grass_block')
        .visuals
        .first;
    final fence = meadow.definition.parts
        .firstWhere((part) => part.blockId == 'minecraft:oak_fence')
        .visuals
        .first;
    expect(grass.material.faceTextures?.top, endsWith('grass_block_top.png'));
    expect(fence.material.modelData, contains('"from":[6,0,6]'));
    expect(fence.material.objTextures['texture'], endsWith('oak_planks.png'));
  });

  test('non-air any slots remain omitted from the preview', () {
    for (final entry in structurePreviewCatalog) {
      expect(
        entry.definition.parts.any((part) => part.tags.contains('any')),
        isFalse,
        reason:
            '${entry.id} must hide Predicates.any slots unless air is explicit',
      );
    }
  });

  test('production catalog copy avoids development jargon', () {
    for (final entry in structurePreviewCatalog) {
      final texts = <String>[
        entry.definition.metadata.summary,
        entry.definition.metadata.description,
        for (final part in entry.definition.parts)
          '${part.displayName} ${part.description}',
        for (final part in entry.definition.parts)
          for (final candidate in part.candidates)
            '${candidate.displayName} ${candidate.description}',
      ];
      for (final text in texts) {
        expect(text, isNot(contains('候选')));
        expect(text, isNot(contains('运行时')));
        expect(text, isNot(contains('示例')));
        expect(text, isNot(contains('Predicates')));
        expect(text, isNot(contains('CTNHPartAbility')));
      }
    }
  });

  test(
    'smashing factory replacement slots do not advertise energy hatches',
    () {
      final smashing = structurePreviewCatalog.firstWhere(
        (entry) => entry.id == 'ctpp:smashing-factory',
      );
      final replacementCandidates = smashing.definition.parts
          .where((part) => part.id.startsWith('smashing-ability'))
          .expand((part) => part.candidates)
          .toList();

      expect(
        replacementCandidates.map((candidate) => candidate.blockId),
        isNot(
          anyOf(
            contains('gtceu:energy_input_hatch'),
            contains('gtceu:energy_output_hatch'),
          ),
        ),
      );
      expect(
        replacementCandidates.map((candidate) => candidate.blockId),
        containsAll(<String>[
          'ctpp:kinetic_input_box',
          'ctpp:mechanical_upgrade_bus',
          'gtceu:item_import_bus',
          'gtceu:item_export_bus',
        ]),
      );
    },
  );
}
