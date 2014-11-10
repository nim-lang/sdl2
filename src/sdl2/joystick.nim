import sdl2


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
  TJoystick* = object
  PJoystick* = ptr TJoystick

# A structure that encodes the stable unique id for a joystick device#
type
  TJoystickGuid* = object
    data: array[16, uint8]
  TJoystickID* = Int32

{.push callconv: cdecl, dynlib: sdl2.LibName, importc: "SDL_$1".}

#  Function prototypes# /
## 
#   Count the number of joysticks attached to the system right now
# /
proc NumJoysticks*(): cint

## 
#   Get the implementation dependent name of a joystick.
#   This can be called before any joysticks are opened.
#   If no name can be found, this function returns NULL.
# /
proc JoystickNameForIndex*(device_index: cint): cstring

## 
#   Open a joystick for use.
#   The index passed as an argument refers tothe N'th joystick on the system.
#   This index is the value which will identify this joystick in future joystick
#   events.
# 
#   \return A joystick identifier, or NULL if an error occurred.
# /
proc  JoystickOpen*(device_index: cint): PJoystick

## 
#   Return the name for this currently opened joystick.
#   If no name can be found, this function returns NULL.
# /
proc JoystickName*(joystick: PJoystick): cstring
proc Name* (joystick: PJoystick) {.inline.} = joystick.JoystickName

## 
#   Return the GUID for the joystick at this index
# /
proc JoystickGetDeviceGUID*(device_index: cint): TJoystickGUID

# *
#   Return the GUID for this opened joystick
#   
proc JoystickGetGUID*(joystick: PJoystick): TJoystickGUID
proc GetGUID* (joystick: PJoystick) {.inline.} = joystick.JoystickGetGUID

# *
#   Return a string representation for this guid. pszGUID must point to at least 33 bytes
#   (32 for the string plus a NULL terminator).
#   
proc JoystickGetGUIDString*(guid: TJoystickGUID, pszGUID: cstring, cbGUID: cint)

# *
#   convert a string into a joystick formatted guid
#   
proc JoystickGetGUIDFromString*(pchGUID: cstring): TJoystickGUID

# *
#   Returns SDL_TRUE if the joystick has been opened and currently connected, or SDL_FALSE if it has not.
#   
proc JoystickGetAttached*(joystick: PJoystick): Bool32
proc GetAttached* (joystick: PJoystick) {.inline.} = joystick.JoystickGetAttached

# *
#   Get the instance ID of an opened joystick or -1 if the joystick is invalid.
#   
proc JoystickInstanceID*(joystick: PJoystick): TJoystickID
proc InstanceID* (joystick: PJoystick) {.inline.} = joystick.JoystickInstanceID

# *
#   Get the number of general axis controls on a joystick.
#   
proc JoystickNumAxes*(joystick: PJoystick): cint
proc NumAxes* (joystick: PJoystick) {.inline.} = joystick.JoystickNumAxes

# *
#   Get the number of trackballs on a joystick.
#
#   Joystick trackballs have only relative motion events associated
#   with them and their state cannot be polled.
#   events are enabled.
#   
proc JoystickNumBalls*(joystick: PJoystick): cint
proc NumBalls* (joystick: PJoystick) {.inline.} = joystick.JoystickNumBalls

#  
#   Get the number of POV hats on a joystick.
#  
proc JoystickNumHats*(joystick: PJoystick): cint
proc NumHats* (joystick: PJoystick) {.inline.} = joystick.JoystickNumHats

#  
#   Get the number of buttons on a joystick.
#  
proc JoystickNumButtons*(joystick: PJoystick): cint
proc NumButtons* (joystick: PJoystick) {.inline.} = joystick.JoystickNumButtons

#  
#   Update the current state of the open joysticks.
#
#   This is called automatically by the event loop if any joystick
#  
proc JoystickUpdate*()

#  
#   Enable/disable joystick event polling.
#
#   If joystick events are disabled, you must call SDL_JoystickUpdate()
#   yourself and check the state of the joystick when you want joystick
#   information.
#
#   The state can be one of ::SDL_QUERY, ::SDL_ENABLE or ::SDL_IGNORE.
#  
proc JoystickEventState*(state: cint): cint

#  
#   Get the current state of an axis control on a joystick.
#
#   The state is a value ranging from -32768 to 32767.
#
#   The axis indices start at index 0.
#  
proc JoystickGetAxis*(joystick: PJoystick, axis: cint): Int16
proc GetAxis* (joystick: PJoystick) {.inline.} = joystick.JoystickGetAxis(axis)

#
#   \name Hat positions
#
#  @{#  
const
  SDL_HAT_CENTERED* = (0x00000000)
  SDL_HAT_UP* = (0x00000001)
  SDL_HAT_RIGHT* = (0x00000002)
  SDL_HAT_DOWN* = (0x00000004)
  SDL_HAT_LEFT* = (0x00000008)
  SDL_HAT_RIGHTUP* = (SDL_HAT_RIGHT or SDL_HAT_UP)
  SDL_HAT_RIGHTDOWN* = (SDL_HAT_RIGHT or SDL_HAT_DOWN)
  SDL_HAT_LEFTUP* = (SDL_HAT_LEFT or SDL_HAT_UP)
  SDL_HAT_LEFTDOWN* = (SDL_HAT_LEFT or SDL_HAT_DOWN)
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
proc JoystickGetHat*(joystick: PJoystick, hat: cint): Uint8
proc GetHat* (joystick: PJoystick) {.inline.} = joystick.JoystickGetHat(hat)

#  
#   Get the ball axis change since the last poll.
#
#   \return 0, or -1 if you passed it invalid parameters.
#
#   The ball indices start at index 0.
#  
proc JoystickGetBall*(joystick: PJoystick, ball: cint, dx: ptr cint, dy: ptr cint): cint
proc GetBall* (joystick: PJoystick) {.inline.} = joystick.JoystickGetBall(ball, dx, dy)

#  
#   Get the current state of a button on a joystick.
#
#   The button indices start at index 0.
#  
proc JoystickGetButton*(joystick: PJoystick, button: cint): Uint8
proc GetButton* (joystick: PJoystick) {.inline.} = joystick.JoystickGetButton(button)

#  
#   Close a joystick previously opened with SDL_JoystickOpen().
#  
proc JoystickClose*(joystick: PJoystick)
proc Close* (joystick: PJoystick) {.inline.} = joystick.JoystickClose()

# Ends C function definitions when using C++ 

# vi: set ts=4 sw=4 expandtab: 
{.pop.}