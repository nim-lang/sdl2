## The Simple DirectMedia Layer Library.

import macros

import strutils
export strutils.`%`


# Add for people running sdl 2.0.0
{.push warning[user]: off}
when defined(SDL_Static):
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."

else:
  when defined(windows):
    const LibName* = "SDL2.dll"
  elif defined(macosx):
    const LibName* = "libSDL2.dylib"
  elif defined(openbsd):
    const LibName* = "libSDL2.so.0.6"
  elif defined(haiku):
    const LibName* = "libSDL2-2.0.so.0"
  else:
    const LibName* = "libSDL2(|-2.0).so(|.0)"

{.pop.}

include sdl2/private/keycodes

const
  SDL_TEXTEDITINGEVENT_TEXT_SIZE* = 32
  SDL_TEXTINPUTEVENT_TEXT_SIZE* = 32
type

  WindowEventID* {.size: sizeof(byte).} = enum
    ## Event subtype for window events
    WindowEvent_None = 0, ## Never used
    WindowEvent_Shown, ## Window has been shown
    WindowEvent_Hidden, ## Window has been hidden
    WindowEvent_Exposed, ## Window has been exposed and should be redrawn
    WindowEvent_Moved, ## Window has been moved to data1, data2
    WindowEvent_Resized, ## Window has been resized to data1*data2
    WindowEvent_SizeChanged,
      ## The window size has changed, either as a result of an API call or
      ## through the system or user changing the window size.
    WindowEvent_Minimized, ## Window has been minimized
    WindowEvent_Maximized, ## Window has been maximized
    WindowEvent_Restored,
      ## Window has been restored to normal size and position
    WindowEvent_Enter, ## Window has gained mouse focus
    WindowEvent_Leave, ## Window has lost mouse focus
    WindowEvent_FocusGained, ## Window has gained keyboard focus
    WindowEvent_FocusLost, ## Window has lost keyboard focus
    WindowEvent_Close,
    WindowEvent_TakeFocus,
      ## The window manager requests that the window be closed
    WindowEvent_HitTest
      ## Window had a hit test that wasn't `SDL_HITTEST_NORMAL`.

  EventType* {.size: sizeof(uint32).} = enum
    ## The types of events that can be delivered.

    # Application events
    QuitEvent = 0x100, ## User-requested quit
    AppTerminating,
      ## The application is being terminated by the OS
      ## Called on iOS in `applicationWillTerminate()`
      ## Called on Android in `onDestroy()`
    AppLowMemory,
      ## The application is low on memory, free memory if possible.
      ## Called on iOS in `applicationDidReceiveMemoryWarning()`
      ## Called on Android in `onLowMemory()`
    AppWillEnterBackground,
      ## The application is about to enter the background
      ## Called on iOS in `applicationWillResignActive()`
      ## Called on Android in `onPause()`
    AppDidEnterBackground,
      ## The application did enter the background
      ## and may not get CPU for some time
      ## Called on iOS in `applicationDidEnterBackground()`
      ## Called on Android in `onPause()`
    AppWillEnterForeground,
      ## The application is about to enter the foreground
      ## Called on iOS in `applicationWillEnterForeground()`
      ## Called on Android in `onResume()`
    AppDidEnterForeground,
      ## The application is now interactive
      ## Called on iOS in `applicationDidBecomeActive()`
      ## Called on Android in `onResume()`

    # Display events
    DisplayEvent = 0x150, ## Display state change

    # Window events
    WindowEvent = 0x200, ## Window state change
    SysWMEvent, ## System specific event

    # Keyboard events
    KeyDown = 0x300, ## Key pressed
    KeyUp, ## Key released
    TextEditing, ## Keyboard text editing (composition)
    TextInput, ## Keyboard text input
    KeymapChanged,
      ## Keymap changed due to a system event such as
      ## an input language or keyboard layout change.

    # Mouse events
    MouseMotion = 0x400, ## Mouse moved
    MouseButtonDown, ## Mouse button pressed
    MouseButtonUp, ## Mouse button released
    MouseWheel, ## Mouse wheel motion

    # Joysticks events
    JoyAxisMotion = 0x600, ## Joystick axis motion
    JoyBallMotion, ## Joystick trackball motion
    JoyHatMotion, ## Joystick hat position change
    JoyButtonDown, ## Joystick button pressed
    JoyButtonUp, ## Joystick button released
    JoyDeviceAdded, ## A new joystick has been inserted into the system
    JoyDeviceRemoved, ## An opened joystick has been removed

    # Game controller events
    ControllerAxisMotion = 0x650, ## Game controller axis motion
    ControllerButtonDown, ## Game controller button pressed
    ControllerButtonUp, ## Game controller button released
    ControllerDeviceAdded, ## A new Game controller has been inserted into the system
    ControllerDeviceRemoved, ## An opened Game controller has been removed
    ControllerDeviceRemapped, ## The controller mapping was updated

    # Touch events
    FingerDown = 0x700,
    FingerUp,
    FingerMotion,

    # Gesture events
    DollarGesture = 0x800,
    DollarRecord,
    MultiGesture,

    # Clipboard events
    ClipboardUpdate = 0x900, ## The clipboard changed

    # Drag and drop events
    DropFile = 0x1000, ## The system requests a file open
    DropText, ## Text/plain drag-and-drop event
    DropBegin, ## A new set of drops is beginning (`nil` filename)
    DropComplete, ## Current set of drops is now complete (`nil` filename)

    # Audio hotplug events
    AudioDeviceAdded = 0x1100, ## A new audio device is available
    AudioDeviceRemoved = 0x1101, ## An audio device has been removed

    # Sensor events
    SensorUpdate = 0x1200, ## A sensor was updated

    # Render events
    RenderTargetsReset = 0x2000,
      ## The render targets have been reset and their contents need to be updated
    RenderDeviceReset,
      ## The device has beed reset and all textures need to be recreated
    UserEvent = 0x8000,
      ## Events `USEREVENT` through `LASTEVENT` are for your use,
      ## and should be allocated with `registerEvents()`
    UserEvent1,
    UserEvent2,
    UserEvent3,
    UserEvent4,
    UserEvent5,
    LastEvent = 0xFFFF, ## This last event is only for bounding internal arrays


  Event* = object
    ## General event structure
    kind*: EventType ## Event type, shared with all events
    padding: array[56-sizeof(EventType), byte]

  QuitEventPtr* = ptr QuitEventObj
  QuitEventObj* = object
    ## The "quit requested" event
    kind*: EventType ## `QuitEvent`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`

  WindowEventPtr* = ptr WindowEventObj
  WindowEventObj* = object
    ## Window state change event data (`event.window.*`)
    kind*: EventType ## `WindowEvent`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The associated window
    event*: WindowEventID ## WindowEvent ID
    pad1,pad2,pad3: uint8
    data1*, data2*: cint ## event dependent data
    pad*: array[56-24, byte]

  KeyboardEventPtr* = ptr KeyboardEventObj
  KeyboardEventObj* = object
    ## Keyboard button event structure (`event.key.*`)
    kind*: EventType ## `KEYDOWN` or `KEYUP`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The window with keyboard focus, if any
    state*: uint8 ## `PRESSED` or `RELEASED`
    repeat*: bool ## Non-zero if this is a key repeat
    keysym*: KeySym ## The key that was pressed or released
    pad*: array[24, byte]

  TextEditingEventPtr* = ptr TextEditingEventObj
  TextEditingEventObj* = object
    ## Keyboard text editing event structure (`event.edit.*`)
    kind*: EventType ## `TEXTEDITING`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The window with keyboard focus, if any
    text*: array[SDL_TEXTEDITINGEVENT_TEXT_SIZE, char] ## The editing text
    start*: int32 ## The start cursor of selected editing text
    length*: int32 ## The length of selected editing text
    pad*: array[8, byte]

  TextInputEventPtr* = ptr TextInputEventObj
  TextInputEventObj* = object
    ## Keyboard text input event structure (`event.text.*`)
    kind*: EventType ## `TEXTINPUT`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The window with keyboard focus, if any
    text*: array[SDL_TEXTINPUTEVENT_TEXT_SIZE, char] ## The input text
    pad*: array[24, byte]

  MouseMotionEventPtr* = ptr MouseMotionEventObj
  MouseMotionEventObj* = object
    ## Mouse motion event structure (`event.motion.*`)
    kind*: EventType ## `MOUSEMOTION`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The window with mouse focus, if any
    which*: uint32 ## The mouse instance id, or `SDL_TOUCH_MOUSEID`
    state*: uint32 ## The current button state
    x*: int32 ## X coordinate, relative to window
    y*: int32 ## Y coordinate, relative to window
    xrel*: int32 ## The relative motion in the X direction
    yrel*: int32 ## The relative motion in the Y direction
    pad*: array[20, byte]

  MouseButtonEventPtr* = ptr MouseButtonEventObj
  MouseButtonEventObj* = object
    ## Mouse button event structure (`event.button.*`)
    kind*: EventType ## `MOUSEBUTTONDOWN` or `MOUSEBUTTONUP`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The window with mouse focus, if any
    which*: uint32 ## The mouse instance id, or `SDL_TOUCH_MOUSEID`
    button*: uint8 ## The mouse button index
    state*: uint8 ## `PRESSED` or `RELEASED`
    clicks*: uint8 ## `1` for single-click, `2` for double-click, etc.
    x*: cint ## X coordinate, relative to window
    y*: cint ## Y coordinate, relative to window
    pad*: array[28, byte]

  MouseWheelEventPtr* = ptr MouseWheelEventObj
  MouseWheelEventObj* = object
    ## Mouse wheel event structure (`event.wheel.*`)
    kind*: EventType ## `MOUSEWHEEL`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The window with mouse focus, if any
    which*: uint32 ## The mouse instance id, or `SDL_TOUCH_MOUSEID`
    x*: cint
      ## The amount scrolled horizontally,
      ## positive to the right and negative to the left
    y*: cint
      ## The amount scrolled vertically,
      ## positive away from the user and negative toward the user
    direction*: MouseWheelDirection
      ## Set to one of the `SDL_MOUSEWHEEL_*`.
      ## When `SDL_MOUSEWHEEL_FLIPPED` the values in X and Y will be opposite.
      ## Multiply by `-1` to change them back.
    pad*: array[28, byte]

  JoyAxisEventPtr* = ptr JoyAxisEventObj
  JoyAxisEventObj* = object
    ## Joystick axis motion event structure (`event.jaxis.*`)
    kind*: EventType ## `JOYAXISMOTION`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32 ## The joystick instance id
    axis*: uint8 ## The joystick axis index
    pad1,pad2,pad3: uint8
    value*: int16 ## The axis value (range: `-32768` to `32767`)

  JoyBallEventPtr* = ptr JoyBallEventObj
  JoyBallEventObj* = object
    ## Joystick trackball motion event structure (`event.jball.*`)
    kind*: EventType ## `JOYBALLMOTION`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32 ## The joystick instance id
    ball*: uint8 ## The joystick trackball index
    pad1,pad2,pad3: uint8
    xrel*: int16 ## The relative motion in the X direction
    yrel*: int16 ## The relative motion in the Y direction

  JoyHatEventPtr* = ptr JoyHatEventObj
  JoyHatEventObj* = object
    ## Joystick hat position change event structure (`event.jhat.*`)
    kind*: EventType ## `JOYHATMOTION`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32 ## The joystick instance id
    hat*: uint8 ## The joystick hat index
    value*: uint8
      ## The hat position value (`joystick.SDL_HAT_*` consts)
      ## Note that zero means the POV is centered.

  JoyButtonEventPtr* = ptr JoyButtonEventObj
  JoyButtonEventObj* = object
    ## Joystick button event structure (`event.jbutton.*`)
    kind*: EventType ## `JOYBUTTONDOWN` or `JOYBUTTONUP`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32 ## The joystick instance id
    button*: uint8 ## The joystick button index
    state*: uint8 ## `PRESSED` or `RELEASED`

  JoyDeviceEventPtr* = ptr JoyDeviceEventObj
  JoyDeviceEventObj* = object
    ## Joystick device event structure (`event.jdevice.*`)
    kind*: EventType ## `JOYDEVICEADDED` or `JOYDEVICEREMOVED`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32
      ## The joystick device index for the `ADDED` event,
      ## instance id for the `REMOVED` event

  ControllerAxisEventPtr* = ptr ControllerAxisEventObj
  ControllerAxisEventObj* = object
    ## Game controller axis motion event structure (`event.caxis.*`)
    kind*: EventType ## `CONTROLLERAXISMOTION`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32 ## The joystick instance id
    axis*: uint8 ## The controller axis (`GameControllerAxis`)
    pad1,pad2,pad3: uint8
    value*: int16 ## The axis value

  ControllerButtonEventPtr* = ptr ControllerButtonEventObj
  ControllerButtonEventObj* = object
    ## Game controller button event structure (`event.cbutton.*`)
    kind*: EventType ## `CONTROLLERBUTTONDOWN` or `CONTROLLERBUTTONUP`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32 ## The joystick instance id
    button*: uint8 ## The controller button (`GameControllerButton`)
    state*: uint8 ## `PRESSED` or `RELEASED`

  ControllerDeviceEventPtr* = ptr ControllerDeviceEventObj
  ControllerDeviceEventObj* = object
    ## Controller device event structure (`event.cdevice.*`)
    kind*: EventType
      ## `CONTROLLERDEVICEADDED`,
      ## `CONTROLLERDEVICEREMOVED` or
      ## `CONTROLLERDEVICEREMAPPED`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    which*: int32
      ## The joystick device index for the `ADDED` event,
      ## instance id for the `REMOVED` or `REMAPPED` event

  TouchID* = int64
  FingerID* = int64

  TouchFingerEventPtr* = ptr TouchFingerEventObj
  TouchFingerEventObj* = object
    ## Touch finger event structure (`event.tfinger.*`)
    kind*: EventType ## `FINGERMOTION` or `FINGERDOWN` or `FINGERUP`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    touchID*: TouchID ## The touch device id
    fingerID*: FingerID ## Normalized in the range 0...1
    x*: cfloat ## Normalized in the range 0..1
    y*: cfloat ## Normalized in the range 0..1
    dx*: cfloat ## Normalized in the range -1..1
    dy*: cfloat ## Normalized in the range -1..1
    pressure*: cfloat ## Normalized in the range 0..1
    pad*: array[24, byte]

  MultiGestureEventPtr* = ptr MultiGestureEventObj
  MultiGestureEventObj* = object
    ## Multiple Finger Gesture Event (`event.mgesture.*`)
    kind*: EventType ## `MULTIGESTURE`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    touchID*: TouchID ## The touch device index
    dTheta*, dDist*, x*, y*: cfloat
    numFingers*: uint16

  Finger* = object
    id*: FingerID
    x*,y*: cfloat
    pressure*: cfloat

  GestureID = int64
  DollarGestureEventPtr* = ptr DollarGestureEventObj
  DollarGestureEventObj* = object
    ## Dollar Gesture Event (`event.dgesture.*`)
    kind*: EventType ## `DOLLARGESTURE` or `DOLLARRECORD`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    touchID*: TouchID ## The touch device id
    gestureID*: GestureID
    numFingers*: uint32
    error*: cfloat
    x*: cfloat ## Normalized center of gesture
    y*: cfloat ## Normalized center of gesture

  DropEventPtr* = ptr DropEventObj
  DropEventObj* = object
    ## An event used to request a file open by the system (`event.drop.*`)
    ## This event is enabled by default, you can disable it with `eventState()`
    ##
    ## **Note:** If this event is enabled, you must free the filename in the event.
    kind*: EventType ## `DROPBEGIN`, `DROPFILE`, `DROPTEXT` or `DROPCOMPLETE`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    file*: cstring ## The file name, which should be freed with `free()`

  UserEventPtr* = ptr UserEventObj
  UserEventObj* = object
    ## A user-defined event type (`event.user.*`)
    kind*: EventType ## `USEREVENT` through `LASTEVENT-1`
    timestamp*: uint32 ## In milliseconds, populated using `getTicks()`
    windowID*: uint32 ## The associated window if any
    code*: int32 ## User defined event code
    data1*: pointer ## User defined data pointer
    data2*: pointer ## User defined data pointer

  Eventaction* {.size: sizeof(cint).} = enum
    SDL_ADDEVENT, SDL_PEEKEVENT, SDL_GETEVENT
  EventFilter* = proc (userdata: pointer; event: ptr Event): Bool32 {.cdecl.}


  SDL_Return* {.size: sizeof(cint).} = enum
    ## Return value for many SDL functions.
    ## Any function that returns like this should also be discardable
    SdlError = -1, SdlSuccess = 0

  Bool32* {.size: sizeof(cint).} = enum ## SDL_bool
    False32 = 0, True32 = 1

  KeyState* {.size: sizeof(byte).} = enum KeyReleased = 0, KeyPressed

  KeySym* {.pure.} = object
    ## The SDL keysym object, used in key events.
    ##
    ## **Note:** If you are looking for translated character input,
    ## see the `TextInput` event.
    scancode*: ScanCode ## SDL physical key code - see `ScanCode` for details
    sym*: cint ## SDL virtual key code - see `Keycode` for details
    modstate*: int16 ## current key modifiers
    unicode*: cint

  Point* = tuple
    ## A 2D point
    x, y: cint

  PointF* = object
    ## A 2D point
    x*, y*: cfloat

  Rect* = tuple
    ## A rectangle with the origin at the upper left
    x, y: cint
    w, h: cint

  RectF* = object
    ## A rectangle with the origin at the upper left
    x*, y*: cfloat
    w*, h*: cfloat

  GLattr*{.size: sizeof(cint).} = enum
    ## OpenGL configuration attributes
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
    SDL_GL_SHARE_WITH_CURRENT_CONTEXT,
    SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,
    SDL_GL_CONTEXT_RELEASE_BEHAVIOR,
    SDL_GL_CONTEXT_RESET_NOTIFICATION,
    SDL_GL_CONTEXT_NO_ERROR

  MouseWheelDirection* {.size: sizeof(uint32).} = enum
    ## Scroll direction types for the Scroll event
    SDL_MOUSEWHEEL_NORMAL, ## The scroll direction is normal
    SDL_MOUSEWHEEL_FLIPPED ## The scroll direction is flipped / natural

const
  # GLprofile enum.
  SDL_GL_CONTEXT_PROFILE_CORE*:          cint = 0x0001
  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY*: cint = 0x0002
  SDL_GL_CONTEXT_PROFILE_ES*:            cint = 0x0004

  # GLcontextFlag enum.
  SDL_GL_CONTEXT_DEBUG_FLAG*:              cint = 0x0001
  SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG*: cint = 0x0002
  SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG*:      cint = 0x0004
  SDL_GL_CONTEXT_RESET_ISOLATION_FLAG*:    cint = 0x0008

  # GLcontextRelease enum.
  SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE*:  cint  = 0x0000
  SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH*: cint  = 0x0001

type
  DisplayMode* = object
    ## The object that defines a display mode
    ##
    ## **See also:**
    ## * `getNumDisplayModes proc<#getNumDisplayModes,cint>`_
    ## * `getDisplayMode proc<#getDisplayMode,WindowPtr,DisplayMode>`_
    ## * `getDesktopDisplayMode proc<#getDesktopDisplayMode,cint,DisplayMode>`_
    ## * `getCurrentDisplayMode proc<#getCurrentDisplayMode,cint,DisplayMode>`_
    ## * `getClosestDisplayMode proc<#getClosestDisplayMode,cint,ptr.DisplayMode,ptr.DisplayMode>`_

    format*: cuint ## pixel format
    w*: cint ## width, in screen coordinates
    h*: cint ## height, in screen coordinates
    refresh_rate*: cint ## refresh rate (or zero for unspecified)
    driverData*: pointer ## driver-specific data, initialize to 0

  WindowPtr* = ptr object ## The type used to identify a window
  RendererPtr* = ptr object
  TexturePtr* = ptr object
  CursorPtr* = ptr object

  GlContextPtr* = ptr object ## An opaque handle to an OpenGL context.

  SDL_Version* = object
    ## Information about the version of SDL in use.
    ##
    ## Represents the library's version as three levels: major revision
    ## (increments with massive changes, additions, and enhancements),
    ## minor revision (increments with backwards-compatible changes to the
    ## major revision), and patchlevel (increments with fixes to the minor
    ## revision).
    ##
    ## **See also:**
    ## * `getVersion proc<#getVersion,SDL_Version>`_

    major*, minor*, patch*: uint8

  RendererInfoPtr* = ptr RendererInfo
  RendererInfo* {.pure, final.} = object
    ## Information on the capabilities of a render driver or context
    name*: cstring          ## The name of the renderer
    flags*: uint32          ## Supported `RendererFlags`
    num_texture_formats*: uint32 ## The number of available texture formats
    texture_formats*: array[0..16 - 1, uint32] ## The available texture formats
    max_texture_width*: cint ## The maximimum texture width
    max_texture_height*: cint ## The maximimum texture height

  TextureAccess* {.size: sizeof(cint).} = enum
    ## The access pattern allowed for a texture
    SDL_TEXTUREACCESS_STATIC, ## Changes rarely, not lockable
    SDL_TEXTUREACCESS_STREAMING, ## Changes frequently, lockable
    SDL_TEXTUREACCESS_TARGET ## Texture can be used as a render target

  TextureModulate*{.size:sizeof(cint).} = enum
    ## The texture channel modulation used in `copy proc<#copy,RendererPtr,TexturPtr,ptr.Rect,ptr.Rect>`_
    SDL_TEXTUREMODULATE_NONE, ## No modulation
    SDL_TEXTUREMODULATE_COLOR, ## srcC = srcC * color
    SDL_TEXTUREMODULATE_ALPHA ## srcA = srcA * alpha

  RendererFlip* = cint
  SysWMType* {.size: sizeof(cint).}=enum
    SysWM_Unknown, SysWM_Windows, SysWM_X11, SysWM_DirectFB,
    SysWM_Cocoa, SysWM_UIkit, SysWM_Wayland, SysWM_Mir, SysWM_WinRT, SysWM_Android, SysWM_Vivante
  WMinfo* = object
    version*: SDL_Version
    subsystem*: SysWMType
    padding*: array[64, byte]
      ## if the low-level stuff is important to you check
      ## SDL_syswm.h and cast padding to the right type

