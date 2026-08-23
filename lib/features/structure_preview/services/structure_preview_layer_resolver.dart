import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_layer.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';

/// Derives selectable horizontal layers from generated part positions.
class StructurePreviewLayerResolver {
  const StructurePreviewLayerResolver({this.positionPrecision = 1000});

  /// Multiplies coordinates before rounding so generated decimal spacing is
  /// grouped consistently without relying on exact double equality.
  final int positionPrecision;

  List<StructurePreviewLayer> resolveLayers(
    StructurePreviewDefinition definition,
  ) {
    return resolveParts(definition.parts);
  }

  /// Derives layers directly from preview parts, including pattern-builder
  /// grid:x-y-z and optional layer:<index> tags.
  List<StructurePreviewLayer> resolveParts(
    Iterable<StructurePreviewPart> sourceParts,
  ) {
    final parts = List.unmodifiable(sourceParts);
    if (parts.isEmpty) {
      return const [];
    }

    final buckets = <int, List<StructurePreviewPart>>{};
    for (final part in parts) {
      final key = _layerKey(part);
      buckets.putIfAbsent(key, () => <StructurePreviewPart>[]).add(part);
    }

    final keys = buckets.keys.toList()..sort();
    final layers = <StructurePreviewLayer>[];
    for (var index = 0; index < keys.length; index++) {
      final layerParts = buckets[keys[index]]!;
      final requiredCount = layerParts
          .where((part) => part.state == StructurePartState.required)
          .length;
      final optionalCount = layerParts
          .where((part) => part.state == StructurePartState.optional)
          .length;
      final customLabel = _customLabel(layerParts);

      layers.add(
        StructurePreviewLayer(
          id: 'layer-' + index.toString(),
          index: index,
          label: customLabel ?? '第 ' + (index + 1).toString() + ' 层',
          y: layerParts.first.position.y,
          partIds: List.unmodifiable(layerParts.map((part) => part.id)),
          requiredPartCount: requiredCount,
          optionalPartCount: optionalCount,
        ),
      );
    }

    return List.unmodifiable(layers);
  }

  int _layerKey(StructurePreviewPart part) {
    for (final tag in part.tags) {
      final explicitIndex = _parseTagIndex(tag, 'layer-index:');
      if (explicitIndex != null) {
        return explicitIndex;
      }
      final legacyIndex = _parseTagIndex(tag, 'layer:');
      if (legacyIndex != null) {
        return legacyIndex;
      }
      final gridIndex = _parseGridY(tag);
      if (gridIndex != null) {
        return gridIndex;
      }
    }
    return (part.position.y * positionPrecision).round();
  }

  int? _parseTagIndex(String tag, String prefix) {
    if (!tag.startsWith(prefix)) {
      return null;
    }
    return int.tryParse(tag.substring(prefix.length));
  }

  int? _parseGridY(String tag) {
    const prefix = 'grid:';
    if (!tag.startsWith(prefix)) {
      return null;
    }
    final coordinates = tag.substring(prefix.length).split('-');
    if (coordinates.length != 3) {
      return null;
    }
    return int.tryParse(coordinates[1]);
  }

  String? _customLabel(Iterable<StructurePreviewPart> parts) {
    for (final part in parts) {
      for (final tag in part.tags) {
        const prefix = 'layer-label:';
        if (tag.startsWith(prefix) && tag.length > prefix.length) {
          return tag.substring(prefix.length);
        }
      }
    }
    return null;
  }
}
