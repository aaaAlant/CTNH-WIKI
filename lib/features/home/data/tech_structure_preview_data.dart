import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_metadata.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_step.dart';
import 'package:ctnh_wiki/features/structure_preview/services/multiblock_pattern_builder.dart';

final _primitiveBlastFurnacePattern = MultiblockPatternBuilder(
  aisles: const [
    ['XXX', 'XXX', 'XXX', 'XXX'],
    ['XXX', 'X&X', 'X#X', 'X#X'],
    ['XXX', 'XYX', 'XXX', 'XXX'],
  ],
  aislesFromBackToFront: true,
  rowsFromTopToBottom: false,
  symbols: const {
    'X': MultiblockPatternSymbolDefinition.part(
      blockId: 'ctnhcore:machine_primitive_bricks',
      displayName: '土高炉砖块',
      description: '土高炉的主体炉墙，负责形成 3x4x3 的砖体外壳。',
      category: StructurePartCategory.casing,
      partIdPrefix: 'primitive-bricks',
      tags: ['casing', 'shell'],
    ),
    'Y': MultiblockPatternSymbolDefinition.part(
      blockId: 'ctnhcore:industrial_primitive_blast_furnace',
      displayName: '工业土高炉控制器',
      description: '前方中央的控制器方块，用来定义结构朝向并作为交互入口。',
      category: StructurePartCategory.controller,
      partIdPrefix: 'primitive-blast-furnace-controller',
      tags: ['controller', 'front'],
    ),
    '#': MultiblockPatternSymbolDefinition.skip(),
    '&': MultiblockPatternSymbolDefinition.skip(),
  },
).build();

final _primitiveBlastFurnaceCasingIds = _primitiveBlastFurnacePattern
    .partIdsForSymbol('X');
final _primitiveBlastFurnaceControllerIds = _primitiveBlastFurnacePattern
    .partIdsForSymbol('Y');

final techStructurePreviewDefinition = StructurePreviewDefinition(
  id: 'primitive-blast-furnace-preview',
  metadata: const StructurePreviewMetadata(
    title: '工业土高炉',
    summary: '基于 GT 多方块 pattern 自动展开的 3x4x3 砖体结构预览。',
    description:
        '这个示例不再是手工摆放的原型块，而是直接把多方块 pattern 转成结构部件。当前已经接入真实砖块贴图和控制器前脸 overlay，可以用来验证 pattern 驱动的自动建模链路。',
    module: StructurePreviewModule.tech,
    status: StructurePreviewStatus.inProgress,
    tags: ['科技', '多方块', '土高炉', 'pattern', 'GT'],
    versionRange: StructureVersionRange(
      minVersion: 'v1.4.1b',
      note: '首页科技模块的首个真实多方块示例。',
    ),
    source: '首页 / 科技模块',
  ),
  camera: const StructureCameraConfig(
    position: StructureVector3(5.6, 4.6, 6.2),
    target: StructureVector3(0, 1.3, 0.8),
    minDistance: 4.5,
    maxDistance: 14,
    autoRotateSpeed: 0.48,
  ),
  stage: const StructurePreviewStage(),
  parts: _primitiveBlastFurnacePattern.parts,
  steps: [
    StructurePreviewStep(
      id: 'shell',
      title: '搭建砖体外壳',
      description: '先按照 3x4x3 的轮廓把土高炉砖块搭好，中间保持烟道空间。',
      revealedPartIds: _primitiveBlastFurnaceCasingIds,
      focusedPartIds: _primitiveBlastFurnaceCasingIds.take(1).toList(),
    ),
    StructurePreviewStep(
      id: 'controller',
      title: '放置控制器',
      description: '最后在正面中央放上工业土高炉控制器，完成结构识别。',
      revealedPartIds: [
        ..._primitiveBlastFurnaceCasingIds,
        ..._primitiveBlastFurnaceControllerIds,
      ],
      focusedPartIds: _primitiveBlastFurnaceControllerIds,
    ),
  ],
);

const techPreviewApiBullets = [
  '当前示例已经切换成基于 aisle pattern 自动展开的真实多方块结构，后续不需要再手写每个方块坐标。',
  '结构中的砖体与控制器使用 block registry 提供的贴图定义，控制器前脸额外叠加了 overlay 贴图。',
  '选中、悬停、步骤切换和过滤仍然复用同一套结构数据，说明面板和 3D 预览会自动同步。',
];

const techPreviewRoadmap = [
  '继续把更多 GT/CTNH 多方块 pattern 接入同一个自动建模器。',
  '补充控制器 inactive/active 状态切换，以及更多特殊方块的叠层贴图。',
  '把结构预览和机器图鉴、任务概览页面真正联动起来。',
];
