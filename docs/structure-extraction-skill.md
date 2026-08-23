# 多方块结构提炼 Skill

## 用途

这份规范用于把 CTNH / GregTech Modern 源码中的多方块结构定义，提炼为 Wiki 可以展示、筛选和逐步搭建的结构预览数据。它是数据建模和审查规则，不等同于一个运行时 Java 解析器。

结构提炼的产物必须能够回答以下问题：

- 结构的尺寸是多少，层和行的顺序是什么
- 每个 pattern 符号代表哪些方块或候选方块
- 哪些位置是空气、内部空腔或不应渲染的空间
- 控制器、外壳、功能方块和装饰方块分别位于哪里
- 玩家可以按哪些步骤搭建或检查结构
- 哪些结论来自源码，哪些仍然需要人工确认

## 输入边界

优先从机器的结构定义中提取以下信息：

- FactoryBlockPattern.start() 或同类 builder 的连续 .aisle(...) 调用
- 每个 aisle 内的行字符串
- .where('X', ...) 形式的符号谓词
- 控制器、方块注册对象和直接的 Block / ItemLike 引用
- 机器的名称、模组、来源文件和版本信息

推荐同时记录完整来源定位，例如：

- 模块：CTNH-Core、CTNH-Energy、GregTech-Modern 等
- Java 文件路径和类名
- pattern 方法名
- 源码提交或版本
- 提炼日期

如果只拿到截图、结构尺寸或人工描述，产物必须标记为草稿，不得伪装成源码提炼结果。

## 提炼流程

### 1. 定位结构入口

找到返回 BlockPattern / FactoryBlockPattern 的方法，确认 .aisle(...) 的调用顺序以及 .where(...) 是否属于同一个 pattern。不要只依据机器类名猜测结构。

保留每个 aisle 的原始行字符串。所有 aisle 必须有相同的行数，每行必须有相同的字符数；不满足时先报输入错误，不要通过截断或补空格“修复”。

### 2. 建立符号表

逐个收集 pattern 中出现的字符，并为每个字符建立明确的语义分类：

| 分类 | 常见来源 | 预览处理 |
| --- | --- | --- |
| 必需方块 | blocks(REGISTERED_BLOCK)、固定 block predicate | 生成必需部件 |
| 控制器 | Predicates.controller(...) | 生成控制器部件，并保留控制器标签 |
| 空气 / 空腔 | Predicates.air() 或明确的 skip 定义 | 不生成实体部件 |
| 可选候选 | air().or(...)、多个合法方块的谓词 | 生成候选信息；无法确定时不冒充单一方块 |
| 能力谓词 | 能量、流体、朝向、材质或自定义 predicate | 保留为约束或备注，不能直接当作方块 |

对于 air().or(...) 这类定义，至少保留 optional / candidate 标记和候选列表。若现有视觉模型一次只能展示一个方块，应在说明面板中写清“当前显示代表候选”，而不是丢弃其他候选。

符号没有映射时必须失败并指出符号；不要默认为空气。空气只能由显式 skip 或明确的空气谓词产生。

### 3. 计算坐标与方向

Wiki 当前 builder 的默认约定是：

- aisle 数量 = depth
- 第一 aisle 的行数 = height
- 行字符串长度 = width
- aisle 顺序默认从后向前
- 行顺序默认从下向上
- X 轴以结构中心为原点居中
- Y 轴从底部向上
- Z 轴以结构中心为原点居中

对应 MultiblockPatternBuilder 的开关：

- rowsFromTopToBottom = true：把源码第一行解释为最高层
- aislesFromBackToFront = false：反转 aisle 的深度方向
- origin：整体平移
- blockSpacing：方块间距

如果源码或游戏内验证显示控制器朝向与展示视角不一致，优先调整方向参数和 StructureFacing，不要改写 pattern 的原始顺序。方向假设必须记录在结构元数据或文档中。

### 4. 生成部件和索引

每个非 skip 单元格生成一个 StructurePreviewPart，至少包含：

- 稳定的 id
- 注册方块 id
- 显示名称和短说明
- 分类（结构、控制器、功能、装饰等）
- 三维坐标
- 朝向 / 旋转
- 必需、可选或状态信息
- pattern:<symbol> 和 grid:x-y-z 标签

部件 id 必须由符号和网格坐标稳定生成，避免使用随机值。为每个符号建立 symbol -> partIds 索引，以便步骤聚焦、分类筛选和点击说明复用同一份结构数据。

### 5. 编排搭建步骤

