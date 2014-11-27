import macros

import unsigned, strutils
export unsigned, strutils.`%`


# Add for people running sdl 2.0.0
{. deadCodeElim: on .}

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

include sdl2/private/keycodes

const
  SDL_TEXTEDITINGEVENT_TEXT_SIZE* = 32
  SDL_TEXTINPUTEVENT_TEXT_SIZE* = 32
type

  TWindowEventID* {.size: sizeof(byte).} = enum
    WindowEvent_None = 0, WindowEvent_Shown, WindowEvent_Hidden, WindowEvent_Exposed,
    WindowEvent_Moved, WindowEvent_Resized, WindowEvent_SizeChanged, WindowEvent_Minimized,
    WindowEvent_Maximized, WindowEvent_Restored, WindowEvent_Enter, WindowEvent_Leave,
    WindowEvent_FocusGained, WindowEvent_FocusLost, WindowEvent_Close
  
  TEventType* {.size: sizeof(cint).} = enum
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

  
  TEvent* = object
    kind*: TEventType
    padding: array[56-sizeof(TEventType), byte]
  
  PQuitEvent* = ptr TQuitEvent
  TQuitEvent* = object
    kind*: TEventType
    timestamp*: uint32
  PWindowEvent* = ptr TWindowEvent
  TWindowEvent* = object
    kind*: TEventType
    timestamp*: uint32
    windowID*: uint32
    event*: TWindowEventID
    pad1,pad2,pad3: uint8
    data1*, data2*: cint
  PKeyboardEvent* = ptr TKeyboardEvent
  TKeyboardEvent* = object
    kind*: TEventType
    timestamp*: uint32
    windowID*: uint32
    state*: uint8
    repeat*: bool
    pad1,pad2: byte
    keysym*: TKeySym
  PTextEditingEvent* = ptr TTextEditingEvent
  TTextEditingEvent* = object
    kind*: TEventType
    timestamp*: uint32
    windowID*: uint32
    text*: array[SDL_TEXTEDITINGEVENT_TEXT_SIZE, char]
    start*,length*: int32
  PTextInputEvent* = ptr TTextInputEvent
  TTextInputEvent* = object
    kind*: TEventType
    timestamp*: uint32
    windowID*: uint32
    text*: array[SDL_TEXTINPUTEVENT_TEXT_SIZE,char]
  PMouseMotionEvent* = ptr TMouseMotionEvent
  TMouseMotionEvent* =  object
    kind*: TEventType
    timestamp*,windowID*: uint32
    which*: uint32
    state*: uint32
    x*,y*, xrel*,yrel*: int32
  PMouseButtonEvent* = ptr TMouseButtonEvent
  TMouseButtonEvent* = object
    kind*: TEventType
    timestamp*,windowID*: uint32
    which*: uint32
    button*: uint8
    state*: uint8
    pad1,pad2: uint8
    x*,y*: cint
  PMouseWheelEvent* = ptr TMouseWheelEvent
  TMouseWheelEvent* = object
    kind*: TEventType
    timestamp*,windowID*: uint32
    which*: uint32
    x*,y*: cint
  PJoyAxisEvent* = ptr TJoyAxisEvent
  TJoyAxisEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: uint8
    axis*: uint8
    pad1,pad2: uint8
    value*: cint
  PJoyBallEvent* = ptr TJoyBallEvent
  TJoyBallEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*,ball*, pad1,pad2: uint8
    xrel*,yrel*: int32
  PJoyHatEvent* = ptr TJoyHatEvent
  TJoyHatEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: int32
    hat*,value*: uint8
  PJoyButtonEvent* = ptr TJoyButtonEvent
  TJoyButtonEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: int32
    button*,state*: uint8
  PJoyDeviceEvent* = ptr TJoyDeviceEvent
  TJoyDeviceEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: int32
  PControllerAxisEvent* = ptr TControllerAxisEvent
  TControllerAxisEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: int32
    axis*, pad1,pad2,pad3: uint8
    value*: int16
  PControllerButtonEvent* = ptr TControllerButtonEvent
  TControllerButtonEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: int32
    button*,state*: uint8
  PControllerDeviceEvent* = ptr TControllerDeviceEvent
  TControllerDeviceEvent* = object
    kind*: TEventType
    timestamp*: uint32
    which*: int32
  
  TTouchID = int64
  TFingerID = int64
  
  PTouchFingerEvent* = ptr TTouchFingerEvent
  TTouchFingerEvent* = object
    kind*: TEventType
    timestamp*: uint32
    touchID*: TTouchID
    fingerID*: TFingerID
    x*,y*,dx*,dy*,pressure*: cfloat
  PMultiGestureEvent* = ptr TMultiGestureEvent
  TMultiGestureEvent* = object
    kind*: TEventType
    timestamp*: uint32
    touchID*: TTouchID
    dTheta*,dDist*,x*,y*: cfloat
    numFingers*: uint16
  
  TGestureID = int64
  PDollarGestureEvent* = ptr TDollarGestureEvent
  TDollarGestureEvent* = object 
    kind*: TEventType
    timestamp*: uint32
    touchID*: TTouchID
    gestureID*: TGestureID
    numFingers*: uint32
    error*, x*, y*: float
  PDropEvent* = ptr TDropEvent
  TDropEvent* = object
    kind*: TEventType
    timestamp*: uint32
    file*: cstring
  PUserEvent* = ptr TUserEvent
  TUserEvent* = object
    kind*: TEventType
    timestamp*,windowID*: uint32
    code*: int32
    data1*,data2*: pointer

  TEventaction* {.size: sizeof(cint).} = enum 
    SDL_ADDEVENT, SDL_PEEKEVENT, SDL_GETEVENT
  TEventFilter* = proc (userdata: pointer; event: ptr TEvent): Bool32 {.cdecl.}
  

  SDL_Return* {.size: sizeof(cint).} = enum SdlError = -1, SdlSuccess = 0 ##\
    ## Return value for many SDL functions. Any function that returns like this \
    ## should also be discardable
  Bool32* {.size: sizeof(cint).} = enum False32 = 0, True32 = 1 ##\
    ## SDL_bool
  TKeyState* {.size: sizeof(byte).} = enum KeyPressed = 0, KeyReleased

  TKeySym* {.pure.} = object
    scancode*: cint ##TScancode
    sym*: cint ##TKeycode
    modstate*: int16
    unicode*: cint

  TPoint* = tuple[x, y: cint]
  TRect* = tuple[x, y: cint, w, h: cint]

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
  TDisplayMode* = object 
    format*: cuint
    w*,h*,refresh_rate*: cint
    driverData*: pointer        
  
  PWindow* = ptr object
  PRenderer* = ptr object
  PTexture* = ptr object
  PCursor* = ptr object

  PGLContext* = ptr object
  
  SDL_Version* = object
    major*, minor*, patch*: uint8
   
  PRendererInfo* = ptr TRendererInfo 
  TRendererInfo* {.pure, final.} = object 
    name*: cstring          #*< The name of the renderer 
    flags*: uint32          #*< Supported ::SDL_RendererFlags 
    num_texture_formats*: uint32 #*< The number of available texture formats 
    texture_formats*: array[0..16 - 1, uint32] #*< The available texture formats 
    max_texture_width*: cint #*< The maximimum texture width 
    max_texture_height*: cint #*< The maximimum texture height 
  
  TTextureAccess* {.size: sizeof(cint).} = enum
    SDL_TEXTUREACCESS_STATIC, SDL_TEXTUREACCESS_STREAMING, SDL_TEXTUREACCESS_TARGET
  TTextureModulate*{.size:sizeof(cint).} = enum
    SDL_TEXTUREMODULATE_NONE, SDL_TEXTUREMODULATE_COLOR, SDL_TEXTUREMODULATE_ALPHA
  TRendererFlip* = cint  
  TSysWMType* {.size: sizeof(cint).}=enum
    SysWM_Unknown, SysWM_Windows, SysWM_X11, SysWM_DirectFB,
    SysWM_Cocoa, SysWM_UIkit
  TWMinfo* = object
    version*: SDL_Version
    subsystem*: TSysWMType
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
    SDL_FLIP_NONE*: cint = 0x00000000 # Do not flip 
    SDL_FLIP_HORIZONTAL*: cint = 0x00000001 # flip horizontally 
    SDL_FLIP_VERTICAL*: cint = 0x00000002 # flip vertically 

