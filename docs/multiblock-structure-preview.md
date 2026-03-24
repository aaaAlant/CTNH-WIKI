# 多方块结构预览模块说明

## 1. 当前目标

“多方块结构预览”用于在 Flutter 页面里嵌入一个可交互的 3D 结构窗口，向玩家展示：

- 一个多方块结构由哪些方块组成
- 它们在空间里如何分布
- 应该按什么顺序搭建
- 点击任意关键方块后，对应说明是什么

当前实现已经不再只是手工摆几个演示方块，而是开始支持从机器 `pattern` 自动生成结构。

## 2. 当前已完成能力

### 2.1 结构模型与 three_js 预览

已完成：

- 正式结构定义模型
- three_js 预览视口
- 相机旋转、缩放
- 部件选中与悬停高亮
- 步骤切换
- 分类过滤
- 说明面板联动

核心目录：

- `lib/features/structure_preview/models/`
- `lib/features/structure_preview/services/`
- `lib/features/structure_preview/three_js/`
- `lib/features/structure_preview/view/`

### 2.2 方块注册与贴图映射

已完成：

- `blockId -> visuals` 的注册表
- 单贴图材质
- 六面贴图材质
- 像素风贴图采样
- 贴图缓存

核心文件：

- `lib/features/structure_preview/data/structure_block_registry.dart`
- `lib/features/structure_preview/services/structure_texture_cache.dart`

### 2.3 pattern 自动建模

新增完成：

- 可把 `FactoryBlockPattern.start().aisle(...).where(...)` 这一类结构模式转成预览部件
- 支持按 `symbol` 映射到真实方块定义或空气跳过
- 自动生成三维坐标与部件 id
- 自动产出 `symbol -> partIds`，供步骤系统直接复用

核心文件：

- `lib/features/structure_preview/services/multiblock_pattern_builder.dart`

当前 builder 支持：

- 多个 `aisle`
- 每个 `aisle` 多行字符串
- `skip` 符号
- 自定义方块 id、分类、标签、朝向、旋转
- 配置行序和 aisle 朝向

## 3. 新增示例：工业土高炉

当前首页科技模块已经接入了一个真实多方块示例：工业土高炉。

相关文件：

- `lib/features/home/data/tech_structure_preview_data.dart`
- `lib/features/structure_preview/data/structure_block_registry.dart`
- `data/machine/machine_primitive_bricks.png`
- `data/machine/overlay_front.png`
- `data/machine/overlay_front_active.png`

### 3.1 当前结构来源

当前土高炉结构直接来自你提供的 pattern：

```java
.pattern(definition -> FactoryBlockPattern.start()
    .aisle("XXX", "XXX", "XXX", "XXX")
    .aisle("XXX", "X&X", "X#X", "X#X")
    .aisle("XXX", "XYX", "XXX", "XXX")
    .where('X', blocks(CASING_PRIMITIVE_BRICKS.get()))
    .where('#', Predicates.air())
    .where('&', Predicates.air().or(...))
    .where('Y', Predicates.controller(blocks(definition.getBlock())))
    .build())
```

### 3.2 当前解析结果

当前预览按下面的规则构建：

- `X`：土高炉砖块
- `Y`：工业土高炉控制器
- `#`：空气，不建模
- `&`：空气/雪，不建模

当前结构尺寸：

- 宽度 3
- 高度 4
- 深度 3

### 3.3 当前外观实现

已完成：

- 砖体使用 `machine_primitive_bricks.png`
- 控制器主体仍沿用砖体贴图
- 控制器正面叠加 `overlay_front_active.png`

当前实现方式不是运行时拼贴图片，而是：

- 基础方块走 registry 里的贴图立方体
- 控制器额外增加一个很薄的前脸 overlay 几何层

这样做的好处是简单、稳定，而且对现有渲染层侵入小。

## 4. 当前关键假设

这次土高炉预览有一个明确假设：

- pattern 的行顺序当前按“从下到上”解释
- aisle 顺序当前按“从后到前”解释
- 控制器 `Y` 因此位于结构正面中心

这个假设是为了让控制器朝向和预览视角更符合机器阅读习惯。

如果你后面确认 GT/CTNH 实际 pattern 的坐标规则不同，我们只需要调整 builder 的两个方向参数，不需要重写整个结构定义。

## 5. 下一阶段建议

建议继续按下面顺序推进：

1. 给控制器补 `inactive / active` 状态切换
2. 给 pattern builder 增加可选的符号级覆写视觉
3. 把更多机器 pattern 接进同一套 builder
4. 把多方块预览接到机器图鉴页，而不是只放在首页科技模块
5. 增加“显示空气腔体轮廓”或“显示内部空间”的辅助模式

## 6. 当前结论

现在这套多方块预览已经具备两层能力：

- 可以展示 3D 结构
- 可以从真实机器 pattern 自动建模

这意味着后面扩展别的多方块机器时，工作重点会从“手工摆方块坐标”转成：

- 提供 pattern
- 提供方块贴图或模型
- 配置 symbol 映射
- 配置步骤和说明

这条链路已经可以作为正式框架继续扩展。
