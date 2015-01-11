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

{.push callconv:cdecl, dynlib: LibName.}
{.push importc.}

proc IMG_Linked_Version*(): ptr SDL_version {.importc: "IMG_Linked_Version".}
#proc Linked_Version* : ptr SDL_version {.importc: "IMG_$1".}

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
proc IMG_LoadTyped_RW*(src: PRWops; freesrc: cint; `type`: cstring): PSurface
# Convenience functions 
proc IMG_Load*(file: cstring): PSurface {.importc: "IMG_Load".}
proc IMG_Load_RW*(src: PRWops; freesrc: cint): PSurface
  ##Load an image directly into a render texture.
# 
proc IMG_LoadTexture*(renderer: PRenderer; file: cstring): PTexture {.
  importc: "IMG_LoadTexture".}
proc IMG_LoadTexture_RW*(renderer: PRenderer; src: PRWops; 
                         freesrc: cint): PTexture
proc IMG_LoadTextureTyped_RW*(renderer: PRenderer; src: PRWops; 
                              freesrc: cint; `type`: cstring): PTexture


#discard """
# Functions to detect a file type, given a seekable source 
proc IMG_isICO*(src: PRWops): cint
proc IMG_isCUR*(src: PRWops): cint
proc IMG_isBMP*(src: PRWops): cint
proc IMG_isGIF*(src: PRWops): cint
proc IMG_isJPG*(src: PRWops): cint
proc IMG_isLBM*(src: PRWops): cint
proc IMG_isPCX*(src: PRWops): cint
proc IMG_isPNG*(src: PRWops): cint
proc IMG_isPNM*(src: PRWops): cint
proc IMG_isTIF*(src: PRWops): cint
proc IMG_isXCF*(src: PRWops): cint
proc IMG_isXPM*(src: PRWops): cint
proc IMG_isXV*(src: PRWops): cint
proc IMG_isWEBP*(src: PRWops): cint 
# Individual loading functions 
proc IMG_LoadICO_RW*(src: PRWops): PSurface
proc IMG_LoadCUR_RW*(src: PRWops): PSurface
proc IMG_LoadBMP_RW*(src: PRWops): PSurface
proc IMG_LoadGIF_RW*(src: PRWops): PSurface
proc IMG_LoadJPG_RW*(src: PRWops): PSurface
proc IMG_LoadLBM_RW*(src: PRWops): PSurface
proc IMG_LoadPCX_RW*(src: PRWops): PSurface
proc IMG_LoadPNG_RW*(src: PRWops): PSurface
proc IMG_LoadPNM_RW*(src: PRWops): PSurface
proc IMG_LoadTGA_RW*(src: PRWops): PSurface
proc IMG_LoadTIF_RW*(src: PRWops): PSurface
proc IMG_LoadXCF_RW*(src: PRWops): PSurface
proc IMG_LoadXPM_RW*(src: PRWops): PSurface
proc IMG_LoadXV_RW*(src: PRWops): PSurface
proc IMG_LoadWEBP_RW*(src: PRWops): PSurface
proc IMG_ReadXPMFromArray*(xpm: cstringArray): PSurface
#"""


{.pop.}
{.pop.}













