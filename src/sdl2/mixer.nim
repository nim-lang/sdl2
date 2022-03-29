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

## Multi-channel audio mixer library.

{.deadCodeElim: on.}
# Dynamically link to the correct library for our system:

when not defined(SDL_Static):
  when defined(windows):
    const LibName* = "SDL2_mixer.dll"
  elif defined(macosx):
    const LibName* = "libSDL2_mixer.dylib"
  else:
    const LibName* = "libSDL2_mixer(|-2.0).so(|.0)"
else:
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."

when not defined(SDL_Static):
  {.push callConv:cdecl, dynlib: LibName.}

import sdl2, sdl2.audio

when system.cpuEndian == littleEndian: # SDL_BYTEORDER == SDL_LIL_ENDIAN
  const
    MIX_DEFAULT_FORMAT* = AUDIO_S16LSB
else:
  const
    MIX_DEFAULT_FORMAT* = AUDIO_S16MSB

# Remove prefixes in our wrapper, we have modules in Nim:

# These are not recognized by c2nim, but that's easy to fix:

proc linkedVersion*(): ptr SDL_version {.importc: "Mix_Linked_Version".}
  ## Gets the version of the dynamically linked mixer
  ## library.
  # TODO: Add the equivalent of the SDL_MIXER_VERSION() macro
  # (version() template ?) and this comment:
  # It should NOT be used to fill a version structure, instead you
  # should use the `version()` template.

const
    MIX_INIT_FLAC*       : cint = 0x00000001
    ## (.flac) requiring the FLAC library on system
    ## also any command-line player, which is not mixed by `mixer`
    MIX_INIT_MOD*        : cint = 0x00000002
    ## (.mod .xm .s3m .669 .it .med and more) requiring libmikmod on system
    MIX_INIT_MODPLUG*    : cint = 0x00000004
    MIX_INIT_MP3*        : cint = 0x00000008
    ## (.mp3) requiring SMPEG or MAD library on system
    MIX_INIT_OGG*        : cint = 0x00000010
    ## (.ogg) requiring ogg/vorbis libraries on system
    MIX_INIT_FLUIDSYNTH* : cint = 0x00000020


proc init*(flags: cint): cint {.importc: "Mix_Init".}
  ## Loads dynamic libraries and prepares them for use.
  ##
  ## `flags` bitwise OR'd set of sample/music formats to support by loading
  ## a library now from `mixer.INIT_*`
  ##
  ## Initialize by loading support as indicated by the flags, or at least
  ## return success if support is already loaded. You may call this multiple
  ## times, which will actually require you to call `mixer.quit()`
  ## just once to clean up. You may call this procedure with a `0` to retrieve
  ## whether support was built-in or not loaded yet.
  ##
  ## `Note:` you can call `mixer.init()` with the right
  ## `mixer.INIT_*` flags OR'd together before you program gets busy,
  ## to prevent a later hiccup while it loads and unloads the library,
  ## and to check that you do have the support that you need before you try
  ## and use it.
  ##
  ## `Note:` this procedure does not always set the error string, so do not
  ## depend on `mixer.getError()` being meaningful all the time.
  ##
  ## `Return` the flags successfully initialized, or `0` on failure.

proc quit*() {.importc: "Mix_Quit".}
  ## Unloads libraries loaded with `init()`.
  ##
  ## This procedure cleans up all dynamically loaded library handles, freeing
  ## memory. If support is required again it will be initialized again, either
  ## by `mixer.init()` or loading a sample or some music with dynamic
  ## support required. You may call this procedure when `mixer.load*`
  ## procedures are no longer needed for the `mixer.INIT_*` formats.
  ## You should call this procedure for each time `mixer.init()` was
  ## called, otherwise it may not free all the dynamic library resources until
  ## the program ends. This is done so that multiple unrelated modules of a
  ## program may call `mixer.init()` and `mixer.quit()` without
  ## affecting the others performance and needs.
  ##
  ## `Note:` Since each call to `init()` may set different
  ## flags, there is no way, currently, to request how many times each one
  ## was `init`ialized. In other words, the only way to quit for sure is to do
  ## a loop like so:
  ##
  ## .. code-block:: nim
  ##   # force a quit
  ##   while init(0) != 0:
  ##     mixer.quit()

const
  MIX_CHANNELS* = 8 ## The default mixer has `8` simultaneous mixing channels

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
    ## The internal format for an audio chunk
    ##
    ## This stores the sample data, the length in bytes of that data,
    ## and the volume to use when mixing the sample.
    allocated*: cint
      ## a boolean indicating whether to free abuf when the chunk is freed.
      ## `0` if the memory was not allocated and thus not owned by this chunk.
      ## `1` if the memory was allocated and is thus owned by this chunk.
    abuf*: ptr uint8
      ## Pointer to the sample data,
      ## which is in the output format and sample rate.
    alen*: uint32 ## Length of abuf in bytes.
    volume*: uint8 ## Per-sample volume,
      ## `0` = silent, `128` = max volume. This takes effect when mixing.


# The different fading types supported

type
  Fading* {.size: sizeof(cint).} = enum
    ## Return values from `mixer.fadingMusic()` and
    ## `mixer.fadingChannel()` are of these enumerated values.
    ##
    ## If no fading is taking place on the queried channel or music,
    ## then `MIX_NO_FADING` is returned. Otherwise they are self explanatory.
    MIX_NO_FADING, MIX_FADING_OUT, MIX_FADING_IN

  MusicType* {.size: sizeof(cint).} = enum
    ## Return values from `mixer.getMusicType()`
    ## are of these enumerated values.
    ##
    ## If no music is playing then `MUS_NONE` is returned.    ##
    ## If music is playing via an external command then `MUS_CMD` is returned.
    ## Otherwise they are self explanatory.
    ##
    ## These are types of music files (not libraries used to load them).
    MUS_NONE, MUS_CMD, MUS_WAV, MUS_MOD, MUS_MID, MUS_OGG, MUS_MP3, MUS_MP3_MAD,
    MUS_FLAC, MUS_MODPLUG



# The internal format for a music chunk interpreted via mikmod

type
  MusicPtr* = ptr Music
  Music* = object
    ## The internal format for a music chunk interpreted via mikmod



# Open the mixer with a certain audio format

proc openAudio*(frequency: cint; format: uint16; channels: cint;
                chunksize: cint): cint {.importc: "Mix_OpenAudio".}
  ## Open the mixer with a certain audio format.
  ##
  ## `frequency` Output sampling frequency in samples per second (Hz).
  ## you might use `mixer.DEFAULT_FREQUENCY` (22050) since that is a good
  ## value for most games.
  ## `frequency` would be `44100` for 44.1KHz, which is CD audio rate.
  ## Most games use `22050`, because `44100` requires too much CPU power
  ## on older computers.
  ##
  ## `format` Output sample format, based on SDL audio support.
  ## See `audio.nim` (`AUDIO_*`).
  ##
  ## `channels` Number of sound channels in output.
  ## Set to `2` for stereo, `1` for mono.
  ## This has nothing to do with mixing channels.
  ## `mixer.Channels` (8) mixing channels will be allocated by default.
  ##
  ## `chunksize` Bytes used per output sample.
  ## `chunksize` is the size of each mixed sample.
  ## The smaller this is the more your hooks will be called.
  ## If make this too small on a slow system, sound may skip.
  ## If made to large, sound effects will lag behind the action more.
  ## You want a happy medium for your target computer.
  ## You also may make this `4096`, or larger, if you are just playing music.
  ##
  ## This must be called before using other procedures in this library.
  ##
  ## SDL must be initialized with `sdl.INIT_AUDIO` before this call.
  ##
  ## You may call this procedures multiple times, however you will have to call
  ## `mixer.closeAudio()` just as many times for the device to actually
  ## close. The format will not changed on subsequent calls until fully closed.
  ## So you will have to close all the way before trying to open with different
  ## format parameters.
  ##
  ## `Return` `0` on success, `-1` on errors.


