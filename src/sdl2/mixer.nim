#
#  SDL_mixer:  An audio mixer library based on the SDL library
#  Copyright (C) 1997-2013 Sam Lantinga <slouken@libsdl.org>
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

{.deadCodeElim: on.}
# Dynamically link to the correct library for our system:

when not defined(SDL_Static):
  when defined(windows):
    const LibName* = "SDL2_mixer.dll"
  elif defined(macosx):
    const LibName* = "libSDL2_mixer.dylib"
  else:
    const LibName* = "libSDL2_mixer(|-2.0).so(|.0)"

when defined(SDL_Static):
  {.push header: "<SDL2/SDL_mixer.h>".}
else:
  {.push callConv:cdecl, dynlib: LibName.}

import sdl2, sdl2.audio

when false:
  when SDL_BYTEORDER == SDL_LIL_ENDIAN:
    const
      MIX_DEFAULT_FORMAT = AUDIO_S16LSB
  else:
    const
      MIX_DEFAULT_FORMAT = AUDIO_S16MSB

# Remove prefixes in our wrapper, we have modules in Nim:

# These are not recognized by c2nim, but that's easy to fix:

# This function gets the version of the dynamically linked SDL_mixer library.
#   it should NOT be used to fill a version structure, instead you should
#   use the SDL_MIXER_VERSION() macro.
#

proc linkedVersion*(): ptr SDL_version {.importc: "Mix_Linked_Version".}

const
    MIX_INIT_FLAC*       : cint = 0x00000001
    MIX_INIT_MOD*        : cint = 0x00000002
    MIX_INIT_MODPLUG*    : cint = 0x00000004
    MIX_INIT_MP3*        : cint = 0x00000008
    MIX_INIT_OGG*        : cint = 0x00000010 
    MIX_INIT_FLUIDSYNTH* : cint = 0x00000020


# Loads dynamic libraries and prepares them for use.  Flags should be
#   one or more flags from MIX_InitFlags OR'd together.
#   It returns the flags successfully initialized, or 0 on failure.
#

proc init*(flags: cint): cint {.importc: "Mix_Init".}
# Unloads libraries loaded with Mix_Init

proc quit*() {.importc: "Mix_Quit".}
# The default mixer has 8 simultaneous mixing channels

const
  MIX_CHANNELS* = 8

# Good default values for a PC soundcard

const
  MIX_DEFAULT_FREQUENCY* = 22050
  MIX_DEFAULT_CHANNELS* = 2

# Volume of a chunk

const
  MIX_MAX_VOLUME* = 128

# The internal format for an audio chunk

type
  ChunkPtr* = ptr Chunk
  Chunk* = object
    allocated*: cint
    abuf*: ptr uint8
    alen*: uint32
    volume*: uint8            # Per-sample volume, 0-128


# The different fading types supported

type
  Fading* {.size: sizeof(cint).} = enum
    MIX_NO_FADING, MIX_FADING_OUT, MIX_FADING_IN
  MusicType* {.size: sizeof(cint).} = enum
    MUS_NONE, MUS_CMD, MUS_WAV, MUS_MOD, MUS_MID, MUS_OGG, MUS_MP3, MUS_MP3_MAD,
    MUS_FLAC, MUS_MODPLUG



# The internal format for a music chunk interpreted via mikmod

type
  MusicPtr* = ptr Music
  Music* = object


# Open the mixer with a certain audio format

proc openAudio*(frequency: cint; format: uint16; channels: cint;
                    chunksize: cint): cint {.importc: "Mix_OpenAudio".}
# Dynamically change the number of channels managed by the mixer.
#   If decreasing the number of channels, the upper channels are
#   stopped.
#   This function returns the new number of allocated channels.
#

proc allocateChannels*(numchans: cint): cint {.
    importc: "Mix_AllocateChannels".}
# Find out what the actual audio device parameters are.
#   This function returns 1 if the audio has been opened, 0 otherwise.
#

