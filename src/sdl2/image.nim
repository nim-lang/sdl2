## A simple library to load images of various formats as SDL surfaces.


import sdl2

when not defined(SDL_Static):
  when defined(windows):
    const LibName = "SDL2_image.dll"
  elif defined(macosx):
    const LibName = "libSDL2_image.dylib"
  else:
    const LibName = "libSDL2_image(|-2.0).so(|.0)"
else:
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."

const
  IMG_INIT_JPG* = 0x00000001
  IMG_INIT_PNG* = 0x00000002
  IMG_INIT_TIF* = 0x00000004
  IMG_INIT_WEBP* = 0x00000008

when not defined(SDL_Static):
  {.push callConv: cdecl, dynlib: LibName.}

proc linkedVersion*(): ptr SDL_version {.importc: "IMG_Linked_Version".}
  ## Gets the version of the dynamically linked image library.

proc init*(flags: cint = IMG_INIT_JPG or IMG_INIT_PNG): cint {.importc: "IMG_Init".}
  ## It returns the flags successfully initialized, or 0 on failure.
  ## This is completely different than sdl2.init() -_-

proc quit*() {.importc: "IMG_Quit".}
  ## Unloads libraries loaded with `init()`.

proc loadTyped_RW*(src: RWopsPtr; freesrc: cint;
                  `type`: cstring): SurfacePtr {.importc: "IMG_LoadTyped_RW".}
  ## Load an image from an SDL data source.
  ##
  ## `kind` may be one of: `"BMP"`, `"GIF"`, `"PNG"`, etc.
  ##
  ## If the image format supports a transparent pixel, SDL will set the
  ## colorkey for the surface.  You can enable RLE acceleration on the
  ## surface afterwards by calling:
  ##
  ## .. code-block:: nim
  ##   setColorKey(image, SDL_RLEACCEL, image.format.colorkey)

# Convenience functions
proc load*(file: cstring): SurfacePtr {.importc: "IMG_Load".}
proc load_RW*(src: RWopsPtr;
              freesrc: cint): SurfacePtr {.importc: "IMG_Load_RW".}
proc load*(src: RWopsPtr; freesrc: cint): SurfacePtr {.importc: "IMG_Load_RW".}
  ## Load an image directly into a render texture.

proc loadTexture*(renderer: RendererPtr;
                  file: cstring): TexturePtr {.importc: "IMG_LoadTexture".}
proc loadTexture_RW*(renderer: RendererPtr; src: RWopsPtr;
                     freesrc: cint): TexturePtr {.
  importc: "IMG_LoadTexture_RW".}
proc loadTexture*(renderer: RendererPtr; src: RWopsPtr;
                  freesrc: cint): TexturePtr {.
  importc: "IMG_LoadTexture_RW".}
proc loadTextureTyped_RW*(renderer: RendererPtr;
                          src: RWopsPtr;
                          freesrc: cint;
                          `type`: cstring): TexturePtr {.
  importc: "IMG_LoadTextureTyped_RW".}
proc loadTexture*(renderer: RendererPtr;
                  src: RWopsPtr;
                  freesrc: cint;
                  `type`: cstring): TexturePtr {.
  importc: "IMG_LoadTextureTyped_RW".}

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
proc loadICO*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadICO_RW".}
proc loadCUR_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadCUR_RW".}
proc loadCUR*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadCUR_RW".}
proc loadBMP_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadBMP_RW".}
proc loadBMP*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadBMP_RW".}
proc loadGIF_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadGIF_RW".}
proc loadGIF*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadGIF_RW".}
proc loadJPG_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadJPG_RW".}
proc loadJPG*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadJPG_RW".}
proc loadLBM_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadLBM_RW".}
proc loadLBM*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadLBM_RW".}
proc loadPCX_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPCX_RW".}
proc loadPCX*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPCX_RW".}
proc loadPNG_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPNG_RW".}
proc loadPNG*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPNG_RW".}
proc loadPNM_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPNM_RW".}
proc loadPNM*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadPNM_RW".}
proc loadTGA_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadTGA_RW".}
proc loadTGA*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadTGA_RW".}
proc loadTIF_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadTIF_RW".}
proc loadTIF*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadTIF_RW".}
proc loadXCF_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXCF_RW".}
proc loadXCF*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXCF_RW".}
proc loadXPM_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXPM_RW".}
proc loadXPM*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXPM_RW".}
proc loadXV_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXV_RW".}
proc loadXV(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadXV_RW".}
proc loadWEBP_RW*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadWEBP_RW".}
proc loadWEBP*(src: RWopsPtr): SurfacePtr {.importc: "IMG_LoadWEBP_RW".}
proc readXPMFromArray*(xpm: cstringArray): SurfacePtr {.importc: "IMG_ReadXPMFromArray".}
proc readXPM*(xpm: cstringArray): SurfacePtr {.importc: "IMG_ReadXPMFromArray".}
# Saving functions
proc savePNG*(surface: SurfacePtr, file: cstring): cint {.importc: "IMG_SavePNG".}

when not defined(SDL_Static):
  {.pop.}
