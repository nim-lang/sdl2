#  Simple DirectMedia Layer
#  Copyright (C) 1997-2014 Sam Lantinga <slouken@libsdl.org>
#
#  This software is provided 'as-is', without any express or implied
#  warranty.  In no event will the authors be held liable for any damages
#  arising from the use of this software.
#
#  Permission is granted to anyone to use this software for any purpose,
#  including commercial applications, and to alter it and redistribute it
#  freely, subject to the following restrictions:
#
#  1. The origin of this software must not be misrepresented; you must not
#     claim that you wrote the original software. If you use this software
#     in a product, an acknowledgment in the product documentation would be
#     appreciated but is not required.
#  2. Altered source versions must be plainly marked as such, and must not be
#     misrepresented as being the original software.
#  3. This notice may not be removed or altered from any source distribution.
#

## The SDL haptic subsystem allows you to control
## haptic (force feedback) devices.
##
## The basic usage is as follows:
## * Initialize the Subsystem (`sdl2.INIT_HAPTIC`).
## * Open a haptic Device.
##   - `hapticOpen proc<#hapticOpen,cint>`_ to open from index.
##   - `hapticOpenFromJoystick proc<#hapticOpenFromJoystick,JoystickPtr>`_ to open from an existing joystick.
## * Create an effect (`HapticEffect type<#HapticEffect>`_).
## * Upload the effect with `newEffect proc<#newEffect,HapticPtr,ptr.HapticEffect>`_.
## * Run the effect with `runEffect proc<#runEffect,HapticPtr,cint,uint32>`_.
## * (optional) Free the effect with `destroyEffect proc<#destroyEffect,HapticPtr,cint>`_.
## * Close the haptic device with `close proc<#close,HapticPtr>`_.

import "../sdl2"
import "joystick"


type
  Haptic* = object
    ## The haptic object used to identify an SDL haptic.
    ##
    ## **See also:**
    ## * `hapticOpen proc<#hapticOpen,cint>`_
    ## * `hapticOpenFromJoystick proc<#hapticOpenFromJoystick,JoystickPtr>`_
    ## * `close proc<#close,HapticPtr>`_

  HapticPtr* = ptr Haptic


const SDL_HAPTIC_CONSTANT* = (1 shl 0)
    ## Constant haptic effect.
    ##
    ## **See also:**
    ## * `HapticCondition type<#HapticCondition>`_

const SDL_HAPTIC_SINE* = (1 shl 1)
    ## Sine wave effect supported.
    ##
    ## Periodic haptic effect that simulates sine waves.
    ##
    ## **See also:**
    ## * `HapticPeriodic type<#HapticPeriodic>`_

const SDL_HAPTIC_LEFTRIGHT* = (1 shl 2)
    ## Left/Right effect supported.
    ##
    ## Haptic effect for direct control over high/low frequency motors.
    ##
    ## **See also:**
    ## * `HapticLeftRight type<#HapticLeftRight>`_
    ##
    ## `Warning:` this value was `SDL_HAPTIC_SQUARE` right before 2.0.0 shipped.
    ## Sorry, we ran out of bits, and this is important for XInput devices.


#  !!! FIXME: put this back when we have more bits in 2.1
#  const SDL_HAPTIC_SQUARE* = (1 shl 2)


const SDL_HAPTIC_TRIANGLE* = (1 shl 3)
    ## Triangle wave effect supported.
    ##
    ## Periodic haptic effect that simulates triangular waves.
    ##
    ## **See also:**
    ## * `HapticPeriodic type<#HapticPeriodic>`_

const SDL_HAPTIC_SAWTOOTHUP* = (1 shl 4)
    ## Sawtoothup wave effect supported.
    ##
    ## Periodic haptic effect that simulates saw tooth up waves.
    ##
    ## **See also:**
    ## * `HapticPeriodic type<#HapticPeriodic>`_

const SDL_HAPTIC_SAWTOOTHDOWN* = (1 shl 5)
    ## Sawtoothdown wave effect supported.
    ##
    ## Periodic haptic effect that simulates saw tooth down waves.
    ##
    ## **See also:**
    ## * `HapticPeriodic type<#HapticPeriodic>`_

const SDL_HAPTIC_RAMP* = (1 shl 6)
    ## Ramp effect supported.
    ##
    ## Ramp haptic effect.
    ##
    ## **See also:**
    ## * `HapticRamp type<#HapticRamp>`_

const SDL_HAPTIC_SPRING* = (1 shl 7)
    ## Spring effect supported - uses axes position.
    ##
    ## Condition haptic effect that simulates a spring.
    ## Effect is based on the axes position.
    ##
    ## **See also:**
    ## * `HapticCondition type<#HapticCondition>`_

const SDL_HAPTIC_DAMPER* = (1 shl 8)
    ## Damper effect supported - uses axes velocity.
    ##
    ## Condition haptic effect that simulates dampening.
    ## Effect is based on the axes velocity.
    ##
    ## **See also:**
    ## * `HapticCondition type<#HapticCondition>`_

const SDL_HAPTIC_INERTIA* = (1 shl 9)
    ## Inertia effect supported - uses axes acceleration.
    ##
    ## Condition haptic effect that simulates inertia.
    ## Effect is based on the axes acceleration.
    ##
    ## **See also:**
    ## * `HapticCondition type<#HapticCondition>`_

