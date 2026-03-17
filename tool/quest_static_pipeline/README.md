# Quest Static Pipeline

## Purpose

This folder contains the offline extraction pipeline for quest preview data. It reads:

- `data/quests`
- `data/lang`
- `data/mods`

and generates front-end friendly assets under `assets/generated/quests`.

## Recommended Environment

Recommended Python version: `3.11+`

The extractor currently uses only the Python standard library.
If you use Python `< 3.11`, install `requirements.txt` so TOML parsing can fall back to `tomli`.

## Option A: Conda

```powershell
conda create -n ctnh-quest-pipeline python=3.11 -y
conda activate ctnh-quest-pipeline
pip install -r tool/quest_static_pipeline/requirements.txt
python tool/quest_static_pipeline/extract_mod_assets.py --clean-icons
```

## Option B: venv

```powershell
py -3.11 -m venv tool/quest_static_pipeline/.venv
tool\quest_static_pipeline\.venv\Scripts\Activate.ps1
pip install -r tool/quest_static_pipeline/requirements.txt
python tool/quest_static_pipeline/extract_mod_assets.py --clean-icons
```

## Output

The extractor writes:

- `assets/generated/quests/quest_assets_index.json`
- `assets/generated/quests/build_report.json`
- `assets/generated/quests/icons/mods/...`
- `web/assets/generated/quests/icons/mods/...`

The web mirror exists because Flutter Web may not reliably serve newly generated nested asset files through the asset bundle during iteration. The front end uses the web mirror as a static URL source.

## What The First Version Extracts

- Quest-referenced namespaced ids from `data/quests/**/*.snbt`
- Mod metadata from `META-INF/mods.toml`
- `zh_cn` and `en_us` item/block names from mod lang files
- Best-effort item/block icon textures from item models, blockstates and block models
- A report of unresolved ids and namespaces

## Known Limitations

- Vanilla `minecraft:*` names and icons are not available unless a Minecraft jar or resource pack is provided separately.
- Complex dynamic models are not guaranteed to resolve to the exact in-game icon.
- This stage is optimized for the quest preview UI, not for complete resource-pack reconstruction.
