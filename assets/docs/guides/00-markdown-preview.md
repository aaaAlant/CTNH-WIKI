---
title: Markdown 语法预览
summary: 用于预览攻略教程板块当前支持的 Markdown 渲染效果。
order: 0
---

# Markdown 语法预览

这份文档用于验证 `攻略教程` 板块的 Markdown 渲染能力。后续只需要把新的 `.md` 文档放进 `assets/docs/guides/`，页面就会自动发现并显示。

---

## 1. 标题层级

### 三级标题

#### 四级标题

普通正文会保持较舒适的行高，适合放较长的整包说明、推进思路和配图注释。

## 2. 强调与行内语法

- 这是 **加粗** 文本
- 这是 *斜体* 文本
- 这是 ~~删除线~~ 文本
- 这是 `行内代码`

> 这是引用块。  
> 适合放提示、注意事项、特殊说明或作者注。

## 3. 列表

### 无序列表

- 开荒阶段
- 科技推进
- 魔法支线
- 物流整理

### 有序列表

1. 先确认文档文件名排序
2. 再编写正文和配图说明
3. 最后把文档放到指定目录中

## 4. 链接

- [CTNH GitHub 仓库](https://github.com/CTNH-Team/Create-New-Horizon)
- [CurseForge 页面](https://www.curseforge.com/minecraft/modpacks/ctnh)

## 5. 配图

下面是一张来自当前本地资源的示例图片：

![精密构件示意图](assets/images/wiki/formal/image1.png)

## 6. 代码块

```md
# 这是一个示例标题

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

## 7. 表格

| 模块 | 说明 | 当前状态 |
| --- | --- | --- |
| 科技 | 机械动力、格雷科技、血肉重铸 | 已录入 |
| 魔法 | 植物魔法、血魔法 | 已录入 |
| 物流 | AE2 及附属扩展 | 已录入 |

## 8. 分隔线

---

## 9. 最后说明

后续正式攻略文档建议使用如下约定：

1. 文件名使用 `NN-标题.md`
2. 第一行可选 YAML 头信息
3. 正文第一段写用途概述
4. 图片尽量引用本地 `assets` 资源
