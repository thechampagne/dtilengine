module dtilengine;

extern (C):

enum TILENGINE_VER_MAJ = 2;
enum TILENGINE_VER_MIN = 14;
enum TILENGINE_VER_REV = 0;
enum TILENGINE_HEADER_VERSION = (TILENGINE_VER_MAJ << 16) | (TILENGINE_VER_MIN << 8) | TILENGINE_VER_REV;

/*! tile/sprite flags. Can be none or a combination of the following: */
enum TLN_TileFlags
{
    NONE = 0, /*!< no flags */
    FLIPX = (1 << 15), /*!< horizontal flip */
    FLIPY = (1 << 14), /*!< vertical flip */
    ROTATE = (1 << 13), /*!< row/column flip (unsupported, Tiled compatibility) */
    PRIORITY = (1 << 12), /*!< tile goes in front of sprite layer */
    MASKED = (1 << 11), /*!< sprite won't be drawn inside masked region */
    TILESET = 7 << 8, /*!< tileset index (0 - 7) */
    PALETTE = 7 << 5 /*!< palette index (0 - 7) */
}

/*!
 * layer blend modes. Must be one of these and are mutually exclusive:
 */
enum TLN_Blend
{
    NONE = 0, /*!< blending disabled */
    MIX25 = 1, /*!< color averaging 1 */
    MIX50 = 2, /*!< color averaging 2 */
    MIX75 = 3, /*!< color averaging 3 */
    ADD = 4, /*!< color is always brighter (simulate light effects) */
    SUB = 5, /*!< color is always darker (simulate shadow effects) */
    MOD = 6, /*!< color is always darker (simulate shadow effects) */
    CUSTOM = 7, /*!< user provided blend function with TLN_SetCustomBlendFunction() */
    MAX_BLEND = 8,
    MIX = MIX50
}

/*!
 * layer type retrieved by \ref TLN_GetLayerType
 */
enum TLN_LayerType
{
    NONE = 0, /*!< undefined */
    TILE = 1, /*!< tilemap-based layer */
    OBJECT = 2, /*!< objects layer */
    BITMAP = 3 /*!< bitmapped layer */
}

/*! Affine transformation parameters */
struct TLN_Affine
{
    float angle; /*!< rotation in degrees */
    float dx; /*!< horizontal translation */
    float dy; /*!< vertical translation */
    float sx; /*!< horizontal scaling */
    float sy; /*!< vertical scaling */
}

/*! Tile item for Tilemap access methods */
union Tile
{
    uint value;

    struct
    {
        ushort index; /*!< tile index */
        union
        {
            ushort flags; /*!< attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) */
            struct
            {
                import std.bitmanip : bitfields;

                mixin(bitfields!(
                    ubyte, "unused", 5,
                    ubyte, "palette", 3,
                    ubyte, "tileset", 3,
                    bool, "masked", 1,
                    bool, "priority", 1,
                    bool, "rotated", 1,
                    bool, "flipy", 1,
                    bool, "flipx", 1));
            }
        }
    }
}

/*! frame animation definition */
struct TLN_SequenceFrame
{
    int index; /*!< tile/sprite index */
    int delay; /*!< time delay for next frame */
}

/*! color strip definition */
struct TLN_ColorStrip
{
    int delay; /*!< time delay between frames */
    ubyte first; /*!< index of first color to cycle */
    ubyte count; /*!< number of colors in the cycle */
    ubyte dir; /*!< direction: 0=descending, 1=ascending */
}

/*! sequence info returned by TLN_GetSequenceInfo */
struct TLN_SequenceInfo
{
    char[32] name; /*!< sequence name */
    int num_frames; /*!< number of frames */
}

/*! Sprite creation info for TLN_CreateSpriteset() */
struct TLN_SpriteData
{
    char[64] name; /*!< entry name */
    int x; /*!< horizontal position */
    int y; /*!< vertical position */
    int w; /*!< width */
    int h; /*!< height */
}

/*! Sprite information */
struct TLN_SpriteInfo
{
    int w; /*!< width of sprite */
    int h; /*!< height of sprite */
}

