import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_layer.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_layer_resolver.dart';
import 'package:flutter/foundation.dart';

/// Controls an optional layer slice. A null selected layer means ALL layers.
class StructureLayerController extends ChangeNotifier {
  StructureLayerController({
    Iterable<StructurePreviewLayer> layers = const [],
    Iterable<StructurePreviewPart> parts = const [],
    int? selectedLayer,
    int? initialIndex,
    StructurePreviewLayerResolver resolver = const StructurePreviewLayerResolver(),
  }) {
    final sourceParts = List<StructurePreviewPart>.unmodifiable(parts);
    _layers = sourceParts.isNotEmpty
        ? resolver.resolveParts(sourceParts)
        : List<StructurePreviewLayer>.unmodifiable(layers);
    _selectedLayer = _normalizeSelection(
      _layers,
      selectedLayer ?? initialIndex,
    );
  }

  late List<StructurePreviewLayer> _layers;
  int? _selectedLayer;

  List<StructurePreviewLayer> get layers => _layers;
  int? get selectedLayer => _selectedLayer;
  int? get selectedLayerIndex => _selectedLayer;
  int get currentIndex => _selectedLayer ?? -1;
  int get layerCount => _layers.length;
  bool get hasLayers => _layers.isNotEmpty;
  bool get isAllSelected => _selectedLayer == null;

  StructurePreviewLayer? get currentLayer {
    final index = _selectedLayer;
    if (index == null || index < 0 || index >= _layers.length) {
      return null;
    }
    return _layers[index];
  }

  /// Returns null for ALL layers, matching StructurePreviewViewport's
  /// existing null-visiblePartIds contract.
  Set<String>? get visiblePartIds {
    final layer = currentLayer;
    if (layer == null) {
      return null;
    }
    return layer.partIds.toSet();
  }

  /// The selected layer's part IDs, or an empty set while ALL is selected.
  Set<String> get currentPartIds => currentLayer == null
      ? const <String>{}
      : currentLayer!.partIds.toSet();

  /// All layer part IDs, useful when a caller needs a concrete ALL set.
  Set<String> get allPartIds => {
    for (final layer in _layers) ...layer.partIds,
  };

  void selectLayer(int? index) {
    final normalized = _normalizeSelection(_layers, index);
    if (_selectedLayer == normalized) {
      return;
    }
    _selectedLayer = normalized;
    notifyListeners();
  }

  void setLayers(
    Iterable<StructurePreviewLayer> layers, {
    int? initialIndex,
  }) {
    final nextLayers = List<StructurePreviewLayer>.unmodifiable(layers);
    final previousLayerId = currentLayer?.id;
    final nextIndex = initialIndex != null
        ? _normalizeSelection(nextLayers, initialIndex)
        : _selectedLayer == null
        ? null
        : _indexForId(nextLayers, previousLayerId);
    if (_sameLayers(nextLayers, _layers) && nextIndex == _selectedLayer) {
      return;
    }
    _layers = nextLayers;
    _selectedLayer = nextIndex;
    notifyListeners();
  }

  void setParts(
    Iterable<StructurePreviewPart> parts, {
    StructurePreviewLayerResolver resolver = const StructurePreviewLayerResolver(),
  }) {
    final nextLayers = resolver.resolveParts(parts);
    final previousLayerId = currentLayer?.id;
    final nextIndex = _selectedLayer == null
        ? null
        : _indexForId(nextLayers, previousLayerId);
    if (_sameLayers(nextLayers, _layers) && nextIndex == _selectedLayer) {
      return;
    }
    _layers = nextLayers;
    _selectedLayer = nextIndex;
    notifyListeners();
  }

  void goToLayer(int index) => selectLayer(index);

  void nextLayer() {
    final next = (_selectedLayer ?? -1) + 1;
    selectLayer(next);
  }

  void previousLayer() {
    final previous = (_selectedLayer ?? 0) - 1;
    selectLayer(previous);
  }

  int? _normalizeSelection(
    List<StructurePreviewLayer> layers,
    int? index,
  ) {
    if (index == null || layers.isEmpty) {
      return null;
    }
    return index.clamp(0, layers.length - 1).toInt();
  }

  int? _indexForId(List<StructurePreviewLayer> layers, String? id) {
    if (id == null) {
      return null;
    }
    for (var index = 0; index < layers.length; index++) {
      if (layers[index].id == id) {
        return index;
      }
    }
    return null;
  }

  bool _sameLayers(
    List<StructurePreviewLayer> left,
    List<StructurePreviewLayer> right,
  ) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index].id != right[index].id ||
          left[index].label != right[index].label ||
          left[index].y != right[index].y ||
          left[index].requiredPartCount != right[index].requiredPartCount ||
          left[index].optionalPartCount != right[index].optionalPartCount ||
          !_sameIds(left[index].partIds, right[index].partIds)) {
        return false;
      }
    }
    return true;
  }

  bool _sameIds(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
}
