import macros

import unsigned, strutils
export unsigned, strutils.`%`


# Add for people running sdl 2.0.0
{. deadCodeElim: on .}

{.push warning[user]: off}
when defined(SDL_Static):
  static: echo "SDL2 will be statically linked. Please make sure you pass the correct compiler/linker flags "&
    "(header search paths, library search paths, linked libraries)."
  #{.passl: gorge("pkg-config --libs sdl2").}
  #{.pragma: sdl_header, header: "<SDL2/SDL.h>".}
  #{.error: "Static linking SDL2 is disabled.".}

else:
  when defined(Windows):
    const LibName* = "SDL2.dll"
  elif defined(Linux):
    const LibName* = "libSDL2.so"
  elif defined(macosx):
    const LibName* = "libSDL2.dylib"
{.pop.}

include sdl2/private/keycodes

const
  SDL_TEXTEDITINGEVENT_TEXT_SIZE* = 32
  SDL_TEXTINPUTEVENT_TEXT_SIZE* = 32
type

  WindowEventID* {.size: sizeof(byte).} = enum
    WindowEvent_None = 0, WindowEvent_Shown, WindowEvent_Hidden, WindowEvent_Exposed,
    WindowEvent_Moved, WindowEvent_Resized, WindowEvent_SizeChanged, WindowEvent_Minimized,
    WindowEvent_Maximized, WindowEvent_Restored, WindowEvent_Enter, WindowEvent_Leave,
    WindowEvent_FocusGained, WindowEvent_FocusLost, WindowEvent_Close

  EventType* {.size: sizeof(cint).} = enum
    QuitEvent = 0x100, AppTerminating, AppLowMemory, AppWillEnterBackground, AppDidEnterBackground, AppWillEnterForeground, AppDidEnterForeground,
    WindowEvent = 0x200, SysWMEvent,
    KeyDown = 0x300, KeyUp, TextEditing, TextInput,
    MouseMotion = 0x400, MouseButtonDown, MouseButtonUp, MouseWheel,
    JoyAxisMotion = 0x600, JoyBallMotion, JoyHatMotion, JoyButtonDown, JoyButtonUp, JoyDeviceAdded, JoyDeviceRemoved,
    ControllerAxisMotion = 0x650, ControllerButtonDown, ControllerButtonUp, ControllerDeviceAdded, ControllerDeviceRemoved, ControllerDeviceRemapped,
    FingerDown = 0x700, FingerUp, FingerMotion,
    DollarGesture = 0x800, DollarRecord, MultiGesture,
    ClipboardUpdate = 0x900,
    DropFile = 0x1000,
    UserEvent = 0x8000, UserEvent1, UserEvent2, UserEvent3, UserEvent4, UserEvent5


  Event* = object
    kind*: EventType
    padding: array[56-sizeof(EventType), byte]

  QuitEventPtr* = ptr QuitEventObj
  QuitEventObj* = object
    kind*: EventType
    timestamp*: uint32
  WindowEventPtr* = ptr WindowEventObj
  WindowEventObj* = object
    kind*: EventType
    timestamp*: uint32
    windowID*: uint32
    event*: WindowEventID
    pad1,pad2,pad3: uint8
    data1*, data2*: cint
  KeyboardEventPtr* = ptr KeyboardEventObj
  KeyboardEventObj* = object
    kind*: EventType
    timestamp*: uint32
    windowID*: uint32
    state*: uint8
    repeat*: bool
    pad1,pad2: byte
    keysym*: KeySym
  TextEditingEventPtr* = ptr TextEditingEventObj
  TextEditingEventObj* = object
    kind*: EventType
    timestamp*: uint32
    windowID*: uint32
    text*: array[SDL_TEXTEDITINGEVENT_TEXT_SIZE, char]
    start*,length*: int32
  TextInputEventPtr* = ptr TextInputEventObj
  TextInputEventObj* = object
    kind*: EventType
    timestamp*: uint32
    windowID*: uint32
    text*: array[SDL_TEXTINPUTEVENT_TEXT_SIZE,char]
  MouseMotionEventPtr* = ptr MouseMotionEventObj
  MouseMotionEventObj* =  object
    kind*: EventType
    timestamp*,windowID*: uint32
    which*: uint32
    state*: uint32
    x*,y*, xrel*,yrel*: int32
  MouseButtonEventPtr* = ptr MouseButtonEventObj
  MouseButtonEventObj* = object
    kind*: EventType
    timestamp*,windowID*: uint32
    which*: uint32
    button*: uint8
    state*: uint8
    pad1,pad2: uint8
    x*,y*: cint
  MouseWheelEventPtr* = ptr MouseWheelEventObj
  MouseWheelEventObj* = object
    kind*: EventType
    timestamp*,windowID*: uint32
    which*: uint32
    x*,y*: cint
  JoyAxisEventPtr* = ptr JoyAxisEventObj
  JoyAxisEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: uint8
    axis*: uint8
    pad1,pad2: uint8
    value*: cint
  JoyBallEventPtr* = ptr JoyBallEventObj
  JoyBallEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*,ball*, pad1,pad2: uint8
    xrel*,yrel*: int32
  JoyHatEventPtr* = ptr JoyHatEventObj
  JoyHatEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: int32
    hat*,value*: uint8
  JoyButtonEventPtr* = ptr JoyButtonEventObj
  JoyButtonEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: int32
    button*,state*: uint8
  JoyDeviceEventPtr* = ptr JoyDeviceEventObj
  JoyDeviceEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: int32
  ControllerAxisEventPtr* = ptr ControllerAxisEventObj
  ControllerAxisEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: int32
    axis*, pad1,pad2,pad3: uint8
    value*: int16
  ControllerButtonEventPtr* = ptr ControllerButtonEventObj
  ControllerButtonEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: int32
    button*,state*: uint8
  ControllerDeviceEventPtr* = ptr ControllerDeviceEventObj
  ControllerDeviceEventObj* = object
    kind*: EventType
    timestamp*: uint32
    which*: int32

  TouchID = int64
  FingerID = int64

  TouchFingerEventPtr* = ptr TouchFingerEventObj
  TouchFingerEventObj* = object
    kind*: EventType
    timestamp*: uint32
    touchID*: TouchID
    fingerID*: FingerID
    x*,y*,dx*,dy*,pressure*: cfloat
  MultiGestureEventPtr* = ptr MultiGestureEventObj
  MultiGestureEventObj* = object
    kind*: EventType
    timestamp*: uint32
    touchID*: TouchID
    dTheta*,dDist*,x*,y*: cfloat
    numFingers*: uint16

  GestureID = int64
  DollarGestureEventPtr* = ptr DollarGestureEventObj
  DollarGestureEventObj* = object
    kind*: EventType
    timestamp*: uint32
    touchID*: TouchID
    gestureID*: GestureID
    numFingers*: uint32
    error*, x*, y*: float
  DropEventPtr* = ptr DropEventObj
  DropEventObj* = object
    kind*: EventType
    timestamp*: uint32
    file*: cstring
  UserEventPtr* = ptr UserEventObj
  UserEventObj* = object
    kind*: EventType
    timestamp*,windowID*: uint32
    code*: int32
    data1*,data2*: pointer

  Eventaction* {.size: sizeof(cint).} = enum
    SDL_ADDEVENT, SDL_PEEKEVENT, SDL_GETEVENT
  EventFilter* = proc (userdata: pointer; event: ptr Event): Bool32 {.cdecl.}


  SDL_Return* {.size: sizeof(cint).} = enum SdlError = -1, SdlSuccess = 0 ##\
    ## Return value for many SDL functions. Any function that returns like this \
    ## should also be discardable
  Bool32* {.size: sizeof(cint).} = enum False32 = 0, True32 = 1 ##\
    ## SDL_bool
  KeyState* {.size: sizeof(byte).} = enum KeyReleased = 0, KeyPressed

  KeySym* {.pure.} = object
    scancode*: ScanCode
    sym*: cint ##Keycode
    modstate*: int16
    unicode*: cint

  Point* = tuple[x, y: cint]
  Rect* = tuple[x, y: cint, w, h: cint]

  GLattr*{.size: sizeof(cint).} = enum
    SDL_GL_RED_SIZE,
    SDL_GL_GREEN_SIZE,
    SDL_GL_BLUE_SIZE,
    SDL_GL_ALPHA_SIZE,
    SDL_GL_BUFFER_SIZE,
    SDL_GL_DOUBLEBUFFER,
    SDL_GL_DEPTH_SIZE,
    SDL_GL_STENCIL_SIZE,
    SDL_GL_ACCUM_RED_SIZE,
    SDL_GL_ACCUM_GREEN_SIZE,
    SDL_GL_ACCUM_BLUE_SIZE,
    SDL_GL_ACCUM_ALPHA_SIZE,
    SDL_GL_STEREO,
    SDL_GL_MULTISAMPLEBUFFERS,
    SDL_GL_MULTISAMPLESAMPLES,
    SDL_GL_ACCELERATED_VISUAL,
    SDL_GL_RETAINED_BACKING,
    SDL_GL_CONTEXT_MAJOR_VERSION,
    SDL_GL_CONTEXT_MINOR_VERSION,
    SDL_GL_CONTEXT_EGL,
    SDL_GL_CONTEXT_FLAGS,
    SDL_GL_CONTEXT_PROFILE_MASK,
    SDL_GL_SHARE_WITH_CURRENT_CONTEXT


type
  DisplayMode* = object
    format*: cuint
    w*,h*,refresh_rate*: cint
    driverData*: pointer

  WindowPtr* = ptr object
  RendererPtr* = ptr object
  TexturePtr* = ptr object
  CursorPtr* = ptr object

  GlContextPtr* = ptr object

  SDL_Version* = object
    major*, minor*, patch*: uint8

  RendererInfoPtr* = ptr RendererInfo
  RendererInfo* {.pure, final.} = object
    name*: cstring          #*< The name of the renderer
    flags*: uint32          #*< Supported ::SDL_RendererFlags
    num_texture_formats*: uint32 #*< The number of available texture formats
    texture_formats*: array[0..16 - 1, uint32] #*< The available texture formats
    max_texture_width*: cint #*< The maximimum texture width
    max_texture_height*: cint #*< The maximimum texture height

  TextureAccess* {.size: sizeof(cint).} = enum
    SDL_TEXTUREACCESS_STATIC, SDL_TEXTUREACCESS_STREAMING, SDL_TEXTUREACCESS_TARGET
  TextureModulate*{.size:sizeof(cint).} = enum
    SDL_TEXTUREMODULATE_NONE, SDL_TEXTUREMODULATE_COLOR, SDL_TEXTUREMODULATE_ALPHA
  RendererFlip* = cint
  SysWMType* {.size: sizeof(cint).}=enum
    SysWM_Unknown, SysWM_Windows, SysWM_X11, SysWM_DirectFB,
    SysWM_Cocoa, SysWM_UIkit
  WMinfo* = object
    version*: SDL_Version
    subsystem*: SysWMType
    padding*: array[0.. <24, byte] ## if the low-level stuff is important to you check \
      ## SDL_syswm.h and cast padding to the right type

const ## WindowFlags
    SDL_WINDOW_FULLSCREEN*:cuint = 0x00000001#         /**< fullscreen window */
    SDL_WINDOW_OPENGL*:cuint = 0x00000002#             /**< window usable with OpenGL context */
    SDL_WINDOW_SHOWN*:cuint = 0x00000004#              /**< window is visible */
    SDL_WINDOW_HIDDEN*:cuint = 0x00000008#             /**< window is not visible */
    SDL_WINDOW_BORDERLESS*:cuint = 0x00000010#         /**< no window decoration */
    SDL_WINDOW_RESIZABLE*:cuint = 0x00000020#          /**< window can be resized */
    SDL_WINDOW_MINIMIZED*:cuint = 0x00000040#          /**< window is minimized */
    SDL_WINDOW_MAXIMIZED*:cuint = 0x00000080#          /**< window is maximized */
    SDL_WINDOW_INPUT_GRABBED*:cuint = 0x00000100#      /**< window has grabbed input focus */
    SDL_WINDOW_INPUT_FOCUS*:cuint = 0x00000200#        /**< window has input focus */
    SDL_WINDOW_MOUSE_FOCUS*:cuint = 0x00000400#        /**< window has mouse focus */
    SDL_WINDOW_FULLSCREEN_DESKTOP*:cuint = ( SDL_WINDOW_FULLSCREEN or 0x00001000 )
    SDL_WINDOW_FOREIGN*:cuint = 0x00000800#             /**< window not created by SDL */
    SDL_WINDOW_ALLOW_HIGHDPI*:cuint = 0x00002000#       /**< window should be created in high-DPI mode if supported */
    SDL_FLIP_NONE*: cint = 0x00000000 # Do not flip
    SDL_FLIP_HORIZONTAL*: cint = 0x00000001 # flip horizontally
    SDL_FLIP_VERTICAL*: cint = 0x00000002 # flip vertically

converter toBool*(some: Bool32): bool = bool(some)
converter toBool*(some: SDL_Return): bool = some == SdlSuccess
converter toCint*(some: TextureAccess): cint = some.cint

## pixel format flags
const
  SDL_ALPHA_OPAQUE* = 255
  SDL_ALPHA_TRANSPARENT* = 0