/*! Tile information returned by TLN_GetLayerTile() */
struct TLN_TileInfo
{
    ushort index; /*!< tile index */
    ushort flags; /*!< attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) */
    int row; /*!< row number in the tilemap */
    int col; /*!< col number in the tilemap */
    int xoffset; /*!< horizontal position inside the title */
    int yoffset; /*!< vertical position inside the title */
    ubyte color; /*!< color index at collision point */
    ubyte type; /*!< tile type */
    bool empty; /*!< cell is empty*/
}

/*! Object item info returned by TLN_GetObjectInfo() */
struct TLN_ObjectInfo
{
    ushort id; /*!< unique ID */
    ushort gid; /*!< graphic ID (tile index) */
    ushort flags; /*!< attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY) */
    int x; /*!< horizontal position */
    int y; /*!< vertical position */
    int width; /*!< horizontal size */
    int height; /*!< vertical size */
    ubyte type; /*!< type property */
    bool visible; /*!< visible property */
    char[64] name; /*!< name property */
}

/*! Tileset attributes for TLN_CreateTileset() */
struct TLN_TileAttributes
{
    ubyte type; /*!< tile type */
    bool priority; /*!< priority flag set */
}

/* kept for backwards compatibility with pre-2.10 release */
enum TLN_OVERLAY_NONE = 0;
enum TLN_OVERLAY_SHADOWMASK = 0;
enum TLN_OVERLAY_APERTURE = 0;
enum TLN_OVERLAY_SCANLINES = 0;
enum TLN_OVERLAY_CUSTOM = 0;

/*! types of built-in CRT effect for \ref TLN_ConfigCRTEffect */
enum TLN_CRT
{
    SLOT = 0, /*!< slot mask without scanlines, similar to legacy effect */
    APERTURE = 1, /*!< aperture grille with scanlines (matrix-like dot arrangement) */
    SHADOW = 2 /*!< shadow mask with scanlines, diagonal subpixel arrangement */
}

/*! pixel mapping for TLN_SetLayerPixelMapping() */
struct TLN_PixelMap
{
    short dx; /*!< horizontal pixel displacement */
    short dy; /*!< vertical pixel displacement */
}

struct Engine;
alias TLN_Engine = Engine*; /*!< Engine context */
alias TLN_Tile = Tile*; /*!< Tile reference */
struct Tileset;
alias TLN_Tileset = Tileset*; /*!< Opaque tileset reference */
struct Tilemap;
alias TLN_Tilemap = Tilemap*; /*!< Opaque tilemap reference */
struct Palette;
alias TLN_Palette = Palette*; /*!< Opaque palette reference */
struct Spriteset;
alias TLN_Spriteset = Spriteset*; /*!< Opaque sspriteset reference */
struct Sequence;
alias TLN_Sequence = Sequence*; /*!< Opaque sequence reference */
struct SequencePack;
alias TLN_SequencePack = SequencePack*; /*!< Opaque sequence pack reference */
struct Bitmap;
alias TLN_Bitmap = Bitmap*; /*!< Opaque bitmap reference */
struct ObjectList;
alias TLN_ObjectList = ObjectList*; /*!< Opaque object list reference */

/*! Image Tile items for TLN_CreateImageTileset() */
struct TLN_TileImage
{
    TLN_Bitmap bitmap;
    ushort id;
    ubyte type;
}

/*! Sprite state */
struct TLN_SpriteState
{
    int x; /*!< Screen position x */
    int y; /*!< Screen position y */
    int w; /*!< Actual width in screen (after scaling) */
    int h; /*!< Actual height in screen (after scaling) */
    uint flags; /*!< flags */
    TLN_Palette palette; /*!< assigned palette */
    TLN_Spriteset spriteset; /*!< assigned spriteset */
    int index; /*!< graphic index inside spriteset */
    bool enabled; /*!< enabled or not */
    bool collision; /*!< per-pixel collision detection enabled or not */
}

/* callbacks */
union SDL_Event;
alias TLN_VideoCallback = void function (int scanline);
alias TLN_BlendFunction = ubyte function (ubyte src, ubyte dst);
alias TLN_SDLCallback = void function (SDL_Event*);

