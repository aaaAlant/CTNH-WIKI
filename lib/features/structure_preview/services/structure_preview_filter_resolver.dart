import 'package:ctnh_wiki/features/structure_preview/controllers/structure_filter_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';

class StructurePreviewFilterResolver {
  const StructurePreviewFilterResolver();

  Set<String> resolveVisiblePartIds({
    required StructurePreviewDefinition definition,
    StructureStepController? stepController,
    StructureFilterController? filterController,
  }) {
    final cumulativeStepPartIds = stepController?.visiblePartIds;
    final currentStepPartIds = resolveCurrentStepPartIds(stepController);
    final shouldLimitToCurrentStep =
        filterController?.showOnlyCurrentStepParts == true &&
        stepController?.currentStep != null;

    final visiblePartIds = <String>{};

    for (final part in definition.parts) {
      if (cumulativeStepPartIds != null &&
          !cumulativeStepPartIds.contains(part.id)) {
        continue;
      }

      if (filterController != null &&
          !filterController.isCategoryVisible(part.category)) {
        continue;
      }

      if (shouldLimitToCurrentStep && !currentStepPartIds.contains(part.id)) {
        continue;
      }

      visiblePartIds.add(part.id);
    }

    return visiblePartIds;
  }

  Set<String> resolveCurrentStepPartIds(StructureStepController? stepController) {
    final currentStep = stepController?.currentStep;
    if (currentStep == null) {
      return const <String>{};
    }

    return {
      ...currentStep.revealedPartIds,
      ...currentStep.focusedPartIds,
    };
  }
}
