# 多方块结构预览模块说明

## 1. 模块目标

“多方块结构预览”用于在 Flutter 页面中嵌入一个可交互的 3D 结构预览区，向玩家展示某个多方块结构由哪些部件组成、应该按什么步骤搭建，以及每个关键部件承担什么作用。

当前实现定位是：

- 在页面内提供一个可旋转、可缩放、可选中的 `three_js` 预览窗口
- 用正式的数据模型描述结构元信息、部件、步骤和场景配置
- 将说明、筛选、步骤和部件详情统一到同一套结构数据上

## 2. 当前实现状态

当前已经完成的能力：

- 正式结构定义模型
- three_js 预览视口
- 部件点击选中与说明联动
- 悬停高亮
- 步骤切换与按步骤显示部件
- 分类过滤与“只看当前步骤”过滤
- `blockId -> registry -> visuals` 的基础映射链路
- 首页科技模块中的完整示例
- 独立的结构说明面板

当前仍在推进的方向：

- 真实方块贴图与特殊模型
- 关联词条 / 任务概览 / 版本记录等入口联动
- 更强的图层控制与性能优化
- 更完整的降级与测试方案

## 3. 当前架构

### 3.1 数据模型

核心模型位于 `lib/features/structure_preview/models/`：

- `structure_preview_definition.dart`
  - 结构总定义，包含结构 id、元数据、相机、部件、步骤和舞台配置
- `structure_preview_metadata.dart`
  - 结构标题、摘要、描述、模块、状态、标签、版本范围、来源
- `structure_preview_part.dart`
  - 单个部件定义，包含 `partId`、`blockId`、名称、说明、分类、位置、朝向、状态和视觉定义
- `structure_preview_step.dart`
  - 步骤标题、说明、当前步骤显示哪些部件、聚焦哪些部件
- `structure_block.dart`
  - `blockId` 对应的默认视觉定义
- `structure_preview_scene.dart`
  - 渲染层使用的低层 scene 数据结构

### 3.2 控制器

控制器位于 `lib/features/structure_preview/controllers/`：

- `structure_selection_controller.dart`
  - 管理当前选中的部件
- `structure_step_controller.dart`
  - 管理当前步骤、步数切换和按步骤可见部件
- `structure_filter_controller.dart`
  - 管理分类过滤和“只看当前步骤相关部件”

### 3.3 服务层

服务位于 `lib/features/structure_preview/services/`：

- `structure_preview_scene_builder.dart`
  - 把正式结构定义转换成 three_js 使用的 scene 数据
- `structure_hit_test_service.dart`
  - 使用 `Raycaster` 做命中检测
- `structure_texture_cache.dart`
  - 纹理缓存
- `structure_preview_filter_resolver.dart`
  - 结合步骤与过滤器计算当前可见部件集合

### 3.4 渲染层

渲染层位于 `lib/features/structure_preview/three_js/structure_preview_renderer.dart`，当前负责：

- 创建 scene、camera、lights、controls
- 根据 scene 数据构建 mesh
- 维护 hover / selected / focused 三类高亮状态
- 应用默认材质、贴图材质和方块视觉定义

### 3.5 视图层

视图相关文件位于 `lib/features/structure_preview/view/`：

- `structure_preview_viewport.dart`
  - Flutter 页面内嵌 3D 视口
- `widgets/structure_step_timeline.dart`
  - 步骤切换条
- `widgets/structure_filter_panel.dart`
  - 过滤面板
- `widgets/structure_part_detail_card.dart`
  - 部件详情卡
- `widgets/structure_insight_panel.dart`
  - 结构说明面板

当前首页科技模块示例位于：

- `lib/features/home/data/tech_structure_preview_data.dart`
- `lib/features/home/view/modules/tech_module_page.dart`

## 4. 功能拆分

### 4.1 结构定义与场景数据

已完成。

当前已经能够用一套正式模型描述：

- 结构级元数据
- 部件级信息
- 步骤级信息
- 相机与舞台配置

### 4.2 部件选中与悬停

已完成。

当前行为：

- 鼠标悬停部件时，3D 结构高亮
- 点击部件后，选中状态锁定
- 右侧说明面板同步更新当前部件信息

### 4.3 步骤系统

已完成。

当前行为：

- 可按步骤切换结构显示
- 当前步骤可定义聚焦部件
- 时间轴与说明面板同步展示当前步骤

### 4.4 方块注册表与视觉映射

已完成第一版。

当前能力：

- `part.visuals` 为空时，会退回到 `blockId` 对应的默认视觉定义
- 已接通基础贴图与材质缓存链路

后续还要继续补：

- 六面贴图命名规范
- 更复杂的 block visual factory
- 非完整立方体的特殊模型

### 4.5 图层与过滤系统

已完成第一版。

当前能力：

- 按分类显示 / 隐藏部件
- 只看当前步骤相关部件
- 过滤后同步修正当前选中部件

### 4.6 说明面板

已完成第一版。

当前说明面板已经包含：

- 结构概览
- 当前可见部件统计
- 过滤状态
- 当前步骤摘要
- 当前部件详情
- 已接入能力清单
- 下一步扩展清单
- 预留入口占位

## 5. 后续需要分别实现的功能

下面这些能力建议继续拆开实现：

### 5.1 页面入口联动

需要实现：

- 从结构说明面板跳转到图鉴词条
- 从结构说明面板跳转到任务概览
- 从结构说明面板查看对应版本差异

依赖：

- 结构级或部件级的关联数据字段
- 页面路由与目标数据源

### 5.2 真实方块视觉

需要实现：

- 方块六面贴图
- 像素风采样配置
- 更完整的 `blockId -> material / texture / model` 注册表
- 机械部件、管道、面板等特殊模型

依赖：

- 贴图资源
- 面朝向约定
- 非立方体方块的建模方案

### 5.3 图层系统增强

需要实现：

- 更细粒度的图层开关
- 基础层 / 机器层 / 连线层 / 装饰层分层显示
- 半透明幽灵部件与步骤对比显示

### 5.4 性能优化

需要实现：

- 重复方块的合批或实例化
- 不可见面剔除
- 更稳定的纹理缓存策略
- 大结构场景下的降级方案

### 5.5 测试与降级

需要实现：

- scene builder 的单元测试
- filter / selection / step controller 的单元测试
- 无 3D 环境时的 fallback 预览卡
- 多平台兼容性验证

## 6. 推荐的下一阶段顺序

建议按下面顺序继续推进：

1. 页面入口联动
2. 真实方块视觉
3. 图层系统增强
4. 性能优化
5. 测试与降级

## 7. 当前结论

目前这套“多方块结构预览”已经不是临时 demo，而是一套可以继续扩展的正式框架：

- 结构数据层已经稳定
- three_js 渲染层已经可复用
- 页面交互链路已经贯通
- 说明面板已经具备继续接真实内容的承载能力

接下来重点不再是“能不能显示一个 3D 结构”，而是把这套框架继续扩成真正能服务图鉴、任务概览和版本说明的结构预览系统。