proc allocateChannels*(numchans: cint): cint {.
    importc: "Mix_AllocateChannels".}
  ## Set the number of channels being mixed.
  ##
  ## `numchans` Number of channels to allocate for mixing.
  ## A negative number will not do anything, it will tell you
  ## how many channels are currently allocated.
  ##
  ## This can be called multiple times, even with sounds playing.
  ## If `numchans` is less than the current number of channels,
  ## then the higher channels will be stopped, freed, and therefore
  ## not mixed any longer. It's probably not a good idea to change
  ## the size 1000 times a second though.
  ##
  ## If any channels are deallocated, any callback set by
  ## `mixer.channelFinished()` will be called when each channel
  ## is halted to be freed.
  ##
  ## `Note:` passing in zero WILL free all mixing channels,
  ## however music will still play.
  ##
  ## `Return` the number of channels allocated.
  ## Never fails... but a high number of channels can segfault
  ## if you run out of memory. We're talking REALLY high!

proc querySpec*(frequency: ptr cint; format: ptr uint16;
                channels: ptr cint): cint {.importc: "Mix_QuerySpec".}
  ## Get the actual audio format in use by the opened audio device.
  ## This may or may not match the parameters you passed to
  ## `mixer.openAudio()`.
  ##
  ## `frequency` A pointer to an `int` where the frequency actually used
  ## by the opened audio device will be stored.
  ##
  ## `format` A pointer to a `uint16` where the output format actually
  ## being used by the audio device will be stored.
  ##
  ## `channels` A pointer to an `int` where the number of audio channels
  ## will be stored. `2` will mean stereo, `1` will mean mono.
  ##
  ## `Return` `0` on error.
  ## If the device was open the number of times it was opened will be returned.
  ## The values of the arguments variables are not set on an error.

proc loadWAV_RW*(src: RWopsPtr; freesrc: cint): ptr Chunk {.
  importc: "Mix_LoadWAV_RW".}
  ## Load src for use as a sample.
  ##
  ## This can load WAVE, AIFF, RIFF, OGG, and VOC formats.
  ## Using `sdl.RWops` is not covered here, but they enable you to load from
  ## almost any source.
  ##
  ## `src` The source `sdl.RWops` as a pointer.
  ## The sample is loaded from this.
  ##
  ## `freesrc` A non-zero value mean is will automatically close/free
  ## the `src` for you.
  ##
  ## `Note:` You must call `sdl.openAudio()` before this.
  ## It must know the output characteristics so it can convert the sample
  ## for playback, it does this conversion at load time.
  ##
  ## `Return` a pointer to the sample as a `mixer.chunk()`.
  ## `nil` is returned on errors.

template loadWAV*(file: untyped): untyped =
  loadWAV_RW(rwFromFile(file, "rb"), 1)

proc loadMUS*(file: cstring): ptr Music {.importc: "Mix_LoadMUS".}
  ## Load music file to use.
  ## This can load WAVE, MOD, MIDI, OGG, MP3, FLAC,
  ## and any file that you use a command to play with.
  ##
  ## `file` Name of music file to use.
  ##
  ## If you are using an external command to play the music, you must call
  ## `mixer.setMusicCMD()` before this, otherwise the internal players
  ## will be used. Alternatively, if you have set an external command up and
  ## don't want to use it, you must call `mixer.setMusicCMD(nil)`
  ## to use the built-in players again.
  ##
  ## `Return` a pointer to a `mixer.Music`.
  ## `nil` is returned on errors.

proc loadMUS_RW*(src: RWopsPtr; freesrc: cint): ptr Music {.
    importc: "Mix_LoadMUS_RW".}
  ## Load a music file from an RWop object (Ogg and MikMod specific currently).
  ##
  ## Matt Campbell (matt@campbellhome.dhs.org) April 2000


proc loadMUSType_RW*(src: RWopsPtr; `type`: MusicType; freesrc: cint): ptr Music {.
    importc: "Mix_LoadMUSType_RW".}
  ## Load a music file from an RWop object assuming a specific format.

proc quickLoad_WAV*(mem: ptr uint8): ptr Chunk {.importc: "Mix_QuickLoad_WAV".}
  ## Load mem as a WAVE/RIFF file into a new sample.
  ##
  ## The WAVE in mem must be already in the output format.
  ## It would be better to use `mixer.loadWAV_RW()` if you aren't sure.
  ##
  ## `mem` Memory buffer containing a WAVE file in output format.
  ##
  ## `Note:` This procedure does very little checking.
  ## If the format mismatches the output format,
  ## or if the buffer is not a WAVE, it will not return an error.
  ## This is probably a dangerous procedure to use.
  ##
  ## `Return` a pointer to the sample as a `mixer.Chunk`.
  ## `nil` is returned on errors.

proc quickLoad_RAW*(mem: ptr uint8; len: uint32): ptr Chunk {.
  importc: "Mix_QuickLoad_RAW".}
  ## Load mem as a raw sample.
  ##
  ## The data in mem must be already in the output format.
  ## If you aren't sure what you are doing,
  ## this is not a good procedure for you!
  ##
  ## `mem` Memory buffer containing a WAVE file in output format.
  ##
  ## `Note:` This procedure does very little checking.
  ## If the format mismatches the output format it will not return an error.
  ## This is probably a dangerous procedure to use.
  ##
  ## `Return` a pointer to the sample as a `mixer.Chunk`.
  ## `nil` is returned on errors, such as when out of memory.

proc freeChunk*(chunk: ptr Chunk) {.importc: "Mix_FreeChunk".}
  ## Free the memory used in `chunk`, and free `chunk` itself as well.
  ## Do not use `chunk` after this without loading a new sample to it.
  ##
  ## `chunk` Pointer to the `mixer.Chunk` to free.
  ##
  ## `Note:` It's a bad idea to free a chunk that is still being played...

proc freeMusic*(music: ptr Music) {.importc: "Mix_FreeMusic".}
  ## Free the loaded `music`.
  ##
  ## `music` Pointer to `mixer.Music` to free.
  ##
  ## If `music` is playing it will be halted.
  ## If `music` is fading out, then this procedure will wait (blocking)
  ## until the fade out is complete.

proc getNumChunkDecoders*(): cint {.importc: "Mix_GetNumChunkDecoders".}
  ## Get a list of chunk/music decoders that this build of SDL_mixer provides.
  ##
  ## This list can change between builds AND runs of the program, if external
  ## libraries that add functionality become available.
  ## You must successfully call `openAudio()`
  ## before calling these procedures.
  ## This API is only available in SDL_mixer 1.2.9 and later.
  ##
  ## Usage:
  ##
  ## .. code-block:: nim
  ##   var i: cint
  ##   const total: cint = getNumChunkDecoders()
  ##   for i in 0..total-1:
  ##     echo "Supported chunk decoder: [$1]" % [getChunkDecoder(i)]
  ##
  ## Appearing in this list doesn't promise your specific audio file will
  ## decode...but it's handy to know if you have, say, a functioning Timidity
  ## install.
  ##
  ## These return values are static, read-only data; do not modify or free it.
  ## The pointers remain valid until you call `closeAudio()`.

proc getChunkDecoder*(index: cint): cstring {.importc: "Mix_GetChunkDecoder".}
  ## Get the name of the indexed sample chunk decoder.
  ## You need to get the number of sample chunk decoders available using the
  ## `mixer.getNumChunkDecoders()` procedure.
  ##
  ## `index` The index number of sample chunk decoder to get.
  ## In the range from `0` to `mixer.getNumChunkDecoders()`-1, inclusive.
  ##
  ## `Return` the name of the indexed sample chunk decoder.
  ## This string is owned by the SDL_mixer library, do not modify or free it.
  ## It is valid until you call `mixer.closeAudio()` the final time.

proc getNumMusicDecoders*(): cint {.importc: "Mix_GetNumMusicDecoders".}
  ## Get the number of music decoders available
  ## from the `mixer.getMusicDecoder()` procedure.
  ##
  ## This number can be different for each run of a program,
  ## due to the change in availability of shared libraries
  ## that support each format.
  ##
  ## `Return` the number of music decoders available.