const # WindowFlags
    SDL_WINDOW_FULLSCREEN*: cuint = 0x00000001 ## fullscreen window
    SDL_WINDOW_OPENGL*: cuint = 0x00000002 ## window usable with OpenGL context
    SDL_WINDOW_SHOWN*: cuint = 0x00000004 ## window is visible
    SDL_WINDOW_HIDDEN*: cuint = 0x00000008 ## window is not visible
    SDL_WINDOW_BORDERLESS*: cuint = 0x00000010 ## no window decoration
    SDL_WINDOW_RESIZABLE*: cuint = 0x00000020 ## window can be resized
    SDL_WINDOW_MINIMIZED*: cuint = 0x00000040 ## window is minimized
    SDL_WINDOW_MAXIMIZED*: cuint = 0x00000080 ## window is maximized
    SDL_WINDOW_INPUT_GRABBED*: cuint = 0x00000100 ## window has grabbed input focus
    SDL_WINDOW_INPUT_FOCUS*: cuint = 0x00000200 ## window has input focus
    SDL_WINDOW_MOUSE_FOCUS*: cuint = 0x00000400 ## window has mouse focus
    SDL_WINDOW_FULLSCREEN_DESKTOP*: cuint = ( SDL_WINDOW_FULLSCREEN or 0x00001000 )
    SDL_WINDOW_FOREIGN*: cuint = 0x00000800 ## window not created by SDL
    SDL_WINDOW_ALLOW_HIGHDPI*: cuint = 0x00002000
      ## window should be created in high-DPI mode if supported
    ## On macOS `NSHighResolutionCapable` must be set true
    ## in the application's `Info.plist` for this to have any effect.
    SDL_WINDOW_MOUSE_CAPTURE*: cuint = 0x00004000
      ## window has mouse captured (unrelated to INPUT_GRABBED)
    SDL_WINDOW_VULKAN*: cuint = 0x10000000 ## window usable for Vulkan surface
    SDL_FLIP_NONE*: cint = 0x00000000 ## Do not flip
    SDL_FLIP_HORIZONTAL*: cint = 0x00000001 ## flip horizontally
    SDL_FLIP_VERTICAL*: cint = 0x00000002 ## flip vertically


converter toBool*(some: Bool32): bool = bool(some)
converter toBool*(some: SDL_Return): bool = some == SdlSuccess
converter toCint*(some: TextureAccess): cint = some.cint

# pixel format flags
const
  SDL_ALPHA_OPAQUE* = 255
  SDL_ALPHA_TRANSPARENT* = 0

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
# Bitmap pixel order, high bit -> low bit.
const
  SDL_BITMAPORDER_NONE* = 0
  SDL_BITMAPORDER_4321* = 1
  SDL_BITMAPORDER_1234* = 2
# Packed component order, high bit -> low bit.
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
# Array component order, low byte -> high byte.
const
  SDL_ARRAYORDER_NONE* = 0
  SDL_ARRAYORDER_RGB* = 1
  SDL_ARRAYORDER_RGBA* = 2
  SDL_ARRAYORDER_ARGB* = 3
  SDL_ARRAYORDER_BGR* = 4
  SDL_ARRAYORDER_BGRA* = 5
  SDL_ARRAYORDER_ABGR* = 6
# Packed component layout.
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

template SDL_FOURCC (a,b,c,d: uint8): uint32 =
  uint32(a) or (uint32(b) shl 8) or (uint32(c) shl 16) or (uint32(d) shl 24)

template SDL_DEFINE_PIXELFOURCC*(A, B, C, D: char): uint32 =
  SDL_FOURCC(A.uint8, B.uint8, C.uint8, D.uint8)

template SDL_DEFINE_PIXELFORMAT*(`type`, order, layout, bits, bytes: int): uint32 =
  uint32((1 shl 28) or ((`type`) shl 24) or ((order) shl 20) or ((layout) shl 16) or
      ((bits) shl 8) or ((bytes) shl 0))

template SDL_PIXELFLAG*(X: uint32): int =
  int(((X) shr 28) and 0x0000000F)

template SDL_PIXELTYPE*(X: uint32): int =
  int(((X) shr 24) and 0x0000000F)

template SDL_PIXELORDER*(X: uint32): int =
  int(((X) shr 20) and 0x0000000F)

template SDL_PIXELLAYOUT*(X: uint32): int =
  int(((X) shr 16) and 0x0000000F)

template SDL_BITSPERPIXEL*(X: uint32): int =
  int(((X) shr 8) and 0x000000FF)

template SDL_BYTESPERPIXEL*(X: uint32): int =
  int(if SDL_ISPIXELFORMAT_FOURCC(X): (if (((X) == SDL_PIXELFORMAT_YUY2) or
      ((X) == SDL_PIXELFORMAT_UYVY) or ((X) == SDL_PIXELFORMAT_YVYU)): 2 else: 1) else: (
      ((X) shr 0) and 0x000000FF))

template SDL_ISPIXELFORMAT_INDEXED*(format: uint32): bool =
  (not SDL_ISPIXELFORMAT_FOURCC(format) and
      ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) or
      (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4) or
      (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8)))

template SDL_ISPIXELFORMAT_ALPHA*(format: uint32): bool =
  (not SDL_ISPIXELFORMAT_FOURCC(format) and
      ((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) or
      (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA) or
      (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR) or
      (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA)))

# The flag is set to 1 because 0x1? is not in the printable ASCII range
template SDL_ISPIXELFORMAT_FOURCC*(format: uint32): bool =
  ((format != 0) and (SDL_PIXELFLAG(format) != 1))

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
  ## Planar mode: Y + V + U  (3 planes)
  SDL_PIXELFORMAT_IYUV* = SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V') #*< Planar mode: Y + U + V  (3 planes)
  ## Planar mode: Y + U + V  (3 planes)
  SDL_PIXELFORMAT_YUY2* = SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2') #*< Packed mode: Y0+U0+Y1+V0 (1 plane)
  ## Packed mode: Y0+U0+Y1+V0 (1 plane)
  SDL_PIXELFORMAT_UYVY* = SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y') #*< Packed mode: U0+Y0+V0+Y1 (1 plane)
  ## Packed mode: U0+Y0+V0+Y1 (1 plane)
  SDL_PIXELFORMAT_YVYU* = SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U') #*< Packed mode: Y0+V0+Y1+U0 (1 plane)
  ## Packed mode: Y0+V0+Y1+U0 (1 plane)


type
  Color* {.pure, final.} = tuple
    r: uint8
    g: uint8
    b: uint8
    a: uint8

  Palette* {.pure, final.} = object
    ncolors*: cint
    colors*: ptr Color
    version*: uint32
    refcount*: cint

  PixelFormat* {.pure, final.} = object
    ## **Note:** Everything in the pixel format object is read-only.
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

  BlitMapPtr* {.pure.} = ptr object ## couldnt find SDL_BlitMap ?

  SurfacePtr* = ptr Surface
  Surface* {.pure, final.} = object
    ## A collection of pixels used in software blitting.
    ##
    ## **Note:** This object should be treated as read-only, except for
    ## `pixels`, which, if not `nil`, contains the raw pixel data
    ## for the surface.
    flags*: uint32           ## Read-only
    format*: ptr PixelFormat ## Read-only
    w*, h*, pitch*: int32    ## Read-only
    pixels*: pointer         ## Read-write
    userdata*: pointer       ## Application data associated with the surface. Read-write
    locked*: int32           ## Read-only   ## see if this should be Bool32
    lock_data*: pointer      ## Read-only
    clip_rect*: Rect         ## clipping information. Read-only
    map: BlitMapPtr
      ## info for fast blit mapping to other surfaces. Private
    refcount*: cint
      ## Reference count, used when freeing surface. Read-mostly

  BlendMode* {.size: sizeof(cint).} = enum
    ## The blend mode used in `copy proc<#copy,RendererPtr,TexturPtr,ptr.Rect,ptr.Rect>`_ and drawing operations.
    BlendMode_None = 0x00000000,
      ## no blending
      ## dstRGBA = srcRGBA
    BlendMode_Blend = 0x00000001,
      ## alpha blending
      ## dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
      ## dstA = srcA + (dstA * (1-srcA))
    BlendMode_Add  = 0x00000002,
      ## additive blending
      ## dstRGB = (srcRGB * srcA) + dstRGB
      ## dstA = dstA
    BlendMode_Mod  = 0x00000004
      ## color modulate
      ## dstRGB = srcRGB * dstRGB
      ## dstA = dstA

  BlitFunction* = proc(src: SurfacePtr; srcrect: ptr Rect;
                       dst: SurfacePtr; dstrect: ptr Rect): cint{.cdecl.}
    ## The type of procedure used for surface blitting procedures.

  TimerCallback* = proc (interval: uint32; param: pointer): uint32{.cdecl.}
    ## Procedure prototype for the timer callback procedure.
    ##
    ## The callback procedure is passed the current timer interval and returns
    ## the next timer interval.  If the returned value is the same as the one
    ## passed in, the periodic alarm continues, otherwise a new alarm is
    ## scheduled.  If the callback returns `0`, the periodic alarm is
    ## cancelled.

  TimerID* = cint

const ## RendererFlags
  Renderer_Software*: cint = 0x00000001
    ## The renderer is a software fallback
  Renderer_Accelerated*: cint = 0x00000002
    ## The renderer uses hardware acceleration
  Renderer_PresentVsync*: cint = 0x00000004
    ## Present is synchronized with the refresh rate
  Renderer_TargetTexture*: cint = 0x00000008
    ## Ther render supports rendering to texture

const  ## These are the currently supported flags for the `Surface`.
  SDL_SWSURFACE* = 0         ## Just here for compatibility
  SDL_PREALLOC* = 0x00000001 ## Surface uses preallocated memory
  SDL_RLEACCEL* = 0x00000002 ## Surface is RLE encoded
  SDL_DONTFREE* = 0x00000004 ## Surface is referenced internally

template SDL_MUSTLOCK*(some: SurfacePtr): bool =
  ## Checks if the surface needs to be locked before access.
  (some.flags and SDL_RLEACCEL) != 0



const
  INIT_TIMER*       = 0x00000001
  INIT_AUDIO*       = 0x00000010
  INIT_VIDEO*       = 0x00000020
  INIT_JOYSTICK*    = 0x00000200
  INIT_HAPTIC*      = 0x00001000
  INIT_GAMECONTROLLER* = 0x00002000
  INIT_EVENTS*      = 0x00004000
  INIT_NOPARACHUTE* = 0x00100000
  INIT_EVERYTHING*  = 0x0000FFFF

const SDL_WINDOWPOS_UNDEFINED_MASK* = 0x1FFF0000

template SDL_WINDOWPOS_UNDEFINED_DISPLAY*(X: cint): untyped =
  ## Used to indicate that you don't care what the window position is.
  cint(SDL_WINDOWPOS_UNDEFINED_MASK or X)

const SDL_WINDOWPOS_UNDEFINED*: cint = SDL_WINDOWPOS_UNDEFINED_DISPLAY(0)
template SDL_WINDOWPOS_ISUNDEFINED*(X: cint): bool = (((X) and 0xFFFF0000) == SDL_WINDOWPOS_UNDEFINED_MASK)

const SDL_WINDOWPOS_CENTERED_MASK* = 0x2FFF0000
template SDL_WINDOWPOS_CENTERED_DISPLAY*(X: cint): cint =
  ## Used to indicate that the window position should be centered.
  cint(SDL_WINDOWPOS_CENTERED_MASK or X)

const SDL_WINDOWPOS_CENTERED*: cint = SDL_WINDOWPOS_CENTERED_DISPLAY(0)
template SDL_WINDOWPOS_ISCENTERED*(X: cint): bool = (((X) and 0xFFFF0000) == SDL_WINDOWPOS_CENTERED_MASK)

template evConv(name, name2, ptype: untyped; valid: openarray[EventType]): untyped =
  proc `name`*(event: Event): ptype =
    assert event.kind in valid
    return cast[ptype](unsafeAddr event)
  proc `name2`*(event: Event): ptype =
    assert event.kind in valid
    return cast[ptype](unsafeAddr event)

evConv(evWindow, window, WindowEventPtr, [WindowEvent])
evConv(evKeyboard, key, KeyboardEventPtr, [KeyDown, KeyUP])
evConv(evTextEditing, edit, TextEditingEventPtr, [TextEditing])
evConv(evTextInput, text, TextInputEventPtr, [TextInput])

evConv(evMouseMotion, motion, MouseMotionEventPtr, [MouseMotion])
evConv(evMouseButton, button, MouseButtonEventPtr, [MouseButtonDown, MouseButtonUp])
evConv(evMouseWheel, wheel, MouseWheelEventPtr, [MouseWheel])

evConv(EvJoyAxis, jaxis, JoyAxisEventPtr, [JoyAxisMotion])
evConv(EvJoyBall, jball, JoyBallEventPtr, [JoyBallMotion])
evConv(EvJoyHat, jhat, JoyHatEventPtr, [JoyHatMotion])
evConv(EvJoyButton, jbutton, JoyButtonEventPtr, [JoyButtonDown, JoyButtonUp])
evConv(EvJoyDevice, jdevice, JoyDeviceEventPtr, [JoyDeviceAdded, JoyDeviceRemoved])

evConv(EvControllerAxis, caxis, ControllerAxisEventPtr, [ControllerAxisMotion])
evConv(EvControllerButton, cbutton, ControllerButtonEventPtr, [ControllerButtonDown, ControllerButtonUp])
evConv(EvControllerDevice, cdevice, ControllerDeviceEventPtr, [ControllerDeviceAdded, ControllerDeviceRemoved])

evConv(EvTouchFinger, tfinger, TouchFingerEventPtr, [FingerMotion, FingerDown, FingerUp])
evConv(EvMultiGesture, mgesture, MultiGestureEventPtr, [MultiGesture])
evConv(EvDollarGesture, dgesture, DollarGestureEventPtr, [DollarGesture])

evConv(evDropFile, drop, DropEventPtr, [DropFile])
evConv(evQuit, quit, QuitEventPtr, [QuitEvent])

evConv(evUser, user, UserEventPtr, [UserEvent, UserEvent1, UserEvent2, UserEvent3, UserEvent4, UserEvent5])
#evConv(EvSysWM, syswm, SysWMEventPtr, {SysWMEvent})

const ## SDL_MessageBox flags. If supported will display warning icon, etc.
  SDL_MESSAGEBOX_ERROR* = 0x00000010 ## error dialog
  SDL_MESSAGEBOX_WARNING* = 0x00000020 ## warning dialog
  SDL_MESSAGEBOX_INFORMATION* = 0x00000040 ## informational dialog

  # Flags for SDL_MessageBoxButtonData.
  SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT* = 0x00000001
    ## Marks the default button when return is hit
  SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT* = 0x00000002
    ## Marks the default button when escape is hit

type
  MessageBoxColor* {.pure, final.} = object
    ## RGB value used in a message box color scheme
    r*: uint8
    g*: uint8
    b*: uint8

  MessageBoxColorType* = enum
    SDL_MESSAGEBOX_COLOR_BACKGROUND, SDL_MESSAGEBOX_COLOR_TEXT,
    SDL_MESSAGEBOX_COLOR_BUTTON_BORDER,
    SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND,
    SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED, SDL_MESSAGEBOX_COLOR_MAX
  MessageBoxColorScheme* {.pure, final.} = object
    ## A set of colors to use for message box dialogs
    colors*: array[MessageBoxColorType, MessageBoxColor]


  MessageBoxButtonData* {.pure, final.} = object
    ## Individual button data
    flags*: cint ## MessageBoxButtonFlags
    buttonid*: cint
      ## User defined button id (value returned via SDL_MessageBox)
    text*: cstring ## The UTF-8 button text

  MessageBoxData* {.pure, final.} = object
    flags*: cint ## SDL_MessageBoxFlags
    window*: WindowPtr ## Parent window, can be `nil`
    title*: cstring ## UTF-8 title
    message*: cstring ## UTF-8 message text
    numbuttons*: cint
    buttons*: ptr MessageBoxButtonData
    colorScheme*: ptr MessageBoxColorScheme
      ## SDL_MessageBoxColorScheme, can be `nil` to use system settings

  RWopsPtr* = ptr RWops
  RWops* {.pure, final.} = object
    ## This is the read/write operation structure -- very basic.
    size*: proc (context: RWopsPtr): int64 {.cdecl, tags: [], raises: [].}
      ## `Return` the size of the file in this rwops, or `-1` if unknown
    seek*: proc (context: RWopsPtr; offset: int64;
                 whence: cint): int64 {.cdecl, tags: [], raises: [].}
      ## Seek to `offset` relative to `whence`,
      ## one of stdio's whence values:
      ## `RW_SEEK_SET`, `RW_SEEK_CUR`, `RW_SEEK_END`
      ##
      ## `Return` the final offset in the data stream, or `-1` on error.
      # TODO: Add the forementioned consts

    read*: proc (context: RWopsPtr; destination: pointer;
                  size, maxnum: csize_t): csize_t {.
                  cdecl, tags: [ReadIOEffect], raises: [].}
      ## Read up to `maxnum` objects each of size `size` from the data
      ## stream to the area pointed at by `p`.
      ##
      ## `Return` the number of objects read, or `0` at error or end of file.

    write*: proc (context: RWopsPtr; source: pointer; size: csize_t;
                  num: csize_t): csize_t {.cdecl, tags: [WriteIOEffect], raises: [].}
      ## Write exactly `num` objects each of size `size` from the area
      ## pointed at by `p` to data stream.
      ##
      ## `Return` the number of objects written,
      ## or `0` at error or end of file.

    close*: proc (context: RWopsPtr): cint {.cdecl, tags: [WriteIOEffect].}
      ## Close and free an allocated RWops object.
      ##
      ## `Return` `0` if successful,
      ## or `-1` on write error when flushing data.

    kind*: cint
    mem*: Mem

  Mem*{.final.} = object
    base*: ptr byte
    here*: ptr byte
    stop*: ptr byte

# SDL_system.h
type VoidCallback* = proc(arg: pointer): void {.cdecl.}
const SDL_ANDROID_EXTERNAL_STORAGE_READ*  = cint(0x01)
const SDL_ANDROID_EXTERNAL_STORAGE_WRITE* = cint(0x02)

when not defined(SDL_Static):
  {.push callConv: cdecl, dynlib: LibName.}


# functions whose names have been shortened by elision of a type name
proc getWMInfo*(window: WindowPtr; info: var WMInfo): Bool32 {.
  importc: "SDL_GetWindowWMInfo".}

proc setLogicalSize*(renderer: RendererPtr; w, h: cint): cint {.
  importc: "SDL_RenderSetLogicalSize".}
  ## Set device independent resolution for rendering.
  ##
  ## `renderer` The renderer for which resolution should be set.
  ##
  ## `w` The width of the logical resolution
  ##
  ## `h` The height of the logical resolution
  ##
  ## This procedure uses the viewport and scaling functionality to allow a
  ## fixed logical resolution for rendering, regardless of the actual output
  ## resolution. If the actual  output resolution doesn't have the same aspect
  ## ratio the output rendering will be centered within the output display.
  ##
  ## If the output display is a window, mouse events in the window will be
  ## filtered and scaled so they seem to arrive within the logical resolution.
  ##
  ## **Note:** If this procedure results in scaling or subpixel drawing by the
  ## rendering backend, it will be handled using the appropriate quality hints.
  ##
  ## `Return` `0` on success or a negative error code on failure.
  ##
  ## **See also:**
  ## * `getLogicalSize proc<#getLogicalSize,RendererPtr,cint,cint>`_
  ## * `setScale proc<#setScale,RendererPtr,cfloat,cfloat>`_
  ## * `setViewport proc<#setViewport,RendererPtr,ptr.Rect>`_


proc getLogicalSize*(renderer: RendererPtr; w, h: var cint) {.
  importc: "SDL_RenderGetLogicalSize".}
  ## Get device independent resolution for rendering.
  ##
  ## `renderer` The renderer from which resolution should be queried.
  ##
  ## `w` A pointer filled with the width of the logical resolution.
  ##
  ## `h` A pointer filled with the height of the logical resolution.
  ##
  ## **See also:**
  ## * `setLogicalSize proc<#setLogicalSize,RendererPtr,cint,cint>`_


proc setIntegerScale*(renderer: RendererPtr; enable: Bool32): cint {.
  importc: "SDL_RenderSetIntegerScale".}
  ## Set whether to force integer scales for resolution-independent rendering.
  ##
  ## This function restricts the logical viewport to integer values - that is,
  ## when a resolution is between two multiples of a logical size, the viewport
  ## size is rounded down to the lower multiple.
  ##
  ## `renderer` the renderer for which integer scaling should be set
  ## `enable` enable or disable the integer scaling for rendering
  ##
  ## `Return` 0 on success or a negative error code on failure
  ##
  ## ** See also:*
  ## * `getIntegerScale proc<#getIntegerScale,RendererPtr>`_
  ## * `setLogicalSize proc<#setLogicalSize,RendererPtr,cint,cint>`_


proc getIntegerScale*(renderer: RendererPtr): Bool32 {.
  importc: "SDL_RenderGetIntegerScale".}
  ## Get whether integer scales are forced for resolution-independent rendering.
  ##
  ## `renderer` the renderer from which integer scaling should be queried
  ##
  ## `Return` `True32` if integer scales are forced or `False32` if not and on
  ##          failure
  ##
  ## ** See also:*
  ## * `setIntegerScale proc<#setIntegerScale,RendererPtr,Bool32>`_


