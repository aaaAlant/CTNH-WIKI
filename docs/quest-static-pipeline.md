# 任务静态转译方案

## 目标

将根目录下的 `data/quests`、`data/lang`、`data/mods` 作为离线源数据，通过一次性静态转译生成前端可直接加载的任务预览数据和资源索引。Flutter 运行时只读取生成产物，不再解析 SNBT，也不再扫描 mod jar。

## 当前目录约定

- 源任务数据：`data/quests`
- FTB 任务语言：`data/lang`
- Mod jar 数据源：`data/mods`
- 前端生成产物：`assets/generated/quests`

## 预期产物

- `assets/generated/quests/quest_catalog.json`
  - 三栏任务预览主数据
- `assets/generated/quests/quest_assets_index.json`
  - 任务节点图标、物品名、方块名、奖励图标索引
- `assets/generated/quests/icons/...`
  - 从 mod jar 提取出的任务相关图标
- `assets/generated/quests/build_report.json`
  - 本次转译的命中统计、缺失语言 key、缺失贴图记录

## 实施阶段

### 阶段 1：输入路径重构

- [x] 确认新的源目录位于 `data/`
- [x] 将 `data/` 加入 `.gitignore`
- [x] 重构 `tool/generate_quest_catalog.dart`，统一从 `data/quests`、`data/lang` 读取
- [x] 让现有 `quest_catalog.json` 重新生成通过

### 阶段 2：mod 资源索引

- [x] 建立 Python 提取器目录与环境说明
- [x] 新增 `extract_mod_assets.py`，用于扫描 `data/mods/*.jar`
- [x] 实现 `lang/*.json` 和旧版 `.lang` 的读取逻辑
- [x] 实现 item/block model、blockstate 与 texture 的最佳努力图标解析逻辑
- [ ] 在真实 Python 环境中执行提取并校验 `quest_assets_index.json`

### 阶段 3：任务转译增强

- [x] 任务文案优先使用 FTB 语言表
- [x] 未命中文案时回退到 mod 语言表
- [x] 为任务节点和奖励绑定最佳可用图标
- [ ] 输出标题来源、图标来源与缺失原因

### 阶段 4：前端接入与验证

- [x] 前端继续只读 `assets/generated/quests`
- [ ] 验证章节列表、任务图、右侧详情在生成数据下完整可用
- [ ] 评估生成体积与 Web 端加载性能

## Python 提取器

- 脚本路径：`tool/quest_static_pipeline/extract_mod_assets.py`
- 环境说明：`tool/quest_static_pipeline/README.md`
- 依赖文件：`tool/quest_static_pipeline/requirements.txt`

### 当前职责

- 从 `data/quests/**/*.snbt` 里收集任务引用的命名空间 id
- 扫描 `data/mods/*.jar`
- 提取 mod 元数据、`zh_cn/en_us` 的 item/block 名称
- 通过 item model、blockstate、block model 和 texture 路径进行最佳努力图标解析
- 生成：`quest_assets_index.json`、`build_report.json` 与 `icons/mods/...`

### 当前已知边界

- 若没有提供 Minecraft 原版资源，`minecraft:*` 的名称和图标无法完整解析
- 复杂动态模型只能做近似图标，不保证和游戏内完全一致
- 当前优先服务任务预览界面，不做完整资源包重建

## 运行方式

推荐使用 Python `3.11+`。

Conda 示例：

```powershell
conda create -n ctnh-quest-pipeline python=3.11 -y
conda activate ctnh-quest-pipeline
pip install -r tool/quest_static_pipeline/requirements.txt
python tool/quest_static_pipeline/extract_mod_assets.py --clean-icons
```

venv 示例：

```powershell
py -3.11 -m venv tool/quest_static_pipeline/.venv
tool\quest_static_pipeline\.venv\Scripts\Activate.ps1
pip install -r tool/quest_static_pipeline/requirements.txt
python tool/quest_static_pipeline/extract_mod_assets.py --clean-icons
```

## 风险边界

- 任务文案的解析成功率会很高，但前提是源语言 key 存在。
- 普通物品图标和普通方块代表图大概率可以自动提取。
- 复杂机器、多层 blockstate、代码动态生成模型不能保证完全自动还原。
- 第一版目标是“任务预览器”，不是完整复刻游戏资源浏览器。

## 进度日志

- 2026-03-17：确认数据已迁移至 `data/quests`、`data/lang`、`data/mods`，开始重构静态转译链路。
- 2026-03-17：生成器输入路径已切换到 `data/quests` 与 `data/lang`，并已重新生成通过。
- 2026-03-17：新增 Python 提取器 `tool/quest_static_pipeline/extract_mod_assets.py`，开始接入 mod jar 的名称与图标提取。
- 2026-03-17：当前沙箱内 `python` 不可用，因此提取器尚未在本地执行验证；下一步需要在你的 Conda 或 venv 环境中跑第一轮提取。
- 2026-03-17：quest_assets_index.json 已接入任务页面运行时加载，任务节点、目标和奖励会优先显示提取出的名称与图标。
- 2026-03-17：为避免 Flutter Web 对新生成嵌套 asset 的 404 问题，图标现在会同时镜像到 web/assets/generated/quests/icons/...，Web 前端改走静态 URL 加载。