proc querySpec*(frequency: ptr cint; format: ptr uint16; channels: ptr cint): cint {.
    importc: "Mix_QuerySpec".}
# Load a wave file or a music (.mod .s3m .it .xm) file

proc loadWAV_RW*(src: RWopsPtr; freesrc: cint): ptr Chunk {.importc: "Mix_LoadWAV_RW".}

template loadWAV*(file: expr): expr =
  loadWAV_RW(rwFromFile(file, "rb"), 1)

proc loadMUS*(file: cstring): ptr Music {.importc: "Mix_LoadMUS".}
# Load a music file from an SDL_RWop object (Ogg and MikMod specific currently)
#   Matt Campbell (matt@campbellhome.dhs.org) April 2000

proc loadMUS_RW*(src: ptr RWopsPtr; freesrc: cint): ptr Music {.
    importc: "Mix_LoadMUS_RW".}
# Load a music file from an SDL_RWop object assuming a specific format

proc loadMUSType_RW*(src: ptr RWopsPtr; `type`: MusicType; freesrc: cint): ptr Music {.
    importc: "Mix_LoadMUSType_RW".}
# Load a wave file of the mixer format from a memory buffer

proc quickLoad_WAV*(mem: ptr uint8): ptr Chunk {.importc: "Mix_QuickLoad_WAV".}
# Load raw audio data of the mixer format from a memory buffer

proc quickLoad_RAW*(mem: ptr uint8; len: uint32): ptr Chunk {.importc: "Mix_QuickLoad_RAW".}
# Free an audio chunk previously loaded

proc freeChunk*(chunk: ptr Chunk) {.importc: "Mix_FreeChunk".}
proc freeMusic*(music: ptr Music) {.importc: "Mix_FreeMusic".}
# Get a list of chunk/music decoders that this build of SDL_mixer provides.
#   This list can change between builds AND runs of the program, if external
#   libraries that add functionality become available.
#   You must successfully call Mix_OpenAudio() before calling these functions.
#   This API is only available in SDL_mixer 1.2.9 and later.
#
#   // usage...
#   int i;
#   const int total = Mix_GetNumChunkDecoders();
#   for (i = 0; i < total; i++)
#       printf("Supported chunk decoder: [%s]\n", Mix_GetChunkDecoder(i));
#
#   Appearing in this list doesn't promise your specific audio file will
#   decode...but it's handy to know if you have, say, a functioning Timidity
#   install.
#
#   These return values are static, read-only data; do not modify or free it.
#   The pointers remain valid until you call Mix_CloseAudio().
#

proc getNumChunkDecoders*(): cint {.importc: "Mix_GetNumChunkDecoders".}
proc getChunkDecoder*(index: cint): cstring {.importc: "Mix_GetChunkDecoder".}
proc getNumMusicDecoders*(): cint {.importc: "Mix_GetNumMusicDecoders".}
proc getMusicDecoder*(index: cint): cstring {.importc: "Mix_GetMusicDecoder".}
# Find out the music format of a mixer music, or the currently playing
#   music, if 'music' is NULL.
#

proc getMusicType*(music: ptr Music): MusicType {.importc: "Mix_GetMusicType".}
# Set a function that is called after all mixing is performed.
#   This can be used to provide real-time visual display of the audio stream
#   or add a custom mixer filter for the stream data.
#

proc setPostMix*(mix_func: proc (udata: pointer; stream: ptr uint8;
                                     len: cint) {.cdecl.}; arg: pointer) {.importc: "Mix_SetPostMix".}
# Add your own music player or additional mixer function.
#   If 'mix_func' is NULL, the default music player is re-enabled.
#

proc hookMusic*(mix_func: proc (udata: pointer; stream: ptr uint8; len: cint) {.
    cdecl.}; arg: pointer) {.importc: "Mix_HookMusic".}
# Add your own callback when the music has finished playing.
#   This callback is only called if the music finishes naturally.
#

proc hookMusicFinished*(music_finished: proc () {.cdecl.}) {.importc: "Mix_HookMusicFinished".}
# Get a pointer to the user data for the current music hook