proc getMusicDecoder*(index: cint): cstring {.importc: "Mix_GetMusicDecoder".}
  ## Get the name of the `index`'ed music decoder.
  ## You need to get the number of music decoders available using the
  ## `mixer.getNumMusicDecoders()` procedure.
  ##
  ## `index` The index number of music decoder to get.
  ## In the range from `0` to `mixer.getNumMusicDecoders()`-1, inclusive.
  ##
  ## `Return` the name of the `index`'ed music decoder.
  ## This string is owned by the SDL_mixer library, do not modify or free it.
  ## It is valid until you call `mixer.closeAudio()` the final time.

proc getMusicType*(music: ptr Music): MusicType {.importc: "Mix_GetMusicType".}
  ## Find out the music format of a mixer music, or the currently playing
  ## music, if `music` is `nil`.
  ##
  ## `music` The music to get the type of.
  ## `nil` will get the currently playing music type.
  ##
  ## Tells you the file format encoding of the music.
  ## This may be handy when used with `mixer.setMusicPosition()`,
  ## and other music procedures that vary based on the type of music being
  ## played. If you want to know the type of music currently being played,
  ## pass in `nil` to `music`.
  ##
  ## `Return` the type of `music` or if `music` is `nil` then the
  ## currently playing music type, otherwise `MUS_NONE` if no music is playing.

proc setPostMix*(
  mix_func: proc (udata: pointer; stream: ptr uint8; len: cint) {.cdecl.};
  arg: pointer) {.importc: "Mix_SetPostMix".}
  ## Set a procedure that is called after all mixing is performed.
  ##
  ## `mix_func` The procedure pointer for the postmix processor.
  ## `nil` unregisters the current postmixer.
  ##
  ## `arg` A pointer to data to pass into the `mix_func`'s `udata`
  ## parameter. It is a good place to keep the state data for the processor,
  ## especially if the processor is made to handle multiple channels at the
  ## same time.
  ## This may be `nil`, depending on the processor.
  ##
  ## This can be used to provide real-time visual display of the audio stream
  ## or add a custom mixer filter for the stream data.
  ##
  ## You may just be reading the data and displaying it, or you may be
  ## altering the stream to add an echo. Most processors also have state data
  ## that they allocate as they are in use, this would be stored in the `arg`
  ## pointer data space. This processor is never really finished, until the
  ## audio device is closed, or you pass `nil` as the `mix_func`.
  ##
  ## There can only be one postmix procedure used at a time through this
  ## method. Use `mixer.registerEffect(CHANNEL_POST, mix_func, nil, arg)`
  ## to use multiple postmix processors.
  ##
  ## This postmix processor is run AFTER all the registered postmixers set up
  ## by `mixer.registerEffect()`.

proc hookMusic*(mix_func: proc (udata: pointer; stream: ptr uint8; len: cint) {.
    cdecl.}; arg: pointer) {.importc: "Mix_HookMusic".}
  ## Add your own music player or additional mixer procedure.
  ##
  ## `mix_func` Procedure pointer to a music player mixer procedure.
  ## `nil` will stop the use of the music player, returning the mixer to using
  ## the internal music players like usual.
  ##
  ## `arg` This is passed to the `mix_func`'s udata parameter
  ## when it is called.
  ##
  ## This sets up a custom music player procedure. The procedure will be called
  ## with `arg` passed into the `udata` parameter when the `mix_func` is
  ## called. The `stream` parameter passes in the audio stream buffer to be
  ## filled with `len` bytes of music.
  ##
  ## The music player will then be called automatically when the mixer needs
  ## it. Music playing will start as soon as this is called.
  ##
  ## All the music playing and stopping procedures have no effect on music
  ## after this. Pause and resume will work.
  ##
  ## Using a custom music player and the internal music player is not possible,
  ## the custom music player takes priority. To stop the custom music player
  ## call `mixer.hookMusic(nil, nil)`.
  ##
  ## `Note:` NEVER call SDL_Mixer procedures, nor `sdl.lockAudio()`,
  ## from a callback procedure.

proc hookMusicFinished*(music_finished: proc () {.cdecl.}) {.
  importc: "Mix_HookMusicFinished".}
  ## Add your own callback for when the music has finished playing or when
  ## it is stopped from a call to `mix.haltMusic()`.
  ##
  ## `music_finished` Procedure pointer to a `proc() {.cdecl.}`.
  ## `nil` will remove the hook.
  ##
  ## This sets up a procedure to be called when music playback is halted.
  ## Any time music stops, the music_finished procedure will be called.
  ## Call with `nil` to remove the callback.
  ##
  ## `Note:` NEVER call SDL_Mixer procedures, nor `sdl.lockAudio()`,
  ## from a callback procedure.

proc getMusicHookData*(): pointer {.importc: "Mix_GetMusicHookData".}
  ## Get the `arg` passed into `mixer.hookMusic()`.
  ##
  ## `Return` the `arg` pointer.

proc channelFinished*(channel_finished: proc (channel: cint) {.cdecl.}) {.
  importc: "Mix_ChannelFinished".}
  ## Add your own callback when a channel has finished playing.
  ##
  ## `channel_finished` Procedure to call when any channel finishes playback.
  ## `nil` to disable callback. The callback may be called from the mixer's
  ## audio callback or it could be called as a result of
  ## `mixer.haltChannel()`, etc.
  ##
  ## `Note:` NEVER call SDL_Mixer procedures, nor `sdl.lockAudio()`
  ## from a callback procedure.

const
  MIX_CHANNEL_POST* = - 2


type
  Mix_EffectFunc_t* = proc (chan: cint; stream: pointer; len: cint;
                            udata: pointer) {.cdecl.}
    ## This is the prototype for effect processing procedures.
    ##
    ## `chan` The channel number that this effect is effecting now.
    ## `mixer.CHANNEL_POST` is passed in for post processing effects
    ## over the final mix.
    ##
    ## `stream` The buffer containing the current sample to process.
    ##
    ## `len` The length of stream in bytes.
    ##
    ## `udata` User data pointer that was passed in
    ## to `mixer.registerEffect()` when registering this
    ## effect processor procedure.
    ##
    ## These procedures are used to apply effects processing on a sample chunk.
    ## As a channel plays a sample, the registered effect procedures are
    ## called. Each effect would then read and perhaps alter the `len` bytes
    ## of `stream`. It may also be advantageous to keep the effect state in
    ## the `udata`, with would be setup when registering the effect procedure
    ## on a channel.
    ##
    ## Your effect changes the contents of `stream` based on whatever
    ## parameters are significant, or just leaves it be, if you prefer.
    ## You can do whatever you like to the buffer, though, and it will
    ## continue in its changed state down the mixing pipeline, through
    ## any other effect procedures, then finally to be mixed with the rest
    ## of the channels and music for the final output stream.
    ##
    ## `DO NOT EVER` call `lockAudio()` from your callback procedure!

type
  Mix_EffectDone_t* = proc (chan: cint; udata: pointer) {.cdecl.}
    ## This is the prototype for effect processing procedures.
    ##
    ## `chan` The channel number that this effect is effecting now.
    ## `mixer.CHANNEL_POST` is passed in for post processing effects
    ## over the final mix.
    ##
    ## `udata` User data pointer that was passed in
    ## to `mixer.registerEffect()` when registering this
    ## effect processor procedure.
    ##
    ## This is a callback that signifies that a channel has finished all its
    ## loops and has completed playback. This gets called if the buffer
    ## plays out normally, or if you call `haltChannel()`, implicitly stop
    ## a channel via `allocateChannels()`, or unregister a callback while
    ## it's still playing. At that time the effects processing procedure may
    ## want to reset some internal variables or free some memory. It should
    ## free memory at least, because the processor could be freed after this
    ## call.
    ##
    ## `DO NOT EVER` call `lockAudio()` from your callback procedure!


