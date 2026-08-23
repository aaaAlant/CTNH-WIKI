import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_filter_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_layer_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_selection_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/controllers/structure_step_controller.dart';
import 'package:ctnh_wiki/features/structure_preview/data/structure_preview_catalog.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/services/structure_preview_filter_resolver.dart';
import 'package:ctnh_wiki/features/structure_preview/view/structure_preview_viewport.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_insight_panel.dart';
import 'package:ctnh_wiki/features/structure_preview/view/widgets/structure_step_timeline.dart';
import 'package:flutter/material.dart';

class StructurePreviewTab extends StatefulWidget {
  const StructurePreviewTab({super.key});

  @override
  State<StructurePreviewTab> createState() => _StructurePreviewTabState();
}

class _StructurePreviewTabState extends State<StructurePreviewTab> {
  late StructurePreviewCatalogEntry _selectedEntry;
  late StructureSelectionController _selectionController;
  late StructureLayerController _layerController;
  late StructureStepController _stepController;
  late StructureFilterController _filterController;
  String? _selectedModuleKey;
  int _selectedPageIndex = 0;
  int? _selectedLayer;
  late final ValueNotifier<String?> _hoveredPartNotifier;

  StructurePreviewDefinition get _definition =>
      _selectedEntry.allPages[_selectedPageIndex];

  List<StructurePreviewCatalogEntry> get _visibleEntries {
    if (_selectedModuleKey == null) {
      return structurePreviewCatalog;
    }
    return structurePreviewCatalog
        .where((entry) => entry.moduleKey == _selectedModuleKey)
        .toList(growable: false);
  }

  Map<String, String> get _availableModules {
    return {
      for (final entry in structurePreviewCatalog)
        entry.moduleKey: entry.moduleLabel,
    };
  }

  List<int> get _availableLayers {
    return _layerController.layers
        .map((layer) => layer.index)
        .toList(growable: false);
  }

  Set<String> get _visiblePartIds {
    final visible = const StructurePreviewFilterResolver()
        .resolveVisiblePartIds(
          definition: _definition,
          stepController: _stepController,
          filterController: _filterController,
        );
    final layerPartIds = _layerController.visiblePartIds;
    if (layerPartIds == null) {
      return visible;
    }
    return visible.where(layerPartIds.contains).toSet();
  }

  @override
  void initState() {
    super.initState();
    _hoveredPartNotifier = ValueNotifier<String?>(null);
    _selectedEntry = structurePreviewCatalog.first;
    _createControllers();
  }

  void _createControllers() {
    _selectionController = StructureSelectionController();
    _layerController = StructureLayerController(parts: _definition.parts);
    _stepController = StructureStepController(
      steps: _definition.steps,
      initialIndex: _definition.steps.length - 1,
    );
    _filterController = StructureFilterController(parts: _definition.parts);
    _selectedLayer = null;
  }

  void _replaceControllers() {
    _selectionController.dispose();
    _layerController.dispose();
    _stepController.dispose();
    _filterController.dispose();
    _createControllers();
  }

  void _selectEntry(StructurePreviewCatalogEntry entry) {
    if (entry.id == _selectedEntry.id) {
      return;
    }
    _setStateAfterBuild(() {
      _selectedEntry = entry;
      _selectedPageIndex = 0;
      _replaceControllers();
    });
  }

  void _selectPage(int index) {
    if (index == _selectedPageIndex ||
        index < 0 ||
        index >= _selectedEntry.allPages.length) {
      return;
    }
    _setStateAfterBuild(() {
      _selectedPageIndex = index;
      _replaceControllers();
    });
  }

