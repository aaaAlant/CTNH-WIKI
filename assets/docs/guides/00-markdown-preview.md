---
title: Markdown 语法预览
summary: 用于预览攻略教程板块当前支持的 Markdown 渲染效果。
order: 0
---

# Markdown 语法预览

这份文档用于验证 `攻略教程` 板块当前支持的 Markdown 能力，也方便我们确认标题、代码块、表格、图片和引用的实际视觉效果。

---

## 标题层级

### 三级标题

#### 四级标题

普通正文会保持比较舒适的行高，适合写整包说明、推进思路和配图注释。

## 强调与行内语法

- 这是 **加粗** 文本
- 这是 *斜体* 文本
- 这是 ~~删除线~~ 文本
- 这是 `行内代码`

> 这是引用块。
> 适合放注意事项、提示信息、阶段提醒或特殊说明。

## 列表

### 无序列表

- 开荒阶段
- 科技推进
- 魔法支线
- 物流整理

### 有序列表

1. 先确认注册表内容
2. 再编写 Markdown 正文
3. 最后在页面里测试搜索和标签筛选

## 链接

- [CTNH GitHub 仓库](https://github.com/CTNH-Team/Create-New-Horizon)
- [CurseForge 页面](https://www.curseforge.com/minecraft/modpacks/ctnh)

## 配图

下面是一张来自本地资源的示例图片：

![正式 Wiki 配图](assets/images/wiki/formal/image1.png)

## 代码块

```md
# 示例标题
- 列表项 A
- 列表项 B

![示例图片](assets/images/wiki/formal/image1.png)
```

```dart
class ExampleGuideStep {
  const ExampleGuideStep(this.title, this.description);

  final String title;
  final String description;
}
```

## 表格

| 模块 | 说明 | 当前状态 |
| --- | --- | --- |
| 科技 | 机械动力、格雷科技、应用能源等 | 已接入 |
| 魔法 | 植物魔法、血魔法、血肉重铸等 | 已接入 |
| 物流 | AE2 及附属扩展 | 已接入 |

## 结束说明

后续正式教程建议遵守这几个约定：

1. Markdown 只负责正文内容。
2. 分类、标签、顺序由 `index.json` 统一维护。
3. 图片尽量优先使用本地 `assets` 资源。