proc registerEffect*(chan: cint; f: Mix_EffectFunc_t; d: Mix_EffectDone_t;
                         arg: pointer): cint {.importc: "Mix_RegisterEffect".}
  ## Register a special effect procedure.
  ##
  ## `chan` Channel number to register `f` and `d` on.
  ## Use `mixer.CHANNEL_POST` to process the postmix stream.
  ##
  ## `f` The procedure pointer for the effects processor.
  ##
  ## `d` The procedure pointer for any cleanup routine to be called
  ## when the channel is done playing a sample.
  ## This may be `nil` for any processors that don't need to clean up
  ## any memory or other dynamic data.
  ##
  ## `arg` A pointer to data to pass into the `f`'s and `d`'s `udata`
  ## parameter. It is a good place to keep the state data for the processor,
  ## especially if the processor is made to handle multiple channels
  ## at the same time.
  ## This may be `nil`, depending on the processor.
  ##
  ## Hook a processor procedure `f` into a channel for post processing
  ## effects. You may just be reading the data and displaying it, or you may be
  ## altering the stream to add an echo. Most processors also have state data
  ## that they allocate as they are in use, this would be stored in the `arg`
  ## pointer data space. When a processor is finished being used, any procedure
  ## passed into `d` will be called, which is when your processor should
  ## clean up the data in the `arg` data space.
  ##
  ## The effects are put into a linked list, and always appended to the end,
  ## meaning they always work on previously registered effects output. Effects
  ## may be added multiple times in a row. Effects are cumulative this way.
  ##
  ## At mixing time, the channel data is copied into a buffer and passed
  ## through each registered effect procedure. After it passes through all the
  ## procedures, it is mixed into the final output stream. The copy to buffer
  ## is performed once, then each effect procedure performs on the output
  ## of the previous effect. Understand that this extra copy to a buffer
  ## is not performed if there are no effects registered for a given chunk,
  ## which saves CPU cycles, and any given effect will be extra cycles, too,
  ## so it is crucial that your code run fast. Also note that the data that
  ## your procedure is given is in the format of the sound device, and not the
  ## format you gave to `openAudio()`, although they may in reality be the
  ## same. This is an unfortunate but necessary speed concern. Use
  ## `querySpec()` to determine if you can handle the data before you
  ## register your effect, and take appropriate actions.
  ##
  ## You may also specify a callback (`EffectDone_t`) that is called when
  ## the channel finishes playing. This gives you a more fine-grained control
  ## than `channelFinished()`, in case you need to free effect-specific
  ## resources, etc. If you don't need this, you can specify `nil`.
  ##
  ## You may set the callbacks before or after calling `playChannel()`.
  ##
  ## Things like `setPanning()` are just internal special effect procedures,
  ## so if you are using that, you've already incurred the overhead of a copy
  ## to a separate buffer, and that these effects will be in the queue with
  ## any procedures you've registered. The list of registered effects for a
  ## channel is reset when a chunk finishes playing, so you need to explicitly
  ## set them with each call to `playChannel()`.
  ##
  ## You may also register a special effect procedure that is to be run after
  ## final mixing occurs. The rules for these callbacks are identical to those
  ## in `registerEffect()`, but they are run after all the channels and the
  ## music have been mixed into a single stream, whereas channel-specific
  ## effects run on a given channel before any other mixing occurs. These
  ## global effect callbacks are call "posteffects". Posteffects only have
  ## their `EffectDone_t` proceudre called when they are unregistered (since
  ## the main output stream is never "done" in the same sense as a channel).
  ## You must unregister them manually when you've had enough. Your callback
  ## will be told that the channel being mixed is (`CHANNEL_POST`) if the
  ## processing is considered a posteffect.
  ##
  ## After all these effects have finished processing, the callback registered
  ## through `setPostMix()` runs, and then the stream goes to the audio
  ## device.
  ##
  ## `DO NOT EVER` call `lockAudio()` from your callback procedure!
  ##
  ## `Return` `0` if error (no such channel), nonzero if added.
  ##
  ## Error messages can be retrieved from `getError()`.

proc unregisterEffect*(channel: cint; f: Mix_EffectFunc_t): cint {.
  importc: "Mix_UnregisterEffect".}
  ## Remove the oldest (first found) registered effect procedure `f`
  ## from the effect list for `channel`.
  ##
  ## `channel` Channel number to remove `f` from as a post processor.
  ## Use `mixer.CHANNEL_POST` for the postmix stream.
  ##
  ## `f` The procedure to remove from `channel`.
  ##
  ## This only removes the first found occurance of that procedure, so it may
  ## need to be called multiple times if you added the same procedure multiple
  ## times, just stop removing when `mixer.unregisterEffect()` returns an
  ## error, to remove all occurances of `f` from a channel.
  ##
  ## If the `channel` is active the registered effect will have its
  ## `mixer.EffectDone_t` procedure called, if it was specified in
  ## `mixer.registerEffect()`.
  ##
  ## You may not need to call this explicitly, unless you need to stop an
  ## effect from processing in the middle of a chunk's playback.
  ##
  ## Posteffects are never implicitly unregistered as they are for channels,
  ## but they may be explicitly unregistered through this procedure by
  ## specifying `CHANNEL_POST` for a channel.
  ##
  ## `Return` `0` if error (no such channel or effect), nonzero if removed.
  ##
  ## Error messages can be retrieved from `getError()`.

proc unregisterAllEffects*(channel: cint): cint {.
  importc: "Mix_UnregisterAllEffects".}
  ## This removes all effects registered to `channel`.
  ##
  ## `channel` Channel to remove all effects from.
  ## Use `mixer.CHANNEL_POST` for the postmix stream.
  ##
  ## If the `channel` is active, all the registered effects will have their
  ## `mixer.EffectDone_t` procedures called, if they were specified in
  ## `mixer.registerEffect()`.
  ##
  ## You may not need to call this explicitly, unless you need to stop all
  ## effects from processing in the middle of a chunk's playback. Note that
  ## this will also shut off some internal effect processing, since
  ## `setPanning()` and others may use this API under the hood. This is
  ## called internally when a channel completes playback.
  ##
  ## Posteffects are never implicitly unregistered as they are for channels,
  ## but they may be explicitly unregistered through this procedure by
  ## specifying `CHANNEL_POST` for a channel.
  ##
  ## `Return` `0` if error (no such channel), nonzero if all effects removed.
  ##
  ## Error messages can be retrieved from `getError()`.


const
  MIX_EFFECTSMAXSPEED* = "MIX_EFFECTSMAXSPEED"
    ## These are the internally-defined mixing effects. They use the same
    ## API that effects defined in the application use, but are provided here
    ## as a convenience. Some effects can reduce their quality or use more
    ## memory in the name of speed; to enable this, make sure the environment
    ## variable `EFFECTSMAXSPEED` (see above) is defined before you call
    ## `openAudio()`.

proc setPanning*(channel: cint; left: uint8; right: uint8): cint {.
  importc: "Mix_SetPanning".}
  ## Set the panning of a `channel`.
  ##
  ## `channel` Channel number to register this effect on.
  ## Use `mixer.CHANNEL_POST` to process the postmix stream.
  ##
  ## `left` Volume for the left channel,
  ## range is `0` (silence) to `255` (loud).
  ##
  ## `right` Volume for the right channel,
  ## range is `0` (silence) to `255` (loud).
  ##
  ## This effect will only work on stereo audio.
  ## Meaning you called `mixer.openAudio()` with `2` channels
  ## (`mixer.DEFAULT_CHANNELS`). The easiest way to do true panning
  ## is to call `mixer.setPanning(channel, left, 254 - left)` so that
  ## the total volume is correct, if you consider the maximum volume to be
  ## `127` per channel for center, or `254` max for left, this works,
  ## but about halves the effective volume.
  ##
  ## This procedure registers the effect for you,
  ## so don't try to `mixer.registerEffect()` it yourself.
  ##
  ## `Note:` Setting both left and right to `255` will unregister the effect
  ## from channel. You cannot unregister it any other way, unless you use
  ## `mixer.unregisterAllEffects()` on the channel.
  ##
  ## `Note:` Using this procedure on a mono audio device will not register
  ## the effect, nor will it return an error status.
  ##
  ## Setting `channel` to `CHANNEL_POST` registers this as a posteffect, and
  ## the panning will be done to the final mixed stream before passing it on
  ## to the audio device.
  ##
  ## `Return` `0` if error (no such channel or `registerEffect()` fails),
  ## nonzero if panning effect enabled. Note that an audio device in mono
  ## mode is a no-op, but this call will return successful in that case.
  ##
  ## Error messages can be retrieved from `getError()`.