# @}
#* Pixel type.
const
  SDL_PIXELTYPE_UNKNOWN* = 0
  SDL_PIXELTYPE_INDEX1* = 1
  SDL_PIXELTYPE_INDEX4* = 2
  SDL_PIXELTYPE_INDEX8* = 3
  SDL_PIXELTYPE_PACKED8* = 4
  SDL_PIXELTYPE_PACKED16* = 5
  SDL_PIXELTYPE_PACKED32* = 6
  SDL_PIXELTYPE_ARRAYU8* = 7
  SDL_PIXELTYPE_ARRAYU16* = 8
  SDL_PIXELTYPE_ARRAYU32* = 9
  SDL_PIXELTYPE_ARRAYF16* = 10
  SDL_PIXELTYPE_ARRAYF32* = 11
#* Bitmap pixel order, high bit -> low bit.
const
  SDL_BITMAPORDER_NONE* = 0
  SDL_BITMAPORDER_4321* = 1
  SDL_BITMAPORDER_1234* = 2
#* Packed component order, high bit -> low bit.
const
  SDL_PACKEDORDER_NONE* = 0
  SDL_PACKEDORDER_XRGB* = 1
  SDL_PACKEDORDER_RGBX* = 2
  SDL_PACKEDORDER_ARGB* = 3
  SDL_PACKEDORDER_RGBA* = 4
  SDL_PACKEDORDER_XBGR* = 5
  SDL_PACKEDORDER_BGRX* = 6
  SDL_PACKEDORDER_ABGR* = 7
  SDL_PACKEDORDER_BGRA* = 8
#* Array component order, low byte -> high byte.
const
  SDL_ARRAYORDER_NONE* = 0
  SDL_ARRAYORDER_RGB* = 1
  SDL_ARRAYORDER_RGBA* = 2
  SDL_ARRAYORDER_ARGB* = 3
  SDL_ARRAYORDER_BGR* = 4
  SDL_ARRAYORDER_BGRA* = 5
  SDL_ARRAYORDER_ABGR* = 6
#* Packed component layout.
const
  SDL_PACKEDLAYOUT_NONE* = 0
  SDL_PACKEDLAYOUT_332* = 1
  SDL_PACKEDLAYOUT_4444* = 2
  SDL_PACKEDLAYOUT_1555* = 3
  SDL_PACKEDLAYOUT_5551* = 4
  SDL_PACKEDLAYOUT_565* = 5
  SDL_PACKEDLAYOUT_8888* = 6
  SDL_PACKEDLAYOUT_2101010* = 7
  SDL_PACKEDLAYOUT_1010102* = 8

# /* Define a four character code as a Uint32 */
# #define SDL_FOURCC(A, B, C, D) \
#     ((SDL_static_cast(Uint32, SDL_static_cast(Uint8, (A))) << 0) | \
#      (SDL_static_cast(Uint32, SDL_static_cast(Uint8, (B))) << 8) | \
#      (SDL_static_cast(Uint32, SDL_static_cast(Uint8, (C))) << 16) | \
#      (SDL_static_cast(Uint32, SDL_static_cast(Uint8, (D))) << 24))
template SDL_FOURCC (a,b,c,d): expr =
  a or (b shl 8) or (c shl 16) or (d shl 24)

template SDL_DEFINE_PIXELFOURCC*(A, B, C, D: expr): expr =
  cint(SDL_FOURCC(A.int, B.int, C.int, D.int))

template SDL_DEFINE_PIXELFORMAT*(`type`, order, layout, bits, bytes: expr): expr =
  ((1 shl 28) or ((`type`) shl 24) or ((order) shl 20) or ((layout) shl 16) or
      ((bits) shl 8) or ((bytes) shl 0))

template SDL_PIXELFLAG*(X: expr): expr =
  (((X) shr 28) and 0x0000000F)

template SDL_PIXELTYPE*(X: expr): expr =
  (((X) shr 24) and 0x0000000F)

template SDL_PIXELORDER*(X: expr): expr =
  (((X) shr 20) and 0x0000000F)

template SDL_PIXELLAYOUT*(X: expr): expr =
  (((X) shr 16) and 0x0000000F)

template SDL_BITSPERPIXEL*(X: expr): expr =
  (((X) shr 8) and 0x000000FF)

template SDL_BYTESPERPIXEL*(X: expr): expr =
  (if SDL_ISPIXELFORMAT_FOURCC(X): (if (((X) == SDL_PIXELFORMAT_YUY2) or
      ((X) == SDL_PIXELFORMAT_UYVY) or ((X) == SDL_PIXELFORMAT_YVYU)): 2 else: 1) else: (
      ((X) shr 0) and 0x000000FF))

template SDL_ISPIXELFORMAT_INDEXED*(format: expr): expr =
  (not SDL_ISPIXELFORMAT_FOURCC(format) and
      ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) or
      (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4) or
      (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8)))

template SDL_ISPIXELFORMAT_ALPHA*(format: expr): expr =
  (not SDL_ISPIXELFORMAT_FOURCC(format) and
      ((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) or
      (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA) or
      (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR) or
      (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA)))

# The flag is set to 1 because 0x1? is not in the printable ASCII range
template SDL_ISPIXELFORMAT_FOURCC*(format: expr): expr =
  ((format) and (SDL_PIXELFLAG(format) != 1))

# Note: If you modify this list, update SDL_GetPixelFormatName()
const
  SDL_PIXELFORMAT_UNKNOWN* = 0
  SDL_PIXELFORMAT_INDEX1LSB* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1,
      SDL_BITMAPORDER_4321, 0, 1, 0)
  SDL_PIXELFORMAT_INDEX1MSB* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1,
      SDL_BITMAPORDER_1234, 0, 1, 0)
  SDL_PIXELFORMAT_INDEX4LSB* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4,
      SDL_BITMAPORDER_4321, 0, 4, 0)
  SDL_PIXELFORMAT_INDEX4MSB* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4,
      SDL_BITMAPORDER_1234, 0, 4, 0)
  SDL_PIXELFORMAT_INDEX8* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX8, 0, 0,
      8, 1)
  SDL_PIXELFORMAT_RGB332* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED8,
      SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_332, 8, 1)
  SDL_PIXELFORMAT_RGB444* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_4444, 12, 2)
  SDL_PIXELFORMAT_RGB555* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_1555, 15, 2)
  SDL_PIXELFORMAT_BGR555* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_1555, 15, 2)
  SDL_PIXELFORMAT_ARGB4444* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_4444, 16, 2)
  SDL_PIXELFORMAT_RGBA4444* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_4444, 16, 2)
  SDL_PIXELFORMAT_ABGR4444* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_4444, 16, 2)
  SDL_PIXELFORMAT_BGRA4444* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_4444, 16, 2)
  SDL_PIXELFORMAT_ARGB1555* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_1555, 16, 2)
  SDL_PIXELFORMAT_RGBA5551* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_5551, 16, 2)
  SDL_PIXELFORMAT_ABGR1555* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_1555, 16, 2)
  SDL_PIXELFORMAT_BGRA5551* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_5551, 16, 2)
  SDL_PIXELFORMAT_RGB565* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_565, 16, 2)
  SDL_PIXELFORMAT_BGR565* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16,
      SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_565, 16, 2)
  SDL_PIXELFORMAT_RGB24* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8,
      SDL_ARRAYORDER_RGB, 0, 24, 3)
  SDL_PIXELFORMAT_BGR24* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8,
      SDL_ARRAYORDER_BGR, 0, 24, 3)
  SDL_PIXELFORMAT_RGB888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_8888, 24, 4)
  SDL_PIXELFORMAT_RGBX8888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_RGBX, SDL_PACKEDLAYOUT_8888, 24, 4)
  SDL_PIXELFORMAT_BGR888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_8888, 24, 4)
  SDL_PIXELFORMAT_BGRX8888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_BGRX, SDL_PACKEDLAYOUT_8888, 24, 4)
  SDL_PIXELFORMAT_ARGB8888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_8888, 32, 4)
  SDL_PIXELFORMAT_RGBA8888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4)
  SDL_PIXELFORMAT_ABGR8888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_8888, 32, 4)
  SDL_PIXELFORMAT_BGRA8888* = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
      SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_8888, 32, 4)
  SDL_PIXELFORMAT_ARGB2101010* = SDL_DEFINE_PIXELFORMAT(
      SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_2101010,
      32, 4)
  SDL_PIXELFORMAT_YV12* = SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2') #*< Planar mode: Y + V + U  (3 planes)
  SDL_PIXELFORMAT_IYUV* = SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V') #*< Planar mode: Y + U + V  (3 planes)
  SDL_PIXELFORMAT_YUY2* = SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2') #*< Packed mode: Y0+U0+Y1+V0 (1 plane)
  SDL_PIXELFORMAT_UYVY* = SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y') #*< Packed mode: U0+Y0+V0+Y1 (1 plane)
  SDL_PIXELFORMAT_YVYU* = SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U') #*< Packed mode: Y0+V0+Y1+U0 (1 plane)


type
  Color* {.pure, final.} = tuple[
    r: uint8,
    g: uint8,
    b: uint8,
    a: uint8]

  Palette* {.pure, final.} = object
    ncolors*: cint
    colors*: ptr Color
    version*: uint32
    refcount*: cint

  PixelFormat* {.pure, final.} = object
    format*: uint32
    palette*: ptr Palette
    BitsPerPixel*: uint8
    BytesPerPixel*: uint8
    padding*: array[0..2 - 1, uint8]
    Rmask*: uint32
    Gmask*: uint32
    Bmask*: uint32
    Amask*: uint32
    Rloss*: uint8
    Gloss*: uint8
    Bloss*: uint8
    Aloss*: uint8
    Rshift*: uint8
    Gshift*: uint8
    Bshift*: uint8
    Ashift*: uint8
    refcount*: cint
    next*: ptr PixelFormat

  BlitMapPtr* = ptr object{.pure.} ##couldnt find SDL_BlitMap ?

  SurfacePtr* = ptr Surface
  Surface* {.pure, final.} = object
    flags*: uint32          #*< Read-only
    format*: ptr PixelFormat #*< Read-only
    w*, h*, pitch*: int32   #*< Read-only
    pixels*: pointer        #*< Read-write
    userdata*: pointer      #*< Read-write
    locked*: int32          #*< Read-only   ## see if this should be Bool32
    lock_data*: pointer     #*< Read-only
    clip_rect*: Rect       #*< Read-only
    map: BlitMapPtr           #*< Private
    refcount*: cint         #*< Read-mostly

  BlendMode* {.size: sizeof(cint).} = enum
      BlendMode_None = 0x00000000, #*< No blending
      BlendMode_Blend = 0x00000001, #*< dst = (src * A) + (dst * (1-A))
      BlendMode_Add  = 0x00000002, #*< dst = (src * A) + dst
      BlendMode_Mod  = 0x00000004 #*< dst = src * dst
  BlitFunction* = proc(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
    dstrect: ptr Rect): cint{.cdecl.}

  TimerCallback* = proc (interval: uint32; param: pointer): uint32{.cdecl.}
  TimerID* = cint

const ##RendererFlags
  Renderer_Software*: cint = 0x00000001
  Renderer_Accelerated*: cint = 0x00000002
  Renderer_PresentVsync*: cint = 0x00000004
  Renderer_TargetTexture*: cint = 0x00000008

const  ## These are the currently supported flags for the ::SDL_surface.
  SDL_SWSURFACE* = 0        #*< Just here for compatibility
  SDL_PREALLOC* = 0x00000001 #*< Surface uses preallocated memory
  SDL_RLEACCEL* = 0x00000002 #*< Surface is RLE encoded
  SDL_DONTFREE* = 0x00000004 #*< Surface is referenced internally

template SDL_MUSTLOCK*(some: SurfacePtr): bool = (some.flags and SDL_RLEACCEL) != 0



const
  INIT_TIMER*       = 0x00000001
  INIT_AUDIO*       = 0x00000010
  INIT_VIDEO*       = 0x00000020
  INIT_JOYSTICK*    = 0x00000200
  INIT_HAPTIC*      = 0x00001000
  INIT_NOPARACHUTE* = 0x00100000
  INIT_EVERYTHING*  = 0x0000FFFF

const SDL_WINDOWPOS_UNDEFINED_MASK* = 0x1FFF0000
template SDL_WINDOWPOS_UNDEFINED_DISPLAY*(X: cint): expr = (SDL_WINDOWPOS_UNDEFINED_MASK or X)
const SDL_WINDOWPOS_UNDEFINED* = SDL_WINDOWPOS_UNDEFINED_DISPLAY(0)
template SDL_WINDOWPOS_ISUNDEFINED*(X): expr = (((X) and 0xFFFF0000) == SDL_WINDOWPOS_UNDEFINED_MASK)

const SDL_WINDOWPOS_CENTERED_MASK* = 0x2FFF0000
template SDL_WINDOWPOS_CENTERED_DISPLAY*(X: cint): expr = (SDL_WINDOWPOS_CENTERED_MASK or X)
const SDL_WINDOWPOS_CENTERED* = SDL_WINDOWPOS_CENTERED_DISPLAY(0)
template SDL_WINDOWPOS_ISCENTERED*(X): expr = (((X) and 0xFFFF0000) == SDL_WINDOWPOS_CENTERED_MASK)