/*! Player index for input assignment functions */
enum TLN_Player
{
    PLAYER1 = 0, /*!< Player 1 */
    PLAYER2 = 1, /*!< Player 2 */
    PLAYER3 = 2, /*!< Player 3 */
    PLAYER4 = 3 /*!< Player 4 */
}

/*! Standard inputs query for TLN_GetInput() */
enum TLN_Input
{
    NONE = 0, /*!< no input */
    UP = 1, /*!< up direction */
    DOWN = 2, /*!< down direction */
    LEFT = 3, /*!< left direction */
    RIGHT = 4, /*!< right direction */
    BUTTON1 = 5, /*!< 1st action button */
    BUTTON2 = 6, /*!< 2nd action button */
    BUTTON3 = 7, /*!< 3th action button */
    BUTTON4 = 8, /*!< 4th action button */
    BUTTON5 = 9, /*!< 5th action button */
    BUTTON6 = 10, /*!< 6th action button */
    START = 11, /*!< Start button */
    QUIT = 12, /*!< Window close (only Player 1 keyboard) */
    CRT = 13, /*!< CRT toggle (only Player 1 keyboard) */

    /* ... up to 32 unique inputs */

    P1 = TLN_Player.PLAYER1 << 5, /*!< request player 1 input (default) */
    P2 = TLN_Player.PLAYER2 << 5, /*!< request player 2 input */
    P3 = TLN_Player.PLAYER3 << 5, /*!< request player 3 input */
    P4 = TLN_Player.PLAYER4 << 5, /*!< request player 4 input */

    /* compatibility symbols for pre-1.18 input model */
    A = BUTTON1,
    B = BUTTON2,
    C = BUTTON3,
    D = BUTTON4,
    E = BUTTON5,
    F = BUTTON6
}

/*! CreateWindow flags. Can be none or a combination of the following: */
enum
{
    CWF_FULLSCREEN = 1 << 0, /*!< create a fullscreen window */
    CWF_VSYNC = 1 << 1, /*!< sync frame updates with vertical retrace */
    CWF_S1 = 1 << 2, /*!< create a window the same size as the framebuffer */
    CWF_S2 = 2 << 2, /*!< create a window 2x the size the framebuffer */
    CWF_S3 = 3 << 2, /*!< create a window 3x the size the framebuffer */
    CWF_S4 = 4 << 2, /*!< create a window 4x the size the framebuffer */
    CWF_S5 = 5 << 2, /*!< create a window 5x the size the framebuffer */
    CWF_NEAREST = 1 << 6 /*<! unfiltered upscaling */
}

/*! Error codes */
enum TLN_Error
{
    OK = 0, /*!< No error */
    OUT_OF_MEMORY = 1, /*!< Not enough memory */
    IDX_LAYER = 2, /*!< Layer index out of range */
    IDX_SPRITE = 3, /*!< Sprite index out of range */
    IDX_ANIMATION = 4, /*!< Animation index out of range */
    IDX_PICTURE = 5, /*!< Picture or tile index out of range */
    REF_TILESET = 6, /*!< Invalid TLN_Tileset reference */
    REF_TILEMAP = 7, /*!< Invalid TLN_Tilemap reference */
    REF_SPRITESET = 8, /*!< Invalid TLN_Spriteset reference */
    REF_PALETTE = 9, /*!< Invalid TLN_Palette reference */
    REF_SEQUENCE = 10, /*!< Invalid TLN_Sequence reference */
    REF_SEQPACK = 11, /*!< Invalid TLN_SequencePack reference */
    REF_BITMAP = 12, /*!< Invalid TLN_Bitmap reference */
    NULL_POINTER = 13, /*!< Null pointer as argument */
    FILE_NOT_FOUND = 14, /*!< Resource file not found */
    WRONG_FORMAT = 15, /*!< Resource file has invalid format */
    WRONG_SIZE = 16, /*!< A width or height parameter is invalid */
    UNSUPPORTED = 17, /*!< Unsupported function */
    REF_LIST = 18, /*!< Invalid TLN_ObjectList reference */
    IDX_PALETTE = 19, /*!< Palette index out of range */
    MAX_ERR = 20
}