proc getMusicHookData*(): pointer {.importc: "Mix_GetMusicHookData".}
#
#  Add your own callback when a channel has finished playing. NULL
#   to disable callback. The callback may be called from the mixer's audio
#   callback or it could be called as a result of Mix_HaltChannel(), etc.
#   do not call SDL_LockAudio() from this callback; you will either be
#   inside the audio callback, or SDL_mixer will explicitly lock the audio
#   before calling your callback.
#

proc channelFinished*(channel_finished: proc (channel: cint) {.cdecl.}) {.importc: "Mix_ChannelFinished".}
# Special Effects API by ryan c. gordon. (icculus@icculus.org)

const
  MIX_CHANNEL_POST* = - 2

# This is the format of a special effect callback:
#
#    myeffect(int chan, void *stream, int len, void *udata);
#
#  (chan) is the channel number that your effect is affecting. (stream) is
#   the buffer of data to work upon. (len) is the size of (stream), and
#   (udata) is a user-defined bit of data, which you pass as the last arg of
#   Mix_RegisterEffect(), and is passed back unmolested to your callback.
#   Your effect changes the contents of (stream) based on whatever parameters
#   are significant, or just leaves it be, if you prefer. You can do whatever
#   you like to the buffer, though, and it will continue in its changed state
#   down the mixing pipeline, through any other effect functions, then finally
#   to be mixed with the rest of the channels and music for the final output
#   stream.
#
#  DO NOT EVER call SDL_LockAudio() from your callback function!
#

type
  Mix_EffectFunc_t* = proc (chan: cint; stream: pointer; len: cint;
                            udata: pointer) {.cdecl.}

#
#  This is a callback that signifies that a channel has finished all its
#   loops and has completed playback. This gets called if the buffer
#   plays out normally, or if you call Mix_HaltChannel(), implicitly stop
#   a channel via Mix_AllocateChannels(), or unregister a callback while
#   it's still playing.
#
#  DO NOT EVER call SDL_LockAudio() from your callback function!
#

type
  Mix_EffectDone_t* = proc (chan: cint; udata: pointer) {.cdecl.}

# Register a special effect function. At mixing time, the channel data is
#   copied into a buffer and passed through each registered effect function.
#   After it passes through all the functions, it is mixed into the final
#   output stream. The copy to buffer is performed once, then each effect
#   function performs on the output of the previous effect. Understand that
#   this extra copy to a buffer is not performed if there are no effects
#   registered for a given chunk, which saves CPU cycles, and any given
#   effect will be extra cycles, too, so it is crucial that your code run
#   fast. Also note that the data that your function is given is in the
#   format of the sound device, and not the format you gave to Mix_OpenAudio(),
#   although they may in reality be the same. This is an unfortunate but
#   necessary speed concern. Use Mix_QuerySpec() to determine if you can
#   handle the data before you register your effect, and take appropriate
#   actions.
#  You may also specify a callback (Mix_EffectDone_t) that is called when
#   the channel finishes playing. This gives you a more fine-grained control
#   than Mix_ChannelFinished(), in case you need to free effect-specific
#   resources, etc. If you don't need this, you can specify NULL.
#  You may set the callbacks before or after calling Mix_PlayChannel().
#  Things like Mix_SetPanning() are just internal special effect functions,
#   so if you are using that, you've already incurred the overhead of a copy
#   to a separate buffer, and that these effects will be in the queue with
#   any functions you've registered. The list of registered effects for a
#   channel is reset when a chunk finishes playing, so you need to explicitly
#   set them with each call to Mix_PlayChannel*().
#  You may also register a special effect function that is to be run after
#   final mixing occurs. The rules for these callbacks are identical to those
#   in Mix_RegisterEffect, but they are run after all the channels and the
#   music have been mixed into a single stream, whereas channel-specific
#   effects run on a given channel before any other mixing occurs. These
#   global effect callbacks are call "posteffects". Posteffects only have
#   their Mix_EffectDone_t function called when they are unregistered (since
#   the main output stream is never "done" in the same sense as a channel).
#   You must unregister them manually when you've had enough. Your callback
#   will be told that the channel being mixed is (MIX_CHANNEL_POST) if the
#   processing is considered a posteffect.
#
#  After all these effects have finished processing, the callback registered
#   through Mix_SetPostMix() runs, and then the stream goes to the audio
#   device.
#
#  DO NOT EVER call SDL_LockAudio() from your callback function!
#
#  returns zero if error (no such channel), nonzero if added.
#   Error messages can be retrieved from Mix_GetError().
#

