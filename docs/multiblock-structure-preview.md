# 多方块结构预览

## 当前范围

Wiki 已新增独立的“多方块预览”页面，用于查看从现有 GTM / CTNH 多方块定义提炼出的结构数据。当前 catalog 已登记：

- CTNH-Core：工业土高炉（现有 Wiki pattern fixture）
  - 地暖系统、天体观测站、能量态光伏电站、宰杀场、焦炉塔、基岩钻机、等离子冷凝器、草原、发酵罐、消化罐（手动从 MultiblocksA 提炼）
- CTNH-Energy：蓄能变电站基础方案、扩展电池层方案
- CTNH-Mana：宝石镶嵌机
- CTNH-Bio：巨型肉块
- CTNH-Astral：火箭组装平台
- CTPP：粉碎工厂

页面入口由 lib/app/wiki_app_shell.dart 和 lib/data/wiki_tabs_data.dart 注册，页面编排位于 lib/features/structure_preview/view/structure_preview_tab.dart。

## 数据边界

Wiki 不解析原始 .nbt、Ponder NBT、SNBT 或 Java 文本，也不依赖 Minecraft/GTM runtime。结构来源是现有 GTM/CTNH 定义经过人工或外部转换提炼后的 Wiki 数据定义，当前以 Dart catalog fixture 维护：

- lib/features/structure_preview/data/structure_preview_catalog.dart
- lib/features/structure_preview/services/multiblock_pattern_builder.dart
- lib/features/structure_preview/models/

每个 catalog 条目记录 moduleKey、来源引用、pattern 方向、controller、visual fallback 和候选来源。未知候选保留 runtime/unresolved 说明，不伪装成空气。

## 页面能力

- 模块筛选：按 CTNH-Core、CTNH-Energy、CTNH-Mana、CTNH-Bio、CTNH-Astral、CTPP 选择结构
- 结构选择：在当前模块的 machine definition 条目中切换
- 方案分页：使用 P:1、P:2，Energy 蓄能变电站示例展示基础和扩展电池层
- 分层：使用 ALL 或 L:n 选择由结构网格 y 坐标派生的水平层
- 搭建步骤：独立于空间层，用于累计显示和聚焦部件
- 3D 交互：Three.js 旋转、缩放、拖拽、悬停高亮和点击选中
- 详情面板：显示 Block ID、局部坐标、朝向、状态、来源标签和候选可替换方块
- 动态/未知位置：仅当源码明确要求空气时显示空腔；非强制 any 使用 skip，不添加半透明占位方块

候选列表遵循 GTM EMI 的展示语义：候选是位置谓词的可接受分支，和 canonical display 分开；查看候选不会替换 3D 结构。

## 结构提炼 Skill

新增 skill：skills/ctnh-multiblock-preview/SKILL.md

新增或修正结构前，先按该 skill 记录 pattern 来源、.aisle 顺序、.where 符号证据、controller 原点、层方向、候选分支、visual 资源和验证结果。skill 明确区分：

- exact：唯一确定的注册方块
- controller：控制器位置
- skip / air：空腔，不生成实体方块
- candidate：多个合法替换方块
- unresolved：动态、自定义或缺少证据的谓词
- manual：Wiki 侧人工补充的说明或视觉

## 坐标规则

当前 builder 默认采用：

- aisle 数量为 depth
- aisle 行数为 height
- 行字符数为 width
- aisle 从后向前
- 行从下向上
- X/Z 居中，Y 从 0 层向上

结构层控制器通过 grid:x-y-z 或显式 layer 标签解析层，Three.js primitive 同时保留 partId、layerId 和网格坐标。页面滚动后的点击命中使用 viewport 的全局原点计算，避免偏移。

## 视觉与降级

Three.js 当前支持 cuboid/cylinder、单贴图或六面材质。Minecraft baked model、复杂 block entity 和动态模型必须在提炼阶段转换为 Wiki visual；不能只提供 block ID。预览通过 `StructureForgeTextureResolver` 读取生成的 Forge 纹理清单，按 block id、model face/texture_overrides 和 LDLib `ldlib.connection` 自动选择 base、overlay、face 与 connection，不再维护手写资源映射；单张贴图加载失败会在 4 秒后降级为颜色材质，详情面板仍显示结构信息。

纹理清单由 `tool/forge_model_parser.dart` 解析 blockstate、model variant、parent 链、texture map、texture_overrides 和 element face 的 `#texture` 引用，再由 `tool/generate_structure_texture_manifest.dart` 生成。解析器不扫描或解析 Gradle jar；缺失资源先由当前结果报告，再按需从 `FORGE_RESOURCE_CACHE` 中的已提取资源复制，最终只保留 `assets/textures/modules/auto/` 和 `assets/models/modules/auto/`。新增或修改模型后重跑生成器，不要直接改生成文件。

结构注册表不再引用工作区外或未声明的 data/machine/*.png 临时路径。正式资源必须位于 Wiki 已跟踪并在 pubspec.yaml 声明的目录。

Flutter 的目录型资产只扫描目录第一层文件，不会递归扫描 `assets/textures/modules/` 下的子目录。当前已按模块与子目录逐一声明实际资源目录；新增贴图时也必须为包含资源的目录补一条声明。

## 验证

提交前检查：

- pattern 所有 aisle 高度和行宽一致
- 每个非 skip 符号都有映射和稳定部件 ID
- controller、层方向和结构尺寸与来源一致
- candidate、any、air、dynamic、unresolved 状态在详情中可见
- P 页面和 ALL/L 层切换不会残留上一个结构的选中状态
- git diff --check 通过
- 可用时运行 flutter analyze、flutter test 和 flutter build web --release

当前使用 Flutter 3.47.1 / Dart 3.13.1 完成 `flutter analyze`、`flutter test` 与 `flutter build web --release`。正式发布前仍需在目标浏览器中检查 WebGL、触摸交互和截图表现。