const SDL_HAPTIC_FRICTION* = (1 shl 10)
    ## Friction effect supported - uses axes movement.
    ##
    ## Condition haptic effect that simulates friction.
    ## Effect is based on the axes movement.
    ##
    ## **See also:**
    ## * `HapticCondition type<#HapticCondition>`_

const SDL_HAPTIC_CUSTOM* = (1 shl 11)
    ## Custom effect is supported.
    ##
    ## User defined custom haptic effect.

const SDL_HAPTIC_GAIN* = (1 shl 12)
    ## Device supports setting the global gain.
    ##
    ## **See also:**
    ## * `setGain proc<#setGain,HapticPtr,int>`_

const SDL_HAPTIC_AUTOCENTER* = (1 shl 13)
    ## Device supports setting autocenter.
    ##
    ## **See also:**
    ## * `setAutoCenter proc<#setAutoCenter,HapticPtr,int>`_

const SDL_HAPTIC_STATUS* = (1 shl 14)
    ## Device supports querying effect status.
    ##
    ## **See also:**
    ## * `getEffectStatus proc<#getEffectStatus,HapticPtr,cint>`_

const SDL_HAPTIC_PAUSE* = (1 shl 15)
    ## Devices supports being paused.
    ##
    ## **See also:**
    ## * `pause proc<#pause,HapticPtr>`_
    ## * `unpause proc<#unpause,HapticPtr>`_

const SDL_HAPTIC_POLAR* = 0
    ## Uses polar coordinates for the direction.
    ##
    ## **See also:**
    ## * `HapticDirection type<#HapticDirection>`_

const SDL_HAPTIC_CARTESIAN* = 1
    ## Uses cartesian coordinates for the direction.
    ##
    ## **See also:**
    ## * `HapticDirection type<#HapticDirection>`_

const SDL_HAPTIC_SPHERICAL* = 2
    ## Uses spherical coordinates for the direction.
    ##
    ## **See also:**
    ## * `HapticDirection type<#HapticDirection>`_

const SDL_HAPTIC_INFINITY* = 4294967295'u
    ## Used to play a device an infinite number of times.
    ##
    ## **See also:**
    ## * `runEffect proc<#runEffect,HapticPtr,cint,uint32>`_


type
  HapticDirection* = object
    ## Object that represents a haptic direction.
    ##
    ## This is the direction where the force comes from,
    ## instead of the direction in which the force is exerted.
    ##
    ## Directions can be specified by:
    ## * `SDL_HAPTIC_POLAR` : Specified by polar coordinates.
    ## * `SDL_HAPTIC_CARTESIAN` : Specified by cartesian coordinates.
    ## * `SDL_HAPTIC_SPHERICAL` : Specified by spherical coordinates.
    ##
    ## Cardinal directions of the haptic device
    ## are relative to the positioning of the device.
    ## North is considered to be away from the user.
    ##
    ## If type is `SDL_HAPTIC_POLAR`, direction is encoded by hundredths of a
    ## degree starting north and turning clockwise.
    ## `SDL_HAPTIC_POLAR` only uses the first `dir` parameter.
    ##
    ## The cardinal directions would be:
    ## * North: `0` (0 degrees)
    ## * East:  `9000` (90 degrees)
    ## * South: `18000` (180 degrees)
    ## * West:  `27000` (270 degrees)
    ##
    ## If type is `SDL_HAPTIC_CARTESIAN`, direction is encoded by three positions
    ## (X axis, Y axis and Z axis (with 3 axes)).
    ## `SDL_HAPTIC_CARTESIAN` uses the first three `dir` parameters.
    ##
    ## The cardinal directions would be:
    ## * North:  `0,-1, 0`
    ## * East:  `1, 0, 0`
    ## * South:  `0, 1, 0`
    ## * West:   `-1, 0, 0`
    ##
    ## The Z axis represents the height of the effect if supported, otherwise
    ## it's unused.  In cartesian encoding (1, 2) would be the same as (2, 4),
    ## you can use any multiple you want, only the direction matters.
    ##
    ## If type is `SDL_HAPTIC_SPHERICAL`, direction is encoded by two rotations.
    ## The first two `dir` parameters are used.
    ##
    ## The `dir` parameters are as follows
    ## (all values are in hundredths of degrees):
    ## * Degrees from (`1, 0`) rotated towards (`0, 1`).
    ## * Degrees towards (`0, 0, 1`) (device needs at least 3 axes).
    ##
    ## Example of force coming from the south with all encodings
    ## (force coming from the south means the user will have to pull
    ## the stick to counteract):
    ##
    ## .. code-block:: nim
    ##   var direction: HapticDirection
    ##   # Cartesian directions
    ##   direction.type = SDL_HAPTIC_CARTESIAN
    ##   direction.dir[0] = 0  # X position
    ##   direction.dir[1] = 1  # Y position
    ##   # Assuming the device has 2 axes,
    ##   # we don't need to specify third parameter.
    ##   # Polar directions
    ##   direction.type = SDL_HAPTIC_POLAR
    ##   direction.dir[0] = 18000  # Polar only uses first parameter
    ##   # Spherical coordinates
    ##   direction.type = SDL_HAPTIC_SPHERICAL # Spherical encoding
    ##   direction.dir[0] = 9000
    ##   # Since we only have two axes we don't need more parameters.
    ##
    ## The following diagram represents the cardinal directions:
    ## ::
    ##                .--.
    ##                |__| .-------.
    ##                |=.| |.-----.|
    ##                |--| ||     ||
    ##                |  | |'-----'|
    ##                |__|~')_____('
    ##                  [ COMPUTER ]
    ##
    ##
    ##                    North (0,-1)
    ##                        ^
    ##                        |
    ##                        |
    ##   (-1,0)  West <----[ HAPTIC ]----> East (1,0)
    ##                        |
    ##                        |
    ##                        v
    ##                     South (0,1)
    ##
    ##
    ##                     [ USER ]
    ##                       \|||/
    ##                       (o o)
    ##                 ---ooO-(_)-Ooo---
    ##
    ## **See also:**
    ## * `SDL_HAPTIC_POLAR const<#SDL_HAPTIC_POLAR>`_
    ## * `SDL_HAPTIC_CARTESIAN const<#SDL_HAPTIC_CARTESIAN>`_
    ## * `SDL_HAPTIC_SPHERICAL const<#SDL_HAPTIC_SPHERICAL>`_
    ## * `HapticEffect type<#HapticEffect>`_
    ## * `numAxes proc<#numAxes,HapticPtr>`_
    kind: uint8           ## The type of encoding.
    dir: array[3, int32]  ## The encoded direction.