proc registerEffect*(chan: cint; f: Mix_EffectFunc_t; d: Mix_EffectDone_t;
                         arg: pointer): cint {.importc: "Mix_RegisterEffect".}
# You may not need to call this explicitly, unless you need to stop an
#   effect from processing in the middle of a chunk's playback.
#  Posteffects are never implicitly unregistered as they are for channels,
#   but they may be explicitly unregistered through this function by
#   specifying MIX_CHANNEL_POST for a channel.
#  returns zero if error (no such channel or effect), nonzero if removed.
#   Error messages can be retrieved from Mix_GetError().
#

proc unregisterEffect*(channel: cint; f: Mix_EffectFunc_t): cint {.importc: "Mix_UnregisterEffect".}
# You may not need to call this explicitly, unless you need to stop all
#   effects from processing in the middle of a chunk's playback. Note that
#   this will also shut off some internal effect processing, since
#   Mix_SetPanning() and others may use this API under the hood. This is
#   called internally when a channel completes playback.
#  Posteffects are never implicitly unregistered as they are for channels,
#   but they may be explicitly unregistered through this function by
#   specifying MIX_CHANNEL_POST for a channel.
#  returns zero if error (no such channel), nonzero if all effects removed.
#   Error messages can be retrieved from Mix_GetError().
#

proc unregisterAllEffects*(channel: cint): cint {.importc: "Mix_UnregisterAllEffects".}

const
  MIX_EFFECTSMAXSPEED* = "MIX_EFFECTSMAXSPEED"

#
#  These are the internally-defined mixing effects. They use the same API that
#   effects defined in the application use, but are provided here as a
#   convenience. Some effects can reduce their quality or use more memory in
#   the name of speed; to enable this, make sure the environment variable
#   MIX_EFFECTSMAXSPEED (see above) is defined before you call
#   Mix_OpenAudio().
#
# Set the panning of a channel. The left and right channels are specified
#   as integers between 0 and 255, quietest to loudest, respectively.
#
#  Technically, this is just individual volume control for a sample with
#   two (stereo) channels, so it can be used for more than just panning.
#   If you want real panning, call it like this:
#
#    Mix_SetPanning(channel, left, 255 - left);
#
#  ...which isn't so hard.
#
#  Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
#   the panning will be done to the final mixed stream before passing it on
#   to the audio device.
#
#  This uses the Mix_RegisterEffect() API internally, and returns without
#   registering the effect function if the audio device is not configured
#   for stereo output. Setting both (left) and (right) to 255 causes this
#   effect to be unregistered, since that is the data's normal state.
#
#  returns zero if error (no such channel or Mix_RegisterEffect() fails),
#   nonzero if panning effect enabled. Note that an audio device in mono
#   mode is a no-op, but this call will return successful in that case.
#   Error messages can be retrieved from Mix_GetError().
#