  void _setStateAfterBuild(VoidCallback update) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(update);
    });
  }

  void _selectModule(String? moduleKey) {
    _setStateAfterBuild(() {
      _selectedModuleKey = moduleKey;
      final entries = _visibleEntries;
      if (entries.isNotEmpty &&
          !entries.any((entry) => entry.id == _selectedEntry.id)) {
        _selectedEntry = entries.first;
        _selectedPageIndex = 0;
        _replaceControllers();
      }
    });
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _layerController.dispose();
    _stepController.dispose();
    _filterController.dispose();
    _hoveredPartNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([
        _selectionController,
        _layerController,
        _stepController,
        _filterController,
      ]),
      builder: (context, _) {
        final visiblePartIds = _visiblePartIds;
        final viewportWidth = responsive.isCompact
            ? (responsive.width - responsive.pageHorizontalPadding * 2).clamp(
                280,
                720,
              )
            : (responsive.isMedium ? 590 : 820);
        final viewportSize = Size(
          viewportWidth.toDouble(),
          responsive.isCompact ? 360 : (responsive.isMedium ? 430 : 520),
        );
        final viewport = StructurePreviewViewport(
          key: ValueKey(_definition.id + '-' + _selectedPageIndex.toString()),
          structure: _definition,
          size: viewportSize,
          visiblePartIds: visiblePartIds,
          selectionController: _selectionController,
          stepController: _stepController,
          onHoveredPartChanged: (partId) {
            _hoveredPartNotifier.value = partId;
          },
        );
        final inspector = StructureInsightPanel(
          structure: _definition,
          selectionController: _selectionController,
          stepController: _stepController,
          filterController: _filterController,
          visiblePartCount: visiblePartIds.length,
          hoveredPartNotifier: _hoveredPartNotifier,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(eyebrow: '结构预览', title: '多方块预览'),
            const SizedBox(height: 10),
            const Text(
              '查看多方块结构、层级和可替换仓室。可切换方案与当前层，并点击方块查看详细信息。',
              style: TextStyle(
                fontSize: 15,
                height: 1.65,
                color: WikiPalette.inkSoft,
              ),
            ),
            SizedBox(height: responsive.pageSectionGap),
            _CatalogToolbar(
              selectedModuleKey: _selectedModuleKey,
              moduleLabels: _availableModules,
              entries: _visibleEntries,
              selectedEntry: _selectedEntry,
              selectedPageIndex: _selectedPageIndex,
              pageCount: _selectedEntry.allPages.length,
              selectedLayer: _selectedLayer,
              layers: _availableLayers,
              onModuleSelected: _selectModule,
              onEntrySelected: _selectEntry,
              onPageSelected: _selectPage,
              onLayerSelected: (layer) {
                _setStateAfterBuild(() {
                  _layerController.selectLayer(layer);
                  _selectedLayer = layer;
                });
              },
            ),
            const SizedBox(height: 18),
            if (responsive.isCompact) ...[
              viewport,
              const SizedBox(height: 18),
              inspector,
              const SizedBox(height: 18),
              StructureStepTimeline(controller: _stepController),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 11, child: viewport),
                  const SizedBox(width: 18),
                  SizedBox(
                    width: responsive.isMedium ? 330 : 380,
                    child: inspector,
                  ),
                ],
              ),
            if (!responsive.isCompact) ...[
              const SizedBox(height: 18),
              StructureStepTimeline(controller: _stepController),
            ],
          ],
        );
      },
    );
  }
}

class _CatalogToolbar extends StatelessWidget {
  const _CatalogToolbar({
    required this.selectedModuleKey,
    required this.moduleLabels,
    required this.entries,
    required this.selectedEntry,
    required this.selectedPageIndex,
    required this.pageCount,
    required this.selectedLayer,
    required this.layers,
    required this.onModuleSelected,
    required this.onEntrySelected,
    required this.onPageSelected,
    required this.onLayerSelected,
  });

