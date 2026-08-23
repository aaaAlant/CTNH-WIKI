import 'package:ctnh_wiki/features/home/data/tech_structure_preview_data.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_block_candidate.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_metadata.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_step.dart';
import 'package:ctnh_wiki/features/structure_preview/services/multiblock_pattern_builder.dart';

class StructurePreviewCatalogEntry {
  const StructurePreviewCatalogEntry({
    required this.id,
    required this.module,
    required this.moduleKey,
    required this.moduleLabel,
    required this.sourceRef,
    required this.definition,
    this.pages = const [],
  });

  final String id;
  final StructurePreviewModule module;
  final String moduleKey;
  final String moduleLabel;
  final String sourceRef;
  final StructurePreviewDefinition definition;
  final List<StructurePreviewDefinition> pages;

  List<StructurePreviewDefinition> get allPages {
    return pages.isEmpty ? [definition] : pages;
  }
}

const _casingVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(color: 0xFF6D7984, roughness: 0.86),
);

const _warmCasingVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(color: 0xFFB57D59, roughness: 0.92),
);

const _glassVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFF8BC6C5,
    opacity: 0.72,
    alphaTest: 0.05,
    doubleSided: true,
    roughness: 0.28,
  ),
);

const _controllerVisual = StructurePartVisual.cuboid(
  id: 'controller',
  size: StructureVector3(0.9, 0.9, 0.9),
  material: StructureMaterialStyle(
    color: 0xFFE3A94F,
    metalness: 0.22,
    roughness: 0.58,
  ),
);

const _powerCasingCandidates = [
  StructureBlockCandidate(
    id: 'gtceu:palladium-substation-casing',
    blockId: 'gtceu:palladium_substation_casing',
    displayName: '钯蓄能变电站外壳',
    description: '蓄能变电站外壳位置的默认方块，可替换为对应的能量、激光或维护仓。',
    category: StructurePartCategory.casing,
    state: StructurePartState.required,
    partIds: const [],
    tags: ['Energy', 'default', 'casing'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:hv-energy-input-hatch',
    blockId: 'gtceu:hv_energy_input_hatch',
    displayName: 'HV 能量输入仓',
    description: '向蓄能变电站输入 HV 电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'energy-input'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:hv-energy-output-hatch',
    blockId: 'gtceu:hv_energy_output_hatch',
    displayName: 'HV 能量输出仓',
    description: '从蓄能变电站输出 HV 电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'energy-output'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:ev-substation-input-hatch',
    blockId: 'gtceu:ev_substation_input_hatch_64a',
    displayName: 'EV 64A 蓄能变电站输入仓',
    description: '向蓄能变电站输入 EV 64A 电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'substation-input'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:ev-substation-output-hatch',
    blockId: 'gtceu:ev_substation_output_hatch_64a',
    displayName: 'EV 64A 蓄能变电站输出仓',
    description: '从蓄能变电站输出 EV 64A 电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'substation-output'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:maintenance-hatch',
    blockId: 'gtceu:maintenance_hatch',
    displayName: '维护仓',
    description: '执行蓄能变电站维护操作的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'maintenance'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:iv-laser-source-hatch',
    blockId: 'gtceu:iv_256a_laser_source_hatch',
    displayName: 'IV 256A 激光输入仓',
    description: '向蓄能变电站输入 IV 256A 激光的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'laser-input'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:iv-laser-target-hatch',
    blockId: 'gtceu:iv_256a_laser_target_hatch',
    displayName: 'IV 256A 激光输出仓',
    description: '从蓄能变电站输出 IV 256A 激光的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Energy', 'ability', 'laser-output'],
  ),
];

const _powerSubstationCandidates = [
  StructureBlockCandidate(
    id: 'gtceu:substation-battery',
    blockId: 'gtceu:substation_battery',
    displayName: '蓄能电池',
    description: '可替换的蓄能电池，支持当前安装版本提供的所有已注册电压等级。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['replaceable', 'battery'],
  ),
];

const _manaCandidates = [
  StructureBlockCandidate(
    id: 'botania:living-rock',
    blockId: 'botania:living_rock',
    displayName: '活石机壳',
    description: '宝石镶嵌机主体机壳的默认方块，可替换为魔力仓。',
    category: StructurePartCategory.casing,
    state: StructurePartState.required,
    partIds: const [],
    tags: ['Mana', 'default', 'casing'],
  ),
  StructureBlockCandidate(
    id: 'ctnhmana:mana_hatch',
    blockId: 'ctnhmana:mana_hatch',
    displayName: '魔力仓',
    description: '向宝石镶嵌机输入魔力的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['Mana', 'ability', 'replaceable'],
  ),
];

const _kineticCandidates = [
  StructureBlockCandidate(
    id: 'create:andesite-casing',
    blockId: 'create:andesite_casing',
    displayName: '安山岩机壳',
    description: '安山岩机壳，粉碎工厂外壳位置的默认方块。',
    category: StructurePartCategory.casing,
    state: StructurePartState.required,
    partIds: const [],
    tags: ['CTPP', 'default', 'casing'],
  ),
  StructureBlockCandidate(
    id: 'ctpp:kinetic-input-box',
    blockId: 'ctpp:kinetic_input_box',
    displayName: '动能输入箱',
    description: '向粉碎工厂输入 Create 应力的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'kinetic-input'],
  ),
  StructureBlockCandidate(
    id: 'ctpp:mechanical-upgrade-bus',
    blockId: 'ctpp:mechanical_upgrade_bus',
    displayName: '机械升级仓',
    description: '增强粉碎工厂机械升级能力的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'mechanical-upgrade'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:item-import-bus',
    blockId: 'gtceu:item_import_bus',
    displayName: '物品输入仓',
    description: '向粉碎工厂输入待粉碎物品的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'item-import'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:item-export-bus',
    blockId: 'gtceu:item_export_bus',
    displayName: '物品输出仓',
    description: '接收粉碎产物的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'item-export'],
  ),
];

const _coreSteelVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_casings_solid_machine_casing_solid_steel.png',
    metalness: 0.08,
    roughness: 0.78,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreCleanSteelVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_casings_solid_machine_casing_clean_stainless_steel.png',
    metalness: 0.1,
    roughness: 0.7,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreGlassVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_casings_transparent_tempered_glass.png',
    opacity: 0.82,
    alphaTest: 0.06,
    doubleSided: true,
    roughness: 0.22,
    pixelated: true,
  ),
);

