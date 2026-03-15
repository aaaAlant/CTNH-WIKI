import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_metadata.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_step.dart';

final techStructurePreviewDefinition = StructurePreviewDefinition(
  id: 'tech-multiblock-preview',
  metadata: const StructurePreviewMetadata(
    title: '黄铜动力试验平台',
    summary: '一个用于验证多方块结构预览链路的科技示例结构。',
    description: '该结构使用正式的结构数据模型描述部件、分类、步骤和场景配置，当前仍使用原生几何体作为临时可视化方案。',
    module: StructurePreviewModule.tech,
    status: StructurePreviewStatus.inProgress,
    tags: ['power', 'kinetics', 'prototype', 'multiblock'],
    versionRange: StructureVersionRange(
      minVersion: 'v1.4.1b',
      note: '当前为首页科技模块预览示例',
    ),
    source: '首页 / 科技模块',
  ),
  camera: const StructureCameraConfig(
    position: StructureVector3(5.8, 5.2, 6.1),
    target: StructureVector3(0.4, 0.6, 0.2),
    minDistance: 5,
    maxDistance: 16,
    autoRotateSpeed: 0.55,
  ),
  stage: const StructurePreviewStage(),
  parts: _buildTechStructurePreviewParts(),
  steps: const [
    StructurePreviewStep(
      id: 'foundation',
      title: '铺设平台',
      description: '先搭出底座和预览平台，保证后续机器和动力轴有稳定支撑。',
      revealedPartIds: [
        'tile-0-0',
        'tile-0-1',
        'tile-0-2',
        'tile-0-3',
        'tile-0-4',
        'tile-1-0',
        'tile-1-1',
        'tile-1-2',
        'tile-1-3',
        'tile-1-4',
        'tile-2-0',
        'tile-2-1',
        'tile-2-2',
        'tile-2-3',
        'tile-2-4',
        'tile-3-0',
        'tile-3-1',
        'tile-3-2',
        'tile-3-3',
        'tile-3-4',
        'tile-4-0',
        'tile-4-1',
        'tile-4-2',
        'tile-4-3',
        'tile-4-4',
      ],
      focusedPartIds: ['tile-2-2'],
    ),
    StructurePreviewStep(
      id: 'power',
      title: '接入动力轴与齿轮',
      description: '先确定动力传递方向，再安装双轴与齿轮作为结构骨架。',
      revealedPartIds: [
        'axle-top',
        'axle-bottom',
        'gear-top',
        'gear-bottom',
        'support-top',
      ],
      focusedPartIds: ['gear-top', 'gear-bottom'],
    ),
    StructurePreviewStep(
      id: 'machines',
      title: '摆放机器主体',
      description: '将主体设备按预定位置摆放，形成一个紧凑的科技试验单元。',
      revealedPartIds: ['machine-a', 'machine-b', 'machine-c', 'machine-d'],
      focusedPartIds: ['machine-a', 'machine-c'],
    ),
    StructurePreviewStep(
      id: 'displays',
      title: '补充读数与监视单元',
      description: '最后补上显示部件，让结构具备“正在工作”的可视化信号。',
      revealedPartIds: ['display-top', 'display-bottom'],
      focusedPartIds: ['display-top', 'display-bottom'],
    ),
  ],
);

const techPreviewApiBullets = [
  '当前示例已经改为正式结构定义，场景元数据、部件信息和步骤信息都在同一套模型里维护。',
  '每个部件都具备独立的 block id、分类、说明和标签，后续可以直接接选中、高亮和说明面板。',
  '渲染层仍然保持独立，当前由适配器把正式模型转换成 three_js 所需的 scene data。',
];

const techPreviewRoadmap = [
  '接入 block id -> 材质 / 模型映射',
  '加入部件点击选中与说明联动',
  '支持按步骤和类别过滤显示结构',
];

