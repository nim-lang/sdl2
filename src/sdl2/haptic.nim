import "../sdl2"
import "joystick"

#
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

#  
#  \file SDL_haptic.h
#  
#  \brief The SDL Haptic subsystem allows you to control haptic (force feedback)
#         devices.
#  
#  The basic usage is as follows:
#   - Initialize the Subsystem (::SDL_INIT_HAPTIC).
#   - Open a Haptic Device.
#    - SDL_HapticOpen() to open from index.
#    - SDL_HapticOpenFromJoystick() to open from an existing joystick.
#   - Create an effect (::SDL_HapticEffect).
#   - Upload the effect with SDL_HapticNewEffect().
#   - Run the effect with SDL_HapticRunEffect().
#   - (optional) Free the effect with SDL_HapticDestroyEffect().
#   - Close the haptic device with SDL_HapticClose().
#  
#   \par Simple rumble example:
#   \code
#    haptic: HapticPtr;
# 
#    // Open the device
#    haptic = SDL_HapticOpen( 0 );
#    if (haptic == NULL)
#       return -1;
# 
#    // Initialize simple rumble
#    if (SDL_HapticRumbleInit( haptic ) != 0)
#       return -1;
# 
#    // Play effect at 50% strength for 2 seconds
#    if (SDL_HapticRumblePlay( haptic, 0.5, 2000 ) != 0)
#       return -1;
#    SDL_Delay( 2000 );
# 
#    // Clean up
#    SDL_HapticClose( haptic );
#  \endcode
# 
#  \par Complete example:
#  \code
#  int test_haptic( joystick: Joystick ) {
#    haptic: HapticPtr;
#    SDL_HapticEffect effect;
#    effect: cint_id;
# 
#    // Open the device
#    haptic = SDL_HapticOpenFromJoystick( joystick );
#    if (haptic == NULL) return -1; // Most likely joystick isn't haptic
# 
#    // See if it can do sine waves
#    if ((SDL_HapticQuery(haptic) & SDL_HAPTIC_SINE)==0) {
#       SDL_HapticClose(haptic); // No sine effect
#       return -1;
#    }
# 
#    // Create the effect
#    memset( &effect, 0, sizeof(SDL_HapticEffect) ); // 0 is safe default
#    effect.type = SDL_HAPTIC_SINE;
#    effect.periodic.direction.type = SDL_HAPTIC_POLAR; // Polar coordinates
#    effect.periodic.direction.dir[0] = 18000; // Force comes from south
#    effect.periodic.period = 1000; // 1000 ms
#    effect.periodic.magnitude = 20000; // 20000/32767 strength
#    effect.periodic.length = 5000; // 5 seconds long
#    effect.periodic.attack_length = 1000; // Takes 1 second to get max strength
#    effect.periodic.fade_length = 1000; // Takes 1 second to fade away
# 
#    // Upload the effect
#    effect_id = SDL_HapticNewEffect( haptic, &effect );
# 
#    // Test the effect
#    SDL_HapticRunEffect( haptic, effect_id, 1 );
#    SDL_Delay( 5000); // Wait for the effect to finish
# 
#    // We destroy the effect, although closing the device also does this
#    SDL_HapticDestroyEffect( haptic, effect_id );
# 
#    // Close the device
#    SDL_HapticClose(haptic);
# 
#    return 0; // Success
#  }
#  \endcode
# 
#  You can also find out more information on my blog:
#  http://bobbens.dyndns.org/journal/2010/sdl_haptic/
# 
#  \author Edgar Simo Serra
# /

#  
#  \typedef SDL_Haptic
# 
#  \brief The haptic structure used to identify an SDL haptic.
# 
#  \sa SDL_HapticOpen
#  \sa SDL_HapticOpenFromJoystick
#  \sa SDL_HapticClose
 
type
  Haptic* = object
  HapticPtr* = ptr Haptic


#  
#  \name Haptic features
# 
#  Different haptic features a device can have.
 
#  @{ 

#  
#  \name Haptic effects
 
#  @{ 

#  
#  \brief Constant effect supported.
# 
#  Constant haptic effect.
# 
#  \sa SDL_HapticCondition
 
const SDL_HAPTIC_CONSTANT* = (1 shl 0)

#  
#  \brief Sine wave effect supported.
# 
#  Periodic haptic effect that simulates sine waves.
# 
#  \sa SDL_HapticPeriodic
 
const SDL_HAPTIC_SINE* = (1 shl 1)

#  
#  \brief Left/Right effect supported.
# 
#  Haptic effect for direct control over high/low frequency motors.
# 
#  \sa SDL_HapticLeftRight
#  \warning this value was SDL_HAPTIC_SQUARE right before 2.0.0 shipped. Sorry,
#          we ran out of bits, and this is important for XInput devices.
 
const SDL_HAPTIC_LEFTRIGHT* = (1 shl 2)

#  !!! FIXME: put this back when we have more bits in 2.1 
#  const SDL_HAPTIC_SQUARE* = (1 shl 2) 

#  
#  \brief Triangle wave effect supported.
# 
#  Periodic haptic effect that simulates triangular waves.
# 
#  \sa SDL_HapticPeriodic
 