proc setPanning*(channel: cint; left: uint8; right: uint8): cint {.importc: "Mix_SetPanning".}
# Set the position of a channel. (angle) is an integer from 0 to 360, that
#   specifies the location of the sound in relation to the listener. (angle)
#   will be reduced as neccesary (540 becomes 180 degrees, -100 becomes 260).
#   Angle 0 is due north, and rotates clockwise as the value increases.
#   For efficiency, the precision of this effect may be limited (angles 1
#   through 7 might all produce the same effect, 8 through 15 are equal, etc).
#   (distance) is an integer between 0 and 255 that specifies the space
#   between the sound and the listener. The larger the number, the further
#   away the sound is. Using 255 does not guarantee that the channel will be
#   culled from the mixing process or be completely silent. For efficiency,
#   the precision of this effect may be limited (distance 0 through 5 might
#   all produce the same effect, 6 through 10 are equal, etc). Setting (angle)
#   and (distance) to 0 unregisters this effect, since the data would be
#   unchanged.
#
#  If you need more precise positional audio, consider using OpenAL for
#   spatialized effects instead of SDL_mixer. This is only meant to be a
#   basic effect for simple "3D" games.
#
#  If the audio device is configured for mono output, then you won't get
#   any effectiveness from the angle; however, distance attenuation on the
#   channel will still occur. While this effect will function with stereo
#   voices, it makes more sense to use voices with only one channel of sound,
#   so when they are mixed through this effect, the positioning will sound
#   correct. You can convert them to mono through SDL before giving them to
#   the mixer in the first place if you like.
#
#  Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
#   the positioning will be done to the final mixed stream before passing it
#   on to the audio device.
#
#  This is a convenience wrapper over Mix_SetDistance() and Mix_SetPanning().
#
#  returns zero if error (no such channel or Mix_RegisterEffect() fails),
#   nonzero if position effect is enabled.
#   Error messages can be retrieved from Mix_GetError().
#

proc setPosition*(channel: cint; angle: int16; distance: uint8): cint {.importc: "Mix_SetPosition".}
# Set the "distance" of a channel. (distance) is an integer from 0 to 255
#   that specifies the location of the sound in relation to the listener.
#   Distance 0 is overlapping the listener, and 255 is as far away as possible
#   A distance of 255 does not guarantee silence; in such a case, you might
#   want to try changing the chunk's volume, or just cull the sample from the
#   mixing process with Mix_HaltChannel().
#  For efficiency, the precision of this effect may be limited (distances 1
#   through 7 might all produce the same effect, 8 through 15 are equal, etc).
#   (distance) is an integer between 0 and 255 that specifies the space
#   between the sound and the listener. The larger the number, the further
#   away the sound is.
#  Setting (distance) to 0 unregisters this effect, since the data would be
#   unchanged.
#  If you need more precise positional audio, consider using OpenAL for
#   spatialized effects instead of SDL_mixer. This is only meant to be a
#   basic effect for simple "3D" games.
#
#  Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
#   the distance attenuation will be done to the final mixed stream before
#   passing it on to the audio device.
#
#  This uses the Mix_RegisterEffect() API internally.
#
#  returns zero if error (no such channel or Mix_RegisterEffect() fails),
#   nonzero if position effect is enabled.
#   Error messages can be retrieved from Mix_GetError().
#

proc setDistance*(channel: cint; distance: uint8): cint {.importc: "Mix_SetDistance".}
#
#  !!! FIXME : Haven't implemented, since the effect goes past the
#               end of the sound buffer. Will have to think about this.
#                --ryan.
#

when 0:
  # Causes an echo effect to be mixed into a sound. (echo) is the amount
  #   of echo to mix. 0 is no echo, 255 is infinite (and probably not
  #   what you want).
  #
  #  Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
  #   the reverbing will be done to the final mixed stream before passing it on
  #   to the audio device.
  #
  #  This uses the Mix_RegisterEffect() API internally. If you specify an echo
  #   of zero, the effect is unregistered, as the data is already in that state.
  #
  #  returns zero if error (no such channel or Mix_RegisterEffect() fails),
  #   nonzero if reversing effect is enabled.
  #   Error messages can be retrieved from Mix_GetError().
  #
  proc setReverb*(channel: cint; echo: uint8): cint {.importc: "Mix_SetReverb".}