步骤应从可验证的结构分区推导，而不是仅按部件列表顺序罗列。推荐顺序：

1. 基础层或承重外壳
2. 外壳和侧壁
3. 内部功能方块或腔体相关方块
4. 控制器与交互面
5. 顶层封闭和最终检查

每一步至少包含标题、说明和聚焦的 partIds。如果来源没有规定建造顺序，应明确标记为 Wiki 推荐顺序。步骤不能改变真实结构要求；它只是玩家操作的展示层。

## 候选与证据模型

结构预览应区分“确定事实”和“待确认信息”：

- exact：源码直接指向一个已解析的注册方块
- candidate：源码允许多个方块，或只解析出部分谓词
- unresolved：有自定义谓词、动态注册或缺少资源，暂时不能确定
- manual：由 Wiki 作者补充的视觉、朝向或说明

对每个候选记录来源证据和备注。一个候选至少应有：符号、候选方块 id（若有）、来源表达式、是否必需、视觉代表是否准确。缺少证据时宁可保留占位和警告，也不要从命名相似的方块中猜选。

## 贴图资源

运行时只保留生成后的 `assets/textures/modules/auto/` 和 `assets/models/modules/auto/`，不再保存整模块原始纹理树。Flutter 的目录型资产只扫描目录第一层文件；这两个自动生成目录都必须单独加入 `pubspec.yaml` 的 `flutter.assets`。构建后应检查 `AssetManifest.bin`，不能只验证源目录存在。

纹理关系由 `tool/forge_model_parser.dart` 自动处理 JSON blockstate/model，而不是手写 block 映射。流程是：解析 blockstate、variant、parent 链、textures、texture_overrides 和 element face 的 `#texture`，再读取对应 PNG 的 `ldlib.connection`，把可用资源复制到 `assets/textures/modules/auto/` 和 `assets/models/modules/auto/` 并生成 `structure_texture_manifest.g.dart`。生成器不解析 jar；缺失资源按报告从已提取资源目录按需复制。需要补资源时，只对缺失路径执行一次 `unzip` 到 `FORGE_RESOURCE_CACHE`，再重跑生成器，不要扫描整份 jar。

## 与现有 Flutter 模型的对应关系

提炼结果落到以下现有结构：

- StructurePreviewDefinition：结构 id、元数据、相机、部件、步骤和舞台
- MultiblockPatternBuilder：aisle、符号映射、方向参数和构建结果
- MultiblockPatternSymbolDefinition：单个符号的方块、分类、状态、标签和视觉
- MultiblockPatternBuildResult：部件列表、尺寸和 symbolPartIds
- StructurePreviewMetadata：模块、状态、标签、版本范围和来源
- StructurePreviewPart：单个空间部件及其说明、朝向、状态和视觉

扩展新机器时优先复用 builder 和 registry；只有结构语义确实不同，才增加新的模型字段或服务。机器专属数据放在对应 feature data 文件，不要把模块来源、候选解释和渲染细节散落在视图 widget 中。

## 质量检查

提交结构提炼结果前，逐项确认：

- [ ] 所有 aisle 行数相同，所有行宽相同
- [ ] pattern 中每个字符都有映射，未知字符会显式报错
- [ ] 空气和内部空腔没有被错误渲染成实体方块
- [ ] 控制器位置、朝向和正面 overlay 与结构方向一致
- [ ] 结构尺寸与源码一致
- [ ] symbolPartIds 能覆盖每个非 skip 符号
- [ ] 步骤聚焦的部件 id 实际存在
- [ ] 方块 id 来自直接注册对象或可靠的离线映射，而不是模糊字符串猜测
- [ ] 候选和未解析谓词在界面中可见且有来源说明
- [ ] 预览桌面和窄屏布局均无文字、控制器或结构重叠
- [ ] 已完成静态分析和相关 Flutter 测试；若无法运行，记录具体环境限制

## 当前限制与后续扩展

当前 Wiki 依赖离线整理的 pattern 和方块映射，尚未对 Java 谓词做通用运行时解析。因此以下内容需要人工确认或专门适配：

- 自定义 predicate 的复杂条件
- 同一符号允许多个方块时的完整候选集合
- 动态注册、方块状态和朝向条件
- 机器运行状态对控制器贴图或 overlay 的影响
- 游戏版本升级后的结构变更

增加新机器时，先把原始 pattern、符号表和方向假设写入数据定义，再补视觉资源和步骤。若来源发生变化，重新提炼并更新来源版本、尺寸、候选证据和验证记录。