template evConv(name, name2, ptype: expr; valid: set[EventType]): stmt {.immediate.}=
  proc `name`* (event: var Event): ptype =
    assert event.kind in valid
    return cast[ptype](addr event)
  proc `name2`* (event: var Event): ptype =
    assert event.kind in valid
    return cast[ptype](addr event)

evConv(EvWindow, window, WindowEventPtr, {WindowEvent})
evConv(EvKeyboard, key, KeyboardEventPtr, {KeyDown, KeyUP})
evConv(EvTextEditing, edit, TextEditingEventPtr, {TextEditing})
evConv(EvTextInput, text, TextInputEventPtr, {TextInput})

evConv(EvMouseMotion, motion, MouseMotionEventPtr, {MouseMotion})
evConv(EvMouseButton, button, MouseButtonEventPtr, {MouseButtonDown, MouseButtonUp})
evConv(EvMouseWheel, wheel, MouseWheelEventPtr, {MouseWheel})

evConv(EvJoyAxis, jaxis, JoyAxisEventPtr, {JoyAxisMotion})
evConv(EvJoyBall, jball, JoyBallEventPtr, {JoyBallMotion})
evConv(EvJoyHat, jhat, JoyHatEventPtr, {JoyHatMotion})
evConv(EvJoyButton, jbutton, JoyButtonEventPtr, {JoyButtonDown, JoyButtonUp})
evConv(EvJoyDevice, jdevice, JoyDeviceEventPtr, {JoyDeviceAdded, JoyDeviceRemoved})

evConv(EvControllerAxis, caxis, ControllerAxisEventPtr, {ControllerAxisMotion})
evConv(EvControllerButton, cbutton, ControllerButtonEventPtr, {ControllerButtonDown, ControllerButtonUp})
evConv(EvControllerDevice, cdevice, ControllerDeviceEventPtr, {ControllerDeviceAdded, ControllerDeviceRemoved})

evConv(EvTouchFinger, tfinger, TouchFingerEventPtr, {FingerMotion, FingerDown, FingerUp})
evConv(EvMultiGesture, mgesture, MultiGestureEventPtr, {MultiGesture})
evConv(EvDollarGesture, dgesture, DollarGestureEventPtr, {DollarGesture})

evConv(EvDropFile, drop, DropEventPtr, {DropFile})
evConv(EvQuit, quit, QuitEventPtr, {QuitEvent})

evConv(EvUser, user, UserEventPtr, {UserEvent, UserEvent1, UserEvent2, UserEvent3, UserEvent4, UserEvent5})
#evConv(EvSysWM, syswm, SysWMEventPtr, {SysWMEvent})

const ## SDL_MessageBox flags. If supported will display warning icon, etc.
  SDL_MESSAGEBOX_ERROR* = 0x00000010 #*< error dialog
  SDL_MESSAGEBOX_WARNING* = 0x00000020 #*< warning dialog
  SDL_MESSAGEBOX_INFORMATION* = 0x00000040 #*< informational dialog

  ## Flags for SDL_MessageBoxButtonData.
  SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT* = 0x00000001 #*< Marks the default button when return is hit
  SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT* = 0x00000002 #*< Marks the default button when escape is hit

type
  MessageBoxColor* {.pure, final.} = object
    r*: uint8
    g*: uint8
    b*: uint8

  MessageBoxColorType* = enum
    SDL_MESSAGEBOX_COLOR_BACKGROUND, SDL_MESSAGEBOX_COLOR_TEXT,
    SDL_MESSAGEBOX_COLOR_BUTTON_BORDER,
    SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND,
    SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED, SDL_MESSAGEBOX_COLOR_MAX
  MessageBoxColorScheme* {.pure, final.} = object
    colors*: array[MessageBoxColorType, MessageBoxColor]


  MessageBoxButtonData* {.pure, final.} = object
    flags*: cint         #*< ::SDL_MessageBoxButtonFlags
    buttonid*: cint         #*< User defined button id (value returned via SDL_MessageBox)
    text*: cstring          #*< The UTF-8 button text

  MessageBoxData* {.pure, final.} = object
    flags*: cint          #*< ::SDL_MessageBoxFlags
    window*: WindowPtr #*< Parent window, can be NULL
    title*, message*: cstring         #*< UTF-8 title and message text
    numbuttons*: cint
    buttons*: ptr MessageBoxButtonData
    colorScheme*: ptr MessageBoxColorScheme #*< ::SDL_MessageBoxColorScheme, can be NULL to use system settings

  RWopsPtr* = ptr RWops
  RWops* {.pure, final.} = object
    size*: proc (context: RWopsPtr): int64 {.cdecl.}
    seek*: proc (context: RWopsPtr; offset: int64; whence: cint): int64 {.cdecl.}
    read*: proc (context: RWopsPtr; destination: pointer; size, maxnum: csize): csize {.cdecl.}
    write*: proc (context: RWopsPtr; source: pointer; size: csize;
                  num: csize): csize {.cdecl.}
    close*: proc (context: RWopsPtr): cint {.cdecl.}
    kind*: cint
    mem*: Mem
  Mem*{.final.} = object
    base*: ptr byte
    here*: ptr byte
    stop*: ptr byte

# SDL_system.h
type VoidCallback* = proc(arg:pointer):void{.cdecl.}
const SDL_ANDROID_EXTERNAL_STORAGE_READ*  = cint(0x01)
const SDL_ANDROID_EXTERNAL_STORAGE_WRITE* = cint(0x02)

when defined(SDL_Static):
  {.push header: "<SDL2/SDL.h>".}
else:
  {.push callConv: cdecl, dynlib: LibName.}


## functions whose names have been shortened by elision of a type name
proc getWMInfo*(window: WindowPtr; info: var WMInfo): Bool32 {.
  importc: "SDL_GetWindowWMInfo".}

proc setLogicalSize*(renderer: RendererPtr; w, h: cint): cint {.
  importc: "SDL_RenderSetLogicalSize".}

proc getLogicalSize*(renderer: RendererPtr; w, h: var cint) {.
  importc: "SDL_RenderGetLogicalSize".}


proc setDrawColor*(renderer: RendererPtr; r, g, b: uint8, a = 255'u8): SDL_Return {.
  importc: "SDL_SetRenderDrawColor", discardable.}
proc getDrawColor*(renderer: RendererPtr; r, g, b, a: var uint8): SDL_Return {.
  importc: "SDL_GetRenderDrawColor", discardable.}
proc setDrawBlendMode*(renderer: RendererPtr; blendMode: BlendMode): SDL_Return {.
  importc: "SDL_SetRenderDrawBlendMode", discardable.}
proc getDrawBlendMode*(renderer: RendererPtr;
  blendMode: var BlendMode): SDL_Return {.
  importc: "SDL_GetRenderDrawBlendMode", discardable.}


proc destroy*(texture: TexturePtr) {.importc: "SDL_DestroyTexture".}
proc destroy*(renderer: RendererPtr) {.importc: "SDL_DestroyRenderer".}
#proc destroy* (texture: TexturePtr) {.inline.} = texture.destroyTexture
#proc destroy* (renderer: RendererPtr) {.inline.} = renderer.destroyRenderer

proc getDisplayIndex*(window: WindowPtr): cint {.importc: "SDL_GetWindowDisplayIndex".}
#*
proc setDisplayMode*(window: WindowPtr;
  mode: ptr DisplayMode): SDL_Return {.importc: "SDL_SetWindowDisplayMode".}
#*
proc getDisplayMode*(window: WindowPtr; mode: var DisplayMode): cint  {.
  importc: "SDL_GetWindowDisplayMode".}
#*
proc getPixelFormat*(window: WindowPtr): uint32 {.importc: "SDL_GetWindowPixelFormat".}

#*
#   \brief Get the numeric ID of a window, for logging purposes.
#
proc getID*(window: WindowPtr): uint32 {.importc: "SDL_GetWindowID".}

#*
#   \brief Get the window flags.
#
proc getFlags*(window: WindowPtr): uint32 {.importc: "SDL_GetWindowFlags".}
#*
#   \brief Set the title of a window, in UTF-8 format.
#
#   \sa SDL_GetWindowTitle()
#
proc setTitle*(window: WindowPtr; title: cstring) {.importc: "SDL_SetWindowTitle".}
#*
#   \brief Get the title of a window, in UTF-8 format.
#
#   \sa SDL_SetWindowTitle()
#
proc getTitle*(window: WindowPtr): cstring {.importc: "SDL_GetWindowTitle".}
#*
#   \brief Set the icon for a window.
#
#   \param icon The icon for the window.
#
proc setIcon*(window: WindowPtr; icon: SurfacePtr) {.importc: "SDL_SetWindowIcon".}
#*
proc setData*(window: WindowPtr; name: cstring;
  userdata: pointer): pointer {.importc: "SDL_SetWindowData".}
#*
proc getData*(window: WindowPtr; name: cstring): pointer {.importc: "SDL_GetWindowData".}
#*
proc setPosition*(window: WindowPtr; x, y: cint) {.importc: "SDL_SetWindowPosition".}
proc getPosition*(window: WindowPtr; x, y: var cint)  {.importc: "SDL_GetWindowPosition".}
#*
proc setSize*(window: WindowPtr; w, h: cint)  {.importc: "SDL_SetWindowSize".}
proc getSize*(window: WindowPtr; w, h: var cint) {.importc: "SDL_GetWindowSize".}

proc setBordered*(window: WindowPtr; bordered: Bool32) {.importc: "SDL_SetWindowBordered".}


proc setFullscreen*(window: WindowPtr; fullscreen: uint32): SDL_Return {.importc: "SDL_SetWindowFullscreen".}
proc getSurface*(window: WindowPtr): SurfacePtr {.importc: "SDL_GetWindowSurface".}

proc updateSurface*(window: WindowPtr): SDL_Return  {.importc: "SDL_UpdateWindowSurface".}
proc updateSurfaceRects*(window: WindowPtr; rects: ptr Rect;
  numrects: cint): SDL_Return  {.importc: "SDL_UpdateWindowSurfaceRects".}
#*
proc setGrab*(window: WindowPtr; grabbed: Bool32) {.importc: "SDL_SetWindowGrab".}
proc getGrab*(window: WindowPtr): Bool32 {.importc: "SDL_GetWindowGrab".}
proc setBrightness*(window: WindowPtr; brightness: cfloat): SDL_Return {.importc: "SDL_SetWindowBrightness".}

proc getBrightness*(window: WindowPtr): cfloat {.importc: "SDL_GetWindowBrightness".}

proc setGammaRamp*(window: WindowPtr;
  red, green, blue: ptr uint16): SDL_Return {.importc: "SDL_SetWindowGammaRamp".}
#*
#   \brief Get the gamma ramp for a window.
#
#   \param red   A pointer to a 256 element array of 16-bit quantities to hold
#                the translation table for the red channel, or NULL.
#   \param green A pointer to a 256 element array of 16-bit quantities to hold
#                the translation table for the green channel, or NULL.
#   \param blue  A pointer to a 256 element array of 16-bit quantities to hold
#                the translation table for the blue channel, or NULL.
#
#   \return 0 on success, or -1 if gamma ramps are unsupported.
#
#   \sa SDL_SetWindowGammaRamp()
#
proc getGammaRamp*(window: WindowPtr; red: ptr uint16;
                  green: ptr uint16; blue: ptr uint16): cint {.importc: "SDL_GetWindowGammaRamp".}


proc init*(flags: cint): SDL_Return {.discardable,
  importc: "SDL_Init".}
#
#   This function initializes specific SDL subsystems
#
proc initSubSystem*(flags: uint32):cint {.
  importc: "SDL_InitSubSystem".}

#
#   This function cleans up specific SDL subsystems
#
proc quitSubSystem*(flags: uint32) {.
  importc: "SDL_QuitSubSystem".}

#
#   This function returns a mask of the specified subsystems which have
#   previously been initialized.
#
#   If \c flags is 0, it returns a mask of all initialized subsystems.
#
proc wasInit*(flags: uint32): uint32 {.
  importc: "SDL_WasInit".}

proc quit* {.
  importc: "SDL_Quit".}

proc getPlatform*(): cstring {.
  importc: "SDL_GetPlatform".}

proc getVersion*(ver: var SDL_Version) {.
  importc: "SDL_GetVersion".}
proc getRevision*(): cstring {.
  importc: "SDL_GetRevision".}
proc getRevisionNumber*(): cint {.
  importc: "SDL_GetRevisionNumber".}


proc getNumRenderDrivers*(): cint {.
  importc: "SDL_GetNumRenderDriver".}
proc getRenderDriverInfo*(index: cint; info: var RendererInfo): SDL_Return {.
  importc: "SDL_GetRenderDriverInfo".}
proc createWindowAndRenderer*(width, height: cint; window_flags: uint32;
  window: var WindowPtr; renderer: var RendererPtr): SDL_Return {.
  importc: "SDL_CreateWindowAndRenderer".}

proc createRenderer*(window: WindowPtr; index: cint; flags: cint): RendererPtr {.
  importc: "SDL_CreateRenderer".}