const SDL_HAPTIC_TRIANGLE* = (1 shl 3)

#  
#  \brief Sawtoothup wave effect supported.
# 
#  Periodic haptic effect that simulates saw tooth up waves.
# 
#  \sa SDL_HapticPeriodic
 
const SDL_HAPTIC_SAWTOOTHUP* = (1 shl 4)

#  
#  \brief Sawtoothdown wave effect supported.
# 
#  Periodic haptic effect that simulates saw tooth down waves.
# 
#  \sa SDL_HapticPeriodic
 
const SDL_HAPTIC_SAWTOOTHDOWN* = (1 shl 5)

#  
#  \brief Ramp effect supported.
# 
#  Ramp haptic effect.
# 
#  \sa SDL_HapticRamp
 
const SDL_HAPTIC_RAMP* = (1 shl 6)

#  
#  \brief Spring effect supported - uses axes position.
# 
#  Condition haptic effect that simulates a spring.  Effect is based on the
#  axes position.
# 
#  \sa SDL_HapticCondition
 
const SDL_HAPTIC_SPRING* = (1 shl 7)

#  
#  \brief Damper effect supported - uses axes velocity.
# 
#  Condition haptic effect that simulates dampening.  Effect is based on the
#  axes velocity.
# 
#  \sa SDL_HapticCondition
 
const SDL_HAPTIC_DAMPER* = (1 shl 8)

#  
#  \brief Inertia effect supported - uses axes acceleration.
# 
#  Condition haptic effect that simulates inertia.  Effect is based on the axes
#  acceleration.
# 
#  \sa SDL_HapticCondition
 
const SDL_HAPTIC_INERTIA* = (1 shl 9)

#  
#  \brief Friction effect supported - uses axes movement.
# 
#  Condition haptic effect that simulates friction.  Effect is based on the
#  axes movement.
# 
#  \sa SDL_HapticCondition
 
const SDL_HAPTIC_FRICTION* = (1 shl 10)

#  
#  \brief Custom effect is supported.
# 
#  User defined custom haptic effect.
 
const SDL_HAPTIC_CUSTOM* = (1 shl 11)

#  @} #  Haptic effects 

#  These last few are features the device has, not effects 

#  
#  \brief Device can set global gain.
# 
#  Device supports setting the global gain.
# 
#  \sa SDL_HapticSetGain
 
const SDL_HAPTIC_GAIN* = (1 shl 12)

#  
#  \brief Device can set autocenter.
# 
#  Device supports setting autocenter.
# 
#  \sa SDL_HapticSetAutocenter
 
const SDL_HAPTIC_AUTOCENTER* = (1 shl 13)

#  
#  \brief Device can be queried for effect status.
# 
#  Device can be queried for effect status.
# 
#  \sa SDL_HapticGetEffectStatus
 
const SDL_HAPTIC_STATUS* = (1 shl 14)

#  
#  \brief Device can be paused.
# 
#  \sa SDL_HapticPause
#  \sa SDL_HapticUnpause
 
const SDL_HAPTIC_PAUSE* = (1 shl 15)


#  
#  \name Direction encodings
 
#  @{ 

#  
#  \brief Uses polar coordinates for the direction.
# 
#  \sa HapticDirection
 
const SDL_HAPTIC_POLAR* = 0

#  
#  \brief Uses cartesian coordinates for the direction.
# 
#  \sa HapticDirection
 
const SDL_HAPTIC_CARTESIAN* = 1

#  
#  \brief Uses spherical coordinates for the direction.
# 
#  \sa HapticDirection
 
const SDL_HAPTIC_SPHERICAL* = 2

#  @} #  Direction encodings 

#  @} #  Haptic features 

# 
#  Misc defines.
 

#  
#  \brief Used to play a device an infinite number of times.
# 
#  \sa SDL_HapticRunEffect
 
const SDL_HAPTIC_INFINITY* = 4294967295'u