proc setPosition*(channel: cint; angle: int16; distance: uint8): cint {.
  importc: "Mix_SetPosition".}
  ## Set the position of a `channel`.
  ##
  ## `channel` Channel number to register this effect on.
  ## Use `mixer.CHANNEL_POST` to process the postmix stream.
  ##
  ## `angle` Direction in relation to forward from `0` to `360` degrees.
  ## Larger angles will be reduced to this range using `angle mod 360`.
  ## * `0` = directly in front.
  ## * `90` = directly to the right.
  ## * `180` = directly behind.
  ## * `270` = directly to the left.
  ##
  ## So you can see it goes clockwise starting at directly in front.
  ## This ends up being similar in effect to `mixer.setPanning()`
  ## For efficiency, the precision of this effect may be limited
  ## (angles `1` through `7` might all produce the same effect,
  ## `8` through `15` are equal, etc).
  ##
  ## `distance` The distance from the listener,
  ## from `0` (near/loud) to `255 (far/quiet).
  ## This is the same as the `mixer.setDistance()` effect.
  ## For efficiency, the precision of this effect may be limited
  ## (distance `0` through `5` might all produce the same effect,
  ## `6` through `10` are equal, etc).
  ##
  ## This effect emulates a simple 3D audio effect. It's not all that
  ## realistic, but it can help improve some level of realism. By giving it
  ## the `angle` and `distance` from the camera's point of view,
  ## the effect pans and attenuates volumes. If you are looking for better
  ## positional audio, using OpenAL is suggested.
  ##
  ## `Note:` Using angle and distance of `0`, will cause the effect to
  ## unregister itself from `channel`. You cannot unregister it any other
  ## way, unless you use `mixer.unregisterAllEffects()`
  ## on the `channel`.
  ##
  ## If the audio device is configured for mono output, then you won't get
  ## any effectiveness from the `angle`; however, distance attenuation on
  ## the channel will still occur. While this effect will function with stereo
  ## voices, it makes more sense to use voices with only one channel of sound,
  ## so when they are mixed through this effect, the positioning will sound
  ## correct. You can convert them to mono through SDL before giving them to
  ## the mixer in the first place if you like.
  ##
  ## Setting `channel` to `mixer.CHANNEL_POST` registers this
  ## as a posteffect, and the positioning will be done to the final mixed
  ## stream before passing it on to the audio device.
  ##
  ## This is a convenience wrapper over `setDistance()` and `setPanning()`.
  ##
  ## `Return` `0` if error (no such channel or `registerEffect()` fails),
  ## nonzero if position effect is enabled.
  ##
  ## Error messages can be retrieved from `getError()`.

proc setDistance*(channel: cint; distance: uint8): cint {.
  importc: "Mix_SetDistance".}
  ## Set the `distance` of a `channel`.
  ##
  ## `channel` Channel number to register this effect on.
  ## Use `mixer.CHANNEL_POST` to process the postmix stream.
  ##
  ## `distance` Specify the distance from the listener,
  ## from `0` (close/loud) to `255` (far/quiet). A distance of `255` does
  ## not guarantee silence; in such a case, you might want to try changing
  ## the chunk's volume, or just cull the sample from the mixing process with
  ## `mixer.haltChannel()`.
  ##
  ## This effect simulates a simple attenuation of volume due to distance.
  ## The volume never quite reaches silence, even at max distance.
  ##
  ## `Note:` Using a distance of `0` will cause the effect to unregister
  ## itself from `channel`. You cannot unregister it any other way, unless
  ## you use `mixer.unregisterAllEffects()` on the `channel`.
  ##
  ## For efficiency, the precision of this effect may be limited
  ## (distances `1` through `7` might all produce the same effect,
  ## `8` through `15` are equal, etc).
  ##
  ## If you need more precise positional audio, consider using OpenAL for
  ## spatialized effects instead of mixer. This is only meant to be a
  ## basic effect for simple "3D" games.
  ##
  ## Setting `channel` to `mixer.CHANNEL_POST` registers this
  ## as a posteffect, and the distance attenuation will be done to the final
  ## mixed stream before passing it on to the audio device.
  ##
  ## This uses the `registerEffect()` API internally.
  ##
  ## `Return` `0` if error (no such channel or `mixer.registerEffect()`
  ## fails), nonzero if position effect is enabled.
  ##
  ## Error messages can be retrieved from `getError()`.

when false:

  proc setReverb*(channel: cint; echo: uint8): cint {.
    importc: "Mix_SetReverb".}
    ## Causes an echo effect to be mixed into a sound.
    ##
    ## `echo` is the amount of echo to mix.
    ## `0` is no echo, `255` is infinite (and probably not what you want).
    ##
    ## Setting `channel` to `CHANNEL_POST` registers this as a posteffect,
    ## and the reverbing will be done to the final mixed stream before passing
    ## it on to the audio device.
    ##
    ## This uses the `registerEffect()` API internally.
    ##
    ## If you specify an echo of zero, the effect is unregistered,
    ## as the data is already in that state.
    ##
    ## `Returns` `0` if error (no such channel or `registerEffect()`
    ## fails), nonzero if reversing effect is enabled.
    ##
    ## Error messages can be retrieved from `getError()`.

proc setReverseStereo*(channel: cint; flip: cint): cint {.
  importc: "Mix_SetReverseStereo".}
  ## Simple reverse stereo, swaps left and right channel sound.
  ##
  ## `channel` Channel number to register this effect on.
  ## Use `mixer.CHANNEL_POST` to process the postmix stream.
  ##
  ## `flip` Must be non-zero to work,
  ## means nothing to the effect processor itself.
  ## Set to `0` to unregister the effect from channel.
  ##
  ## Causes a `channel` to reverse its stereo. This is handy if the user has
  ## his speakers hooked up backwards, or you would like to have a minor bit
  ## of psychedelia in your sound code.  :)
  ##
  ## Calling this procedure with `flip` set to non-zero reverses the chunks's
  ## usual channels. If `flip` is zero, the effect is unregistered.
  ##
  ## This uses the `registerEffect()` API internally, and thus is probably
  ## more CPU intensive than having the user just plug in his speakers
  ## correctly. `setReverseStereo()` returns without registering the effect
  ## procedure if the audio device is not configured for stereo output.
  ##
  ## If you specify `CHANNEL_POST` for `channel`, then this the effect is
  ## used on the final mixed stream before sending it on to the audio device
  ## (a posteffect).
  ##
  ## `Note:` Using a flip of `0`, will cause the effect to unregister itself
  ## from `channel`. You cannot unregister it any other way, unless you use
  ## `mixer.unregisterAllEffects()` on the `channel`.
  ##
  ## `Return` `0` if error (no such channel or `registerEffect()` fails),
  ## nonzero if reversing effect is enabled. Note that an audio device in mono
  ## mode is a no-op, but this call will return successful in that case.
  ##
  ## Error messages can be retrieved from `getError()`.

proc reserveChannels*(num: cint): cint {.importc: "Mix_ReserveChannels".}
  ## Reserve `num` channels from being used when playing samples when
  ## passing in `-1` as a channel number to playback procedures.
  ## The channels are reserved starting from channel `0` to `num`-1.
  ## Passing in `0` will unreserve all channels.
  ## Normally SDL_mixer starts without any channels reserved.
  ##
  ## `num` Number of channels to reserve from default mixing.
  ## `0` removes all reservations.
  ##
  ## The following procedures are affected by this setting:
  ##
  ## * `mixer.playChannel()`
  ## * `mixer.playChannelTimed()`
  ## * `mixer.fadeInChannel()`
  ## * `mixer.fadeInChannelTimed()`
  ##
  ## `Return` the number of channels reserved.
  ## Never fails, but may return less channels than you ask for,
  ## depending on the number of channels previously allocated.

proc groupChannel*(which: cint; tag: cint): cint {.importc: "Mix_GroupChannel".}
  ## Add `which` channel to group tag, or reset it's group to the default
  ## group tag (`-1`).
  ##
  ## `which` Channel number of channels to assign tag to.
  ##
  ## `tag` A group number. Any positive numbers (including zero).
  ## `-1` is the default group. Use `-1` to remove a group tag essentially.
  ##
  ## `Return` `1` on success.
  ## `0` is returned when the channel specified is invalid.