converter toBool*(some: Bool32): bool = bool(some)
converter toBool*(some: SDL_Return): bool = some == SdlSuccess
converter toCint*(some: TTextureAccess): cint = some.cint

type 
  TColor* {.pure, final.} = tuple[
    r: uint8,
    g: uint8,
    b: uint8,
    a: uint8]

  TPalette* {.pure, final.} = object 
    ncolors*: cint
    colors*: ptr TColor
    version*: uint32
    refcount*: cint

  TPixelFormat* {.pure, final.} = object 
    format*: uint32
    palette*: ptr TPalette
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
    next*: ptr TPixelFormat
  
  PBlitMap* = ptr object{.pure.} ##couldnt find SDL_BlitMap ?
  
  PSurface* = ptr TSurface
  TSurface* {.pure, final.} = object 
    flags*: uint32          #*< Read-only 
    format*: ptr TPixelFormat #*< Read-only 
    w*, h*, pitch*: int32   #*< Read-only 
    pixels*: pointer        #*< Read-write 
    userdata*: pointer      #*< Read-write  
    locked*: int32          #*< Read-only   ## see if this should be Bool32
    lock_data*: pointer     #*< Read-only 
    clip_rect*: TRect       #*< Read-only 
    map: PBlitMap           #*< Private 
    refcount*: cint         #*< Read-mostly 
  
  TBlendMode* {.size: sizeof(cint).} = enum
      BlendMode_None = 0x00000000, #*< No blending 
      BlendMode_Blend = 0x00000001, #*< dst = (src * A) + (dst * (1-A)) 
      BlendMode_Add  = 0x00000002, #*< dst = (src * A) + dst 
      BlendMode_Mod  = 0x00000004 #*< dst = src * dst 
  TBlitFunction* = proc(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
    dstrect: ptr TRect): cint
    
  TTimerCallback* = proc (interval: uint32; param: pointer): uint32
  TTimerID* = cint

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

template SDL_MUSTLOCK*(some: PSurface): bool = (some.flags and SDL_RLEACCEL) != 0



const
  INIT_TIMER*       = 0x00000001
  INIT_AUDIO*       = 0x00000010
  INIT_VIDEO*       = 0x00000020
  INIT_JOYSTICK*    = 0x00000200
  INIT_HAPTIC*      = 0x00001000
  INIT_NOPARACHUTE* = 0x00100000      
  INIT_EVERYTHING*  = 0x0000FFFF

const SDL_WINDOWPOS_CENTERED_MASK* = 0x2FFF0000
template SDL_WINDOWPOS_CENTERED_DISPLAY*(X: cint): expr = (SDL_WINDOWPOS_CENTERED_MASK or X)
const SDL_WINDOWPOS_CENTERED* = SDL_WINDOWPOS_CENTERED_DISPLAY(0)
template SDL_WINDOWPOS_ISCENTERED*(X): expr = (((X) and 0xFFFF0000) == SDL_WINDOWPOS_CENTERED_MASK)


template EvConv(name, name2, ptype: expr; valid: set[TEventType]): stmt {.immediate.}=
  proc `name`* (event: var TEvent): ptype =
    assert event.kind in valid
    return cast[ptype](addr event)
  proc `name2`* (event: var TEvent): ptype =
    assert event.kind in valid
    return cast[ptype](addr event)

EvConv(EvWindow, window, PWindowEvent, {WindowEvent})
EvConv(EvKeyboard, key, PKeyboardEvent, {KeyDown, KeyUP})
EvConv(EvTextEditing, edit, PTextEditingEvent, {TextEditing})
EvConv(EvTextInput, text, PTextInputEvent, {TextInput})

EvConv(EvMouseMotion, motion, PMouseMotionEvent, {MouseMotion})
EvConv(EvMouseButton, button, PMouseButtonEvent, {MouseButtonDown, MouseButtonUp})
EvConv(EvMouseWheel, wheel, PMouseWheelEvent, {MouseWheel})

EvConv(EvJoyAxis, jaxis, PJoyAxisEvent, {JoyAxisMotion})
EvConv(EvJoyBall, jball, PJoyBallEvent, {JoyBallMotion})
EvConv(EvJoyHat, jhat, PJoyHatEvent, {JoyHatMotion})
EvConv(EvJoyButton, jbutton, PJoyButtonEvent, {JoyButtonDown, JoyButtonUp})
EvConv(EvJoyDevice, jdevice, PJoyDeviceEvent, {JoyDeviceAdded, JoyDeviceRemoved})

EvConv(EvControllerAxis, caxis, PControllerAxisEvent, {ControllerAxisMotion})
EvConv(EvControllerButton, cbutton, PControllerButtonEvent, {ControllerButtonDown, ControllerButtonUp})
EvConv(EvControllerDevice, cdevice, PControllerDeviceEvent, {ControllerDeviceAdded, ControllerDeviceRemoved})

EvConv(EvTouchFinger, tfinger, PTouchFingerEvent, {FingerMotion, FingerDown, FingerUp})
EvConv(EvMultiGesture, mgesture, PMultiGestureEvent, {MultiGesture})
EvConv(EvDollarGesture, dgesture, PDollarGestureEvent, {DollarGesture})

EvConv(EvDropFile, drop, PDropEvent, {DropFile})
EvConv(EvQuit, quit, PQuitEvent, {QuitEvent})

EvConv(EvUser, user, PUserEvent, {UserEvent, UserEvent1, UserEvent2, UserEvent3, UserEvent4, UserEvent5})
#EvConv(EvSysWM, syswm, PSysWMEvent, {SysWMEvent})