#  
#  \brief Structure that represents a haptic direction.
# 
#  Directions can be specified by:
#   - ::SDL_HAPTIC_POLAR : Specified by polar coordinates.
#   - ::SDL_HAPTIC_CARTESIAN : Specified by cartesian coordinates.
#   - ::SDL_HAPTIC_SPHERICAL : Specified by spherical coordinates.
# 
#  Cardinal directions of the haptic device are relative to the positioning
#  of the device.  North is considered to be away from the user.
# 
#  The following diagram represents the cardinal directions:
#  \verbatim
#                 .--.
#                 |__| .-------.
#                 |=.| |.-----.|
#                 |--| ||     ||
#                 |  | |'-----'|
#                 |__|~')_____('
#                   [ COMPUTER ]
#
#
#                     North (0,-1)
#                         ^
#                         |
#                         | = (1,0)  West <----[ HAPTIC ]----> East (-1,0)
#                         |
#                         |
#                         v
#                      South (0,1)
#
#
#                      [ USER ]
#                        \|||/ = (o o)
#                  ---ooO-(_)-Ooo---
#    \endverbatim
# 
#  If type is ::SDL_HAPTIC_POLAR, direction is encoded by hundredths of a
#  degree starting north and turning clockwise.  ::SDL_HAPTIC_POLAR only uses
#  the first \c dir parameter.  The cardinal directions would be:
#   - North: 0 (0 degrees)
#   - East: 9000 (90 degrees)
#   - South: 18000 (180 degrees)
#   - West: 27000 (270 degrees)
# 
#  If type is ::SDL_HAPTIC_CARTESIAN, direction is encoded by three positions
# = (X axis, Y axis and Z axis (with 3 axes)).  ::SDL_HAPTIC_CARTESIAN uses
#  the first three \c dir parameters.  The cardinal directions would be:
#   - North:  0,-1, 0
#   - East:  -1, 0, 0
#   - South:  0, 1, 0
#   - West:   1, 0, 0
# 
#  The Z axis represents the height of the effect if supported, otherwise
#  it's unused.  In cartesian encoding (1, 2) would be the same as (2, 4), you
#  can use any multiple you want, only the direction matters.
# 
#  If type is ::SDL_HAPTIC_SPHERICAL, direction is encoded by two rotations.
#  The first two \c dir parameters are used.  The \c dir parameters are as
#  follows (all values are in hundredths of degrees):
#   - Degrees from (1, 0) rotated towards (0, 1).
#   - Degrees towards (0, 0, 1) (device needs at least 3 axes).
# 
# 
#  Example of force coming from the south with all encodings (force coming
#  from the south means the user will have to pull the stick to counteract):
#  \code
#  HapticDirection direction;
# 
#  // Cartesian directions
#  direction.type = SDL_HAPTIC_CARTESIAN; // Using cartesian direction encoding.
#  direction.dir[0] = 0; // X position
#  direction.dir[1] = 1; // Y position
#  // Assuming the device has 2 axes, we don't need to specify third parameter.
# 
#  // Polar directions
#  direction.type = SDL_HAPTIC_POLAR; // We'll be using polar direction encoding.
#  direction.dir[0] = 18000; // Polar only uses first parameter
# 
#  // Spherical coordinates
#  direction.type = SDL_HAPTIC_SPHERICAL; // Spherical encoding
#  direction.dir[0] = 9000; // Since we only have two axes we don't need more parameters.
#  \endcode
# 
#  \sa SDL_HAPTIC_POLAR
#  \sa SDL_HAPTIC_CARTESIAN
#  \sa SDL_HAPTIC_SPHERICAL
#  \sa SDL_HapticEffect
#  \sa SDL_HapticNumAxes
 
type
  HapticDirection* = object
    kind: uint8         #  < The type of encoding. 
    dir: array[3, int32]      #  < The encoded direction. 


#  
#  \brief A structure containing a template for a Constant effect.
# 
#  The struct is exclusive to the ::SDL_HAPTIC_CONSTANT effect.
# 
#  A constant effect applies a constant force in the specified direction
#  to the joystick.
# 
#  \sa SDL_HAPTIC_CONSTANT
#  \sa SDL_HapticEffect
 
type
  HapticConstant* = object
    #  Header 
    kind: uint16            #  < ::SDL_HAPTIC_CONSTANT 
    direction: HapticDirection  #  < Direction of the effect. 

    #  Replay 
    length: uint32          #  < Duration of the effect. 
    delay: uint16           #  < Delay before starting the effect. 

    #  Trigger 
    button: uint16          #  < Button that triggers the effect. 
    interval: uint16        #  < How soon it can be triggered again after button. 

    #  Constant 
    level: int16           #  < Strength of the constant effect. 

    #  Envelope 
    attack_length: uint16   #  < Duration of the attack. 
    attack_level: uint16    #  < Level at the start of the attack. 
    fade_length: uint16     #  < Duration of the fade. 
    fade_level: uint16      #  < Level at the end of the fade. 

#  
#  \brief A structure containing a template for a Periodic effect.
# 
#  The struct handles the following effects:
#   - ::SDL_HAPTIC_SINE
#   - ::SDL_HAPTIC_LEFTRIGHT
#   - ::SDL_HAPTIC_TRIANGLE
#   - ::SDL_HAPTIC_SAWTOOTHUP
#   - ::SDL_HAPTIC_SAWTOOTHDOWN
# 
#  A periodic effect consists in a wave-shaped effect that repeats itself
#  over time.  The type determines the shape of the wave and the parameters
#  determine the dimensions of the wave.
# 
#  Phase is given by hundredth of a cycle meaning that giving the phase a value
#  of 9000 will displace it 25% of its period.  Here are sample values:
#   -     0: No phase displacement.
#   -  9000: Displaced 25% of its period.
#   - 18000: Displaced 50% of its period.
#   - 27000: Displaced 75% of its period.
#   - 36000: Displaced 100% of its period, same as 0, but 0 is preferred.
# 
#  Examples:
#  \verbatim
#    SDL_HAPTIC_SINE
#      __      __      __      __
#     /  \    /  \    /  \    /
#    /    \__/    \__/    \__/
#
#    SDL_HAPTIC_SQUARE
#     __    __    __    __    __
#    |  |  |  |  |  |  |  |  |  |
#    |  |__|  |__|  |__|  |__|  |
#
#    SDL_HAPTIC_TRIANGLE
#      /\    /\    /\    /\    /\
#     /  \  /  \  /  \  /  \  /
#    /    \/    \/    \/    \/
#
#    SDL_HAPTIC_SAWTOOTHUP
#      /|  /|  /|  /|  /|  /|  /|
#     / | / | / | / | / | / | / |
#    /  |/  |/  |/  |/  |/  |/  |
#
#    SDL_HAPTIC_SAWTOOTHDOWN
#    \  |\  |\  |\  |\  |\  |\  |
#     \ | \ | \ | \ | \ | \ | \ |
#      \|  \|  \|  \|  \|  \|  \|
#    \endverbatim
# 
#  \sa SDL_HAPTIC_SINE
#  \sa SDL_HAPTIC_LEFTRIGHT
#  \sa SDL_HAPTIC_TRIANGLE
#  \sa SDL_HAPTIC_SAWTOOTHUP
#  \sa SDL_HAPTIC_SAWTOOTHDOWN
#  \sa SDL_HapticEffect
 