const _coreCopperVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/create_block_copper_shingles.png',
    metalness: 0.04,
    roughness: 0.82,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreReflectVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_casings_solid_machine_casing_clean_stainless_steel.png',
    metalness: 0.12,
    roughness: 0.52,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreGirderVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    objTextures: const {
      '1': 'assets/textures/modules/auto/create_block_girder_pole.png',
      '2': 'assets/textures/modules/auto/create_block_girder_pole_side.png',
    },
    modelData: '{"elements":[{"from":[4,0,4],"to":[12,16,12],"faces":{"north":{"uv":[4,0,12,16],"texture":"#2"},"east":{"uv":[4,0,12,16],"texture":"#2"},"south":{"uv":[4,0,12,16],"texture":"#2"},"west":{"uv":[4,0,12,16],"texture":"#2"},"up":{"uv":[8,0,16,8],"texture":"#1"},"down":{"uv":[8,0,16,8],"texture":"#1"}}}]}',
    roughness: 0.68,
    metalness: 0.08,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreGrassVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_grass_block_side.png',
      right:
          'assets/textures/modules/auto/minecraft_block_grass_block_side.png',
      left: 'assets/textures/modules/auto/minecraft_block_grass_block_side.png',
      top: 'assets/textures/modules/auto/minecraft_block_grass_block_top.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_dirt.png',
      front:
          'assets/textures/modules/auto/minecraft_block_grass_block_side.png',
      back: 'assets/textures/modules/auto/minecraft_block_grass_block_side.png',
    ),
    roughness: 0.9,
    metalness: 0.0,
    alphaTest: 0.03,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreOakFenceVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    objTextures: const {
      'texture': 'assets/textures/modules/auto/minecraft_block_oak_planks.png',
    },
    modelData: '{"elements":[{"from":[6,0,6],"to":[10,16,10],"faces":{"down":{"uv":[6,6,10,10],"texture":"#texture"},"up":{"uv":[6,6,10,10],"texture":"#texture"},"north":{"uv":[6,0,10,16],"texture":"#texture"},"south":{"uv":[6,0,10,16],"texture":"#texture"},"west":{"uv":[6,0,10,16],"texture":"#texture"},"east":{"uv":[6,0,10,16],"texture":"#texture"}}},{"from":[7,12,0],"to":[9,15,9],"faces":{"down":{"uv":[7,0,9,9],"texture":"#texture"},"up":{"uv":[7,0,9,9],"texture":"#texture"},"north":{"uv":[7,1,9,4],"texture":"#texture"},"south":{"uv":[7,1,9,4],"texture":"#texture"},"west":{"uv":[0,1,9,4],"texture":"#texture"},"east":{"uv":[0,1,9,4],"texture":"#texture"}}},{"from":[7,6,0],"to":[9,9,9],"faces":{"down":{"uv":[7,0,9,9],"texture":"#texture"},"up":{"uv":[7,0,9,9],"texture":"#texture"},"north":{"uv":[7,7,9,10],"texture":"#texture"},"south":{"uv":[7,7,9,10],"texture":"#texture"},"west":{"uv":[0,7,9,10],"texture":"#texture"},"east":{"uv":[0,7,9,10],"texture":"#texture"}}},{"from":[0,12,7],"to":[9,15,9],"faces":{"down":{"uv":[0,0,9,9],"texture":"#texture"},"up":{"uv":[0,0,9,9],"texture":"#texture"},"north":{"uv":[0,1,9,4],"texture":"#texture"},"south":{"uv":[0,1,9,4],"texture":"#texture"},"west":{"uv":[0,1,9,4],"texture":"#texture"},"east":{"uv":[0,1,9,4],"texture":"#texture"}}},{"from":[0,6,7],"to":[9,9,9],"faces":{"down":{"uv":[0,0,9,9],"texture":"#texture"},"up":{"uv":[0,0,9,9],"texture":"#texture"},"north":{"uv":[0,7,9,10],"texture":"#texture"},"south":{"uv":[0,7,9,10],"texture":"#texture"},"west":{"uv":[0,7,9,10],"texture":"#texture"},"east":{"uv":[0,7,9,10],"texture":"#texture"}}}]}',
    roughness: 0.82,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreOakStairsVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    objTextures: const {
      'bottom': 'assets/textures/modules/auto/minecraft_block_oak_planks.png',
      'top': 'assets/textures/modules/auto/minecraft_block_oak_planks.png',
      'side': 'assets/textures/modules/auto/minecraft_block_oak_planks.png',
    },
    modelData: '{"elements":[{"from":[0,0,0],"to":[16,8,16],"faces":{"down":{"texture":"#bottom"},"up":{"texture":"#top"},"north":{"texture":"#side"},"south":{"texture":"#side"},"west":{"texture":"#side"},"east":{"texture":"#side"}}},{"from":[8,8,0],"to":[16,16,16],"faces":{"up":{"texture":"#top"},"north":{"texture":"#side"},"south":{"texture":"#side"},"west":{"texture":"#side"},"east":{"texture":"#side"}}}]}',
    roughness: 0.82,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreOakLogVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_oak_log.png',
      right: 'assets/textures/modules/auto/minecraft_block_oak_log.png',
      left: 'assets/textures/modules/auto/minecraft_block_oak_log.png',
      top: 'assets/textures/modules/auto/minecraft_block_oak_log_top.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_oak_log_top.png',
      front: 'assets/textures/modules/auto/minecraft_block_oak_log.png',
      back: 'assets/textures/modules/auto/minecraft_block_oak_log.png',
    ),
    roughness: 0.86,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreHayVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_hay_block_side.png',
      right: 'assets/textures/modules/auto/minecraft_block_hay_block_side.png',
      left: 'assets/textures/modules/auto/minecraft_block_hay_block_side.png',
      top: 'assets/textures/modules/auto/minecraft_block_hay_block_top.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_hay_block_top.png',
      front: 'assets/textures/modules/auto/minecraft_block_hay_block_side.png',
      back: 'assets/textures/modules/auto/minecraft_block_hay_block_side.png',
    ),
    roughness: 0.92,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreDirtPathVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_dirt_path_side.png',
      right: 'assets/textures/modules/auto/minecraft_block_dirt_path_side.png',
      left: 'assets/textures/modules/auto/minecraft_block_dirt_path_side.png',
      top: 'assets/textures/modules/auto/minecraft_block_dirt_path_top.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_dirt.png',
      front: 'assets/textures/modules/auto/minecraft_block_dirt_path_side.png',
      back: 'assets/textures/modules/auto/minecraft_block_dirt_path_side.png',
    ),
    roughness: 0.9,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreBoneVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_bone_block_side.png',
      right: 'assets/textures/modules/auto/minecraft_block_bone_block_side.png',
      left: 'assets/textures/modules/auto/minecraft_block_bone_block_side.png',
      top: 'assets/textures/modules/auto/minecraft_block_bone_block_top.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_bone_block_top.png',
      front: 'assets/textures/modules/auto/minecraft_block_bone_block_side.png',
      back: 'assets/textures/modules/auto/minecraft_block_bone_block_side.png',
    ),
    roughness: 0.76,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreWaterVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_water_still.png',
      right: 'assets/textures/modules/auto/minecraft_block_water_still.png',
      left: 'assets/textures/modules/auto/minecraft_block_water_still.png',
      top: 'assets/textures/modules/auto/minecraft_block_water_still.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_water_still.png',
      front: 'assets/textures/modules/auto/minecraft_block_water_still.png',
      back: 'assets/textures/modules/auto/minecraft_block_water_still.png',
    ),
    opacity: 0.72,
    roughness: 0.18,
    metalness: 0.0,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreLilyPadVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(0.9, 0.08, 0.9),
  localOffset: StructureVector3(0, 0.48, 0),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/minecraft_block_lily_pad.png',
    roughness: 0.72,
    metalness: 0.0,
    alphaTest: 0.08,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreBarsVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(0.96, 0.96, 0.96),
  material: StructureMaterialStyle(
    color: 0xFF5C5B58,
    roughness: 0.76,
    metalness: 0.05,
  ),
);

const _coreBricksVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_bricks.png',
      right: 'assets/textures/modules/auto/minecraft_block_bricks.png',
      left: 'assets/textures/modules/auto/minecraft_block_bricks.png',
      top: 'assets/textures/modules/auto/minecraft_block_bricks.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_bricks.png',
      front: 'assets/textures/modules/auto/minecraft_block_bricks.png',
      back: 'assets/textures/modules/auto/minecraft_block_bricks.png',
    ),
    roughness: 0.86,
    metalness: 0.0,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreTrapdoorVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 0.18, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
      right: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
      left: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
      top: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
      bottom: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
      front: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
      back: 'assets/textures/modules/auto/minecraft_block_iron_trapdoor.png',
    ),
    roughness: 0.8,
    metalness: 0.05,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreHeatVentVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
      right: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
      left: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
      top: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
      bottom: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
      front: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
      back: 'assets/textures/modules/auto/gtceu_block_casings_unique_heat_vent.png',
    ),
    roughness: 0.72,
    metalness: 0.08,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreCoilVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
      right: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
      left: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
      top: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
      bottom: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
      front: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
      back: 'assets/textures/modules/auto/gtceu_block_casings_coils_machine_coil_kanthal.png',
    ),
    roughness: 0.8,
    metalness: 0.05,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreFireboxVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
      right: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
      left: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
      top: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
      bottom: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
      front: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
      back: 'assets/textures/modules/auto/gtceu_block_casings_firebox_machine_casing_firebox_titanium.png',
    ),
    roughness: 0.78,
    metalness: 0.1,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _corePipeVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
      right: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
      left: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
      top: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
      bottom: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
      front: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
      back: 'assets/textures/modules/auto/gtceu_block_casings_pipe_machine_casing_pipe_steel.png',
    ),
    roughness: 0.76,
    metalness: 0.08,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreFrameVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    faceTextures: StructureFaceTextureSet(
      all: 'assets/textures/modules/auto/minecraft_frame_gt.png',
      right: 'assets/textures/modules/auto/minecraft_frame_gt.png',
      left: 'assets/textures/modules/auto/minecraft_frame_gt.png',
      top: 'assets/textures/modules/auto/minecraft_frame_gt.png',
      bottom: 'assets/textures/modules/auto/minecraft_frame_gt.png',
      front: 'assets/textures/modules/auto/minecraft_frame_gt.png',
      back: 'assets/textures/modules/auto/minecraft_frame_gt.png',
    ),
    roughness: 0.8,
    metalness: 0.05,
    alphaTest: 0.02,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreSecureVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_casings_solid_machine_casing_clean_stainless_steel.png',
    metalness: 0.08,
    roughness: 0.65,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreBlazeVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/ctnhcore_block_casings_blaze_blast_furnace_casing.png',
    metalness: 0.04,
    roughness: 0.9,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreDiamondVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/ctnhcore_block_casings_tungstencu_diamond_plating_casing.png',
    metalness: 0.12,
    roughness: 0.64,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreControllerVisual = StructurePartVisual.cuboid(
  id: 'body',
  size: StructureVector3(1, 1, 1),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_casings_solid_machine_casing_solid_steel.png',
    metalness: 0.1,
    roughness: 0.74,
    alphaTest: 0.04,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreControllerOverlayVisual = StructurePartVisual.cuboid(
  id: 'front-overlay',
  size: StructureVector3(0.82, 0.82, 0.06),
  localOffset: StructureVector3(0, 0, 0.5),
  material: StructureMaterialStyle(
    color: 0xFFFFFFFF,
    mapAsset: 'assets/textures/modules/auto/gtceu_block_multiblock_assembly_line_overlay_front.png',
    metalness: 0.02,
    roughness: 0.56,
    alphaTest: 0.08,
    pixelated: true,
    doubleSided: true,
  ),
);

const _coreItemCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:item-import-bus-core',
    blockId: 'gtceu:item_import_bus',
    displayName: '物品输入仓',
    description: '向多方块输入待加工物品的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'item-import'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:item-export-bus-core',
    blockId: 'gtceu:item_export_bus',
    displayName: '物品输出仓',
    description: '接收已加工物品的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'item-export'],
  ),
];

const _coreFluidCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:fluid-import-hatch-core',
    blockId: 'gtceu:fluid_import_hatch',
    displayName: '流体输入仓',
    description: '向多方块输入工作流体的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'fluid-import'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:fluid-export-hatch-core',
    blockId: 'gtceu:fluid_export_hatch',
    displayName: '流体输出仓',
    description: '接收已处理流体的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'fluid-export'],
  ),
];