type
  HapticConstant* = object
    ## An object containing a template for a Constant effect.
    ##
    ## The object is exclusively to the `HAPTIC_CONSTANT` effect.
    ##
    ## A constant effect applies a constant force
    ## in the specified direction to the joystick.
    ##
    ## **See also:**
    ## * `SDL_HAPTIC_CONSTANT const<#SDL_HAPTIC_CONSTANT>`_
    ## * `HapticEffect type<#HapticEffect>`_
    #  Header
    kind: uint16            ## SDL_HAPTIC_CONSTANT
    direction: HapticDirection  ## Direction of the effect.

    #  Replay
    length: uint32          ## Duration of the effect.
    delay: uint16           ## Delay before starting the effect.

    #  Trigger
    button: uint16          ## Button that triggers the effect.
    interval: uint16        ## How soon it can be triggered again after button.

    #  Constant
    level: int16           ## Strength of the constant effect.

    #  Envelope
    attack_length: uint16   ## Duration of the attack.
    attack_level: uint16    ## Level at the start of the attack.
    fade_length: uint16     ## Duration of the fade.
    fade_level: uint16      ## Level at the end of the fade.

type
  HapticPeriodic* = object
    ## An object containing a template for a Periodic effect.
    ##
    ## The object handles the following effects:
    ## * `HAPTIC_SINE`
    ## * `HAPTIC_LEFTRIGHT`
    ## * `HAPTIC_TRIANGLE`
    ## * `HAPTIC_SAWTOOTHUP`
    ## * `HAPTIC_SAWTOOTHDOWN`
    ##
    ## A periodic effect consists in a wave-shaped effect that repeats itself
    ## over time. The type determines the shape of the wave and the parameters
    ## determine the dimensions of the wave.
    ##
    ## Phase is given by hundredth of a degree meaning that giving the phase
    ## a value of `9000` will displace it 25% of its period.
    ##
    ## Here are sample values:
    ## *     `0`: No phase displacement.
    ## *  `9000`: Displaced 25% of its period.
    ## * `18000`: Displaced 50% of its period.
    ## * `27000`: Displaced 75% of its period.
    ## * `36000`: Displaced 100% of its period, \
    ## same as `0`, but `0` is preferred.
    ##
    ## Examples:
    ## ::
    ##   SDL_HAPTIC_SINE
    ##     __      __      __      __
    ##    /  \    /  \    /  \    /
    ##   /    \__/    \__/    \__/
    ##
    ##   SDL_HAPTIC_SQUARE
    ##    __    __    __    __    __
    ##   |  |  |  |  |  |  |  |  |  |
    ##   |  |__|  |__|  |__|  |__|  |
    ##
    ##   SDL_HAPTIC_TRIANGLE
    ##     /\    /\    /\    /\    /\
    ##    /  \  /  \  /  \  /  \  /
    ##   /    \/    \/    \/    \/
    ##
    ##   SDL_HAPTIC_SAWTOOTHUP
    ##     /|  /|  /|  /|  /|  /|  /|
    ##    / | / | / | / | / | / | / |
    ##   /  |/  |/  |/  |/  |/  |/  |
    ##
    ##   SDL_HAPTIC_SAWTOOTHDOWN
    ##   \  |\  |\  |\  |\  |\  |\  |
    ##    \ | \ | \ | \ | \ | \ | \ |
    ##     \|  \|  \|  \|  \|  \|  \|
    ##
    ## **See also:**
    ## * `SDL_HAPTIC_SINE const<#SDL_HAPTIC_SINE>`_
    ## * `SDL_HAPTIC_LEFTRIGHT const<#SDL_HAPTIC_LEFTRIGHT>`_
    ## * `SDL_HAPTIC_TRIANGLE const<#SDL_HAPTIC_TRIANGLE>`_
    ## * `SDL_HAPTIC_SAWTOOTHDOWN const<#SDL_HAPTIC_SAWTOOTHDOWN>`_
    ## * `SDL_HAPTIC_SAWTOOTHUP const<#SDL_HAPTIC_SAWTOOTHUP>`_
    ## * `HapticEffect type<#HapticEffect>`_
    #  Header
    kind: uint16        ## SDL_HAPTIC_SINE, SDL_HAPTIC_LEFTRIGHT,
                        ## SDL_HAPTIC_TRIANGLE, SDL_HAPTIC_SAWTOOTHUP or
                        ## SDL_HAPTIC_SAWTOOTHDOWN
    direction: HapticDirection  ## Direction of the effect.

    #  Replay
    length: uint32      ## Duration of the effect.
    delay: uint16       ## Delay before starting the effect.

    #  Trigger
    button: uint16      ## Button that triggers the effect.
    interval: uint16    ## How soon it can be triggered again after button.

    #  Periodic
    period: uint16      ## Period of the wave.
    magnitude: int16    ## Peak value.
    offset: int16       ## Mean value of the wave.
    phase: uint16       ## Horizontal shift given by hundredth of a cycle.

    #  Envelope
    attack_length: uint16   ## Duration of the attack.
    attack_level: uint16    ## Level at the start of the attack.
    fade_length: uint16 ## Duration of the fade.
    fade_level: uint16  ## Level at the end of the fade.