type
  HapticPeriodic* = object
    #  Header 
    kind: uint16        #  < ::SDL_HAPTIC_SINE, ::SDL_HAPTIC_LEFTRIGHT,
                        #    ::SDL_HAPTIC_TRIANGLE, ::SDL_HAPTIC_SAWTOOTHUP or
                        #    ::SDL_HAPTIC_SAWTOOTHDOWN 
    direction: HapticDirection  #  < Direction of the effect. 

    #  Replay 
    length: uint32      #  < Duration of the effect. 
    delay: uint16       #  < Delay before starting the effect. 

    #  Trigger 
    button: uint16      #  < Button that triggers the effect. 
    interval: uint16    #  < How soon it can be triggered again after button. 

    #  Periodic 
    period: uint16      #  < Period of the wave. 
    magnitude: int16   #  < Peak value. 
    offset: int16      #  < Mean value of the wave. 
    phase: uint16       #  < Horizontal shift given by hundredth of a cycle. 

    #  Envelope 
    attack_length: uint16   #  < Duration of the attack. 
    attack_level: uint16    #  < Level at the start of the attack. 
    fade_length: uint16 #  < Duration of the fade. 
    fade_level: uint16  #  < Level at the end of the fade. 

#  
#  \brief A structure containing a template for a Condition effect.
# 
#  The struct handles the following effects:
#   - ::SDL_HAPTIC_SPRING: Effect based on axes position.
#   - ::SDL_HAPTIC_DAMPER: Effect based on axes velocity.
#   - ::SDL_HAPTIC_INERTIA: Effect based on axes acceleration.
#   - ::SDL_HAPTIC_FRICTION: Effect based on axes movement.
# 
#  Direction is handled by condition internals instead of a direction member.
#  The condition effect specific members have three parameters.  The first
#  refers to the X axis, the second refers to the Y axis and the third
#  refers to the Z axis.  The right terms refer to the positive side of the
#  axis and the left terms refer to the negative side of the axis.  Please
#  refer to the ::HapticDirection diagram for which side is positive and
#  which is negative.
# 
#  \sa HapticDirection
#  \sa SDL_HAPTIC_SPRING
#  \sa SDL_HAPTIC_DAMPER
#  \sa SDL_HAPTIC_INERTIA
#  \sa SDL_HAPTIC_FRICTION
#  \sa SDL_HapticEffect
 
type
  HapticCondition* = object
    #  Header 
    kind: uint16            #  < ::SDL_HAPTIC_SPRING, ::SDL_HAPTIC_DAMPER,
                            #     ::SDL_HAPTIC_INERTIA or ::SDL_HAPTIC_FRICTION 
    direction: HapticDirection  #  < Direction of the effect - Not used ATM. 

    #  Replay 
    length: uint32          #  < Duration of the effect. 
    delay: uint16           #  < Delay before starting the effect. 

    #  Trigger 
    button: uint16          #  < Button that triggers the effect. 
    interval: uint16        #  < How soon it can be triggered again after button. 

    #  Condition 
    right_sat: array[3, uint16]    #  < Level when joystick is to the positive side. 
    left_sat: array[3, uint16]     #  < Level when joystick is to the negative side. 
    right_coeff: array[3, int16]  #  < How fast to increase the force towards the positive side. 
    left_coeff: array[3, int16]   #  < How fast to increase the force towards the negative side. 
    deadband: array[3, uint16]     #  < Size of the dead zone. 
    center: array[3, int16]       #  < Position of the dead zone. 

#  
#  \brief A structure containing a template for a Ramp effect.
# 
#  This struct is exclusively for the ::SDL_HAPTIC_RAMP effect.
# 
#  The ramp effect starts at start strength and ends at end strength.
#  It augments in linear fashion.  If you use attack and fade with a ramp
#  the effects get added to the ramp effect making the effect become
#  quadratic instead of linear.
# 
#  \sa SDL_HAPTIC_RAMP
#  \sa SDL_HapticEffect
 
