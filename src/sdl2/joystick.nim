import "../sdl2"


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



\file SDL_joystick.h

Include file for SDL joystick event handling

The term "device_index" identifies currently plugged in joystick devices between 0 and SDL_NumJoysticks, with the exact joystick
 behind a device_index changing as joysticks are plugged and unplugged.

The term "instance_id" is the current instantiation of a joystick device in the system, if the joystick is removed and then re-inserted
 then it will get a new instance_id, instance_id's are monotonically increasing identifiers of a joystick plugged in.

The term JoystickGUID is a stable 128-bit identifier for a joystick device that does not change over time, it identifies class of
 the device (a X360 wired controller for example). This identifier is platform dependent.

"""

#*
#   \file SDL_joystick.h
#
#   In order to use these functions, SDL_Init() must have been called
#   with the ::SDL_INIT_JOYSTICK flag.  This causes SDL to scan the system
#   for joysticks, and load appropriate drivers.
#
#   If you would like to receive joystick updates while the application
#   is in the background, you should set the following hint before calling
#   SDL_Init(): SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS
#

# The joystick structure used to identify an SDL joystick#
type
  Joystick* = object
  JoystickPtr* = ptr Joystick

# A structure that encodes the stable unique id for a joystick device#
type
  JoystickGuid* = object
    data: array[16, uint8]
  JoystickID* = int32

{.push callconv: cdecl, dynlib: sdl2.LibName.}

#  Function prototypes# /
##
#   Count the number of joysticks attached to the system right now
# /
proc numJoysticks*(): cint {.
  importc: "SDL_NumJoysticks".}

##
#   Get the implementation dependent name of a joystick.
#   This can be called before any joysticks are opened.
#   If no name can be found, this function returns NULL.
# /
proc joystickNameForIndex*(device_index: cint): cstring {.
  importc: "SDL_JoystickNameForIndex".}

##
#   Open a joystick for use.
#   The index passed as an argument refers tothe N'th joystick on the system.
#   This index is the value which will identify this joystick in future joystick
#   events.
#
#   \return A joystick identifier, or NULL if an error occurred.
# /
proc joystickOpen*(device_index: cint): JoystickPtr {.
  importc: "SDL_JoystickOpen".}

##
#   Return the name for this currently opened joystick.
#   If no name can be found, this function returns NULL.
# /
proc joystickName*(joystick: ptr Joystick): cstring {.importc: "SDL_JoystickName".}
proc name* (joystick: ptr Joystick) {.inline.} = joystick.joystickName

##
#   Return the GUID for the joystick at this index
# /
proc joystickGetDeviceGUID*(device_index: cint): JoystickGUID {.
  importc: "SDL_JoystickGetDeviceGUID".}

# *
#   Return the GUID for this opened joystick
#
proc joystickGetGUID*(joystick: JoystickPtr): JoystickGUID {.
  importc: "SDL_JoystickGetGUID".}
proc getGUID* (joystick: JoystickPtr) {.inline.} = joystick.JoystickGetGUID

# *
#   Return a string representation for this guid. pszGUID must point to at least 33 bytes
#   (32 for the string plus a NULL terminator).
#
proc joystickGetGUIDString*(guid: JoystickGUID, pszGUID: cstring, cbGUID: cint) {.
  importc: "SDL_JoystickGetGUIDString".}

# *
#   convert a string into a joystick formatted guid
#
proc joystickGetGUIDFromString*(pchGUID: cstring): JoystickGUID {.
  importc: "SDL_JoystickGetGUIDFromString".}

# *
#   Returns SDL_TRUE if the joystick has been opened and currently connected, or SDL_FALSE if it has not.
#
proc joystickGetAttached*(joystick: JoystickPtr): Bool32 {.
  importc: "SDL_JoystickGetAttached".}
proc getAttached* (joystick: JoystickPtr) {.inline.} = joystick.JoystickGetAttached

# *
#   Get the instance ID of an opened joystick or -1 if the joystick is invalid.
#
proc joystickInstanceID*(joystick: JoystickPtr): JoystickID {.
  importc: "SDL_JoystickInstanceID".}
proc instanceID* (joystick: JoystickPtr) {.inline.} = joystick.JoystickInstanceID

# *
#   Get the number of general axis controls on a joystick.
#
proc joystickNumAxes*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumAxes".}
proc numAxes* (joystick: JoystickPtr) {.inline.} = joystick.JoystickNumAxes

# *
#   Get the number of trackballs on a joystick.
#
#   Joystick trackballs have only relative motion events associated
#   with them and their state cannot be polled.
#   events are enabled.
#
proc joystickNumBalls*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumBalls".}
proc numBalls* (joystick: JoystickPtr) {.inline.} = joystick.JoystickNumBalls

#
#   Get the number of POV hats on a joystick.
#
proc joystickNumHats*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumHats".}
proc numHats* (joystick: JoystickPtr) {.inline.} = joystick.JoystickNumHats

#
#   Get the number of buttons on a joystick.
#
proc joystickNumButtons*(joystick: JoystickPtr): cint {.
  importc: "SDL_JoystickNumButtons".}
proc numButtons* (joystick: JoystickPtr) {.inline.} = joystick.JoystickNumButtons

#
#   Update the current state of the open joysticks.
#
#   This is called automatically by the event loop if any joystick
#
proc joystickUpdate*() {.
  importc: "SDL_JoystickUpdate".}

#
#   Enable/disable joystick event polling.
#
#   If joystick events are disabled, you must call SDL_JoystickUpdate()
#   yourself and check the state of the joystick when you want joystick
#   information.
#
#   The state can be one of ::SDL_QUERY, ::SDL_ENABLE or ::SDL_IGNORE.
#
proc joystickEventState*(state: cint): cint {.
  importc: "SDL_JoystickEventState".}

#
#   Get the current state of an axis control on a joystick.
#
#   The state is a value ranging from -32768 to 32767.
#
#   The axis indices start at index 0.
#
proc joystickGetAxis*(joystick: JoystickPtr, axis: cint): Int16 {.
  importc: "SDL_JoystickGetAxis".}
proc getAxis* (joystick: JoystickPtr) {.inline.} = joystick.JoystickGetAxis(axis)

#
#   \name Hat positions
#
#  @{#
const
  SDL_HAT_CENTERED*:cint = (0x00000000)
  SDL_HAT_UP*:cint = (0x00000001)
  SDL_HAT_RIGHT*:cint = (0x00000002)
  SDL_HAT_DOWN*:cint = (0x00000004)
  SDL_HAT_LEFT*:cint = (0x00000008)
  SDL_HAT_RIGHTUP*:cint = (SDL_HAT_RIGHT or SDL_HAT_UP)
  SDL_HAT_RIGHTDOWN*:cint = (SDL_HAT_RIGHT or SDL_HAT_DOWN)
  SDL_HAT_LEFTUP*:cint = (SDL_HAT_LEFT or SDL_HAT_UP)
  SDL_HAT_LEFTDOWN*:cint = (SDL_HAT_LEFT or SDL_HAT_DOWN)
#  @}#

#
#   Get the current state of a POV hat on a joystick.
#
#   The hat indices start at index 0.
#
#   \return The return value is one of the following positions:
#            - ::SDL_HAT_CENTERED
#            - ::SDL_HAT_UP
#            - ::SDL_HAT_RIGHT
#            - ::SDL_HAT_DOWN
#            - ::SDL_HAT_LEFT
#            - ::SDL_HAT_RIGHTUP
#            - ::SDL_HAT_RIGHTDOWN
#            - ::SDL_HAT_LEFTUP
#            - ::SDL_HAT_LEFTDOWN
#
proc joystickGetHat*(joystick: JoystickPtr, hat: cint): Uint8
proc getHat* (joystick: JoystickPtr) {.inline.} = joystick.JoystickGetHat(hat)

#
#   Get the ball axis change since the last poll.
#
#   \return 0, or -1 if you passed it invalid parameters.
#
#   The ball indices start at index 0.
#
proc joystickGetBall*(joystick: JoystickPtr, ball: cint, dx: ptr cint, dy: ptr cint): cint
proc getBall* (joystick: JoystickPtr) {.inline.} = joystick.JoystickGetBall(ball, dx, dy)

#
#   Get the current state of a button on a joystick.
#
#   The button indices start at index 0.
#
proc joystickGetButton*(joystick: JoystickPtr, button: cint): Uint8
proc getButton* (joystick: JoystickPtr) {.inline.} = joystick.JoystickGetButton(button)

#
#   Close a joystick previously opened with SDL_JoystickOpen().
#
proc joystickClose*(joystick: JoystickPtr)
proc close* (joystick: JoystickPtr) {.inline.} = joystick.JoystickClose()

# Ends C function definitions when using C++

# vi: set ts=4 sw=4 expandtab:
{.pop.}

{.deprecated: [PJoystick: JoystickPtr].}
{.deprecated: [TJoystick: Joystick].}
{.deprecated: [TJoystickGuid: JoystickGuid].}
{.deprecated: [TJoystickID: JoystickID].}

{.deprecated: [Close: close].}
{.deprecated: [GetAttached: getAttached].}
{.deprecated: [GetAxis: getAxis].}
{.deprecated: [GetBall: getBall].}
{.deprecated: [GetButton: getButton].}
{.deprecated: [GetGUID: getGUID].}
{.deprecated: [GetHat: getHat].}
{.deprecated: [InstanceID: instanceID].}
{.deprecated: [JoystickClose: joystickClose].}
{.deprecated: [JoystickEventState: joystickEventState].}
{.deprecated: [JoystickGetAttached: joystickGetAttached].}
{.deprecated: [JoystickGetAxis: joystickGetAxis].}
{.deprecated: [JoystickGetBall: joystickGetBall].}
{.deprecated: [JoystickGetButton: joystickGetButton].}
{.deprecated: [JoystickGetDeviceGUID: joystickGetDeviceGUID].}
{.deprecated: [JoystickGetGUID: joystickGetGUID].}
{.deprecated: [JoystickGetGUIDFromString: joystickGetGUIDFromString].}
{.deprecated: [JoystickGetGUIDString: joystickGetGUIDString].}
{.deprecated: [JoystickGetHat: joystickGetHat].}
{.deprecated: [JoystickInstanceID: joystickInstanceID].}
{.deprecated: [JoystickName: joystickName].}
{.deprecated: [JoystickNameForIndex: joystickNameForIndex].}
{.deprecated: [JoystickNumAxes: joystickNumAxes].}
{.deprecated: [JoystickNumBalls: joystickNumBalls].}
{.deprecated: [JoystickNumButtons: joystickNumButtons].}
{.deprecated: [JoystickNumHats: joystickNumHats].}
{.deprecated: [JoystickOpen: joystickOpen].}
{.deprecated: [JoystickUpdate: joystickUpdate].}
{.deprecated: [Name: name].}
{.deprecated: [NumAxes: numAxes].}
{.deprecated: [NumBalls: numBalls].}
{.deprecated: [NumButtons: numButtons].}
{.deprecated: [NumHats: numHats].}
{.deprecated: [NumJoysticks: numJoysticks].}
