# 多方块结构预览模块说明

## 1. 模块定位

“多方块结构预览”用于在 Flutter 页面内嵌一个可交互的 3D 结构视口，展示配方、多方块机器或阶段性搭建结构。目标不是做完整 Minecraft 世界渲染器，而是做一个受控、可说明、可扩展的结构预览组件。

当前技术路线：

- 页面层：Flutter 原生 UI
- 3D 层：`three_js`
- 数据层：结构定义、部件定义、步骤定义、block 注册表
- 交互层：选中、悬停、步骤切换、命中检测

---

## 2. 当前已完成能力

### 2.1 基础视口

- 已接入 `three_js`
- 已封装 `StructurePreviewViewport`
- 已支持旋转、缩放和基础灯光
- 已支持测试环境和无 3D 环境下的 fallback

### 2.2 正式数据模型

- 已完成 `StructurePreviewDefinition`
- 已完成 `StructurePreviewMetadata`
- 已完成 `StructurePreviewPart`
- 已完成 `StructurePreviewStep`
- 已完成舞台和相机配置模型

### 2.3 场景构建与渲染

- 已完成 `StructurePreviewSceneBuilder`
- 已完成 primitive 场景构建
- 已完成 `blockId -> registry -> visuals` 回退链路
- 已完成单贴图和六面贴图材质支持
- 已完成贴图缓存和像素风采样配置

### 2.4 交互

- 已完成点击命中
- 已完成选中高亮
- 已完成步骤焦点高亮
- 已完成悬停高亮
- 已完成选中部件与右侧说明联动
- 已完成步骤切换与结构显隐联动

### 2.5 页面示例

- 首页科技模块已接入正式示例
- 示例同时覆盖：
  - 结构渲染
  - 步骤系统
  - 选中联动
  - 悬停提示
  - block registry 渲染映射

---

## 3. 当前目录职责

### 3.1 数据模型

- `lib/features/structure_preview/models/structure_preview_definition.dart`
  - 整个结构的统一入口
- `lib/features/structure_preview/models/structure_preview_metadata.dart`
  - 标题、摘要、描述、标签、状态等元数据
- `lib/features/structure_preview/models/structure_preview_part.dart`
  - 单个逻辑部件定义
- `lib/features/structure_preview/models/structure_preview_step.dart`
  - 步骤定义
- `lib/features/structure_preview/models/structure_preview_scene.dart`
  - 渲染层使用的低层 scene 数据
- `lib/features/structure_preview/models/structure_block.dart`
  - block 注册表条目定义

### 3.2 控制器

- `lib/features/structure_preview/controllers/structure_selection_controller.dart`
  - 管理当前选中部件
- `lib/features/structure_preview/controllers/structure_step_controller.dart`
  - 管理步骤索引、可见部件和焦点部件

### 3.3 服务层

- `lib/features/structure_preview/services/structure_preview_scene_builder.dart`
  - 将正式结构定义转换成渲染场景
- `lib/features/structure_preview/services/structure_hit_test_service.dart`
  - 使用 `Raycaster` 做部件命中检测
- `lib/features/structure_preview/services/structure_texture_cache.dart`
  - 负责纹理加载与缓存

### 3.4 渲染层

- `lib/features/structure_preview/three_js/structure_preview_renderer.dart`
  - 初始化场景、相机、灯光、控制器、mesh
  - 管理选中、悬停、步骤焦点三种高亮状态
  - 管理 interactive objects 列表
  - 管理材质构建与刷新

### 3.5 视图层

- `lib/features/structure_preview/view/structure_preview_viewport.dart`
  - Flutter 与 3D 的桥接层
  - 接线 selection controller
  - 接线 step controller
  - 绑定 pointer move/down/leave
  - 把 hover / selection 结果回传页面
- `lib/features/structure_preview/view/widgets/structure_part_detail_card.dart`
  - 显示当前选中部件详情