type
  HapticRamp* = object
    #  Header 
    kind: uint16            #  < ::SDL_HAPTIC_RAMP 
    direction: HapticDirection  #  < Direction of the effect. 

    #  Replay 
    length: uint32          #  < Duration of the effect. 
    delay: uint16           #  < Delay before starting the effect. 

    #  Trigger 
    button: uint16          #  < Button that triggers the effect. 
    interval: uint16        #  < How soon it can be triggered again after button. 

    #  Ramp 
    start: int16           #  < Beginning strength level. 
    `end`: int16             #  < Ending strength level. 

    #  Envelope 
    attack_length: uint16   #  < Duration of the attack. 
    attack_level: uint16    #  < Level at the start of the attack. 
    fade_length: uint16     #  < Duration of the fade. 
    fade_level: uint16      #  < Level at the end of the fade. 

#  
#  \brief A structure containing a template for a Left/Right effect.
# 
#  This struct is exclusively for the ::SDL_HAPTIC_LEFTRIGHT effect.
# 
#  The Left/Right effect is used to explicitly control the large and small
#  motors, commonly found in modern game controllers. One motor is high
#  frequency, the other is low frequency.
# 
#  \sa SDL_HAPTIC_LEFTRIGHT
#  \sa SDL_HapticEffect
 
type
  HapticLeftRight* = object
    #  Header 
    kind: uint16            #  < ::SDL_HAPTIC_LEFTRIGHT 

    #  Replay 
    length: uint32          #  < Duration of the effect. 

    #  Rumble 
    large_magnitude: uint16 #  < Control of the large controller motor. 
    small_magnitude: uint16 #  < Control of the small controller motor. 

#  
#  \brief A structure containing a template for the ::SDL_HAPTIC_CUSTOM effect.
# 
#  A custom force feedback effect is much like a periodic effect, where the
#  application can define its exact shape.  You will have to allocate the
#  data yourself.  Data should consist of channels#  samples uint16 samples.
# 
#  If channels is one, the effect is rotated using the defined direction.
#  Otherwise it uses the samples in data for the different axes.
# 
#  \sa SDL_HAPTIC_CUSTOM
#  \sa SDL_HapticEffect
 
type
  HapticCustom* = object
    #  Header 
    kind: uint16            #  < ::SDL_HAPTIC_CUSTOM 
    direction: HapticDirection  #  < Direction of the effect. 

    #  Replay 
    length: uint32          #  < Duration of the effect. 
    delay: uint16           #  < Delay before starting the effect. 

    #  Trigger 
    button: uint16          #  < Button that triggers the effect. 
    interval: uint16        #  < How soon it can be triggered again after button. 

    #  Custom 
    channels: uint8         #  < Axes to use, minimum of one. 
    period: uint16          #  < Sample periods. 
    samples: uint16         #  < Amount of samples. 
    data: ptr uint16           #  < Should contain channels*samples items. 

    #  Envelope 
    attack_length: uint16   #  < Duration of the attack. 
    attack_level: uint16    #  < Level at the start of the attack. 
    fade_length: uint16     #  < Duration of the fade. 
    fade_level: uint16      #  < Level at the end of the fade. 

#  
#  \brief The generic template for any haptic effect.
# 
#  All values max at 32767 (0x7FFF).  Signed values also can be negative.
#  Time values unless specified otherwise are in milliseconds.
# 
#  You can also pass ::SDL_HAPTIC_INFINITY to length instead of a 0-32767
#  value.  Neither delay, interval, attack_length nor fade_length support
#  ::SDL_HAPTIC_INFINITY.  Fade will also not be used since effect never ends.
# 
#  Additionally, the ::SDL_HAPTIC_RAMP effect does not support a duration of
#  ::SDL_HAPTIC_INFINITY.
# 
#  Button triggers may not be supported on all devices, it is advised to not
#  use them if possible.  Buttons start at index 1 instead of index 0 like
#  the joystick.
# 
#  If both attack_length and fade_level are 0, the envelope is not used,
#  otherwise both values are used.
# 
#  Common parts:
#  \code
#  // Replay - All effects have this
#  uint32 length;        // Duration of effect (ms).
#  uint16 delay;         // Delay before starting effect.
# 
#  // Trigger - All effects have this
#  uint16 button;        // Button that triggers effect.
#  uint16 interval;      // How soon before effect can be triggered again.
# 
#  // Envelope - All effects except condition effects have this
#  uint16 attack_length; // Duration of the attack (ms).
#  uint16 attack_level;  // Level at the start of the attack.
#  uint16 fade_length;   // Duration of the fade out (ms).
#  uint16 fade_level;    // Level at the end of the fade.
#  \endcode
# 
# 
#  Here we have an example of a constant effect evolution in time:
#  \verbatim
#    Strength
#    ^
#    |
#    |    effect level -->  _________________
#    |                     /                 \
#    |                    /                   \
#    |                   /                     \
#    |                  /                       \
#    | attack_level --> |                        \
#    |                  |                        |  <---  fade_level
#    |
#    +--------------------------------------------------> Time
#                       [--]                 [---]
#                       attack_length        fade_length
#
#    [------------------][-----------------------]
#    delay               length
#    \endverbatim
# 
#  Note either the attack_level or the fade_level may be above the actual
#  effect level.
# 
#  \sa SDL_HapticConstant
#  \sa SDL_HapticPeriodic
#  \sa SDL_HapticCondition
#  \sa SDL_HapticRamp
#  \sa SDL_HapticLeftRight
#  \sa SDL_HapticCustom
 
