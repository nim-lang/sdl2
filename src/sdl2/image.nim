import sdl2

when defined(Linux):
  const LibName = "libSDL2_image.so"
elif defined(macosx):
  const LibName = "libSDL2_image.dylib"
elif defined(Windows):
  const LibName = "SDL2_image.dll"
else:
  {.fatal: "Please fill out the library name for your platform at the top of sdl2/image.nim".}



const
  IMG_INIT_JPG* = 0x00000001
  IMG_INIT_PNG* = 0x00000002
  IMG_INIT_TIF* = 0x00000004
  IMG_INIT_WEBP* = 0x00000008

{.push callconv:cdecl, dynlib: LibName.}

proc linkedVersion*(): ptr SDL_version {.importc: "IMG_Linked_Version".}

proc init*(flags: cint = IMG_INIT_JPG or IMG_INIT_PNG): cint {.importc: "IMG_Init".}
  ## It returns the flags successfully initialized, or 0 on failure.
  ## This is completely different than SDL_Init() -_-

proc quit*() {.importc: "IMG_Quit".}
# Load an image from an SDL data source.
#   The 'type' may be one of: "BMP", "GIF", "PNG", etc.
#
#   If the image format supports a transparent pixel, SDL will set the
#   colorkey for the surface.  You can enable RLE acceleration on the
#   surface afterwards by calling:
# SDL_SetColorKey(image, SDL_RLEACCEL, image->format->colorkey);
#
proc loadTyped_RW*(src: RWopsPtr; freesrc: cint; `type`: cstring): SurfacePtr {.importc: "IMG_LoadTyped_RW".}
# Convenience functions
proc load*(file: cstring): SurfacePtr {.importc: "IMG_Load".}
proc load_RW*(src: RWopsPtr; freesrc: cint): SurfacePtr {.importc: "IMG_Load_RW".}
  ##Load an image directly into a render texture.
#
proc loadTexture*(renderer: RendererPtr; file: cstring): TexturePtr {.importc: "IMG_LoadTexture".}
proc loadTexture_RW*(renderer: RendererPtr; src: RWopsPtr;
                     freesrc: cint): TexturePtr {.importc: "IMG_LoadTexture_RW".}
proc loadTextureTyped_RW*(renderer: RendererPtr; src: RWopsPtr;
                          freesrc: cint; `type`: cstring): TexturePtr {.importc: "IMG_LoadTextureTyped_RW".}

#discard """
# Functions to detect a file type, given a seekable source
proc isICO*(src: RWopsPtr): cint {.importc: "IMG_isICO".}
proc isCUR*(src: RWopsPtr): cint {.importc: "IMG_isCUR".}
proc isBMP*(src: RWopsPtr): cint {.importc: "IMG_isBMP".}
proc isGIF*(src: RWopsPtr): cint {.importc: "IMG_isGIF".}
proc isJPG*(src: RWopsPtr): cint {.importc: "IMG_isJPG".}
proc isLBM*(src: RWopsPtr): cint {.importc: "IMG_isLBM".}
proc isPCX*(src: RWopsPtr): cint {.importc: "IMG_isPCX".}
proc isPNG*(src: RWopsPtr): cint {.importc: "IMG_isPNG".}
proc isPNM*(src: RWopsPtr): cint {.importc: "IMG_isPNM".}
proc isTIF*(src: RWopsPtr): cint {.importc: "IMG_isTIF".}
proc isXCF*(src: RWopsPtr): cint {.importc: "IMG_isXCF".}
proc isXPM*(src: RWopsPtr): cint {.importc: "IMG_isXPM".}
proc isXV*(src: RWopsPtr): cint {.importc: "IMG_isXV".}
proc isWEBP*(src: RWopsPtr): cint {.importc: "IMG_isWEBP".}
# Individual loading functions
proc loadICO_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadICO_RW".}
proc loadCUR_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadCUR_RW".}
proc loadBMP_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadBMP_RW".}
proc loadGIF_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadGIF_RW".}
proc loadJPG_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadJPG_RW".}
proc loadLBM_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadLBM_RW".}
proc loadPCX_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPCX_RW".}
proc loadPNG_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPNG_RW".}
proc loadPNM_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPNM_RW".}
proc loadTGA_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadTGA_RW".}
proc loadTIF_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadTIF_RW".}
proc loadXCF_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXCF_RW".}
proc loadXPM_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXPM_RW".}
proc loadXV_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXV_RW".}
proc loadWEBP_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadWEBP_RW".}
proc readXPMFromArray*(xpm: cstringArray): SurfacePtr {.importc: "IMG_ReadXPMFromArray".}
#"""

{.pop.}

{.deprecated: [IMG_Init: init].}
{.deprecated: [IMG_Linked_Version: linkedVersion].}
{.deprecated: [IMG_Load: load].}
{.deprecated: [IMG_LoadBMP_RW: loadBMP_RW].}
{.deprecated: [IMG_LoadCUR_RW: loadCUR_RW].}
{.deprecated: [IMG_LoadGIF_RW: loadGIF_RW].}
{.deprecated: [IMG_LoadICO_RW: loadICO_RW].}
{.deprecated: [IMG_LoadJPG_RW: loadJPG_RW].}
{.deprecated: [IMG_LoadLBM_RW: loadLBM_RW].}
{.deprecated: [IMG_LoadPCX_RW: loadPCX_RW].}
{.deprecated: [IMG_LoadPNG_RW: loadPNG_RW].}
{.deprecated: [IMG_LoadPNM_RW: loadPNM_RW].}
{.deprecated: [IMG_LoadTGA_RW: loadTGA_RW].}
{.deprecated: [IMG_LoadTIF_RW: loadTIF_RW].}
{.deprecated: [IMG_LoadTexture: loadTexture].}
{.deprecated: [IMG_LoadTextureTyped_RW: loadTextureTyped_RW].}
{.deprecated: [IMG_LoadTexture_RW: loadTexture_RW].}
{.deprecated: [IMG_LoadTyped_RW: loadTyped_RW].}
{.deprecated: [IMG_LoadWEBP_RW: loadWEBP_RW].}
{.deprecated: [IMG_LoadXCF_RW: loadXCF_RW].}
{.deprecated: [IMG_LoadXPM_RW: loadXPM_RW].}
{.deprecated: [IMG_LoadXV_RW: loadXV_RW].}
{.deprecated: [IMG_Load_RW: load_RW].}
{.deprecated: [IMG_Quit: quit].}
{.deprecated: [IMG_ReadXPMFromArray: readXPMFromArray].}
{.deprecated: [IMG_isBMP: isBMP].}
{.deprecated: [IMG_isCUR: isCUR].}
{.deprecated: [IMG_isGIF: isGIF].}
{.deprecated: [IMG_isICO: isICO].}
{.deprecated: [IMG_isJPG: isJPG].}
{.deprecated: [IMG_isLBM: isLBM].}
{.deprecated: [IMG_isPCX: isPCX].}
{.deprecated: [IMG_isPNG: isPNG].}
{.deprecated: [IMG_isPNM: isPNM].}
{.deprecated: [IMG_isTIF: isTIF].}
{.deprecated: [IMG_isWEBP: isWEBP].}
{.deprecated: [IMG_isXCF: isXCF].}
{.deprecated: [IMG_isXPM: isXPM].}
{.deprecated: [IMG_isXV: isXV].}