List<StructurePreviewPart> _buildTechStructurePreviewParts() {
  final parts = <StructurePreviewPart>[];

  for (var x = 0; x < 5; x++) {
    for (var z = 0; z < 5; z++) {
      final isLightTile = (x + z).isEven;
      parts.add(
        StructurePreviewPart(
          id: 'tile-$x-$z',
          blockId: 'ctnh:lab_floor_tile',
          displayName: '试验平台地砖',
          description: '用于承载当前结构的展示底座，不参与后续交互逻辑。',
          category: StructurePartCategory.foundation,
          position: StructureVector3(x - 2, -0.2, z - 2),
          tags: const ['floor', 'base'],
          visuals: [
            StructurePartVisual.cuboid(
              id: 'body',
              size: const StructureVector3(1, 0.4, 1),
              material: StructureMaterialStyle(
                color: isLightTile ? 0xFFF7F7F2 : 0xFFE1E5E8,
                roughness: 0.95,
              ),
            ),
          ],
        ),
      );
    }
  }

  parts.addAll(const [
    StructurePreviewPart(
      id: 'axle-top',
      blockId: 'create:shaft',
      displayName: '上层动力轴',
      description: '负责把上层转动力从左侧齿轮传递到机器主体。',
      category: StructurePartCategory.power,
      position: StructureVector3(-0.2, 0.95, -0.95),
      tags: ['shaft', 'power', 'upper'],
      visuals: [
        StructurePartVisual.cuboid(
          id: 'body',
          size: StructureVector3(4.7, 0.2, 0.2),
          material: StructureMaterialStyle(
            color: 0xFF8F959C,
            metalness: 0.45,
            roughness: 0.35,
          ),
        ),
      ],
    ),
    StructurePreviewPart(
      id: 'axle-bottom',
      blockId: 'create:shaft',
      displayName: '下层动力轴',
      description: '与上层动力轴共同构成双通道动力传输示例。',
      category: StructurePartCategory.power,
      position: StructureVector3(0.3, 0.95, 0.95),
      tags: ['shaft', 'power', 'lower'],
      visuals: [
        StructurePartVisual.cuboid(
          id: 'body',
          size: StructureVector3(4.4, 0.2, 0.2),
          material: StructureMaterialStyle(
            color: 0xFF8F959C,
            metalness: 0.45,
            roughness: 0.35,
          ),
        ),
      ],
    ),
    StructurePreviewPart(
      id: 'gear-top',
      blockId: 'create:large_cogwheel',
      displayName: '上层大齿轮',
      description: '示意科技结构中显眼的机械传动部件。',
      category: StructurePartCategory.power,
      position: StructureVector3(-1.75, 0.95, -0.95),
      tags: ['gear', 'power'],
      visuals: [
        StructurePartVisual.cylinder(
          id: 'body',
          radiusTop: 0.82,
          radiusBottom: 0.82,
          height: 0.16,
          rotation: StructureRotation(0, 0, 90),
          material: StructureMaterialStyle(
            color: 0xFF8B5C2E,
            metalness: 0.08,
            roughness: 0.78,
          ),
        ),
      ],
    ),
    StructurePreviewPart(
      id: 'gear-bottom',
      blockId: 'create:large_cogwheel',
      displayName: '下层大齿轮',
      description: '与上层大齿轮一起形成双轴动力的视觉锚点。',
      category: StructurePartCategory.power,
      position: StructureVector3(-1.55, 0.95, 0.95),
      tags: ['gear', 'power'],
      visuals: [
        StructurePartVisual.cylinder(
          id: 'body',
          radiusTop: 0.82,
          radiusBottom: 0.82,
          height: 0.16,
          rotation: StructureRotation(0, 0, 90),
          material: StructureMaterialStyle(
            color: 0xFF8B5C2E,
            metalness: 0.08,
            roughness: 0.78,
          ),
        ),
      ],
    ),
    StructurePreviewPart(
      id: 'machine-a',
      blockId: 'ctnh:prototype_machine_a',
      displayName: '加工机组 A',
      description: '示例中的机器主体，用于占位未来真实方块模型。',
      category: StructurePartCategory.machine,
      position: StructureVector3(0.8, 0.58, -0.95),
      tags: ['machine', 'core'],
      visuals: [],
    ),
    StructurePreviewPart(
      id: 'machine-b',
      blockId: 'ctnh:prototype_machine_b',
      displayName: '加工机组 B',
      description: '与 A 共同组成上侧设备组合。',
      category: StructurePartCategory.machine,
      position: StructureVector3(1.85, 0.58, -0.95),
      tags: ['machine'],
      visuals: [],
    ),
    StructurePreviewPart(
      id: 'machine-c',
      blockId: 'ctnh:prototype_machine_c',
      displayName: '加工机组 C',
      description: '下侧核心设备之一，用于示例机组的紧凑布置。',
      category: StructurePartCategory.machine,
      position: StructureVector3(1.35, 0.58, 0.95),
      tags: ['machine', 'core'],
      visuals: [],
    ),
    StructurePreviewPart(
      id: 'machine-d',
      blockId: 'ctnh:prototype_machine_d',
      displayName: '加工机组 D',
      description: '下侧设备补位，用于呈现紧密排布的科技平台。',
      category: StructurePartCategory.machine,
      position: StructureVector3(0.35, 0.58, 0.95),
      tags: ['machine'],
      visuals: [],
    ),
    StructurePreviewPart(
      id: 'display-top',
      blockId: 'ctnh:monitor_top',
      displayName: '上层读数面板',
      description: '示例中的监视单元，后续可替换为真实显示部件模型。',
      category: StructurePartCategory.display,
      position: StructureVector3(0.35, 0.58, -1.45),
      tags: ['display', 'monitor'],
      visuals: [],
    ),
    StructurePreviewPart(
      id: 'display-bottom',
      blockId: 'ctnh:monitor_side',
      displayName: '侧向读数面板',
      description: '作为侧向可视化信号源，表示可联动的特殊部件。',
      category: StructurePartCategory.display,
      position: StructureVector3(2.1, 0.58, -0.3),
      rotation: StructureRotation(0, -90, 0),
      tags: ['display', 'monitor'],
      visuals: [],
    ),
    StructurePreviewPart(
      id: 'support-top',
      blockId: 'create:metal_bracket',
      displayName: '上层连杆',
      description: '作为动力轴与主体设备之间的示意支撑件。',
      category: StructurePartCategory.transport,
      position: StructureVector3(1.35, 1.1, 0),
      rotation: StructureRotation(0, 90, 0),
      tags: ['support', 'bridge'],
      visuals: [
        StructurePartVisual.cuboid(
          id: 'body',
          size: StructureVector3(2, 0.22, 0.22),
          material: StructureMaterialStyle(
            color: 0xFFA9B0B5,
            metalness: 0.35,
            roughness: 0.42,
          ),
        ),
      ],
    ),
  ]);

  return parts;
}