proc createSoftwareRenderer*(surface: SurfacePtr): RendererPtr {.
  importc: "SDL_CreateSoftwareRenderer".}
proc getRenderer*(window: WindowPtr): RendererPtr {.
  importc: "SDL_GetRenderer".}
proc getRendererInfo*(renderer: RendererPtr; info: RendererInfoPtr): cint {.
  importc: "SDL_GetRendererInfo".}

proc createTexture*(renderer: RendererPtr; format: uint32;
  access, w, h: cint): TexturePtr {.
  importc: "SDL_CreateTexture".}

proc createTextureFromSurface*(renderer: RendererPtr; surface: SurfacePtr): TexturePtr {.
  importc: "SDL_CreateTextureFromSurface".}
proc createTexture*(renderer: RendererPtr; surface: SurfacePtr): TexturePtr {.
  inline.} = renderer.createTextureFromSurface(surface)

proc queryTexture*(texture: TexturePtr; format: ptr uint32;
  access, w, h: ptr cint): SDL_Return {.discardable,
  importc: "SDL_QueryTexture".}

proc setTextureColorMod*(texture: TexturePtr; r, g, b: uint8): SDL_Return {.
  importc: "SDL_SetTextureColorMod".}

proc getTextureColorMod*(texture: TexturePtr; r, g, b: var uint8): SDL_Return {.
  importc: "SDL_GetTextureColorMod".}

proc setTextureAlphaMod*(texture: TexturePtr; alpha: uint8): SDL_Return {.
  importc: "SDL_SetTextureAlphaMod", discardable.}

proc getTextureAlphaMod*(texture: TexturePtr; alpha: var uint8): SDL_Return {.
  importc: "SDL_GetTextureAlphaMod", discardable.}

proc setTextureBlendMode*(texture: TexturePtr; blendMode: BlendMode): SDL_Return {.
  importc: "SDL_SetTextureBlendMode", discardable.}

proc getTextureBlendMode*(texture: TexturePtr;
  blendMode: var BlendMode): SDL_Return {.importc: "SDL_GetTextureBlendMode", discardable.}

proc updateTexture*(texture: TexturePtr; rect: ptr Rect; pixels: pointer;
  pitch: cint): SDL_Return {.importc: "SDL_UpdateTexture", discardable.}

proc lockTexture*(texture: TexturePtr; rect: ptr Rect; pixels: ptr pointer;
  pitch: ptr cint): SDL_Return {.importc: "SDL_LockTexture", discardable.}

proc unlockTexture*(texture: TexturePtr) {.importc: "SDL_UnlockTexture".}

proc renderTargetSupported*(renderer: RendererPtr): Bool32 {.
  importc: "SDL_RenderTargetSupported".}

proc setRenderTarget*(renderer: RendererPtr; texture: TexturePtr): SDL_Return {.discardable,
  importc: "SDL_SetRenderTarget".}
#*
#
proc getRenderTarget*(renderer: RendererPtr): TexturePtr {.
  importc: "SDL_GetRenderTarget".}




#*
#   \brief Set the drawing area for rendering on the current target.
#
#   \param rect The rectangle representing the drawing area, or NULL to set the viewport to the entire target.
#
#   The x,y of the viewport rect represents the origin for rendering.
#
#   \note When the window is resized, the current viewport is automatically
#         centered within the new window size.
#
#   \sa SDL_RenderGetViewport()
#   \sa SDL_RenderSetLogicalSize()
#
proc setViewport*(renderer: RendererPtr; rect: ptr Rect): SDL_Return {.
  importc: "SDL_RenderSetViewport", discardable.}
proc getViewport*(renderer: RendererPtr; rect: var Rect) {.
  importc: "SDL_RenderGetViewport".}

proc setScale*(renderer: RendererPtr; scaleX, scaleY: cfloat): SDL_Return {.
  importc: "SDL_RenderSetScale", discardable.}
proc getScale*(renderer: RendererPtr; scaleX, scaleY: var cfloat) {.
  importc: "SDL_RenderGetScale".}
proc drawPoint*(renderer: RendererPtr; x, y: cint): SDL_Return {.
  importc: "SDL_RenderDrawPoint", discardable.}