proc groupChannels*(`from`: cint; to: cint; tag: cint): cint {.
  importc: "Mix_GroupChannels".}
  ## Add channels starting at `ch_from` up through `ch_to` to group tag,
  ## or reset it's group to the default group tag (`-1`).
  ##
  ## `ch_from` First Channel number of channels to assign tag to.
  ## Must be less or equal to `ch_to`.
  ##
  ## `ch_to` Last Channel number of channels to assign tag to.
  ## Must be greater or equal to `ch_from`.
  ##
  ## `tag` A group number. Any positive numbers (including zero).
  ## `-1` is the default group. Use `-1` to remove a group tag essentially.
  ##
  ## `Return` the number of tagged channels on success.
  ## If that number is less than `ch_to` - `ch_from` + 1
  ## then some channels were no tagged because they didn't exist.

proc groupAvailable*(tag: cint): cint {.importc: "Mix_GroupAvailable".}
  ## Finds the first available (not playing) channel in a group `tag`.
  ##
  ## `tag`  group number. Any positive numbers (including zero).
  ## `-1` will search ALL channels.
  ##
  ## `Return` the channel found on success.
  ## `-1` is returned when no channels in the group are available.

proc groupCount*(tag: cint): cint {.importc: "Mix_GroupCount".}
  ## Count the number of channels in group `tag`.
  ##
  ## `tag` A group number. Any positive numbers (including zero).
  ## `-1` will count ALL channels.
  ##
  ## `Return` the number of channels in a group. This procedure never fails.
  ## This is also a subtle way to get the total number of channels
  ## when `tag` is `-1`.

proc groupOldest*(tag: cint): cint {.importc: "Mix_GroupOldest".}
  ## Find the "oldest" sample playing in a group `tag`.
  ##
  ## `tag` A group number. Any positive numbers (including zero).
  ## `-1` will search ALL channels.
  ##
  ## `Return` the channel found on success.
  ## `-1` is returned when no channels in the group are playing
  ## or the group is empty.

proc groupNewer*(tag: cint): cint {.importc: "Mix_GroupNewer".}
  ## Find the "most recent" (i.e. last) sample playing in a group `tag`.
  ##
  ## `tag` A group number. Any positive numbers (including zero).
  ## `-1` will search ALL channels.
  ##
  ## `Return` the channel found on success.
  ## `-1` is returned when no channels in the group are playing
  ## or the group is empty.

proc playChannelTimed*(channel: cint; chunk: ptr Chunk; loops: cint;
                       ticks: cint): cint {.importc: "Mix_PlayChannelTimed".}
  ## The same as `mixer.playChannel()`,
  ## but the sound is played at most `ticks` milliseconds.
  ##
  ## `channel` Channel to play on,
  ## or `-1` for the first free unreserved channel.
  ##
  ## `chunk` Sample to play.
  ##
  ## `loops` Number of loops, `-1` is infinite loops.
  ## Passing `1` here plays the sample twice (1 loop).
  ##
  ## `ticks` Millisecond limit to play sample, at most.
  ## If not enough loops or the sample chunk is not long enough,
  ## then the sample may stop before this timeout occurs.
  ## `-1` means play forever.
  ##
  ## If the sample is long enough and has enough loops then the sample will
  ## stop after `ticks` milliseconds.
  ## Otherwise this procedure is the same as `mixer.playChannel()`.
  ##
  ## `Return` the channel the sample is played on.
  ## On any errors, `-1` is returned.

template playChannel*(channel, chunk, loops: untyped): untyped =
  ## Play chunk on channel, or if channel is `-1`,
  ## pick the first free unreserved channel.
  ##
  ## `channel` Channel to play on, or `-1`
  ## for the first free unreserved channel.
  ##
  ## `chunk` Sample to play.
  ##
  ## `loops` Number of loops, `-1` is infinite loops.
  ## Passing `1` here plays the sample twice (1 loop).
  ##
  ## The sample will play for `loops` + 1 number of times,
  ## unless stopped by halt, or fade out, or setting a new expiration time
  ## of less time than it would have originally taken to play the loops,
  ## or closing the mixer.
  ##
  ## `Note:` this just calls `mixer.playChannelTimed()`
  ## with ticks set to `-1`.
  ##
  ## `Return` the channel the sample is played on.
  ## On any errors, `-1` is returned.
  playChannelTimed(channel, chunk, loops, - 1)

proc playMusic*(music: ptr Music; loops: cint): cint {.importc: "Mix_PlayMusic".}
  ## Play the loaded `music` `loops` times through from start to finish.
  ##
  ## `music` Pointer to `mixer.Music` to play.
  ##
  ## `loops` Number of times to play through the `music`.
  ## `0` plays the music zero times.
  ## `-1` plays the music forever (or as close as it can get to that).
  ##
  ## The previous music will be halted, or if fading out it waits (blocking)
  ## for that to finish.
  ##
  ## `Return` `0` on success, or `-1` on errors.

proc fadeInMusic*(music: ptr Music; loops: cint; ms: cint): cint {.
  importc: "Mix_FadeInMusic".}
  ## Fade in over `ms` milliseconds of time, the loaded `music`,
  ## playing it `loops` times through from start to finish.
  ##
  ## `music` Pointer to `mixer.Music` to play.
  ##
  ## `loops` Number of times to play through the `music`.
  ## `0` plays the music zero times.
  ## `-1` plays the music forever (or as close as it can get to that).
  ##
  ## `ms` Milliseconds for the fade-in effect to complete.
  ##
  ## The fade in effect only applies to the first loop.
  ##
  ## Any previous music will be halted, or if it is fading out it will wait
  ## (blocking) for the fade to complete. This procedure is the same as
  ## `mixer.fadeInMusicPos(music, loops, ms, 0)`.
  ##
  ## `Return` `0` on success, or `-1` on errors.

proc fadeInMusicPos*(music: ptr Music; loops: cint; ms: cint;
                     position: cdouble): cint {.importc: "Mix_FadeInMusicPos".}
  ## Fade in over `ms` milliseconds of time, the loaded `music`,
  ## playing it `loops` times through from start to finish.
  ##
  ## `music` Pointer to `mixer.Music` to play.
  ##
  ## `loops` Number of times to play through the music.
  ## `0` plays the music zero times.
  ## `-1` plays the music forever (or as close as it can get to that).
  ##
  ## `ms` Milliseconds for the fade-in effect to complete.
  ##
  ## `position` Posistion to play from,
  ## see `mixer.setMusicPosition()` for meaning.
  ##
  ## The fade in effect only applies to the first loop.
  ##
  ## The first time the music is played, it posistion will be set to
  ## `posistion`, which means different things for different types
  ## of music files, see `mixer.setMusicPosition()` for more info
  ## on that.
  ##
  ## Any previous music will be halted, or if it is fading out it will wait
  ## (blocking) for the fade to complete.
  ##
  ## `Return` `0` on success, or `-1` on errors.

template fadeInChannel*(channel, chunk, loops, ms: untyped): untyped =
  ## Play `chunk` on `channel`, or if `channel` is `-1`,
  ## pick the first free unreserved channel.
  ##
  ## `channel` Channel to play on,
  ## or `-1` for the first free unreserved channel.
  ##
  ## `chunk` Sample to play.
  ##
  ## `loops` Number of loops, `-1` is infinite loops.
  ## Passing `1` here plays the sample twice (1 loop).
  ##
  ## `ms` Milliseconds of time that the fade-in effect should take
  ## to go from silence to full volume.
  ##
  ## The channel volume starts at `0` and fades up to full volume over `ms`
  ## milliseconds of time.
  ## The sample may end before the fade-in is complete if it is too short
  ## or doesn't have enough loops.
  ## The sample will play for `loops` + 1 number of times,
  ## unless stopped by halt, or fade out, or setting a new expiration time
  ## of less time than it would have originally taken to play the loops,
  ## or closing the mixer.
  ##
  ## `Note:` this just calls `mixer.fadeInChannelTimed()`
  ## with ticks set to `-1`.
  ##
  ## `Return` the channel the sample is played on.
  ## On any errors, `-1` is returned.
  fadeInChannelTimed(channel, chunk, loops, ms, - 1)

