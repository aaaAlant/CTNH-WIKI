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
      description: '构成工业土高炉主体的炉墙砖块。',
      category: StructurePartCategory.casing,
      partIdPrefix: 'primitive-bricks',
      tags: ['casing', 'shell'],
    ),
    'Y': MultiblockPatternSymbolDefinition.part(
      blockId: 'ctnhcore:industrial_primitive_blast_furnace',
      displayName: '工业土高炉控制器',
      description: '控制工业土高炉运行的核心方块。',
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
    summary: '由土高炉砖块和控制器组成的 3x4x3 多方块结构。',
    description: '工业土高炉以土高炉砖块围成炉体，中央保留烟道空间，控制器位于正面中央用于启动加工。',
    module: StructurePreviewModule.tech,
    status: StructurePreviewStatus.published,
    tags: ['科技', '多方块', '工业土高炉'],
    versionRange: StructureVersionRange(
      minVersion: 'v1.4.1b',
      note: '适用于 v1.4.1b 及后续版本。',
    ),
    source: '工业土高炉',
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
      description: '先按照 3x4x3 的轮廓把土高炉砖块搭好，中央保留烟道空间。',
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
