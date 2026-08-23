---
name: ctnh-multiblock-preview
description: 从 CTNH 与 GregTech Modern 的多方块 pattern 提炼 Wiki 预览结构、层级候选、符号证据和搭建步骤。适用于新增机器预览、校正层方向、审查方块候选与更新结构说明。
---

# CTNH 多方块预览 Skill

## 目标

把 CTNH / GregTech Modern 源码中的多方块结构定义转换成 CTNH-WIKI 可消费的结构预览数据。输出必须同时支持：

- 结构整体预览和尺寸说明
- 按层查看 pattern 内容
- 选择方块或候选并查看来源说明
- 按搭建步骤聚焦部件
- 对未知、可选和未确认的谓词保留警告

本 skill 负责结构提炼和数据审查，不负责修改 CTNH 模组源码，也不负责把 Java 谓词实现成 Flutter 运行时解析器。

## 触发场景

在下列场景加载本 skill：

- 为 Wiki 新增一台多方块机器预览
- 从真实机器 pattern 校正现有结构尺寸或方向
- 增加层级查看、候选方块查看或符号筛选
- 检查控制器、空气腔体、外壳和功能方块的映射
- 更新结构来源、版本范围或提炼说明

## 工作边界

只修改 Wiki 侧文件，默认范围是：

- skills/ctnh-multiblock-preview/SKILL.md
- docs/multiblock-structure-preview.md
- lib/features/structure_preview/ 下与结构模型、数据或视图直接相关的文件
- lib/features/home/data/ 下的结构预览数据
- assets/ 与 web/ 下明确属于预览的贴图或静态资源

不要修改 CTNH-Modules 中的 Java、Gradle 或生成资源。不要把机器源码复制进 Wiki 作为未经审查的事实；应记录来源文件、类名、方法名和版本。

## 输入检查

优先从机器结构定义中提取：

1. 返回 BlockPattern 或 FactoryBlockPattern 的方法。
2. 按原顺序排列的 .aisle(...) 行字符串。
3. 所有 .where(symbol, predicate) 符号谓词。
4. 控制器、外壳和功能方块使用的直接注册对象。
5. 模组、类名、方法名、源码路径和版本信息。

输入只包含截图、尺寸或人工摆放坐标时，结构状态必须标为草稿或 manual，不能声称是源码自动提炼。

保留原始 aisle 字符串作为证据。先检查所有 aisle 的行数相同、所有行宽相同；发现不一致时停止构建并报告具体 aisle、行号和宽度。

## 符号提炼规则

为 pattern 中每个字符建立符号记录。至少包含 symbol、语义类别、候选方块、来源表达式、必需性、视觉代表和备注。

| 类别 | 判定依据 | 预览行为 |
| --- | --- | --- |
| exact | 谓词直接指向一个已解析注册方块 | 生成必需部件 |
| controller | 使用 Predicates.controller 或明确的控制器定义 | 生成控制器部件和控制器标签 |
| skip | 明确的 Predicates.air 或显式跳过定义 | 不生成实体部件，可在层视图显示为空腔 |
| candidate | air().or(...) 或谓词允许多个合法方块 | 保留候选集合，不冒充单一方块 |
| unresolved | 自定义谓词、动态注册、缺失映射或无法判断 | 保留警告和来源，不生成实体；除非源码明确要求空气，否则不要指定为任意动态视觉 |
| manual | Wiki 作者补充的说明、朝向或视觉覆盖 | 明确标注为人工补充 |

未知字符不能默认视为空气。只有源码显式表达空气，或数据定义明确使用 skip，才可以不渲染。

对于候选谓词，当前渲染层只能展示一个代表方块时，必须在部件详情中说明该视觉只是候选代表，并保留其余候选。候选信息不能只存在于注释或开发者记忆中。

## 坐标和层方向

现有 MultiblockPatternBuilder 的默认解释是：

- aisle 数量对应 depth
- 每个 aisle 的行数对应 height
- 每行字符数对应 width
- aisle 默认按从后向前解释
- 行默认按从下向上解释
- X 轴居中，Y 轴从底部向上，Z 轴居中

需要反转时使用已有配置，而不是修改源码 pattern：

- rowsFromTopToBottom：源码第一行代表最高层
- aislesFromBackToFront：控制 aisle 深度方向
- origin：整体偏移
- blockSpacing：部件间距

层查看器必须使用与 3D builder 相同的坐标解释。不要让平面层预览和 3D 预览各自推导一套坐标。控制器正面、朝向和 overlay 必须与最终方向假设一起记录并验证。

## 输出模型

优先复用现有模型和服务：