const ## SDL_MessageBox flags. If supported will display warning icon, etc.
  SDL_MESSAGEBOX_ERROR* = 0x00000010 #*< error dialog 
  SDL_MESSAGEBOX_WARNING* = 0x00000020 #*< warning dialog 
  SDL_MESSAGEBOX_INFORMATION* = 0x00000040 #*< informational dialog 
  
  ## Flags for SDL_MessageBoxButtonData. 
  SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT* = 0x00000001 #*< Marks the default button when return is hit 
  SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT* = 0x00000002 #*< Marks the default button when escape is hit 

type
  TMessageBoxColor* {.pure, final.} = object 
    r*: uint8
    g*: uint8
    b*: uint8

  TMessageBoxColorType* = enum 
    SDL_MESSAGEBOX_COLOR_BACKGROUND, SDL_MESSAGEBOX_COLOR_TEXT, 
    SDL_MESSAGEBOX_COLOR_BUTTON_BORDER, 
    SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND, 
    SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED, SDL_MESSAGEBOX_COLOR_MAX
  TMessageBoxColorScheme* {.pure, final.} = object 
    colors*: array[TMessageBoxColorType, TMessageBoxColor]


  TMessageBoxButtonData* {.pure, final.} = object 
    flags*: cint         #*< ::SDL_MessageBoxButtonFlags 
    buttonid*: cint         #*< User defined button id (value returned via SDL_MessageBox) 
    text*: cstring          #*< The UTF-8 button text 
  
  TMessageBoxData* {.pure, final.} = object 
    flags*: cint          #*< ::SDL_MessageBoxFlags 
    window*: PWindow #*< Parent window, can be NULL 
    title*, message*: cstring         #*< UTF-8 title and message text
    numbuttons*: cint
    buttons*: ptr TMessageBoxButtonData
    colorScheme*: ptr TMessageBoxColorScheme #*< ::SDL_MessageBoxColorScheme, can be NULL to use system settings 

  PRWops* = ptr TRWops
  TRWops* {.pure, final.} = object 
    size*: proc (context: PRWops): int64 
    seek*: proc (context: PRWops; offset: int64; whence: cint): int64 
    read*: proc (context: PRWops; destination: pointer; size, maxnum: csize): csize 
    write*: proc (context: PRWops; source: pointer; size: csize; 
                  num: csize): csize 
    close*: proc (context: PRWops): cint
    kind*: cint          
    mem*: TMem
  TMem*{.final.} = object 
    base*: ptr byte
    here*: ptr byte
    stop*: ptr byte

when defined(SDL_Static):
  {.push header: "<SDL2/SDL.h>".}
else:
  {.push callConv: cdecl, dynlib: LibName.}


## functions that are not imported directly as SDL_$1  (usually they are prefixed witha type)
proc GetWMInfo*(window: PWindow; info: var TWMInfo): Bool32 {.
  importc: "SDL_GetWindowWMInfo".}

proc SetLogicalSize*(renderer: PRenderer; w, h: cint): cint {.
  importc: "SDL_RenderSetLogicalSize".}

proc GetLogicalSize*(renderer: PRenderer; w, h: var cint) {.
  importc: "SDL_RenderGetLogicalSize".}


proc SetDrawColor*(renderer: PRenderer; r, g, b: uint8, a = 255'u8): SDL_Return {.
  importc: "SDL_SetRenderDrawColor", discardable.}
proc GetDrawColor*(renderer: PRenderer; r, g, b, a: var uint8): SDL_Return {.
  importc: "SDL_GetRenderDrawColor", discardable.}
proc SetDrawBlendMode*(renderer: PRenderer; blendMode: TBlendMode): SDL_Return {.
  importc: "SDL_SetRenderDrawBlendMode", discardable.}
proc GetDrawBlendMode*(renderer: PRenderer; 
  blendMode: var TBlendMode): SDL_Return {.
  importc: "SDL_GetRenderDrawBlendMode", discardable.}


proc destroy*(texture: PTexture) {.importc: "SDL_DestroyTexture".}
proc destroy*(renderer: PRenderer) {.importc: "SDL_DestroyRenderer".}
#proc destroy* (texture: PTexture) {.inline.} = texture.destroyTexture
#proc destroy* (renderer: PRenderer) {.inline.} = renderer.destroyRenderer

proc GetDisplayIndex*(window: PWindow): cint {.importc: "SDL_GetWindowDisplayIndex".}
#*
proc SetDisplayMode*(window: PWindow; 
  mode: ptr TDisplayMode): SDL_Return {.importc: "SDL_SetWindowDisplayMode".}
#*
proc GetDisplayMode*(window: PWindow; mode: var TDisplayMode): cint  {.
  importc: "SDL_GetWindowDisplayMode".}
#*
proc GetPixelFormat*(window: PWindow): uint32 {.importc: "SDL_GetWindowPixelFormat".}

#*
#   \brief Get the numeric ID of a window, for logging purposes.
# 
proc GetID*(window: PWindow): uint32 {.importc: "SDL_GetWindowID".}

#*
#   \brief Get the window flags.
# 
proc GetFlags*(window: PWindow): uint32 {.importc: "SDL_GetWindowFlags".}
#*
#   \brief Set the title of a window, in UTF-8 format.
#   
#   \sa SDL_GetWindowTitle()
# 
proc SetTitle*(window: PWindow; title: cstring) {.importc: "SDL_SetWindowTitle".}
#*
#   \brief Get the title of a window, in UTF-8 format.
#   
#   \sa SDL_SetWindowTitle()
# 
proc GetTitle*(window: PWindow): cstring {.importc: "SDL_GetWindowTitle".}
#*
#   \brief Set the icon for a window.
#   
#   \param icon The icon for the window.
# 
proc SetIcon*(window: PWindow; icon: PSurface) {.importc: "SDL_SetWindowIcon".}
#*
proc SetData*(window: PWindow; name: cstring; 
  userdata: pointer): pointer {.importc: "SDL_SetWindowData".}
#*
proc GetData*(window: PWindow; name: cstring): pointer {.importc: "SDL_GetWindowData".}
#*
proc SetPosition*(window: PWindow; x, y: cint) {.importc: "SDL_SetWindowPosition".}
proc GetPosition*(window: PWindow; x, y: var cint)  {.importc: "SDL_GetWindowPosition".}
#*
proc SetSize*(window: PWindow; w, h: cint)  {.importc: "SDL_SetWindowSize".}
proc GetSize*(window: PWindow; w, h: var cint) {.importc: "SDL_GetWindowSize".}

proc SetBordered*(window: PWindow; bordered: Bool32) {.importc: "SDL_SetWindowBordered".}


proc SetFullscreen*(window: PWindow; fullscreen: Bool32): SDL_Return {.importc: "SDL_SetWindowFullscreen".}
proc GetSurface*(window: PWindow): PSurface {.importc: "SDL_GetWindowSurface".}

proc UpdateSurface*(window: PWindow): SDL_Return  {.importc: "SDL_UpdateWindowSurface".}
proc UpdateSurfaceRects*(window: PWindow; rects: ptr TRect; 
  numrects: cint): SDL_Return  {.importc: "SDL_UpdateWindowSurfaceRects".}