const _coreEnergyCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:energy-input-hatch-core',
    blockId: 'gtceu:energy_input_hatch',
    displayName: '能量输入仓',
    description: '向多方块输入电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'energy-input'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:energy-output-hatch-core',
    blockId: 'gtceu:energy_output_hatch',
    displayName: '能量输出仓',
    description: '从多方块输出电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'energy-output'],
  ),
];

const _coreMaintenanceCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:maintenance-hatch-core',
    blockId: 'gtceu:maintenance_hatch',
    displayName: '维护仓',
    description: '执行维护操作的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'maintenance'],
  ),
];

const _coreMufflerCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:muffler-core',
    blockId: 'gtceu:muffler_hatch',
    displayName: '消音仓',
    description: '降低多方块排气噪音的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'muffler'],
  ),
];

const _coreParallelCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:parallel-hatch-core',
    blockId: 'gtceu:parallel_hatch',
    displayName: '并行仓',
    description: '提高多方块并行处理能力的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'parallel'],
  ),
];

const _coreLaserCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:input-laser-source-core',
    blockId: 'gtceu:input_laser_source_hatch',
    displayName: '激光输入源',
    description: '为多方块提供输入激光的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'laser-input'],
  ),
  StructureBlockCandidate(
    id: 'gtceu:input-laser-target-core',
    blockId: 'gtceu:input_laser_target_hatch',
    displayName: '激光输入目标',
    description: '接收输入激光的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'laser-input'],
  ),
];

const _coreCircuitCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'ctnhcore:circuit-bus-core',
    blockId: 'ctnhcore:circuit_bus',
    displayName: '电路总线',
    description: '提供结构运行所需电路配线的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'circuit'],
  ),
];

const _coreKineticCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'ctpp:kinetic-input-box-core',
    blockId: 'ctpp:kinetic_input_box',
    displayName: '动能输入箱',
    description: '向多方块输入 Create 应力的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'kinetic-input'],
  ),
];

const _coreAutoAbilityCandidates = <StructureBlockCandidate>[
  ..._coreItemCandidates,
  ..._coreFluidCandidates,
  ..._coreEnergyCandidates,
  ..._coreMaintenanceCandidates,
];

const _coreEnergyInputCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:energy-input-hatch-core-input',
    blockId: 'gtceu:energy_input_hatch',
    displayName: '能量输入仓',
    description: '向多方块输入电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'energy-input'],
  ),
];

const _coreEnergyOutputCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'gtceu:energy-output-hatch-core-output',
    blockId: 'gtceu:energy_output_hatch',
    displayName: '能量输出仓',
    description: '从多方块输出电能的仓室。',
    category: StructurePartCategory.power,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['ability', 'energy-output'],
  ),
];

const _coreItemAndFluidCandidates = <StructureBlockCandidate>[
  ..._coreItemCandidates,
  ..._coreFluidCandidates,
];

const _coreMeadowCandidates = <StructureBlockCandidate>[
  ..._coreItemAndFluidCandidates,
  ..._coreKineticCandidates,
];

const _corePhotovoltaicCandidates = <StructureBlockCandidate>[
  ..._coreEnergyOutputCandidates,
  ..._coreMaintenanceCandidates,
];

const _coreBedrockCandidates = <StructureBlockCandidate>[
  ..._coreAutoAbilityCandidates,
  ..._coreParallelCandidates,
  ..._coreLaserCandidates,
];

const _corePlasmaCandidates = <StructureBlockCandidate>[
  ..._coreAutoAbilityCandidates,
  ..._coreParallelCandidates,
  ..._coreLaserCandidates,
];

const _coreCoilCandidates = <StructureBlockCandidate>[
  StructureBlockCandidate(
    id: 'ctnhcore:heating-coil-candidate',
    blockId: 'ctnhcore:heating_coil',
    displayName: '加热线圈',
    description: '用于达到加工温度要求的加热线圈。',
    category: StructurePartCategory.machine,
    state: StructurePartState.optional,
    partIds: const [],
    tags: ['replaceable', 'heating-coil'],
  ),
];

MultiblockPatternBuildResult _buildPowerSubstationPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['XXSXX', 'XXXXX', 'XXXXX', 'XXXXX', 'XXXXX'],
      ['XXXXX', 'XCCCX', 'XCCCX', 'XCCCX', 'XXXXX'],
      ['GGGGG', 'GBBBG', 'GBBBG', 'GBBBG', 'GGGGG'],
      ['GGGGG', 'GGGGG', 'GGGGG', 'GGGGG', 'GGGGG'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'S': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhenergy:power_substation',
        displayName: '蓄能变电站控制器',
        description: '控制蓄能变电站运行、输入输出和结构状态的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'power-substation-controller',
        visuals: [_controllerVisual],
        tags: ['controller', 'energy'],
      ),
      'X': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:palladium_substation_casing',
        displayName: '钯蓄能变电站外壳',
        description: '可放置高压能量仓、蓄能变电站能量仓、激光仓或维护仓的外壳位置。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'power-substation-casing',
        candidates: _powerCasingCandidates,
        visuals: [_casingVisual],
        tags: ['casing', 'ability-slot'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:palladium_substation_casing',
        displayName: '蓄能变电站内壳',
        description: '蓄能变电站中层的固定外壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'power-substation-inner-casing',
        visuals: [_casingVisual],
        tags: ['casing'],
      ),
      'G': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:laminated_glass',
        displayName: '层压玻璃',
        description: '蓄能变电站的玻璃外墙。',
        category: StructurePartCategory.display,
        partIdPrefix: 'power-substation-glass',
        visuals: [_glassVisual],
        tags: ['glass', 'shell'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:substation_battery',
        displayName: '蓄能变电站电池',
        description: '可放置任意已注册蓄能电池的仓室。',
        category: StructurePartCategory.power,
        partIdPrefix: 'power-substation-battery',
        candidates: _powerSubstationCandidates,
        visuals: [_controllerVisual],
        tags: ['battery', 'replaceable'],
      ),
    },
  ).build();
}

final _powerSubstationPattern = _buildPowerSubstationPattern();