- `lib/features/structure_preview/view/widgets/structure_step_timeline.dart`
  - 显示步骤切换条

### 3.6 数据入口与示例

- `lib/features/structure_preview/data/structure_block_registry.dart`
  - 维护 `blockId -> StructureBlockDefinition`
- `lib/features/home/data/tech_structure_preview_data.dart`
  - 科技模块的结构预览示例
- `lib/features/home/view/modules/tech_module_page.dart`
  - 科技模块页面接入

---

## 4. 当前核心数据模型

## 4.1 `StructurePreviewDefinition`

字段职责：

- `id`：结构唯一标识
- `metadata`：结构元数据
- `camera`：相机预设
- `parts`：所有逻辑部件
- `steps`：步骤列表
- `stage`：舞台背景与灯光配置

它是页面层、渲染层、步骤系统的统一输入对象。

## 4.2 `StructurePreviewPart`

一个 part 表示一个逻辑部件，而不是单个 mesh。

当前支持：

- `id`
- `blockId`
- `displayName`
- `description`
- `category`
- `position`
- `rotation`
- `facing`
- `state`
- `tags`
- `visuals`

说明：

- 一个 part 可以展开成一个或多个 primitive
- `visuals` 为空时，会根据 `blockId` 到 registry 找默认外观

## 4.3 `StructurePreviewStep`

当前支持：

- `id`
- `title`
- `description`
- `revealedPartIds`
- `focusedPartIds`

职责：

- 定义某一步新增显示哪些部件
- 定义当前步骤重点强调哪些部件

## 4.4 `StructureMaterialStyle`

当前支持：

- `color`
- `metalness`
- `roughness`
- `opacity`
- `mapAsset`
- `faceTextures`
- `pixelated`
- `alphaTest`
- `doubleSided`

职责：

- 把“结构数据”与“渲染材质”解耦
- 为像 Minecraft 一样的方块贴图提供正式接口

## 4.5 `StructureBlockDefinition`

当前支持：

- `blockId`
- `displayName`
- `visuals`

职责：

- 为 block 提供统一默认渲染定义
- 避免在页面示例里直接写死视觉 primitive

---

## 5. 当前已打通的功能链路

## 5.1 选中链路

1. 用户点击视口
2. `StructureHitTestService` 使用 `Raycaster` 做命中检测
3. 命中结果返回 `partId`
4. `StructureSelectionController` 更新当前选中部件
5. `StructurePreviewRenderer` 刷新对应 mesh 高亮
6. 页面刷新 `StructurePartDetailCard`

## 5.2 悬停链路

1. 用户在视口内移动鼠标
2. `StructurePreviewViewport` 监听 `pointermove`
3. `StructureHitTestService` 返回当前命中的 `partId`
4. `StructurePreviewRenderer` 刷新 hover 高亮
5. 页面接收 `onHoveredPartChanged`
6. 科技模块顶部提示条同步显示当前悬停部件名称

说明：

- hover 与 selected 分离
- hover 是轻量反馈
- selected 是固定选中态
- focused 是步骤系统提供的阶段焦点态

当前高亮优先级：

1. selected
2. hovered
3. focused

## 5.3 步骤链路

1. 用户在 `StructureStepTimeline` 中切换步骤
2. `StructureStepController` 更新当前步骤索引
3. 视口根据步骤重新计算可见部件
4. 需要时重建场景
5. 渲染器刷新当前焦点部件高亮
6. 页面同步刷新步骤说明

## 5.4 block 渲染链路

1. `StructurePreviewSceneBuilder` 处理 part 数据
2. 如果 part 未直接声明 `visuals`，则按 `blockId` 查询 `StructureBlockRegistry`
3. registry 返回默认 visuals
4. 渲染器根据材质配置创建材质
5. 如果材质定义里有贴图，则通过 `StructureTextureCache` 加载
6. 渲染器生成单材质或六面材质

---

## 6. 当前页面示例的职责

