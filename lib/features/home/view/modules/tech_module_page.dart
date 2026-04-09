import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:ctnh_wiki/features/home/data/tech_structure_preview_data.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_filter_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_filter_resolver.dart';
import 'package:ctnh_wiki/features/structure_preview/view/structure_preview_viewport.dart';
import 'package:flutter/material.dart';

class TechModulePage extends StatefulWidget {
  const TechModulePage({super.key});

  @override
  State<TechModulePage> createState() => _TechModulePageState();
}

class _TechModulePageState extends State<TechModulePage> {
  static const _filterResolver = StructurePreviewFilterResolver();

  late final StructureSelectionController _selectionController;
  late final StructureStepController _stepController;
  late final StructureFilterController _filterController;

  Set<String> get _visiblePartIds {
    return _filterResolver.resolveVisiblePartIds(
      definition: techStructurePreviewDefinition,
      stepController: _stepController,
      filterController: _filterController,
    );
  }

  @override
  void initState() {
    super.initState();
    _stepController = StructureStepController(
      steps: techStructurePreviewDefinition.steps,
      initialIndex: techStructurePreviewDefinition.steps.isEmpty
          ? 0
          : techStructurePreviewDefinition.steps.length - 1,
    );
    _filterController = StructureFilterController(
      parts: techStructurePreviewDefinition.parts,
    );
    _selectionController = StructureSelectionController(
      initialPartId: _resolveVisibleSelection(_visiblePartIds),
    );
    _stepController.addListener(_handlePresentationChanged);
    _filterController.addListener(_handlePresentationChanged);
  }

  @override
  void dispose() {
    _stepController.removeListener(_handlePresentationChanged);
    _filterController.removeListener(_handlePresentationChanged);
    _selectionController.dispose();
    _stepController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _handlePresentationChanged() {
    _syncSelectionWithVisibility();
    if (mounted) {
      setState(() {});
    }
  }

  void _syncSelectionWithVisibility() {
    final visiblePartIds = _visiblePartIds;
    final currentPartId = _selectionController.selectedPartId;
    if (currentPartId != null && visiblePartIds.contains(currentPartId)) {
      return;
    }

    _selectionController.selectPart(_resolveVisibleSelection(visiblePartIds));
  }

  String? _resolveVisibleSelection(Set<String> visiblePartIds) {
    final focusedPartIds = _stepController.focusedPartIds;
    for (final partId in focusedPartIds) {
      if (visiblePartIds.contains(partId)) {
        return partId;
      }
    }

    final currentStepPartIds = _filterResolver.resolveCurrentStepPartIds(
      _stepController,
    );
    if (_filterController.showOnlyCurrentStepParts) {
      for (final partId in currentStepPartIds) {
        if (visiblePartIds.contains(partId)) {
          return partId;
        }
      }
    }

    for (final part in techStructurePreviewDefinition.parts) {
      if (visiblePartIds.contains(part.id)) {
        return part.id;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 920;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModuleHeader(
          icon: techHomeModule.icon,
          tint: techHomeModule.tint,
          title: techHomeModule.title,
          description: techHomeModule.description,
        ),
        const SizedBox(height: 24),
        _TechPreviewShowcase(
          isCompact: isCompact,
          visiblePartIds: _visiblePartIds,
          selectionController: _selectionController,
          stepController: _stepController,
        ),
      ],
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.icon,
    required this.tint,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: const Color(0xFF201A16)),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF201A16),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Color(0xFF5F554D),
          ),
        ),
      ],
    );
  }
}

class _TechPreviewShowcase extends StatelessWidget {
  const _TechPreviewShowcase({
    required this.isCompact,
    required this.visiblePartIds,
    required this.selectionController,
    required this.stepController,
  });

  final bool isCompact;
  final Set<String> visiblePartIds;
  final StructureSelectionController selectionController;
  final StructureStepController stepController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 18 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EEE1), Color(0xFFF5EBE0), Color(0xFFEDE4D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE3D7C7)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final previewHeight = isCompact ? 280.0 : 360.0;

          return StructurePreviewViewport(
            structure: techStructurePreviewDefinition,
            size: Size(maxWidth, previewHeight),
            visiblePartIds: visiblePartIds,
            selectionController: selectionController,
            stepController: stepController,
          );
        },
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7DCCB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF201A16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF5F554D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