  final String? selectedModuleKey;
  final Map<String, String> moduleLabels;
  final List<StructurePreviewCatalogEntry> entries;
  final StructurePreviewCatalogEntry selectedEntry;
  final int selectedPageIndex;
  final int pageCount;
  final int? selectedLayer;
  final List<int> layers;
  final ValueChanged<String?> onModuleSelected;
  final ValueChanged<StructurePreviewCatalogEntry> onEntrySelected;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<int?> onLayerSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: WikiDecorations.frame(
        color: WikiPalette.parchmentDark,
        radiusValue: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModuleChip(
                label: '全部模块',
                selected: selectedModuleKey == null,
                onTap: () => onModuleSelected(null),
              ),
              for (final entry in moduleLabels.entries)
                _ModuleChip(
                  label: entry.value,
                  selected: selectedModuleKey == entry.key,
                  onTap: () => onModuleSelected(entry.key),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final controls = <Widget>[
                Expanded(
                  child: _StructureDropdown(
                    entries: entries,
                    selectedEntry: selectedEntry,
                    onChanged: onEntrySelected,
                  ),
                ),
                _PageSelector(
                  selectedPageIndex: selectedPageIndex,
                  pageCount: pageCount,
                  onSelected: onPageSelected,
                ),
                _LayerSelector(
                  selectedLayer: selectedLayer,
                  layers: layers,
                  onSelected: onLayerSelected,
                ),
              ];
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StructureDropdown(
                      entries: entries,
                      selectedEntry: selectedEntry,
                      onChanged: onEntrySelected,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: controls.skip(1).toList(),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  controls[0],
                  const SizedBox(width: 12),
                  controls[1],
                  const SizedBox(width: 12),
                  controls[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModuleChip extends StatelessWidget {
  const _ModuleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: WikiPalette.steel,
      backgroundColor: WikiPalette.parchmentLight,
      side: const BorderSide(color: WikiPalette.purpleMuted),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: selected ? WikiPalette.lineLight : WikiPalette.ink,
      ),
      showCheckmark: false,
    );
  }
}

class _StructureDropdown extends StatelessWidget {
  const _StructureDropdown({
    required this.entries,
    required this.selectedEntry,
    required this.onChanged,
  });

  final List<StructurePreviewCatalogEntry> entries;
  final StructurePreviewCatalogEntry selectedEntry;
  final ValueChanged<StructurePreviewCatalogEntry> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ToolbarLabel(label: '结构'),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: WikiDecorations.slot(
            color: WikiPalette.parchmentLight,
            radiusValue: 8,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<StructurePreviewCatalogEntry>(
              value: selectedEntry,
              isExpanded: true,
              icon: const Icon(Icons.unfold_more_rounded),
              items: entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry,
                      child: Text(
                        entry.definition.metadata.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: WikiPalette.ink,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (entry) {
                if (entry != null) onChanged(entry);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PageSelector extends StatelessWidget {
  const _PageSelector({
    required this.selectedPageIndex,
    required this.pageCount,
    required this.onSelected,
  });

  final int selectedPageIndex;
  final int pageCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ToolbarLabel(label: '方案'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: List.generate(
            pageCount,
            (index) => ChoiceChip(
              label: Text('P:' + (index + 1).toString()),
              selected: index == selectedPageIndex,
              onSelected: (_) => onSelected(index),
              selectedColor: WikiPalette.steel,
              backgroundColor: WikiPalette.parchmentLight,
              side: const BorderSide(color: WikiPalette.purpleMuted),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: index == selectedPageIndex
                    ? WikiPalette.lineLight
                    : WikiPalette.ink,
              ),
              showCheckmark: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _LayerSelector extends StatelessWidget {
  const _LayerSelector({
    required this.selectedLayer,
    required this.layers,
    required this.onSelected,
  });

  final int? selectedLayer;
  final List<int> layers;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ToolbarLabel(label: '层'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('ALL'),
              selected: selectedLayer == null,
              onSelected: (_) => onSelected(null),
              selectedColor: WikiPalette.rustDark,
              backgroundColor: WikiPalette.parchmentLight,
              side: const BorderSide(color: WikiPalette.purpleMuted),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: selectedLayer == null
                    ? WikiPalette.lineLight
                    : WikiPalette.ink,
              ),
              showCheckmark: false,
            ),
            for (final layer in layers)
              ChoiceChip(
                label: Text('L:' + layer.toString()),
                selected: selectedLayer == layer,
                onSelected: (_) => onSelected(layer),
                selectedColor: WikiPalette.rustDark,
                backgroundColor: WikiPalette.parchmentLight,
                side: const BorderSide(color: WikiPalette.purpleMuted),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: selectedLayer == layer
                      ? WikiPalette.lineLight
                      : WikiPalette.ink,
                ),
                showCheckmark: false,
              ),
          ],
        ),
      ],
    );
  }
}

class _ToolbarLabel extends StatelessWidget {
  const _ToolbarLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: WikiPalette.rustDark,
      ),
    );
  }
}
