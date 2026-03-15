# 多方块结构预览模块说明

## 1. 模块定位

“多方块结构预览”用于在页面中嵌入一个可交互的 3D 结构视图，以接近 JEI / 思索预览的方式展示：

- 一个多方块结构由哪些部件组成
- 各部件在三维空间中的相对位置
- 结构的层级、搭建步骤和关键说明
- 方块、模块、配方或章节与结构之间的关联关系

当前项目已经完成的是第一版 API 骨架：

- 使用 `three_js` 作为 3D 渲染底座
- 使用 Flutter 页面承载 3D 视口
- 使用场景数据驱动简单几何体摆放
- 在首页科技模块中嵌入了一个示例结构

当前代码入口：

- 场景数据模型：`lib/features/structure_preview/models/structure_preview_scene.dart`
- 渲染器：`lib/features/structure_preview/three_js/structure_preview_renderer.dart`
- 视口组件：`lib/features/structure_preview/view/structure_preview_viewport.dart`
- 科技模块示例数据：`lib/features/home/data/tech_structure_preview_data.dart`
- 科技模块示例页面：`lib/features/home/view/modules/tech_module_page.dart`

---

## 2. 模块目标

这个模块后续应该承担三类能力：

### 2.1 展示能力

- 展示完整多方块结构
- 展示结构的分层、分面、分步骤状态
- 展示结构中的特殊部件、方向和连接关系

### 2.2 解释能力

- 点选某个部件后展示说明
- 标出关键输入、输出、动力轴、管道、控制器等位置
- 让用户理解“为什么这样搭”

### 2.3 扩展能力

- 同一套预览器可复用于科技、魔法、冒险三个模块
- 后续可接真实方块数据、真实模型和真实结构配置
- 可扩展为独立页面，甚至结构浏览器

---

## 3. 当前实现状态

### 3.1 已完成

- `three_js` 已接入工程
- Web 端所需 `gles_bindings.js` 已在 `web/index.html` 中接入
- 已有统一的场景数据结构 `StructurePreviewSceneData`
- 已支持两类基础几何：
  - `cuboid`
  - `cylinder`
- 已支持基础材质参数：
  - `color`
  - `metalness`
  - `roughness`
  - `opacity`
- 已支持基础相机控制：
  - 初始相机位置
  - 目标点
  - 缩放距离限制
  - 轨道旋转
  - 自动旋转
- 已支持基础灯光：
  - 环境光
  - 主方向光
  - 补光
- 已支持在 Flutter 页面中嵌入一个固定尺寸视口
- 已支持测试环境 / 特殊环境下自动降级为占位 UI

### 3.2 当前仍然是预览级实现

目前这套实现更偏向“原型验证”，还没有进入正式组件阶段。主要限制：

- 只支持手写 primitive 数据
- 还没有 block id 到渲染表现的映射层
- 还没有悬停、点选、高亮
- 还没有分步搭建动画
- 还没有层级显示和过滤
- 还没有与正文说明联动
- 还没有资源缓存、批量渲染优化和复用策略

---

## 4. 当前架构说明

## 4.1 分层结构

当前建议把模块理解为 4 层：

### A. 内容层

负责描述“这个结构是什么”。

示例：

- 结构 id
- 结构标题
- 结构说明
- 结构所需方块列表
- 结构步骤
- 结构备注

### B. 场景数据层

负责描述“这个结构在 3D 空间里如何摆放”。

当前对应：

- `StructurePreviewSceneData`
- `StructurePrimitive`
- `StructureCameraConfig`

这层不关心 Flutter 页面，只关心场景对象。

### C. 渲染层

负责把场景数据变成 `three_js` 场景。

当前对应：

- `StructurePreviewRenderer`

这层负责：

- 创建 scene
- 创建 camera
- 创建 OrbitControls
- 配置灯光
- 构造 mesh
- 把 primitive 加入 scene

### D. 视图层

负责在 Flutter 中显示 3D 结果，并管理生命周期。

当前对应：

- `StructurePreviewViewport`

这层负责：

- 持有 `ThreeJS`
- 管理初始化与销毁
- 提供 fallback UI
- 嵌入页面布局

---

## 5. 当前数据模型说明

## 5.1 `StructurePreviewSceneData`

表示一个完整可渲染场景。

主要字段：

- `id`
- `camera`
- `primitives`
- `backgroundColor`
- `ambientLightColor`
- `ambientLightIntensity`
- `keyLightColor`
- `keyLightIntensity`
- `keyLightPosition`
- `fillLightColor`
- `fillLightIntensity`
- `fillLightPosition`

作用：

- 统一描述“场景级配置”
- 让一个结构预览可以完全数据驱动

## 5.2 `StructureCameraConfig`

表示相机和操控器初始配置。

主要字段：

- `position`
- `target`
- `fov`
- `minDistance`
- `maxDistance`
- `maxPolarAngle`
- `autoRotate`
- `autoRotateSpeed`

作用：

- 控制默认观看角度
- 控制用户交互边界
- 保持不同结构的预览视角稳定

