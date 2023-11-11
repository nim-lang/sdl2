discard """
  Simple DirectMedia Layer
  Copyright (C) 1997-2014 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
"""


## SDL game controller event handling
##
## In order to use these functions, `sdl.init()` must have been called
## with the `SDL_INIT_JOYSTICK` flag.  This causes SDL to scan the system
## for game controllers, and load appropriate drivers.
##
## If you would like to receive controller updates while the application
## is in the background, you should set the following hint before calling
## init(): SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS

import "../sdl2"
import "joystick"


type
  GameController* = object
    ## The gamecontroller structure used to identify an SDL game controller.

  GameControllerPtr* = ptr GameController

  GameControllerBindType* {.size: sizeof(cint).} = enum
    SDL_CONTROLLER_BINDTYPE_NONE,
    SDL_CONTROLLER_BINDTYPE_BUTTON,
    SDL_CONTROLLER_BINDTYPE_AXIS,
    SDL_CONTROLLER_BINDTYPE_HAT

# Get the SDL joystick layer binding for this controller button/axis mapping

type
  GameControllerButtonBind* = object
    ## Get the SDL joystick layer binding
    ## for this controller button/axis mapping
    case bindType*: GameControllerBindType
      of SDL_CONTROLLER_BINDTYPE_NONE:
        nil
      of SDL_CONTROLLER_BINDTYPE_BUTTON:
        button*: cint
      of SDL_CONTROLLER_BINDTYPE_AXIS:
        axis*: cint
      of SDL_CONTROLLER_BINDTYPE_HAT:
        hat*, hatMask*: cint

when defined(SDL_Static):
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."
else:
  {.push callConv: cdecl, dynlib: LibName.}

proc gameControllerAddMapping*(mappingString: cstring): cint {.
  importc: "SDL_GameControllerAddMapping".}
  ## Add or update an existing mapping configuration.
  ##
  ## `Return` `1` if mapping is added, `0` if updated, `-1` on error.

proc gameControllerMappingForGUID*(guid: JoystickGuid): cstring {.
  importc: "SDL_GameControllerMappingForGUID".}
  ## Get a mapping string for a GUID.
  ##
  ## `Return` the mapping string.  Must be freed with `sdl.free()`.
  ## Returns `nil` if no mapping is available

proc mapping*(gameController: GameControllerPtr): cstring {.
  importc: "SDL_GameControllerMapping".}
  ## Get a mapping string for an open GameController.
  ##
  ## `Return` the mapping string.  Must be freed with `sdl.free()`.
  ## Returns `nil` if no mapping is available

proc isGameController*(joystickIndex: cint): Bool32 {.
  importc: "SDL_IsGameController".}
  ## Is the joystick on this index supported by the game controller interface?

proc gameControllerNameForIndex*(joystickIndex: cint): cstring {.
  importc: "SDL_GameControllerNameForIndex".}
  ## Get the implementation dependent name of a game controller.
  ##
  ## This can be called before any controllers are opened.
  ## If no name can be found, this procedure returns `nil`.

proc gameControllerOpen*(joystickIndex: cint): GameControllerPtr {.
  importc: "SDL_GameControllerOpen".}
  ## Open a game controller for use.
  ##
  ## The index passed as an argument refers to the N'th game controller
  ## on the system.
  ##
  ## This index is not the value which will identify this controller in future
  ## controller events. The joystick's instance id (`JoystickID`) will be
  ## used there instead.
  ##
  ## `Return` a controller identifier, or `nil` if an error occurred.

proc name*(gameController: GameControllerPtr): cstring {.
  importc: "SDL_GameControllerName".}
  ## `Return` the name for this currently opened controller.

proc getAttached*(gameController: GameControllerPtr): Bool32 {.
  importc: "SDL_GameControllerGetAttached".}
  ## `Returns` `true` if the controller has been opened and currently
  ## connected, or `false` if it has not.

proc getJoystick*(gameController: GameControllerPtr): JoystickPtr {.
  importc: "SDL_GameControllerGetJoystick".}
  ## Get the underlying joystick object used by a controller.

proc gameControllerEventState*(state: cint): cint {.
  importc: "SDL_GameControllerEventState".}
  ## Enable/disable controller event polling.
  ##
  ## If controller events are disabled, you must call
  ## `gameControllerUpdate()` yourself and check the state of the
  ## controller when you want controller information.
  ##
  ## The state can be one of `SDL_QUERY`, `SDL_ENABLE` or `SDL_IGNORE`.


proc gameControllerUpdate*() {.importc: "SDL_GameControllerUpdate".}
  ## Update the current state of the open game controllers.
  ##
  ## This is called automatically by the event loop if any game controller
  ## events are enabled.