#*
proc SetGrab*(window: PWindow; grabbed: Bool32) {.importc: "SDL_SetWindowGrab".}
proc GetGrab*(window: PWindow): Bool32 {.importc: "SDL_GetWindowGrab".}
proc SetBrightness*(window: PWindow; brightness: cfloat): SDL_Return {.importc: "SDL_SetWindowBrightness".}

proc GetBrightness*(window: PWindow): cfloat {.importc: "SDL_GetWindowBrightness".}

proc SetGammaRamp*(window: PWindow; 
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
proc GetGammaRamp*(window: PWindow; red: ptr uint16; 
                               green: ptr uint16; blue: ptr uint16): cint {.importc: "SDL_GetWindowGammaRamp".}


















{.push importc: "SDL_$1".}
proc Init*(flags: cint): SDL_Return {.discardable.}
#
#   This function initializes specific SDL subsystems
# 
proc InitSubSystem*(flags: uint32):cint

#
#   This function cleans up specific SDL subsystems
# 
proc QuitSubSystem*(flags: uint32)

#
#   This function returns a mask of the specified subsystems which have
#   previously been initialized.
# 
#   If \c flags is 0, it returns a mask of all initialized subsystems.
# 
proc WasInit*(flags: uint32): uint32

proc Quit*  

proc GetPlatform*(): cstring 

proc GetVersion*(ver: var SDL_Version) 
proc GetRevision*(): cstring 
proc GetRevisionNumber*(): cint 


proc GetNumRenderDrivers*(): cint 
proc GetRenderDriverInfo*(index: cint; info: var TRendererInfo): SDL_Return 
proc CreateWindowAndRenderer*(width, height: cint; window_flags: uint32; 
  window: var PWindow; renderer: var PRenderer): SDL_Return 

proc CreateRenderer*(window: PWindow; index: cint; flags: cint): PRenderer 
proc CreateSoftwareRenderer*(surface: PSurface): PRenderer 
proc GetRenderer*(window: PWindow): PRenderer 
proc GetRendererInfo*(renderer: PRenderer; info: PRendererInfo): cint 

proc CreateTexture*(renderer: PRenderer; format: uint32; 
  access, w, h: cint): PTexture 

proc CreateTextureFromSurface*(renderer: PRenderer; surface: PSurface): PTexture {.
  importc: "SDL_CreateTextureFromSurface".}
proc CreateTexture*(renderer: PRenderer; surface: PSurface): PTexture {.
  inline.} = renderer.createTextureFromSurface(surface) 

proc QueryTexture*(texture: PTexture; format: ptr uint32; 
  access, w, h: ptr cint): SDL_Return {.discardable.}

proc SetTextureColorMod*(texture: PTexture; r, g, b: uint8): SDL_Return {.
  importc: "SDL_SetTextureColorMod".}

proc GetTextureColorMod*(texture: PTexture; r, g, b: var uint8): SDL_Return {.
  importc: "SDL_GetTextureColorMod".}

proc SetTextureAlphaMod*(texture: PTexture; alpha: uint8): SDL_Return {.
  importc: "SDL_SetTextureAlphaMod", discardable.}

proc GetTextureAlphaMod*(texture: PTexture; alpha: var uint8): SDL_Return {.
  importc: "SDL_GetTextureAlphaMod", discardable.}
  
proc SetTextureBlendMode*(texture: PTexture; blendMode: TBlendMode): SDL_Return {.
  importc: "SDL_SetTextureBlendMode", discardable.}
  
proc GetTextureBlendMode*(texture: PTexture; 
  blendMode: var TBlendMode): SDL_Return {.importc: "SDL_GetTextureBlendMode", discardable.}

proc UpdateTexture*(texture: PTexture; rect: ptr TRect; pixels: pointer; 
  pitch: cint): SDL_Return {.importc: "SDL_UpdateTexture", discardable.}

proc LockTexture*(texture: PTexture; rect: ptr TRect; pixels: ptr pointer; 
  pitch: ptr cint): SDL_Return {.importc: "SDL_LockTexture", discardable.}

proc UnlockTexture*(texture: PTexture) {.importc: "SDL_UnlockTexture".}

proc RenderTargetSupported*(renderer: PRenderer): Bool32 {.
  importc: "SDL_RenderTargetSupported".}

proc SetRenderTarget*(renderer: PRenderer; texture: PTexture): SDL_Return {.discardable.}
#*
# 
proc GetRenderTarget*(renderer: PRenderer): PTexture 




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
{.push importc: "SDL_Render$1".}
proc SetViewport*(renderer: PRenderer; rect: ptr TRect): SDL_Return {.
  importc: "SDL_RenderSetViewport", discardable.}
proc GetViewport*(renderer: PRenderer; rect: var TRect) {.
  importc: "SDL_RenderGetViewport".}

proc SetScale*(renderer: PRenderer; scaleX, scaleY: cfloat): SDL_Return {.
  importc: "SDL_RenderSetScale", discardable.}
proc GetScale*(renderer: PRenderer; scaleX, scaleY: var cfloat) {.
  importc: "SDL_RenderGetScale".}
proc DrawPoint*(renderer: PRenderer; x, y: cint): SDL_Return {.
  importc: "SDL_RenderDrawPoint", discardable.}
#*
proc DrawPoints*(renderer: PRenderer; points: ptr TPoint; 
  count: cint): SDL_Return {.importc: "SDL_RenderDrawPoints", discardable.}

proc DrawLine*(renderer: PRenderer; 
  x1, y1, x2, y2: cint): SDL_Return {.
  importc: "SDL_RenderDrawLine", discardable.}
#*
proc DrawLines*(renderer: PRenderer; points: ptr TPoint; 
  count: cint): SDL_Return {.importc: "SDL_RenderDrawLines", discardable.}

proc DrawRect*(renderer: PRenderer; rect: var TRect): SDL_Return{.
  importc: "SDL_RenderDrawRect", discardable.}

proc DrawRects*(renderer: PRenderer; rects: ptr TRect; 
  count: cint): SDL_Return {.importc: "SDL_RenderDrawRects".}
proc FillRect*(renderer: PRenderer; rect: var TRect): SDL_Return {.
  importc: "SDL_RenderFillRect", discardable.}
proc FillRect*(renderer: PRenderer; rect: ptr TRect = nil): SDL_Return {.
  importc: "SDL_RenderFillRect", discardable.}
#*
proc FillRects*(renderer: PRenderer; rects: ptr TRect; 
  count: cint): SDL_Return {.importc: "SDL_RenderFillRects", discardable.}

proc Copy*(renderer: PRenderer; texture: PTexture; 
                     srcrect, dstrect: ptr TRect): SDL_Return {.
  importc: "SDL_RenderCopy", discardable.}

proc CopyEx*(renderer: PRenderer; texture: PTexture; 
             srcrect, dstrect: var TRect; angle: cdouble; center: ptr TPoint; 
             flip: TRendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyEx", discardable.}
proc CopyEx*(renderer: PRenderer; texture: PTexture;
             srcRect, dstRect: ptr TRect; angle: cdouble; center: ptr TPoint;
             flip: TRendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyEx", discardable.}

proc Clear*(renderer: PRenderer): cint {.
  importc: "SDL_RenderClear", discardable.}

proc ReadPixels*(renderer: PRenderer; rect: var TRect; format: cint; 
  pixels: pointer; pitch: cint): cint {.importc: "SDL_RenderReadPixels".}
proc Present*(renderer: PRenderer) {.importc: "SDL_RenderPresent".}

{.pop.}


{.push importc: "SDL_$1".}
proc GL_BindTexture*(texture: PTexture; texw, texh: var cfloat): cint 
proc GL_UnbindTexture*(texture: PTexture)

proc CreateRGBSurface*(flags: cint; width, height, depth: cint; 
  Rmask, Gmask, BMask, Amask: uint32): PSurface 
proc CreateRGBSurfaceFrom*(pixels: pointer; width, height, depth, pitch: cint;
  Rmask, Gmask, Bmask, Amask: uint32): PSurface 

proc FreeSurface*(surface: PSurface) 

proc SetSurfacePalette*(surface: PSurface; palette: ptr TPalette): cint {.
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
proc LockSurface*(surface: PSurface): cint {.importc: "SDL_LockSurface".}
#* \sa SDL_LockSurface() 
proc UnlockSurface*(surface: PSurface) {.importc: "SDL_UnlockSurface".}
#*
#   Load a surface from a seekable SDL data stream (memory or file).
#   
#   If \c freesrc is non-zero, the stream will be closed after being read.
#   
#   The new surface should be freed with SDL_FreeSurface().
#   
#   \return the new surface, or NULL if there was an error.
# 
proc LoadBMP_RW*(src: PRWops; freesrc: cint): PSurface {.
  importc: "SDL_LoadBMP_RW".}



proc RWFromFile*(file: cstring; mode: cstring): PRWops {.importc: "SDL_RWFromFile".}
proc RWFromFP*(fp: TFILE; autoclose: Bool32): PRWops {.importc: "SDL_RWFromFP".}
proc RWFromMem*(mem: pointer; size: cint): PRWops {.importc: "SDL_RWFromMem".}
proc RWFromConstMem*(mem: pointer; size: cint): PRWops {.importc: "SDL_RWFromConstMem".}

#*
#   Load a surface from a file.
#   
#   Convenience macro.
# 
#*
proc SaveBMP_RW*(surface: PSurface; dst: PRWops; 
                     freedst: cint): SDL_Return {.importc: "SDL_SaveBMP_RW".}

proc SetSurfaceRLE*(surface: PSurface; flag: cint): cint {.
  importc:"SDL_SetSurfaceRLE".}
proc SetColorKey*(surface: PSurface; flag: cint; key: uint32): cint {.
  importc: "SDL_SetColorKey".}

proc GetColorKey*(surface: PSurface; key: var uint32): cint {.
  importc: "SDL_GetColorKey".}
proc SetSurfaceColorMod*(surface: PSurface; r, g, b: uint8): cint {.
  importc: "SDL_SetSurfaceColorMod".}

proc GetSurfaceColorMod*(surface: PSurface; r, g, b: var uint8): cint {.
  importc: "SDL_GetSurfaceColorMod".}

proc SetSurfaceAlphaMod*(surface: PSurface; alpha: uint8): cint {.
  importc: "SDL_SetSurfaceAlphaMod".}
proc GetSurfaceAlphaMod*(surface: PSurface; alpha: var uint8): cint {.
  importc: "SDL_GetSurfaceAlphaMod".}

proc SetSurfaceBlendMode*(surface: PSurface; blendMode: TBlendMode): cint {.
  importc: "SDL_SetSurfaceBlendMode".}
proc GetSurfaceBlendMode*(surface: PSurface; blendMode: ptr TBlendMode): cint {.
  importc: "SDL_GetSurfaceBlendMode".}

proc SetClipRect*(surface: PSurface; rect: ptr TRect): Bool32 {.
  importc: "SDL_SetClipRect".}
proc GetClipRect*(surface: PSurface; rect: ptr TRect) {.
  importc: "SDL_GetClipRect".}

proc ConvertSurface*(src: PSurface; fmt: ptr TPixelFormat; 
  flags: cint): PSurface {.importc: "SDL_ConvertSurface".}
proc ConvertSurfaceFormat*(src: PSurface; pixel_format, 
  flags: uint32): PSurface {.importc: "SDL_ConvertSurfaceFormat".}

proc ConvertPixels*(width, height: cint; src_format: uint32; src: pointer; 
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
proc FillRect*(dst: PSurface; rect: ptr TRect; color: uint32): SDL_Return {.
  importc: "SDL_FillRect", discardable.}
proc FillRects*(dst: PSurface; rects: ptr TRect; count: cint; 
                    color: uint32): cint {.importc: "SDL_FillRects".}

proc UpperBlit*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.importc: "SDL_UpperBlit".}

proc LowerBlit*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.importc: "SDL_LowerBlit".}

proc SoftStretch*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.importc: "SDL_SoftStretch".}


proc UpperBlitScaled*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.importc: "SDL_UpperBlitScaled".}
proc LowerBlitScaled*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.importc: "SDL_LowerBlitScaled".} 