type
  HapticCondition* = object
    ## An object containing a template for a Condition effect.
    ##
    ## The object handles the following effects:
    ## * `HAPTIC_SPRING`: Effect based on axes position.
    ## * `HAPTIC_DAMPER`: Effect based on axes velocity.
    ## * `HAPTIC_INERTIA`: Effect based on axes acceleration.
    ## * `HAPTIC_FRICTION`: Effect based on axes movement.
    ##
    ## Direction is handled by condition internals
    ## instead of a direction member.
    ##
    ## The condition effect specific members have three parameters. The first
    ## refers to the X axis, the second refers to the Y axis and the third
    ## refers to the Z axis.  The right terms refer to the positive side
    ## of the axis and the left terms refer to the negative side of the axis.
    ##
    ## Please refer to the `HapticDirection` diagram for which side is
    ## positive and which is negative.
    ##
    ## **See also:**
    ## * `HapticDirection type<#HapticDirection>`_
    ## * `SDL_HAPTIC_SPRING const<#SDL_HAPTIC_SPRING>`_
    ## * `SDL_HAPTIC_DAMPER const<#SDL_HAPTIC_DAMPER>`_
    ## * `SDL_HAPTIC_INERTIA const<#SDL_HAPTIC_INERTIA>`_
    ## * `SDL_HAPTIC_FRICTION const<#SDL_HAPTIC_FRICTION>`_
    ## * `HapticEffect type<#HapticEffect>`_
    #  Header
    kind: uint16            ## SDL_HAPTIC_SPRING, SDL_HAPTIC_DAMPER,
                            ## SDL_HAPTIC_INERTIA or SDL_HAPTIC_FRICTION
    direction: HapticDirection  ## Direction of the effect - Not used ATM.

    #  Replay
    length: uint32          ## Duration of the effect.
    delay: uint16           ## Delay before starting the effect.

    #  Trigger
    button: uint16          ## Button that triggers the effect.
    interval: uint16        ## How soon it can be triggered again after button.

    #  Condition
    right_sat: array[3, uint16]    ## Level when joystick is to the positive side.
    left_sat: array[3, uint16]     ## Level when joystick is to the negative side.
    right_coeff: array[3, int16]  ## How fast to increase the force towards the positive side.
    left_coeff: array[3, int16]   ## How fast to increase the force towards the negative side.
    deadband: array[3, uint16]     ## Size of the dead zone.
    center: array[3, int16]       ## Position of the dead zone.

type
  HapticRamp* = object
    ## An object containing a template for a Ramp effect.
    ##
    ## This object is exclusively for the `HAPTIC_RAMP` effect.
    ##
    ## The ramp effect starts at start strength and ends at end strength.
    ## It augments in linear fashion.  If you use attack and fade with a ramp
    ## the effects get added to the ramp effect making the effect become
    ## quadratic instead of linear.
    ##
    ## **See also:**
    ## * `SDL_HAPTIC_RAMP const<#SDL_HAPTIC_RAMP>`_
    ## * `HapticEffect type<#HapticEffect>`_
    #  Header
    kind: uint16            ## SDL_HAPTIC_RAMP
    direction: HapticDirection  ## Direction of the effect.

    #  Replay
    length: uint32          ## Duration of the effect.
    delay: uint16           ## Delay before starting the effect.

    #  Trigger
    button: uint16          ## Button that triggers the effect.
    interval: uint16        ## How soon it can be triggered again after button.

    #  Ramp
    start: int16            ## Beginning strength level.
    fin: int16              ## Ending strength level.

    #  Envelope
    attack_length: uint16   ## Duration of the attack.
    attack_level: uint16    ## Level at the start of the attack.
    fade_length: uint16     ## Duration of the fade.
    fade_level: uint16      ## Level at the end of the fade.

type
  HapticLeftRight* = object
    ## An object containing a template for a Left/Right effect.
    ##
    ## This object is exclusively for the `HAPTIC_LEFTRIGHT` effect.
    ##
    ## The Left/Right effect is used to explicitly control the large and small
    ## motors, commonly found in modern game controllers.
    ## The small (right) motor is high frequency,
    ## and the large (left) motor is low frequency.
    ##
    ## **See also:**
    ## * `SDL_HAPTIC_LEFTRIGHT const<#SDL_HAPTIC_LEFTRIGHT>`_
    ## * `HapticEffect type<#HapticEffect>`_
    #  Header
    kind: uint16            ## SDL_HAPTIC_LEFTRIGHT

    #  Replay
    length: uint32          ## Duration of the effect.

    #  Rumble
    large_magnitude: uint16 ## Control of the large controller motor.
    small_magnitude: uint16 ## Control of the small controller motor.