# Causes a channel to reverse its stereo. This is handy if the user has his
#   speakers hooked up backwards, or you would like to have a minor bit of
#   psychedelia in your sound code.  :)  Calling this function with (flip)
#   set to non-zero reverses the chunks's usual channels. If (flip) is zero,
#   the effect is unregistered.
#
#  This uses the Mix_RegisterEffect() API internally, and thus is probably
#   more CPU intensive than having the user just plug in his speakers
#   correctly. Mix_SetReverseStereo() returns without registering the effect
#   function if the audio device is not configured for stereo output.
#
#  If you specify MIX_CHANNEL_POST for (channel), then this the effect is used
#   on the final mixed stream before sending it on to the audio device (a
#   posteffect).
#
#  returns zero if error (no such channel or Mix_RegisterEffect() fails),
#   nonzero if reversing effect is enabled. Note that an audio device in mono
#   mode is a no-op, but this call will return successful in that case.
#   Error messages can be retrieved from Mix_GetError().
#

proc setReverseStereo*(channel: cint; flip: cint): cint {.importc: "Mix_SetReverseStereo".}
# end of effects API. --ryan.
# Reserve the first channels (0 -> n-1) for the application, i.e. don't allocate
#   them dynamically to the next sample if requested with a -1 value below.
#   Returns the number of reserved channels.
#

proc reserveChannels*(num: cint): cint {.importc: "Mix_ReserveChannels".}
# Channel grouping functions
# Attach a tag to a channel. A tag can be assigned to several mixer
#   channels, to form groups of channels.
#   If 'tag' is -1, the tag is removed (actually -1 is the tag used to
#   represent the group of all the channels).
#   Returns true if everything was OK.
#

proc groupChannel*(which: cint; tag: cint): cint {.importc: "Mix_GroupChannel".}
# Assign several consecutive channels to a group

proc groupChannels*(`from`: cint; to: cint; tag: cint): cint {.importc: "Mix_GroupChannels".}
# Finds the first available channel in a group of channels,
#   returning -1 if none are available.
#

proc groupAvailable*(tag: cint): cint {.importc: "Mix_GroupAvailable".}
# Returns the number of channels in a group. This is also a subtle
#   way to get the total number of channels when 'tag' is -1
#

proc groupCount*(tag: cint): cint {.importc: "Mix_GroupCount".}
# Finds the "oldest" sample playing in a group of channels

proc groupOldest*(tag: cint): cint {.importc: "Mix_GroupOldest".}
# Finds the "most recent" (i.e. last) sample playing in a group of channels

proc groupNewer*(tag: cint): cint {.importc: "Mix_GroupNewer".}
# Play an audio chunk on a specific channel.
#   If the specified channel is -1, play on the first free channel.
#   If 'loops' is greater than zero, loop the sound that many times.
#   If 'loops' is -1, loop inifinitely (~65000 times).
#   The sound is played at most 'ticks' milliseconds. If -1, play forever.
#   Returns which channel was used to play the sound.
#

proc playChannelTimed*(channel: cint; chunk: ptr Chunk; loops: cint;
                           ticks: cint): cint {.importc: "Mix_PlayChannelTimed".}

# The same as above, but the sound is played forever

template playChannel*(channel, chunk, loops: expr): expr =
  playChannelTimed(channel, chunk, loops, - 1)

proc playMusic*(music: ptr Music; loops: cint): cint {.importc: "Mix_PlayMusic".}
# Fade in music or a channel over "ms" milliseconds, same semantics as the "Play" functions

proc fadeInMusic*(music: ptr Music; loops: cint; ms: cint): cint {.importc: "Mix_FadeInMusic".}
proc fadeInMusicPos*(music: ptr Music; loops: cint; ms: cint;
                         position: cdouble): cint {.importc: "Mix_FadeInMusicPos".}
template fadeInChannel*(channel, chunk, loops, ms: expr): expr =
  fadeInChannelTimed(channel, chunk, loops, ms, - 1)

proc fadeInChannelTimed*(channel: cint; chunk: ptr Chunk; loops: cint;
                             ms: cint; ticks: cint): cint {.importc: "Mix_FadeInChannelTimed".}
# Set the volume in the range of 0-128 of a specific channel or chunk.
#   If the specified channel is -1, set volume for all channels.
#   Returns the original volume.
#   If the specified volume is -1, just return the current volume.
#

