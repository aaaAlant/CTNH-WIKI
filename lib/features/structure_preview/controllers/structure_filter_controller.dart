import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:flutter/foundation.dart';

class StructureFilterController extends ChangeNotifier {
  StructureFilterController({
    required Iterable<StructurePreviewPart> parts,
    bool showOnlyCurrentStepParts = false,
  }) : _availableCategories = {...parts.map((part) => part.category)},
       _showOnlyCurrentStepParts = showOnlyCurrentStepParts,
       _visibleCategories = {...parts.map((part) => part.category)};

  final Set<StructurePartCategory> _availableCategories;
  final Set<StructurePartCategory> _visibleCategories;
  bool _showOnlyCurrentStepParts;

  Set<StructurePartCategory> get availableCategories => {
    ..._availableCategories,
  };

  Set<StructurePartCategory> get visibleCategories => {..._visibleCategories};

  bool get showOnlyCurrentStepParts => _showOnlyCurrentStepParts;

  bool isCategoryVisible(StructurePartCategory category) {
    return _visibleCategories.contains(category);
  }

  bool get hasCategoryFilter {
    return _visibleCategories.length != _availableCategories.length;
  }

  bool get hasActiveFilter {
    return _showOnlyCurrentStepParts || hasCategoryFilter;
  }

  void setShowOnlyCurrentStepParts(bool value) {
    if (_showOnlyCurrentStepParts == value) {
      return;
    }

    _showOnlyCurrentStepParts = value;
    notifyListeners();
  }

  void toggleCategory(StructurePartCategory category) {
    if (_visibleCategories.contains(category)) {
      _visibleCategories.remove(category);
    } else {
      _visibleCategories.add(category);
    }
    notifyListeners();
  }

  void reset() {
    var changed = false;

    if (_showOnlyCurrentStepParts) {
      _showOnlyCurrentStepParts = false;
      changed = true;
    }

    if (_visibleCategories.length != _availableCategories.length) {
      _visibleCategories
        ..clear()
        ..addAll(_availableCategories);
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }
}
