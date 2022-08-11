discard """ Simple DirectMedia Layer
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

## Include file for SDL joystick event handling
##
## The term "device_index" identifies currently plugged in joystick devices
## between 0 and SDL_NumJoysticks, with the exact joystick behind a 
## device_index changing as joysticks are plugged and unplugged.
##
## The term "instance_id" is the current instantiation of a joystick device in
## the system, if the joystick is removed and then re-inserted then it will get
## a new instance_id, instance_id's are monotonically increasing identifiers of
## a joystick plugged in.
##
## The term JoystickGUID is a stable 128-bit identifier for a joystick device
## that does not change over time, it identifies class of the device 
## (a X360 wired controller for example). This identifier is platform dependent.
##
## In order to use these functions, `init()` must have been called with
## the `INIT_JOYSTICK` flag. This causes SDL to scan the system for joysticks,
## and load appropriate drivers.
##
## If you would like to receive joystick updates while the application
## is in the background, you should set the following hint before calling
## `init()`: `SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS`
import "../sdl2"


# The joystick structure used to identify an SDL joystick
type
  Joystick* = object
  JoystickPtr* = ptr Joystick

# A structure that encodes the stable unique id for a joystick device#
type
  JoystickGuid* = object
    data: array[16, uint8]
  JoystickID* = int32
    ## This is a unique ID for a joystick for the time it is connected to the
    ## system, and is never reused for the lifetime of the application. If the
    ## joystick is disconnected and reconnected, it will get a new ID.
    ##
    ## The ID value starts at `0` and increments from there.
    ## The value `-1` is an invalid ID.

when defined(SDL_Static):
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."
else:
  {.push callConv: cdecl, dynlib: LibName.}


proc numJoysticks*(): cint {.importc: "SDL_NumJoysticks".}
  ## Count the number of joysticks attached to the system right now.

proc joystickNameForIndex*(device_index: cint): cstring {.
  importc: "SDL_JoystickNameForIndex".}
  ## Get the implementation dependent name of a joystick.
  ##
  ## This can be called before any joysticks are opened.
  ## If no name can be found, this procedure returns `nil`.

proc joystickOpen*(device_index: cint): JoystickPtr {.
  importc: "SDL_JoystickOpen".}
  ## Open a joystick for use.
  ##
  ## The index passed as an argument refers to the N'th joystick on the system.
  ## This index is not the value which will identify this joystick in future
  ## joystick events. The joystick's instance id (`JoystickID`) will be used
  ## there instead.
  ##
  ## `Return` a joystick identifier, or `nil` if an error occurred.

proc joystickName*(joystick: ptr Joystick): cstring {.importc: "SDL_JoystickName".}
  ## `Return` the name for this currently opened joystick.
  ## If no name can be found, this procedure returns `nil`.

proc name*(joystick: ptr Joystick): cstring {.inline.} =
  ## `Return` the name for this currently opened joystick.
  ## If no name can be found, this procedure returns `nil`.
  joystick.joystickName

proc joystickGetDeviceGUID*(device_index: cint): JoystickGUID {.
  importc: "SDL_JoystickGetDeviceGUID".}
  ## Return the GUID for the joystick at this index.
  ##
  ## This can be called before any joysticks are opened.

proc joystickGetGUID*(joystick: JoystickPtr): JoystickGUID {.
  importc: "SDL_JoystickGetGUID".}
  ## `Return` the GUID for this opened joystick.

proc getGUID*(joystick: JoystickPtr): JoystickGUID {.inline.} =
  ## `Return` the GUID for this opened joystick.
  joystick.joystickGetGUID

proc joystickGetGUIDString*(guid: JoystickGUID, pszGUID: cstring, cbGUID: cint) {.
  importc: "SDL_JoystickGetGUIDString".}
  ## `Return` a string representation for this guid.
  ##
  ## `pszGUID` must point to at least 33 bytes
  ## (32 for the string plus a `nil` terminator).

proc joystickGetGUIDFromString*(pchGUID: cstring): JoystickGUID {.
  importc: "SDL_JoystickGetGUIDFromString".}
  ## Convert a string into a joystick GUID.

proc joystickGetAttached*(joystick: JoystickPtr): Bool32 {.
  importc: "SDL_JoystickGetAttached".}
  ## `Return` `true` if the joystick has been opened and currently
  ## connected, or `false` if it has not.

proc getAttached* (joystick: JoystickPtr): Bool32 {.inline.} =
  ## `Return` `true` if the joystick has been opened and currently
  ## connected, or `false` if it has not.
  joystick.joystickGetAttached

proc joystickInstanceID*(joystick: JoystickPtr): JoystickID {.
  importc: "SDL_JoystickInstanceID".}
  ## Get the instance ID of an opened joystick,
  ## or `-1` if the joystick is invalid.

proc instanceID*(joystick: JoystickPtr): JoystickID {.inline.} =
  ## Get the instance ID of an opened joystick,
  ## or `-1` if the joystick is invalid.
  joystick.joystickInstanceID

proc joystickNumAxes*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumAxes".}
  ## Get the number of general axis controls on a joystick.

proc numAxes* (joystick: JoystickPtr): cint {.inline.} =
  ## Get the number of general axis controls on a joystick.
  joystick.joystickNumAxes

proc joystickNumBalls*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumBalls".}
  ## Get the number of trackballs on a joystick.
  ##
  ## Joystick trackballs have only relative motion events associated
  ## with them and their state cannot be polled.

proc numBalls*(joystick: JoystickPtr): cint {.inline.} =
  ## Get the number of trackballs on a joystick.
  ##
  ## Joystick trackballs have only relative motion events associated
  ## with them and their state cannot be polled.
  joystick.joystickNumBalls

proc joystickNumHats*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumHats".}
  ## Get the number of POV hats on a joystick.

proc numHats*(joystick: JoystickPtr): cint {.inline.} =
  ## Get the number of POV hats on a joystick.
  joystick.joystickNumHats

proc joystickNumButtons*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumButtons".}
  ## Get the number of buttons on a joystick.

proc numButtons*(joystick: JoystickPtr): cint {.inline.} =
  ## Get the number of buttons on a joystick.
  joystick.joystickNumButtons

proc joystickUpdate*() {.importc: "SDL_JoystickUpdate".}
  ## Update the current state of the open joysticks.
  ##
  ## This is called automatically by the event loop if any joystick
  ## events are enabled.

proc joystickEventState*(state: cint): cint {.
  importc: "SDL_JoystickEventState".}
  ## Enable/disable joystick event polling.
  ##
  ## If joystick events are disabled, you must call `joystickUpdate()`
  ## yourself and check the state of the joystick when you want joystick
  ## information.
  ##
  ## The `state` can be one of `SDL_QUERY`, `SDL_ENABLE` or `SDL_IGNORE`.

proc joystickGetAxis*(joystick: JoystickPtr, axis: cint): int16 {.
  importc: "SDL_JoystickGetAxis".}
  ## Get the current state of an axis control on a joystick.
  ##
  ## The state is a value ranging from `-32768` to `32767`.
  ##
  ## The axis indices start at index `0`.

proc getAxis*(joystick: JoystickPtr, axis: cint): int16 {.inline.} =
  ## Get the current state of an axis control on a joystick.
  ##
  ## The state is a value ranging from `-32768` to `32767`.
  ##
  ## The axis indices start at index `0`.
  joystick.joystickGetAxis(axis)

const
  SDL_HAT_CENTERED*: cint = 0x00000000
  SDL_HAT_UP*: cint = 0x00000001
  SDL_HAT_RIGHT*: cint = 0x00000002
  SDL_HAT_DOWN*: cint = 0x00000004
  SDL_HAT_LEFT*: cint = 0x00000008
  SDL_HAT_RIGHTUP*: cint = SDL_HAT_RIGHT or SDL_HAT_UP
  SDL_HAT_RIGHTDOWN*: cint = SDL_HAT_RIGHT or SDL_HAT_DOWN
  SDL_HAT_LEFTUP*: cint = SDL_HAT_LEFT or SDL_HAT_UP
  SDL_HAT_LEFTDOWN*: cint = SDL_HAT_LEFT or SDL_HAT_DOWN


proc joystickGetHat*(joystick: JoystickPtr, hat: cint): uint8 {.
  importc: "SDL_JoystickGetHat".}
  ## Get the current state of a POV hat on a joystick.
  ##
  ## The hat indices start at index `0`.
  ##
  ## `Return` The return value is one of the following positions:
  ## * SDL_HAT_CENTERED
  ## * SDL_HAT_UP
  ## * SDL_HAT_RIGHT
  ## * SDL_HAT_DOWN
  ## * SDL_HAT_LEFT
  ## * SDL_HAT_RIGHTUP
  ## * SDL_HAT_RIGHTDOWN
  ## * SDL_HAT_LEFTUP
  ## * SDL_HAT_LEFTDOWN

proc getHat*(joystick: JoystickPtr, hat: cint): uint8 {.inline.} =
  ## Get the current state of a POV hat on a joystick.
  ##
  ## The hat indices start at index `0`.
  ##
  ## `Return` The return value is one of the following positions:
  ## * SDL_HAT_CENTERED
  ## * SDL_HAT_UP
  ## * SDL_HAT_RIGHT
  ## * SDL_HAT_DOWN
  ## * SDL_HAT_LEFT
  ## * SDL_HAT_RIGHTUP
  ## * SDL_HAT_RIGHTDOWN
  ## * SDL_HAT_LEFTUP
  ## * SDL_HAT_LEFTDOWN
  joystick.joystickGetHat(hat)

proc joystickGetBall*(joystick: JoystickPtr, ball: cint, dx: ptr cint, dy: ptr cint): cint {.
  importc: "SDL_JoystickGetBall".}
  ## Get the ball axis change since the last poll.
  ##
  ## `Return` `0`, or `-1` if you passed it invalid parameters.
  ##
  ## The ball indices start at index `0`.

proc getBall*(joystick: JoystickPtr, ball: cint, dx: ptr cint, dy: ptr cint): cint {.inline.} =
  ## Get the ball axis change since the last poll.
  ##
  ## `Return` `0`, or `-1` if you passed it invalid parameters.
  ##
  ## The ball indices start at index `0`.
  joystick.joystickGetBall(ball, dx, dy)

proc joystickGetButton*(joystick: JoystickPtr, button: cint): uint8 {.
  importc: "SDL_JoystickGetButton".}
  ## Get the current state of a button on a joystick.
  ##
  ## The button indices start at index `0`.

proc getButton* (joystick: JoystickPtr, button: cint): uint8 {.inline.} =
  ## Get the current state of a button on a joystick.
  ##
  ## The button indices start at index `0`.
  joystick.joystickGetButton(button)

proc joystickClose*(joystick: JoystickPtr) {.importc: "SDL_JoystickClose".}
  ## Close a joystick previously opened with `joystickOpen()`.

proc close* (joystick: JoystickPtr) {.inline.} =
  ## Close a joystick previously opened with `joystickOpen()`.
  joystick.joystickClose()

when not defined(SDL_Static):
  {.pop.}