type
  HapticCustom* = object
    ## An object containing a template for the `HAPTIC_CUSTOM` effect.
    ##
    ## This object is exclusively for the `HAPTIC_CUSTOM` effect.
    ##
    ## A custom force feedback effect is much like a periodic effect, where
    ## the application can define its exact shape.  You will have to allocate
    ## the data yourself.
    ## Data should consist of channels * samples `uint16` samples.
    ##
    ## If channels is one, the effect is rotated using the defined direction.
    ## Otherwise it uses the samples in data for the different axes.
    ##
    ## **See also:**
    ## * `SDL_HAPTIC_CUSTOM const<#SDL_HAPTIC_CUSTOM>`_
    ## * `HapticEffect type<#HapticEffect>`_
    #  Header
    kind: uint16            ## SDL_HAPTIC_CUSTOM
    direction: HapticDirection  ## Direction of the effect.

    #  Replay
    length: uint32          ## Duration of the effect.
    delay: uint16           ## Delay before starting the effect.

    #  Trigger
    button: uint16          ## Button that triggers the effect.
    interval: uint16        ## How soon it can be triggered again after button.

    #  Custom
    channels: uint8         ## Axes to use, minimum of one.
    period: uint16          ## Sample periods.
    samples: uint16         ## Amount of samples.
    data: ptr uint16        ## Should contain `channels*samples` items.

    #  Envelope
    attack_length: uint16   ## Duration of the attack.
    attack_level: uint16    ## Level at the start of the attack.
    fade_length: uint16     ## Duration of the fade.
    fade_level: uint16      ## Level at the end of the fade.

type
  HapticEffect* {.union.} = object
    ## The generic template for any haptic effect.
    ##
    ## All values max at `32767` (`0x7FFF`).
    ## Signed values also can be negative.
    ## Time values unless specified otherwise are in milliseconds.
    ##
    ## You can also pass `HAPTIC_INFINITY` to length instead of a `0`-`32767`
    ## value.  Neither delay, interval, attack_length nor fade_length support
    ## `HAPTIC_INFINITY`.  Fade will also not be used since effect never ends.
    ##
    ## Additionally, the `HAPTIC_RAMP` effect does not support a duration of
    ## `HAPTIC_INFINITY`.
    ##
    ## Button triggers may not be supported on all devices, it is advised to
    ## not use them if possible.  Buttons start at index `1` instead of index
    ## `0` like the joystick.
    ##
    ## If both `attack_length` and `fade_level` are `0`,
    ## the envelope is not used, otherwise both values are used.
    ##
    ## Common parts:
    ##
    ## .. code-block:: nim
    ##   # Replay - All effects have this
    ##   length: uint32      # Duration of effect (ms).
    ##   delay: uint16       # Delay before starting effect.
    ##   # Trigger - All effects have this
    ##   button: uint16      # Button that triggers effect.
    ##   interval: uint16    # How soon before effect can be triggered again.
    ##   # Envelope - All effects except condition effects have this
    ##   attack_length: uint16   # Duration of the attack (ms).
    ##   attack_level: uint16    # Level at the start of the attack.
    ##   fade_length: uint16     # Duration of the fade out (ms).
    ##   fade_level: uint16      # Level at the end of the fade.
    ##
    ## Here we have an example of a constant effect evolution in time:
    ## ::
    ##   Strength
    ##   ^
    ##   |
    ##   |    effect level -->  _________________
    ##   |                     /                 \
    ##   |                    /                   \
    ##   |                   /                     \
    ##   |                  /                       \
    ##   | attack_level --> |                        \
    ##   |                  |                        |  <---  fade_level
    ##   |
    ##   +--------------------------------------------------> Time
    ##                      [--]                 [---]
    ##                      attack_length        fade_length
    ##
    ##   [------------------][-----------------------]
    ##   delay               length
    ##
    ## Note either the attack_level or the fade_level may be above the actual
    ## effect level.
    ##
    ## **See also:**
    ## * `HapticConstant type<#HapticConstant>`_
    ## * `HapticPeriodic type<#HapticPeriodic>`_
    ## * `HapticCondition type<#HapticCondition>`_
    ## * `HapticRamp type<#HapticRamp>`_
    ## * `HapticLeftRight type<#HapticLeftRight>`_
    ## * `HapticCustom type<#HapticCustom>`_
    #  Common for all force feedback effects
    kind: uint16                ## Effect type.
    constant: HapticConstant    ## Constant effect.
    periodic: HapticPeriodic    ## Periodic effect.
    condition: HapticCondition  ## Condition effect.
    ramp: HapticRamp            ## Ramp effect.
    leftright: HapticLeftRight  ## Left/Right effect.
    custom: HapticCustom        ## Custom effect.


when defined(SDL_Static):
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."
else:
  {.push callConv: cdecl, dynlib: LibName.}

proc numHaptics*(): cint {.importc: "SDL_NumHaptics".}
  ## Count the number of haptic devices attached to the system.
  ##
  ## `Return` number of haptic devices detected on the system.

proc hapticName*(device_index: cint): cstring {.importc: "SDL_HapticName".}
  ## Get the implementation dependent name of a haptic device.
  ##
  ## This can be called before any joysticks are opened.
  ## If no name can be found, this procedure returns `nil`.
  ##
  ## `device_index` Index of the device to get its name.
  ##
  ## `Return` name of the device or `nil` on error.
  ##
  ## **See also:**
  ## * `numHaptics proc<#numHaptics>`_