proc fadeInChannelTimed*(channel: cint; chunk: ptr Chunk; loops: cint;
                         ms: cint; ticks: cint): cint {.
  importc: "Mix_FadeInChannelTimed".}
  ## The same as `mixer.fadeInChannel()`,
  ## but the sound is played at most `ticks` milliseconds.
  ##
  ## `channel` Channel to play on,
  ## or `-1` for the first free unreserved channel.
  ##
  ## `chunk` Sample to play.
  ##
  ## `loops` Number of loops, `-1` is infinite loops.
  ## Passing `1` here plays the sample twice (1 loop).
  ##
  ## `ms` Milliseconds of time that the fade-in effect should take
  ## to go from silence to full volume.
  ##
  ## `ticks` Millisecond limit to play sample, at most.
  ## If not enough loops or the sample chunk is not long enough,
  ## then the sample may stop before this timeout occurs.
  ## `-1` means play forever.
  ##
  ## If the sample is long enough and has enough loops then the sample will
  ## stop after `ticks` milliseconds.
  ## Otherwise this procedures is the same as `mixer.fadeInChannel()`.
  ##
  ## `Return` the channel the sample is played on.
  ## On any errors, `-1` is returned.

proc volume*(channel: cint; volume: cint): cint {.importc: "Mix_Volume".}
  ## Set the volume for any allocated channel.
  ##
  ## `channel` Channel to set mix volume for.
  ## `-1` will set the volume for all allocated channels.
  ##
  ## `volume` The volume to use from `0` to `mixer.MAX_VOLUME` (128).
  ## If greater than `mixer.MAX_VOLUME`,
  ## then it will be set to `mixer.MAX_VOLUME`.
  ## If less than `0` then the volume will not be set.
  ##
  ## If `channel` is `-1` then all channels at are set at once.
  ## The `volume` is applied during the final mix, along with the sample
  ## volume. So setting this volume to `64` will halve the output of all
  ## samples played on the specified channel.
  ## All channels default to a volume of `128`, which is the max.
  ## Newly allocated channels will have the max volume set, so setting all
  ## channels volumes does not affect subsequent channel allocations.
  ##
  ## `Return` current volume of the channel.
  ## If channel is `-1`, the average volume is returned.

proc volumeChunk*(chunk: ptr Chunk; volume: cint): cint {.
  importc: "Mix_VolumeChunk".}
  ## Set `chunk.volume` to `volume`.
  ##
  ## The volume setting will take effect when the chunk is used on a channel,
  ## being mixed into the output.
  ##
  ## `chunk` Pointer to the `mixer.chunk` to set the volume in.
  ##
  ## `volume` The volume to use from `0` to `mixer.MAX_VOLUME` (128).
  ## If greater than `mixer.MAX_VOLUME`,
  ## then it will be set to `mixer.MAX_VOLUME`.
  ## If less than `0` then `chunk.volume` will not be set.
  ##
  ## `Return` previous `chunk.volume` setting.
  ## If you passed a negative value for `volume` then this volume is still
  ## the current volume for the `chunk`.

proc volumeMusic*(volume: cint): cint {.importc: "Mix_VolumeMusic".}
  ## Set the volume to `volume`, if it is `0` or greater,
  ## and return the previous volume setting.
  ##
  ## `volume` Music volume, from `0` to `mixer.MAX_VOLUME` (128).
  ## Values greater than `mixer.MAX_VOLUME`
  ## will use `mixer.MAX_VOLUME`.
  ## `-1` does not set the volume, but does return the current volume setting.
  ##
  ## Setting the volume during a fade will not work, the faders use this
  ## procedure to perform their effect!
  ##
  ## Setting volume while using an external music player set by
  ## `mixer.setMusicCMD()` will have no effect,
  ## and `mixer.getError()` will show the reason why not.
  ##
  ## `Return` the previous volume setting.

proc haltChannel*(channel: cint): cint {.importc: "Mix_HaltChannel".}
  ## Halt `channel` playback, or all channels if `-1` is passed in.
  ##
  ## `channel` Channel to stop playing, or `-1` for all channels.
  ##
  ## Any callback set by `mixer.channelFinished()` will be called.
  ##
  ## `Return` always returns zero. (kinda silly)

proc haltGroup*(tag: cint): cint {.importc: "Mix_HaltGroup".}
  ## Halt playback on all channels in group tag.
  ##
  ## `tag` Group to fade out.
  ## `Note:` `-1` will NOT halt all channels.
  ## Use `mixer.haltChannel(-1)` for that instead.
  ##
  ## Any callback set by `mixer.channelFinished()` will be called
  ## once for each channel that stops.
  ##
  ## `Return` always returns zero.
  ## (more silly than `mixer.haltChannel()`)

proc haltMusic*(): cint {.importc: "Mix_HaltMusic".}
  ## Halt playback of music.
  ##
  ## This interrupts music fader effects.
  ##
  ## Any callback set by `mixer.hookMusicFinished()` will be called
  ## when the music stops.
  ##
  ## `Return` always returns zero.
  ## (even more silly than `mixer.haltGroup()`)

proc expireChannel*(channel: cint; ticks: cint): cint {.
  importc: "Mix_ExpireChannel".}
  ## Halt `channel` playback, or all channels if `-1` is passed in,
  ## after `ticks` milliseconds.
  ##
  ## `channel` Channel to stop playing, or `-1` for all channels.
  ##
  ## `ticks` Millisecons until channel(s) halt playback.
  ##
  ## Any callback set by `mixer.channelFinished()` will be called
  ## when the channel expires.
  ##
  ## `Return` number of channels set to expire.
  ## Whether or not they are active.

proc fadeOutChannel*(which: cint; ms: cint): cint {.
  importc: "Mix_FadeOutChannel".}
  ## Gradually fade out `which` channel over `ms` milliseconds
  ## starting from now.
  ##
  ## `channel` Channel to fade out, or `-1` to fade all channels out.
  ##
  ## `ms` Milliseconds of time that the fade-out effect should take
  ## to go to silence, starting now.
  ##
  ## The channel will be halted after the fade out is completed. Only channels
  ## that are playing are set to fade out, including paused channels.
  ##
  ## Any callback set by `mixer.channelFinished()` will be called
  ## when the channel finishes fading out.
  ##
  ## `Return` the number of channels set to fade out.

proc fadeOutGroup*(tag: cint; ms: cint): cint {.importc: "Mix_FadeOutGroup".}
  ## Gradually fade out channels in group `tag` over `ms` milliseconds
  ## starting from now.
  ##
  ## `tag` Group to fade out.
  ## `Note:` `-1` will NOT fade all channels out.
  ## Use `mixer.fadeOutChannel(-1)` for that instead.
  ##
  ## `ms` Milliseconds of time that the fade-out effect should take
  ## to go to silence, starting now.
  ##
  ## The channels will be halted after the fade out is completed.
  ## Only channels that are playing are set to fade out, including paused
  ## channels. Any callback set by `mixer.channelFinished()` will be
  ## called when each channel finishes fading out.
  ##
  ## `Return` the number of channels set to fade out.

proc fadeOutMusic*(ms: cint): cint {.importc: "Mix_FadeOutMusic".}
  ## Gradually fade out the music over `ms` milliseconds starting from now.
  ##
  ## `ms` Milliseconds of time that the fade-out effect should take
  ## to go to silence, starting now.
  ##
  ## The music will be halted after the fade out is completed.
  ## Only when music is playing and not fading already are set to fade out,
  ## including paused channels.
  ##
  ## Any callback set by `mixer.hookMusicFinished()` will be called
  ## when the music finishes fading out.
  ##
  ## `Return` `1` on success, `0` on failure.

proc fadingMusic*(): Fading {.importc: "Mix_FadingMusic".}
  ## Tells you if music is fading in, out, or not at all.
  ##
  ## Does not tell you if the channel is playing anything, or paused,
  ## so you'd need to test that separately.
  ##
  ## `Return` the fading status. Never returns an error.

