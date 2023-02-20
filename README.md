# dtilengine

[![](https://img.shields.io/github/v/tag/thechampagne/dtilengine?label=version)](https://github.com/thechampagne/dtilengine/releases/latest) [![](https://img.shields.io/github/license/thechampagne/dtilengine)](https://github.com/thechampagne/dtilengine/blob/main/LICENSE)

D binding for **Tilengine** a 2D graphics engine with raster effects for retro/classic style game development.

### Download
[DUB](https://code.dlang.org/packages/dtilengine/)

```
dub add dtilengine
```

### Example
```d
import dtilengine;

void main() {
    TLN_Tilemap foreground;

    TLN_Init(400, 240, 1, 0, 0);
    foreground = TLN_LoadTilemap("assets/sonic/Sonic_md_fg1.tmx", null);
    TLN_SetLayerTilemap(0, foreground);

    TLN_CreateWindow(null, 0);
    while (TLN_ProcessWindow()) {
        TLN_DrawFrame(0);
    }

    TLN_DeleteTilemap(foreground);
    TLN_Deinit();
}
```

### References
 - [Tilengine](https://github.com/megamarc/Tilengine)

### License

This repo is released under the [MPL-2.0](https://github.com/thechampagne/dtilengine/blob/main/LICENSE).