final _powerSubstationDefinition = _makeDefinition(
  id: 'ctnhenergy:power-substation',
  title: '蓄能变电站',
  summary: '由钯蓄能变电站外壳、层压玻璃、电池层和控制器组成的蓄能变电站。',
  description: '蓄能变电站通过层压玻璃围成主体，内部放置蓄能电池，外壳位置可根据需要安装能量仓、激光仓或维护仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Energy / CEMultiblock.POWER_SUBSTATION',
  pattern: _powerSubstationPattern,
  tags: const ['Energy', '蓄能变电站', 'repeatable-aisle', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

final _powerSubstationExpandedPattern = MultiblockPatternBuilder(
  aisles: const [
    ['XXSXX', 'XXXXX', 'XXXXX', 'XXXXX', 'XXXXX'],
    ['XXXXX', 'XCCCX', 'XCCCX', 'XCCCX', 'XXXXX'],
    ['GGGGG', 'GBBBG', 'GBBBG', 'GBBBG', 'GGGGG'],
    ['GGGGG', 'GBBBG', 'GBBBG', 'GBBBG', 'GGGGG'],
    ['GGGGG', 'GGGGG', 'GGGGG', 'GGGGG', 'GGGGG'],
  ],
  aislesFromBackToFront: true,
  rowsFromTopToBottom: false,
  symbols: const {
    'S': MultiblockPatternSymbolDefinition.part(
      blockId: 'ctnhenergy:power_substation',
      displayName: '蓄能变电站控制器',
      description: '控制蓄能变电站运行、输入输出和结构状态的核心方块。',
      category: StructurePartCategory.controller,
      partIdPrefix: 'power-substation-controller',
      visuals: [_controllerVisual],
      tags: ['controller', 'energy'],
    ),
    'X': MultiblockPatternSymbolDefinition.part(
      blockId: 'gtceu:palladium_substation_casing',
      displayName: '钯蓄能变电站外壳',
      description: '可放置高压能量仓、蓄能变电站能量仓、激光仓或维护仓的外壳位置。',
      category: StructurePartCategory.casing,
      partIdPrefix: 'power-substation-casing',
      candidates: _powerCasingCandidates,
      visuals: [_casingVisual],
      tags: ['casing', 'ability-slot'],
    ),
    'C': MultiblockPatternSymbolDefinition.part(
      blockId: 'gtceu:palladium_substation_casing',
      displayName: '蓄能变电站内壳',
      description: '蓄能变电站中层的固定外壳。',
      category: StructurePartCategory.casing,
      partIdPrefix: 'power-substation-inner-casing',
      visuals: [_casingVisual],
      tags: ['casing'],
    ),
    'G': MultiblockPatternSymbolDefinition.part(
      blockId: 'gtceu:laminated_glass',
      displayName: '层压玻璃',
      description: '蓄能变电站的玻璃外墙。',
      category: StructurePartCategory.display,
      partIdPrefix: 'power-substation-glass',
      visuals: [_glassVisual],
      tags: ['glass', 'shell'],
    ),
    'B': MultiblockPatternSymbolDefinition.part(
      blockId: 'gtceu:substation_battery',
      displayName: '蓄能变电站电池',
      description: '扩展电池层中的可替换电池仓。',
      category: StructurePartCategory.power,
      partIdPrefix: 'power-substation-battery',
      candidates: _powerSubstationCandidates,
      visuals: [_controllerVisual],
      tags: ['battery', 'replaceable'],
    ),
  },
).build();

final _powerSubstationExpandedDefinition = _makeDefinition(
  id: 'ctnhenergy:power-substation-expanded',
  title: '蓄能变电站（扩展电池层）',
  summary: '蓄能变电站的扩展方案，包含额外一层电池。',
  description: '扩展方案增加一层可放置蓄能电池的仓室，主体结构和可替换外壳位置保持不变。',
  module: StructurePreviewModule.tech,
  source:
      'CTNH-Energy / CEMultiblock.POWER_SUBSTATION / repeatable battery layer',
  pattern: _powerSubstationExpandedPattern,
  tags: const ['Energy', '蓄能变电站', 'P:2', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildGreatFleshPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['AAA', 'AAA', 'AAA'],
      ['AAA', 'AAA', 'AAA'],
      ['AAA', 'A@A', 'AAA'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'biomancy:flesh_block',
        displayName: '血肉方块',
        description: '构成巨型肉块主体的血肉方块。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'great-flesh-casing',
        visuals: [_warmCasingVisual],
        tags: ['Bio', 'casing', 'living'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhbio:great_flesh',
        displayName: '巨型肉块控制器',
        description: '控制巨型肉块运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'great-flesh-controller',
        visuals: [_controllerVisual],
        tags: ['Bio', 'controller'],
      ),
    },
  ).build();
}

final _greatFleshPattern = _buildGreatFleshPattern();

final _greatFleshDefinition = _makeDefinition(
  id: 'ctnhbio:great-flesh',
  title: '巨型肉块',
  summary: '由血肉方块组成的 3x3x3 多方块结构。',
  description: '巨型肉块以血肉方块围成主体，控制器位于正面中央，用于启动加工流程。',
  module: StructurePreviewModule.magic,
  source: 'CTNH-Bio / CBMultiblocks.GREAT_FLESH',
  pattern: _greatFleshPattern,
  tags: const ['Bio', '巨型肉块', 'living-multiblock'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildGemInlayPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['BBB', 'BBB', 'BBB'],
      ['BBB', 'BCB', 'BBB'],
      ['BBB', 'B@B', 'BBB'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'botania:living_rock',
        displayName: '活石机壳',
        description: '宝石镶嵌机主体机壳，可替换为魔力仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'gem-inlay-casing',
        candidates: _manaCandidates,
        visuals: [_warmCasingVisual],
        tags: ['Mana', 'casing', 'ability-slot'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'apotheosis:gem_cutting_table',
        displayName: '宝石切割台',
        description: '宝石镶嵌机中心的宝石切割台。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'gem-inlay-table',
        visuals: [_glassVisual],
        tags: ['Mana', 'machine'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhmana:gem_inlay',
        displayName: '宝石镶嵌机控制器',
        description: '控制宝石镶嵌机运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'gem-inlay-controller',
        visuals: [_controllerVisual],
        tags: ['Mana', 'controller'],
      ),
    },
  ).build();
}

final _gemInlayPattern = _buildGemInlayPattern();

final _gemInlayDefinition = _makeDefinition(
  id: 'ctnhmana:gem-inlay',
  title: '宝石镶嵌机',
  summary: '由活石机壳、宝石切割台和控制器组成的 3x3x3 结构。',
  description: '宝石镶嵌机以活石机壳围成主体，中心安装宝石切割台，主体位置可安装魔力仓。',
  module: StructurePreviewModule.magic,
  source: 'CTNH-Mana / ManaMachine.GEM_INLAY',
  pattern: _gemInlayPattern,
  tags: const ['Mana', '宝石镶嵌机', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildRocketAssemblyPattern() {
  return MultiblockPatternBuilder(
    aisles: [
      List<String>.filled(7, 'XXXXAXXXX'),
      ...List<List<String>>.generate(
        9,
        (_) => ['BBBBBBBBB', ...List<String>.filled(6, 'XXXXXXXXX')],
      ),
      ['XXXX@XXXX', ...List<String>.filled(6, 'XXXXXXXXX')],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:stainless_steel_frame',
        displayName: '不锈钢框架',
        description: '火箭组装平台外围的不锈钢框架。',
        category: StructurePartCategory.foundation,
        partIdPrefix: 'rocket-frame',
        visuals: [_casingVisual],
        tags: ['Astral', 'frame'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:andesite_casing',
        displayName: '安山岩机壳',
        description: '火箭组装平台的安山岩机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'rocket-casing',
        visuals: [_casingVisual],
        tags: ['Astral', 'casing'],
      ),
      'X': MultiblockPatternSymbolDefinition.skip(),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhastral:rocket_assembly_platform',
        displayName: '火箭组装平台控制器',
        description: '控制火箭组装流程的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'rocket-controller',
        visuals: [_controllerVisual],
        tags: ['Astral', 'controller'],
      ),
    },
  ).build();
}

final _rocketAssemblyPattern = _buildRocketAssemblyPattern();

final _rocketAssemblyDefinition = _makeDefinition(
  id: 'ctnhastral:rocket-assembly-platform',
  title: '火箭组装平台',
  summary: '由不锈钢框架、安山岩机壳和控制器组成的火箭组装平台。',
  description: '火箭组装平台以安山岩机壳组成主体，外包围不锈钢框架，控制器用于启动组装流程。',
  module: StructurePreviewModule.adventure,
  source: 'CTNH-Astral / CAMultiblocks.ROCKET_ASSEMBLY_PLATFORM',
  pattern: _rocketAssemblyPattern,
  tags: const ['Astral', '火箭', 'structure', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildSmashingFactoryPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['AAAAA', 'ABBBA', 'ABBBA'],
      ['AAAAA', 'A   A', 'AC CA'],
      ['AAAAA', 'A   A', 'AC CA'],
      ['AAAAA', 'A   A', 'AC CA'],
      ['AAAAA', 'AB@BA', 'ABBBA'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:andesite_casing',
        displayName: '安山岩机壳',
        description: '粉碎工厂外壳位置的默认方块。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'smashing-casing',
        visuals: [_casingVisual],
        tags: ['CTPP', 'casing'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:andesite_casing',
        displayName: '可替换仓室',
        description: '可安装动能输入箱、机械升级仓或物品输入/输出仓，不能安装能量仓。',
        category: StructurePartCategory.power,
        partIdPrefix: 'smashing-ability',
        candidates: _kineticCandidates,
        visuals: [_controllerVisual],
        tags: ['CTPP', 'replaceable', 'hatch'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:crushing_wheel',
        displayName: '粉碎轮',
        description: '执行粉碎加工的粉碎轮。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'smashing-wheel',
        visuals: [_warmCasingVisual],
        tags: ['CTPP', 'machine'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctpp:smashing_factory',
        displayName: '粉碎工厂控制器',
        description: '控制粉碎工厂运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'smashing-controller',
        visuals: [_controllerVisual],
        tags: ['CTPP', 'controller'],
      ),
      ' ': MultiblockPatternSymbolDefinition.skip(),
    },
  ).build();
}

final _smashingFactoryPattern = _buildSmashingFactoryPattern();

final _smashingFactoryDefinition = _makeDefinition(
  id: 'ctpp:smashing-factory',
  title: '粉碎工厂',
  summary: '5x3x5 多方块结构，使用 Create 应力驱动粉碎轮。',
  description: '粉碎工厂主体使用安山岩机壳，内部安装一台粉碎轮；正面位置可放置动能输入箱、机械升级仓或物品输入/输出仓。',
  module: StructurePreviewModule.tech,
  source: 'CTPP / CTPPMultiblockMachines.SMASHING_FACTORY',
  pattern: _smashingFactoryPattern,
  tags: const ['CTPP', '粉碎工厂', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreUnderfloorPattern() {
  return MultiblockPatternBuilder(
    aisles: [
      ['AAAAAAAAAAAAAAAA'],
      ...List<List<String>>.generate(14, (_) => ['AAAAAAAABAAAAAAA']),
      ['AAAAAAAA@AAAAAAA'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:copper_shingles',
        displayName: '铜瓦',
        description: '地暖系统铜瓦外壳，可替换为流体输入或输出仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'underfloor-casing',
        candidates: _coreFluidCandidates,
        visuals: [_coreCopperVisual],
        tags: ['Core', 'casing', 'ability-slot', 'weathering-candidate'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:bronze_pipe_casing',
        displayName: '青铜管道',
        description: '用于输送供热流体的青铜管道。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'underfloor-pipe',
        visuals: [_coreSteelVisual],
        tags: ['Core', 'pipe'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:underfloor_heating_system',
        displayName: '地暖系统控制器',
        description: '控制地暖系统运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'underfloor-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _coreUnderfloorPattern = _buildCoreUnderfloorPattern();

final _coreUnderfloorDefinition = _makeDefinition(
  id: 'ctnhcore:underfloor-heating-system',
  title: '地暖系统',
  summary: '由铜瓦、青铜管道和控制器组成的 16x1x16 结构。',
  description: '地暖系统以铜瓦形成单层平面结构，中央覆盖青铜管道，铜瓦位置可安装流体输入或输出仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.UNDERFLOOR_HEATING_SYSTEM',
  pattern: _coreUnderfloorPattern,
  tags: const ['Core', '地暖系统', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreObservatoryPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      [
        '   BBB   ',
        '   BBB   ',
        '   BBB   ',
        '   BBB   ',
        '   BBB   ',
        '   RDR   ',
        '         ',
        '         ',
        '         ',
      ],
      [
        '  BBBBB  ',
        '  B   B  ',
        '  B E B  ',
        '  B F B  ',
        '  B   B  ',
        '  R   R  ',
        '   RDR   ',
        '         ',
        '         ',
      ],
      [
        ' BBBBBBB ',
        ' B     B ',
        ' B  E  B ',
        ' B  F  B ',
        ' B     B ',
        ' R     R ',
        '  R   R  ',
        '   RDR   ',
        '         ',
      ],
      [
        'BBBBBBBBB',
        'B       B',
        'B   E   B',
        'B   F   B',
        'B       B',
        'R       R',
        ' R     R ',
        '  R   R  ',
        '   RDR   ',
      ],
      [
        'BBBBBBBBB',
        'B       B',
        'BEEEEEEEB',
        'B   F   B',
        'B       B',
        'R       R',
        ' R     R ',
        '  R   R  ',
        '   RDR   ',
      ],
      [
        'BBBBBBBBB',
        'B       B',
        'B   E   B',
        'B   F   B',
        'B       B',
        'R       R',
        ' R     R ',
        '  R   R  ',
        '   RDR   ',
      ],
      [
        ' BBBBBBB ',
        ' B     B ',
        ' B  E  B ',
        ' B  F  B ',
        ' B     B ',
        ' R     R ',
        '  R   R  ',
        '   RDR   ',
        '         ',
      ],
      [
        '  BBBBB  ',
        '  B   B  ',
        '  B E B  ',
        '  B F B  ',
        '  B   B  ',
        '  R   R  ',
        '   RDR   ',
        '         ',
        '         ',
      ],
      [
        '   BBB   ',
        '   B@B   ',
        '   BAB   ',
        '   BBB   ',
        '   BBB   ',
        '   RDR   ',
        '         ',
        '         ',
        '         ',
      ],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      ' ': MultiblockPatternSymbolDefinition.skip(),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:circuit_ability',
        displayName: '电路总线',
        description: '可安装用于提供电路配线的电路总线。',
        category: StructurePartCategory.power,
        partIdPrefix: 'observatory-circuit',
        state: StructurePartState.optional,
        candidates: _coreCircuitCandidates,
        visuals: [_coreReflectVisual],
        tags: ['Core', 'replaceable', 'circuit'],
      ),
      'R': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:reflect_light_casing',
        displayName: '反光机壳',
        description: '用于反射光线并形成主体结构的天文台机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'observatory-reflect',
        visuals: [_coreReflectVisual],
        tags: ['Core', 'casing'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:stainless_steel_casing',
        displayName: '不锈钢机壳/能量输入位',
        description: '可安装一个能量输入仓的不锈钢机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'observatory-casing',
        candidates: _coreEnergyInputCandidates,
        visuals: [_coreCleanSteelVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tempered_glass',
        displayName: '强化玻璃',
        description: '天文台观察窗，用于保持封闭并观察天体。',
        category: StructurePartCategory.display,
        partIdPrefix: 'observatory-glass',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'glass'],
      ),
      'E': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:hv_hull',
        displayName: 'HV 机壳',
        description: '构成天文台主体的 HV 机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'observatory-hv-hull',
        visuals: [_coreCleanSteelVisual],
        tags: ['Core', 'hull'],
      ),
      'F': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:daylight_detector',
        displayName: '光照传感器',
        description: '用于读取观测区域光照状态的传感器。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'observatory-daylight',
        visuals: [_coreReflectVisual],
        tags: ['Core', 'sensor'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:astronomical_observatory',
        displayName: '天体观测站控制器',
        description: '控制天文台运行和观测流程的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'observatory-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _coreObservatoryPattern = _buildCoreObservatoryPattern();

final _coreObservatoryDefinition = _makeDefinition(
  id: 'ctnhcore:astronomical-observatory',
  title: '天体观测站',
  summary: '由反光机壳、强化玻璃、HV 机壳和控制器组成的 9x9x9 结构。',
  description: '天文台以反光机壳形成主体，观察窗、HV 机壳和电路位置按实际结构布置，控制器用于启动观测流程。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.ASTRONOMICAL_OBSERVATORY',
  pattern: _coreObservatoryPattern,
  tags: const ['Core', '天体观测站', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCorePhotovoltaicPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      [
        '#AAAAAAA#',
        '#########',
        '#AAAAAAA#',
        '####B####',
        '####B####',
        '####B####',
        '#########',
      ],
      [
        'AAAAAAAAA',
        '##AAAAA##',
        'AAAAAAAAA',
        '#########',
        '#########',
        '##CCCCC##',
        '#CC###CC#',
      ],
      [
        'AAAAAAAAA',
        '#AA###AA#',
        'AAADDDAAA',
        '#########',
        '#########',
        '##CEEEC##',
        '#CE###EC#',
      ],
      [
        'AAAAAAAAA',
        '#A#####A#',
        'AADDDDDAA',
        '#########',
        '#########',
        '##CEEEC##',
        '#CE###EC#',
      ],
      [
        'AAAAAAAAA',
        '#A#####A#',
        'AADDDDDAA',
        '#########',
        '#########',
        '##CEEEC##',
        '#CE###EC#',
      ],
      [
        'AAAAAAAAA',
        '#A#####A#',
        'AADDDDDAA',
        '#########',
        '#########',
        '##CEEEC##',
        '#CE###EC#',
      ],
      [
        'AAAAAAAAA',
        '#AA###AA#',
        'AAADDDAAA',
        '#########',
        '#########',
        '##CEEEC##',
        '#CE###EC#',
      ],
      [
        'AAAAAAAAA',
        '##AAAAA##',
        'AAAAAAAAA',
        '#########',
        '#########',
        '##CCCCC##',
        '#CC###CC#',
      ],
      [
        '#AAA@AAA#',
        '#########',
        '#AAAAAAA#',
        '####B####',
        '####B####',
        '####B####',
        '#########',
      ],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      ' ': MultiblockPatternSymbolDefinition.skip(),
      '#': MultiblockPatternSymbolDefinition.skip(),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:reflect_light_casing',
        displayName: '反光机壳/输出能力位',
        description: '光伏电站反光机壳，可安装能量输出或维护仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'photovoltaic-casing',
        candidates: _corePhotovoltaicCandidates,
        visuals: [_coreReflectVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:metal_girder',
        displayName: '金属桁架',
        description: '固定光伏模块并支撑主体结构的金属桁架。',
        category: StructurePartCategory.foundation,
        partIdPrefix: 'photovoltaic-girder',
        visuals: [_coreGirderVisual],
        tags: ['Core', 'foundation'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:reflect_light_casing',
        displayName: '反光机壳',
        description: '反射阳光并构成主体结构的光伏电站机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'photovoltaic-reflect',
        visuals: [_coreReflectVisual],
        tags: ['Core', 'casing'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tempered_glass',
        displayName: '强化玻璃',
        description: '光伏电站的观察窗和防护外壳。',
        category: StructurePartCategory.display,
        partIdPrefix: 'photovoltaic-glass',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'glass'],
      ),
      'E': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:energetic_photovoltaic_block',
        displayName: '能量光伏方块',
        description: '用于输出电能的能量光伏模块。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'photovoltaic-block',
        visuals: [_coreReflectVisual],
        tags: ['Core', 'photovoltaic'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:photovoltaic_power_station_energetic',
        displayName: '光伏电站控制器',
        description: '控制光伏电站运行和能量输出的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'photovoltaic-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _corePhotovoltaicPattern = _buildCorePhotovoltaicPattern();

final _corePhotovoltaicDefinition = _makeDefinition(
  id: 'ctnhcore:photovoltaic-power-station-energetic',
  title: '光伏发电站（能量态）',
  summary: '由反光机壳、金属桁架、强化玻璃和能量光伏方块组成的 9x7x9 结构。',
  description: '能量态光伏电站以反光机壳和金属桁架构成主体，能量光伏方块负责输出电能，壳体位置可安装维护仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.PHOTOVOLTAIC_POWER_STATION_ENERGETIC',
  pattern: _corePhotovoltaicPattern,
  tags: const ['Core', '光伏发电站', 'energy', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreSlaughterPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['ABBBA', 'ABBBA', 'CCCCC', 'CCCCC', 'CCCCC', 'CCCCC', 'ABBBA'],
      ['BAAAB', 'BDDDB', 'CDDDC', 'CDDDC', 'CDDDC', 'CDDDC', 'BAAAB'],
      ['BAAAB', 'BD#DB', 'CD#DC', 'CD#DC', 'CD#DC', 'CD#DC', 'BAEAB'],
      ['BAAAB', 'BDDDB', 'CDDDC', 'CDDDC', 'CDDDC', 'CDDDC', 'BAAAB'],
      ['AB@BA', 'ABBBA', 'CCCCC', 'CCCCC', 'CCCCC', 'CCCCC', 'ABBBA'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      '#': MultiblockPatternSymbolDefinition.skip(),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:machine_casing_solid_steel',
        displayName: '实心钢机壳',
        description: '构成宰杀场主体的实心钢机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'slaughter-steel',
        visuals: [_coreSteelVisual],
        tags: ['Core', 'casing'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:machine_casing_solid_steel',
        displayName: '实心钢机壳/能力位',
        description: '宰杀场可替换机壳，可安装物品、流体、能量或维护仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'slaughter-ability-casing',
        candidates: _coreAutoAbilityCandidates,
        visuals: [_coreSteelVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tempered_glass',
        displayName: '强化玻璃',
        description: '宰杀场观察窗和封闭防护层。',
        category: StructurePartCategory.display,
        partIdPrefix: 'slaughter-glass',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'glass'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:dark_steel_bars',
        displayName: '暗钢栏杆',
        description: '用于隔离宰杀区域的暗钢栏杆。',
        category: StructurePartCategory.display,
        partIdPrefix: 'slaughter-bars',
        visuals: [_coreBarsVisual],
        tags: ['Core', 'display'],
      ),
      'E': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:muffler_hatch',
        displayName: '消音仓',
        description: '降低宰杀场排气噪音的仓室。',
        category: StructurePartCategory.power,
        partIdPrefix: 'slaughter-muffler',
        visuals: [_coreControllerVisual],
        tags: ['Core', 'ability', 'muffler'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:slaughter_house',
        displayName: '宰杀场控制器',
        description: '控制宰杀场运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'slaughter-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _coreSlaughterPattern = _buildCoreSlaughterPattern();

final _coreSlaughterDefinition = _makeDefinition(
  id: 'ctnhcore:slaughter-house',
  title: '宰杀场',
  summary: '由实心钢机壳、强化玻璃、暗钢栏杆和控制器组成的 5x7x5 结构。',
  description: '宰杀场以实心钢机壳围成主体，设置观察窗、暗钢栏杆和消音仓；可替换机壳可安装物品、流体、能量或维护仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.SLAUGHTER_HOUSE',
  pattern: _coreSlaughterPattern,
  tags: const ['Core', '宰杀场', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreCokePattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      [
        'ABBBA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        '#ACA#',
      ],
      [
        'BDDDB',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'ACCCA',
      ],
      [
        'BDDDB',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CFGFC',
        'CEGEC',
        'CCHCC',
      ],
      [
        'BDDDB',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'CFFFC',
        'CEEEC',
        'ACCCA',
      ],
      [
        'ABBBA',
        'ACCCA',
        'AC@CA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        'ACCCA',
        '#ACA#',
      ],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      '#': MultiblockPatternSymbolDefinition.skip(),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:stainless_steel_frame',
        displayName: '不锈钢框架',
        description: '焦炉塔主体外围的不锈钢框架。',
        category: StructurePartCategory.foundation,
        partIdPrefix: 'coke-frame',
        visuals: [_coreFrameVisual],
        tags: ['Core', 'frame'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:heat_vent',
        displayName: '散热口',
        description: '用于排出焦炉塔废热的散热口。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'coke-heat-vent',
        visuals: [_coreHeatVentVisual],
        tags: ['Core', 'machine'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:machine_casing_clean_stainless_steel',
        displayName: '洁净不锈钢机壳/能力位',
        description: '焦炉塔可替换机壳，可安装物品、流体、能量或维护仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'coke-casing',
        candidates: _coreAutoAbilityCandidates,
        visuals: [_coreCleanSteelVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:firebox_titanium',
        displayName: '钛炉膛',
        description: '承受高温加工环境的钛炉膛。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'coke-firebox',
        visuals: [_coreFireboxVisual],
        tags: ['Core', 'firebox'],
      ),
      'E': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:heating_coil',
        displayName: '加热线圈',
        description: '满足焦炉塔加工温度要求的加热线圈。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'coke-coil',
        candidates: _coreCoilCandidates,
        visuals: [_coreCoilVisual],
        tags: ['Core', 'coil', 'replaceable'],
      ),
      'F': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:invar_heatproof_casing',
        displayName: '殷钢耐热机壳',
        description: '焦炉塔耐高温主体机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'coke-invar',
        visuals: [_coreSteelVisual],
        tags: ['Core', 'casing'],
      ),
      'G': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:steel_pipe_casing',
        displayName: '钢管道',
        description: '用于输送焦炉塔工作流体的钢管道。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'coke-pipe',
        visuals: [_corePipeVisual],
        tags: ['Core', 'pipe'],
      ),
      'H': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:muffler_hatch',
        displayName: '消音仓',
        description: '降低焦炉塔排气噪音的仓室。',
        category: StructurePartCategory.power,
        partIdPrefix: 'coke-muffler',
        visuals: [_coreControllerVisual],
        tags: ['Core', 'ability', 'muffler'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:coke_tower',
        displayName: '焦炉塔控制器',
        description: '控制焦炉塔运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'coke-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _coreCokePattern = _buildCoreCokePattern();

final _coreCokeDefinition = _makeDefinition(
  id: 'ctnhcore:coke-tower',
  title: '焦炉塔',
  summary: '由不锈钢框架、洁净不锈钢机壳、炉膛、加热线圈和控制器组成的 5x17x5 结构。',
  description: '焦炉塔以洁净不锈钢机壳形成高层主体，内部设置钛炉膛和加热线圈；可替换机壳可安装物品、流体、能量或维护仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.COKE_TOWER',
  pattern: _coreCokePattern,
  tags: const ['Core', '焦炉塔', 'coil', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreBedrockPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      [
        '#######',
        'AAAAAAA',
        'A#####A',
        'A#####A',
        'A#####A',
        'A#####A',
        'A#####A',
        'AAAAAAA',
      ],
      [
        '#######',
        'A#####A',
        '#######',
        '#B###B#',
        '#######',
        '#######',
        '#######',
        'AB###BA',
      ],
      [
        '#######',
        'A#####A',
        '##BCB##',
        '###C###',
        '##CCC##',
        '##CCC##',
        '##CCC##',
        'A#BCB#A',
      ],
      [
        '###E###',
        'A##C##A',
        '##CCC##',
        '##CDC##',
        '##CDC##',
        '##CDC##',
        '##CDC##',
        'A#CCC#A',
      ],
      [
        '#######',
        'A#####A',
        '##BCB##',
        '###C###',
        '##CCC##',
        '##C@C##',
        '##CCC##',
        'A#BCB#A',
      ],
      [
        '#######',
        'A#####A',
        '#######',
        '#B###B#',
        '#######',
        '#######',
        '#######',
        'AB###BA',
      ],
      [
        '#######',
        'AAAAAAA',
        'A#####A',
        'A#####A',
        'A#####A',
        'A#####A',
        'A#####A',
        'AAAAAAA',
      ],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      '#': MultiblockPatternSymbolDefinition.skip(),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:secure_maceration_casing',
        displayName: '安全粉碎机壳',
        description: '基岩钻机主体使用的安全粉碎机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'bedrock-secure-casing',
        visuals: [_coreSecureVisual],
        tags: ['Core', 'casing'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tungsten_carbide_frame',
        displayName: '碳化钨框架',
        description: '基岩钻机主体外围的碳化钨框架。',
        category: StructurePartCategory.foundation,
        partIdPrefix: 'bedrock-frame',
        visuals: [_coreFrameVisual],
        tags: ['Core', 'frame'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:tungstencu_diamond_plating_casing',
        displayName: '铜钨碳金刚石镀层机壳/能力位',
        description: '基岩钻机可替换机壳，可安装物品、流体、能量、并行或激光仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'bedrock-casing',
        candidates: _coreBedrockCandidates,
        visuals: [_coreDiamondVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tungsten_steel_pipe_casing',
        displayName: '钨钢管道',
        description: '用于输送基岩钻机工作流体的钨钢管道。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'bedrock-pipe',
        visuals: [_corePipeVisual],
        tags: ['Core', 'pipe'],
      ),
      'E': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:bedrock',
        displayName: '基岩',
        description: '钻头接触基岩并进行采样的位置。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'bedrock-block',
        visuals: [_coreSecureVisual],
        tags: ['Core', 'bedrock'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:bedrock_drilling_rigs',
        displayName: '基岩钻机控制器',
        description: '控制基岩钻机运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'bedrock-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _coreBedrockPattern = _buildCoreBedrockPattern();

final _coreBedrockDefinition = _makeDefinition(
  id: 'ctnhcore:bedrock-drilling-rigs',
  title: '基岩钻机',
  summary: '由安全粉碎机壳、碳化钨框架、铜钨碳金刚石镀层机壳和控制器组成的 7x8x7 结构。',
  description: '基岩钻机以安全粉碎机壳和碳化钨框架形成主体，内部设置钻头采样位；可替换机壳可安装物品、流体、能量、并行或激光仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.BEDROCK_DRILLING_RIGS',
  pattern: _coreBedrockPattern,
  tags: const ['Core', '基岩钻机', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCorePlasmaPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['#####AAA#####', '#####AAA#####', '#####AAA#####'],
      ['####AAAAA####', '####BCCCB####', '####AAAAA####'],
      ['##AAAAAAAAA##', '##AACABACAA##', '##AAAAAAAAA##'],
      ['##AAA###AAA##', '##ACA###ACA##', '##AAA###AAA##'],
      ['#AAA#####AAA#', '#BCA#####ACB#', '#AAA#####AAA#'],
      ['AAA#######AAA', 'ACA#######ACA', 'AAA#######AAA'],
      ['AAA#######AAA', 'ACB#######BCA', 'AAA#######AAA'],
      ['AAA#######AAA', 'ACA#######ACA', 'AAA#######AAA'],
      ['#AAA#####AAA#', '#BCA#####ACB#', '#AAA#####AAA#'],
      ['##AAA###AAA##', '##ACA###ACA##', '##AAA###AAA##'],
      ['##AAAAAAAAA##', '##AACABACAA##', '##AAAAAAAAA##'],
      ['####AAAAA####', '####BCCCB####', '####AAAAA####'],
      ['#####AAA#####', '#####A@A#####', '#####AAA#####'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      '#': MultiblockPatternSymbolDefinition.skip(),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:antifreeze_heatproof_machine_casing',
        displayName: '防冻耐热机壳/能力位',
        description: '等离子冷凝器可替换机壳，可安装物品、流体、能量、并行或激光仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'plasma-casing',
        candidates: _corePlasmaCandidates,
        visuals: [_coreSteelVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tempered_glass',
        displayName: '强化玻璃',
        description: '等离子冷凝器观察窗和封闭防护层。',
        category: StructurePartCategory.display,
        partIdPrefix: 'plasma-glass',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'glass'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:plasma_cooled_core',
        displayName: '等离子冷却核心',
        description: '用于冷凝和回收等离子的核心装置。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'plasma-core',
        visuals: [_coreReflectVisual],
        tags: ['Core', 'machine'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:plasma_condenser',
        displayName: '等离子冷凝器控制器',
        description: '控制等离子冷凝器运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'plasma-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _corePlasmaPattern = _buildCorePlasmaPattern();

final _corePlasmaDefinition = _makeDefinition(
  id: 'ctnhcore:plasma-condenser',
  title: '等离子冷凝器',
  summary: '由防冻耐热机壳、强化玻璃、等离子冷却核心和控制器组成的 13x3x13 结构。',
  description: '等离子冷凝器以防冻耐热机壳形成主体，内部设置等离子冷却核心；可替换机壳可安装维护、并行、激光或能量输入仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.PLASMA_CONDENSER',
  pattern: _corePlasmaPattern,
  tags: const ['Core', '等离子冷凝器', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreMeadowPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      [
        'BBBBBBBBBBB',
        'JCCCJCCCCCC',
        'J###J######',
        'JJJJJD#####',
        'EEEEE######',
        '###########',
      ],
      [
        'BBBBFFFBBBB',
        'CEE####GG#C',
        '#E#####GG##',
        'J###JD#####',
        'EEEEE######',
        '#EEE#######',
      ],
      [
        'BBBBFFFBBBB',
        'CE#####GG#C',
        '###########',
        'J###JD#####',
        'EEEEE######',
        '#EEE#######',
      ],
      [
        'BBBBFFFBBBB',
        'C#######G#C',
        '###########',
        'J###JD#####',
        'EEEEE######',
        '#EEE#######',
      ],
      [
        'BBBBBFFBBBB',
        'J###J#####C',
        'J###J######',
        'JJJJJD#####',
        'EEEEE######',
        '###########',
      ],
      [
        'BEEBFFFHHHB',
        'C#########C',
        '###########',
        'DDDDDD#####',
        '###########',
        '###########',
      ],
      [
        'BEEBFFFHHHB',
        'C######II#C',
        '###########',
        '###########',
        '###########',
        '###########',
      ],
      [
        'BEEBFFFHHHB',
        'C#######I#C',
        '###########',
        '###########',
        '###########',
        '###########',
      ],
      [
        'BEEBFFFBHHB',
        'C#########C',
        '###########',
        '###########',
        '###########',
        '###########',
      ],
      [
        'BEEBFFFBHHB',
        'C########IC',
        '###########',
        '###########',
        '###########',
        '###########',
      ],
      [
        'BBBBB@BBBBB',
        'CCCCCCCCCCC',
        '###########',
        '###########',
        '###########',
        '###########',
      ],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      '#': MultiblockPatternSymbolDefinition.skip(),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:grass_block',
        displayName: '草方块/可替换位',
        description: '牧场的泥土或草方块位置，可安装物品、流体仓或动能输入箱。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'meadow-ground',
        candidates: _coreMeadowCandidates,
        visuals: [_coreGrassVisual],
        tags: ['Core', 'ground', 'ability-slot'],
      ),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:oak_fence',
        displayName: '橡木栅栏',
        description: '用于围合牧场区域的橡木栅栏。',
        category: StructurePartCategory.display,
        partIdPrefix: 'meadow-fence',
        visuals: [_coreOakFenceVisual],
        tags: ['Core', 'fence'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:oak_stairs',
        displayName: '橡木楼梯',
        description: '牧场区域的橡木楼梯。',
        category: StructurePartCategory.display,
        partIdPrefix: 'meadow-stairs',
        visuals: [_coreOakStairsVisual],
        tags: ['Core', 'stairs'],
      ),
      'E': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:hay_block',
        displayName: '干草块',
        description: '牧场区域摆放的干草块。',
        category: StructurePartCategory.decoration,
        partIdPrefix: 'meadow-hay',
        visuals: [_coreHayVisual],
        tags: ['Core', 'hay'],
      ),
      'F': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:dirt_path',
        displayName: '土径',
        description: '牧场区域的泥土路径。',
        category: StructurePartCategory.decoration,
        partIdPrefix: 'meadow-path',
        visuals: [_coreDirtPathVisual],
        tags: ['Core', 'path'],
      ),
      'G': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:bone_block',
        displayName: '骨块',
        description: '牧场区域摆放的骨块。',
        category: StructurePartCategory.decoration,
        partIdPrefix: 'meadow-bone',
        visuals: [_coreBoneVisual],
        tags: ['Core', 'bone'],
      ),
      'H': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:water',
        displayName: '水',
        description: '牧场区域的水体。',
        category: StructurePartCategory.display,
        partIdPrefix: 'meadow-water',
        visuals: [_coreWaterVisual],
        tags: ['Core', 'water'],
      ),
      'I': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:lily_pad',
        displayName: '睡莲',
        description: '牧场水体上生长的睡莲。',
        category: StructurePartCategory.decoration,
        partIdPrefix: 'meadow-lily',
        visuals: [_coreLilyPadVisual],
        tags: ['Core', 'lily'],
      ),
      'J': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:oak_log',
        displayName: '橡木原木',
        description: '牧场区域摆放的橡木原木。',
        category: StructurePartCategory.decoration,
        partIdPrefix: 'meadow-log',
        visuals: [_coreOakLogVisual],
        tags: ['Core', 'log'],
      ),
      '@': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:meadow',
        displayName: '牧场控制器',
        description: '控制牧场结构运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'meadow-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
    },
  ).build();
}

final _coreMeadowPattern = _buildCoreMeadowPattern();

final _coreMeadowDefinition = _makeDefinition(
  id: 'ctnhcore:meadow',
  title: '牧场',
  summary: '由草方块、橡木栅栏、干草、水体、睡莲和控制器组成的 11x6x11 结构。',
  description: '牧场以草方块形成地面，搭配橡木栅栏、楼梯、原木、干草、水体、睡莲和骨块；地面位置可安装物品、流体仓或动能输入箱。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.MEADOW',
  pattern: _coreMeadowPattern,
  tags: const ['Core', '牧场', 'natural', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreFermentingPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['C   C', 'C   C', 'CCCCC', 'H   H', 'H   H', 'H   H', 'DAAAD'],
      ['     ', ' GGG ', 'CGGGC', ' MMM ', ' GGG ', ' GGG ', 'AAAAA'],
      ['     ', ' GGG ', 'CG GC', ' M M ', ' G G ', ' G G ', 'AABAA'],
      ['     ', ' GGG ', 'CGGGC', ' MMM ', ' GGG ', ' GGG ', 'AAAAA'],
      ['C   C', 'CAKAC', 'CAAAC', 'H   H', 'H   H', 'H   H', 'DAAAD'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      ' ': MultiblockPatternSymbolDefinition.skip(),
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:steel_frame',
        displayName: '钢框架',
        description: '发酵罐主体外围的钢框架。',
        category: StructurePartCategory.foundation,
        partIdPrefix: 'fermenting-frame',
        visuals: [_coreFrameVisual],
        tags: ['Core', 'frame'],
      ),
      'H': MultiblockPatternSymbolDefinition.part(
        blockId: 'create:metal_girder',
        displayName: '金属桁架',
        description: '支撑发酵罐主体结构的金属桁架。',
        category: StructurePartCategory.foundation,
        partIdPrefix: 'fermenting-girder',
        visuals: [_coreGirderVisual],
        tags: ['Core', 'foundation'],
      ),
      'K': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:fermenting_tank',
        displayName: '发酵罐控制器',
        description: '控制发酵罐运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'fermenting-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
      'M': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:heating_coil',
        displayName: '加热线圈',
        description: '满足发酵温度要求的加热线圈。',
        category: StructurePartCategory.machine,
        partIdPrefix: 'fermenting-coil',
        candidates: _coreCoilCandidates,
        visuals: [_coreCoilVisual],
        tags: ['Core', 'coil', 'replaceable'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:machine_casing_solid_steel',
        displayName: '实心钢机壳',
        description: '构成发酵罐主体的实心钢机壳。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'fermenting-steel',
        visuals: [_coreSteelVisual],
        tags: ['Core', 'casing'],
      ),
      'B': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:muffler_hatch',
        displayName: '消音仓',
        description: '降低发酵罐排气噪音的仓室。',
        category: StructurePartCategory.power,
        partIdPrefix: 'fermenting-muffler',
        visuals: [_coreControllerVisual],
        tags: ['Core', 'ability', 'muffler'],
      ),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:machine_casing_solid_steel',
        displayName: '实心钢机壳/能力位',
        description: '发酵罐可替换机壳，可安装物品、流体、能量或维护仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'fermenting-casing',
        candidates: _coreAutoAbilityCandidates,
        visuals: [_coreSteelVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'G': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tempered_glass',
        displayName: '强化玻璃',
        description: '发酵罐观察窗和封闭防护层。',
        category: StructurePartCategory.display,
        partIdPrefix: 'fermenting-glass',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'glass'],
      ),
    },
  ).build();
}

final _coreFermentingPattern = _buildCoreFermentingPattern();

final _coreFermentingDefinition = _makeDefinition(
  id: 'ctnhcore:fermenting-tank',
  title: '发酵罐',
  summary: '由钢框架、金属桁架、实心钢机壳、加热线圈和控制器组成的 5x7x5 结构。',
  description: '发酵罐以实心钢机壳形成主体，内部设置加热线圈和金属桁架；可替换机壳可安装物品、流体、能量或维护仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.FERMENTING_TANK',
  pattern: _coreFermentingPattern,
  tags: const ['Core', '发酵罐', 'coil', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

MultiblockPatternBuildResult _buildCoreDigestionPattern() {
  return MultiblockPatternBuilder(
    aisles: const [
      ['CCCCC', 'CAAAC', 'CCCCC'],
      ['CCCCC', 'AWWWA', 'CDDDC'],
      ['CCCCC', 'CAKAC', 'CGGGC'],
    ],
    aislesFromBackToFront: true,
    rowsFromTopToBottom: false,
    symbols: const {
      'C': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:bricks',
        displayName: '砖块',
        description: '构成消化罐主体的砖块。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'digestion-bricks',
        visuals: [_warmCasingVisual],
        tags: ['Core', 'casing'],
      ),
      'K': MultiblockPatternSymbolDefinition.part(
        blockId: 'ctnhcore:digestion_tank',
        displayName: '消化罐控制器',
        description: '控制消化罐运行的核心方块。',
        category: StructurePartCategory.controller,
        partIdPrefix: 'digestion-controller',
        visuals: [_coreControllerVisual, _coreControllerOverlayVisual],
        tags: ['Core', 'controller'],
      ),
      'D': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:iron_trapdoor',
        displayName: '铁活板门',
        description: '消化罐维护和观察用的铁活板门。',
        category: StructurePartCategory.display,
        partIdPrefix: 'digestion-trapdoor',
        visuals: [_coreTrapdoorVisual],
        tags: ['Core', 'display'],
      ),
      'A': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:bricks',
        displayName: '砖块/能力位',
        description: '消化罐可替换砖块，可安装物品、流体、能量或维护仓。',
        category: StructurePartCategory.casing,
        partIdPrefix: 'digestion-ability',
        candidates: _coreAutoAbilityCandidates,
        visuals: [_warmCasingVisual],
        tags: ['Core', 'casing', 'ability-slot'],
      ),
      'G': MultiblockPatternSymbolDefinition.part(
        blockId: 'gtceu:tempered_glass',
        displayName: '强化玻璃',
        description: '消化罐观察窗和封闭防护层。',
        category: StructurePartCategory.display,
        partIdPrefix: 'digestion-glass',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'glass'],
      ),
      'W': MultiblockPatternSymbolDefinition.part(
        blockId: 'minecraft:water',
        displayName: '水',
        description: '消化罐内部用于处理物料的水体。',
        category: StructurePartCategory.display,
        partIdPrefix: 'digestion-water',
        visuals: [_coreGlassVisual],
        tags: ['Core', 'water'],
      ),
    },
  ).build();
}

final _coreDigestionPattern = _buildCoreDigestionPattern();

final _coreDigestionDefinition = _makeDefinition(
  id: 'ctnhcore:digestion-tank',
  title: '消化罐',
  summary: '由砖块、强化玻璃、铁活板门、水和控制器组成的 5x3x3 结构。',
  description: '消化罐以砖块形成主体，内部设置水体和铁活板门，强化玻璃用于观察；砖块位置可安装物品、流体、能量或维护仓。',
  module: StructurePreviewModule.tech,
  source: 'CTNH-Core / MultiblocksA.DIGESTION_TANK',
  pattern: _coreDigestionPattern,
  tags: const ['Core', '消化罐', 'water', 'replaceable'],
  casingIds: const [],
  controllerIds: const [],
);

StructurePreviewDefinition _makeDefinition({
  required String id,
  required String title,
  required String summary,
  required String description,
  required StructurePreviewModule module,
  required String source,
  required MultiblockPatternBuildResult pattern,
  required List<String> tags,
  required List<String> casingIds,
  required List<String> controllerIds,
}) {
  final allPartIds = pattern.parts
      .map((part) => part.id)
      .toList(growable: false);
  final controllerPartIds = pattern.parts
      .where((part) => part.category == StructurePartCategory.controller)
      .map((part) => part.id)
      .toList(growable: false);
  final effectiveControllerIds = controllerIds.isEmpty
      ? controllerPartIds
      : controllerIds;
  final effectiveCasingIds = casingIds.isEmpty
      ? pattern.parts
            .where((part) => part.category == StructurePartCategory.casing)
            .map((part) => part.id)
            .toList(growable: false)
      : casingIds;

  return StructurePreviewDefinition(
    id: id,
    metadata: StructurePreviewMetadata(
      title: title,
      summary: summary,
      description: description,
      module: module,
      status: StructurePreviewStatus.published,
      tags: tags,
      source: source,
    ),
    camera: StructureCameraConfig(
      position: StructureVector3(
        pattern.width * 1.55,
        pattern.height * 1.25,
        pattern.depth * 1.55,
      ),
      target: StructureVector3(0, pattern.height * 0.42, 0),
      minDistance: 3.5,
      maxDistance: (pattern.width + pattern.height + pattern.depth) * 2.4,
      autoRotateSpeed: 0.42,
    ),
    parts: pattern.parts,
    steps: [
      StructurePreviewStep(
        id: 'structure',
        title: '查看完整结构',
        description: '查看多方块整体轮廓、控制器和可替换仓室。',
        revealedPartIds: allPartIds,
        focusedPartIds: effectiveControllerIds,
      ),
      StructurePreviewStep(
        id: 'casing',
        title: '检查主体与控制器',
        description: '聚焦主体外壳和控制器，点击方块查看其可替换仓室。',
        revealedPartIds: allPartIds,
        focusedPartIds: [...effectiveCasingIds, ...effectiveControllerIds],
      ),
    ],
  );
}

final structurePreviewCatalog = <StructurePreviewCatalogEntry>[
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:primitive-blast-furnace',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / existing Wiki extraction fixture',
    definition: techStructurePreviewDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:underfloor-heating-system',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.UNDERFLOOR_HEATING_SYSTEM',
    definition: _coreUnderfloorDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:astronomical-observatory',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.ASTRONOMICAL_OBSERVATORY',
    definition: _coreObservatoryDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:photovoltaic-power-station-energetic',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.PHOTOVOLTAIC_POWER_STATION_ENERGETIC',
    definition: _corePhotovoltaicDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:slaughter-house',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.SLAUGHTER_HOUSE',
    definition: _coreSlaughterDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:coke-tower',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.COKE_TOWER',
    definition: _coreCokeDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:bedrock-drilling-rigs',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.BEDROCK_DRILLING_RIGS',
    definition: _coreBedrockDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:plasma-condenser',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.PLASMA_CONDENSER',
    definition: _corePlasmaDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:meadow',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.MEADOW',
    definition: _coreMeadowDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:fermenting-tank',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.FERMENTING_TANK',
    definition: _coreFermentingDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhcore:digestion-tank',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhcore',
    moduleLabel: 'CTNH-Core',
    sourceRef: 'CTNH-Core / MultiblocksA.DIGESTION_TANK',
    definition: _coreDigestionDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhenergy:power-substation',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctnhenergy',
    moduleLabel: 'CTNH-Energy',
    sourceRef: 'CTNH-Energy / CEMultiblock.POWER_SUBSTATION',
    definition: _powerSubstationDefinition,
    pages: [_powerSubstationDefinition, _powerSubstationExpandedDefinition],
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhbio:great-flesh',
    module: StructurePreviewModule.magic,
    moduleKey: 'ctnhbio',
    moduleLabel: 'CTNH-Bio',
    sourceRef: 'CTNH-Bio / CBMultiblocks.GREAT_FLESH',
    definition: _greatFleshDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhmana:gem-inlay',
    module: StructurePreviewModule.magic,
    moduleKey: 'ctnhmana',
    moduleLabel: 'CTNH-Mana',
    sourceRef: 'CTNH-Mana / ManaMachine.GEM_INLAY',
    definition: _gemInlayDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctnhastral:rocket-assembly-platform',
    module: StructurePreviewModule.adventure,
    moduleKey: 'ctnhastral',
    moduleLabel: 'CTNH-Astral',
    sourceRef: 'CTNH-Astral / CAMultiblocks.ROCKET_ASSEMBLY_PLATFORM',
    definition: _rocketAssemblyDefinition,
  ),
  StructurePreviewCatalogEntry(
    id: 'ctpp:smashing-factory',
    module: StructurePreviewModule.tech,
    moduleKey: 'ctpp',
    moduleLabel: 'CTPP',
    sourceRef: 'CTPP / CTPPMultiblockMachines.SMASHING_FACTORY',
    definition: _smashingFactoryDefinition,
  ),
];