type
  HapticEffect* = object {.union.}
    #  Common for all force feedback effects 
    kind: uint16                    #  < Effect type. 
    constant: HapticConstant    #  < Constant effect. 
    periodic: HapticPeriodic    #  < Periodic effect. 
    condition: HapticCondition  #  < Condition effect. 
    ramp: HapticRamp            #  < Ramp effect. 
    leftright: HapticLeftRight  #  < Left/Right effect. 
    custom: HapticCustom        #  < Custom effect. 



{.push callconv: cdecl, dynlib: sdl2.LibName.}

#  Function prototypes 
#  
#  \brief Count the number of haptic devices attached to the system.
# 
#  \return Number of haptic devices detected on the system.
 
proc numHaptics*():cint {.importc: "SDL_NumHaptics".}

#  
#  \brief Get the implementation dependent name of a Haptic device.
# 
#  This can be called before any joysticks are opened.
#  If no name can be found, this function returns NULL.
# 
#  \param device_index Index of the device to get its name.
#  \return Name of the device or NULL on error.
# 
#  \sa SDL_NumHaptics
 
proc hapticName*(device_index: cint):cstring {.importc: "SDL_HapticName".}

#  
#  \brief Opens a Haptic device for usage.
# 
#  The index passed as an argument refers to the N'th Haptic device on this
#  system.
# 
#  When opening a haptic device, its gain will be set to maximum and
#  autocenter will be disabled.  To modify these values use
#  SDL_HapticSetGain() and SDL_HapticSetAutocenter().
# 
#  \param device_index Index of the device to open.
#  \return Device identifier or NULL on error.
# 
#  \sa SDL_HapticIndex
#  \sa SDL_HapticOpenFromMouse
#  \sa SDL_HapticOpenFromJoystick
#  \sa SDL_HapticClose
#  \sa SDL_HapticSetGain
#  \sa SDL_HapticSetAutocenter
#  \sa SDL_HapticPause
#  \sa SDL_HapticStopAll
 
proc hapticOpen*(device_index: cint):HapticPtr {.importc: "SDL_HapticOpen".}

#  
#  \brief Checks if the haptic device at index has been opened.
# 
#  \param device_index Index to check to see if it has been opened.
#  \return 1 if it has been opened or 0 if it hasn't.
# 
#  \sa SDL_HapticOpen
#  \sa SDL_HapticIndex
 
proc hapticOpened*(device_index: cint):cint {.importc: "SDL_HapticOpened".}

#  
#  \brief Gets the index of a haptic device.
# 
#  \param haptic Haptic device to get the index of.
#  \return The index of the haptic device or -1 on error.
# 
#  \sa SDL_HapticOpen
#  \sa SDL_HapticOpened
 
proc index*(haptic: HapticPtr):cint {.importc: "SDL_HapticIndex".}

#  
#  \brief Gets whether or not the current mouse has haptic capabilities.
# 
#  \return SDL_TRUE if the mouse is haptic, SDL_FALSE if it isn't.
# 
#  \sa SDL_HapticOpenFromMouse
 
proc mouseIsHaptic*():cint {.importc: "SDL_MouseIsHaptic".}

#  
#  \brief Tries to open a haptic device from the current mouse.
# 
#  \return The haptic device identifier or NULL on error.
# 
#  \sa SDL_MouseIsHaptic
#  \sa SDL_HapticOpen
 
proc hapticOpenFromMouse*():HapticPtr {.importc: "SDL_HapticOpenFromMouse".}

#  
#  \brief Checks to see if a joystick has haptic features.
# 
#  \param joystick Joystick to test for haptic capabilities.
#  \return 1 if the joystick is haptic, 0 if it isn't
#          or -1 if an error ocurred.
# 
#  \sa SDL_HapticOpenFromJoystick
 
proc joystickIsHaptic*(joystick: Joystick):cint {.importc: "SDL_JoystickIsHaptic".}

#  
#  \brief Opens a Haptic device for usage from a Joystick device.
# 
#  You must still close the haptic device seperately.  It will not be closed
#  with the joystick.
# 
#  When opening from a joystick you should first close the haptic device before
#  closing the joystick device.  If not, on some implementations the haptic
#  device will also get unallocated and you'll be unable to use force feedback
#  on that device.
# 
#  \param joystick Joystick to create a haptic device from.
#  \return A valid haptic device identifier on success or NULL on error.
# 
#  \sa SDL_HapticOpen
#  \sa SDL_HapticClose
 
proc hapticOpenFromJoystick*(joystick: JoystickPtr):HapticPtr {.importc: "SDL_HapticOpenFromJoystick".}