proc ReadU8*(src: PRWops): uint8 {.importc: "SDL_ReadU8".}
proc ReadLE16*(src: PRWops): uint16 {.importc: "SDL_ReadLE16".}
proc ReadBE16*(src: PRWops): uint16 {.importc: "SDL_ReadBE16".}
proc ReadLE32*(src: PRWops): uint32 {.importc: "SDL_ReadLE32".}
proc ReadBE32*(src: PRWops): uint32 {.importc: "SDL_ReadBE32".}
proc ReadLE64*(src: PRWops): uint64 {.importc: "SDL_ReadLE64".}
proc ReadBE64*(src: PRWops): uint64 {.importc: "SDL_ReadBE64".}
proc WriteU8*(dst: PRWops; value: uint8): csize {.importc: "SDL_WriteU8".}
proc WriteLE16*(dst: PRWops; value: uint16): csize {.importc: "SDL_WriteLE16".}
proc WriteBE16*(dst: PRWops; value: uint16): csize {.importc: "SDL_WriteBE16".}
proc WriteLE32*(dst: PRWops; value: uint32): csize {.importc: "SDL_WriteLE32".}
proc WriteBE32*(dst: PRWops; value: uint32): csize {.importc: "SDL_WriteBE32".}
proc WriteLE64*(dst: PRWops; value: uint64): csize {.importc: "SDL_WriteLE64".}
proc WriteBE64*(dst: PRWops; value: uint64): csize {.importc: "SDL_WriteBE64".}

proc ShowMessageBox*(messageboxdata: ptr TMessageBoxData; 
  buttonid: var cint): cint {.importc: "SDL_ShowMessageBox".}

proc ShowSimpleMessageBox*(flags: uint32; title, message: cstring; 
  window: PWindow): cint {.importc: "SDL_ShowSimpleMessageBox".}
  #   \return 0 on success, -1 on error