首页科技模块中的示例目前承担这些职责：

- 验证 `three_js + Flutter` 的集成方式
- 验证正式结构定义是否足够支撑渲染和页面说明
- 验证“点击部件 -> 右侧详情联动”
- 验证“悬停部件 -> 顶部提示反馈”
- 验证“步骤切换 -> 结构显隐和焦点更新”
- 验证“blockId -> registry -> material/texture” 的正式渲染链路

因此它已经不是一次性 demo，而是正式组件的原型版本。

---

## 7. 还需要分别实现的功能模块

## 7.1 图层与过滤系统

目标：

- 让用户只看某一类部件或某一层结构

需要实现：

- 按分类过滤
- 按标签过滤
- 按状态过滤
- 只看当前步骤相关部件
- 被过滤部件的可见性与交互策略

## 7.2 更完整的说明面板

目标：

- 从“部件详情卡”扩展成完整的结构说明入口

需要实现：

- 结构简介
- 当前步骤说明
- 当前选中部件详情
- 关联词条 / 任务 / 版本入口
- 可能的材料与依赖信息

## 7.3 更完整的 block 外观注册

目标：

- 让 registry 真正承载大部分预览方块外观

需要实现：

- 常规立方方块贴图方案
- 顶/底/侧不同贴图的方块
- 带透明通道的贴图方块
- 多 primitive 组合方块
- 后续非立方体模型入口

## 7.4 非完整方块与复杂模型

目标：

- 支持管道、齿轮、支架、面板等结构件

需要实现：

- 组合几何工厂
- 朝向和旋转规则
- 未来 glTF 或其他模型接入入口

## 7.5 性能优化

目标：

- 保证结构复杂度提升后仍可用

需要实现：

- 几何与材质复用
- 贴图缓存策略细化
- 场景重建最小化
- hover / selection 刷新范围最小化
- 评估 `InstancedMesh`

## 7.6 测试与稳定性

目标：

- 保证非 3D 环境、测试环境和后续扩展时都稳定

需要实现：

- fallback UI 测试
- scene builder 测试
- selection controller 测试
- step controller 测试
- block registry 测试
- 页面联动测试

---

## 8. 建议的后续实施顺序

建议按下面顺序继续推进：

1. 图层与过滤系统
2. 说明面板扩展
3. 更完整的 block 外观注册
4. 非完整方块与复杂模型
5. 性能优化
6. 测试补齐

原因：

- 当前交互基础链路已经闭合
- 下一步最值得补的是“可用性”，也就是过滤与说明入口
- registry 和模型扩展要建立在交互入口稳定之后

---

## 9. 当前阶段验收标准

当前版本如果满足以下条件，即可视为“悬停高亮阶段完成”：

- 科技模块内可以正常显示 3D 结构
- 结构可旋转、缩放
- 鼠标悬停部件时会出现轻量高亮
- 点击部件后会出现固定选中高亮
- 选中详情卡会同步更新
- 下方步骤条可以切换步骤
- 切换步骤后结构会按阶段显示
- 当前步骤焦点部件会高亮
- 部分 block 已经通过 registry 渲染
- 页面在无 3D 环境下仍有 fallback
- `dart analyze .` 通过

---

## 10. 当前需要你后续提供的输入

为了继续往 Minecraft 风格方块渲染扩展，后面需要你逐步提供：

- 正式的方块材质贴图
- 六个面的命名约定
- 哪些方块是完整立方体
- 哪些方块需要特殊模型或组合几何
- 结构数据中各类 `blockId` 的命名规范

---

## 11. 下一步建议

下一步建议直接开始做“图层与过滤系统”，先补一层最小可用能力：

- 只看当前步骤相关部件
- 按分类隐藏 / 显示
- 页面右侧同步说明当前过滤状态

这一层补完之后，整个多方块结构预览就会从“能看、能点、能分步”进入“能快速查结构”的阶段。