## 5.3 `StructurePrimitive`

表示一个基础可渲染单元。

当前支持两种构造：

- `StructurePrimitive.cuboid`
- `StructurePrimitive.cylinder`

作用：

- 用最基础的几何体快速搭出结构原型
- 在没有真实模型前先验证 API 和布局链路

## 5.4 `StructureMaterialStyle`

表示 primitive 的材质表现。

当前字段：

- `color`
- `metalness`
- `roughness`
- `opacity`

作用：

- 控制不同部件的观感
- 让示例结构具备基础区分度

---

## 6. 正式化后建议的能力拆分

下面这些功能建议分别实现，不要全部堆在一个文件里。

## 6.1 场景描述与结构数据

### 需要实现的功能

- 定义正式的结构数据模型
- 允许一个结构由多个部件组成
- 为每个部件记录：
  - 唯一 id
  - block id / 部件类型
  - 位置
  - 旋转
  - 状态
  - 标签
  - 说明
- 支持场景级元数据：
  - 标题
  - 简介
  - 分类
  - 来源模块
  - 版本适用范围

### 建议拆分

- `structure_preview_scene.dart`
- `structure_preview_block.dart`
- `structure_preview_metadata.dart`

## 6.2 Block 注册表与渲染映射

### 需要实现的功能

- 建立 `blockId -> 渲染配置` 的映射
- 区分：
  - 普通方块
  - 特殊方块
  - 多方块控制器
  - 管道 / 动力轴 / 齿轮等连接件
- 为每个 block 定义：
  - 使用 primitive 还是模型
  - 材质
  - 默认尺寸
  - 默认旋转规则
  - 可交互区域

### 建议拆分

- `structure_block_registry.dart`
- `structure_block_visual.dart`
- `structure_block_factory.dart`

## 6.3 几何构建与渲染管线

### 需要实现的功能

- 根据结构数据创建 3D 对象
- 支持 primitive 生成
- 支持后续模型加载
- 支持对象复用和缓存
- 支持后续按类型批量构建

### 建议拆分

- `structure_preview_renderer.dart`
- `structure_mesh_builder.dart`
- `structure_material_factory.dart`
- `structure_model_loader.dart`

## 6.4 相机与交互控制

### 需要实现的功能

- 固定默认观察角度
- 允许拖拽旋转
- 允许滚轮缩放
- 限制最大最小距离
- 限制极角，避免看穿地板
- 提供“重置视角”能力
- 提供“正交视角 / 等角视角”切换能力

### 建议拆分

- `structure_camera_controller.dart`
- `structure_view_controls.dart`

## 6.5 选中、悬停与高亮

### 需要实现的功能

- 鼠标悬停高亮部件
- 点击选中部件
- 被选中部件高亮描边或发光
- 支持显示部件名称和说明
- 支持联动右侧说明卡片

### 技术点

- `Raycaster`
- 命中对象与业务 id 的映射
- 高亮材质或覆盖层

### 建议拆分

- `structure_hit_test_service.dart`
- `structure_selection_controller.dart`
- `structure_highlight_overlay.dart`

## 6.6 步骤演示与时间轴

### 需要实现的功能

- 按步骤显示结构搭建过程
- 每一步显示新增部件
- 支持播放 / 暂停 / 上一步 / 下一步
- 支持显示步骤说明
- 支持高亮当前步骤新增或关键部件

### 建议拆分

- `structure_step_data.dart`
- `structure_step_controller.dart`
- `structure_step_timeline.dart`

## 6.7 图层与过滤能力

### 需要实现的功能

- 按层显示 / 隐藏部件
- 按类别过滤：
  - 外壳
  - 动力
  - 输入
  - 输出
  - 控制器
  - 装饰 / 占位
- 支持半透明显示非重点部件

### 建议拆分

- `structure_layer_state.dart`
- `structure_filter_panel.dart`

## 6.8 说明面板与页面联动

### 需要实现的功能

- 右侧说明区展示选中部件信息
- 展示结构概览、材料、步骤、提示
- 点击正文锚点可联动高亮结构中的对应部件
- 点击结构中的部件可定位到正文说明

### 建议拆分

- `structure_preview_panel.dart`
- `structure_part_detail_card.dart`
- `structure_link_bridge.dart`

## 6.9 主题与视觉表现

### 需要实现的功能

- 自定义背景色、灯光方案
- 控制平台底座、网格、阴影和环境
- 控制不同模块的视觉风格：
  - 科技
  - 魔法
  - 冒险

### 建议拆分

- `structure_preview_theme.dart`
- `structure_light_preset.dart`
- `structure_stage_builder.dart`

## 6.10 性能优化

### 需要实现的功能

- 合并重复几何体
- 通过 `InstancedMesh` 降低 draw call
- 缓存重复材质
- 避免频繁销毁 / 重建场景
- 控制高 DPI 下的渲染分辨率
- 仅在可见时更新动画

### 建议拆分

- `structure_render_cache.dart`
- `structure_instance_batch.dart`
- `structure_performance_profile.dart`