/*! Debug level */
enum TLN_LogLevel
{
    NONE = 0, /*!< Don't print anything (default) */
    ERRORS = 1, /*!< Print only runtime errors */
    VERBOSE = 2 /*!< Print everything */
}


TLN_Engine TLN_Init (int hres, int vres, int numlayers, int numsprites, int numanimations);
void TLN_Deinit ();
bool TLN_DeleteContext (TLN_Engine context);
bool TLN_SetContext (TLN_Engine context);
TLN_Engine TLN_GetContext ();
int TLN_GetWidth ();
int TLN_GetHeight ();
uint TLN_GetNumObjects ();
uint TLN_GetUsedMemory ();
uint TLN_GetVersion ();
int TLN_GetNumLayers ();
int TLN_GetNumSprites ();
void TLN_SetBGColor (ubyte r, ubyte g, ubyte b);
bool TLN_SetBGColorFromTilemap (TLN_Tilemap tilemap);
void TLN_DisableBGColor ();
bool TLN_SetBGBitmap (TLN_Bitmap bitmap);
bool TLN_SetBGPalette (TLN_Palette palette);
bool TLN_SetGlobalPalette (int index, TLN_Palette palette);
void TLN_SetRasterCallback (TLN_VideoCallback);
void TLN_SetFrameCallback (TLN_VideoCallback);
void TLN_SetRenderTarget (ubyte* data, int pitch);
void TLN_UpdateFrame (int frame);
void TLN_SetLoadPath (const(char)* path);
void TLN_SetCustomBlendFunction (TLN_BlendFunction);
void TLN_SetLogLevel (TLN_LogLevel log_level);
bool TLN_OpenResourcePack (const(char)* filename, const(char)* key);
void TLN_CloseResourcePack ();
TLN_Palette TLN_GetGlobalPalette (int index);


void TLN_SetLastError (TLN_Error error);
TLN_Error TLN_GetLastError ();
const(char)* TLN_GetErrorString (TLN_Error error);


bool TLN_CreateWindow (const(char)* overlay, int flags);
bool TLN_CreateWindowThread (const(char)* overlay, int flags);
void TLN_SetWindowTitle (const(char)* title);
bool TLN_ProcessWindow ();
bool TLN_IsWindowActive ();
bool TLN_GetInput (TLN_Input id);
void TLN_EnableInput (TLN_Player player, bool enable);
void TLN_AssignInputJoystick (TLN_Player player, int index);
void TLN_DefineInputKey (TLN_Player player, TLN_Input input, uint keycode);
void TLN_DefineInputButton (TLN_Player player, TLN_Input input, ubyte joybutton);
void TLN_DrawFrame (int frame);
void TLN_WaitRedraw ();
void TLN_DeleteWindow ();
void TLN_EnableBlur (bool mode);
void TLN_ConfigCRTEffect (TLN_CRT type, bool blur);
void TLN_EnableCRTEffect (int overlay, ubyte overlay_factor, ubyte threshold, ubyte v0, ubyte v1, ubyte v2, ubyte v3, bool blur, ubyte glow_factor);
void TLN_DisableCRTEffect ();
void TLN_SetSDLCallback (TLN_SDLCallback);
void TLN_Delay (uint msecs);
uint TLN_GetTicks ();
int TLN_GetWindowWidth ();
int TLN_GetWindowHeight ();


TLN_Spriteset TLN_CreateSpriteset (TLN_Bitmap bitmap, TLN_SpriteData* data, int num_entries);
TLN_Spriteset TLN_LoadSpriteset (const(char)* name);
TLN_Spriteset TLN_CloneSpriteset (TLN_Spriteset src);
bool TLN_GetSpriteInfo (TLN_Spriteset spriteset, int entry, TLN_SpriteInfo* info);
TLN_Palette TLN_GetSpritesetPalette (TLN_Spriteset spriteset);
int TLN_FindSpritesetSprite (TLN_Spriteset spriteset, const(char)* name);
bool TLN_SetSpritesetData (TLN_Spriteset spriteset, int entry, TLN_SpriteData* data, void* pixels, int pitch);
bool TLN_DeleteSpriteset (TLN_Spriteset Spriteset);


