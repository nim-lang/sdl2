import sdl2

when defined(Linux):
  const LibName = "libSDL2_image.so"
elif defined(macosx):
  const LibName = "libSDL2_image.dylib"
else:
  {.fatal: "Please fill out the library name for your platform at the top of sdl2/image.nim".}



const
  IMG_INIT_JPG* = 0x00000001
  IMG_INIT_PNG* = 0x00000002
  IMG_INIT_TIF* = 0x00000004
  IMG_INIT_WEBP* = 0x00000008

{.push callconv:cdecl, dynlib: libName.}
{.push importc.}

proc IMG_Linked_Version*(): ptr SDL_version {.importc: "IMG_Linked_Version".}
#proc linked_Version* : ptr SDL_version {.importc: "IMG_$1".}

proc IMG_Init*(flags: cint = IMG_INIT_JPG or IMG_INIT_PNG): cint {.
  importc: "IMG_Init".}
  ## It returns the flags successfully initialized, or 0 on failure.
  ## This is completely different than SDL_Init() -_-

proc IMG_Quit*() {.importc: "IMG_Quit".}
# Load an image from an SDL data source.
#   The 'type' may be one of: "BMP", "GIF", "PNG", etc.
#
#   If the image format supports a transparent pixel, SDL will set the
#   colorkey for the surface.  You can enable RLE acceleration on the
#   surface afterwards by calling:
# SDL_SetColorKey(image, SDL_RLEACCEL, image->format->colorkey);
#
proc IMG_LoadTyped_RW*(src: RWopsPtr; freesrc: cint; `type`: cstring): SurfacePtr
# Convenience functions
proc IMG_Load*(file: cstring): SurfacePtr {.importc: "IMG_Load".}
proc IMG_Load_RW*(src: RWopsPtr; freesrc: cint): SurfacePtr
  ##Load an image directly into a render texture.
#
proc IMG_LoadTexture*(renderer: RendererPtr; file: cstring): TexturePtr {.
  importc: "IMG_LoadTexture".}
proc IMG_LoadTexture_RW*(renderer: RendererPtr; src: RWopsPtr;
                         freesrc: cint): TexturePtr
proc IMG_LoadTextureTyped_RW*(renderer: RendererPtr; src: RWopsPtr;
                              freesrc: cint; `type`: cstring): TexturePtr


#discard """
# Functions to detect a file type, given a seekable source
proc IMG_isICO*(src: RWopsPtr): cint
proc IMG_isCUR*(src: RWopsPtr): cint
proc IMG_isBMP*(src: RWopsPtr): cint
proc IMG_isGIF*(src: RWopsPtr): cint
proc IMG_isJPG*(src: RWopsPtr): cint
proc IMG_isLBM*(src: RWopsPtr): cint
proc IMG_isPCX*(src: RWopsPtr): cint
proc IMG_isPNG*(src: RWopsPtr): cint
proc IMG_isPNM*(src: RWopsPtr): cint
proc IMG_isTIF*(src: RWopsPtr): cint
proc IMG_isXCF*(src: RWopsPtr): cint
proc IMG_isXPM*(src: RWopsPtr): cint
proc IMG_isXV*(src: RWopsPtr): cint
proc IMG_isWEBP*(src: RWopsPtr): cint
# Individual loading functions
proc IMG_LoadICO_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadCUR_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadBMP_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadGIF_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadJPG_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadLBM_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadPCX_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadPNG_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadPNM_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadTGA_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadTIF_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadXCF_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadXPM_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadXV_RW*(src: RWopsPtr): SurfacePtr
proc IMG_LoadWEBP_RW*(src: RWopsPtr): SurfacePtr
proc IMG_ReadXPMFromArray*(xpm: cstringArray): SurfacePtr
#"""


{.pop.}
{.pop.}