#  
#  \brief Closes a Haptic device previously opened with SDL_HapticOpen().
# 
#  \param haptic Haptic device to close.
 
proc close*(haptic: HapticPtr) {.importc: "SDL_HapticClose".}

#  
#  \brief Returns the number of effects a haptic device can store.
# 
#  On some platforms this isn't fully supported, and therefore is an
#  approximation.  Always check to see if your created effect was actually
#  created and do not rely solely on SDL_HapticNumEffects().
# 
#  \param haptic The haptic device to query effect max.
#  \return The number of effects the haptic device can store or
#          -1 on error.
# 
#  \sa SDL_HapticNumEffectsPlaying
#  \sa SDL_HapticQuery
 
proc numEffects*(haptic: HapticPtr):cint {.importc: "SDL_HapticNumEffects".}

#  
#  \brief Returns the number of effects a haptic device can play at the same
#         time.
# 
#  This is not supported on all platforms, but will always return a value.
#  Added here for the sake of completeness.
# 
#  \param haptic The haptic device to query maximum playing effects.
#  \return The number of effects the haptic device can play at the same time
#          or -1 on error.
# 
#  \sa SDL_HapticNumEffects
#  \sa SDL_HapticQuery
 
proc numEffectsPlaying*(haptic: HapticPtr):cint {.importc: "SDL_HapticNumEffectsPlaying".}

#  
#  \brief Gets the haptic devices supported features in bitwise matter.
# 
#  Example:
#  \code
#  if (SDL_HapticQuery(haptic) & SDL_HAPTIC_CONSTANT) {
#      printf("We have constant haptic effect!");
#  }
#  \endcode
# 
#  \param haptic The haptic device to query.
#  \return Haptic features in bitwise manner (OR'd).
# 
#  \sa SDL_HapticNumEffects
#  \sa SDL_HapticEffectSupported
 
proc query*(haptic: HapticPt):uint {.importc: "SDL_HapticQuery".}


#  
#  \brief Gets the number of haptic axes the device has.
# 
#  \sa HapticDirection
 
proc numAxes*(haptic: HapticPt):cint {.importc: "SDL_HapticNumAxes".}

#  
#  \brief Checks to see if effect is supported by haptic.
# 
#  \param haptic Haptic device to check on.
#  \param effect Effect to check to see if it is supported.
#  \return SDL_TRUE if effect is supported, SDL_FALSE if it isn't or -1 on error.
# 
#  \sa SDL_HapticQuery
#  \sa SDL_HapticNewEffect
 
proc effectSupported*(haptic: HapticPt, effect: ptr HapticEffect):cint {.importc: "SDL_HapticEffectSupported".}

#  
#  \brief Creates a new haptic effect on the device.
# 
#  \param haptic Haptic device to create the effect on.
#  \param effect Properties of the effect to create.
#  \return The id of the effect on success or -1 on error.
# 
#  \sa SDL_HapticUpdateEffect
#  \sa SDL_HapticRunEffect
#  \sa SDL_HapticDestroyEffect
 
proc newEffect*(haptic: HapticPt, effect: ptr HapticEffect):cint {.importc: "SDL_HapticNewEffect".}

#  
#  \brief Updates the properties of an effect.
# 
#  Can be used dynamically, although behaviour when dynamically changing
#  direction may be strange.  Specifically the effect may reupload itself
#  and start playing from the start.  You cannot change the type either when
#  running SDL_HapticUpdateEffect().
# 
#  \param haptic Haptic device that has the effect.
#  \param effect Effect to update.
#  \param data New effect properties to use.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticNewEffect
#  \sa SDL_HapticRunEffect
#  \sa SDL_HapticDestroyEffect
 
proc updateEffect*(haptic: HapticPt, effect: cint, data: ptr HapticEffect):cint {.importc: "SDL_HapticUpdateEffect".}

#  
#  \brief Runs the haptic effect on its associated haptic device.
# 
#  If iterations are ::SDL_HAPTIC_INFINITY, it'll run the effect over and over
#  repeating the envelope (attack and fade) every time.  If you only want the
#  effect to last forever, set ::SDL_HAPTIC_INFINITY in the effect's length
#  parameter.
# 
#  \param haptic Haptic device to run the effect on.
#  \param effect Identifier of the haptic effect to run.
#  \param iterations Number of iterations to run the effect. Use
#         ::SDL_HAPTIC_INFINITY for infinity.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticStopEffect
#  \sa SDL_HapticDestroyEffect
#  \sa SDL_HapticGetEffectStatus
 
proc runEffect*(haptic: HapticPt, effect: cint, iterations: uint32):cint {.importc: "SDL_HapticRunEffect".}

#  
#  \brief Stops the haptic effect on its associated haptic device.
# 
#  \param haptic Haptic device to stop the effect on.
#  \param effect Identifier of the effect to stop.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticRunEffect
#  \sa SDL_HapticDestroyEffect
 
proc stopEffect*(haptic: HapticPt, effect: cint):cint {.importc: "SDL_HapticStopEffect".}