TLN_Tileset TLN_CreateTileset (int numtiles, int width, int height, TLN_Palette palette, TLN_SequencePack sp, TLN_TileAttributes* attributes);
TLN_Tileset TLN_CreateImageTileset (int numtiles, TLN_TileImage* images);
TLN_Tileset TLN_LoadTileset (const(char)* filename);
TLN_Tileset TLN_CloneTileset (TLN_Tileset src);
bool TLN_SetTilesetPixels (TLN_Tileset tileset, int entry, ubyte* srcdata, int srcpitch);
int TLN_GetTileWidth (TLN_Tileset tileset);
int TLN_GetTileHeight (TLN_Tileset tileset);
int TLN_GetTilesetNumTiles (TLN_Tileset tileset);
TLN_Palette TLN_GetTilesetPalette (TLN_Tileset tileset);
TLN_SequencePack TLN_GetTilesetSequencePack (TLN_Tileset tileset);
bool TLN_DeleteTileset (TLN_Tileset tileset);


TLN_Tilemap TLN_CreateTilemap (int rows, int cols, TLN_Tile tiles, uint bgcolor, TLN_Tileset tileset);
TLN_Tilemap TLN_LoadTilemap (const(char)* filename, const(char)* layername);
TLN_Tilemap TLN_CloneTilemap (TLN_Tilemap src);
int TLN_GetTilemapRows (TLN_Tilemap tilemap);
int TLN_GetTilemapCols (TLN_Tilemap tilemap);
bool TLN_SetTilemapTileset (TLN_Tilemap tilemap, TLN_Tileset tileset);
TLN_Tileset TLN_GetTilemapTileset (TLN_Tilemap tilemap);
bool TLN_SetTilemapTileset2 (TLN_Tilemap tilemap, TLN_Tileset tileset, int index);
TLN_Tileset TLN_GetTilemapTileset2 (TLN_Tilemap tilemap, int index);
bool TLN_GetTilemapTile (TLN_Tilemap tilemap, int row, int col, TLN_Tile tile);
bool TLN_SetTilemapTile (TLN_Tilemap tilemap, int row, int col, TLN_Tile tile);
bool TLN_CopyTiles (TLN_Tilemap src, int srcrow, int srccol, int rows, int cols, TLN_Tilemap dst, int dstrow, int dstcol);
TLN_Tile TLN_GetTilemapTiles (TLN_Tilemap tilemap, int row, int col);
bool TLN_DeleteTilemap (TLN_Tilemap tilemap);


TLN_Palette TLN_CreatePalette (int entries);
TLN_Palette TLN_LoadPalette (const(char)* filename);
TLN_Palette TLN_ClonePalette (TLN_Palette src);
bool TLN_SetPaletteColor (TLN_Palette palette, int color, ubyte r, ubyte g, ubyte b);
bool TLN_MixPalettes (TLN_Palette src1, TLN_Palette src2, TLN_Palette dst, ubyte factor);
bool TLN_AddPaletteColor (TLN_Palette palette, ubyte r, ubyte g, ubyte b, ubyte start, ubyte num);
bool TLN_SubPaletteColor (TLN_Palette palette, ubyte r, ubyte g, ubyte b, ubyte start, ubyte num);
bool TLN_ModPaletteColor (TLN_Palette palette, ubyte r, ubyte g, ubyte b, ubyte start, ubyte num);
ubyte* TLN_GetPaletteData (TLN_Palette palette, int index);
bool TLN_DeletePalette (TLN_Palette palette);