#*
proc drawPoints*(renderer: RendererPtr; points: ptr Point;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawPoints", discardable.}

proc drawLine*(renderer: RendererPtr;
  x1, y1, x2, y2: cint): SDL_Return {.
  importc: "SDL_RenderDrawLine", discardable.}
#*
proc drawLines*(renderer: RendererPtr; points: ptr Point;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawLines", discardable.}

proc drawRect*(renderer: RendererPtr; rect: var Rect): SDL_Return{.
  importc: "SDL_RenderDrawRect", discardable.}

proc drawRects*(renderer: RendererPtr; rects: ptr Rect;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawRects".}
proc fillRect*(renderer: RendererPtr; rect: var Rect): SDL_Return {.
  importc: "SDL_RenderFillRect", discardable.}
proc fillRect*(renderer: RendererPtr; rect: ptr Rect = nil): SDL_Return {.
  importc: "SDL_RenderFillRect", discardable.}
#*
proc fillRects*(renderer: RendererPtr; rects: ptr Rect;
  count: cint): SDL_Return {.importc: "SDL_RenderFillRects", discardable.}

proc copy*(renderer: RendererPtr; texture: TexturePtr;
                     srcrect, dstrect: ptr Rect): SDL_Return {.
  importc: "SDL_RenderCopy", discardable.}

proc copyEx*(renderer: RendererPtr; texture: TexturePtr;
             srcrect, dstrect: var Rect; angle: cdouble; center: ptr Point;
             flip: RendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyEx", discardable.}
proc copyEx*(renderer: RendererPtr; texture: TexturePtr;
             srcRect, dstRect: ptr Rect; angle: cdouble; center: ptr Point;
             flip: RendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyEx", discardable.}

proc clear*(renderer: RendererPtr): cint {.
  importc: "SDL_RenderClear", discardable.}

proc readPixels*(renderer: RendererPtr; rect: var Rect; format: cint;
  pixels: pointer; pitch: cint): cint {.importc: "SDL_RenderReadPixels".}
proc present*(renderer: RendererPtr) {.importc: "SDL_RenderPresent".}



proc glBindTexture*(texture: TexturePtr; texw, texh: var cfloat): cint {.
  importc: "SDL_GL_BindTexture".}
proc glUnbindTexture*(texture: TexturePtr) {.
  importc: "SDL_GL_UnbindTexture".}

proc createRGBSurface*(flags: cint; width, height, depth: cint;
  Rmask, Gmask, BMask, Amask: uint32): SurfacePtr {.
  importc: "SDL_CreateRGBSurface".}
proc createRGBSurfaceFrom*(pixels: pointer; width, height, depth, pitch: cint;
  Rmask, Gmask, Bmask, Amask: uint32): SurfacePtr {.
  importc: "SDL_CreateRGBSurfaceFrom".}

proc freeSurface*(surface: SurfacePtr) {.
  importc: "SDL_FreeSurface".}

proc setSurfacePalette*(surface: SurfacePtr; palette: ptr Palette): cint {.
  importc:"SDL_SetSurfacePalette".}
#*
#   \brief Sets up a surface for directly accessing the pixels.
#
#   Between calls to SDL_LockSurface() / SDL_UnlockSurface(), you can write
#   to and read from \c surface->pixels, using the pixel format stored in
#   \c surface->format.  Once you are done accessing the surface, you should
#   use SDL_UnlockSurface() to release it.
#
#   Not all surfaces require locking.  If SDL_MUSTLOCK(surface) evaluates
#   to 0, then you can read and write to the surface at any time, and the
#   pixel format of the surface will not change.
#
#   No operating system or library calls should be made between lock/unlock
#   pairs, as critical system locks may be held during this time.
#
#   SDL_LockSurface() returns 0, or -1 if the surface couldn't be locked.
#
#   \sa SDL_UnlockSurface()
#
proc lockSurface*(surface: SurfacePtr): cint {.importc: "SDL_LockSurface".}
#* \sa SDL_LockSurface()
proc unlockSurface*(surface: SurfacePtr) {.importc: "SDL_UnlockSurface".}
#*
#   Load a surface from a seekable SDL data stream (memory or file).
#
#   If \c freesrc is non-zero, the stream will be closed after being read.
#
#   The new surface should be freed with SDL_FreeSurface().
#
#   \return the new surface, or NULL if there was an error.
#
proc loadBMP_RW*(src: RWopsPtr; freesrc: cint): SurfacePtr {.
  importc: "SDL_LoadBMP_RW".}



proc rwFromFile*(file: cstring; mode: cstring): RWopsPtr {.importc: "SDL_RWFromFile".}
proc rwFromFP*(fp: File; autoclose: Bool32): RWopsPtr {.importc: "SDL_RWFromFP".}
proc rwFromMem*(mem: pointer; size: cint): RWopsPtr {.importc: "SDL_RWFromMem".}
proc rwFromConstMem*(mem: pointer; size: cint): RWopsPtr {.importc: "SDL_RWFromConstMem".}

proc allocRW* : RWopsPtr {.importc: "SDL_AllocRW".}
proc freeRW* (area: RWopsPtr) {.importc: "SDL_FreeRW".}


#*
#   Load a surface from a file.
#
#   Convenience macro.
#
#*
proc saveBMP_RW*(surface: SurfacePtr; dst: RWopsPtr;
                 freedst: cint): SDL_Return {.importc: "SDL_SaveBMP_RW".}

proc setSurfaceRLE*(surface: SurfacePtr; flag: cint): cint {.
  importc:"SDL_SetSurfaceRLE".}
proc setColorKey*(surface: SurfacePtr; flag: cint; key: uint32): cint {.
  importc: "SDL_SetColorKey".}

proc getColorKey*(surface: SurfacePtr; key: var uint32): cint {.
  importc: "SDL_GetColorKey".}
proc setSurfaceColorMod*(surface: SurfacePtr; r, g, b: uint8): cint {.
  importc: "SDL_SetSurfaceColorMod".}

proc getSurfaceColorMod*(surface: SurfacePtr; r, g, b: var uint8): cint {.
  importc: "SDL_GetSurfaceColorMod".}

proc setSurfaceAlphaMod*(surface: SurfacePtr; alpha: uint8): cint {.
  importc: "SDL_SetSurfaceAlphaMod".}
proc getSurfaceAlphaMod*(surface: SurfacePtr; alpha: var uint8): cint {.
  importc: "SDL_GetSurfaceAlphaMod".}

proc setSurfaceBlendMode*(surface: SurfacePtr; blendMode: BlendMode): cint {.
  importc: "SDL_SetSurfaceBlendMode".}
proc getSurfaceBlendMode*(surface: SurfacePtr; blendMode: ptr BlendMode): cint {.
  importc: "SDL_GetSurfaceBlendMode".}

proc setClipRect*(surface: SurfacePtr; rect: ptr Rect): Bool32 {.
  importc: "SDL_SetClipRect".}
proc getClipRect*(surface: SurfacePtr; rect: ptr Rect) {.
  importc: "SDL_GetClipRect".}

proc convertSurface*(src: SurfacePtr; fmt: ptr PixelFormat;
  flags: cint): SurfacePtr {.importc: "SDL_ConvertSurface".}
proc convertSurfaceFormat*(src: SurfacePtr; pixel_format,
  flags: uint32): SurfacePtr {.importc: "SDL_ConvertSurfaceFormat".}

proc convertPixels*(width, height: cint; src_format: uint32; src: pointer;
  src_pitch: cint; dst_format: uint32; dst: pointer; dst_pitch: cint): cint {.
  importc: "SDL_ConvertPixels".}
#*
#   Performs a fast fill of the given rectangle with \c color.
#
#   If \c rect is NULL, the whole surface will be filled with \c color.
#
#   The color should be a pixel of the format used by the surface, and
#   can be generated by the SDL_MapRGB() function.
#
#   \return 0 on success, or -1 on error.
#
proc fillRect*(dst: SurfacePtr; rect: ptr Rect; color: uint32): SDL_Return {.
  importc: "SDL_FillRect", discardable.}
proc fillRects*(dst: SurfacePtr; rects: ptr Rect; count: cint;
                    color: uint32): cint {.importc: "SDL_FillRects".}

proc upperBlit*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_UpperBlit".}

proc lowerBlit*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_LowerBlit".}

proc softStretch*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_SoftStretch".}


proc upperBlitScaled*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_UpperBlitScaled".}
proc lowerBlitScaled*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_LowerBlitScaled".}



proc readU8*(src: RWopsPtr): uint8 {.importc: "SDL_ReadU8".}
proc readLE16*(src: RWopsPtr): uint16 {.importc: "SDL_ReadLE16".}
proc readBE16*(src: RWopsPtr): uint16 {.importc: "SDL_ReadBE16".}
proc readLE32*(src: RWopsPtr): uint32 {.importc: "SDL_ReadLE32".}
proc readBE32*(src: RWopsPtr): uint32 {.importc: "SDL_ReadBE32".}
proc readLE64*(src: RWopsPtr): uint64 {.importc: "SDL_ReadLE64".}
proc readBE64*(src: RWopsPtr): uint64 {.importc: "SDL_ReadBE64".}
proc writeU8*(dst: RWopsPtr; value: uint8): csize {.importc: "SDL_WriteU8".}
proc writeLE16*(dst: RWopsPtr; value: uint16): csize {.importc: "SDL_WriteLE16".}
proc writeBE16*(dst: RWopsPtr; value: uint16): csize {.importc: "SDL_WriteBE16".}
proc writeLE32*(dst: RWopsPtr; value: uint32): csize {.importc: "SDL_WriteLE32".}
proc writeBE32*(dst: RWopsPtr; value: uint32): csize {.importc: "SDL_WriteBE32".}
proc writeLE64*(dst: RWopsPtr; value: uint64): csize {.importc: "SDL_WriteLE64".}
proc writeBE64*(dst: RWopsPtr; value: uint64): csize {.importc: "SDL_WriteBE64".}

proc showMessageBox*(messageboxdata: ptr MessageBoxData;
  buttonid: var cint): cint {.importc: "SDL_ShowMessageBox".}

proc showSimpleMessageBox*(flags: uint32; title, message: cstring;
  window: WindowPtr): cint {.importc: "SDL_ShowSimpleMessageBox".}
  #   \return 0 on success, -1 on error





proc getNumVideoDrivers*(): cint {.importc: "SDL_GetNumVideoDrivers".}
proc getVideoDriver*(index: cint): cstring {.importc: "SDL_GetVideoDriver".}
proc videoInit*(driver_name: cstring): SDL_Return {.importc: "SDL_VideoInit".}
proc videoQuit*() {.importc: "SDL_VideoQuit".}
proc getCurrentVideoDriver*(): cstring {.importc: "SDL_GetCurrentVideoDriver".}
proc getNumVideoDisplays*(): cint {.importc: "SDL_GetNumVideoDisplays".}

proc getDisplayBounds*(displayIndex: cint; rect: var Rect): SDL_Return {.
  importc: "SDL_GetDisplayBounds".}
proc getNumDisplayModes*(displayIndex: cint): cint {.importc: "SDL_GetNumDisplayModes".}
#*
proc getDisplayMode*(displayIndex: cint; modeIndex: cint;
  mode: var DisplayMode): SDL_Return {.importc: "SDL_GetDisplayMode".}

proc getDesktopDisplayMode*(displayIndex: cint;
  mode: var DisplayMode): SDL_Return {.importc: "SDL_GetDesktopDisplayMode".}
proc getCurrentDisplayMode*(displayIndex: cint;
  mode: var DisplayMode): SDL_Return {.importc: "SDL_GetCurrentDisplayMode".}

proc getClosestDisplayMode*(displayIndex: cint; mode: ptr DisplayMode;
                                closest: ptr DisplayMode): ptr DisplayMode {.importc: "SDL_GetClosestDisplayMode".}
#*
#*
proc createWindow*(title: cstring; x, y, w, h: cint;
                   flags: uint32): WindowPtr  {.importc: "SDL_CreateWindow".}
#*
proc createWindowFrom*(data: pointer): WindowPtr {.importc: "SDL_CreateWindowFrom".}

#*
#   \brief Get a window from a stored ID, or NULL if it doesn't exist.
#
proc getWindowFromID*(id: uint32): WindowPtr {.importc: "SDL_GetWindowFromID".}




#
proc showWindow*(window: WindowPtr) {.importc: "SDL_ShowWindow".}
proc hideWindow*(window: WindowPtr) {.importc: "SDL_HideWindow".}
#*
proc raiseWindow*(window: WindowPtr) {.importc: "SDL_RaiseWindow".}
proc maximizeWindow*(window: WindowPtr) {.importc: "SDL_MaximizeWindow".}
proc minimizeWindow*(window: WindowPtr) {.importc: "SDL_MinimizeWindow".}
#*
#
proc restoreWindow*(window: WindowPtr) {.importc: "SDL_RestoreWindow".}

proc destroyWindow*(window: WindowPtr) {.importc: "SDL_DestroyWindow".}

proc isScreenSaverEnabled*(): Bool32 {.importc: "SDL_IsScreenSaverEnabled".}
proc enableScreenSaver*() {.importc: "SDL_EnableScreenSaver".}
proc disableScreenSaver*() {.importc: "SDL_DisableScreenSaver".}


proc getTicks*(): uint32 {.importc: "SDL_GetTicks".}
proc getPerformanceCounter*(): uint64 {.importc: "SDL_GetPerformanceCounter".}
proc getPerformanceFrequency*(): uint64 {.importc: "SDL_GetPerformanceFrequency".}
proc delay*(ms: uint32) {.importc: "SDL_Delay".}
#*
#  \brief Add a new timer to the pool of timers already running.
#
#  \return A timer ID, or NULL when an error occurs.
#
proc addTimer*(interval: uint32; callback: TimerCallback;
      param: pointer): TimerID {.importc: "SDL_AddTimer".}
#*
#  \brief Remove a timer knowing its ID.
#
#  \return A boolean value indicating success or failure.
#
#  \warning It is not safe to remove a timer multiple times.
#
proc removeTimer*(id: TimerID): Bool32 {.importc: "SDL_RemoveTimer".}


#*
#   \name OpenGL support functions
#
#@{
#*
#   \brief Dynamically load an OpenGL library.
#
#   \param path The platform dependent OpenGL library name, or NULL to open the
#               default OpenGL library.
#
#   \return 0 on success, or -1 if the library couldn't be loaded.
#
#   This should be done after initializing the video driver, but before
#   creating any OpenGL windows.  If no OpenGL library is loaded, the default
#   library will be loaded upon creation of the first OpenGL window.
#
#   \note If you do this, you need to retrieve all of the GL functions used in
#         your program from the dynamic library using SDL_GL_GetProcAddress().
#
#   \sa SDL_GL_GetProcAddress()
#   \sa SDL_GL_UnloadLibrary()
#
#extern DECLSPEC int SDLCALL SDL_GL_LoadLibrary(const char *path);
proc glLoadLibrary* (path: cstring): SDL_Return {.discardable,
  importc: "SDL_GL_LoadLibrary".}
#extern DECLSPEC void *SDLCALL SDL_GL_GetProcAddress(const char *proc);
proc glGetProcAddress* (procedure: cstring): pointer {.
  importc: "SDL_GL_GetProcAddress".}
#extern DECLSPEC void SDLCALL SDL_GL_UnloadLibrary(void);
proc glUnloadLibrary* {.
  importc: "SDL_GL_UnloadLibrary".}
#extern DECLSPEC SDL_bool SDLCALL SDL_GL_ExtensionSupported(const char
#                                                          *extension);
proc glExtensionSupported* (extension: cstring): bool {.
  importc: "SDL_GL_ExtensionSupported".}

#extern DECLSPEC int SDLCALL SDL_GL_SetAttribute(SDL_GLattr attr, int value);
proc glSetAttribute* (attr: GLattr; value: cint): cint {.
  importc: "SDL_GL_SetAttribute".}
#extern DECLSPEC int SDLCALL SDL_GL_GetAttribute(SDL_GLattr attr, int *value);
proc glGetAttribute* (attr: GLattr; value: var cint): cint {.
  importc: "SDL_GL_GetAttribute".}


proc glCreateContext*(window: WindowPtr): GlContextPtr {.
  importc: "SDL_GL_CreateContext".}
  ## Create an OpenGL context for use with an OpenGL window, and make it current.
proc glMakeCurrent* (window: WindowPtr; context: GlContextPtr): cint {.
  importc: "SDL_GL_MakeCurrent".}

proc glGetCurrentWindow* : WindowPtr {.
  importc: "SDL_GL_GetCurrentWindow".}
proc glGetCurrentContext*: GlContextPtr {.
  importc: "SDL_GL_GetCurrentContext".}

proc glGetDrawableSize* (window: WindowPtr; w,h: var cint) {.
  importc: "SDL_GL_GetDrawableSize".}

proc glSetSwapInterval* (interval: cint): cint {.
  importc: "SDL_GL_SetSwapInterval".}
proc glGetSwapInterval* : cint {.
  importc: "SDL_GL_GetSwapInterval".}

proc glSwapWindow*(window: WindowPtr) {.
  importc: "SDL_GL_SwapWindow".}
  ## Swap the OpenGL buffers for a window, if double-buffering is supported.

proc glDeleteContext* (context: GlContextPtr) {.
  importc: "SDL_GL_DeleteContext".}


##SDL_keyboard.h:
proc getKeyboardFocus*: WindowPtr {.importc: "SDL_GetKeyboardFocus".}
  #Get the window which currently has keyboard focus.
proc getKeyboardState*(numkeys: ptr int = nil): ptr array[0 .. SDL_NUM_SCANCODES.int, uint8] {.importc: "SDL_GetKeyboardState".}
  #Get the snapshot of the current state of the keyboard
proc getModState*: Keymod {.importc: "SDL_GetModState".}
  #Get the current key modifier state for the keyboard
proc setModState*(state: Keymod) {.importc: "SDL_SetModState".}
  #Set the current key modifier state for the keyboard
proc getKeyFromScancode*(scancode: ScanCode): cint {.importc: "SDL_GetKeyFromScancode".}
  #Get the key code corresponding to the given scancode according to the current keyboard layout
proc getScancodeFromKey*(key: cint): ScanCode {.importc: "SDL_GetScancodeFromKey".}
  #Get the scancode corresponding to the given key code according to the current keyboard layout
proc getScancodeName*(scancode: ScanCode): cstring {.importc: "SDL_GetScancodeName".}
  #Get a human-readable name for a scancode
proc getScancodeFromName*(name: cstring): ScanCode {.importc: "SDL_GetScancodeFromName".}
  #Get a scancode from a human-readable name
proc getKeyName*(key: cint): cstring {.
  importc: "SDL_GetKeyName".}
  #Get a human-readable name for a key
proc getKeyFromName*(name: cstring): cint {.
  importc: "SDL_GetKeyFromName".}
  #Get a key code from a human-readable name
proc startTextInput* {.
  importc: "SDL_StartTextInput".}
  #Start accepting Unicode text input events
proc isTextInputActive*: bool {.
  importc: "SDL_IsTextInputActive".}
proc stopTextInput* {.
  importc: "SDL_StopTextInput".}
proc setTextInputRect*(rect: ptr Rect) {.
  importc: "SDL_SetTextInputRect".}
proc hasScreenKeyboardSupport*: bool {.importc: "SDL_HasScreenKeyboardSupport".}
proc isScreenKeyboardShown*(window: WindowPtr): bool {.importc: "SDL_IsScreenKeyboardShown".}



proc getMouseFocus*(): WindowPtr {.importc: "SDL_GetMouseFocus".}
#*
#   \brief Retrieve the current state of the mouse.
#
#   The current button state is returned as a button bitmask, which can
#   be tested using the SDL_BUTTON(X) macros, and x and y are set to the
#   mouse cursor position relative to the focus window for the currently
#   selected mouse.  You can pass NULL for either x or y.
#
proc getMouseState*(x, y: var cint): uint8 {.importc: "SDL_GetMouseState", discardable.}
proc getMouseState*(x, y: ptr cint): uint8 {.importc: "SDL_GetMouseState", discardable.}
#*
proc getRelativeMouseState*(x, y: var cint): uint8 {.
  importc: "SDL_GetRelativeMouseState".}
#*
proc warpMouseInWindow*(window: WindowPtr; x, y: cint)  {.
  importc: "SDL_WarpMouseInWindow".}
#*
proc setRelativeMouseMode*(enabled: Bool32): SDL_Return  {.
  importc: "SDL_SetRelativeMouseMode".}
#*
proc getRelativeMouseMode*(): Bool32 {.importc: "SDL_GetRelativeMouseMode".}
#*
proc createCursor*(data, mask: ptr uint8;
  w, h, hot_x, hot_y: cint): CursorPtr {.importc: "SDL_CreateCursor".}
#*
proc createColorCursor*(surface: SurfacePtr; hot_x, hot_y: cint): CursorPtr {.
  importc: "SDL_CreateColorCursor".}
proc setCursor*(cursor: CursorPtr) {.importc: "SDL_SetCursor".}
proc getCursor*(): CursorPtr {.importc: "SDL_GetCursor".}
proc freeCursor* (cursor: CursorPtr) {.importc: "SDL_FreeCursor".}
proc showCursor* (toggle: bool): Bool32 {.importc: "SDL_ShowCursor", discardable.}


# Function prototypes
#*
#   Pumps the event loop, gathering events from the input devices.
#
#   This function updates the event queue and internal input device state.
#
#   This should only be run in the thread that sets the video mode.
#
proc pumpEvents*() {.importc: "SDL_PumpEvents".}

#*
#   Checks the event queue for messages and optionally returns them.
#
#   If \c action is ::SDL_ADDEVENT, up to \c numevents events will be added to
#   the back of the event queue.
#
#   If \c action is ::SDL_PEEKEVENT, up to \c numevents events at the front
#   of the event queue, within the specified minimum and maximum type,
#   will be returned and will not be removed from the queue.
#
#   If \c action is ::SDL_GETEVENT, up to \c numevents events at the front
#   of the event queue, within the specified minimum and maximum type,
#   will be returned and will be removed from the queue.
#
#   \return The number of events actually stored, or -1 if there was an error.
#
#   This function is thread-safe.
#
proc peepEvents*(events: ptr Event; numevents: cint; action: Eventaction;
  minType: uint32; maxType: uint32): cint {.importc: "SDL_PeepEvents".}
#@}
#*
#   Checks to see if certain event types are in the event queue.
#
proc hasEvent*(kind: uint32): Bool32 {.importc: "SDL_HasEvent".}
proc hasEvents*(minType: uint32; maxType: uint32): Bool32 {.importc: "SDL_HasEvents".}
proc flushEvent*(kind: uint32) {.importc: "SDL_FlushEvent".}
proc flushEvents*(minType: uint32; maxType: uint32) {.importc: "SDL_FlushEvents".}

proc pollEvent*(event: var Event): Bool32 {.importc: "SDL_PollEvent".}
proc waitEvent*(event: var Event): Bool32 {.importc: "SDL_WaitEvent".}
proc waitEventTimeout*(event: var Event; timeout: cint): Bool32 {.importc: "SDL_WaitEventTimeout".}
#*
#   \brief Add an event to the event queue.
#
#   \return 1 on success, 0 if the event was filtered, or -1 if the event queue
#           was full or there was some other error.
#
proc pushEvent*(event: ptr Event): cint {.importc: "SDL_PushEvent".}

#*
proc setEventFilter*(filter: EventFilter; userdata: pointer) {.importc: "SDL_SetEventFilter".}
#*
#   Return the current event filter - can be used to "chain" filters.
#   If there is no event filter set, this function returns SDL_FALSE.
#
proc getEventFilter*(filter: var EventFilter; userdata: var pointer): Bool32 {.importc: "SDL_GetEventFilter".}
#*
#   Add a function which is called when an event is added to the queue.
#
proc addEventWatch*(filter: EventFilter; userdata: pointer) {.importc: "SDL_AddEventWatch".}
#*
#   Remove an event watch function added with SDL_AddEventWatch()
#
proc delEventWatch*(filter: EventFilter; userdata: pointer) {.importc: "SDL_DelEventWatch".}
#*
#   Run the filter function on the current event queue, removing any
#   events for which the filter returns 0.
#
proc filterEvents*(filter: EventFilter; userdata: pointer) {.importc: "SDL_FilterEvents".}
#@{
#
#/**
#   This function allows you to set the state of processing certain events.
#    - If \c state is set to ::SDL_IGNORE, that event will be automatically
#      dropped from the event queue and will not event be filtered.
#    - If \c state is set to ::SDL_ENABLE, that event will be processed
#      normally.
#    - If \c state is set to ::SDL_QUERY, SDL_EventState() will return the
#      current processing state of the specified event.
#
proc eventState*(kind: EventType; state: cint): uint8 {.importc: "SDL_EventState".}
#@}
#
#/**
#   This function allocates a set of user-defined events, and returns
#   the beginning event number for that set of events.
#
#   If there aren't enough user-defined events left, this function
#   returns (uint32)-1
#
proc registerEvents*(numevents: cint): uint32 {.importc: "SDL_RegisterEvents".}


proc setError*(fmt: cstring) {.varargs, importc: "SDL_SetError".}
proc getError*(): cstring {.importc: "SDL_GetError".}
proc clearError*() {.importc: "SDL_ClearError".}

#extern DECLSPEC const char* SDLCALL SDL_GetPixelFormatName(uint32 format);
proc getPixelFormatName* (format: uint32): cstring {.
  importc: "SDL_GetPixelFormatName".}
  ## Get the human readable name of a pixel format

#extern DECLSPEC SDL_bool SDLCALL SDL_PixelFormatEnumToMasks(uint32 format,
#                                                            int *bpp,
#                                                            uint32 * Rmask,
#                                                            uint32 * Gmask,
#                                                            uint32 * Bmask,
#                                                            uint32 * Amask);
proc pixelFormatEnumToMasks* (format: uint32; bpp: var cint;
  Rmask, Gmask, Bmask, Amask: var uint32): bool {.
  importc: "SDL_PixelFormatEnumToMasks".}
  ##Convert one of the enumerated pixel formats to a bpp and RGBA masks.
  ##Returns TRUE or FALSE if the conversion wasn't possible.


#extern DECLSPEC uint32 SDLCALL SDL_MasksToPixelFormatEnum(int bpp,
#                                                          uint32 Rmask,
#                                                          uint32 Gmask,
#                                                          uint32 Bmask,
#                                                          uint32 Amask);
proc masksToPixelFormatEnum* (bpp: cint; Rmask, Gmask, Bmask, Amask: uint32): uint32 {.
  importc: "SDL_MasksToPixelFormatEnum".}
  ##Convert a bpp and RGBA masks to an enumerated pixel format.
  ##The pixel format, or ::SDL_PIXELFORMAT_UNKNOWN if the conversion wasn't possible.

#extern DECLSPEC SDL_PixelFormat * SDLCALL SDL_AllocFormat(uint32 pixel_format);
proc allocFormat* (pixelFormat: uint32): ptr PixelFormat {.
  importc: "SDL_AllocFormat".}
##Create an SDL_PixelFormat structure from a pixel format enum.

#extern DECLSPEC void SDLCALL SDL_FreeFormat(SDL_PixelFormat *format);
proc freeFormat* (format: ptr PixelFormat) {.
  importc: "SDL_FreeFormat".}
  ##Free an SDL_PixelFormat structure.

#extern DECLSPEC SDL_Palette *SDLCALL SDL_AllocPalette(int ncolors);
proc allocPalette* (numColors: cint): ptr Palette {.
  importc: "SDL_AllocPalette".}
  ##Create a palette structure with the specified number of color entries.
  ##Returns A new palette, or NULL if there wasn't enough memory.
  ##Note: The palette entries are initialized to white.

#extern DECLSPEC int SDLCALL SDL_SetPixelFormatPalette(SDL_PixelFormat * format,
#                                                      SDL_Palette *palette);
proc setPixelFormatPalette* (format: ptr PixelFormat; palette: ptr Palette): cint {.
  importc: "SDL_SetPixelFormatPalette".}
  ##Set the palette for a pixel format structure.

#extern DECLSPEC int SDLCALL SDL_SetPaletteColors(SDL_Palette * palette,
#                                                 const SDL_Color * colors,
#                                                 int firstcolor, int ncolors);
proc setPaletteColors* (palette: ptr Palette; colors: ptr Color; first, numColors: cint): SDL_Return {.discardable,
  importc: "SDL_SetPaletteColors".}
  ## Set a range of colors in a palette.
#extern DECLSPEC void SDLCALL SDL_FreePalette(SDL_Palette * palette);
proc freePalette* (palette: ptr Palette) {.
  importc: "SDL_FreePalette".}
  ##Free a palette created with SDL_AllocPalette().

#extern DECLSPEC uint32 SDLCALL SDL_MapRGB(const SDL_PixelFormat * format,
#                                          uint8 r, uint8 g, uint8 b);
proc mapRGB* (format: ptr PixelFormat; r,g,b: uint8): uint32 {.
  importc: "SDL_MapRGB".}
  ##Maps an RGB triple to an opaque pixel value for a given pixel format.

#extern DECLSPEC uint32 SDLCALL SDL_MapRGBA(const SDL_PixelFormat * format,
#                                           uint8 r, uint8 g, uint8 b,
#                                           uint8 a);
proc mapRGBA* (format: ptr PixelFormat; r,g,b,a: uint8): uint32 {.
  importc: "SDL_MapRGBA".}
  ##Maps an RGBA quadruple to a pixel value for a given pixel format.

#extern DECLSPEC void SDLCALL SDL_GetRGB(uint32 pixel,
#                                        const SDL_PixelFormat * format,
#                                        uint8 * r, uint8 * g, uint8 * b);
proc getRGB* (pixel: uint32; format: ptr PixelFormat; r,g,b: var uint8) {.
  importc: "SDL_GetRGB".}
  ##Get the RGB components from a pixel of the specified format.

#extern DECLSPEC void SDLCALL SDL_GetRGBA(uint32 pixel,
#                                         const SDL_PixelFormat * format,
#                                         uint8 * r, uint8 * g, uint8 * b,
#                                         uint8 * a);
proc getRGBA* (pixel: uint32; format: ptr PixelFormat; r,g,b,a: var uint8) {.
  importc: "SDL_GetRGBA".}
  ##Get the RGBA components from a pixel of the specified format.

#extern DECLSPEC void SDLCALL SDL_CalculateGammaRamp(float gamma, uint16 * ramp);
proc calculateGammaRamp* (gamma: cfloat; ramp: ptr uint16) {.
  importc: "SDL_CalculateGammaRamp".}
  ##Calculate a 256 entry gamma ramp for a gamma value.



# SDL_system.h
when defined(windows):

  proc direct3D9GetAdapterIndex* (displayIndex: cint): cint {.
    importc: "SDL_Direct3D9GetAdapterIndex".}
    ## Returns the D3D9 adapter index that matches the specified display index.
    ## This adapter index can be passed to IDirect3D9::CreateDevice and controls
    ## on which monitor a full screen application will appear.

  #extern DECLSPEC IDirect3DDevice9* SDLCALL SDL_RenderGetD3D9Device(SDL_Renderer * renderer);
  proc getD3D9Device* (renderer: RendererPtr): pointer {.
    importc:"SDL_RenderGetD3D9Device".}
    ## Returns the D3D device associated with a renderer, or NULL if it's not a D3D renderer.
    ## Once you are done using the device, you should release it to avoid a resource leak.

  #extern DECLSPEC void SDLCALL SDL_DXGIGetOutputInfo( int displayIndex, int *adapterIndex, int *outputIndex );
  proc dXGIGetOutputInfo* (displayIndex: cint, adapterIndex,outputIndex: ptr cint) {.importc: "SDL_DXGIGetOutputInfo".}
    ## Returns the DXGI Adapter and Output indices for the specified display index.
    ## These can be passed to EnumAdapters and EnumOutputs respectively to get the objects
    ## required to create a DX10 or DX11 device and swap chain.

  {.deprecated: [DXGIGetOutputInfo: dXGIGetOutputInfo].}
  {.deprecated: [Direct3D9GetAdapterIndex: direct3D9GetAdapterIndex].}
  {.deprecated: [GetD3D9Device: getD3D9Device].}

elif defined(iPhone):


  #extern DECLSPEC int SDLCALL SDL_iPhoneSetAnimationCallback(
  #    SDL_Window * window, int interval,
  #    void (*callback)(void*), void *callbackParam);
  proc iPhoneSetAnimationCallback*(window: WindowPtr, interval:cint, callback: VoidCallback, callbackParam: pointer): cint {.
    importc: "SDL_iPhoneSetAnimationCallback".}

  #extern DECLSPEC void SDLCALL SDL_iPhoneSetEventPump(SDL_bool enabled);
  proc iPhoneSetEventPump*(enabled: bool) {.
    importc: "SDL_iPhoneSetEventPump".}

  #extern DECLSPEC int SDLCALL SDL_iPhoneKeyboardShow(SDL_Window * window);
  proc iPhoneKeyboardShow*(window:WindowPtr): cint {.
    importc: "SDL_iPhoneKeyboardShow".}
  #extern DECLSPEC int SDLCALL SDL_iPhoneKeyboardHide(SDL_Window * window);
  proc iPhoneKeyboardHide*(window:WindowPtr): cint {.
    importc: "SDL_iPhoneKeyboardHide".}
  #extern DECLSPEC SDL_bool SDLCALL SDL_iPhoneKeyboardIsShown(SDL_Window * window);
  proc iPhoneKeyboardIsShown*(window:WindowPtr): bool {.
    importc: "SDL_iPhoneKeyboardIsShown".}
  #extern DECLSPEC int SDLCALL SDL_iPhoneKeyboardToggle(SDL_Window * window);
  proc iPhoneKeyboardToggle*(window:WindowPtr): cint {.
    importc: "SDL_iPhoneKeyboardToggle".}

elif defined(android):

  #extern DECLSPEC void * SDLCALL SDL_AndroidGetJNIEnv();
  proc androidGetJNIEnv*(): pointer {.importc: "SDL_AndroidGetJNIEnv".}

  #extern DECLSPEC void * SDLCALL SDL_AndroidGetActivity();
  proc androidGetActivity*(): pointer {.importc: "SDL_AndroidGetActivity".}

  #extern DECLSPEC int SDLCALL SDL_AndroidGetExternalStorageState();
  proc androidGetExternalStorageState*(): cint {.
    importc: "SDL_AndroidGetExternalStorageState".}

  #extern DECLSPEC const char * SDLCALL SDL_AndroidGetInternalStoragePath();
  proc androidGetInternalStoragePath* (): cstring {.
    importc: "SDL_AndroidGetInternalStoragePath".}

  #extern DECLSPEC const char * SDLCALL SDL_AndroidGetExternalStoragePath();
  proc androidGetExternalStoragePath* (): cstring {.
    importc: "SDL_AndroidGetExternalStoragePath".}

  {.deprecated: [AndroidGetActivity: androidGetActivity].}
  {.deprecated: [AndroidGetExternalStoragePath: androidGetExternalStoragePath].}
  {.deprecated: [AndroidGetExternalStorageState: androidGetExternalStorageState].}
  {.deprecated: [AndroidGetInternalStoragePath: androidGetInternalStoragePath].}
  {.deprecated: [AndroidGetJNIEnv: androidGetJNIEnv].}


const
  SDL_QUERY* = -1
  SDL_IGNORE* = 0
  SDL_DISABLE* = 0
  SDL_ENABLE* = 1

##define SDL_GetEventState(type) SDL_EventState(type, SDL_QUERY)
proc getEventState*(kind: EventType): uint8 {.inline.} = eventState(kind, SDL_QUERY)

##define SDL_BUTTON(X)		(1 << ((X)-1))
template SDL_BUTTON*(x: uint8): uint8 = (1'u8 shl (x - 1'u8))
const
  BUTTON_LEFT* = 1'u8
  BUTTON_MIDDLE* = 2'u8
  BUTTON_RIGHT* = 3'u8
  BUTTON_X1* = 4'u8
  BUTTON_X2* = 5'u8
  BUTTON_LMASK* = SDL_BUTTON(BUTTON_LEFT)
  BUTTON_MMASK* = SDL_BUTTON(BUTTON_MIDDLE)
  BUTTON_RMASK* = SDL_BUTTON(BUTTON_RIGHT)
  BUTTON_X1MASK* = SDL_BUTTON(BUTTON_X1)
  BUTTON_X2MASK* = SDL_BUTTON(BUTTON_X2)



## compatibility functions

proc createRGBSurface* (width, height, depth: int32): SurfacePtr {.inline.} = sdl2.createRGBSurface(
  0, width, height, depth, 0,0,0,0)
proc getSize*(window: WindowPtr): Point {.inline.} = getSize(window, result.x, result.y)

proc destroyTexture*(texture: TexturePtr) {.inline.} = destroy(texture)
#proc destroy* (texture: TexturePtr) {.inline.} = texture.destroyTexture
proc destroyRenderer*(renderer: RendererPtr) {.inline.} = destroy(renderer)
#proc destroy* (renderer: RendererPtr) {.inline.} = renderer.destroyRenderer

proc destroy* (window: WindowPtr) {.inline.} = window.destroyWindow
proc destroy* (cursor: CursorPtr) {.inline.} = cursor.freeCursor
proc destroy* (surface: SurfacePtr) {.inline.} = surface.freeSurface
proc destroy* (format: ptr PixelFormat) {.inline.} = format.freeFormat
proc destroy* (palette: ptr Palette) {.inline.} = palette.freePalette

proc blitSurface*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.inline, discardable.} = upperBlit(src, srcrect, dst, dstrect)
proc blitScaled*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.inline, discardable.} = upperBlitScaled(src, srcrect, dst, dstrect)

#proc init*(flags: cint): SDL_Return {.inline, deprecated.} = sdl2.init(flags)
#proc quit*() {.inline,deprecated.} = sdl2.quit()

#/#define SDL_LoadBMP(file)	SDL_LoadBMP_RW(SDL_RWFromFile(file, "rb"), 1)
proc loadBMP*(file: string): SurfacePtr {.inline.} = loadBMP_RW(rwFromFile(cstring(file), "rb"), 1)
##define SDL_SaveBMP(surface, file) \
#  SDL_SaveBMP_RW(surface, SDL_RWFromFile(file, "wb"), 1)
proc saveBMP*(surface: SurfacePtr; file: string): SDL_Return {.
  inline, discardable.} = saveBMP_RW(surface, rwFromFile(file, "wb"), 1)

proc color*(r, g, b, a: range[0..255]): Color = (r.uint8, g.uint8, b.uint8, a.uint8)

proc rect*(x, y: cint; w = cint(0), h = cint(0)): Rect =
  result.x = x
  result.y = y
  result.w = w
  result.h = h

proc point*[T: SomeNumber](x, y: T): Point = (x.cint, y.cint)

proc contains*(some: Rect; point: Point): bool =
  return point.x >= some.x and point.x <= (some.x + some.w) and
          point.y >= some.y and point.y <= (some.y + some.h)

proc setHint*(name: cstring, value: cstring): bool {.
  importc: "SDL_SetHint".}

proc setHintWithPriority*(name: cstring, value: cstring, priority: cint): bool {.
  importc: "SDL_SetHintWithPriority".}

proc getHint*(name: cstring): cstring {.
  importc: "SDL_GetHint".}

proc size* (ctx:RWopsPtr): int64 {.inline.} =
  ctx.size(ctx)
proc seek* (ctx:RWopsPtr; offset:int64; whence:cint): int64 {.inline.} =
  ctx.seek(ctx,offset,whence)
proc read* (ctx:RWopsPtr; `ptr`: pointer; size,maxnum:csize): csize{.inline.} =
  ctx.read(ctx, `ptr`, size, maxnum)
proc write* (ctx:RWopsPtr; `ptr`:pointer; size,num:csize): csize{.inline.} =
  ctx.write(ctx, `ptr`, size, num)
proc close* (ctx:RWopsPtr): cint {.inline.} =
  ctx.close(ctx)

{.pop.}

let defaultEvent* = Event(kind: QuitEvent)
  ## a default "initialized" Event

{.deprecated: [PBlitMap: BlitMapPtr].}
{.deprecated: [PControllerAxisEvent: ControllerAxisEventPtr].}
{.deprecated: [PControllerButtonEvent: ControllerButtonEventPtr].}
{.deprecated: [PControllerDeviceEvent: ControllerDeviceEventPtr].}
{.deprecated: [PCursor: CursorPtr].}
{.deprecated: [PDollarGestureEvent: DollarGestureEventPtr].}
{.deprecated: [PDropEvent: DropEventPtr].}
{.deprecated: [PGLContext: GlContextPtr].}
{.deprecated: [PJoyAxisEvent: JoyAxisEventPtr].}
{.deprecated: [PJoyBallEvent: JoyBallEventPtr].}
{.deprecated: [PJoyButtonEvent: JoyButtonEventPtr].}
{.deprecated: [PJoyDeviceEvent: JoyDeviceEventPtr].}
{.deprecated: [PJoyHatEvent: JoyHatEventPtr].}
{.deprecated: [PKeyboardEvent: KeyboardEventPtr].}
{.deprecated: [PMouseButtonEvent: MouseButtonEventPtr].}
{.deprecated: [PMouseMotionEvent: MouseMotionEventPtr].}
{.deprecated: [PMouseWheelEvent: MouseWheelEventPtr].}
{.deprecated: [PMultiGestureEvent: MultiGestureEventPtr].}
{.deprecated: [PQuitEvent: QuitEventPtr].}
{.deprecated: [PRWops: RWopsPtr].}
{.deprecated: [PRenderer: RendererPtr].}
{.deprecated: [PRendererInfo: RendererInfoPtr].}
{.deprecated: [PSurface: SurfacePtr].}
{.deprecated: [PTextEditingEvent: TextEditingEventPtr].}
{.deprecated: [PTextInputEvent: TextInputEventPtr].}
{.deprecated: [PTexture: TexturePtr].}
{.deprecated: [PTouchFingerEvent: TouchFingerEventPtr].}
{.deprecated: [PUserEvent: UserEventPtr].}
{.deprecated: [PWindow: WindowPtr].}
{.deprecated: [PWindowEvent: WindowEventPtr].}
{.deprecated: [TBlendMode: BlendMode].}
{.deprecated: [TBlitFunction: BlitFunction].}
{.deprecated: [TColor: Color].}
{.deprecated: [TControllerAxisEvent: ControllerAxisEventObj].}
{.deprecated: [TControllerButtonEvent: ControllerButtonEventObj].}
{.deprecated: [TControllerDeviceEvent: ControllerDeviceEventObj].}
{.deprecated: [TDisplayMode: DisplayMode].}
{.deprecated: [TDollarGestureEvent: DollarGestureEventObj].}
{.deprecated: [TDropEvent: DropEventObj].}
{.deprecated: [TEvent: Event].}
{.deprecated: [TEventFilter: EventFilter].}
{.deprecated: [TEventType: EventType].}
{.deprecated: [TEventaction: Eventaction].}
{.deprecated: [TFingerID: FingerID].}
{.deprecated: [TGestureID: GestureID].}
{.deprecated: [TJoyAxisEvent: JoyAxisEventObj].}
{.deprecated: [TJoyBallEvent: JoyBallEventObj].}
{.deprecated: [TJoyButtonEvent: JoyButtonEventObj].}
{.deprecated: [TJoyDeviceEvent: JoyDeviceEventObj].}
{.deprecated: [TJoyHatEvent: JoyHatEventObj].}
{.deprecated: [TKeyState: KeyState].}
{.deprecated: [TKeySym: KeySym].}
{.deprecated: [TKeyboardEvent: KeyboardEventObj].}
{.deprecated: [TMem: Mem].}
{.deprecated: [TMessageBoxButtonData: MessageBoxButtonData].}
{.deprecated: [TMessageBoxColor: MessageBoxColor].}
{.deprecated: [TMessageBoxColorScheme: MessageBoxColorScheme].}
{.deprecated: [TMessageBoxColorType: MessageBoxColorType].}
{.deprecated: [TMessageBoxData: MessageBoxData].}
{.deprecated: [TMouseButtonEvent: MouseButtonEventObj].}
{.deprecated: [TMouseMotionEvent: MouseMotionEventObj].}
{.deprecated: [TMouseWheelEvent: MouseWheelEventObj].}
{.deprecated: [TMultiGestureEvent: MultiGestureEventObj].}
{.deprecated: [TPalette: Palette].}
{.deprecated: [TPixelFormat: PixelFormat].}
{.deprecated: [TPoint: Point].}
{.deprecated: [TQuitEvent: QuitEventObj].}
{.deprecated: [TRWops: RWops].}
{.deprecated: [TRect: Rect].}
{.deprecated: [TRendererFlip: RendererFlip].}
{.deprecated: [TRendererInfo: RendererInfo].}
{.deprecated: [TSurface: Surface].}
{.deprecated: [TSysWMType: SysWMType].}
{.deprecated: [TTextEditingEvent: TextEditingEventObj].}
{.deprecated: [TTextInputEvent: TextInputEventObj].}
{.deprecated: [TTextureAccess: TextureAccess].}
{.deprecated: [TTextureModulate: TextureModulate].}
{.deprecated: [TTimerCallback: TimerCallback].}
{.deprecated: [TTimerID: TimerID].}
{.deprecated: [TTouchFingerEvent: TouchFingerEventObj].}
{.deprecated: [TTouchID: TouchID].}
{.deprecated: [TUserEvent: UserEventObj].}
{.deprecated: [TVoidCallback: VoidCallback].}
{.deprecated: [TWMinfo: WMinfo].}
{.deprecated: [TWindowEvent: WindowEventObj].}
{.deprecated: [TWindowEventID: WindowEventID].}

{.deprecated: [AddEventWatch: addEventWatch].}
{.deprecated: [AddTimer: addTimer].}
{.deprecated: [AllocFormat: allocFormat].}
{.deprecated: [AllocPalette: allocPalette].}
{.deprecated: [BlitScaled: blitScaled].}
{.deprecated: [BlitSurface: blitSurface].}
{.deprecated: [CalculateGammaRamp: calculateGammaRamp].}
{.deprecated: [Clear: clear].}
{.deprecated: [ClearError: clearError].}
{.deprecated: [Contains: contains].}
{.deprecated: [ConvertPixels: convertPixels].}
{.deprecated: [ConvertSurface: convertSurface].}
{.deprecated: [ConvertSurfaceFormat: convertSurfaceFormat].}
{.deprecated: [Copy: copy].}
{.deprecated: [CopyEx: copyEx].}
{.deprecated: [CreateColorCursor: createColorCursor].}
{.deprecated: [CreateCursor: createCursor].}
{.deprecated: [CreateRGBSurface: createRGBSurface].}
{.deprecated: [CreateRGBSurfaceFrom: createRGBSurfaceFrom].}
{.deprecated: [CreateRenderer: createRenderer].}
{.deprecated: [CreateSoftwareRenderer: createSoftwareRenderer].}
{.deprecated: [CreateTexture: createTexture].}
{.deprecated: [CreateTextureFromSurface: createTextureFromSurface].}
{.deprecated: [CreateWindow: createWindow].}
{.deprecated: [CreateWindowAndRenderer: createWindowAndRenderer].}
{.deprecated: [CreateWindowFrom: createWindowFrom].}
{.deprecated: [DelEventWatch: delEventWatch].}
{.deprecated: [Delay: delay].}
{.deprecated: [DestroyRenderer: destroyRenderer].}
{.deprecated: [DestroyTexture: destroyTexture].}
{.deprecated: [DestroyWindow: destroyWindow].}
{.deprecated: [DisableScreenSaver: disableScreenSaver].}
{.deprecated: [DrawLine: drawLine].}
{.deprecated: [DrawLines: drawLines].}
{.deprecated: [DrawPoint: drawPoint].}
{.deprecated: [DrawPoints: drawPoints].}
{.deprecated: [DrawRect: drawRect].}
{.deprecated: [DrawRects: drawRects].}
{.deprecated: [EnableScreenSaver: enableScreenSaver].}
{.deprecated: [EventState: eventState].}
{.deprecated: [FillRect: fillRect].}
{.deprecated: [FillRects: fillRects].}
{.deprecated: [FilterEvents: filterEvents].}
{.deprecated: [FlushEvent: flushEvent].}
{.deprecated: [FlushEvents: flushEvents].}
{.deprecated: [FreeCursor: freeCursor].}
{.deprecated: [FreeFormat: freeFormat].}
{.deprecated: [FreePalette: freePalette].}
{.deprecated: [FreeSurface: freeSurface].}
{.deprecated: [GL_BindTexture: glBindTexture].}
{.deprecated: [GL_CreateContext: glCreateContext].}
{.deprecated: [GL_DeleteContext: glDeleteContext].}
{.deprecated: [GL_ExtensionSupported: glExtensionSupported].}
{.deprecated: [GL_GetAttribute: glGetAttribute].}
{.deprecated: [GL_GetCurrentContext: glGetCurrentContext].}
{.deprecated: [GL_GetCurrentWindow: glGetCurrentWindow].}
{.deprecated: [GL_GetDrawableSize: glGetDrawableSize].}
{.deprecated: [GL_GetProcAddress: glGetProcAddress].}
{.deprecated: [GL_GetSwapInterval: glGetSwapInterval].}
{.deprecated: [GL_LoadLibrary: glLoadLibrary].}
{.deprecated: [GL_MakeCurrent: glMakeCurrent].}
{.deprecated: [GL_SetAttribute: glSetAttribute].}
{.deprecated: [GL_SetSwapInterval: glSetSwapInterval].}
{.deprecated: [GL_SwapWindow: glSwapWindow].}
{.deprecated: [GL_UnbindTexture: glUnbindTexture].}
{.deprecated: [GL_UnloadLibrary: glUnloadLibrary].}
{.deprecated: [GetBrightness: getBrightness].}
{.deprecated: [GetClipRect: getClipRect].}
{.deprecated: [GetClosestDisplayMode: getClosestDisplayMode].}
{.deprecated: [GetColorKey: getColorKey].}
{.deprecated: [GetCurrentDisplayMode: getCurrentDisplayMode].}
{.deprecated: [GetCurrentVideoDriver: getCurrentVideoDriver].}
{.deprecated: [GetCursor: getCursor].}
{.deprecated: [GetData: getData].}
{.deprecated: [GetDesktopDisplayMode: getDesktopDisplayMode].}
{.deprecated: [GetDisplayBounds: getDisplayBounds].}
{.deprecated: [GetDisplayIndex: getDisplayIndex].}
{.deprecated: [GetDisplayMode: getDisplayMode].}
{.deprecated: [GetDrawBlendMode: getDrawBlendMode].}
{.deprecated: [GetDrawColor: getDrawColor].}
{.deprecated: [GetError: getError].}
{.deprecated: [GetEventFilter: getEventFilter].}
{.deprecated: [GetEventState: getEventState].}
{.deprecated: [GetFlags: getFlags].}
{.deprecated: [GetGammaRamp: getGammaRamp].}
{.deprecated: [GetGrab: getGrab].}
{.deprecated: [GetHint: getHint].}
{.deprecated: [GetID: getID].}
{.deprecated: [GetKeyFromName: getKeyFromName].}
{.deprecated: [GetKeyFromScancode: getKeyFromScancode].}
{.deprecated: [GetKeyName: getKeyName].}
{.deprecated: [GetKeyboardFocus: getKeyboardFocus].}
{.deprecated: [GetKeyboardState: getKeyboardState].}
{.deprecated: [GetLogicalSize: getLogicalSize].}
{.deprecated: [GetModState: getModState].}
{.deprecated: [GetMouseFocus: getMouseFocus].}
{.deprecated: [GetMouseState: getMouseState].}
{.deprecated: [GetNumDisplayModes: getNumDisplayModes].}
{.deprecated: [GetNumRenderDrivers: getNumRenderDrivers].}
{.deprecated: [GetNumVideoDisplays: getNumVideoDisplays].}
{.deprecated: [GetNumVideoDrivers: getNumVideoDrivers].}
{.deprecated: [GetPerformanceCounter: getPerformanceCounter].}
{.deprecated: [GetPerformanceFrequency: getPerformanceFrequency].}
{.deprecated: [GetPixelFormat: getPixelFormat].}
{.deprecated: [GetPixelFormatName: getPixelFormatName].}
{.deprecated: [GetPlatform: getPlatform].}
{.deprecated: [GetPosition: getPosition].}
{.deprecated: [GetRGB: getRGB].}
{.deprecated: [GetRGBA: getRGBA].}
{.deprecated: [GetRelativeMouseMode: getRelativeMouseMode].}
{.deprecated: [GetRelativeMouseState: getRelativeMouseState].}
{.deprecated: [GetRenderDriverInfo: getRenderDriverInfo].}
{.deprecated: [GetRenderTarget: getRenderTarget].}
{.deprecated: [GetRenderer: getRenderer].}
{.deprecated: [GetRendererInfo: getRendererInfo].}
{.deprecated: [GetRevision: getRevision].}
{.deprecated: [GetRevisionNumber: getRevisionNumber].}
{.deprecated: [GetScale: getScale].}
{.deprecated: [GetScancodeFromKey: getScancodeFromKey].}
{.deprecated: [GetScancodeFromName: getScancodeFromName].}
{.deprecated: [GetScancodeName: getScancodeName].}
{.deprecated: [GetSize: getSize].}
{.deprecated: [GetSurface: getSurface].}
{.deprecated: [GetSurfaceAlphaMod: getSurfaceAlphaMod].}
{.deprecated: [GetSurfaceBlendMode: getSurfaceBlendMode].}
{.deprecated: [GetSurfaceColorMod: getSurfaceColorMod].}
{.deprecated: [GetTextureAlphaMod: getTextureAlphaMod].}
{.deprecated: [GetTextureBlendMode: getTextureBlendMode].}
{.deprecated: [GetTextureColorMod: getTextureColorMod].}
{.deprecated: [GetTicks: getTicks].}
{.deprecated: [GetTitle: getTitle].}
{.deprecated: [GetVersion: getVersion].}
{.deprecated: [GetVideoDriver: getVideoDriver].}
{.deprecated: [GetViewport: getViewport].}
{.deprecated: [GetWMInfo: getWMInfo].}
{.deprecated: [GetWindowFromID: getWindowFromID].}
{.deprecated: [HasEvent: hasEvent].}
{.deprecated: [HasEvents: hasEvents].}
{.deprecated: [HasScreenKeyboardSupport: hasScreenKeyboardSupport].}
{.deprecated: [HideWindow: hideWindow].}
{.deprecated: [Init: init].}
{.deprecated: [InitSubSystem: initSubSystem].}
{.deprecated: [IsScreenKeyboardShown: isScreenKeyboardShown].}
{.deprecated: [IsScreenSaverEnabled: isScreenSaverEnabled].}
{.deprecated: [IsTextInputActive: isTextInputActive].}
{.deprecated: [LoadBMP: loadBMP].}
{.deprecated: [LoadBMP_RW: loadBMP_RW].}
{.deprecated: [LockSurface: lockSurface].}
{.deprecated: [LockTexture: lockTexture].}
{.deprecated: [LowerBlit: lowerBlit].}
{.deprecated: [LowerBlitScaled: lowerBlitScaled].}
{.deprecated: [MapRGB: mapRGB].}
{.deprecated: [MapRGBA: mapRGBA].}
{.deprecated: [MasksToPixelFormatEnum: masksToPixelFormatEnum].}
{.deprecated: [MaximizeWindow: maximizeWindow].}
{.deprecated: [MinimizeWindow: minimizeWindow].}
{.deprecated: [PeepEvents: peepEvents].}
{.deprecated: [PixelFormatEnumToMasks: pixelFormatEnumToMasks].}
{.deprecated: [PollEvent: pollEvent].}
{.deprecated: [Present: present].}
{.deprecated: [PumpEvents: pumpEvents].}
{.deprecated: [PushEvent: pushEvent].}
{.deprecated: [QueryTexture: queryTexture].}
{.deprecated: [Quit: quit].}
{.deprecated: [QuitSubSystem: quitSubSystem].}
{.deprecated: [RWFromConstMem: rWFromConstMem].}
{.deprecated: [RWFromFP: rWFromFP].}
{.deprecated: [RWFromFile: rWFromFile].}
{.deprecated: [RWFromMem: rWFromMem].}
{.deprecated: [RaiseWindow: raiseWindow].}
{.deprecated: [ReadBE16: readBE16].}
{.deprecated: [ReadBE32: readBE32].}
{.deprecated: [ReadBE64: readBE64].}
{.deprecated: [ReadLE16: readLE16].}
{.deprecated: [ReadLE32: readLE32].}
{.deprecated: [ReadLE64: readLE64].}
{.deprecated: [ReadPixels: readPixels].}
{.deprecated: [ReadU8: readU8].}
{.deprecated: [RegisterEvents: registerEvents].}
{.deprecated: [RemoveTimer: removeTimer].}
{.deprecated: [RenderTargetSupported: renderTargetSupported].}
{.deprecated: [RestoreWindow: restoreWindow].}
{.deprecated: [SDL_Init: init].}
{.deprecated: [SDL_Quit: quit].}
{.deprecated: [SaveBMP: saveBMP].}
{.deprecated: [SaveBMP_RW: saveBMP_RW].}
{.deprecated: [SetBordered: setBordered].}
{.deprecated: [SetBrightness: setBrightness].}
{.deprecated: [SetClipRect: setClipRect].}
{.deprecated: [SetColorKey: setColorKey].}
{.deprecated: [SetCursor: setCursor].}
{.deprecated: [SetData: setData].}
{.deprecated: [SetDisplayMode: setDisplayMode].}
{.deprecated: [SetDrawBlendMode: setDrawBlendMode].}
{.deprecated: [SetDrawColor: setDrawColor].}
{.deprecated: [SetError: setError].}
{.deprecated: [SetEventFilter: setEventFilter].}
{.deprecated: [SetFullscreen: setFullscreen].}
{.deprecated: [SetGammaRamp: setGammaRamp].}
{.deprecated: [SetGrab: setGrab].}
{.deprecated: [SetHint: setHint].}
{.deprecated: [SetHintWithPriority: setHintWithPriority].}
{.deprecated: [SetIcon: setIcon].}
{.deprecated: [SetLogicalSize: setLogicalSize].}
{.deprecated: [SetModState: setModState].}
{.deprecated: [SetPaletteColors: setPaletteColors].}
{.deprecated: [SetPixelFormatPalette: setPixelFormatPalette].}
{.deprecated: [SetPosition: setPosition].}
{.deprecated: [SetRelativeMouseMode: setRelativeMouseMode].}
{.deprecated: [SetRenderTarget: setRenderTarget].}
{.deprecated: [SetScale: setScale].}
{.deprecated: [SetSize: setSize].}
{.deprecated: [SetSurfaceAlphaMod: setSurfaceAlphaMod].}
{.deprecated: [SetSurfaceBlendMode: setSurfaceBlendMode].}
{.deprecated: [SetSurfaceColorMod: setSurfaceColorMod].}
{.deprecated: [SetSurfacePalette: setSurfacePalette].}
{.deprecated: [SetSurfaceRLE: setSurfaceRLE].}
{.deprecated: [SetTextInputRect: setTextInputRect].}
{.deprecated: [SetTextureAlphaMod: setTextureAlphaMod].}
{.deprecated: [SetTextureBlendMode: setTextureBlendMode].}
{.deprecated: [SetTextureColorMod: setTextureColorMod].}
{.deprecated: [SetTitle: setTitle].}
{.deprecated: [SetViewport: setViewport].}
{.deprecated: [ShowCursor: showCursor].}
{.deprecated: [ShowMessageBox: showMessageBox].}
{.deprecated: [ShowSimpleMessageBox: showSimpleMessageBox].}
{.deprecated: [ShowWindow: showWindow].}
{.deprecated: [SoftStretch: softStretch].}
{.deprecated: [StartTextInput: startTextInput].}
{.deprecated: [StopTextInput: stopTextInput].}
{.deprecated: [UnlockSurface: unlockSurface].}
{.deprecated: [UnlockTexture: unlockTexture].}
{.deprecated: [UpdateSurface: updateSurface].}
{.deprecated: [UpdateSurfaceRects: updateSurfaceRects].}
{.deprecated: [UpdateTexture: updateTexture].}
{.deprecated: [UpperBlit: upperBlit].}
{.deprecated: [UpperBlitScaled: upperBlitScaled].}
{.deprecated: [VideoInit: videoInit].}
{.deprecated: [VideoQuit: videoQuit].}
{.deprecated: [WaitEvent: waitEvent].}
{.deprecated: [WaitEventTimeout: waitEventTimeout].}
{.deprecated: [WarpMouseInWindow: warpMouseInWindow].}
{.deprecated: [WasInit: wasInit].}
{.deprecated: [WriteBE16: writeBE16].}
{.deprecated: [WriteBE32: writeBE32].}
{.deprecated: [WriteBE64: writeBE64].}
{.deprecated: [WriteLE16: writeLE16].}
{.deprecated: [WriteLE32: writeLE32].}
{.deprecated: [WriteLE64: writeLE64].}
{.deprecated: [WriteU8: writeU8].}