proc hapticOpen*(device_index: cint): HapticPtr {.importc: "SDL_HapticOpen".}
  ## Opens a haptic device for usage.
  ##
  ## The index passed as an argument refers to the N'th haptic device
  ## on this system.
  ##
  ## When opening a haptic device, its gain will be set to maximum and
  ## autocenter will be disabled.  To modify these values use
  ## `hapticSetGain()` and `hapticSetAutocenter()`.
  ##
  ## `device_index` Index of the device to open.
  ##
  ## `Return` device identifier or `nil` on error.
  ##
  ## **See also:**
  ## * `index proc<#index,HapticPtr>`_
  ## * `hapticOpenFromMouse proc<#hapticOpenFromMouse>`_
  ## * `hapticOpenFromJoystick proc<#hapticOpenFromJoystick,JoystickPtr>`_
  ## * `close proc<#close,HapticPtr>`_
  ## * `setGain proc<#setGain,HapticPtr,int>`_
  ## * `setAutocenter proc<#setAutocenter,HapticPtr,int>`_
  ## * `pause proc<#pause,HapticPtr>`_
  ## * `stopAll proc<#stopAll,HapticPtr>`_

proc hapticOpened*(device_index: cint): cint {.importc: "SDL_HapticOpened".}
  ## Checks if the haptic device at index has been opened.
  ##
  ## `device_index` Index to check to see if it has been opened.
  ##
  ## `Return` `1` if it has been opened or `0` if it hasn't.
  ##
  ## **See also:**
  ## * `hapticOpen proc<#hapticOpen,cint>`_
  ## * `index proc<#index,HapticPtr>`_

proc index*(haptic: HapticPtr): cint {.importc: "SDL_HapticIndex".}
  ## Gets the index of a haptic device.
  ##
  ## `haptic` Haptic device to get the index of.
  ##
  ## `Return` The index of the haptic device or `-1` on error.
  ##
  ## **See also:**
  ## * `hapticOpen proc<#hapticOpen,cint>`_
  ## * `hapticOpened proc<#hapticOpened,cint>`_

proc mouseIsHaptic*(): cint {.importc: "SDL_MouseIsHaptic".}
  ## Gets whether or not the current mouse has haptic capabilities.
  ##
  ## `Return` `1` if the mouse is haptic, `0` if it isn't.
  ##
  ## **See also:**
  ## * `hapticOpenFromMouse proc<#hapticOpenFromMouse>`_

proc hapticOpenFromMouse*(): HapticPtr {.importc: "SDL_HapticOpenFromMouse".}
  ## Tries to open a haptic device from the current mouse.
  ##
  ## `Return` The haptic device identifier or `nil` on error.
  ##
  ## **See also:**
  ## * `mouseIsHaptic proc<#mouseIsHaptic>`_
  ## * `hapticOpen proc<#hapticOpen,cint>`_

proc joystickIsHaptic*(joystick: Joystick): cint {.importc: "SDL_JoystickIsHaptic".}
  ## Checks to see if a joystick has haptic features.
  ##
  ## `joystick` Joystick to test for haptic capabilities.
  ##
  ## `Return` `1` if the joystick is haptic, `0` if it isn't
  ## or `-1` if an error ocurred.
  ##
  ## **See also:**
  ## * `hapticOpenFromJoystick proc<#hapticOpenFromJoystick,JoystickPtr>`_

proc hapticOpenFromJoystick*(joystick: JoystickPtr): HapticPtr {.
  importc: "SDL_HapticOpenFromJoystick".}
  ## Opens a haptic device for usage from a joystick device.
  ##
  ## You must still close the haptic device separately.
  ## It will not be closed with the joystick.
  ##
  ## When opening from a joystick you should first close the haptic device
  ## before closing the joystick device. If not, on some implementations the
  ## haptic device will also get unallocated and you'll be unable to use
  ## force feedback on that device.
  ##
  ## `joystick` Joystick to create a haptic device from.
  ##
  ## `Return` A valid haptic device identifier on success or `nil` on error.
  ##
  ## **See also:**
  ## * `hapticOpen proc<#hapticOpen,cint>`_
  ## * `close proc<#close,HapticPtr>`_

proc close*(haptic: HapticPtr) {.importc: "SDL_HapticClose".}
  ## Closes a haptic device previously opened with `hapticOpen proc<#hapticOpen,cint>`_.
  ##
  ## `haptic` Haptic device to close.

proc numEffects*(haptic: HapticPtr):cint {.importc: "SDL_HapticNumEffects".}
  ## Returns the number of effects a haptic device can store.
  ##
  ## On some platforms this isn't fully supported, and therefore is an
  ## approximation.  Always check to see if your created effect was actually
  ## created and do not rely solely on `hapticNumEffects()`.
  ##
  ## `haptic` The haptic device to query effect max.
  ##
  ## `Return` The number of effects the haptic device can store
  ## or `-1` on error.
  ##
  ## **See also:**
  ## * `numEffectsPlaying proc<#numEffectsPlaying,HapticPtr>`_
  ## * `query proc<#query,HapticPtr>`_

proc numEffectsPlaying*(haptic: HapticPtr): cint {.
  importc: "SDL_HapticNumEffectsPlaying".}
  ## Returns the number of effects a haptic device can play at the same time.
  ##
  ## This is not supported on all platforms, but will always return a value.
  ## Added here for the sake of completeness.
  ##
  ## `haptic` The haptic device to query maximum playing effects.
  ##
  ## `Return` The number of effects the haptic device can play
  ## at the same time or `-1` on error.
  ##
  ## **See also:**
  ## * `numEffects proc<#numEffects,HapticPtr>`_
  ## * `query proc<#query,HapticPtr>`_