TLN_Bitmap TLN_CreateBitmap (int width, int height, int bpp);
TLN_Bitmap TLN_LoadBitmap (const(char)* filename);
TLN_Bitmap TLN_CloneBitmap (TLN_Bitmap src);
ubyte* TLN_GetBitmapPtr (TLN_Bitmap bitmap, int x, int y);
int TLN_GetBitmapWidth (TLN_Bitmap bitmap);
int TLN_GetBitmapHeight (TLN_Bitmap bitmap);
int TLN_GetBitmapDepth (TLN_Bitmap bitmap);
int TLN_GetBitmapPitch (TLN_Bitmap bitmap);
TLN_Palette TLN_GetBitmapPalette (TLN_Bitmap bitmap);
bool TLN_SetBitmapPalette (TLN_Bitmap bitmap, TLN_Palette palette);
bool TLN_DeleteBitmap (TLN_Bitmap bitmap);


TLN_ObjectList TLN_CreateObjectList ();
bool TLN_AddTileObjectToList (TLN_ObjectList list, ushort id, ushort gid, ushort flags, int x, int y);
TLN_ObjectList TLN_LoadObjectList (const(char)* filename, const(char)* layername);
TLN_ObjectList TLN_CloneObjectList (TLN_ObjectList src);
int TLN_GetListNumObjects (TLN_ObjectList list);
bool TLN_GetListObject (TLN_ObjectList list, TLN_ObjectInfo* info);
bool TLN_DeleteObjectList (TLN_ObjectList list);


bool TLN_SetLayer (int nlayer, TLN_Tileset tileset, TLN_Tilemap tilemap);
bool TLN_SetLayerTilemap (int nlayer, TLN_Tilemap tilemap);
bool TLN_SetLayerBitmap (int nlayer, TLN_Bitmap bitmap);
bool TLN_SetLayerPalette (int nlayer, TLN_Palette palette);
bool TLN_SetLayerPosition (int nlayer, int hstart, int vstart);
bool TLN_SetLayerScaling (int nlayer, float xfactor, float yfactor);
bool TLN_SetLayerAffineTransform (int nlayer, TLN_Affine* affine);
bool TLN_SetLayerTransform (int layer, float angle, float dx, float dy, float sx, float sy);
bool TLN_SetLayerPixelMapping (int nlayer, TLN_PixelMap* table);
bool TLN_SetLayerBlendMode (int nlayer, TLN_Blend mode, ubyte factor);
bool TLN_SetLayerColumnOffset (int nlayer, int* offset);
bool TLN_SetLayerClip (int nlayer, int x1, int y1, int x2, int y2);
bool TLN_DisableLayerClip (int nlayer);
bool TLN_SetLayerWindow (int nlayer, int x1, int y1, int x2, int y2, bool invert);
bool TLN_SetLayerWindowColor (int nlayer, ubyte r, ubyte g, ubyte b, TLN_Blend blend);
bool TLN_DisableLayerWindow (int nlayer);
bool TLN_DisableLayerWindowColor (int nlayer);
bool TLN_SetLayerMosaic (int nlayer, int width, int height);
bool TLN_DisableLayerMosaic (int nlayer);
bool TLN_ResetLayerMode (int nlayer);
bool TLN_SetLayerObjects (int nlayer, TLN_ObjectList objects, TLN_Tileset tileset);
bool TLN_SetLayerPriority (int nlayer, bool enable);
bool TLN_SetLayerParent (int nlayer, int parent);
bool TLN_DisableLayerParent (int nlayer);
bool TLN_DisableLayer (int nlayer);
bool TLN_EnableLayer (int nlayer);
TLN_LayerType TLN_GetLayerType (int nlayer);
TLN_Palette TLN_GetLayerPalette (int nlayer);
TLN_Tileset TLN_GetLayerTileset (int nlayer);
TLN_Tilemap TLN_GetLayerTilemap (int nlayer);
TLN_Bitmap TLN_GetLayerBitmap (int nlayer);
TLN_ObjectList TLN_GetLayerObjects (int nlayer);
bool TLN_GetLayerTile (int nlayer, int x, int y, TLN_TileInfo* info);
int TLN_GetLayerWidth (int nlayer);
int TLN_GetLayerHeight (int nlayer);
int TLN_GetLayerX (int nlayer);
int TLN_GetLayerY (int nlayer);


