import 'package:ctnh_wiki/features/structure_preview/models/structure_block_candidate.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';

class MultiblockPatternSymbolDefinition {
  const MultiblockPatternSymbolDefinition.part({
    required this.blockId,
    required this.displayName,
    required this.description,
    required this.category,
    this.partIdPrefix,
    this.rotation = const StructureRotation.zero(),
    this.facing = StructureFacing.north,
    this.state = StructurePartState.required,
    this.tags = const [],
    this.candidates = const [],
    this.visuals = const [],
  }) : skip = false;

  const MultiblockPatternSymbolDefinition.skip()
    : skip = true,
      blockId = '',
      displayName = '',
      description = '',
      category = StructurePartCategory.decoration,
      partIdPrefix = null,
      rotation = const StructureRotation.zero(),
      facing = StructureFacing.north,
      state = StructurePartState.required,
      tags = const [],
      candidates = const [],
      visuals = const [];

  final bool skip;
  final String blockId;
  final String displayName;
  final String description;
  final StructurePartCategory category;
  final String? partIdPrefix;
  final StructureRotation rotation;
  final StructureFacing facing;
  final StructurePartState state;
  final List<String> tags;
  final List<StructureBlockCandidate> candidates;
  final List<StructurePartVisual> visuals;
}

class MultiblockPatternBuildResult {
  const MultiblockPatternBuildResult({
    required this.parts,
    required this.symbolPartIds,
    required this.width,
    required this.height,
    required this.depth,
  });

  final List<StructurePreviewPart> parts;
  final Map<String, List<String>> symbolPartIds;
  final int width;
  final int height;
  final int depth;

  List<String> partIdsForSymbol(String symbol) {
    return symbolPartIds[symbol] ?? const [];
  }
}

class MultiblockPatternBuilder {
  const MultiblockPatternBuilder({
    required this.aisles,
    required this.symbols,
    this.rowsFromTopToBottom = false,
    this.aislesFromBackToFront = true,
    this.origin = const StructureVector3(0, 0, 0),
    this.blockSpacing = 1,
  });

  final List<List<String>> aisles;
  final Map<String, MultiblockPatternSymbolDefinition> symbols;
  final bool rowsFromTopToBottom;
  final bool aislesFromBackToFront;
  final StructureVector3 origin;
  final double blockSpacing;

  MultiblockPatternBuildResult build() {
    if (aisles.isEmpty) {
      return const MultiblockPatternBuildResult(
        parts: [],
        symbolPartIds: {},
        width: 0,
        height: 0,
        depth: 0,
      );
    }

    final depth = aisles.length;
    final height = aisles.first.length;
    final width = aisles.first.first.length;

    for (final aisle in aisles) {
      if (aisle.length != height) {
        throw ArgumentError('All aisles must have the same row count.');
      }
      for (final row in aisle) {
        if (row.length != width) {
          throw ArgumentError('All pattern rows must have the same width.');
        }
      }
    }

    final parts = <StructurePreviewPart>[];
    final symbolPartIds = <String, List<String>>{};
    final xOffset = (width - 1) / 2;
    final zOffset = (depth - 1) / 2;

    for (var zIndex = 0; zIndex < depth; zIndex++) {
      final aisle = aisles[zIndex];
      final zPositionIndex = aislesFromBackToFront ? zIndex : (depth - 1 - zIndex);

      for (var yIndex = 0; yIndex < height; yIndex++) {
        final row = aisle[yIndex];
        final yPositionIndex = rowsFromTopToBottom
            ? (height - 1 - yIndex)
            : yIndex;

        for (var xIndex = 0; xIndex < width; xIndex++) {
          final symbol = row[xIndex];
          final definition = symbols[symbol];
          if (definition == null) {
            throw ArgumentError('No symbol mapping provided for "$symbol".');
          }
          if (definition.skip) {
            continue;
          }

          final partIdPrefix = definition.partIdPrefix ?? definition.blockId.split(':').last;
          final partId = '$partIdPrefix-$xIndex-$yPositionIndex-$zPositionIndex';
          final position = StructureVector3(
            origin.x + (xIndex - xOffset) * blockSpacing,
            origin.y + yPositionIndex * blockSpacing,
            origin.z + (zPositionIndex - zOffset) * blockSpacing,
          );

          parts.add(
            StructurePreviewPart(
              id: partId,
              blockId: definition.blockId,
              displayName: definition.displayName,
              description: definition.description,
              category: definition.category,
              position: position,
              rotation: definition.rotation,
              facing: definition.facing,
              state: definition.state,
              tags: [
                ...definition.tags,
                'pattern:$symbol',
                'grid:$xIndex-$yPositionIndex-$zPositionIndex',
              ],
              candidates: definition.candidates
                  .map((candidate) => candidate.forPart(partId))
                  .toList(growable: false),
              visuals: definition.visuals,
            ),
          );
          symbolPartIds.putIfAbsent(symbol, () => <String>[]).add(partId);
        }
      }
    }

    return MultiblockPatternBuildResult(
      parts: List.unmodifiable(parts),
      symbolPartIds: symbolPartIds.map(
        (key, value) => MapEntry(key, List.unmodifiable(value)),
      ),
      width: width,
      height: height,
      depth: depth,
    );
  }
}