proc query*(haptic: HapticPtr): uint {.importc: "SDL_HapticQuery".}
  ## Gets the haptic device's supported features in bitwise manner.
  ##
  ## Example:
  ##
  ## .. code-block:: nim
  ##   if hapticQuery(haptic) and HAPTIC_CONSTANT:
  ##     echo("We have constant haptic effect!")
  ##
  ## `haptic` The haptic device to query.
  ##
  ## `Return` Haptic features in bitwise manner (OR'd).
  ##
  ## **See also:**
  ## * `numEffects proc<#numEffects,HapticPtr>`_
  ## * `effectSupported proc<#effectSupported,HapticPtr,ptr.HapticEffect>`_

proc numAxes*(haptic: HapticPtr):cint {.importc: "SDL_HapticNumAxes".}
  ## Gets the number of haptic axes the device has.
  ##
  ## **See also:**
  ## * `HapticDirection type<#HapticDirection>`_

proc effectSupported*(haptic: HapticPtr, effect: ptr HapticEffect): cint {.
  importc: "SDL_HapticEffectSupported".}
  ## Checks to see if effect is supported by haptic.
  ##
  ## `haptic` Haptic device to check on.
  ##
  ## `effect` Effect to check to see if it is supported.
  ##
  ## `Return` `1` if effect is supported, `0` if it isn't
  ## or `-1` on error.
  ##
  ## **See also:**
  ## * `query proc<#query,HapticPtr>`_
  ## * `newEffect proc<#newEffect,HapticPtr,ptr.HapticEffect>`_

proc newEffect*(haptic: HapticPtr, effect: ptr HapticEffect): cint {.
  importc: "SDL_HapticNewEffect".}
  ## Creates a new haptic effect on the device.
  ##
  ## `haptic` Haptic device to create the effect on.
  ##
  ## `effect` Properties of the effect to create.
  ##
  ## `Return` The identifier of the effect on success or `-1` on error.
  ##
  ## **See also:**
  ## * `updateEffect proc<#updateEffect,HapticPtr,cint,ptr.HapticEffect>`_
  ## * `runEffect proc<#runEffect,HapticPtr,cint,uint32>`_
  ## * `destroyEffect proc<#destroyEffect,HapticPtr,cint>`_

proc updateEffect*(haptic: HapticPtr, effect: cint,
  data: ptr HapticEffect): cint {.importc: "SDL_HapticUpdateEffect".}
  ## Updates the properties of an effect.
  ##
  ## Can be used dynamically, although behavior when dynamically changing
  ## direction may be strange.  Specifically the effect may reupload itself
  ## and start playing from the start.  You cannot change the type either
  ## when running `hapticUpdateEffect()`.
  ##
  ## `haptic` Haptic device that has the effect.
  ##
  ## `effect` Identifier of the effect to update.
  ##
  ## `data` New effect properties to use.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `newEffect proc<#newEffect,HapticPtr,ptr.HapticEffect>`_
  ## * `runEffect proc<#runEffect,HapticPtr,cint,uint32>`_
  ## * `destroyEffect proc<#destroyEffect,HapticPtr,cint>`_

proc runEffect*(haptic: HapticPtr, effect: cint,
                iterations: uint32): cint {.importc: "SDL_HapticRunEffect".}
  ## Runs the haptic effect on its associated haptic device.
  ##
  ## If iterations are `HAPTIC_INFINITY`, it'll run the effect over and over
  ## repeating the envelope (attack and fade) every time.
  ## If you only want the effect to last forever, set `HAPTIC_INFINITY`
  ## in the effect's length parameter.
  ##
  ## `haptic` Haptic device to run the effect on.
  ##
  ## `effect` Identifier of the haptic effect to run.
  ##
  ## `iterations` Number of iterations to run the effect.
  ## Use `HAPTIC_INFINITY` for infinity.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `stopEffect proc<#stopEffect,HapticPtr,cint>`_
  ## * `destroyEffect proc<#destroyEffect,HapticPtr,cint>`_
  ## * `getEffectStatus proc<#getEffectStatus,HapticPtr,cint>`_

proc stopEffect*(haptic: HapticPtr,
                 effect: cint): cint {.importc: "SDL_HapticStopEffect".}
  ## Stops the haptic effect on its associated haptic device.
  ##
  ## `haptic` Haptic device to stop the effect on.
  ##
  ## `effect` Identifier of the effect to stop.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `runEffect proc<#runEffect,HapticPtr,cint,uint32>`_
  ## * `destroyEffect proc<#destroyEffect,HapticPtr,cint>`_

proc destroyEffect*(haptic: HapticPtr,
                    effect: cint) {.importc: "SDL_HapticDestroyEffect".}
  ## Destroys a haptic effect on the device.
  ##
  ## This will stop the effect if it's running.  Effects are automatically
  ## destroyed when the device is closed.
  ##
  ## `haptic` Device to destroy the effect on.
  ##
  ## `effect` Identifier of the effect to destroy.
  ##
  ## **See also:**
  ## * `newEffect proc<#newEffect,HapticPtr,ptr.HapticEffect>`_

