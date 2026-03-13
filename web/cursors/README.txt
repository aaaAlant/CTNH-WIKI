Place custom web cursor assets in this folder.

Theme folders:
- tech/manifest.json
- magic/manifest.json
- adventure/manifest.json

Recommended size:
- 32x32 PNG with transparent background

The hotspot in web/index.html is currently set to 8 8.
Each theme folder should contain a manifest.json file with an array of cursor
file names. The web code will read that manifest and randomly choose one entry
whenever the theme is activated.