type
  GameControllerAxis* {.size: sizeof(cint).} = enum
    ## The list of axes available from a controller.
    ##
    ## Thumbstick axis values range
    ## from `JOYSTICK_AXIS_MIN` to `JOYSTICK_AXIS_MAX`,
    ## and are centered within ~8000 of zero,
    ## though advanced UI will allow users to set
    ## or autodetect the dead zone, which varies between controllers.
    ##
    ## Trigger axis values range from `0` to `JOYSTICK_AXIS_MAX`.
    SDL_CONTROLLER_AXIS_INVALID = -1,
    SDL_CONTROLLER_AXIS_LEFTX,
    SDL_CONTROLLER_AXIS_LEFTY,
    SDL_CONTROLLER_AXIS_RIGHTX,
    SDL_CONTROLLER_AXIS_RIGHTY,
    SDL_CONTROLLER_AXIS_TRIGGERLEFT,
    SDL_CONTROLLER_AXIS_TRIGGERRIGHT,
    SDL_CONTROLLER_AXIS_MAX

converter toInt*(some: GameControllerAxis): uint8 = uint8(some)

proc gameControllerGetAxisFromString*(pchString: cstring): GameControllerAxis {.
  importc: "SDL_GameControllerGetAxisFromString".}
proc getAxisFromString*(pchString: cstring): GameControllerAxis {.
  importc: "SDL_GameControllerGetAxisFromString".}
  ## Turn this string into a axis mapping.

proc gameControllerGetStringForAxis*(axis: GameControllerAxis): cstring {.
  importc: "SDL_GameControllerGetStringForAxis".}
proc getStringForAxis*(axis: GameControllerAxis): cstring {.
  importc: "SDL_GameControllerGetStringForAxis".}
  ## Turn this axis enum into a string mapping.

proc getBindForAxis*(gameController: GameControllerPtr,
                     axis: GameControllerAxis): GameControllerButtonBind {.
                     importc: "SDL_GameControllerGetBindForAxis".}
  ## Get the SDL joystick layer binding for this controller button mapping.

proc getAxis*(gameController: GameControllerPtr,
              axis: GameControllerAxis): int16 {.
  importc: "SDL_GameControllerGetAxis".}
  ## Get the current state of an axis control on a game controller.
  ##
  ## The state is a value ranging from `-32768` to `32767`
  ## (except for the triggers, which range from `0` to `32767`.
  ##
  ## The axis indices start at index `0`.

type
  GameControllerButton* {.size: sizeof(cint).} = enum
    ## The list of buttons available from a controller
    SDL_CONTROLLER_BUTTON_INVALID = -1,
    SDL_CONTROLLER_BUTTON_A,
    SDL_CONTROLLER_BUTTON_B,
    SDL_CONTROLLER_BUTTON_X,
    SDL_CONTROLLER_BUTTON_Y,
    SDL_CONTROLLER_BUTTON_BACK,
    SDL_CONTROLLER_BUTTON_GUIDE,
    SDL_CONTROLLER_BUTTON_START,
    SDL_CONTROLLER_BUTTON_LEFTSTICK,
    SDL_CONTROLLER_BUTTON_RIGHTSTICK,
    SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
    SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
    SDL_CONTROLLER_BUTTON_DPAD_UP,
    SDL_CONTROLLER_BUTTON_DPAD_DOWN,
    SDL_CONTROLLER_BUTTON_DPAD_LEFT,
    SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
    SDL_CONTROLLER_BUTTON_MAX

converter toInt*(some: GameControllerButton): uint8 = uint8(some)

proc gameControllerGetButtonFromString*(
  pchString: cstring): GameControllerButton {.
  importc: "SDL_GameControllerGetButtonFromString".}
proc getButtonFromString*(pchString: cstring): GameControllerButton {.
  importc: "SDL_GameControllerGetButtonFromString".}
  ## Turn this string into a button mapping.

proc gameControllerGetStringForButton*(
  button: GameControllerButton): cstring {.
  importc: "SDL_GameControllerGetStringForButton".}
proc getStringForButton*(button: GameControllerButton): cstring {.
  importc: "SDL_GameControllerGetStringForButton".}
  ## Turn this button enum into a string mapping.

proc getBindForButton*(
  gameController: GameControllerPtr,
  button: GameControllerButton): GameControllerButtonBind {.
  importc: "SDL_GameControllerGetBindForButton".}
  ## Get the SDL joystick layer binding for this controller button mapping.

proc getButton*(
  gameController: GameControllerPtr,
  button: GameControllerButton): uint8 {.
  importc: "SDL_GameControllerGetButton".}
  ## Get the current state of a button on a game controller.
  ##
  ## The button indices start at index `0`.

proc close*(gameController: GameControllerPtr) {.
  importc: "SDL_GameControllerClose".}
  ## Close a controller previously opened with `gameControllerOpen()`.


when not defined(SDL_Static):
  {.pop.}