proc getEffectStatus*(haptic: HapticPtr, effect: cint): cint {.
  importc: "SDL_HapticGetEffectStatus".}
  ## Gets the status of the current effect on the haptic device.
  ##
  ## Device must support the `HAPTIC_STATUS` feature.
  ##
  ## `haptic` Haptic device to query the effect status on.
  ##
  ## `effect` Identifier of the effect to query its status.
  ##
  ## `Return` `0` if it isn't playing, `1` if it is playing
  ## or `-1` on error.
  ##
  ## **See also:**
  ## * `runEffect proc<#runEffect,HapticPtr,cint,uint32>`_
  ## * `stopEffect proc<#stopEffect,HapticPtr,cint>`_

proc setGain*(haptic: HapticPtr,
              gain: int): cint {.importc: "SDL_HapticSetGain".}
  ## Sets the global gain of the device.
  ##
  ## Device must support the `HAPTIC_GAIN` feature.
  ##
  ## The user may specify the maximum gain by setting the environment variable
  ## `HAPTIC_GAIN_MAX` which should be between `0` and `100`.  All calls to
  ## `hapticSetGain()` will scale linearly using `HAPTIC_GAIN_MAX` as the
  ## maximum.
  ##
  ## `haptic` Haptic device to set the gain on.
  ##
  ## `gain` Value to set the gain to, should be between `0` and `100`.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `query proc<#query,HapticPtr>`_

proc setAutocenter*(haptic: HapticPtr, autocenter: int): cint {.
  importc: "SDL_HapticSetAutocenter".}
  ## Sets the global autocenter of the device.
  ##
  ## Autocenter should be between `0` and `100`.
  ## Setting it to `0` will disable autocentering.
  ##
  ## Device must support the `HAPTIC_AUTOCENTER` feature.
  ##
  ## `haptic` Haptic device to set autocentering on.
  ##
  ## `autocenter` Value to set autocenter to, `0` disables autocentering.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `query proc<#query,HapticPtr>`_

proc pause*(haptic: HapticPtr): cint {.importc: "SDL_HapticPause".}
  ## Pauses a haptic device.
  ##
  ## Device must support the `HAPTIC_PAUSE` feature.
  ## Call `unpause()` to resume playback.
  ##
  ## Do not modify the effects nor add new ones while the device is paused.
  ## That can cause all sorts of weird errors.
  ##
  ## `haptic` Haptic device to pause.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `unpause proc<#unpause,HapticPtr>`_

proc unpause*(haptic: HapticPtr): cint {.importc: "SDL_HapticUnpause".}
  ## Unpauses a haptic device.
  ##
  ## Call to unpause after `pause()`.
  ##
  ## `haptic` Haptic device to unpause.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `pause proc<#pause,HapticPtr>`_

proc stopAll*(haptic: HapticPtr): cint {.importc: "SDL_HapticStopAll".}
  ## Stops all the currently playing effects on a haptic device.
  ##
  ## `haptic` Haptic device to stop.
  ##
  ## `Return` `0` on success or `-1` on error.

proc rumbleSupported*(haptic: HapticPtr): cint {.
  importc: "SDL_HapticRumbleSupported".}
  ## Checks to see if rumble is supported on a haptic device.
  ##
  ## `haptic` Haptic device to check to see if it supports rumble.
  ##
  ## `Return` `1` if effect is supported, `0` if it isn't
  ## or `-1` on error.
  ##
  ## **See also:**
  ## * `rumbleInit proc<#rumbleInit,HapticPtr>`_
  ## * `rumblePlay proc<#rumblePlay,HapticPtr,float,uint32>`_
  ## * `rumbleStop proc<#rumbleStop,HapticPtr>`_

proc rumbleInit*(haptic: HapticPtr): cint {.importc: "SDL_HapticRumbleInit".}
  ## Initializes the haptic device for simple rumble playback.
  ##
  ## `haptic` Haptic device to initialize for simple rumble playback.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `hapticOpen proc<#hapticOpen,cint>`_
  ## * `rumbleSupported proc<#rumbleSupported,HapticPtr>`_
  ## * `rumblePlay proc<#rumblePlay,HapticPtr,float,uint32>`_
  ## * `rumbleStop proc<#rumbleStop,HapticPtr>`_

proc rumblePlay*(haptic: HapticPtr, strength: float, length: uint32): cint {.
  importc: "SDL_HapticRumblePlay".}
  ## Runs simple rumble on a haptic device
  ##
  ## `haptic` Haptic device to play rumble effect on.
  ##
  ## `strength` Strength of the rumble to play as a `0`-`1` float value.
  ##
  ## `length` Length of the rumble to play in milliseconds.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `rumbleSupported proc<#rumbleSupported,HapticPtr>`_
  ## * `rumbleInit proc<#rumbleInit,HapticPtr>`_
  ## * `rumbleStop proc<#rumbleStop,HapticPtr>`_

proc rumbleStop*(haptic: HapticPtr):cint {.importc: "SDL_HapticRumbleStop".}
  ## Stops the simple rumble on a haptic device.
  ##
  ## `haptic` Haptic to stop the rumble on.
  ##
  ## `Return` `0` on success or `-1` on error.
  ##
  ## **See also:**
  ## * `rumbleSupported proc<#rumbleSupported,HapticPtr>`_
  ## * `rumbleInit proc<#rumbleInit,HapticPtr>`_
  ## * `rumbleStop proc<#rumbleStop,HapticPtr>`_


when not defined(SDL_Static):
  {.pop.}
