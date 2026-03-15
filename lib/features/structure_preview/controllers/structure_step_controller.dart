import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_step.dart';
import 'package:flutter/foundation.dart';

class StructureStepController extends ChangeNotifier {
  StructureStepController({
    required List<StructurePreviewStep> steps,
    int initialIndex = 0,
  }) : _steps = List.unmodifiable(steps),
       _currentIndex = steps.isEmpty
           ? -1
           : initialIndex.clamp(0, steps.length - 1);

  final List<StructurePreviewStep> _steps;
  int _currentIndex;

  List<StructurePreviewStep> get steps => _steps;
  int get currentIndex => _currentIndex;
  int get stepCount => _steps.length;
  bool get hasSteps => _steps.isNotEmpty;

  StructurePreviewStep? get currentStep {
    if (!hasSteps || _currentIndex < 0 || _currentIndex >= _steps.length) {
      return null;
    }
    return _steps[_currentIndex];
  }

  Set<String>? get visiblePartIds {
    if (!hasSteps || _currentIndex < 0) {
      return null;
    }

    final ids = <String>{};
    for (var i = 0; i <= _currentIndex; i++) {
      ids.addAll(_steps[i].revealedPartIds);
    }
    return ids;
  }

  Set<String> get focusedPartIds {
    final step = currentStep;
    if (step == null) {
      return const <String>{};
    }
    return step.focusedPartIds.toSet();
  }

  void goToStep(int index) {
    if (!hasSteps) {
      return;
    }

    final normalized = index.clamp(0, _steps.length - 1);
    if (_currentIndex == normalized) {
      return;
    }

    _currentIndex = normalized;
    notifyListeners();
  }

  void nextStep() {
    goToStep(_currentIndex + 1);
  }

  void previousStep() {
    goToStep(_currentIndex - 1);
  }
}