proc volume*(channel: cint; volume: cint): cint {.importc: "Mix_Volume".}
proc volumeChunk*(chunk: ptr Chunk; volume: cint): cint {.importc: "Mix_VolumeChunk".}
proc volumeMusic*(volume: cint): cint {.importc: "Mix_VolumeMusic".}
# Halt playing of a particular channel

proc haltChannel*(channel: cint): cint {.importc: "Mix_HaltChannel".}
proc haltGroup*(tag: cint): cint {.importc: "Mix_HaltGroup".}
proc haltMusic*(): cint {.importc: "Mix_HaltMusic".}
# Change the expiration delay for a particular channel.
#   The sample will stop playing after the 'ticks' milliseconds have elapsed,
#   or remove the expiration if 'ticks' is -1
#

proc expireChannel*(channel: cint; ticks: cint): cint {.importc: "Mix_ExpireChannel".}
# Halt a channel, fading it out progressively till it's silent
#   The ms parameter indicates the number of milliseconds the fading
#   will take.
#

proc fadeOutChannel*(which: cint; ms: cint): cint {.importc: "Mix_FadeOutChannel".}
proc fadeOutGroup*(tag: cint; ms: cint): cint {.importc: "Mix_FadeOutGroup".}
proc fadeOutMusic*(ms: cint): cint {.importc: "Mix_FadeOutMusic".}
# Query the fading status of a channel

proc fadingMusic*(): Fading {.importc: "Mix_FadingMusic".}
proc fadingChannel*(which: cint): Fading {.importc: "Mix_FadingChannel".}
# Pause/Resume a particular channel

proc pause*(channel: cint) {.importc: "Mix_Pause".}
proc resume*(channel: cint) {.importc: "Mix_Resume".}
proc paused*(channel: cint): cint {.importc: "Mix_Paused".}
# Pause/Resume the music stream

proc pauseMusic*() {.importc: "Mix_PauseMusic".}
proc resumeMusic*() {.importc: "Mix_ResumeMusic".}
proc rewindMusic*() {.importc: "Mix_RewindMusic".}
proc pausedMusic*(): cint {.importc: "Mix_PausedMusic".}
# Set the current position in the music stream.
#   This returns 0 if successful, or -1 if it failed or isn't implemented.
#   This function is only implemented for MOD music formats (set pattern
#   order number) and for OGG, FLAC, MP3_MAD, and MODPLUG music (set
#   position in seconds), at the moment.
#

proc setMusicPosition*(position: cdouble): cint {.importc: "Mix_SetMusicPosition".}

# Check the status of a specific channel.
#   If the specified channel is -1, check all channels.
#
proc playing*(channel: cint): cint {.importc: "Mix_Playing".}
proc playingMusic*(): cint {.importc: "Mix_PlayingMusic".}

# Stop music and set external music playback command
proc setMusicCMD*(command: cstring): cint {.importc: "Mix_SetMusicCMD".}
# Synchro value is set by MikMod from modules while playing

proc setSynchroValue*(value: cint): cint {.importc: "Mix_SetSynchroValue".}
proc getSynchroValue*(): cint {.importc: "Mix_GetSynchroValue".}
# Set/Get/Iterate SoundFonts paths to use by supported MIDI backends

proc setSoundFonts*(paths: cstring): cint {.
    importc: "Mix_SetSoundFonts".}
proc getSoundFonts*(): cstring {.importc: "Mix_GetSoundFonts".}
proc eachSoundFont*(function: proc (a2: cstring; a3: pointer): cint {.cdecl.};
                        data: pointer): cint {.importc: "Mix_EachSoundFont".}
# Get the Chunk currently associated with a mixer channel
#    Returns NULL if it's an invalid channel, or there's no chunk associated.
#

proc getChunk*(channel: cint): ptr Chunk {.importc: "Mix_GetChunk".}
# Close the mixer, halting all playing audio

proc closeAudio*() {.importc: "Mix_CloseAudio".}