- StructurePreviewDefinition：结构元数据、相机、部件、步骤和舞台
- MultiblockPatternBuilder：aisle、符号映射、坐标和构建结果
- MultiblockPatternSymbolDefinition：符号对应方块、类别、状态、标签和视觉
- MultiblockPatternBuildResult：部件、尺寸和 symbolPartIds
- StructurePreviewPart：位置、方块、说明、朝向、状态和视觉
- StructurePreviewStep：步骤标题、说明和聚焦部件

每个非 skip 单元格需要稳定部件 id。id 应由符号和网格坐标组成，不能使用随机值。每个符号要建立 symbolPartIds 索引，以便层筛选、步骤聚焦、悬停和详情面板复用。

## 贴图资源

Flutter 的目录型资产不会递归扫描子目录。`assets/textures/modules/auto/`、`assets/textures/modules/auto/icons/` 和 `assets/models/modules/auto/` 必须分别加入 `pubspec.yaml` 的 `flutter.assets`。原始模块纹理树不加入运行时资源；新增或移动贴图后重跑生成器，并确认构建后的 `AssetManifest.bin` 引用这些路径。

预览使用 `StructureForgeTextureResolver` 读取生成的 Forge 纹理清单：blockstate、模型 face map、element `#texture`、texture_overrides、父模型关系和 LDLib `ldlib.connection` 都由 `tool/forge_model_parser.dart` 自动提取，禁止继续手写 block 到贴图的映射。Flutter Web 当前 Three.js 加载器会把传入路径再作为站内 URL 请求，因此 Web 运行时需要给 `assets/...` 补一次 `assets/` 前缀；加载失败必须降级为颜色材质，不能让预览永久停在初始化状态。

## 层级和候选呈现

新增层或候选交互时，保持以下行为：

- 层选择只改变可见部件集合，不改变结构定义和部件 id
- 候选选择必须显示候选来源、当前代表视觉和确认状态
- 空腔默认不生成方块实体，但可以作为可选辅助轮廓显示
- 当前层、当前步骤和选中部件应能同时表达，不能互相覆盖说明
- 过滤后如果选中部件不可见，应保留选择状态并在界面中说明，或清晰地取消选择
- 所有层标签、候选名称和警告在窄屏上必须换行，不得溢出

## 步骤生成

源码没有规定建造顺序时，使用 Wiki 推荐顺序并标记来源：

1. 基础层或承重外壳
2. 外壳和侧壁
3. 内部功能方块或腔体相关方块
4. 控制器和交互面
5. 顶层封闭与最终检查

步骤只负责展示和聚焦，不得改变 pattern 的必需性。每个步骤引用的 part id 必须存在；符号到部件索引应优先用于生成步骤，避免手写易漂移的坐标列表。

## 来源和证据

每个结构定义至少记录：

- title、module 和结构 id
- source 文件、类名、pattern 方法
- 源码版本或提炼日期
- width、height、depth
- rows 与 aisle 的方向假设
- 符号映射和未解析谓词
- 视觉资源来源及代表性限制
- 游戏内或人工校验结果

结论分为 exact、candidate、unresolved 和 manual。缺少证据时保留不确定性，不从相似命名方块中猜选。

## 验证清单

提交前完成以下检查：

- [ ] pattern 的 aisle、行数和行宽通过一致性检查
- [ ] 每个 pattern 字符都有映射，未知字符会报错
- [ ] 空气和内部腔体没有错误地生成实体方块；非强制 any 位置不会生成半透明占位方块
- [ ] 结构尺寸与来源一致
- [ ] symbolPartIds 覆盖每个非 skip 符号
- [ ] 层预览和 3D 预览的坐标方向一致
- [ ] 步骤引用的部件 id 全部存在
- [ ] 控制器位置、朝向和 overlay 已确认
- [ ] 候选、未解析和人工补充信息在 UI 中可见
- [ ] 贴图和模型资源路径存在，未引用临时构建产物
- [ ] `assets/textures/modules/` 中实际包含文件的目录及其子目录均已加入 `pubspec.yaml`
- [ ] Flutter 静态分析或相关测试已运行；无法运行时记录原因
- [ ] git diff --check 通过，且没有修改 Wiki 之外的文件

## 交付格式

完成一次结构提炼后，向任务负责人报告：

- 修改的 Wiki 文件
- 新增或修正的结构 id、尺寸和层方向
- 符号映射中的 exact、candidate、unresolved 数量或列表
- 已验证项目和未解决风险
- 没有运行的检查及其原因

不要只报告“预览已完成”。必须说明来源和不确定性，方便后续机器接入和版本升级时复核。
