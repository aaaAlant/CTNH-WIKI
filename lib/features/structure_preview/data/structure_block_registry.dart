import 'package:ctnh_wiki/features/structure_preview/models/structure_block.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';

class StructureBlockRegistry {
  const StructureBlockRegistry(this._definitions);

  final Map<String, StructureBlockDefinition> _definitions;

  StructureBlockDefinition? find(String blockId) => _definitions[blockId];
}

const structureBlockRegistry = StructureBlockRegistry({
  'ctnh:prototype_machine_a': StructureBlockDefinition(
    blockId: 'ctnh:prototype_machine_a',
    displayName: '加工机组 A',
    visuals: [_prototypeMachineVisual],
  ),
  'ctnh:prototype_machine_b': StructureBlockDefinition(
    blockId: 'ctnh:prototype_machine_b',
    displayName: '加工机组 B',
    visuals: [_prototypeMachineVisual],
  ),
  'ctnh:prototype_machine_c': StructureBlockDefinition(
    blockId: 'ctnh:prototype_machine_c',
    displayName: '加工机组 C',
    visuals: [_prototypeMachineVisual],
  ),
  'ctnh:prototype_machine_d': StructureBlockDefinition(
    blockId: 'ctnh:prototype_machine_d',
    displayName: '加工机组 D',
    visuals: [_prototypeMachineVisual],
  ),
  'ctnh:monitor_top': StructureBlockDefinition(
    blockId: 'ctnh:monitor_top',
    displayName: '上层读数面板',
    visuals: [_monitorFrameVisual, _monitorLogoScreenVisual],
  ),
  'ctnh:monitor_side': StructureBlockDefinition(
    blockId: 'ctnh:monitor_side',
    displayName: '侧向读数面板',
    visuals: [_monitorFrameVisual, _monitorLogoScreenVisual],
  ),
});

const _prototypeMachineVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(0.95, 0.95, 0.95),
  material: StructureMaterialStyle(color: 0xFF7D5638, roughness: 0.88),
);

const _monitorFrameVisual = StructurePartVisual.cuboid(
  id: 'frame',
  size: StructureVector3(0.32, 0.48, 0.18),
  material: StructureMaterialStyle(
    color: 0xFF2D241F,
    metalness: 0.18,
    roughness: 0.62,
  ),
);

const _monitorLogoScreenVisual = StructurePartVisual.cuboid(
  id: 'screen',
  size: StructureVector3(0.18, 0.3, 0.04),
  localOffset: StructureVector3(0, 0, 0.11),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/icons/app/logo-480x300.jpg',
    roughness: 0.16,
    metalness: 0.02,
    pixelated: true,
  ),
);