proc GetNumVideoDrivers*(): cint {.importc: "SDL_GetNumVideoDrivers".}
proc GetVideoDriver*(index: cint): cstring {.importc: "SDL_GetVideoDriver".}
proc VideoInit*(driver_name: cstring): SDL_Return {.importc: "SDL_VideoInit".}
proc VideoQuit*() {.importc: "SDL_VideoQuit".}
proc GetCurrentVideoDriver*(): cstring {.importc: "SDL_GetCurrentVideoDriver".}
proc GetNumVideoDisplays*(): cint {.importc: "SDL_GetNumVideoDisplays".}

proc GetDisplayBounds*(displayIndex: cint; rect: var TRect): SDL_Return {.
  importc: "SDL_GetDisplayBounds".}
proc GetNumDisplayModes*(displayIndex: cint): cint {.importc: "SDL_GetNumDisplayModes".}
#*
proc GetDisplayMode*(displayIndex: cint; modeIndex: cint; 
  mode: var TDisplayMode): SDL_Return {.importc: "SDL_GetDisplayMode".}
                         
proc GetDesktopDisplayMode*(displayIndex: cint; 
  mode: var TDisplayMode): SDL_Return {.importc: "SDL_GetDesktopDisplayMode".}
proc GetCurrentDisplayMode*(displayIndex: cint; 
  mode: var TDisplayMode): SDL_Return {.importc: "SDL_GetCurrentDisplayMode".}

proc GetClosestDisplayMode*(displayIndex: cint; mode: ptr TDisplayMode; 
                                closest: ptr TDisplayMode): ptr TDisplayMode {.importc: "SDL_GetClosestDisplayMode".}
#*
#*
proc CreateWindow*(title: cstring; x, y, w, h: cint; 
                       flags: uint32): PWindow  {.importc: "SDL_CreateWindow".}
#*
proc CreateWindowFrom*(data: pointer): PWindow {.importc: "SDL_CreateWindowFrom".}

#*
#   \brief Get a window from a stored ID, or NULL if it doesn't exist.
# 
proc GetWindowFromID*(id: uint32): PWindow {.importc: "SDL_GetWindowFromID".}




#
proc ShowWindow*(window: PWindow) {.importc: "SDL_ShowWindow".}
proc HideWindow*(window: PWindow) {.importc: "SDL_HideWindow".}
#*
proc RaiseWindow*(window: PWindow) {.importc: "SDL_RaiseWindow".}
proc MaximizeWindow*(window: PWindow) {.importc: "SDL_MaximizeWindow".}
proc MinimizeWindow*(window: PWindow) {.importc: "SDL_MinimizeWindow".}
#*
# 
proc RestoreWindow*(window: PWindow) {.importc: "SDL_RestoreWindow".}
                               
proc DestroyWindow*(window: PWindow) 

proc IsScreenSaverEnabled*(): Bool32 {.importc: "SDL_IsScreenSaverEnabled".}
proc EnableScreenSaver*() {.importc: "SDL_EnableScreenSaver".}
proc DisableScreenSaver*() {.importc: "SDL_DisableScreenSaver".}


proc GetTicks*(): uint32 {.importc: "SDL_GetTicks".}
proc GetPerformanceCounter*(): uint64 {.importc: "SDL_GetPerformanceCounter".}
proc GetPerformanceFrequency*(): uint64 {.importc: "SDL_GetPerformanceFrequency".}
proc Delay*(ms: uint32) {.importc: "SDL_Delay".}
#*
#  \brief Add a new timer to the pool of timers already running.
# 
#  \return A timer ID, or NULL when an error occurs.
# 
proc AddTimer*(interval: uint32; callback: TTimerCallback; 
      param: pointer): TTimerID {.importc: "SDL_AddTimer".}
#*
#  \brief Remove a timer knowing its ID.
# 
#  \return A boolean value indicating success or failure.
# 
#  \warning It is not safe to remove a timer multiple times.
# 
proc RemoveTimer*(id: TTimerID): Bool32 {.importc: "SDL_RemoveTimer".}


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
{.push importc: "SDL_$1".}
#extern DECLSPEC int SDLCALL SDL_GL_LoadLibrary(const char *path);
proc GL_LoadLibrary* (path: cstring): SDL_Return {.discardable.}
#extern DECLSPEC void *SDLCALL SDL_GL_GetProcAddress(const char *proc);
proc GL_GetProcAddress* (procedure: cstring): pointer 
#extern DECLSPEC void SDLCALL SDL_GL_UnloadLibrary(void);
proc GL_UnloadLibrary* 
#extern DECLSPEC SDL_bool SDLCALL SDL_GL_ExtensionSupported(const char
#                                                          *extension);
proc GL_ExtensionSupported* (extension: cstring): bool

#extern DECLSPEC int SDLCALL SDL_GL_SetAttribute(SDL_GLattr attr, int value);
proc GL_SetAttribute* (attr: GLattr; value: cint): cint
#extern DECLSPEC int SDLCALL SDL_GL_GetAttribute(SDL_GLattr attr, int *value);
proc GL_GetAttribute* (attr: GLattr; value: var cint): cint


proc GL_CreateContext*(window: PWindow): PGLContext 
  ## Create an OpenGL context for use with an OpenGL window, and make it current.
proc GL_MakeCurrent* (window: PWindow; context: PGLContext): cint

proc GL_GetCurrentWindow* : PWindow
proc GL_GetCurrentContext*: PGLContext

proc GL_GetDrawableSize* (window: PWindow; w,h: var cint)

proc GL_SetSwapInterval* (interval: cint): cint
proc GL_GetSwapInterval* : cint

proc GL_SwapWindow*(window: PWindow) 
  ## Swap the OpenGL buffers for a window, if double-buffering is supported.

proc GL_DeleteContext* (context: PGLContext)

{.pop.}

##SDL_keyboard.h:
proc GetKeyboardFocus*: PWindow {.importc: "SDL_GetKeyboardFocus".}
  #Get the window which currently has keyboard focus.
proc GetKeyboardState*(numkeys: ptr int = nil): ptr array[0 .. SDL_NUM_SCANCODES.int, uint8] {.importc: "SDL_GetKeyboardState".}
  #Get the snapshot of the current state of the keyboard
proc GetModState*: TKeymod {.importc: "SDL_GetModState".}
  #Get the current key modifier state for the keyboard
proc SetModState*(state: TKeymod) {.importc: "SDL_SetModState".}
  #Set the current key modifier state for the keyboard
proc GetKeyFromScancode*(scancode: TScanCode): cint {.importc: "SDL_GetKeyFromScancode".}
  #Get the key code corresponding to the given scancode according to the current keyboard layout
proc GetScancodeFromKey*(key: cint): TScanCode {.importc: "SDL_GetScancodeFromKey".}
  #Get the scancode corresponding to the given key code according to the current keyboard layout
proc GetScancodeName*(scancode: TScanCode): cstring {.importc: "SDL_GetScancodeName".}
  #Get a human-readable name for a scancode