bool TLN_ConfigSprite (int nsprite, TLN_Spriteset spriteset, uint flags);
bool TLN_SetSpriteSet (int nsprite, TLN_Spriteset spriteset);
bool TLN_SetSpriteFlags (int nsprite, uint flags);
bool TLN_EnableSpriteFlag (int nsprite, uint flag, bool enable);
bool TLN_SetSpritePivot (int nsprite, float px, float py);
bool TLN_SetSpritePosition (int nsprite, int x, int y);
bool TLN_SetSpritePicture (int nsprite, int entry);
bool TLN_SetSpritePalette (int nsprite, TLN_Palette palette);
bool TLN_SetSpriteBlendMode (int nsprite, TLN_Blend mode, ubyte factor);
bool TLN_SetSpriteScaling (int nsprite, float sx, float sy);
bool TLN_ResetSpriteScaling (int nsprite);
//TLNAPI bool TLN_SetSpriteRotation (int nsprite, float angle);
//TLNAPI bool TLN_ResetSpriteRotation (int nsprite);
int TLN_GetSpritePicture (int nsprite);
int TLN_GetSpriteX (int nsprite);
int TLN_GetSpriteY (int nsprite);
int TLN_GetAvailableSprite ();
bool TLN_EnableSpriteCollision (int nsprite, bool enable);
bool TLN_GetSpriteCollision (int nsprite);
bool TLN_GetSpriteState (int nsprite, TLN_SpriteState* state);
bool TLN_SetFirstSprite (int nsprite);
bool TLN_SetNextSprite (int nsprite, int next);
bool TLN_EnableSpriteMasking (int nsprite, bool enable);
void TLN_SetSpritesMaskRegion (int top_line, int bottom_line);
bool TLN_SetSpriteAnimation (int nsprite, TLN_Sequence sequence, int loop);
bool TLN_DisableSpriteAnimation (int nsprite);
bool TLN_PauseSpriteAnimation (int index);
bool TLN_ResumeSpriteAnimation (int index);
bool TLN_DisableAnimation (int index);
bool TLN_DisableSprite (int nsprite);
TLN_Palette TLN_GetSpritePalette (int nsprite);


TLN_Sequence TLN_CreateSequence (const(char)* name, int target, int num_frames, TLN_SequenceFrame* frames);
TLN_Sequence TLN_CreateCycle (const(char)* name, int num_strips, TLN_ColorStrip* strips);
TLN_Sequence TLN_CreateSpriteSequence (const(char)* name, TLN_Spriteset spriteset, const(char)* basename, int delay);
TLN_Sequence TLN_CloneSequence (TLN_Sequence src);
bool TLN_GetSequenceInfo (TLN_Sequence sequence, TLN_SequenceInfo* info);
bool TLN_DeleteSequence (TLN_Sequence sequence);


TLN_SequencePack TLN_CreateSequencePack ();
TLN_SequencePack TLN_LoadSequencePack (const(char)* filename);
TLN_Sequence TLN_GetSequence (TLN_SequencePack sp, int index);
TLN_Sequence TLN_FindSequence (TLN_SequencePack sp, const(char)* name);
int TLN_GetSequencePackCount (TLN_SequencePack sp);
bool TLN_AddSequenceToPack (TLN_SequencePack sp, TLN_Sequence sequence);
bool TLN_DeleteSequencePack (TLN_SequencePack sp);


bool TLN_SetPaletteAnimation (int index, TLN_Palette palette, TLN_Sequence sequence, bool blend);
bool TLN_SetPaletteAnimationSource (int index, TLN_Palette);
bool TLN_GetAnimationState (int index);
bool TLN_SetAnimationDelay (int index, int frame, int delay);
int TLN_GetAvailableAnimation ();
bool TLN_DisablePaletteAnimation (int index);


bool TLN_LoadWorld (const(char)* tmxfile, int first_layer);
void TLN_SetWorldPosition (int x, int y);
bool TLN_SetLayerParallaxFactor (int nlayer, float x, float y);
bool TLN_SetSpriteWorldPosition (int nsprite, int x, int y);
void TLN_ReleaseWorld ();