proc fadingChannel*(which: cint): Fading {.importc: "Mix_FadingChannel".}
  ## Tells you if `which` channel is fading in, out, or not.
  ## Does not tell you if the channel is playing anything, or paused,
  ## so you'd need to test that separately.
  ##
  ## `which` Channel to get the fade activity status from.
  ## `-1` is not valid, and will probably crash the program.
  ##
  ## `Return` the fading status. Never returns an error.

proc pause*(channel: cint) {.importc: "Mix_Pause".}
  ## Pause `channel`, or all playing channels if `-1` is passed in.
  ## You may still halt a paused channel.
  ##
  ## `channel` Channel to pause on, or `-1` for all channels.
  ##
  ## `Note:` Only channels which are actively playing will be paused.

proc resume*(channel: cint) {.importc: "Mix_Resume".}
  ## Unpause `channel`, or all playing and paused channels
  ## if `-1` is passed in.
  ##
  ## `channel` Channel to resume playing, or `-1` for all channels.

proc paused*(channel: cint): cint {.importc: "Mix_Paused".}
  ## Tells you if `channel` is paused, or not.
  ##
  ## `channel` Channel to test whether it is paused or not.
  ## `-1` will tell you how many channels are paused.
  ##
  ## `Note:` Does not check if the channel has been halted
  ## after it was paused, which may seem a little weird.
  ##
  ## `Return` `0` if the channel is not paused.
  ## Otherwise if you passed in `-1`,
  ## the number of paused channels is returned.
  ## If you passed in a specific channel,
  ## then `1` is returned if it is paused.

# Pause/Resume the music stream

proc pauseMusic*() {.importc: "Mix_PauseMusic".}
  ## Pause the music playback. You may halt paused music.
  ##
  ## `Note:` Music can only be paused if it is actively playing.

proc resumeMusic*() {.importc: "Mix_ResumeMusic".}
  ## Unpause the music.
  ## This is safe to use on halted, paused, and already playing music.

proc rewindMusic*() {.importc: "Mix_RewindMusic".}
  ## Rewind the music to the start.
  ## This is safe to use on halted, paused, and already playing music.
  ##
  ## It is not useful to rewind the music immediately after starting playback,
  ## because it starts at the beginning by default.
  ##
  ## This procedure only works for these streams: MOD, OGG, MP3, Native MIDI.

proc pausedMusic*(): cint {.importc: "Mix_PausedMusic".}
  ## Tells you if music is paused, or not.
  ##
  ## `Note:` Does not check if the music was been halted after it was paused,
  ## which may seem a little weird.
  ##
  ## `Return` `0` if music is not paused. `1` if it is paused.

proc setMusicPosition*(position: cdouble): cint {.
  importc: "Mix_SetMusicPosition".}
  ## Set the current `position` in the music stream.
  ##
  ## `position` Posistion to play from.
  ##
  ## The `position` takes different meanings for different music sources.
  ## It only works on the music sources listed below.
  ##
  ## `MOD`
  ##   The `cdouble` is cast to `uint16` and used for a pattern
  ##   number in the module. Passing zero is similar to rewinding the song.
  ##
  ## `OGG`
  ##   Jumps to position seconds from the beginning of the song.
  ##
  ## `MP3`
  ##   Jumps to position seconds from the current position in the stream.
  ##   So you may want to call `mixer.rewindMusic()` before this.
  ##   Does not go in reverse. Negative values do nothing.
  ##
  ## This procedurre is only implemented for MOD music formats (set pattern
  ## order number) and for OGG, FLAC, MP3_MAD, MPD_MPG and MODPLUG music
  ## (set position in seconds), at the moment.
  ##
  ## `Return` `0` on success,
  ## or `-1` if the codec doesn't support this procedure.

proc playing*(channel: cint): cint {.importc: "Mix_Playing".}
  ## Tells you if `channel` is playing, or not.
  ##
  ## `channel` Channel to test whether it is playing or not.
  ## `-1` will tell you how many channels are playing.
  ##
  ## `Note:` Does not check if the channel has been paused.
  ##
  ## `Return` `0` if the channel is not playing.
  ## Otherwise if you passed in `-1`,
  ## the number of channels playing is returned.
  ## If you passed in a specific channel,
  ## then `1` is returned if it is playing.

proc playingMusic*(): cint {.importc: "Mix_PlayingMusic".}
  ## Tells you if music is actively playing, or not.
  ##
  ## `Note:` Does not check if the channel has been paused.
  ##
  ## `Return` `0` if the music is not playing, or `1` if it is playing.

proc setMusicCMD*(command: cstring): cint {.importc: "Mix_SetMusicCMD".}
  ## Stop music and set external music playback command.
  ##
  ## `command` System command to play the music.
  ## Should be a complete command, as if typed in to the command line,
  ## but it should expect the filename to be added as the last argument.
  ## `nil` will turn off using an external command for music,
  ## returning to the internal music playing functionality.
  ##
  ## Setup a command line music player to use to play music.
  ## Any music playing will be halted.
  ##
  ## The music file to play is set by calling `mixer.loadMUS(filename)`,
  ## and the filename is appended as the last argument on the commandline.
  ## This allows you to reuse the music command to play multiple files.
  ##
  ## The command will be sent signals SIGTERM to halt, SIGSTOP to pause,
  ## and SIGCONT to resume. The command program should react correctly
  ## to those signals for it to function properly with mixer.
  ##
  ## `mixer.volumeMusic()` has no effect when using an external music
  ## player, and `mixer.getError()` will have an error code set.
  ## You should set the music volume in the music player's command if the music
  ## player supports that. Looping music works, by calling the command again
  ## when the previous music player process has ended. Playing music through a
  ## command uses a forked process to execute the music command.
  ##
  ## To use the internal music players set the command to `nil`.
  ##
  ## `Note:` External music is not mixed by SDL_mixer,
  ## so no post-processing hooks will be for music.
  ##
  ## `Note:` Playing music through an external command may not work
  ## if the sound driver does not support multiple openings of the audio
  ## device, since SDL_Mixer already has the audio device open for playing
  ## samples through channels.
  ##
  ## `Note:` Commands are not totally portable, so be careful.
  ##
  ## `Return` `0` on success, or `-1` on any errors,
  ## such as running out of memory.

proc setSynchroValue*(value: cint): cint {.importc: "Mix_SetSynchroValue".}
  ## Synchro value is set by MikMod from modules while playing.

proc getSynchroValue*(): cint {.importc: "Mix_GetSynchroValue".}

proc setSoundFonts*(paths: cstring): cint {.
    importc: "Mix_SetSoundFonts".}
  ## Set SoundFonts paths to use by supported MIDI backends
proc getSoundFonts*(): cstring {.importc: "Mix_GetSoundFonts".}
  ## Get SoundFonts paths to use by supported MIDI backends
proc eachSoundFont*(function: proc (a2: cstring; a3: pointer): cint {.cdecl.};
                    data: pointer): cint {.importc: "Mix_EachSoundFont".}
  ## Iterate SoundFonts paths to use by supported MIDI backends

proc getChunk*(channel: cint): ptr Chunk {.importc: "Mix_GetChunk".}
  ## Get the most recent sample chunk pointer played on `channel`.
  ## This pointer may be currently playing, or just the last used.
  ##
  ## `channel` Channel to get the current `mixer.Chunk` playing.
  ## `-1` is not valid, but will not crash the program.
  ##
  ## `Note:` The actual chunk may have been freed,
  ## so this pointer may not be valid anymore.
  ##
  ## `Return` pointer to the `mixer.Chunk`.
  ## `nil` is returned if the channel is not allocated,
  ## or if the channel has not played any samples yet.

proc closeAudio*() {.importc: "Mix_CloseAudio".}
  ## Shutdown and cleanup the mixer API.
  ##
  ## After calling this all audio is stopped, the device is closed,
  ## and the SDL_mixer procedures should not be used. You may, of course,
  ## use `mixer.openAudio()` to start the functionality again.
  ##
  ## `Note:` This procedure doesn't do anything until you have called it
  ## the same number of times that you called `mixer.openAudio()`.
  ## You may use `mixer.querySpec()` to find out how many times
  ## `mixer.closeAudio()` needs to be called before the device
  ## is actually closed.


when not defined(SDL_Static):
  {.pop.}