## 6.11 测试与降级策略

### 需要实现的功能

- widget test 下自动 fallback
- 非 Web / 异常环境下可展示占位卡片
- 保证 3D 初始化失败不影响整页渲染
- 为数据模型和转换层提供单元测试

### 建议拆分

- `structure_preview_fallback.dart`
- `structure_preview_test_data.dart`

---

## 7. 建议的正式组件目录

建议后续演进成下面这样的目录结构：

```text
lib/
  features/
    structure_preview/
      models/
        structure_preview_scene.dart
        structure_preview_block.dart
        structure_preview_step.dart
      data/
        structure_block_registry.dart
        structure_preview_presets.dart
      controllers/
        structure_camera_controller.dart
        structure_selection_controller.dart
        structure_step_controller.dart
      services/
        structure_mesh_builder.dart
        structure_model_loader.dart
        structure_hit_test_service.dart
        structure_render_cache.dart
      three_js/
        structure_preview_renderer.dart
      view/
        structure_preview_viewport.dart
        structure_preview_panel.dart
        structure_step_timeline.dart
        structure_filter_panel.dart
        widgets/
          structure_toolbar.dart
          structure_part_detail_card.dart
          structure_fallback_card.dart
```

---

## 8. 推荐的实施阶段

## 阶段 1：原型稳定化

目标：

- 让当前预览示例稳定可复用

需要完成：

- 整理现有数据模型命名
- 把科技模块示例从业务页彻底解耦
- 补上通用错误处理和 fallback
- 补上视角重置按钮

## 阶段 2：正式场景数据层

目标：

- 从“手写几何体示例”升级为“结构数据驱动”

需要完成：

- 增加 block id
- 增加部件 metadata
- 定义结构步骤
- 定义部件类别

## 阶段 3：交互层

目标：

- 让结构可解释，而不是只可观看

需要完成：

- 悬停高亮
- 点击选中
- 右侧说明面板
- 结构与正文联动

## 阶段 4：演示层

目标：

- 用于真正的攻略展示

需要完成：

- 分步骤播放
- 分层显示
- 类别过滤
- 材料清单

## 阶段 5：性能与资源升级

目标：

- 支持更多结构和更正式的页面接入

需要完成：

- `InstancedMesh`
- 材质缓存
- 模型加载与复用
- 结构切换时的资源回收

---

## 9. 当前建议优先实现的功能清单

这是下一轮最值得优先做的内容。

### 第一优先级

- 定义正式的结构数据模型
- 让 primitive 支持业务 id 和说明信息
- 增加视角重置 / 自动旋转开关
- 增加部件点击选中能力

### 第二优先级

- 右侧说明卡片
- 步骤数据和步骤切换
- 图层过滤

### 第三优先级

- `InstancedMesh` 优化
- 模型资源映射
- 不同模块的主题皮肤

---

## 10. 建议的最小可用正式版本（MVP）

MVP 建议包含以下能力：

- 一个可复用的 `StructurePreviewViewport`
- 一个正式的结构数据格式
- 方块 / 部件点击选中
- 右侧说明区
- 步骤切换
- 视角重置
- 科技模块内至少 2 个真实结构示例

这个版本完成后，模块就不再只是“演示预览”，而是可以开始承载实际内容了。

---

## 11. 目前需要分别实现的功能总表

下面这张表可以直接作为后续开发清单。

| 功能模块 | 目标 | 当前状态 |
| --- | --- | --- |
| 场景数据模型 | 定义结构、部件、相机、步骤等数据 | 已有基础版 |
| primitive 渲染 | 用基础几何体渲染结构 | 已完成 |
| block 渲染映射 | 用 block id 映射材质 / 模型 | 未开始 |
| 相机控制 | 旋转、缩放、限制、重置 | 部分完成 |
| 悬停 / 点击 | 选中部件并联动说明 | 未开始 |
| 高亮效果 | 选中部件可视化强调 | 未开始 |
| 说明面板 | 展示部件信息和结构提示 | 未开始 |
| 步骤播放 | 逐步展示结构搭建 | 未开始 |
| 图层过滤 | 按类别 / 层级显示结构 | 未开始 |
| 性能优化 | 减少 draw call 与重复创建 | 未开始 |
| 资源复用 | 模型、材质、场景缓存 | 未开始 |
| 测试与降级 | 在异常环境下保持页面稳定 | 部分完成 |

---

## 12. 结论

当前“多方块结构预览”已经完成了最关键的一步：  
已经证明 `three_js + Flutter` 在本项目内可以跑通一个页面级、数据驱动的 3D 结构预览。

接下来的实现重点不再是“能不能渲染”，而是：

- 如何把结构数据标准化
- 如何让结构可交互、可解释
- 如何让这套能力在多个页面和多个模块中复用

建议下一步先进入：

1. 正式结构数据模型设计
2. 部件选中与说明联动
3. 步骤系统设计

等这三部分建立起来之后，再继续扩展模型资源、性能优化和更复杂的结构类型。