#  
#  \brief Destroys a haptic effect on the device.
# 
#  This will stop the effect if it's running.  Effects are automatically
#  destroyed when the device is closed.
# 
#  \param haptic Device to destroy the effect on.
#  \param effect Identifier of the effect to destroy.
# 
#  \sa SDL_HapticNewEffect
 
proc destroyEffect*(haptic: HapticPt, effect: cint) {.importc: "SDL_HapticDestroyEffect".}

#  
#  \brief Gets the status of the current effect on the haptic device.
# 
#  Device must support the ::SDL_HAPTIC_STATUS feature.
# 
#  \param haptic Haptic device to query the effect status on.
#  \param effect Identifier of the effect to query its status.
#  \return 0 if it isn't playing, 1 if it is playing or -1 on error.
# 
#  \sa SDL_HapticRunEffect
#  \sa SDL_HapticStopEffect
 
proc getEffectStatus*(haptic: HapticPt, effect: cint):cint {.importc: "SDL_HapticGetEffectStatus".}

#  
#  \brief Sets the global gain of the device.
# 
#  Device must support the ::SDL_HAPTIC_GAIN feature.
# 
#  The user may specify the maximum gain by setting the environment variable
#  SDL_HAPTIC_GAIN_MAX which should be between 0 and 100.  All calls to
#  SDL_HapticSetGain() will scale linearly using SDL_HAPTIC_GAIN_MAX as the
#  maximum.
# 
#  \param haptic Haptic device to set the gain on.
#  \param gain Value to set the gain to, should be between 0 and 100.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticQuery
 
proc setGain*(haptic: HapticPt, gain: int ):cint {.importc: "SDL_HapticSetGain".}

#  
#  \brief Sets the global autocenter of the device.
# 
#  Autocenter should be between 0 and 100.  Setting it to 0 will disable
#  autocentering.
# 
#  Device must support the ::SDL_HAPTIC_AUTOCENTER feature.
# 
#  \param haptic Haptic device to set autocentering on.
#  \param autocenter Value to set autocenter to, 0 disables autocentering.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticQuery
 
proc setAutocenter*(haptic: HapticPt, autocenter: int ):cint {.importc: "SDL_HapticSetAutocenter".}

#  
#  \brief Pauses a haptic device.
# 
#  Device must support the ::SDL_HAPTIC_PAUSE feature.  Call
#  SDL_HapticUnpause() to resume playback.
# 
#  Do not modify the effects nor add new ones while the device is paused.
#  That can cause all sorts of weird errors.
# 
#  \param haptic Haptic device to pause.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticUnpause
 
proc pause*(haptic: HapticPt):cint {.importc: "SDL_HapticPause".}

#  
#  \brief Unpauses a haptic device.
# 
#  Call to unpause after SDL_HapticPause().
# 
#  \param haptic Haptic device to pause.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticPause
 
proc unpause*(haptic: HapticPt):cint {.importc: "SDL_HapticUnpause".}

#  
#  \brief Stops all the currently playing effects on a haptic device.
# 
#  \param haptic Haptic device to stop.
#  \return 0 on success or -1 on error.
 
proc stopAll*(haptic: HapticPt):cint {.importc: "SDL_HapticStopAll".}

#  
#  \brief Checks to see if rumble is supported on a haptic device.
# 
#  \param haptic Haptic device to check to see if it supports rumble.
#  \return SDL_TRUE if effect is supported, SDL_FALSE if it isn't or -1 on error.
# 
#  \sa SDL_HapticRumbleInit
#  \sa SDL_HapticRumblePlay
#  \sa SDL_HapticRumbleStop
 
proc rumbleSupported*(haptic: HapticPt):cint {.importc: "SDL_HapticRumbleSupported".}

#  
#  \brief Initializes the haptic device for simple rumble playback.
# 
#  \param haptic Haptic device to initialize for simple rumble playback.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticOpen
#  \sa SDL_HapticRumbleSupported
#  \sa SDL_HapticRumblePlay
#  \sa SDL_HapticRumbleStop
 
proc rumbleInit*(haptic: HapticPt):cint {.importc: "SDL_HapticRumbleInit".}

#  
#  \brief Runs simple rumble on a haptic device
# 
#  \param haptic Haptic device to play rumble effect on.
#  \param strength Strength of the rumble to play as a 0-1 float value.
#  \param length Length of the rumble to play in milliseconds.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticRumbleSupported
#  \sa SDL_HapticRumbleInit
#  \sa SDL_HapticRumbleStop
 
proc rumblePlay*(haptic: HapticPt, strength: float, length: uint32 ):cint {.importc: "SDL_HapticRumblePlay".}

#  
#  \brief Stops the simple rumble on a haptic device.
# 
#  \param haptic Haptic to stop the rumble on.
#  \return 0 on success or -1 on error.
# 
#  \sa SDL_HapticRumbleSupported
#  \sa SDL_HapticRumbleInit
#  \sa SDL_HapticRumblePlay
 
proc rumbleStop*(haptic: HapticPt):cint {.importc: "SDL_HapticRumbleStop".}

{.pop.}