proc GetScancodeFromName*(name: cstring): TScanCode {.importc: "SDL_GetScancodeFromName".}
  #Get a scancode from a human-readable name
proc GetKeyName*(key: cint): cstring 
  #Get a human-readable name for a key
proc GetKeyFromName*(name: cstring): cint 
  #Get a key code from a human-readable name
proc StartTextInput* 
  #Start accepting Unicode text input events
proc IsTextInputActive*: bool 
proc StopTextInput* 
proc SetTextInputRect*(rect: ptr TRect) 
proc HasScreenKeyboardSupport*: bool {.importc: "SDL_HasScreenKeyboardSupport".}
proc IsScreenKeyboardShown*(window: PWindow): bool {.importc: "SDL_IsScreenKeyboardShown".}



proc GetMouseFocus*(): PWindow {.importc: "SDL_GetMouseFocus".}
#*
#   \brief Retrieve the current state of the mouse.
#   
#   The current button state is returned as a button bitmask, which can
#   be tested using the SDL_BUTTON(X) macros, and x and y are set to the
#   mouse cursor position relative to the focus window for the currently
#   selected mouse.  You can pass NULL for either x or y.
# 
proc GetMouseState*(x, y: var cint): uint8 {.importc: "SDL_GetMouseState", discardable.}
proc GetMouseState*(x, y: ptr cint): uint8 {.importc: "SDL_GetMouseState", discardable.}
#*
proc GetRelativeMouseState*(x, y: var cint): uint8 {.
  importc: "SDL_GetRelativeMouseState".}
#*
proc WarpMouseInWindow*(window: PWindow; x, y: cint)  {.
  importc: "SDL_WarpMouseInWindow".}
#*
proc SetRelativeMouseMode*(enabled: Bool32): SDL_Return  {.
  importc: "SDL_SetRelativeMouseMode".}
#*
proc GetRelativeMouseMode*(): Bool32 {.importc: "SDL_GetRelativeMouseMode".}
#*
proc CreateCursor*(data, mask: ptr uint8; 
  w, h, hot_x, hot_y: cint): PCursor {.importc: "SDL_CreateCursor".}
#*
proc CreateColorCursor*(surface: PSurface; hot_x, hot_y: cint): PCursor {.
  importc: "SDL_CreateColorCursor".}
proc SetCursor*(cursor: PCursor) {.importc: "SDL_SetCursor".}
proc GetCursor*(): PCursor {.importc: "SDL_GetCursor".}
proc FreeCursor* (cursor: PCursor)
proc ShowCursor* (toggle: bool): Bool32 {.importc: "SDL_ShowCursor", discardable.}


# Function prototypes 
#*
#   Pumps the event loop, gathering events from the input devices.
#   
#   This function updates the event queue and internal input device state.
#   
#   This should only be run in the thread that sets the video mode.
# 
proc PumpEvents*() {.importc: "SDL_PumpEvents".}

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
proc PeepEvents*(events: ptr TEvent; numevents: cint; action: TEventaction; 
  minType: uint32; maxType: uint32): cint {.importc: "SDL_PeepEvents".}
#@}
#*
#   Checks to see if certain event types are in the event queue.
# 
proc HasEvent*(kind: uint32): Bool32 {.importc: "SDL_HasEvent".}
proc HasEvents*(minType: uint32; maxType: uint32): Bool32 {.importc: "SDL_HasEvents".}
proc FlushEvent*(kind: uint32) {.importc: "SDL_FlushEvent".}
proc FlushEvents*(minType: uint32; maxType: uint32) {.importc: "SDL_FlushEvents".}

proc PollEvent*(event: var TEvent): Bool32 {.importc: "SDL_PollEvent".}
proc WaitEvent*(event: var TEvent): Bool32 {.importc: "SDL_WaitEvent".}
proc WaitEventTimeout*(event: var TEvent; timeout: cint): Bool32 {.importc: "SDL_WaitEventTimeout".}
#*
#   \brief Add an event to the event queue.
#   
#   \return 1 on success, 0 if the event was filtered, or -1 if the event queue 
#           was full or there was some other error.
# 
proc PushEvent*(event: ptr TEvent): cint {.importc: "SDL_PushEvent".}

#*
proc SetEventFilter*(filter: TEventFilter; userdata: pointer) {.importc: "SDL_SetEventFilter".}
#*
#   Return the current event filter - can be used to "chain" filters.
#   If there is no event filter set, this function returns SDL_FALSE.
# 
proc GetEventFilter*(filter: var TEventFilter; userdata: var pointer): Bool32 {.importc: "SDL_GetEventFilter".}
#*
#   Add a function which is called when an event is added to the queue.
# 
proc AddEventWatch*(filter: TEventFilter; userdata: pointer) {.importc: "SDL_AddEventWatch".}
#*
#   Remove an event watch function added with SDL_AddEventWatch()
# 
proc DelEventWatch*(filter: TEventFilter; userdata: pointer) {.importc: "SDL_DelEventWatch".}
#*
#   Run the filter function on the current event queue, removing any
#   events for which the filter returns 0.
# 
proc FilterEvents*(filter: TEventFilter; userdata: pointer) {.importc: "SDL_FilterEvents".}
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
proc EventState*(kind: TEventType; state: cint): uint8 {.importc: "SDL_EventState".}
#@}
#
#/**
#   This function allocates a set of user-defined events, and returns
#   the beginning event number for that set of events.
# 
#   If there aren't enough user-defined events left, this function
#   returns (uint32)-1
# 
proc RegisterEvents*(numevents: cint): uint32 {.importc: "SDL_RegisterEvents".}


proc SetError*(fmt: cstring) {.varargs, importc: "SDL_SetError".}
proc GetError*(): cstring {.importc: "SDL_GetError".}
proc ClearError*() {.importc: "SDL_ClearError".}

#extern DECLSPEC const char* SDLCALL SDL_GetPixelFormatName(uint32 format);
proc GetPixelFormatName* (format: uint32): cstring 
  ## Get the human readable name of a pixel format

#extern DECLSPEC SDL_bool SDLCALL SDL_PixelFormatEnumToMasks(uint32 format,
#                                                            int *bpp,
#                                                            uint32 * Rmask,
#                                                            uint32 * Gmask,
#                                                            uint32 * Bmask,
#                                                            uint32 * Amask);
proc PixelFormatEnumToMasks* (format: uint32; bpp: var cint;
  Rmask, Gmask, Bmask, Amask: var uint32): bool
  ##Convert one of the enumerated pixel formats to a bpp and RGBA masks.
  ##Returns TRUE or FALSE if the conversion wasn't possible.


#extern DECLSPEC uint32 SDLCALL SDL_MasksToPixelFormatEnum(int bpp,
#                                                          uint32 Rmask,
#                                                          uint32 Gmask,
#                                                          uint32 Bmask,
#                                                          uint32 Amask);
proc MasksToPixelFormatEnum* (bpp: cint; Rmask, Gmask, Bmask, Amask: uint32): uint32
  ##Convert a bpp and RGBA masks to an enumerated pixel format.
  ##The pixel format, or ::SDL_PIXELFORMAT_UNKNOWN if the conversion wasn't possible.