proc setDrawColor*(renderer: RendererPtr; r, g, b: uint8, a = 255'u8):
  SDL_Return {.importc: "SDL_SetRenderDrawColor", discardable.}
  ## Set the color used for drawing operations (Rect, Line and Clear).
  ##
  ## `renderer` The renderer for which drawing color should be set.
  ##
  ## `r` The red value used to draw on the rendering target.
  ##
  ## `g` The green value used to draw on the rendering target.
  ##
  ## `b` The blue value used to draw on the rendering target.
  ##
  ## `a` The alpha value used to draw on the rendering target,
  ## usually `SDL_ALPHA_OPAQUE` (`255`).

proc setDrawColor*(renderer: RendererPtr; c: Color) =
  setDrawColor(renderer, c.r, c.g, c.b, c.a)

proc getDrawColor*(renderer: RendererPtr; r, g, b, a: var uint8): SDL_Return {.
  importc: "SDL_GetRenderDrawColor", discardable.}
  ## Get the color used for drawing operations (Rect, Line and Clear).
  ##
  ## `renderer` The renderer from which drawing color should be queried.
  ##
  ## `r` A pointer to the red value used to draw on the rendering target.
  ##
  ## `g` A pointer to the green value used to draw on the rendering target.
  ##
  ## `b` A pointer to the blue value used to draw on the rendering target.
  ##
  ## `a` A pointer to the alpha value used to draw on the rendering target,
  ## usually `SDL_ALPHA_OPAQUE` (`255`).

proc setDrawBlendMode*(renderer: RendererPtr; blendMode: BlendMode): SDL_Return {.
  importc: "SDL_SetRenderDrawBlendMode", discardable.}
  ## Set the blend mode used for drawing operations (Fill and Line).
  ##
  ## `renderer` The renderer for which blend mode should be set.
  ##
  ## `blendMode` `BlendMode` to use for blending.
  ##
  ## `Return` `0` on success, or `-1` on error
  ##
  ## **Note:** If the blend mode is not supported,
  ## the closest supported mode is chosen.
  ##
  ## **See also:**
  ## * `getDrawBlendMode proc<#getDrawBlendMode,RendererPtr,BlendMode>`_

proc getDrawBlendMode*(
  renderer: RendererPtr; blendMode: var BlendMode): SDL_Return {.
  importc: "SDL_GetRenderDrawBlendMode", discardable.}
  ## Get the blend mode used for drawing operations.
  ##
  ## `renderer` The renderer from which blend mode should be queried.
  ##
  ## `blendMode` A pointer filled in with the current blend mode.
  ##
  ## `Return` `0` on success, or `-1` on error.
  ##
  ## **See also:**
  ## * `setDrawBlendMode proc<#setDrawBlendMode,RendererPtr,BlendMode>`_

proc destroy*(texture: TexturePtr) {.importc: "SDL_DestroyTexture".}
  ## Destroy the specified texture.
  ##
  ## **See also:**
  ## * `createTextute proc<#createTextute,RendererPtr,uint32,cint,cint,cint>`_

proc destroy*(renderer: RendererPtr) {.importc: "SDL_DestroyRenderer".}
  ## Destroy the rendering context for a window and free associated textures.
  ##
  ## **See also:**
  ## * `createRenderer proc<#createRenderer,WindowPtr,cint,cint>`_


proc getDisplayIndex*(window: WindowPtr): cint {.importc: "SDL_GetWindowDisplayIndex".}

proc setDisplayMode*(window: WindowPtr;
  mode: ptr DisplayMode): SDL_Return {.importc: "SDL_SetWindowDisplayMode".}

proc getDisplayMode*(window: WindowPtr; mode: var DisplayMode): cint  {.
  importc: "SDL_GetWindowDisplayMode".}

proc getPixelFormat*(window: WindowPtr): uint32 {.importc: "SDL_GetWindowPixelFormat".}
  ## Get the human readable name of a pixel format.

proc getID*(window: WindowPtr): uint32 {.importc: "SDL_GetWindowID".}
  ## Get the numeric ID of a window, for logging purposes.

proc getFlags*(window: WindowPtr): uint32 {.importc: "SDL_GetWindowFlags".}
  ## Get the window flags.

proc setTitle*(window: WindowPtr; title: cstring) {.importc: "SDL_SetWindowTitle".}
  ## Set the title of a window, in UTF-8 format.
  ##
  ## **See also:**
  ## * `getTitle proc<#getTitle,WindowPtr>`_

proc getTitle*(window: WindowPtr): cstring {.importc: "SDL_GetWindowTitle".}
  ## Get the title of a window, in UTF-8 format.
  ##
  ## **See also:**
  ## * `setTitle proc<#setTitle,WindowPtr,cstring>`_

proc setIcon*(window: WindowPtr; icon: SurfacePtr) {.importc: "SDL_SetWindowIcon".}
  ## Set the icon for a window.
  ##
  ## `window` The window for which the icon should be set.
  ##
  ## `icon` The icon for the window.

proc setData*(window: WindowPtr; name: cstring;
              userdata: pointer): pointer {.importc: "SDL_SetWindowData".}
  ## Associate an arbitrary named pointer with a window.
  ##
  ## `window` The window to associate with the pointer.
  ##
  ## `name` The name of the pointer.
  ##
  ## `userdata` The associated pointer.
  ##
  ## `Return` The previous value associated with `name`.
  ##
  ## **Note:** The name is case-sensitive.
  ##
  ## **See also:**
  ## * `getData proc<#getData,WindowPtr,cstring>`_


proc getData*(window: WindowPtr; name: cstring): pointer {.importc: "SDL_GetWindowData".}
  ## Retrieve the data pointer associated with a window.
  ##
  ## `window` The window to query.
  ##
  ## `name` The name of the pointer.
  ##
  ## `Return` The value associated with `name`.
  ##
  ## **See also:**
  ## * `setData proc<#setData,WindowPtr,cstring,pointer>`_

proc setPosition*(window: WindowPtr; x, y: cint) {.importc: "SDL_SetWindowPosition".}
  ## Set the position of a window.
  ##
  ## `window` The window to reposition.
  ##
  ## `x` The x coordinate of the window in screen coordinates,
  ## `SDL_WINDOWPOS_CENTERED` or `SDL_WINDOWPOS_UNDEFINED`.
  ##
  ## `y` The y coordinate of the window in screen coordinates,
  ## `SDL_WINDOWPOS_CENTERED` or `SDL_WINDOWPOS_UNDEFINED`.
  ##
  ## **Note:** The window coordinate origin is the upper left of the display.
  ##
  ## **See also:**
  ## * `getPosition proc<#getPosition,WindowPtr,cint,cint>`_

proc getPosition*(window: WindowPtr; x, y: var cint)  {.importc: "SDL_GetWindowPosition".}
  ## Get the position of a window.
  ##
  ## `window` The window to query.
  ##
  ## `x` Pointer to variable for storing the x position,
  ## in screen coordinates. May be `nil`.
  ##
  ## `y` Pointer to variable for storing the y position,
  ## in screen coordinates. May be `nil`.
  ##
  ## **See also:**
  ## * `setPosition proc<#setPosition,WindowPtr,cint,cint>`_


proc setSize*(window: WindowPtr; w, h: cint)  {.importc: "SDL_SetWindowSize".}
  ## Set the size of a window's client area.
  ##
  ## `window` The window to resize.
  ##
  ## `w` The width of the window, in screen coordinates. Must be `> 0`.
  ##
  ## `h` The height of the window, in screen coordinates. Must be `> 0`.
  ##
  ## **Note:** Fullscreen windows automatically match the size of the display
  ## mode, and you should use `setDisplayMode()` to change their size.
  ##
  ## The window size in screen coordinates may differ from the size in pixels,
  ## if the window was created with `SDL_WINDOW_ALLOW_HIGHDPI` on a platform with
  ## high-dpi support (e.g. iOS or OS X). Use `getDrawableSize()` or
  ## `getRendererOutputSize()` to get the real client area size in pixels.
  ##
  ## **See also:**
  ## * `getSize proc<#getSize,WindowPtr,cint,cint>`_
  ## * `setDisplayMode proc<#setDisplayMode,WindowPtr,ptr.DisplayMode>`_

proc getSize*(window: WindowPtr; w, h: var cint) {.importc: "SDL_GetWindowSize".}
  ## Get the size of a window's client area.
  ##
  ## `window` The window to query.
  ##
  ## `w` Pointer to variable for storing the width, in screen coordinates.
  ## May be `nil`.
  ##
  ## `h` Pointer to variable for storing the height, in screen coordinates.
  ## May be `nil`.
  ##
  ## The window size in screen coordinates may differ from the size in pixels,
  ## if the window was created with `SDL_WINDOW_ALLOW_HIGHDPI` on a platform with
  ## high-dpi support (e.g. iOS or OS X). Use `glGetDrawableSize()` or
  ## `getRendererOutputSize()` to get the real client area size in pixels.
  ##
  ## **See also:**
  ## * `setSize proc<#setSize,WindowPtr,cint,cint>`_

proc setBordered*(window: WindowPtr; bordered: Bool32) {.importc: "SDL_SetWindowBordered".}
  ## Set the border state of a window.
  ##
  ## This will add or remove the window's `SDL_WINDOW_BORDERLESS` flag and
  ## add or remove the border from the actual window. This is a no-op if the
  ## window's border already matches the requested state.
  ##
  ## `window` The window of which to change the border state.
  ##
  ## `bordered` `false` to remove border, `true` to add border.
  ##
  ## **Note:** You can't change the border state of a fullscreen window.
  ##
  ## **See also:**
  ## * `getFlags proc<#getFlags,WindowPtr>`_

proc setFullscreen*(window: WindowPtr;
  fullscreen: uint32): SDL_Return {.importc: "SDL_SetWindowFullscreen".}
  ## Set a window's fullscreen state.
  ##
  ## `Return` `0` on success, or `-1` if setting the display mode failed.
  ##
  ## **See also:**
  ## * `setDisplayMode proc<#setDisplayMode,WindowPtr,ptr.DisplayMode>`_
  ## * `getDisplayMode proc<#getDisplayMode,WindowPtr,DisplayMode>`_

proc getSurface*(window: WindowPtr): SurfacePtr {.importc: "SDL_GetWindowSurface".}
  ## Get the SDL surface associated with the window.
  ##
  ## `Return` The window's framebuffer surface, or `nil` on error.
  ##
  ## A new surface will be created with the optimal format for the window,
  ## if necessary. This surface will be freed when the window is destroyed.
  ##
  ## **Note:** You may not combine this with 3D or the rendering API
  ## on this window.
  ##
  ## **See also:**
  ## * `updateSurface proc<#updateSurface,WindowPtr>`_
  ## * `updateSurfaceRects proc<#updateSurfaceRects,WindowPtr,ptr.Rect,cint>`_

proc updateSurface*(window: WindowPtr): SDL_Return  {.importc: "SDL_UpdateWindowSurface".}
  ## Copy the window surface to the screen.
  ##
  ## `Return` `0` on success, or `-1` on error.
  ##
  ## **See also:**
  ## * `getSurface proc<#getSurface,WindowPtr>`_
  ## * `updateSurfaceRects proc<#updateSurfaceRects,WindowPtr,ptr.Rect,cint>`_

proc updateSurfaceRects*(window: WindowPtr; rects: ptr Rect;
  numrects: cint): SDL_Return  {.importc: "SDL_UpdateWindowSurfaceRects".}
  ## Copy a number of rectangles on the window surface to the screen.
  ##
  ## `Return` `0` on success, or `-1` on error.
  ##
  ## **See also:**
  ## * `getSurface proc<#getSurface,WindowPtr>`_
  ## * `updateSurface proc<#updateSurface,WindowPtr>`_

proc setGrab*(window: WindowPtr; grabbed: Bool32) {.importc: "SDL_SetWindowGrab".}
  ## Set a window's input grab mode.
  ##
  ## `window` The window for which the input grab mode should be set.
  ##
  ## `grabbed` This is `true` to grab input, and `false` to release input.
  ##
  ## If the caller enables a grab while another window is currently grabbed,
  ## the other window loses its grab in favor of the caller's window.
  ##
  ## **See also:**
  ## * `getGrab proc<#getGrab,WindowPtr>`_

proc getGrab*(window: WindowPtr): Bool32 {.importc: "SDL_GetWindowGrab".}
  ## Get a window's input grab mode.
  ##
  ## `Return` `true` if input is grabbed, and `false` otherwise.
  ##
  ## **See also:**
  ## * `setGrab proc<#setGrab,WindowPtr,Bool32>`_

proc setBrightness*(window: WindowPtr;
  brightness: cfloat): SDL_Return {.importc: "SDL_SetWindowBrightness".}
  ## Set the brightness (gamma correction) for a window.
  ##
  ## `Return` `0` on success,
  ## or `-1` if setting the brightness isn't supported.
  ##
  ## **See also:**
  ## * `getBrightness proc<#getBrightness,WindowPtr>`_
  ## * `setGammaRamp proc<#setGammaRamp,WindowPtr,ptr.uint16,ptr.uint16,ptr.uint16>`_

proc getBrightness*(window: WindowPtr): cfloat {.importc: "SDL_GetWindowBrightness".}
  ## Get the brightness (gamma correction) for a window.
  ##
  ## `Return` The last brightness value passed to `setWindowBrightness()`
  ##
  ## **See also:**
  ## * `setBrightness proc<#setBrightness,WindowPtr,cfloat>`_

proc setGammaRamp*(window: WindowPtr;
  red, green, blue: ptr uint16): SDL_Return {.importc: "SDL_SetWindowGammaRamp".}
  ## Set the gamma ramp for a window.
  ##
  ## `window` The window for which the gamma ramp should be set.
  ##
  ## `red` The translation table for the red channel, or `nil`.
  ##
  ## `green` The translation table for the green channel, or `nil`.
  ##
  ## `blue` The translation table for the blue channel, or `nil`.
  ##
  ## `Return` `0` on success, or `-1` if gamma ramps are unsupported.
  ##
  ## Set the gamma translation table for the red, green, and blue channels
  ## of the video hardware.  Each table is an array of 256 16-bit quantities,
  ## representing a mapping between the input and output for that channel.
  ## The input is the index into the array, and the output is the 16-bit
  ## gamma value at that index, scaled to the output color precision.
  ##
  ## **See also:**
  ## * `getGammaRamp proc<#getGammaRamp,WindowPtr,ptr.uint6,ptr.uint16,ptr.uint16>`_

proc getGammaRamp*(window: WindowPtr; red: ptr uint16;
                  green: ptr uint16;
                  blue: ptr uint16): cint {.importc: "SDL_GetWindowGammaRamp".}
  ## Get the gamma ramp for a window.
  ##
  ## `window` The window from which the gamma ramp should be queried.
  ##
  ## `red` A pointer to a 256 element array of 16-bit quantities to hold
  ## the translation table for the red channel, or `nil`.
  ##
  ## `green` A pointer to a 256 element array of 16-bit quantities to hold
  ## the translation table for the green channel, or `nil`.
  ##
  ## `blue` A pointer to a 256 element array of 16-bit quantities to hold
  ## the translation table for the blue channel, or `nil`.
  ##
  ## `Return` `0` on success, or `-1` if gamma ramps are unsupported.
  ##
  ## **See also:**
  ## * `setGammaRamp proc<#setGammaRamp,WindowPtr,ptr.uint16,ptr.uint16,ptr.uint16>`_



proc init*(flags: cint): SDL_Return {.discardable, importc: "SDL_Init".}
  ## This procedure initializes the subsystems specified by `flags`
  ## Unless the `INIT_NOPARACHUTE` flag is set, it will install cleanup
  ## signal handlers for some commonly ignored fatal signals (like SIGSEGV).
  ##
  ## `Return` `0` on success or a negative error code on failure.

proc initSubSystem*(flags: uint32): cint {.importc: "SDL_InitSubSystem".}
  ## initializes specific SDL subsystems.
  ##
  ## Subsystem initialization is ref-counted, you must call
  ## `sdl.quitSubSystem()` for each `sdl.initSubSystem()` to correctly
  ## shutdown a subsystem manually (or call `sdl.quit()` to force shutdown).
  ##
  ## If a subsystem is already loaded then this call
  ## will increase the ref-count and return.

proc quitSubSystem*(flags: uint32) {.importc: "SDL_QuitSubSystem".}
  ## cleans up specific SDL subsystems.

proc wasInit*(flags: uint32): uint32 {.importc: "SDL_WasInit".}
  ## This procedure returns a mask of the specified subsystems which have
  ## previously been initialized.
  ## If `flags` is `0`, it returns a mask of all initialized subsystems.

proc quit*() {.importc: "SDL_Quit".}
  ## This procedure cleans up all initialized subsystems. You should
  ## call it upon all exit conditions.


proc getPlatform*(): cstring {.importc: "SDL_GetPlatform".}
  ## Gets the name of the platform.

proc getVersion*(ver: var SDL_Version) {.importc: "SDL_GetVersion".}
  ## Get the version of SDL that is linked against your program.
  ##
  ## This procedure may be called safely at any time, even before `init()`.

  # TODO: Add equivalent of the `SDL_VERSION` macro (`version` ? template),
  # and this comment:
  # If you are linking to SDL dynamically, then it is possible that the
  # current version will be different than the version you compiled against.
  # This procedure returns the current version, while version() is a
  # template that tells you what version you compiled with.

proc getRevision*(): cstring {.importc: "SDL_GetRevision".}
  ## Get the code revision of SDL that is linked against your program.
  ##
  ## Returns an arbitrary string (a hash value) uniquely identifying the
  ## exact revision of the SDL library in use, and is only useful in comparing
  ## against other revisions. It is NOT an incrementing number.

proc getRevisionNumber*(): cint {.importc: "SDL_GetRevisionNumber".}
  ## Get the revision number of SDL that is linked against your program.
  ##
  ## Returns a number uniquely identifying the exact revision of the SDL
  ## library in use. It is an incrementing number based on commits to
  ## hg.libsdl.org.

proc getBasePath*(): cstring {.importc: "SDL_GetBasePath".}
  ## Get the path where the application resides.
  ##
  ## Get the "base path". This is the directory where the application was run
  ## from, which is probably the installation directory, and may or may not
  ## be the process's current working directory.
  ##
  ## This returns an absolute path in UTF-8 encoding, and is guaranteed to
  ## end with a path separator ('\\' on Windows, '/' most other places).
  ##
  ## The pointer returned by this procedure is owned by you. Please call
  ## `free()` on the pointer when you are done with it, or it will be a
  ## memory leak. This is not necessarily a fast call, though, so you should
  ## call this once near startup and save the string if you need it.
  ##
  ## Some platforms can't determine the application's path, and on other
  ## platforms, this might be meaningless. In such cases, this procedure will
  ## return `nil`.
  ##
  ## `Return` string of base dir in UTF-8 encoding, or `nil` on error.
  ##
  ## **See also:**
  ## * `getPrefPath proc<#getPrefPath,cstring,cstring>`_

proc getPrefPath*(org, app: cstring): cstring {.importc: "SDL_GetPrefPath".}
  ## Get the user-and-app-specific path where files can be written.
  ##
  ## Get the "pref dir". This is meant to be where users can write personal
  ## files (preferences and save games, etc) that are specific to your
  ## application. This directory is unique per user, per application.
  ##
  ## This procedure will decide the appropriate location in the native
  ## filesystem, create the directory if necessary, and return a string of the
  ## absolute path to the directory in UTF-8 encoding.
  ##
  ## On Windows, the string might look like:
  ## "C:\\Users\\bob\\AppData\\Roaming\\My Company\\My Program Name\\"
  ##
  ## On Linux, the string might look like:
  ## "/home/bob/.local/share/My Program Name/"
  ##
  ## On Mac OS X, the string might look like:
  ## "/Users/bob/Library/Application Support/My Program Name/"
  ##
  ## (etc.)
  ##
  ## You specify the name of your organization (if it's not a real
  ## organization, your name or an Internet domain you own might do) and the
  ## name of your application. These should be untranslated proper names.
  ##
  ## Both the org and app strings may become part of a directory name, so
  ## please follow these rules:
  ## * Try to use the same org string (including case-sensitivity) for
  ##   all your applications that use this procedure.
  ## * Always use a unique app string for each one, and make sure it never
  ##   changes for an app once you've decided on it.
  ## * Unicode characters are legal, as long as it's UTF-8 encoded, but...
  ## * ...only use letters, numbers, and spaces. Avoid punctuation like
  ##   "Game Name 2: Bad Guy's Revenge!" ... "Game Name 2" is sufficient.
  ##
  ## This returns an absolute path in UTF-8 encoding, and is guaranteed to
  ## end with a path separator ('\\' on Windows, '/' most other places).
  ##
  ## The pointer returned by this procedure is owned by you. Please call
  ## `free()` on the pointer when you are done with it, or it will be a
  ## memory leak. This is not necessarily a fast call, though, so you should
  ## call this once near startup and save the string if you need it.
  ##
  ## You should assume the path returned by this procedure is the only safe
  ## place to write files (and that `getBasePath()`, while it might be
  ## writable, or even the parent of the returned path, aren't where you
  ## should be writing things).
  ##
  ## Some platforms can't determine the pref path, and on other
  ## platforms, this might be meaningless. In such cases, this procedure will
  ## return `nil`.
  ##
  ## `org` The name of your organization.
  ##
  ## `app` The name of your application.
  ##
  ## `Return` UTF-8 string of user dir in platform-dependent notation.
  ## `nil` if there's a problem (creating directory failed, etc).
  ##
  ## **See also:**
  ## * `getBasePath proc<#getBasePath>`_


proc getNumRenderDrivers*(): cint {.importc: "SDL_GetNumRenderDrivers".}
  ## Get the number of 2D rendering drivers available for the current display.
  ##
  ## A render driver is a set of code that handles rendering and texture
  ## management on a particular display.  Normally there is only one, but
  ## some drivers may have several available with different capabilities.
  ##
  ## **See also:**
  ## * `getRenderDriverInfo proc<#getRenderDriverInfo,cint,RendererInfo>`_
  ## * `createRenderer proc<#createRenderer,WindowPtr,cint,cint>`_

proc getRenderDriverInfo*(index: cint; info: var RendererInfo): SDL_Return {.
  importc: "SDL_GetRenderDriverInfo".}
  ## Get information about a specific 2D rendering driver
  ## for the current display.
  ##
  ## `index` The index of the driver to query information about.
  ##
  ## `info` A pointer to an RendererInfo struct to be filled with
  ## information on the rendering driver.
  ##
  ## `Return` `0` on success, `-1` if the index was out of range.
  ##
  ## **See also:**
  ## * `createRenderer proc<#createRenderer,WindowPtr,cint,cint>`_

proc createWindowAndRenderer*(width, height: cint; window_flags: uint32;
  window: var WindowPtr; renderer: var RendererPtr): SDL_Return {.
  importc: "SDL_CreateWindowAndRenderer".}
  ## Create a window and default renderer.
  ##
  ## `width` The width of the window.
  ##
  ## `height` The height of the window.
  ##
  ## `window_flags` The flags used to create the window.
  ##
  ## `window` A pointer filled with the window, or `nil` on error.
  ##
  ## `renderer` A pointer filled with the renderer, or `nil` on error.
  ##
  ## `Return` `0` on success, or `-1` on error.


proc createRenderer*(window: WindowPtr; index: cint; flags: cint): RendererPtr {.
  importc: "SDL_CreateRenderer".}
  ## Create a 2D rendering context for a window.
  ##
  ## `window` The window where rendering is displayed.
  ##
  ## `index` The index of the rendering driver to initialize,
  ## or `-1` to initialize the first one supporting the requested flags.
  ## `flags` `RendererFlags`.
  ##
  ## `Return` a valid rendering context or `nil` if there was an error.
  ##
  ## **See also:**
  ## `* createSoftwareRenderer proc<#createSoftwareRenderer,SurfacePtr>`_
  ## `* getRendererInfo proc<#getRendererInfo,RendererPtr,RendererInfoPtr>`_

proc createSoftwareRenderer*(surface: SurfacePtr): RendererPtr {.
  importc: "SDL_CreateSoftwareRenderer".}
  ## Create a 2D software rendering context for a surface.
  ##
  ## `surface` The surface where rendering is done.
  ##
  ## `Return` a valid rendering context or `nil` if there was an error.
  ##
  ## **See also:**
  ## * `createRenderer proc<#createRenderer,WindowPtr,cint,cint>`_
  ## * `destroy proc<#destroy,RendererPtr>`_

proc getRenderer*(window: WindowPtr): RendererPtr {.
  importc: "SDL_GetRenderer".}
  ## Get the renderer associated with a window.

proc getRendererInfo*(renderer: RendererPtr; info: RendererInfoPtr): cint {.
  importc: "SDL_GetRendererInfo".}
  ## Get information about a rendering context.

proc getRendererOutputSize*(renderer: RendererPtr, w: ptr cint, h: ptr cint): cint {.
  importc: "SDL_GetRendererOutputSize".}
  ## Get the output size in pixels of a rendering context.

proc createTexture*(renderer: RendererPtr; format: uint32;
  access, w, h: cint): TexturePtr {.importc: "SDL_CreateTexture".}
  ## Create a texture for a rendering context.
  ##
  ## `renderer` The renderer.
  ##
  ## `format` The format of the texture.
  ##
  ## `access` One of the enumerated values in `TextureAccess`.
  ##
  ## `w` The width of the texture in pixels.
  ##
  ## `h` The height of the texture in pixels.
  ##
  ## `Return` The created texture is returned, or `nil` if no rendering
  ## context was active, the format was unsupported, or the width or height
  ## were out of range.
  ##
  ## **Note:** The contents of the texture are not defined at creation.
  ##
  ## **See also:**
  ## * `queryTextue proc<#queryTextue,TexturePtr,ptr.uint32,ptr.cint,ptr.cint,ptr.cint>`_
  ## * `updateTexture proc<#updateTexture,TexturePtr,ptr.Rect,pointer,cint>`_


proc createTextureFromSurface*(renderer: RendererPtr; surface: SurfacePtr):
  TexturePtr {.importc: "SDL_CreateTextureFromSurface".}
  ## Create a texture from an existing surface.
  ##
  ## `renderer` The renderer.
  ##
  ## `surface` The surface containing pixel data used to fill the texture.
  ##
  ## `Return` The created texture is returned, or `nil` on error.
  ##
  ## **Note:** The surface is not modified or freed by this procedure.
  ##
  ## **See also:**
  ## * `queryTextue proc<#queryTextue,TexturePtr,ptr.uint32,ptr.cint,ptr.cint,ptr.cint>`_

proc createTexture*(renderer: RendererPtr; surface: SurfacePtr): TexturePtr {.
  inline.} = renderer.createTextureFromSurface(surface)

proc queryTexture*(texture: TexturePtr; format: ptr uint32;
  access, w, h: ptr cint): SDL_Return {.discardable, importc: "SDL_QueryTexture".}
proc query*(texture: TexturePtr; format: ptr uint32;
  access, w, h: ptr cint): SDL_Return {.discardable, importc: "SDL_QueryTexture".}
  ## Query the attributes of a texture.
  ##
  ## `texture` A texture to be queried.
  ##
  ## `format`  A pointer filled in with the raw format of the texture.
  ## The actual format may differ, but pixel transfers will use this format.
  ##
  ## `access` A pointer filled in with the actual access to the texture.
  ##
  ## `w` A pointer filled in with the width of the texture in pixels.
  ##
  ## `h` A pointer filled in with the height of the texture in pixels.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid.


proc setTextureColorMod*(texture: TexturePtr; r, g, b: uint8): SDL_Return {.
  importc: "SDL_SetTextureColorMod".}
proc setColorMod*(texture: TexturePtr; r, g, b: uint8): SDL_Return {.
  importc: "SDL_SetTextureColorMod".}
  ## Set an additional color value used in render copy operations.
  ##
  ## `texture` The texture to update.
  ##
  ## `r` The red color value multiplied into copy operations.
  ##
  ## `g` The green color value multiplied into copy operations.
  ##
  ## `b` The blue color value multiplied into copy operations.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid or
  ## color modulation is not supported.
  ##
  ## **See also:**
  ## * `getColorMod proc<#getColorMod,TexturePtr,uint8,uint8,uint8>`_

proc getTextureColorMod*(texture: TexturePtr; r, g, b: var uint8): SDL_Return {.
  importc: "SDL_GetTextureColorMod".}
proc getColorMod*(texture: TexturePtr; r, g, b: var uint8): SDL_Return {.
  importc: "SDL_GetTextureColorMod".}
  ## Get the additional color value used in render copy operations.
  ##
  ## `texture` The texture to query.
  ##
  ## `r` A pointer filled in with the current red color value.
  ##
  ## `g` A pointer filled in with the current green color value.
  ##
  ## `b` A pointer filled in with the current blue color value.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid.
  ##
  ## **See also:**
  ## * `setColorMod proc<#setColorMod,TexturePtr,uint8,uint8,uint8>`_

proc setTextureAlphaMod*(texture: TexturePtr; alpha: uint8): SDL_Return {.
  importc: "SDL_SetTextureAlphaMod", discardable.}
proc setAlphaMod*(texture: TexturePtr; alpha: uint8): SDL_Return {.
  importc: "SDL_SetTextureAlphaMod", discardable.}
  ## Set an additional alpha value used in render copy operations.
  ##
  ## `texture` The texture to update.
  ##
  ## `alpha` The alpha value multiplied into copy operations.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid or
  ## alpha modulation is not supported.
  ##
  ## **See also:**
  ## * `getAlphaMod proc<#getAlphaMod,TexturePtr,uint8>`_

proc getTextureAlphaMod*(texture: TexturePtr; alpha: var uint8): SDL_Return {.
  importc: "SDL_GetTextureAlphaMod", discardable.}
proc getAlphaMod*(texture: TexturePtr; alpha: var uint8): SDL_Return {.
  importc: "SDL_GetTextureAlphaMod", discardable.}
  ## Get the additional alpha value used in render copy operations.
  ##
  ## `texture` The texture to query.
  ##
  ## `alpha` A pointer filled in with the current alpha value.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid.
  ##
  ## **See also:**
  ## * `setAlphaMod proc<#setAlphaMod,TexturePtr,uint8>`_

proc setTextureBlendMode*(texture: TexturePtr; blendMode: BlendMode): SDL_Return {.
  importc: "SDL_SetTextureBlendMode", discardable.}
proc setBlendMode*(texture: TexturePtr; blendMode: BlendMode): SDL_Return {.
  importc: "SDL_SetTextureBlendMode", discardable.}
  ## Set the blend mode used for texture copy operations.
  ##
  ## `texture` The texture to update.
  ##
  ## `blendMode` `BlendMode` to use for texture blending.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid or
  ## the blend mode is not supported.
  ##
  ## **Note:** If the blend mode is not supported,
  ## the closest supported mode is chosen.
  ##
  ## **See also:**
  ## * `getBlendMode proc<#getBlendMode,TexturePtr,BlendMode>`_

proc getTextureBlendMode*(texture: TexturePtr, blendMode: var BlendMode):
  SDL_Return {.importc: "SDL_GetTextureBlendMode", discardable.}
proc getBlendMode*(texture: TexturePtr, blendMode: var BlendMode):
  SDL_Return {.importc: "SDL_GetTextureBlendMode", discardable.}
  ## Get the blend mode used for texture copy operations.
  ##
  ## `texture` The texture to query.
  ##
  ## `blendMode` A pointer filled in with the current blend mode.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid.
  ##
  ## **See also:**
  ## * `setBlendMode proc<#setBlendMode,TexturePtr,BlendMode>`_

proc updateTexture*(texture: TexturePtr; rect: ptr Rect; pixels: pointer;
  pitch: cint): SDL_Return {.importc: "SDL_UpdateTexture", discardable.}
proc update*(texture: TexturePtr; rect: ptr Rect; pixels: pointer;
  pitch: cint): SDL_Return {.importc: "SDL_UpdateTexture", discardable.}
  ## Update the given texture rectangle with new pixel data.
  ##
  ## `texture` The texture to update
  ##
  ## `rect` A pointer to the rectangle of pixels to update, or `nil` to
  ## update the entire texture.
  ##
  ## `pixels` The raw pixel data in the format of the texture.
  ##
  ## `pitch` The number of bytes in a row of pixel data,
  ## including padding between lines.
  ##
  ## The pixel data must be in the format of the texture.
  ## The pixel format can be queried with `query()`.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid.
  ##
  ## **Note:** This is a fairly slow procedure.

proc updateYUVTexture*(texture: TexturePtr; rect: ptr Rect; Yplane: pointer;
  Ypitch: cint; Uplane: pointer; Upitch: cint; Vplane: pointer; Vpitch: cint):
  SDL_Return {.importc: "SDL_UpdateYUVTexture", discardable.}
proc updateYUV*(texture: TexturePtr; rect: ptr Rect; Yplane: pointer;
  Ypitch: cint; Uplane: pointer; Upitch: cint; Vplane: pointer; Vpitch: cint):
  SDL_Return {.importc: "SDL_UpdateYUVTexture", discardable.}
  ## Update a rectangle within a planar YV12 or IYUV texture
  ## with new pixel data.
  ##
  ## `texture` The texture to update
  ##
  ## `rect` A pointer to the rectangle of pixels to update,
  ## or `nil` to update the entire texture.
  ##
  ## `yPlane` The raw pixel data for the Y plane.
  ##
  ## `yPitch` The number of bytes between rows of pixel data for the Y plane.
  ##
  ## `uPlane` The raw pixel data for the U plane.
  ##
  ## `uPitch` The number of bytes between rows of pixel data for the U plane.
  ##
  ## `vPlane` The raw pixel data for the V plane.
  ##
  ## `vPitch` The number of bytes between rows of pixel data for the V plane.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid.
  ##
  ## **Note:** You can use `update()` as long as your pixel data is
  ## a contiguous block of Y and U/V planes in the proper order,
  ## but this procedure is available if your pixel data is not contiguous.

proc lockTexture*(texture: TexturePtr; rect: ptr Rect; pixels: ptr pointer;
  pitch: ptr cint): SDL_Return {.importc: "SDL_LockTexture", discardable.}
proc lock*(texture: TexturePtr; rect: ptr Rect; pixels: ptr pointer;
  pitch: ptr cint): SDL_Return {.importc: "SDL_LockTexture", discardable.}
  ## Lock a portion of the texture for write-only pixel access.
  ##
  ## `texture` The texture to lock for access,
  ## which was created with `SDL_TEXTUREACCESS_STREAMING`.
  ##
  ## `rect` A pointer to the rectangle to lock for access.
  ## If the rect is `nil`, the entire texture will be locked.
  ##
  ## `pixels` This is filled in with a pointer to the locked pixels,
  ## appropriately offset by the locked area.
  ##
  ## `pitch` This is filled in with the pitch of the locked pixels.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid or
  ## was not created with `SDL_TEXTUREACCESS_STREAMING`.
  ##
  ## **See also:**
  ## * `unlock proc<#unlock,TexturePtr>`_

proc unlockTexture*(texture: TexturePtr) {.importc: "SDL_UnlockTexture".}
proc unlock*(texture: TexturePtr) {.importc: "SDL_UnlockTexture".}
  ## Lock a portion of the texture for write-only pixel access.
  ## Expose it as a SDL surface.
  ##
  ## `texture` The texture to lock for access, which was created with
  ## `SDL_TEXTUREACCESS_STREAMING`.
  ##
  ## `rect`  A pointer to the rectangle to lock for access.
  ## If the rect is `nil`, the entire texture will be locked.
  ##
  ## `surface` This is filled in with a SDL surface
  ## representing the locked area.
  ## Surface is freed internally after calling
  ## `unlock()` or `destroy()`.
  ##
  ## `Return` `0` on success, or `-1` if the texture is not valid
  ## or was not created with `SDL_TEXTUREACCESS_STREAMING`.
  ##
  ## **See also:**
  ## * `lock proc<#lock,TexturePtr,ptr.Rect,ptr.pointer,ptr.cint>`_

proc renderTargetSupported*(renderer: RendererPtr): Bool32 {.
  importc: "SDL_RenderTargetSupported".}
  ## Determines whether a window supports the use of render targets.
  ##
  ## `renderer` The renderer that will be checked.
  ##
  ## `Return` `true` if supported, `false` if not.

proc setRenderTarget*(renderer: RendererPtr; texture: TexturePtr): SDL_Return {.discardable,
  importc: "SDL_SetRenderTarget".}
  ## Set a texture as the current rendering target.
  ##
  ## `renderer` The renderer.
  ##
  ## `texture` The targeted texture, which must be created with the
  ## `SDL_TEXTUREACCESS_TARGET` flag, or `nil` for the default render target
  ##
  ## `Return` `0` on success, or `-1` on error.
  ##
  ## **See also:**
  ## * `getRenderTarget proc<#getRenderTarget,RendererPtr>`_

proc getRenderTarget*(renderer: RendererPtr): TexturePtr {.
  importc: "SDL_GetRenderTarget".}
  ## Get the current render target or `nil` for the default render target.
  ##
  ## `Return` The current render target.
  ##
  ## **See also:**
  ## * `setRenderTarget proc<#setRenderTarget,RendererPtr,TexturePtr>`_

proc setViewport*(renderer: RendererPtr; rect: ptr Rect): SDL_Return {.
  importc: "SDL_RenderSetViewport", discardable.}
  ## Set the drawing area for rendering on the current target.
  ##
  ## `renderer` The renderer for which the drawing area should be set.
  ##
  ## `rect` The rectangle representing the drawing area, or `nil` to set
  ## the viewport to the entire target.
  ## The `x`,`y` of the viewport rect represents the origin for rendering.
  ##
  ## `Return` `0` on success, or `-1` on error.
  ##
  ## **Note:** If the window associated with the renderer is resized,
  ## the viewport is automatically reset.
  ##
  ## **See also:**
  ## * `getViewport proc<#getViewport,RendererPtr,Rect>`_
  ## * `setLogicalSize proc<#setLogicalSize,RendererPtr,cint,cint>`_

proc getViewport*(renderer: RendererPtr; rect: var Rect) {.
  importc: "SDL_RenderGetViewport".}
  ## Get the drawing area for the current target.
  ##
  ## **See also:**
  ## * `setViewport proc<#setViewport,RendererPtr,ptr.Rect>`_

proc setScale*(renderer: RendererPtr; scaleX, scaleY: cfloat): SDL_Return {.
  importc: "SDL_RenderSetScale", discardable.}
  ## Set the drawing scale for rendering on the current target.
  ##
  ## `renderer` The renderer for which the drawing scale should be set.
  ##
  ## `scaleX` The horizontal scaling factor.
  ##
  ## `scaleY` The vertical scaling factor.
  ##
  ## The drawing coordinates are scaled by the x/y scaling factors
  ## before they are used by the renderer.  This allows resolution
  ## independent drawing with a single coordinate system.
  ##
  ## **Note:** If this results in scaling or subpixel drawing by the rendering
  ## backend, it will be handled using the appropriate quality hints.
  ## For best results use integer scaling factors.
  ##
  ## **See also:**
  ## * `getScale proc<#getScale,RendererPtr,cfloat,cfloat>`_
  ## * `setLogicalSize proc<#setLogicalSize,RendererPtr,cint,cint>`_

proc getScale*(renderer: RendererPtr; scaleX, scaleY: var cfloat) {.
  importc: "SDL_RenderGetScale".}
  ## Get the drawing scale for the current target.
  ##
  ## `renderer` The renderer from which drawing scale should be queried.
  ##
  ## `scaleX` A pointer filled in with the horizontal scaling factor.
  ##
  ## `scaleY` A pointer filled in with the vertical scaling factor.
  ##
  ## **See also:**
  ## * `setScale proc<#setScale,RendererPtr,cfloat,cfloat>`_

proc drawPoint*(renderer: RendererPtr; x, y: cint): SDL_Return {.
  importc: "SDL_RenderDrawPoint", discardable.}
  ## Draw a point on the current rendering target.
  ##
  ## `renderer` The renderer which should draw a point.
  ##
  ## `x` The x coordinate of the point.
  ##
  ## `y` The y coordinate of the point.

proc drawPointF*(renderer: RendererPtr; x, y: cfloat): SDL_Return {.
  importc: "SDL_RenderDrawPointF", discardable.}
  ## Draw a point on the current rendering target.
  ##
  ## `renderer` The renderer which should draw a point.
  ##
  ## `x` The x coordinate of the point.
  ##
  ## `y` The y coordinate of the point.

proc drawPoints*(renderer: RendererPtr; points: ptr Point;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawPoints", discardable.}
  ## Draw multiple points on the current rendering target.
  ##
  ## `renderer` The renderer which should draw multiple points.
  ##
  ## `points` The points to draw.
  ##
  ## `count` The number of points to draw.
  ##
  ## `Return` `0` on success, or `-1` on error.

proc drawPointsF*(renderer: RendererPtr; points: ptr PointF;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawPointsF", discardable.}
  ## Draw multiple points on the current rendering target.
  ##
  ## `renderer` The renderer which should draw multiple points.
  ##
  ## `points` The points to draw.
  ##
  ## `count` The number of points to draw.
  ##
  ## `Return` `0` on success, or `-1` on error.

proc drawLine*(renderer: RendererPtr; x1, y1, x2, y2: cint): SDL_Return {.
  importc: "SDL_RenderDrawLine", discardable.}
  ## Draw a line on the current rendering target.
  ##
  ## `renderer` The renderer which should draw a line.
  ##
  ## `x1` The x coordinate of the start point.
  ##
  ## `y1` The y coordinate of the start point.
  ##
  ## `x2` The x coordinate of the end point.
  ##
  ## `y2` The y coordinate of the end point.

proc drawLineF*(renderer: RendererPtr; x1, y1, x2, y2: cfloat): SDL_Return {.
  importc: "SDL_RenderDrawLineF", discardable.}
  ## Draw a line on the current rendering target.
  ##
  ## `renderer` The renderer which should draw a line.
  ##
  ## `x1` The x coordinate of the start point.
  ##
  ## `y1` The y coordinate of the start point.
  ##
  ## `x2` The x coordinate of the end point.
  ##
  ## `y2` The y coordinate of the end point.

proc drawLines*(renderer: RendererPtr; points: ptr Point;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawLines", discardable.}
  ## Draw a series of connected lines on the current rendering target.
  ##
  ## `renderer` The renderer which should draw multiple lines.
  ##
  ## `points` The points along the lines.
  ##
  ## `count` The number of points, drawing `count-1` lines.

proc drawLinesF*(renderer: RendererPtr; points: ptr PointF;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawLinesF", discardable.}
  ## Draw a series of connected lines on the current rendering target.
  ##
  ## `renderer` The renderer which should draw multiple lines.
  ##
  ## `points` The points along the lines.
  ##
  ## `count` The number of points, drawing `count-1` lines.

proc drawRect*(renderer: RendererPtr; rect: var Rect): SDL_Return{.
  importc: "SDL_RenderDrawRect", discardable.}

proc drawRectF*(renderer: RendererPtr; rect: var RectF): SDL_Return{.
  importc: "SDL_RenderDrawRectF", discardable.}

proc drawRect*(renderer: RendererPtr; rect: ptr Rect = nil): SDL_Return{.
  importc: "SDL_RenderDrawRect", discardable.}
  ## Draw a rectangle on the current rendering target.
  ##
  ## `renderer` The renderer which should draw a rectangle.
  ##
  ## `rect` A pointer to the destination rectangle,
  ## or `nil` to outline the entire rendering target.

proc drawRectF*(renderer: RendererPtr; rect: ptr RectF = nil): SDL_Return{.
  importc: "SDL_RenderDrawRectF", discardable.}
  ## Draw a rectangle on the current rendering target.
  ##
  ## `renderer` The renderer which should draw a rectangle.
  ##
  ## `rect` A pointer to the destination rectangle,
  ## or `nil` to outline the entire rendering target.

proc drawRects*(renderer: RendererPtr; rects: ptr Rect;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawRects".}
  ## Draw some number of rectangles on the current rendering target.
  ##
  ## `renderer` The renderer which should draw multiple rectangles.
  ##
  ## `rects` A pointer to an array of destination rectangles.
  ##
  ## `count` The number of rectangles.

proc drawRectsF*(renderer: RendererPtr; rects: ptr RectF;
  count: cint): SDL_Return {.importc: "SDL_RenderDrawRectsF".}
  ## Draw some number of rectangles on the current rendering target.
  ##
  ## `renderer` The renderer which should draw multiple rectangles.
  ##
  ## `rects` A pointer to an array of destination rectangles.
  ##
  ## `count` The number of rectangles.

proc fillRect*(renderer: RendererPtr; rect: var Rect): SDL_Return {.
  importc: "SDL_RenderFillRect", discardable.}

proc fillRectF*(renderer: RendererPtr; rect: var RectF): SDL_Return {.
  importc: "SDL_RenderFillRectF", discardable.}

proc fillRect*(renderer: RendererPtr; rect: ptr Rect = nil): SDL_Return {.
  importc: "SDL_RenderFillRect", discardable.}
  ## Fill a rectangle on the current rendering target with the drawing color.
  ##
  ## `renderer` The renderer which should fill a rectangle.
  ##
  ## `rect` A pointer to the destination rectangle,
  ## or `nil` for the entire rendering target.

proc fillRectF*(renderer: RendererPtr; rect: ptr RectF = nil): SDL_Return {.
  importc: "SDL_RenderFillRectF", discardable.}
  ## Fill a rectangle on the current rendering target with the drawing color.
  ##
  ## `renderer` The renderer which should fill a rectangle.
  ##
  ## `rect` A pointer to the destination rectangle,
  ## or `nil` for the entire rendering target.

proc fillRects*(renderer: RendererPtr; rects: ptr Rect;
  count: cint): SDL_Return {.importc: "SDL_RenderFillRects", discardable.}
  ## Fill some number of rectangles on the current rendering target
  ## with the drawing color.
  ##
  ## `renderer` The renderer which should fill multiple rectangles.
  ##
  ## `rects` A pointer to an array of destination rectangles.
  ##
  ## `count` The number of rectangles.

proc fillRectsF*(renderer: RendererPtr; rects: ptr RectF;
  count: cint): SDL_Return {.importc: "SDL_RenderFillRectsF", discardable.}
  ## Fill some number of rectangles on the current rendering target
  ## with the drawing color.
  ##
  ## `renderer` The renderer which should fill multiple rectangles.
  ##
  ## `rects` A pointer to an array of destination rectangles.
  ##
  ## `count` The number of rectangles.

proc copy*(renderer: RendererPtr; texture: TexturePtr;
  srcrect, dstrect: ptr Rect): SDL_Return {.
  importc: "SDL_RenderCopy", discardable.}
  ## Copy a portion of the texture to the current rendering target.
  ##
  ## `renderer` The renderer which should copy parts of a texture.
  ##
  ## `texture` The source texture.
  ##
  ## `srcrect` A pointer to the source rectangle,
  ## or `nil` for the entire texture.
  ##
  ## `dstrect` A pointer to the destination rectangle,
  ## or `nil` for the entire rendering target.

proc copyF*(renderer: RendererPtr; texture: TexturePtr;
  srcrect: ptr Rect, dstrect: ptr RectF): SDL_Return {.
  importc: "SDL_RenderCopyF", discardable.}
  ## Copy a portion of the texture to the current rendering target.
  ##
  ## `renderer` The renderer which should copy parts of a texture.
  ##
  ## `texture` The source texture.
  ##
  ## `srcrect` A pointer to the source rectangle,
  ## or `nil` for the entire texture.
  ##
  ## `dstrect` A pointer to the destination rectangle,
  ## or `nil` for the entire rendering target.

proc copyEx*(renderer: RendererPtr; texture: TexturePtr;
             srcrect, dstrect: var Rect; angle: cdouble; center: ptr Point;
             flip: RendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyEx", discardable.}
proc copyEx*(renderer: RendererPtr; texture: TexturePtr;
             srcrect, dstrect: ptr Rect; angle: cdouble; center: ptr Point;
             flip: RendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyEx", discardable.}
  ## Copy a portion of the source texture to the current rendering target,
  ## rotating it by angle around the given center.
  ##
  ## `renderer` The renderer which should copy parts of a texture.
  ##
  ## `texture` The source texture.
  ##
  ## `srcrect` A pointer to the source rectangle,
  ## or `nil` for the entire texture.
  ##
  ## `dstrect` A pointer to the destination rectangle,
  ## or `nil` for the entire rendering target.
  ##
  ## `angle` An angle in degrees that indicates the rotation
  ## that will be applied to dstrect, rotating it in a clockwise direction.
  ##
  ## `center` A pointer to a point indicating the point
  ## around which `dstrect` will be rotated
  ## (if `nil`, rotation will be done around `dstrect.w/2`, `dstrect.h/2`).
  ##
  ## `flip` `RendererFlip` value stating which flipping actions should be
  ## performed on the texture.

proc copyExF*(renderer: RendererPtr; texture: TexturePtr;
             srcrect: ptr Rect, dstrect: var RectF; angle: cdouble; center: ptr PointF;
             flip: RendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyExF", discardable.}
proc copyExF*(renderer: RendererPtr; texture: TexturePtr;
             srcrect: ptr Rect, dstrect: ptr RectF; angle: cdouble; center: ptr PointF;
             flip: RendererFlip = SDL_FLIP_NONE): SDL_Return {.
             importc: "SDL_RenderCopyExF", discardable.}
  ## Copy a portion of the source texture to the current rendering target,
  ## rotating it by angle around the given center.
  ##
  ## `renderer` The renderer which should copy parts of a texture.
  ##
  ## `texture` The source texture.
  ##
  ## `srcrect` A pointer to the source rectangle,
  ## or `nil` for the entire texture.
  ##
  ## `dstrect` A pointer to the destination rectangle,
  ## or `nil` for the entire rendering target.
  ##
  ## `angle` An angle in degrees that indicates the rotation
  ## that will be applied to dstrect, rotating it in a clockwise direction.
  ##
  ## `center` A pointer to a point indicating the point
  ## around which `dstrect` will be rotated
  ## (if `nil`, rotation will be done around `dstrect.w/2`, `dstrect.h/2`).
  ##
  ## `flip` `RendererFlip` value stating which flipping actions should be
  ## performed on the texture.

proc clear*(renderer: RendererPtr): SDL_Return {.
  importc: "SDL_RenderClear", discardable.}
  ## Clear the current rendering target with the drawing color.
  ##
  ## This procedure clears the entire rendering target, ignoring the viewport,
  ## and the clip rectangle.


proc readPixels*(renderer: RendererPtr; rect: var Rect; format: cint;
  pixels: pointer; pitch: cint): cint {.importc: "SDL_RenderReadPixels".}
proc readPixels*(renderer: RendererPtr; rect: ptr Rect; format: cint;
  pixels: pointer; pitch: cint): cint {.importc: "SDL_RenderReadPixels".}
  ## Read pixels from the current rendering target.
  ##
  ## `renderer` The renderer from which pixels should be read.
  ##
  ## `rect` A pointer to the rectangle to read,
  ## or `nil` for the entire render target.
  ##
  ## `format` The desired format of the pixel data,
  ## or `0` to use the formatof the rendering target.
  ##
  ## `pixels` A pointer to be filled in with the pixel data.
  ##
  ## `pitch` The pitch of the pixels parameter.
  ##
  ## `Return` `0` on success, or `-1` if pixel reading is not supported.
  ##
  ## `Warning:` This is a very slow operation,
  ## and should not be used frequently.

proc present*(renderer: RendererPtr) {.importc: "SDL_RenderPresent".}
  ## Update the screen with rendering performed.


proc glBindTexture*(texture: TexturePtr; texw, texh: var cfloat): cint {.
  importc: "SDL_GL_BindTexture".}
  ## Bind the texture to the current OpenGL/ES/ES2 context for use
  ## with OpenGL instructions.
  ##
  ## `texture` The SDL texture to bind.
  ##
  ## `texw` A pointer to a float that will be filled with the texture width.
  ##
  ## `texh` A pointer to a float that will be filled with the texture height.

proc glUnbindTexture*(texture: TexturePtr) {.importc: "SDL_GL_UnbindTexture".}
  ## Unbind a texture from the current OpenGL/ES/ES2 context.


proc createRGBSurface*(flags: cint; width, height, depth: cint;
  Rmask, Gmask, BMask, Amask: uint32): SurfacePtr {.
  importc: "SDL_CreateRGBSurface".}
  ## Allocate and free an RGB surface.
  ##
  ## If the depth is 4 or 8 bits, an empty palette is allocated for the surface.
  ## If the depth is greater than 8 bits, the pixel format is set using the
  ## flags `[rgb]Mask`.
  ##
  ## If the procedure runs out of memory, it will return `nil`.
  ##
  ## `flags` The `flags` are obsolete and should be set to `0`.
  ##
  ## `width` The width in pixels of the surface to create.
  ##
  ## `height` The height in pixels of the surface to create.
  ##
  ## `depth` The depth in bits of the surface to create.
  ##
  ## `rMask` The red mask of the surface to create.
  ##
  ## `gMask` The green mask of the surface to create.
  ##
  ## `bMask` The blue mask of the surface to create.
  ##
  ## `aMask` The alpha mask of the surface to create.

proc createRGBSurfaceFrom*(pixels: pointer; width, height, depth, pitch: cint;
  Rmask, Gmask, Bmask, Amask: uint32): SurfacePtr {.
  importc: "SDL_CreateRGBSurfaceFrom".}

proc freeSurface*(surface: SurfacePtr) {.importc: "SDL_FreeSurface".}

proc setSurfacePalette*(surface: SurfacePtr; palette: ptr Palette): cint {.
  importc:"SDL_SetSurfacePalette".}
proc setPalette*(surface: SurfacePtr; palette: ptr Palette): cint {.
  importc:"SDL_SetSurfacePalette".}
  ## Set the palette used by a surface.
  ##
  ## `Return` `0`, or `-1` if the surface format doesn't use a palette.
  ##
  ## **Note:** A single palette can be shared with many surfaces.

proc lockSurface*(surface: SurfacePtr): cint {.importc: "SDL_LockSurface".}
proc lock*(surface: SurfacePtr): cint {.importc: "SDL_LockSurface".}
  ## Sets up a surface for directly accessing the pixels.
  ##
  ## Between calls to `lock()` / `unlock()`, you can write
  ## to and read from `surface.pixels`, using the pixel format stored in
  ## `surface.format`.  Once you are done accessing the surface, you should
  ## use `unlock()` to release it.
  ##
  ## Not all surfaces require locking.  If `mustLock(surface)` evaluates
  ## to `0`, then you can read and write to the surface at any time, and the
  ## pixel format of the surface will not change.
  ##
  ## No operating system or library calls should be made between lock/unlock
  ## pairs, as critical system locks may be held during this time.
  ##
  ## `lock()` returns `0`, or `-1` if the surface couldn't be locked.
  ##
  ## **See also:**
  ## * `unlock proc<#unlock,SurfacePtr>`_

proc unlockSurface*(surface: SurfacePtr) {.importc: "SDL_UnlockSurface".}
proc unlock*(surface: SurfacePtr) {.importc: "SDL_UnlockSurface".}
  ## **See also:**
  ## * `lock proc<#lock,SurfacePtr>`_

proc loadBMP_RW*(src: RWopsPtr; freesrc: cint): SurfacePtr {.
  importc: "SDL_LoadBMP_RW".}
proc loadBMP*(src: RWopsPtr; freesrc: cint): SurfacePtr {.
  importc: "SDL_LoadBMP_RW".}
  ## Load a surface from a seekable SDL data stream (memory or file).
  ##
  ## If `freesrc` is non-zero, the stream will be closed after being read.
  ##
  ## The new surface should be freed with `destroy()`.
  ##
  ## `Return` the new surface, or `nil` if there was an error.


proc rwFromFile*(file: cstring; mode: cstring): RWopsPtr {.importc: "SDL_RWFromFile".}
proc rwFromFP*(fp: File; autoclose: Bool32): RWopsPtr {.importc: "SDL_RWFromFP".}
proc rwFromMem*(mem: pointer; size: cint): RWopsPtr {.importc: "SDL_RWFromMem".}
proc rwFromConstMem*(mem: pointer; size: cint): RWopsPtr {.importc: "SDL_RWFromConstMem".}

proc allocRW*: RWopsPtr {.importc: "SDL_AllocRW".}
proc freeRW*(area: RWopsPtr) {.importc: "SDL_FreeRW".}


proc saveBMP_RW*(surface: SurfacePtr; dst: RWopsPtr;
                 freedst: cint): SDL_Return {.importc: "SDL_SaveBMP_RW".}
  ## Save a surface to a seekable SDL data stream (memory or file).
  ##
  ## Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
  ## BMP directly. Other RGB formats with 8-bit or higher get converted to a
  ## 24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
  ## surface before they are saved. YUV and paletted 1-bit and 4-bit formats
  ## are not supported.
  ##
  ## If `freedst` is non-zero, the stream will be closed after being written.
  ##
  ## `Return` `0` if successful or `-1` if there was an error.


proc setSurfaceRLE*(surface: SurfacePtr; flag: cint): cint {.
  importc:"SDL_SetSurfaceRLE".}
  ## Sets the RLE acceleration hint for a surface.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## **Note:** If RLE is enabled, colorkey and alpha blending blits are
  ## much faster, but the surface must be locked before directly
  ## accessing the pixels.

proc setColorKey*(surface: SurfacePtr; flag: cint; key: uint32): cint {.
  importc: "SDL_SetColorKey".}
  ## Sets the color key (transparent pixel) in a blittable surface.
  ##
  ## `surface` The surface to update.
  ##
  ## `flag` Non-zero to enable colorkey and `0` to disable colorkey.
  ##
  ## `key` The transparent pixel in the native surface format.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## You can pass `SDL_RLEACCEL` to enable RLE accelerated blits.

proc getColorKey*(surface: SurfacePtr; key: var uint32): cint {.
  importc: "SDL_GetColorKey".}
  ## Gets the color key (transparent pixel) in a blittable surface.
  ##
  ## `surface` The surface to update.
  ##
  ## `key` A pointer filled in with the transparent pixel
  ## in the native surface format.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid or
  ## colorkey is not enabled.

proc setSurfaceColorMod*(surface: SurfacePtr; r, g, b: uint8): cint {.
  importc: "SDL_SetSurfaceColorMod".}
proc setColorMod*(surface: SurfacePtr; r, g, b: uint8): cint {.
  importc: "SDL_SetSurfaceColorMod".}
  ## Set an additional color value used in blit operations.
  ##
  ## `surface` The surface to update.
  ##
  ## `r` The red color value multiplied into blit operations.
  ##
  ## `g` The green color value multiplied into blit operations.
  ##
  ## `b` The blue color value multiplied into blit operations.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## **See also:**
  ## * `getColorMod proc<#getColorMod,SurfacePtr,uint8,uint8,uint8>`_

proc getSurfaceColorMod*(surface: SurfacePtr; r, g, b: var uint8): cint {.
  importc: "SDL_GetSurfaceColorMod".}
proc getColorMod*(surface: SurfacePtr; r, g, b: var uint8): cint {.
  importc: "SDL_GetSurfaceColorMod".}
  ## Get the additional color value used in blit operations.
  ##
  ## `surface` The surface to query.
  ##
  ## `r` A pointer filled in with the current red color value.
  ##
  ## `g` A pointer filled in with the current green color value.
  ##
  ## `b` A pointer filled in with the current blue color value.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## **See also:**
  ## * `setColorMod proc<#setColorMod,SurfacePtr,uint8,uint8,uint8>`_

proc setSurfaceAlphaMod*(surface: SurfacePtr; alpha: uint8): cint {.
  importc: "SDL_SetSurfaceAlphaMod".}
proc setAlphaMod*(surface: SurfacePtr; alpha: uint8): cint {.
  importc: "SDL_SetSurfaceAlphaMod".}
  ## Set an additional alpha value used in blit operations.
  ##
  ## `surface` The surface to update.
  ##
  ## `alpha` The alpha value multiplied into blit operations.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## **See also:**
  ## * `getAlphaMod proc<#getAlphaMod,SurfacePtr,uint8>`_

proc getSurfaceAlphaMod*(surface: SurfacePtr; alpha: var uint8): cint {.
  importc: "SDL_GetSurfaceAlphaMod".}
proc getAlphaMod*(surface: SurfacePtr; alpha: var uint8): cint {.
  importc: "SDL_GetSurfaceAlphaMod".}
  ## Get the additional alpha value used in blit operations.
  ##
  ## `surface` The surface to query.
  ##
  ## `alpha` A pointer filled in with the current alpha value.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## **See also:**
  ## * `setAlphaMod proc<#setAlphaMod,SurfacePtr,uint8>`_

proc setSurfaceBlendMode*(surface: SurfacePtr; blendMode: BlendMode): cint {.
  importc: "SDL_SetSurfaceBlendMode".}
proc setBlendMode*(surface: SurfacePtr; blendMode: BlendMode): cint {.
  importc: "SDL_SetSurfaceBlendMode".}
  ## Set the blend mode used for blit operations.
  ##
  ## `surface` The surface to update.
  ##
  ## `blendMode` BlendMode to use for blit blending.
  ##
  ## `Return` `0` on success, or `-1` if the parameters are not valid.
  ##
  ## **See also:**
  ## * `getBlendMode proc<#getBlendMode,SurfacePtr,ptr.BlendMode>`_

proc getSurfaceBlendMode*(surface: SurfacePtr; blendMode: ptr BlendMode): cint {.
  importc: "SDL_GetSurfaceBlendMode".}
proc getBlendMode*(surface: SurfacePtr; blendMode: ptr BlendMode): cint {.
  importc: "SDL_GetSurfaceBlendMode".}
  ## Get the blend mode used for blit operations.
  ##
  ## `surface`   The surface to query.
  ##
  ## `blendMode` A pointer filled in with the current blend mode.
  ##
  ## `Return` `0` on success, or `-1` if the surface is not valid.
  ##
  ## **See also:**
  ## * `setBlendMode proc<#setBlendMode,SurfacePtr,BlendMode>`_


proc setClipRect*(surface: SurfacePtr; rect: ptr Rect): Bool32 {.
  importc: "SDL_SetClipRect".}
  ## Sets the clipping rectangle for the destination surface in a blit.
  ## If the clip rectangle is `nil`, clipping will be disabled.
  ## If the clip rectangle doesn't intersect the surface, the procedure will
  ## return `false` and blits will be completely clipped.  Otherwise the
  ## procedure returns `true` and blits to the surface will be clipped to
  ## the intersection of the surface area and the clipping rectangle.
  ##
  ## Note that blits are automatically clipped to the edges of the source
  ## and destination surfaces.

proc getClipRect*(surface: SurfacePtr; rect: ptr Rect) {.
  importc: "SDL_GetClipRect".}
  ## Gets the clipping rectangle for the destination surface in a blit.
  ##
  ## `rect` must be a pointer to a valid rectangle which will be filled
  ## with the correct values.


proc setClipRect*(renderer: RendererPtr; rect: ptr Rect): cint {.
  importc: "SDL_RenderSetClipRect".}
  ## Set the clip rectangle for the current target.
  ##
  ## `renderer` The renderer for which clip rectangle should be set.
  ##
  ## `rect` A pointer to the rectangle to set as the clip rectangle,
  ## or `nil` to disable clipping.
  ##
  ## `Return` `0` on success, or `-1` on error.
  ##
  ## **See also:**
  ## * `getClipRect proc<#getClipRect,RendererPtr,ptr.Rect>`_

proc getClipRect*(renderer: RendererPtr; rect: ptr Rect): cint {.
  importc: "SDL_RenderGetClipRect".}
  ## Get the clip rectangle for the current target.
  ##
  ## `renderer` The renderer from which clip rectangle should be queried.
  ##
  ## `rect` A pointer filled in with the current clip rectangle,
  ## relative to the viewport, or `nil` to disable clipping.
  ##
  ## **See also:**
  ## * `setClipRect proc<#setClipRect,SurfacePtr,ptr.Rect>`_

proc isClipEnabled*(renderer: RendererPtr): cint {.
  importc: "SDL_RenderIsClipEnabled".}
  ## Get whether clipping is enabled on the given renderer.
  ##
  ## `renderer` The renderer from which clip state should be queried.
  ##
  ## **See also:**
  ## * `getClipRect proc<#getClipRect,RendererPtr,ptr.Rect>`_


proc convertSurface*(src: SurfacePtr; fmt: ptr PixelFormat;
  flags: cint): SurfacePtr {.importc: "SDL_ConvertSurface".}
proc convert*(src: SurfacePtr; fmt: ptr PixelFormat;
  flags: cint): SurfacePtr {.importc: "SDL_ConvertSurface".}
  ## Creates a new surface of the specified format, and then copies and maps
  ## the given surface to it so the blit of the converted surface will be as
  ## fast as possible.  If this procedure fails, it returns `nil`.
  ##
  ## The `flags` parameter is passed to `createRGBSurface()` and has those
  ## semantics.  You can also pass `SDL_RLEACCEL` in the flags parameter and
  ## SDL will try to RLE accelerate colorkey and alpha blits in the resulting
  ## surface.

proc convertSurfaceFormat*(src: SurfacePtr; pixel_format,
  flags: uint32): SurfacePtr {.importc: "SDL_ConvertSurfaceFormat".}
proc convert*(src: SurfacePtr; pixel_format,
  flags: uint32): SurfacePtr {.importc: "SDL_ConvertSurfaceFormat".}

proc convertPixels*(width, height: cint; src_format: uint32; src: pointer;
  src_pitch: cint; dst_format: uint32; dst: pointer; dst_pitch: cint): cint {.
  importc: "SDL_ConvertPixels".}
  ## Copy a block of pixels of one format to another format.
  ##
  ## `Return` `0` on success, or `-1` if there was an error.

proc fillRect*(dst: SurfacePtr; rect: ptr Rect; color: uint32): SDL_Return {.
  importc: "SDL_FillRect", discardable.}
  ## Performs a fast fill of the given rectangle with `color`.
  ## If `rect` is `nil`, the whole surface will be filled with `color`.
  ## The color should be a pixel of the format used by the surface, and
  ## can be generated by the `mapRGB()` procedure.
  ##
  ## `Return` `0` on success, or `-1` on error.

proc fillRects*(dst: SurfacePtr; rects: ptr Rect; count: cint;
                    color: uint32): cint {.importc: "SDL_FillRects".}

proc upperBlit*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_UpperBlit".}
  ## This is the public blit procedure, `blitSurface()`, and it performs
  ## rectangle validation and clipping before passing it to `lowerBlit()`.

proc lowerBlit*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_LowerBlit".}
  ## This is a semi-private blit procedure and it performs low-level surface
  ## blitting only.


proc softStretch*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_SoftStretch".}
  ## Perform a fast, low quality, stretch blit between two surfaces of the
  ## same pixel format.
  ##
  ## **Note:** This procedure uses a static buffer, and is not thread-safe.


proc upperBlitScaled*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_UpperBlitScaled".}
  ## This is the public scaled blit procedure, `blitScaled()`,
  ## and it performs rectangle validation and clipping before
  ## passing it to `lowerBlitScaled()`.

proc lowerBlitScaled*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
  dstrect: ptr Rect): SDL_Return {.importc: "SDL_LowerBlitScaled".}
  ## This is a semi-private blit procedure and it performs low-level surface
  ## scaled blitting only.


proc readU8*(src: RWopsPtr): uint8 {.importc: "SDL_ReadU8".}
proc readLE16*(src: RWopsPtr): uint16 {.importc: "SDL_ReadLE16".}
proc readBE16*(src: RWopsPtr): uint16 {.importc: "SDL_ReadBE16".}
proc readLE32*(src: RWopsPtr): uint32 {.importc: "SDL_ReadLE32".}
proc readBE32*(src: RWopsPtr): uint32 {.importc: "SDL_ReadBE32".}
proc readLE64*(src: RWopsPtr): uint64 {.importc: "SDL_ReadLE64".}
proc readBE64*(src: RWopsPtr): uint64 {.importc: "SDL_ReadBE64".}
proc writeU8*(dst: RWopsPtr; value: uint8): csize_t {.importc: "SDL_WriteU8".}
proc writeLE16*(dst: RWopsPtr; value: uint16): csize_t {.importc: "SDL_WriteLE16".}
proc writeBE16*(dst: RWopsPtr; value: uint16): csize_t {.importc: "SDL_WriteBE16".}
proc writeLE32*(dst: RWopsPtr; value: uint32): csize_t {.importc: "SDL_WriteLE32".}
proc writeBE32*(dst: RWopsPtr; value: uint32): csize_t {.importc: "SDL_WriteBE32".}
proc writeLE64*(dst: RWopsPtr; value: uint64): csize_t {.importc: "SDL_WriteLE64".}
proc writeBE64*(dst: RWopsPtr; value: uint64): csize_t {.importc: "SDL_WriteBE64".}

proc showMessageBox*(messageboxdata: ptr MessageBoxData;
  buttonid: var cint): cint {.importc: "SDL_ShowMessageBox".}
  ## Create a modal message box.
  ##
  ## `messageboxdata` The `MessageBoxData` object with title, text, etc.
  ##
  ## `buttonid` The pointer to which user id of hit button should be copied.
  ##
  ## `Return` `-1` on error, otherwise `0` and `buttonid` contains user id
  ## of button hit or `-1` if dialog was closed.
  ##
  ## **Note:** This procedure should be called on the thread that created
  ## the parent window, or on the main thread if the messagebox has no parent.
  ## It will block execution of that thread until the user clicks a button or
  ## closes the messagebox.

proc showSimpleMessageBox*(flags: uint32; title, message: cstring;
  window: WindowPtr): cint {.importc: "SDL_ShowSimpleMessageBox".}
  ## Create a simple modal message box.
  ##
  ## `flags` `MessageBoxFlags`
  ##
  ## `title` UTF-8 title text
  ##
  ## `message` UTF-8 message text
  ##
  ## `window` The parent window, or `nil` for no parent
  ##
  ## `Return` `0` on success, `-1` on error
  ##
  ## **See also:**
  ## * `showMessageBox proc<#showMessageBox,ptr.MessageBoxData,cint>`_



proc getNumVideoDrivers*(): cint {.importc: "SDL_GetNumVideoDrivers".}
  ## Get the number of video drivers compiled into SDL.
  ##
  ## **See also:**
  ## * `getVideoDriver proc<#getVideoDriver,cint>`_

proc getVideoDriver*(index: cint): cstring {.importc: "SDL_GetVideoDriver".}
  ## Get the name of a built in video driver.
  ##
  ## **Note:** The video drivers are presented in the order in which they are
  ## normally checked during initialization.
  ##
  ## **See also:**
  ## * `getNumVideoDrivers proc<#getNumVideoDrivers>`_

proc videoInit*(driver_name: cstring): SDL_Return {.importc: "SDL_VideoInit".}
  ## Initialize the video subsystem, optionally specifying a video driver.
  ##
  ## `driver_name` Initialize a specific driver by name, or `nil` for the
  ## default video driver.
  ##
  ## `Return` `0` on success, `-1` on error.
  ##
  ## This procedure initializes the video subsystem; setting up a connection
  ## to the window manager, etc, and determines the available display modes
  ## and pixel formats, but does not initialize a window or graphics mode.
  ##
  ## **See also:**
  ## * `videoQuit proc<#videoQuit>`_

proc videoQuit*() {.importc: "SDL_VideoQuit".}
  ## Shuts down the video subsystem.
  ##
  ## This procedure closes all windows, and restores the original video mode.
  ##
  ## **See also:**
  ## * `videoInit proc<#videoInit,cstring>`_

proc getCurrentVideoDriver*(): cstring {.importc: "SDL_GetCurrentVideoDriver".}
  ## Returns the name of the currently initialized video driver.
  ##
  ## `Return` The name of the current video driver or `nil` if no driver
  ## has been initialized.
  ##
  ## **See also:**
  ## * `getNumVideoDrivers proc<#getNumVideoDrivers>`_
  ## * `getVideoDriver proc<#getVideoDriver,cint>`_

proc getNumVideoDisplays*(): cint {.importc: "SDL_GetNumVideoDisplays".}
  ## Returns the number of available video displays.
  ##
  ## **See also:**
  ## * `getDisplayBounds proc<#getDisplayBounds,cint,Rect>`_

proc getDisplayBounds*(displayIndex: cint; rect: var Rect): SDL_Return {.
  importc: "SDL_GetDisplayBounds".}
  ## Get the desktop area represented by a display,
  ## with the primary display located at `0,0`.
  ##
  ## `Return` `0` on success, or `-1` if the index is out of range.
  ##
  ## **See also:**
  ## * `getNumVideoDisplays proc<#getNumVideoDisplays>`_

proc getNumDisplayModes*(displayIndex: cint): cint {.
  importc: "SDL_GetNumDisplayModes".}
  ## Returns the number of available display modes.
  ##
  ## **See also:**
  ## * `getDisplayMode proc<#getDisplayMode,WindowPtr,DisplayMode>`_

proc getDisplayMode*(displayIndex: cint; modeIndex: cint;
  mode: var DisplayMode): SDL_Return {.importc: "SDL_GetDisplayMode".}
  ## Fill in information about a specific display mode.
  ##
  ## **Note:** The display modes are sorted in this priority:
  ## * `bits per pixel` -> more colors to fewer colors
  ## * `width` -> largest to smallest
  ## * `height` -> largest to smallest
  ## * `refresh rate` -> highest to lowest
  ##
  ## **See also:**
  ## * `getNumDisplayModes proc<#getNumDisplayModes,cint>`_

proc getDesktopDisplayMode*(displayIndex: cint;
  mode: var DisplayMode): SDL_Return {.importc: "SDL_GetDesktopDisplayMode".}
  ## Fill in information about the desktop display mode.

proc getCurrentDisplayMode*(displayIndex: cint;
  mode: var DisplayMode): SDL_Return {.importc: "SDL_GetCurrentDisplayMode".}
  ## Fill in information about the current display mode.

proc getClosestDisplayMode*(displayIndex: cint; mode: ptr DisplayMode;
                            closest: ptr DisplayMode): ptr DisplayMode {.
                            importc: "SDL_GetClosestDisplayMode".}
  ## Get the closest match to the requested display mode.
  ##
  ## `displayIndex` The index of display from which mode should be queried.
  ##
  ## `mode` The desired display mode.
  ##
  ## `closest` A pointer to a display mode to be filled in with the closest
  ## match of the available display modes.
  ##
  ## `Return` The passed in value `closest`, or `nil` if no matching
  ## video mode was available.
  ##
  ## The available display modes are scanned, and `closest` is filled
  ## in with the closest mode matching the requested mode and returned.
  ## The mode `format` and `refresh_rate` default to the desktop mode
  ## if they are `0`.
  ##
  ## The modes are scanned with size being first priority, `format` being
  ## second priority, and finally checking the `refresh_rate`.  If all the
  ## available modes are too small, then `nil` is returned.
  ##
  ## **See also:**
  ## * `getNumDisplayModes proc<#getNumDisplayModes,cint>`_
  ## * `getDisplayMode proc<#getDisplayMode,WindowPtr,DisplayMode>`_

proc getDisplayDPI*(displayIndex: cint;
  ddpi, hdpi, vdpi: ptr cfloat): SDL_Return {.importc: "SDL_GetDisplayDPI".}
  ## Get the dots/pixels-per-inch for a display.
  ##
  ## **Note:** Diagonal, horizontal and vertical DPI can all be optionally
  ## returned if the parameter is non-nil.
  ##
  ## `Return` `0` on success, or `-1` if no DPI information is available
  ## or the index is out of range.
  ##
  ## **See also:**
  ## * `getNumVideoDisplays proc<#getNumVideoDisplays>`_

proc createWindow*(title: cstring; x, y, w, h: cint;
                   flags: uint32): WindowPtr  {.importc: "SDL_CreateWindow".}
  ## Create a window with the specified position, dimensions, and flags.
  ##
  ## `title` The title of the window, in UTF-8 encoding.
  ##
  ## `x` The x position of the window,
  ## `SDL_WINDOWPOS_CENTERED`, or `SDL_WINDOWPOS_UNDEFINED`.
  ##
  ## `y` The y position of the window,
  ## `SDL_WINDOWPOS_CENTERED`, or `SDL_WINDOWPOS_UNDEFINED`.
  ##
  ## `w` The width of the window, in screen coordinates.
  ##
  ## `h` The height of the window, in screen coordinates.
  ##
  ## `flags` The flags for the window, a mask of any of the following:
  ## * `SDL_WINDOW_FULLSCREEN`,
  ## * `SDL_WINDOW_OPENGL`,
  ## * `SDL_WINDOW_HIDDEN`,
  ## * `SDL_WINDOW_BORDERLESS`,
  ## * `SDL_WINDOW_RESIZABLE`,
  ## * `SDL_WINDOW_MAXIMIZED`,
  ## * `SDL_WINDOW_MINIMIZED`,
  ## * `SDL_WINDOW_INPUT_GRABBED`,
  ## * `SDL_WINDOW_ALLOW_HIGHDPI`,
  ## * `SDL_WINDOW_VULKAN`,
  ##
  ## `Return` the id of the window created,
  ## or `nil` if window creation failed.
  ##
  ## If the window is created with the `SDL_WINDOW_ALLOW_HIGHDPI` flag, its size
  ## in pixels may differ from its size in screen coordinates on platforms with
  ## high-DPI support (e.g. iOS and Mac OS X). Use `getSize()` to query
  ## the client area's size in screen coordinates, and `glGetDrawableSize()`,
  ## `vulkanGetDrawableSize()`, or `getRendererOutputSize()`
  ## to query the drawable size in pixels.
  ##
  ## If the window is created with any of the `SDL_WINDOW_OPENGL` or
  ## `SDL_WINDOW_VULKAN` flags, then the corresponding `loadLibrary` function
  ## (`glLoadLibrary` or `vulkanLoadLibrary`) is called and the
  ## corresponding `UnloadLibrary` function is called by
  ## `destroyWindow()`.
  ##
  ## If `SDL_WINDOW_VULKAN` is specified and there isn't a working Vulkan driver,
  ## `createWindow()` will fail because `vulkanLoadLibrary()` will fail.
  ##
  ## If `WINDOW_METAL` is specified on an OS that does not support Metal,
  ## `createWindow()` will fail.
  ##
  ## **Note:** On non-Apple devices, SDL requires you to either not link to the
  ## Vulkan loader or link to a dynamic library version. This limitation
  ## may be removed in a future version of SDL.
  ##
  ## **See also:**
  ## * `destroy proc<#destroy,WindowPtr>`_
  ## * `glLoadLibrary proc<#glLoadLibrary,cstring>`_
  ## * `vulkanLoadLibrary proc<#vulkanLoadLibrary,cstring>`_
  # TODO: Add `SDL_WINDOW_METAL`


proc createWindowFrom*(data: pointer): WindowPtr {.importc: "SDL_CreateWindowFrom".}
  ## Create an SDL window from an existing native window.
  ##
  ## `data` A pointer to driver-dependent window creation data.
  ##
  ## `Return` the id of the window created,
  ## or `nil` if window creation failed.
  ##
  ## **See also:**
  ## * `destroy proc<#destroy,WindowPtr>`_

proc getWindowFromID*(id: uint32): WindowPtr {.importc: "SDL_GetWindowFromID".}
  ## Get a window from a stored ID, or `nil` if it doesn't exist.

proc showWindow*(window: WindowPtr) {.importc: "SDL_ShowWindow".}
proc show*(window: WindowPtr) {.importc: "SDL_ShowWindow".}
  ## Show a window.
  ##
  ## **See also:**
  ## * `hide proc<#hide,WindowPtr>`_

proc hideWindow*(window: WindowPtr) {.importc: "SDL_HideWindow".}
proc hide*(window: WindowPtr) {.importc: "SDL_HideWindow".}
  ## Hide a window.
  ##
  ## **See also:**
  ## * `show proc<#show,WindowPtr>`_

proc raiseWindow*(window: WindowPtr) {.importc: "SDL_RaiseWindow".}
  ## Raise a window above other windows and set the input focus.

proc maximizeWindow*(window: WindowPtr) {.importc: "SDL_MaximizeWindow".}
proc maximize*(window: WindowPtr) {.importc: "SDL_MaximizeWindow".}
  ## Make a window as large as possible.
  ##
  ## **See also:**
  ## * `restore proc<#restore,WindowPtr>`_

proc minimizeWindow*(window: WindowPtr) {.importc: "SDL_MinimizeWindow".}
proc minimize*(window: WindowPtr) {.importc: "SDL_MinimizeWindow".}
  ## Minimize a window to an iconic representation.
  ##
  ## **See also:**
  ## * `restore proc<#restore,WindowPtr>`_


proc restoreWindow*(window: WindowPtr) {.importc: "SDL_RestoreWindow".}
proc restore*(window: WindowPtr) {.importc: "SDL_RestoreWindow".}
  ## Restore the size and position of a minimized or maximized window.
  ##
  ## **See also:**
  ## * `maximize proc<#maximize,WindowPtr>`_
  ## * `minimize proc<#minimize,WindowPtr>`_


proc destroyWindow*(window: WindowPtr) {.importc: "SDL_DestroyWindow".}
  ## Destroy a window.

proc isScreenSaverEnabled*(): Bool32 {.importc: "SDL_IsScreenSaverEnabled".}
  ## Returns whether the screensaver is currently enabled (default off).
  ##
  ## **See also:**
  ## * `enableScreenSaver proc<#enableScreenSaver>`_
  ## * `disableScreenSaver proc<#disableScreenSaver>`_

proc enableScreenSaver*() {.importc: "SDL_EnableScreenSaver".}
  ## Allow the screen to be blanked by a screensaver.
  ##
  ## **See also:**
  ## * `isScreenSaverEnabled proc<#isScreenSaverEnabled>`_
  ## * `disableScreenSaver proc<#disableScreenSaver>`_

proc disableScreenSaver*() {.importc: "SDL_DisableScreenSaver".}
  ## Prevent the screen from being blanked by a screensaver.
  ##
  ## **See also:**
  ## * `isScreenSaverEnabled proc<#isScreenSaverEnabled>`_
  ## * `enableScreenSaver proc<#enableScreenSaver>`_


proc getTicks*(): uint32 {.importc: "SDL_GetTicks".}
  ## Get the number of milliseconds since the SDL library initialization.
  ## This value wraps if the program runs for more than ~49 days.

proc getPerformanceCounter*(): uint64 {.importc: "SDL_GetPerformanceCounter".}
  ## Get the current value of the high resolution counter.

proc getPerformanceFrequency*(): uint64 {.importc: "SDL_GetPerformanceFrequency".}
  ## Get the count per second of the high resolution counter.

proc delay*(ms: uint32) {.importc: "SDL_Delay".}
  ## Wait a specified number of milliseconds before returning.

proc addTimer*(interval: uint32; callback: TimerCallback;
      param: pointer): TimerID {.importc: "SDL_AddTimer".}
  ## Add a new timer to the pool of timers already running.
  ##
  ## `Return` a timer ID, or `0` when an error occurs.

proc removeTimer*(id: TimerID): Bool32 {.importc: "SDL_RemoveTimer".}
  ## Remove a timer knowing its ID.
  ##
  ## `Return` a boolean value indicating success or failure.
  ##
  ## `Warning:` It is not safe to remove a timer multiple times.


proc glLoadLibrary*(path: cstring): SDL_Return {.discardable,
  importc: "SDL_GL_LoadLibrary".}
  ## Dynamically load an OpenGL library.
  ##
  ## `path` The platform dependent OpenGL library name,
  ## or `nil` to open the default OpenGL library.
  ##
  ## `Return` `0` on success, or `-1` if the library couldn't be loaded.
  ##
  ## This should be done after initializing the video driver, but before
  ## creating any OpenGL windows.  If no OpenGL library is loaded, the default
  ## library will be loaded upon creation of the first OpenGL window.
  ##
  ## **Note:** If you do this, you need to retrieve
  ## all of the GL procedures used in your program
  ## from the dynamic library using `glGetProcAddress()`.
  ##
  ## **See also:**
  ## * `glGetProcAddress proc<#glGetProcAddress,cstring>`_
  ## * `glUnloadLibrary proc<#glUnloadLibrary>`_


proc glGetProcAddress*(procedure: cstring): pointer {.
  importc: "SDL_GL_GetProcAddress".}
  ## Get the address of an OpenGL procedure.

proc glUnloadLibrary* {.importc: "SDL_GL_UnloadLibrary".}
  ## Unload the OpenGL library previously loaded by `glLoadLibrary()`.
  ##
  ## **See also:**
  ## * `glLoadLibrary proc<#glLoadLibrary,cstring>`_

proc glExtensionSupported*(extension: cstring): bool {.
  importc: "SDL_GL_ExtensionSupported".}
  ## `Return` `true` if an OpenGL extension is supported
  ## for the current context.


proc glSetAttribute*(attr: GLattr; value: cint): cint {.
  importc: "SDL_GL_SetAttribute".}
  ## Set an OpenGL window attribute before window creation.
  ##
  ## `Return` `0` on success, or `-1` if the attribute could not be set.


proc glGetAttribute*(attr: GLattr; value: var cint): cint {.
  importc: "SDL_GL_GetAttribute".}
  ## Get the actual value for an attribute from the current context.
  ##
  ## `Return` `0` on success,
  ## or `-1` if the attribute could not be retrieved.
  ## The integer at `value` will be modified in either case.

proc glCreateContext*(window: WindowPtr): GlContextPtr {.
  importc: "SDL_GL_CreateContext".}
  ## Create an OpenGL context for use with an OpenGL window,
  ## and make it current.
  ##
  ## **See also:**
  ## * `glDeleteContext proc<#glDeleteContext,GLContextPtr>`_

proc glMakeCurrent*(window: WindowPtr; context: GlContextPtr): cint {.
  importc: "SDL_GL_MakeCurrent".}
  ## Set up an OpenGL context for rendering into an OpenGL window.
  ##
  ## **Note:** The context must have been created with a compatible window.

proc glGetCurrentWindow*: WindowPtr {.importc: "SDL_GL_GetCurrentWindow".}
  ## Get the currently active OpenGL window.

proc glGetCurrentContext*: GlContextPtr {.importc: "SDL_GL_GetCurrentContext".}
  ## Get the currently active OpenGL context.

proc glGetDrawableSize*(window: WindowPtr; w,h: var cint) {.
  importc: "SDL_GL_GetDrawableSize".}
  ## Get the size of a window's underlying drawable in pixels
  ## (for use with glViewport).
  ##
  ## `window` Window from which the drawable size should be queried.
  ##
  ## `w` Pointer to variable for storing the width in pixels, may be `nil`.
  ##
  ## `h` Pointer to variable for storing the height in pixels, may be `nil`.
  ##
  ## This may differ from `getSize()` if we're rendering to a high-DPI
  ## drawable, i.e. the window was created with `SDL_WINDOW_ALLOW_HIGHDPI` on a
  ## platform with high-DPI support (Apple calls this "Retina"), and not
  ## disabled by the `HINT_VIDEO_HIGHDPI_DISABLED` hint.
  ##
  ## **See also:**
  ## * `getSize proc<#getSize,WindowPtr,cint,cint>`_
  ## * `createWindow proc<#createWindow,cstring,cint,cint,cint,cint,uint32>`_
  # TODO: Add `HINT_VIDEO_HIGHDPI_DISABLED`

proc glSetSwapInterval*(interval: cint): cint {.
  importc: "SDL_GL_SetSwapInterval".}
  ## Set the swap interval for the current OpenGL context.
  ##
  ## `interval` `0` for immediate updates, `1` for updates synchronized
  ## with the vertical retrace. If the system supports it, you may specify
  ## `-1` to allow late swaps to happen immediately instead of waiting for
  ## the next retrace.
  ##
  ## `Return` `0` on success, or `-1` if setting the swap interval
  ## is not supported.
  ##
  ## **See also:**
  ## * `glGetSwapInterval proc<#glGetSwapInterval>`_

proc glGetSwapInterval*: cint {.importc: "SDL_GL_GetSwapInterval".}
  ## Get the swap interval for the current OpenGL context.
  ##
  ## `Return` `0` if there is no vertical retrace synchronization,
  ## `1` if the buffer swap is synchronized with the vertical retrace, and
  ## `-1` if late swaps happen immediately instead of waiting for the next
  ## retrace. If the system can't determine the swap interval, or there isn't
  ## a valid current context, this will return `0` as a safe default.
  ##
  ## **See also:**
  ## * `glSetSwapInterval proc<#glSetSwapInterval,cint>`_

proc glSwapWindow*(window: WindowPtr) {.importc: "SDL_GL_SwapWindow".}
  ## Swap the OpenGL buffers for a window, if double-buffering is supported.

proc glDeleteContext*(context: GlContextPtr) {.importc: "SDL_GL_DeleteContext".}
  ## Delete an OpenGL context.
  ##
  ## **See also:**
  ## * `glCreateContext proc<#glCreateContext,WindowPtr>`_

# SDL_vulkan.h
type VkHandle = int64
type VkNonDispatchableHandle = int64

# Skipped using Vk prefix to stop any potential name clashes with the Vulkan library
type VulkanInstance* = VkHandle
type VulkanSurface* = VkNonDispatchableHandle


proc vulkanLoadLibrary*(path: cstring): cint {.
  importc: "SDL_Vulkan_LoadLibrary".}
  ## Dynamically load a Vulkan loader library.
  ##
  ## `path` The platform dependent Vulkan loader library name, or `nil`.
  ##
  ## `Return` `0` on success, or `-1` if the library couldn't be loaded.
  ##
  ## If `path` is `nil` SDL will use the value of the environment variable
  ## `SDL_VULKAN_LIBRARY`, if set, otherwise it loads the default Vulkan
  ## loader library.
  ##
  ## This should be called after initializing the video driver, but before
  ## creating any Vulkan windows. If no Vulkan loader library is loaded, the
  ## default library will be loaded upon creation of the first Vulkan window.
  ##
  ## **Note:** It is fairly common for Vulkan applications to link with
  ## `libvulkan` instead of explicitly loading it at run time. This will
  ## work with SDL provided the application links to a dynamic library and
  ## both it and SDL use the same search path.
  ##
  ## **Note:** If you specify a non-`nil` `path`, an application should
  ## retrieve all of the Vulkan procedures it uses from the dynamic library
  ## using `vulkanGetVkGetInstanceProcAddr()` unless you can guarantee
  ## `path` points to the same vulkan loader library the application
  ## linked to.
  ##
  ## **Note:** On Apple devices, if `path` is `nil`, SDL will attempt to find
  ## the `vkGetInstanceProcAddr` address within all the mach-o images of
  ## the current process. This is because it is fairly common for Vulkan
  ## applications to link with libvulkan (and historically MoltenVK was
  ## provided as a static library). If it is not found then, on macOS, SDL
  ## will attempt to load `vulkan.framework/vulkan`, `libvulkan.1.dylib`,
  ## followed by `libvulkan.dylib`, in that order.
  ## On iOS SDL will attempt to load `libvulkan.dylib` only. Applications
  ## using a dynamic framework or .dylib must ensure it is included in its
  ## application bundle.
  ##
  ## **Note:** On non-Apple devices, application linking with a static
  ## libvulkan is not supported. Either do not link to the Vulkan loader or
  ## link to a dynamic library version.
  ##
  ## **Note:** This procedures will fail if there are no working Vulkan drivers
  ## installed.
  ##
  ## **See also:**
  ## * `vulkanGetVkGetInstanceProcAddr proc<#vulkanGetVkGetInstanceProcAddr>`_
  ## * `vulkanUnloadLibrary proc<#vulkanUnloadLibrary>`_

proc vulkanGetVkGetInstanceProcAddr*(): pointer {.
  importc: "SDL_Vulkan_GetVkGetInstanceProcAddr".}
  ## Get the address of the `vkGetInstanceProcAddr` procedure.
  ##
  ## **Note:** This should be called after either calling `vulkanLoadLibrary`
  ## or creating a `Window` with the `SDL_WINDOW_VULKAN` flag.

proc vulkanUnloadLibrary*() {.importc: "SDL_Vulkan_UnloadLibrary".}
  ## Unload the Vulkan loader library previously loaded by
  ## `vulkanLoadLibrary()`.
  ##
  ## **See also:**
  ## * `vulkanLoadLibrary proc<#vulkanLoadLibrary,cstring>`_

proc vulkanGetInstanceExtensions*(window: WindowPtr, pCount: ptr cuint,
  pNames: cstringArray): Bool32 {.importc: "SDL_Vulkan_GetInstanceExtensions".}
  ## Get the names of the Vulkan instance extensions needed to create
  ## a surface with `vulkan_CreateSurface()`.
  ##
  ## `window` `nil` or window for which the required Vulkan instance
  ## extensions should be retrieved.
  ##
  ## `pCount` Pointer to an `cuint` related to the number of
  ## required Vulkan instance extensions.
  ##
  ## `pNames` `nil` or a pointer to an array to be filled with the
  ## required Vulkan instance extensions.
  ##
  ## `Return` `true` on success, `false` on error.
  ##
  ## If `pNames` is `nil`, then the number of required Vulkan instance
  ## extensions is returned in `pCount`. Otherwise, `pCount` must point
  ## to a variable set to the number of elements in the `pNames` array,
  ## and on return the variable is overwritten with the number of names
  ## actually written to `pNames`. If `pCount` is less than the number
  ## of required extensions, at most `pCount` structures will be written.
  ## If `pCount` is smaller than the number of required extensions,
  ## `0` will be returned instead `1`, to indicate that not all the required
  ## extensions were returned.
  ##
  ## **Note:** If `window` is not `nil`, it will be checked against its
  ## creation flags to ensure that the Vulkan flag is present. This parameter
  ## will be removed in a future major release.
  ##
  ## **Note:** The returned list of extensions will contain VK_KHR_surface
  ## and zero or more platform specific extensions
  ##
  ## **Note:** The extension names queried here must be enabled when calling
  ## `vulkanCreateInstance`, otherwise surface creation will fail.
  ##
  ## **Note:** `window` should have been created with the
  ## `SDL_WINDOW_VULKAN` flag or be `nil`.
  ##
  ## **See also:**
  ## * `vulkanCreateSurface proc<#vulkanCreateSurface,WindowPtr,VulkanInstance,ptr.VulkanSurface>`_

proc vulkanCreateSurface*(window: WindowPtr, instance: VulkanInstance, surface: ptr VulkanSurface): Bool32 {.
  importc: "SDL_Vulkan_CreateSurface".}
  ## Create a Vulkan rendering surface for a window.
  ##
  ## `window`    `Window` to which to attach the rendering surface.
  ##
  ## `instance`  Handle to the Vulkan instance to use.
  ##
  ## `surface`   receives the handle of the newly created surface.
  ##
  ## `Return` `true` on success, `false` on error.
  ##
  ## .. code-block:: nim
  ##   var
  ##     instance: VulkanInstance
  ##     window: WindowPtr
  ##
  ##   # create instance and window
  ##
  ##   # create the Vulkan surface
  ##   var surface: VulkanSurface
  ##   if not vulkanCreateSurface(window, instance, addr(surface)):
  ##     handleError()
  ##
  ## **Note:** `window` should have been created with the
  ## `SDL_WINDOW_VULKAN` flag.
  ##
  ## **Note:** `instance` should have been created with the
  ## extensions returned by `vulkanCreateSurface()` enabled.
  ##
  ## **See also:**
  ## * `vulkanGetInstanceExtensions proc<#vulkanGetInstanceExtensions,WindowPtr,ptr.cuint,cstringArray>`_

proc vulkanGetDrawableSize*(window: WindowPtr, w, h: ptr cint) {.
  importc: "SDL_Vulkan_GetDrawableSize".}
  ## Get the size of a window's underlying drawable in pixels
  ## (for use with setting viewport, scissor & etc).
  ##
  ## `window`  `Window` from which the drawable size should be queried.
  ##
  ## `w`       Pointer to variable for storing the width in pixels,
  ## may be `nil`.
  ##
  ## `h`       Pointer to variable for storing the height in pixels,
  ## may be `nil`.
  ##
  ## This may differ from `getSize()` if we're rendering to a high-DPI
  ## drawable, i.e. the window was created with `WINDOW_ALLOW_HIGHDPI` on a
  ## platform with high-DPI support (Apple calls this "Retina"),
  ## and not disabled by the `HINT_VIDEO_HIGHDPI_DISABLED` hint.
  ##
  ## **Note:** On macOS high-DPI support must be enabled for an application by
  ## setting `NSHighResolutionCapable` to `true` in its `Info.plist`.
  ##
  ## **See also:**
  ## * `getSize proc<#getSize,WindowPtr,cint,cint>`_
  ## * `createWindow proc<#createWindow,cstring,cint,cint,cint,cint,uint32>`_

# SDL_keyboard.h:
proc getKeyboardFocus*: WindowPtr {.importc: "SDL_GetKeyboardFocus".}
  ## Get the window which currently has keyboard focus.

proc getKeyboardState*(numkeys: ptr int = nil): ptr array[0 .. SDL_NUM_SCANCODES.int, uint8] {.importc: "SDL_GetKeyboardState".}
  ## Get a snapshot of the current state of the keyboard.
  ##
  ## `numkeys` if non-`nil`, receives the length of the returned array.
  ##
  ## `Return` an array of key states. Indexes into this array are obtained
  ## by using `Scancode` values.
  ##
  ## Example:
  ##
  ## .. code-block:: nim
  ##   let state = getKeyboardState(nil)
  ##   if state[SCANCODE_RETURN.int] > 0:
  ##     echo "<RETURN> is pressed."

proc getModState*: Keymod {.importc: "SDL_GetModState".}
  ## Get the current key modifier state for the keyboard

proc setModState*(state: Keymod) {.importc: "SDL_SetModState".}
  ## Set the current key modifier state for the keyboard.
  ##
  ## **Note:** This does not change the keyboard state,
  ## only the key modifier flags.

proc getKeyFromScancode*(scancode: ScanCode): cint {.importc: "SDL_GetKeyFromScancode".}
  ## Get the key code corresponding to the given scancode according
  ## to the current keyboard layout.
  ##
  ## See `Keycode` for details.
  ##
  ## **See also:**
  ## * `getKeyName proc<#getKeyName,cint>`_

proc getScancodeFromKey*(key: cint): ScanCode {.importc: "SDL_GetScancodeFromKey".}
  ## Get the scancode corresponding to the given key code
  ## according to the current keyboard layout.
  ##
  ## See `Scancode` for details.
  ##
  ## **See also:**
  ## * `getScancodeName proc<#getScancodeName,ScanCode>`_

proc getScancodeName*(scancode: ScanCode): cstring {.importc: "SDL_GetScancodeName".}
  ## Get a human-readable name for a scancode.
  ##
  ## `Return` a pointer to the name for the scancode.
  ## If the scancode doesn't have a name, this procedure
  ## returns an empty string ("").
  ##
  ## **See also:**
  ## * `ScanCode type<#ScanCode>`_

proc getScancodeFromName*(name: cstring): ScanCode {.importc: "SDL_GetScancodeFromName".}
  ## Get a scancode from a human-readable name.
  ##
  ## `Return` scancode, or `SDL_SCANCODE_UNKNOWN` if the name wasn't recognized.
  ##
  ## **See also:**
  ## * `ScanCode type<#ScanCode>`_

proc getKeyName*(key: cint): cstring {.importc: "SDL_GetKeyName".}
  ## Get a human-readable name for a key.
  ##
  ## `Return` a pointer to a UTF-8 string that stays valid at least until
  ## the next call to this procedure. If you need it around any longer,
  ## you must copy it. If the key doesn't have a name, this procedure returns
  ## an empty string ("").

proc getKeyFromName*(name: cstring): cint {.importc: "SDL_GetKeyFromName".}
  ## Get a key code from a human-readable name.
  ##
  ## `Return` key code, or `K_UNKNOWN` if the name wasn't recognized.

proc startTextInput* {.importc: "SDL_StartTextInput".}
  ## Start accepting Unicode text input events.
  ##
  ## This procedure will show the on-screen keyboard if supported.
  ##
  ## **See also:**
  ## * `stopTextInput proc<#stopTextInput>`_
  ## * `setTextInputRect proc<#setTextInputRect,ptr.Rect>`_
  ## * `hasScreenKeyboardSupport proc<#hasScreenKeyboardSupport>`_

proc isTextInputActive*: bool {.importc: "SDL_IsTextInputActive".}
  ## Return whether or not Unicode text input events are enabled.
  ##
  ## **See also:**
  ## * `startTextInput proc<#startTextInput>`_
  ## * `stopTextInput proc<#stopTextInput>`_

proc stopTextInput* {.importc: "SDL_StopTextInput".}
  ## Stop receiving any text input events.
  ##
  ## This procedure will hide the on-screen keyboard if supported.
  ##
  ## **See also:**
  ## * `startTextInput proc<#startTextInput>`_
  ## * `hasScreenKeyboardSupport proc<#hasScreenKeyboardSupport>`_

proc setTextInputRect*(rect: ptr Rect) {.importc: "SDL_SetTextInputRect".}
  ## Set the rectangle used to type Unicode text inputs.
  ##
  ## This is used as a hint for IME and on-screen keyboard placement.
  ##
  ## **See also:**
  ## * `startTextInput proc<#startTextInput>`_

proc hasScreenKeyboardSupport*: bool {.importc: "SDL_HasScreenKeyboardSupport".}
  ## Returns whether the platform has some screen keyboard support.
  ##
  ## `Return` `true` if some keyboard support is available else `false`.
  ##
  ## **Note:** Not all screen keyboard procedures are supported
  ## on all platforms.
  ##
  ## **See also:**
  ## * `isScreenKeyboardShown proc<#isScreenKeyboardShown,WindowPtr>`_

proc isScreenKeyboardShown*(window: WindowPtr): bool {.importc: "SDL_IsScreenKeyboardShown".}
  ## Returns whether the screen keyboard is shown for given window.
  ##
  ## `window` The window for which screen keyboard should be queried.
  ##
  ## `Return` `true` if screen keyboard is shown else `false`.
  ##
  ## **See also:**
  ## * `hasScreenKeyboardSupport proc<#hasScreenKeyboardSupport>`_



proc getMouseFocus*(): WindowPtr {.importc: "SDL_GetMouseFocus".}
  ## Get the window which currently has mouse focus.

proc getMouseState*(x, y: var cint): uint8 {.importc: "SDL_GetMouseState", discardable.}

proc getMouseState*(x, y: ptr cint): uint8 {.importc: "SDL_GetMouseState", discardable.}
  ## Retrieve the current state of the mouse.
  ##
  ## The current button state is returned as a button bitmask, which can
  ## be tested using the `button()` template, and `x` and `y` are set to the
  ## mouse cursor position relative to the focus window for the currently
  ## selected mouse.  You can pass `nil` for either `x` or `y`.

proc getRelativeMouseState*(x, y: var cint): uint8 {.
  importc: "SDL_GetRelativeMouseState".}
  ## Retrieve the relative state of the mouse.
  ##
  ## The current button state is returned as a button bitmask, which can
  ## be tested using the `button()` template, and x and y are set to the
  ## mouse deltas since the last call to `getRelativeMouseState()`.

proc warpMouseInWindow*(window: WindowPtr; x, y: cint)  {.
  importc: "SDL_WarpMouseInWindow".}
proc warpMouse*(window: WindowPtr; x, y: cint)  {.
  importc: "SDL_WarpMouseInWindow".}
  ## Moves the mouse to the given position within the window.
  ##
  ## `window` The window to move the mouse into,
  ## or `nil` for the current mouse focus
  ##
  ## `x` The x coordinate within the window
  ##
  ## `y` The y coordinate within the window
  ##
  ## **Note:** This procedure generates a mouse motion event.

proc setRelativeMouseMode*(enabled: Bool32): SDL_Return  {.
  importc: "SDL_SetRelativeMouseMode".}
  ## Set relative mouse mode.
  ##
  ## `enabled` Whether or not to enable relative mode
  ##
  ## `Return` `0` on success, or `-1` if relative mode is not supported.
  ##
  ## While the mouse is in relative mode, the cursor is hidden, and the
  ## driver will try to report continuous motion in the current window.
  ## Only relative motion events will be delivered, the mouse position
  ## will not change.
  ##
  ## **Note:** This procedure will flush any pending mouse motion.
  ##
  ## **See also:**
  ## * `getRelativeMouseMode proc<#getRelativeMouseMode>`_

proc captureMouse*(enabled: Bool32): SDL_Return {.
  importc: "SDL_CaptureMouse" .}
  ## Capture the mouse, to track input outside an SDL window.
  ##
  ## `enabled` Whether or not to enable capturing
  ##
  ## Capturing enables your app to obtain mouse events globally, instead of
  ## just within your window. Not all video targets support this procedure.
  ## When capturing is enabled, the current window will get all mouse events,
  ## but unlike relative mode, no change is made to the cursor and it is
  ## not restrained to your window.
  ##
  ## This procedure may also deny mouse input to other windows - both those in
  ## your application and others on the system - so you should use this
  ## procedure sparingly, and in small bursts. For example, you might want to
  ## track the mouse while the user is dragging something, until the user
  ## releases a mouse button. It is not recommended that you capture the mouse
  ## for long periods of time, such as the entire time your app is running.
  ##
  ## While captured, mouse events still report coordinates relative to the
  ## current (foreground) window, but those coordinates may be outside the
  ## bounds of the window (including negative values). Capturing is only
  ## allowed for the foreground window. If the window loses focus while
  ## capturing, the capture will be disabled automatically.
  ##
  ## While capturing is enabled, the current window will have the
  ## `SDL_WINDOW_MOUSE_CAPTURE` flag set.
  ##
  ## `Return` `0` on success, or `-1` if not supported.

proc getRelativeMouseMode*(): Bool32 {.importc: "SDL_GetRelativeMouseMode".}
  ## Query whether relative mouse mode is enabled.
  ##
  ## **See also:**
  ## * `setRelativeMouseMode proc<#setRelativeMouseMode,Bool32>`_

proc createCursor*(data, mask: ptr uint8;
  w, h, hot_x, hot_y: cint): CursorPtr {.importc: "SDL_CreateCursor".}
  ## Create a cursor, using the specified bitmap data and mask (in MSB format).
  ##
  ## The cursor width must be a multiple of 8 bits.
  ##
  ## The cursor is created in black and white according to the following:
  ##
  ## ::
  ##   ====  ====  ========================================
  ##   data  mask  resulting pixel on screen
  ##   ====  ====  ========================================
  ##   0     1     White
  ##   1     1     Black
  ##   0     0     Transparent
  ##   1     0     Inverted color if possible, black if not.
  ##   ====  ====  =========================================
  ##
  ## **See also:**
  ## * `freeCursor proc<#freeCursor,CursorPtr>`_

proc createColorCursor*(surface: SurfacePtr; hot_x, hot_y: cint): CursorPtr {.
  importc: "SDL_CreateColorCursor".}
  ## Create a color cursor.
  ##
  ## **See also:**
  ## * `freeCursor proc<#freeCursor,CursorPtr>`_

type
  SystemCursor* = enum
    ## Cursor types for `sdl.createSystemCursor()`.
    SDL_SYSTEM_CURSOR_ARROW,     ## Arrow
    SDL_SYSTEM_CURSOR_IBEAM,     ## I-beam
    SDL_SYSTEM_CURSOR_WAIT,      ## Wait
    SDL_SYSTEM_CURSOR_CROSSHAIR, ## Crosshair
    SDL_SYSTEM_CURSOR_WAITARROW, ## Small wait cursor (or Wait if not available)
    SDL_SYSTEM_CURSOR_SIZENWSE,  ## Double arrow pointing northwest and southeast
    SDL_SYSTEM_CURSOR_SIZENESW,  ## Double arrow pointing northeast and southwest
    SDL_SYSTEM_CURSOR_SIZEWE,    ## Double arrow pointing west and east
    SDL_SYSTEM_CURSOR_SIZENS,    ## Double arrow pointing north and south
    SDL_SYSTEM_CURSOR_SIZEALL,   ## Four pointed arrow pointing north, south, east, and west
    SDL_SYSTEM_CURSOR_NO,        ## Slashed circle or crossbones
    SDL_SYSTEM_CURSOR_HAND       ## Hand

proc createSystemCursor*(c: SystemCursor): CursorPtr {.
  importc: "SDL_CreateSystemCursor".}
  ## Create a system cursor.
  ##
  ## **See also:**
  ## * `freeCursor proc<#freeCursor,CursorPtr>`_

proc setCursor*(cursor: CursorPtr) {.importc: "SDL_SetCursor".}
  ## Set the active cursor.

proc getCursor*(): CursorPtr {.importc: "SDL_GetCursor".}
  ## Return the active cursor.

proc freeCursor*(cursor: CursorPtr) {.importc: "SDL_FreeCursor".}
  ## Frees a cursor created with `createCursor()` or similar procedures.
  ##
  ## **See also:**
  ## * `createCursor proc<#createCursor,ptr.uint8,cint,cint,cint,cint>`_
  ## * `createColorCursor proc<#createColorCursor,SurfacePtr,cint,cint>`_
  ## * `createSystemCursor proc<#createSystemCursor,SystemCursor>`_

proc showCursor*(toggle: bool): Bool32 {.importc: "SDL_ShowCursor", discardable.}
  ## Toggle whether or not the cursor is shown.
  ##
  ## `toggle` `1` to show the cursor, `0` to hide it,
  ## `-1` to query the current state.
  ##
  ## `Return` `1` if the cursor is shown, or `0` if the cursor is hidden.


# Function prototypes

proc pumpEvents*() {.importc: "SDL_PumpEvents".}
  ## Pumps the event loop, gathering events from the input devices.
  ##
  ## This procedure updates the event queue and internal input device state.
  ##
  ## This should only be run in the thread that sets the video mode.

proc peepEvents*(events: ptr Event; numevents: cint; action: Eventaction;
  minType: uint32; maxType: uint32): cint {.importc: "SDL_PeepEvents".}
  ## Checks the event queue for messages and optionally returns them.
  ##
  ## If `action` is `SDL_ADDEVENT`, up to `numevents` events will be added to
  ## the back of the event queue.
  ##
  ## If `action` is `SDL_PEEKEVENT`, up to `numevents` events at the front
  ## of the event queue, within the specified minimum and maximum type,
  ## will be returned and will not be removed from the queue.
  ##
  ## If `action` is `SDL_GETEVENT`, up to `numevents` events at the front
  ## of the event queue, within the specified minimum and maximum type,
  ## will be returned and will be removed from the queue.
  ##
  ## `Return` the number of events actually stored,
  ## or `-1` if there was an error.
  ##
  ## This procedure is thread-safe.


proc hasEvent*(kind: uint32): Bool32 {.importc: "SDL_HasEvent".}
  ## Checks to see if certain event types are in the event queue.

proc hasEvents*(minType: uint32; maxType: uint32): Bool32 {.importc: "SDL_HasEvents".}

proc flushEvent*(kind: uint32) {.importc: "SDL_FlushEvent".}
  ## This procedure clears events from the event queue.
  ##
  ## This procedure only affects currently queued events.
  ## If you want to make sure that all pending OS events are flushed,
  ## you can call `pumpEvents()` on the main thread immediately before
  ## flush call.

proc flushEvents*(minType: uint32; maxType: uint32) {.importc: "SDL_FlushEvents".}

proc pollEvent*(event: var Event): Bool32 {.importc: "SDL_PollEvent".}
  ## Polls for currently pending events.
  ##
  ## `Return` `1` if there are any pending events,
  ## or `0` if there are none available.
  ##
  ## `event` If not `nil`, the next event is removed from the queue
  ## and stored in that area.

proc waitEvent*(event: var Event): Bool32 {.importc: "SDL_WaitEvent".}
  ## Waits indefinitely for the next available event.
  ##
  ## `Return` `1`, or `0` if there was an error while waiting for events.
  ##
  ## `event` If not `nil`, the next event is removed from the queue
  ## and stored in that area.

proc waitEventTimeout*(event: var Event; timeout: cint): Bool32 {.
  importc: "SDL_WaitEventTimeout".}
  ## Waits until the specified timeout (in milliseconds)
  ## for the next available event.
  ##
  ## `Return` `1`, or `0` if there was an error while waiting for events.
  ##
  ## `event` If not `nil`, the next event is removed from the queue
  ## and stored in that area.
  ## `timeout` The timeout (in milliseconds)
  ## to wait for next event.

proc pushEvent*(event: ptr Event): cint {.importc: "SDL_PushEvent".}
  ## Add an event to the event queue.
  ##
  ## `Return` `1` on success, `0` if the event was filtered,
  ## or `-1` if the event queue was full or there was some other error.

proc setEventFilter*(filter: EventFilter; userdata: pointer) {.importc: "SDL_SetEventFilter".}
  ## Sets up a filter to process all events before they change internal state
  ## and are posted to the internal event queue.
  ##
  ## The filter is prototyped as:
  ##
  ##  proc EventFilter(userdata: pointer; event: ptr Event): cint {.cdecl.}
  ##
  ## If the filter returns `1`, then the event will be added
  ## to the internal queue.
  ## If it returns `0`, then the event will be dropped from the queue,
  ## but the internal state will still be updated.  This allows selective
  ## filtering of dynamically arriving events.
  ##
  ## `Warning:` Be very careful of what you do in the event filter procedure,
  ## as it may run in a different thread!
  ##
  ## There is one caveat when dealing with the `QuitEvent` event type.  The
  ## event filter is only called when the window manager desires to close the
  ## application window.  If the event filter returns `1`, then the window
  ## will be closed, otherwise the window will remain open if possible.
  ##
  ## If the quit event is generated by an interrupt signal, it will bypass the
  ## internal queue and be delivered to the application at the next event poll.


proc getEventFilter*(filter: var EventFilter; userdata: var pointer): Bool32 {.
  importc: "SDL_GetEventFilter".}
  ## Return the current event filter - can be used to "chain" filters.
  ## If there is no event filter set, this procedure returns `false`.

proc addEventWatch*(filter: EventFilter; userdata: pointer) {.
  importc: "SDL_AddEventWatch".}
  ## Add a procedure which is called when an event is added to the queue.

proc delEventWatch*(filter: EventFilter; userdata: pointer) {.
  importc: "SDL_DelEventWatch".}
  ## Remove an event watch procedure added with `addEventWatch()`

proc filterEvents*(filter: EventFilter; userdata: pointer) {.
  importc: "SDL_FilterEvents".}
  ## Run the filter procedure on the current event queue, removing any
  ## events for which the filter returns `0`.

proc eventState*(kind: EventType; state: cint): uint8 {.
  importc: "SDL_EventState".}
  ## This procedure allows you to set the state of processing certain events.
  ##
  ## * If `state` is set to `SDL_IGNORE`, that event will be automatically
  ##  dropped from the event queue and will not be filtered.
  ## * If `state` is set to `SDL_ENABLE`, that event will be processed normally.
  ## * If `state` is set to `SDL_QUERY`, `eventState()` will return the
  ##  current processing state of the specified event.

proc registerEvents*(numevents: cint): uint32 {.importc: "SDL_RegisterEvents".}
  ## This procedure allocates a set of user-defined events, and returns
  ## the beginning event number for that set of events.
  ##
  ## If there aren't enough user-defined events left, this procedure
  ## returns `-1'u32`.

proc setError*(fmt: cstring) {.varargs, importc: "SDL_SetError".}
  ## Set the error message for the current thread.
  ##
  ## `Return` `-1`, there is no error handling for this procedure.

proc getError*(): cstring {.importc: "SDL_GetError".}
  ## Get the last error message that was set.
  ##
  ## SDL API procedures may set error messages and then succeed, so you should
  ## only use the error value if a procedure fails.
  ##
  ## This returns a pointer to a static buffer for convenience and should not
  ## be called by multiple threads simultaneously.
  ##
  ## `Return` a `cstring` of the last error message that was set.

proc clearError*() {.importc: "SDL_ClearError".}
  ## Clear the error message for the current thread.

proc getPixelFormatName*(format: uint32): cstring {.
  importc: "SDL_GetPixelFormatName".}
  ## Get the human readable name of a pixel format

proc pixelFormatEnumToMasks*(format: uint32; bpp: var cint;
  Rmask, Gmask, Bmask, Amask: var uint32): bool {.
  importc: "SDL_PixelFormatEnumToMasks".}
  ## Convert one of the enumerated pixel formats to a bpp and RGBA masks.
  ## Returns `true` or `false` if the conversion wasn't possible.
  ## **See also:**
  ## * `masksToPixelFormatEnum proc<#masksToPixelFormatEnum,cint,uint32,uint32,uint32,uint32>`_


proc masksToPixelFormatEnum*(bpp: cint; Rmask, Gmask, Bmask, Amask: uint32):
  uint32 {.importc: "SDL_MasksToPixelFormatEnum".}
  ## Convert a bpp and RGBA masks to an enumerated pixel format.
  ## The pixel format, or `SDL_PIXELFORMAT_UNKNOWN` if the conversion wasn't possible.
  ##
  ## **See also:**
  ## * `pixelFormatEnumToMasks proc<#pixelFormatEnumToMasks,uint32,cint,uint32,uint32,uint32,uint32>`_

proc allocFormat*(pixelFormat: uint32): ptr PixelFormat {.
  importc: "SDL_AllocFormat".}
  ## Create a `PixelFormat` object from a pixel format enum.

proc freeFormat*(format: ptr PixelFormat) {.
  importc: "SDL_FreeFormat".}
  ## Free a `PixelFormat` object.

proc allocPalette*(numColors: cint): ptr Palette {.
  importc: "SDL_AllocPalette".}
  ## Create a palette structure with the specified number of color entries.
  ## Returns A new palette, or `nil` if there wasn't enough memory.
  ## Note: The palette entries are initialized to white.

proc setPixelFormatPalette*(format: ptr PixelFormat; palette: ptr Palette): cint {.
  importc: "SDL_SetPixelFormatPalette".}
  ## Set the palette for a pixel format object.

proc setPaletteColors*(palette: ptr Palette; colors: ptr Color;
                        first, numColors: cint): SDL_Return {.
                        discardable, importc: "SDL_SetPaletteColors".}
  ## Set a range of colors in a palette.

proc freePalette*(palette: ptr Palette) {.
  importc: "SDL_FreePalette".}
  ## Free a palette created with `allocPalette()`.

proc mapRGB*(format: ptr PixelFormat; r,g,b: uint8): uint32 {.
  importc: "SDL_MapRGB".}
  ## Maps an RGB triple to an opaque pixel value for a given pixel format.
  ##
  ## **See also:**
  ## * `mapRGBA proc<#mapRGBA,ptr.PixelFormat,uint8,uint8,uint8,uint8>`_

proc mapRGBA*(format: ptr PixelFormat; r,g,b,a: uint8): uint32 {.
  importc: "SDL_MapRGBA".}
  ## Maps an RGBA quadruple to a pixel value for a given pixel format.
  ##
  ## **See also:**
  ## * `mapRGB proc<#mapRGB,ptr.PixelFormat,uint8,uint8,uint8>`_

proc getRGB*(pixel: uint32; format: ptr PixelFormat; r,g,b: var uint8) {.
  importc: "SDL_GetRGB".}
  ## Get the RGB components from a pixel of the specified format.
  ##
  ## **See also:**
  ## * `getRGBA proc<#getRGBA,uint32,ptr.PixelFormat,uint8,uint8,uint8,uint8>`_

proc getRGBA*(pixel: uint32; format: ptr PixelFormat; r,g,b,a: var uint8) {.
  importc: "SDL_GetRGBA".}
  ##Get the RGBA components from a pixel of the specified format.
  ##
  ## **See also:**
  ## * `getRGB proc<#getRGB,uint32,ptr.PixelFormat,uint8,uint8,uint8>`_

proc calculateGammaRamp*(gamma: cfloat; ramp: ptr uint16) {.
  importc: "SDL_CalculateGammaRamp".}
  ## Calculate a 256 entry gamma ramp for a gamma value.

# SDL_clipboard.h
proc setClipboardText*(text: cstring): cint {.importc: "SDL_SetClipboardText".}
  ## Put UTF-8 text into the clipboard.
  ##
  ## **See also:**
  ## * `getClipboardText proc<#getClipboardText>`_

proc getClipboardText*(): cstring {.importc: "SDL_GetClipboardText".}
  ## Get UTF-8 text from the clipboard, which must be freed with `free()`.
  ##
  ## **See also:**
  ## * `setClipboardText proc<#setClipboardText,cstring>`_

proc hasClipboardText*(): Bool32 {.importc: "SDL_HasClipboardText".}
  ## Returns a flag indicating whether the clipboard exists and contains
  ## a text string that is non-empty.
  ##
  ## **See also:**
  ## * `getClipboardText proc<#getClipboardText>`_

proc freeClipboardText*(text: cstring) {.importc: "SDL_free".}


proc getNumTouchFingers*(id: TouchID): cint {.importc: "SDL_GetNumTouchFingers".}
  ## Get the number of active fingers for a given touch device.

proc getTouchFinger*(id: TouchID, index: cint): ptr Finger {.importc: "SDL_GetTouchFinger".}
  ## Get the finger object of the given touch, with the given index.


# SDL_system.h
when defined(windows):

  proc direct3D9GetAdapterIndex*(displayIndex: cint): cint {.
    importc: "SDL_Direct3D9GetAdapterIndex".}
    ## Returns the D3D9 adapter index that matches the specified display index.
    ## This adapter index can be passed to IDirect3D9::CreateDevice and controls
    ## on which monitor a full screen application will appear.

  proc getD3D9Device*(renderer: RendererPtr): pointer {.
    importc:"SDL_RenderGetD3D9Device".}
    ## Returns the D3D device associated with a renderer, or `nil` if it's not a D3D renderer.
    ## Once you are done using the device, you should release it to avoid a resource leak.

  proc dXGIGetOutputInfo*(displayIndex: cint, adapterIndex,outputIndex: ptr cint) {.importc: "SDL_DXGIGetOutputInfo".}
    ## Returns the DXGI Adapter and Output indices for the specified display index.
    ## These can be passed to EnumAdapters and EnumOutputs respectively to get the objects
    ## required to create a DX10 or DX11 device and swap chain.

elif defined(iPhone) or defined(ios):


  proc iPhoneSetAnimationCallback*(window: WindowPtr, interval:cint,
    callback: VoidCallback, callbackParam: pointer): cint {.
    importc: "SDL_iPhoneSetAnimationCallback".}

  proc iPhoneSetEventPump*(enabled: bool) {.importc: "SDL_iPhoneSetEventPump".}

  proc iPhoneKeyboardShow*(window:WindowPtr): cint {.
    importc: "SDL_iPhoneKeyboardShow".}

  proc iPhoneKeyboardHide*(window:WindowPtr): cint {.
    importc: "SDL_iPhoneKeyboardHide".}

  proc iPhoneKeyboardIsShown*(window:WindowPtr): bool {.
    importc: "SDL_iPhoneKeyboardIsShown".}

  proc iPhoneKeyboardToggle*(window:WindowPtr): cint {.
    importc: "SDL_iPhoneKeyboardToggle".}

elif defined(android):

  proc androidGetJNIEnv*(): pointer {.importc: "SDL_AndroidGetJNIEnv".}

  proc androidGetActivity*(): pointer {.importc: "SDL_AndroidGetActivity".}

  proc androidGetExternalStorageState*(): cint {.
    importc: "SDL_AndroidGetExternalStorageState".}

  proc androidGetInternalStoragePath*(): cstring {.
    importc: "SDL_AndroidGetInternalStoragePath".}

  proc androidGetExternalStoragePath*(): cstring {.
    importc: "SDL_AndroidGetExternalStoragePath".}

const
  SDL_QUERY* = -1
  SDL_IGNORE* = 0
  SDL_DISABLE* = 0
  SDL_ENABLE* = 1

proc getEventState*(kind: EventType): uint8 {.inline.} = eventState(kind, SDL_QUERY)

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

const SDL_TOUCH_MOUSEID* = high(uint32)
  ## Used as the device ID for mouse events simulated with touch input


# compatibility functions

proc createRGBSurface*(width, height, depth: int32): SurfacePtr {.inline.} =
  sdl2.createRGBSurface(0, width, height, depth, 0, 0, 0, 0)

proc getSize*(window: WindowPtr): Point {.inline.} =
  getSize(window, result.x, result.y)

proc destroyTexture*(texture: TexturePtr) {.inline.} = destroy(texture)

proc destroyRenderer*(renderer: RendererPtr) {.inline.} = destroy(renderer)

proc destroy*(window: WindowPtr) {.inline.} = window.destroyWindow
  ## Destroy a window.
proc destroy*(cursor: CursorPtr) {.inline.} = cursor.freeCursor
proc destroy*(surface: SurfacePtr) {.inline.} = surface.freeSurface
proc destroy*(format: ptr PixelFormat) {.inline.} = format.freeFormat
proc destroy*(palette: ptr Palette) {.inline.} = palette.freePalette

proc blitSurface*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
                  dstrect: ptr Rect): SDL_Return {.inline, discardable.} =
  upperBlit(src, srcrect, dst, dstrect)
proc blitScaled*(src: SurfacePtr; srcrect: ptr Rect; dst: SurfacePtr;
                 dstrect: ptr Rect): SDL_Return {.inline, discardable.} =
  upperBlitScaled(src, srcrect, dst, dstrect)

proc loadBMP*(file: string): SurfacePtr {.inline.} =
  ## Load a surface from a file.
  loadBMP_RW(rwFromFile(cstring(file), "rb"), 1)

proc saveBMP*(surface: SurfacePtr; file: string): SDL_Return {.
  inline, discardable.} =
  ## Save a surface to a file.
  saveBMP_RW(surface, rwFromFile(file, "wb"), 1)

proc color*(r, g, b, a: range[0..255]): Color = (r.uint8, g.uint8, b.uint8, a.uint8)

proc rect*(x, y: cint; w = cint(0), h = cint(0)): Rect =
  result.x = x
  result.y = y
  result.w = w
  result.h = h

proc rectf*(x, y: cfloat; w = cfloat(0), h = cfloat(0)): RectF =
  result.x = x
  result.y = y
  result.w = w
  result.h = h

proc point*[T: SomeNumber](x, y: T): Point = (x.cint, y.cint)

proc pointf*[T: SomeNumber](x, y: T): PointF = (x.cfloat, y.cfloat)

proc contains*(some: Rect; point: Point): bool =
  return point.x >= some.x and point.x <= (some.x + some.w) and
          point.y >= some.y and point.y <= (some.y + some.h)

const
  HINT_RENDER_SCALE_QUALITY* = "SDL_RENDER_SCALE_QUALITY"
    ## A variable controlling the scaling quality
    ##
    ## This variable can be set to the following values:
    ## * "0" or "nearest" - Nearest pixel sampling
    ## * "1" or "linear"  - Linear filtering (supported by OpenGL and Direct3D)
    ## * "2" or "best"    - Currently this is the same as "linear"
    ##
    ## By default nearest pixel sampling is used.

proc setHint*(name: cstring, value: cstring): bool {.importc: "SDL_SetHint".}
  ## Set a hint with normal priority.
  ##
  ## `Return` `true` if the hint was set, `false` otherwise.

proc setHintWithPriority*(name: cstring, value: cstring, priority: cint): bool {.
  importc: "SDL_SetHintWithPriority".}
  ## Set a hint with a specific priority.
  ##
  ## The priority controls the behavior when setting a hint that already
  ## has a value.  Hints will replace existing hints of their priority and
  ## lower.  Environment variables are considered to have override priority.
  ##
  ## `Return` `true` if the hint was set, `false` otherwise.

proc getHint*(name: cstring): cstring {.importc: "SDL_GetHint".}
  ## Get a hint.
  ##
  ## `Return` the string value of a hint variable.

proc size*(ctx: RWopsPtr): int64 {.inline.} =
  ## `Return` the size of the file in this rwops, or `-1` if unknown.
  ctx.size(ctx)

proc seek*(ctx: RWopsPtr; offset: int64; whence: cint): int64 {.inline.} =
  ## Seek to `offset` relative to `whence`, one of stdio's whence values:
  ## `RW_SEEK_SET`, `RW_SEEK_CUR`, `RW_SEEK_END`.
  ##
  ## `Return` the final offset in the data stream, or `-1` on error.
  # TODO: Add `RW_SEEK_SET`, `RW_SEEK_CUR`, `RW_SEEK_END`.
  ctx.seek(ctx, offset, whence)

proc read*(ctx: RWopsPtr; `ptr`: pointer; size, maxnum: csize_t): csize_t {.inline.} =
  ## Read up to `maxnum` objects each of size `size` from the data
  ## stream to the area pointed at by `p`.
  ##
  ## `Return` the number of objects read, or `0` at error or end of file.
  ctx.read(ctx, `ptr`, size, maxnum)

proc write*(ctx: RWopsPtr; `ptr`: pointer; size, num: csize_t): csize_t {.inline.} =
  ## Write exactly `num` objects each of size `size` from the area
  ## pointed at by `p` to data stream.
  ##
  ## `Return` the number of objects written, or `0` at error or end of file.
  ctx.write(ctx, `ptr`, size, num)

proc close*(ctx: RWopsPtr): cint {.inline.} =
  ## Close and free an allocated `sdl.RWops` object.
  ##
  ## `Return` `0` if successful or `-1` on write error when flushing data.
  ctx.close(ctx)

when not defined(SDL_Static):
  {.pop.}

let defaultEvent* = Event(kind: QuitEvent)
  ## a default "initialized" Event