#extern DECLSPEC SDL_PixelFormat * SDLCALL SDL_AllocFormat(uint32 pixel_format);
proc AllocFormat* (pixelFormat: uint32): ptr TPixelFormat
##Create an SDL_PixelFormat structure from a pixel format enum.

#extern DECLSPEC void SDLCALL SDL_FreeFormat(SDL_PixelFormat *format);
proc FreeFormat* (format: ptr TPixelFormat)
  ##Free an SDL_PixelFormat structure.

#extern DECLSPEC SDL_Palette *SDLCALL SDL_AllocPalette(int ncolors);
proc AllocPalette* (numColors: cint): ptr TPalette
  ##Create a palette structure with the specified number of color entries.
  ##Returns A new palette, or NULL if there wasn't enough memory.
  ##Note: The palette entries are initialized to white.

#extern DECLSPEC int SDLCALL SDL_SetPixelFormatPalette(SDL_PixelFormat * format,
#                                                      SDL_Palette *palette);
proc SetPixelFormatPalette* (format: ptr TPixelFormat; palette: ptr TPalette): cint
  ##Set the palette for a pixel format structure.

#extern DECLSPEC int SDLCALL SDL_SetPaletteColors(SDL_Palette * palette,
#                                                 const SDL_Color * colors,
#                                                 int firstcolor, int ncolors);
proc SetPaletteColors* (palette: ptr TPalette; colors: ptr TColor; first, numColors: cint): SDL_Return {.discardable.}
  ## Set a range of colors in a palette.
#extern DECLSPEC void SDLCALL SDL_FreePalette(SDL_Palette * palette);
proc FreePalette* (palette: ptr TPalette)
  ##Free a palette created with SDL_AllocPalette().

#extern DECLSPEC uint32 SDLCALL SDL_MapRGB(const SDL_PixelFormat * format,
#                                          uint8 r, uint8 g, uint8 b);
proc MapRGB* (format: ptr TPixelFormat; r,g,b: uint8): uint32
  ##Maps an RGB triple to an opaque pixel value for a given pixel format.

#extern DECLSPEC uint32 SDLCALL SDL_MapRGBA(const SDL_PixelFormat * format,
#                                           uint8 r, uint8 g, uint8 b,
#                                           uint8 a);
proc MapRGBA* (format: ptr TPixelFormat; r,g,b,a: uint8): uint32
  ##Maps an RGBA quadruple to a pixel value for a given pixel format.

#extern DECLSPEC void SDLCALL SDL_GetRGB(uint32 pixel,
#                                        const SDL_PixelFormat * format,
#                                        uint8 * r, uint8 * g, uint8 * b);
proc GetRGB* (pixel: uint32; format: ptr TPixelFormat; r,g,b: var uint8)
  ##Get the RGB components from a pixel of the specified format.

#extern DECLSPEC void SDLCALL SDL_GetRGBA(uint32 pixel,
#                                         const SDL_PixelFormat * format,
#                                         uint8 * r, uint8 * g, uint8 * b,
#                                         uint8 * a);
proc GetRGBA* (pixel: uint32; format: ptr TPixelFormat; r,g,b,a: var uint8)
  ##Get the RGBA components from a pixel of the specified format.

#extern DECLSPEC void SDLCALL SDL_CalculateGammaRamp(float gamma, uint16 * ramp);
proc CalculateGammaRamp* (gamma: cfloat; ramp: ptr uint16)
  ##Calculate a 256 entry gamma ramp for a gamma value.


{.pop.}
{.pop.}

const
  SDL_QUERY* = -1
  SDL_IGNORE* = 0
  SDL_DISABLE* = 0
  SDL_ENABLE* = 1

##define SDL_GetEventState(type) SDL_EventState(type, SDL_QUERY)
proc GetEventState*(kind: TEventType): uint8 {.inline.} = EventState(kind, SDL_QUERY)

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

proc CreateRGBSurface* (width, height, depth: int32): PSurface {.inline.} = sdl2.CreateRGBSurface(
  0, width, height, depth, 0,0,0,0)
proc GetSize*(window: PWindow): TPoint {.inline.} = GetSize(window, result.x, result.y)

proc DestroyTexture*(texture: PTexture) {.inline.} = destroy(texture)
#proc destroy* (texture: PTexture) {.inline.} = texture.destroyTexture
proc DestroyRenderer*(renderer: PRenderer) {.inline.} = destroy(renderer)
#proc destroy* (renderer: PRenderer) {.inline.} = renderer.destroyRenderer

proc destroy* (window: PWindow) {.inline.} = window.DestroyWindow
proc destroy* (cursor: PCursor) {.inline.} = cursor.FreeCursor
proc destroy* (surface: PSurface) {.inline.} = surface.FreeSurface
proc destroy* (format: ptr TPixelFormat) {.inline.} = format.FreeFormat
proc destroy* (palette: ptr TPalette) {.inline.} = palette.FreePalette

proc BlitSurface*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.inline, discardable.} = UpperBlit(src, srcrect, dst, dstrect)
proc BlitScaled*(src: PSurface; srcrect: ptr TRect; dst: PSurface; 
  dstrect: ptr TRect): SDL_Return {.inline, discardable.} = UpperBlitScaled(src, srcrect, dst, dstrect) 

proc SDL_Init*(flags: cint): SDL_Return {.inline, deprecated.} = sdl2.Init(flags)
proc SDL_Quit*() {.inline,deprecated.} = sdl2.Quit()

#/#define SDL_LoadBMP(file)	SDL_LoadBMP_RW(SDL_RWFromFile(file, "rb"), 1)
proc LoadBMP*(file: string): PSurface {.inline.} = LoadBMP_RW(RWFromFile(cstring(file), "rb"), 1)
##define SDL_SaveBMP(surface, file) \
#  SDL_SaveBMP_RW(surface, SDL_RWFromFile(file, "wb"), 1)
proc SaveBMP*(surface: PSurface; file: string): SDL_Return {.
  inline, discardable.} = SaveBMP_RW(surface, RWFromFile(file, "wb"), 1)

proc Color*(r, g, b, a: range[0..255]): TColor = (r.uint8, g.uint8, b.uint8, a.uint8)

proc Rect*(x, y: cint; w = cint(0), h = cint(0)): TRect =
  result.x = x
  result.y = y
  result.w = w
  result.h = h

proc Point*[T: TNumber](x, y: T): TPoint = (x.cint, y.cint)

proc Contains*(some: TRect; point: TPoint): bool = 
  return point.x >= some.x and point.x <= (some.x + some.w) and
          point.y >= some.y and point.y <= (some.y + some.h)

proc SetHint*(name: cstring, value: cstring): bool {.
  importc: "SDL_SetHint".}

proc SetHintWithPriority*(name: cstring, value: cstring, priority: cint): bool {.
  importc: "SDL_SetHintWithPriority".}

proc GetHint*(name: cstring): cstring {.
  importc: "SDL_GetHint".}

