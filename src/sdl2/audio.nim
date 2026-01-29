#  Simple DirectMedia Layer
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



## Access to the raw audio mixing buffer for the SDL library.

import sdl2


type
  AudioFormat* = uint16
    ## Audio format flags.
    ##
    ## These are what the 16 bits in `AudioFormat` currently mean...
    ## (Unspecified bits are always zero).
    ##
    ##   ++-----------------------sample is signed if set
    ##   ||
    ##   ||       ++-----------sample is bigendian if set
    ##   ||       ||
    ##   ||       ||          ++---sample is float if set
    ##   ||       ||          ||
    ##   ||       ||          || +---sample bit size---+
    ##   ||       ||          || |                     |
    ##   15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
    ##
    ## There are templates in SDL 2.0 and later to query these bits.

const
  SDL_AUDIO_MASK_BITSIZE*  = uint32(0x000000FF)
  SDL_AUDIO_MASK_DATATYPE* = uint32(1 shl 8)
  SDL_AUDIO_MASK_ENDIAN*   = uint32(1 shl 12)
  SDL_AUDIO_MASK_SIGNED*   = uint32(1 shl 15)

template SDL_AUDIO_BITSIZE*(x: uint32): uint32 =
  (x and SDL_AUDIO_MASK_BITSIZE)

template SDL_AUDIO_ISFLOAT*(x: uint32): bool =
  (x and SDL_AUDIO_MASK_DATATYPE) != 0

template SDL_AUDIO_ISBIGENDIAN*(x: uint32): bool =
  (x and SDL_AUDIO_MASK_ENDIAN) != 0

template SDL_AUDIO_ISSIGNED*(x: uint32): bool =
  (x and SDL_AUDIO_MASK_SIGNED) != 0

template SDL_AUDIO_ISINT*(x: uint32): bool =
  not SDL_AUDIO_ISFLOAT(x)

template SDL_AUDIO_ISLITTLEENDIAN*(x: uint32): bool =
  not SDL_AUDIO_ISBIGENDIAN(x)

template SDL_AUDIO_ISUNSIGNED*(x: uint32): bool =
  not SDL_AUDIO_ISSIGNED(x)


# Audio format flags
#
# Defaults to LSB byte order.
const
  AUDIO_U8* = 0x00000008     ## Unsigned 8-bit samples
  AUDIO_S8* = 0x00008008     ## Signed 8-bit samples
  AUDIO_U16LSB* = 0x00000010 ## Unsigned 16-bit samples
  AUDIO_S16LSB* = 0x00008010 ## Signed 16-bit samples
  AUDIO_U16MSB* = 0x00001010 ## As above, but big-endian byte order
  AUDIO_S16MSB* = 0x00009010 ## As above, but big-endian byte order
  AUDIO_U16* = AUDIO_U16LSB
  AUDIO_S16* = AUDIO_S16LSB

# int32 support
const
  AUDIO_S32LSB* = 0x00008020 ## 32-bit integer samples
  AUDIO_S32MSB* = 0x00009020 ## As above, but big-endian byte order
  AUDIO_S32* = AUDIO_S32LSB

# float32 support
const
  AUDIO_F32LSB* = 0x00008120 ## 32-bit floating point samples
  AUDIO_F32MSB* = 0x00009120 ## As above, but big-endian byte order
  AUDIO_F32* = AUDIO_F32LSB

# Native audio byte ordering
when false:
  # TODO system.cpuEndian
  when SDL_BYTEORDER == SDL_LIL_ENDIAN:
    const
      AUDIO_U16SYS* = AUDIO_U16LSB
      AUDIO_S16SYS* = AUDIO_S16LSB
      AUDIO_S32SYS* = AUDIO_S32LSB
      AUDIO_F32SYS* = AUDIO_F32LSB
  else:
    const
      AUDIO_U16SYS* = AUDIO_U16MSB
      AUDIO_S16SYS* = AUDIO_S16MSB
      AUDIO_S32SYS* = AUDIO_S32MSB
      AUDIO_F32SYS* = AUDIO_F32MSB

# Allow change flags
#
# Which audio format changes are allowed when opening a device.
const
  SDL_AUDIO_ALLOW_FREQUENCY_CHANGE* = 0x00000001
  SDL_AUDIO_ALLOW_FORMAT_CHANGE* = 0x00000002
  SDL_AUDIO_ALLOW_CHANNELS_CHANGE* = 0x00000004
  SDL_AUDIO_ALLOW_ANY_CHANGE* = (SDL_AUDIO_ALLOW_FREQUENCY_CHANGE or
      SDL_AUDIO_ALLOW_FORMAT_CHANGE or SDL_AUDIO_ALLOW_CHANNELS_CHANGE)

# Audio flags
type
  AudioCallback* = proc (userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.}
    ## This procedure is called when the audio device needs more data.
    ##
    ## `userdata` An application-specific parameter
    ## saved in `AudioSpec` object.
    ##
    ## `stream` A pointer to the audio data buffer.
    ##
    ## `len` The length of that buffer in bytes.
    ##
    ## Once the callback returns, the buffer will no longer be valid.
    ## Stereo samples are stored in a LRLRLR ordering.
    ##
    ## You can choose to avoid callbacks and use `queueAudio()` instead,
    ## if you like. Just open your audio device with a `nil` callback.

type
  AudioSpec* = object
    ## The calculated values in this object are calculated by `OpenAudio()`.
    ##
    ## For multi-channel audio, the default SDL channel mapping is:
    ## * 2:  FL FR                     (stereo)
    ## * 3:  FL FR LFE                 (2.1 surround)
    ## * 4:  FL FR BL BR               (quad)
    ## * 5:  FL FR FC BL BR            (quad + center)
    ## * 6:  FL FR FC LFE SL SR        (5.1 surround - last two can also be BL BR)
    ## * 7:  FL FR FC LFE BC SL SR     (6.1 surround)
    ## * 8:  FL FR FC LFE BL BR SL SR  (7.1 surround)
    freq*: cint             ## DSP frequency -- samples per second
    format*: AudioFormat    ## Audio data format
    channels*: uint8        ## Number of channels: 1 mono, 2 stereo
    silence*: uint8         ## Audio buffer silence value (calculated)
    samples*: uint16        ## Audio buffer size in samples (power of 2)
    padding*: uint16        ## Necessary for some compile environments
    size*: uint32           ## Audio buffer size in bytes (calculated)
    callback*: AudioCallback
      ## Callback that feeds the audio device (`nil` to use `queueAudio()`).
    userdata*: pointer
      ## Userdata passed to callback (ignored for `nil` callbacks).

  AudioCVT* {.packed.} = object
    ## A structure to hold a set of audio conversion filters and buffers.
    ##
    ## Note that various parts of the conversion pipeline can take advantage
    ## of SIMD operations (like SSE2, for example). `AudioCVT` doesn't
    ## require you to pass it aligned data, but can possibly run much faster
    ## if you set both its `buf` field to a pointer that is aligned to 16
    ## bytes, and its `len` field to something that's a multiple of 16,
    ## if possible.
    ##
    ## This structure is 84 bytes on 32-bit architectures, make sure GCC
    ## doesn't pad it out to 88 bytes to guarantee ABI compatibility between
    ## compilers. The next time we rev the ABI, make sure to size the ints
    ## and add padding.
    needed*: cint           ## Set to 1 if conversion possible
    src_format*: AudioFormat ## Source audio format
    dst_format*: AudioFormat ## Target audio format
    rate_incr*: cdouble     ## Rate conversion increment
    buf*: ptr uint8         ## Buffer to hold entire audio data
    len*: cint              ## Length of original audio buffer
    len_cvt*: cint          ## Length of converted audio buffer
    len_mult*: cint         ## buffer must be len*len_mult big
    len_ratio*: cdouble     ## Given len, final size is len*len_ratio
    filters*: array[10, AudioFilter] ## Filter list
    filter_index*: cint     ## Current audio conversion function

  AudioFilter* = proc (cvt: ptr AudioCVT; format: AudioFormat){.cdecl.}

type
  AudioStream = object
    ## a new audio conversion interface.
    ##
    ## The benefits vs `AudioCVT`:
    ## * it can handle resampling data in chunks without generating
    ##   artifacts, when it doesn't have the complete buffer available.
    ## * it can handle incoming data in any variable size.
    ## * You push data as you have it, and pull it when you need it.
    ##
    ## This is opaque to the outside world.
    cvt_before_resampling*: AudioCVT
    cvt_after_resampling*: AudioCVT
    queue*: pointer
    first_run*: Bool32
    staging_buffer*: ptr uint8
    staging_buffer_size*: cint
    staging_buffer_filled*: cint
    work_buffer_base*: ptr uint8  # maybe unaligned pointer from SDL_realloc().
    work_buffer_len*: cint
    src_sample_frame_size*: cint
    src_format*: AudioFormat
    src_channels*: uint8
    src_rate*: cint
    dst_sample_frame_size*: cint
    dst_format*: AudioFormat
    dst_channels*: uint8
    dst_rate*: cint
    rate_incr*: cdouble
    pre_resample_channels*: uint8
    packetlen*: cint
    resampler_padding_samples*: cint
    resampler_padding*: ptr cfloat
    resampler_state*: pointer
    resampler_func*: proc(stream: AudioStreamPtr,
                          inbuf: pointer, inbuflen: cint,
                          outbuf: pointer, outbuflen: cint): cint
    reset_resampler_func*: proc(stream: AudioStreamPtr)
    cleanup_resampler_func*: proc(stream: AudioStreamPtr)
  
  AudioStreamPtr* = ptr AudioStream
    ## (Available since SDL 2.0.7)
    ## A pointer to an `AudioStream`. Audio streams were added to SDL2
    ## in version 2.0.7, to provide an easier-to-use alternative to 
    ## `AudioCVT`.
    ##
    ## .. _SDL_AudioStream: https://wiki.libsdl.org/Tutorials/AudioStream
    ## .. _SDL_AudioCVT: https://wiki.libsdl.org/SDL_AudioCVT
    ##
    ## **See also:**
    ## * `newAudioStream proc<#newAudioStream,AudioFormat,uint8,cint,AudioFormat,uint8,cint>`_
    ## * `newAudioStream proc<#newAudioStream,AudioSpec,AudioSpec>`_
    ## * `put proc<#put,AudioStreamPtr,pointer,cint>`_
    ## * `get proc<#get,AudioStreamPtr,pointer,cint>`_
    ## * `available proc<#available,AudioStreamPtr>`_
    ## * `flush proc<#flush,AudioStreamPtr>`_
    ## * `clear proc<#clear,AudioStreamPtr>`_
    ## * `destroy proc<#destroy,AudioStreamPtr>`_

when false:

  when defined(GNUC):#__GNUC__):
    # This structure is 84 bytes on 32-bit architectures, make sure GCC doesn't
    #   pad it out to 88 bytes to guarantee ABI compatibility between compilers.
    #   vvv
    #   The next time we rev the ABI, make sure to size the ints and add padding.
    #
    const
      AudioCVT_PACKED* = x#__attribute__((packed))
  else:
    const
      AudioCVT_PACKED* = true


type
  AudioDeviceID* = uint32
  ## SDL Audio Device IDs.
  ##
  ## A successful call to `openAudio()` is always device id `1`, and legacy
  ## SDL audio APIs assume you want this device ID.
  ## `openAudioDevice()` calls always returns devices >= `2` on success.
  ## The legacy calls are good both for backwards compatibility and when you
  ## don't care about multiple, specific, or capture devices.

type
  AudioStatus* {.size: sizeof(cint).} = enum
    SDL_AUDIO_STOPPED = 0, SDL_AUDIO_PLAYING, SDL_AUDIO_PAUSED
const
  SDL_MIX_MAXVOLUME* = 128

when defined(SDL_Static):
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."
else:
  {.push callConv: cdecl, dynlib: LibName.}

proc getNumAudioDrivers*(): cint {.importc: "SDL_GetNumAudioDrivers".}
  ## Driver discovery procedures.
  ##
  ## These procedures return the list of built in audio drivers, in the
  ## order that they are normally initialized by default.

proc getAudioDriver*(index: cint): cstring {.importc: "SDL_GetAudioDriver".}
  ## Driver discovery procedures.
  ##
  ## These procedures return the list of built in audio drivers, in the
  ## order that they are normally initialized by default.

proc audioInit*(driver_name: cstring): cint {.importc: "SDL_AudioInit".}
  ## Initialization.
  ##
  ## `Internal:` These procedures are used internally, and should not be used
  ## unless you have a specific need to specify the audio driver you want to
  ## use.  You should normally use `init()` or `initSubSystem()`.

proc audioQuit*() {.importc: "SDL_AudioQuit".}
  ## Cleanup.
  ##
  ## `Internal`: These procedures are used internally, and should not be used
  ## unless you have a specific need to specify the audio driver you want to
  ## use.  You should normally use `init()` or `initSubSystem()`.

proc getCurrentAudioDriver*(): cstring {.importc: "SDL_GetCurrentAudioDriver".}
  ## This procedure returns the name of the current audio driver, or `nil`
  ## if no driver has been initialized.

proc openAudio*(desired: ptr AudioSpec; obtained: ptr AudioSpec): SDL_Return {.
  importc: "SDL_OpenAudio", discardable.}
  ## This procedure opens the audio device with the desired parameters, and
  ## returns `0` if successful, placing the actual hardware parameters in the
  ## object pointed to by `obtained`.  If `obtained` is `nil`, the audio
  ## data passed to the callback procedure will be guaranteed to be in the
  ## requested format, and will be automatically converted to the hardware
  ## audio format if necessary.  This procedure returns `-1` if it failed
  ## to open the audio device, or couldn't set up the audio thread.
  ##
  ## When filling in the `desired` audio spec object,
  ## * `desired.freq` should be the desired audio frequency
  ##   in samples-per- second.
  ## * `desired.format` should be the desired audio format.
  ## * `desired.samples` is the desired size of the audio buffer,
  ##   in samples.  This number should be a power of two, and may be adjusted
  ##   by the audio driver to a value more suitable for the hardware.
  ##   Good values seem to range between `512` and `8096` inclusive, depending
  ##   on the  application and CPU speed.  Smaller values yield faster
  ##   response time, but can lead to underflow if the application is doing
  ##   heavy processing and cannot fill the audio buffer in time.  A stereo
  ##   sample consists of both right and left channels in LR ordering.
  ##
  ##   Note that the number of samples is directly related to time by the
  ##   following formula:
  ##
  ##   `ms = (samples*1000)/freq`
  ##
  ## * `desired.size` is the size in bytes of the audio buffer, and is
  ##   calculated by `openAudio()`.
  ## * `desired.silence` is the value used to set the buffer to silence,
  ##   and is calculated by `openAudio()`.
  ## * `desired.callback` should be set to a procedure that will be called
  ##   when the audio device is ready for more data.  It is passed a pointer
  ##   to the audio buffer, and the length in bytes of the audio buffer.
  ##   This procedure usually runs in a separate thread, and so you should
  ##   protect data structures that it accesses by calling `lockAudio()`
  ##   and `unlockAudio()` in your code. Alternately, you may pass a `nil`
  ##   pointer here, and call `queueAudio()` with some frequency, to queue
  ##   more audio samples to be played (or for capture devices, call
  ##   `sdl.dequeueAudio()` with some frequency, to obtain audio samples).
  ## * `desired.userdata` is passed as the first parameter to your callback
  ##   procedure. If you passed a `nil` callback, this value is ignored.
  ##
  ## The audio device starts out playing silence when it's opened, and should
  ## be enabled for playing by calling `pauseAudio(0)` when you are ready
  ## for your audio callback procedure to be called.  Since the audio driver
  ## may modify the requested size of the audio buffer, you should allocate
  ## any local mixing buffers after you open the audio device.

proc getNumAudioDevices*(iscapture: cint): cint {.
  importc: "SDL_GetNumAudioDevices".}
  ## Get the number of available devices exposed by the current driver.
  ##
  ## Only valid after a successfully initializing the audio subsystem.
  ## Returns `-1` if an explicit list of devices can't be determined; this is
  ## not an error. For example, if SDL is set up to talk to a remote audio
  ## server, it can't list every one available on the Internet, but it will
  ## still allow a specific host to be specified to `openAudioDevice()`.
  ##
  ## In many common cases, when this procedure returns a value <= `0`,
  ## it can still  successfully open the default device (`nil` for first
  ## argument of `openAudioDevice()`).

proc getAudioDeviceName*(index: cint; iscapture: cint): cstring {.
  importc: "SDL_GetAudioDeviceName".}
  ## Get the human-readable name of a specific audio device.
  ##
  ## Must be a value between `0` and `(number of audio devices-1)`.
  ## Only valid after a successfully initializing the audio subsystem.
  ## The values returned by this procedure reflect the latest call to
  ## `getNumAudioDevices()`; recall that procedure to redetect available
  ## hardware.
  ##
  ## The string returned by this procedure is UTF-8 encoded, read-only, and
  ## managed internally. You are not to free it. If you need to keep the
  ## string for any length of time, you should make your own copy of it, as it
  ## will be invalid next time any of several other SDL prodedures is called.

proc openAudioDevice*(device: cstring; iscapture: cint;
                      desired: ptr AudioSpec;
                      obtained: ptr AudioSpec;
                      allowed_changes: cint): AudioDeviceID {.
                      importc: "SDL_OpenAudioDevice".}
  ## Open a specific audio device.
  ##
  ## Passing in a device name of `nil` requests the most reasonable default
  ## (and is equivalent to calling `openAudio()`).
  ##
  ## The device name is a UTF-8 string reported by `getAudioDeviceName()`,
  ## but some drivers allow arbitrary and driver-specific strings, such as a
  ## hostname/IP address for a remote audio server, or a filename in the
  ## diskaudio driver.
  ##
  ## `Return` `0` on error, a valid device ID that is >= `2` on success.
  ##
  ## `openAudio()`, unlike this procedure, always acts on device ID `1`.


proc getAudioStatus*(): AudioStatus {.importc: "SDL_GetAudioStatus".}
  ## Get the current audio state.

proc getAudioDeviceStatus*(dev: AudioDeviceID): AudioStatus {.
  importc: "SDL_GetAudioDeviceStatus".}
  ## Get the current audio state.

proc getQueuedAudioSize*(dev: AudioDeviceID): uint32 {.
  importc: "SDL_GetQueuedAudioSize".}
  ## Get the number of bytes of still-queued audio.
  ##
  ## `For playback device:`
  ## This is the number of bytes that have been queued for playback with
  ## `sdl.queueAudio()`, but have not yet been sent to the hardware. This
  ## number may shrink at any time, so this only informs of pending data.
  ##
  ## Once we've sent it to the hardware, this procedure can not decide the
  ## exact byte boundary of what has been played. It's possible that we just
  ## gave the hardware several kilobytes right before you called this
  ## procedure, but it hasn't played any of it yet, or maybe half of it, etc.
  ##
  ## `For capture device:`
  ## This is the number of bytes that have been captured by the device and
  ## are waiting for you to dequeue. This number may grow at any time, so
  ## this only informs of the lower-bound of available data.
  ##
  ## You may not queue audio on a device that is using an application-supplied
  ## callback; calling this procedure on such a device always returns `0`.
  ## You have to queue audio with `sdl.queueAudio()` /
  ## `sdl.dequeueAudio()`, or use the audio callback,  but not both.
  ##
  ## You should not call `lockAudio()` on the device before querying; SDL
  ## handles locking internally for this procedure.
  ##
  ## `dev` The device ID of which we will query queued audio size.
  ##
  ## `Return` number of bytes (not samples!) of queued audio.
  ##
  ## **See also:**
  ## * `queueAudio proc<#queueAudio,AudioDeviceID,pointer,uint32>`_

proc queueAudio*(dev: AudioDeviceID, data: pointer, len: uint32): SDL_Return {.
  importc: "SDL_QueueAudio", discardable.}
  ## Queue more audio on non-callback devices.
  ##
  ## (If you are looking to retrieve queued audio from a non-callback capture
  ## device, you want `sdl.dequeueAudio()` instead. This will return `-1`
  ## to signify an error if you use it with capture devices.)
  ##
  ## SDL offers two ways to feed audio to the device: you can either supply a
  ## callback that SDL triggers with some frequency to obtain more audio
  ## (pull method), or you can supply no callback, and then SDL will expect
  ## you to supply data at regular intervals (push method) with this procedure.
  ##
  ## There are no limits on the amount of data you can queue, short of
  ## exhaustion of address space. Queued data will drain to the device as
  ## necessary without further intervention from you. If the device needs
  ## audio but there is not enough queued, it will play silence to make up
  ## the difference. This means you will have skips in your audio playback
  ## if you aren't routinely queueing sufficient data.
  ##
  ## This procedure copies the supplied data, so you are safe to free it when
  ## the procedure returns. This procedure is thread-safe, but queueing to the
  ## same device from two threads at once does not promise which buffer will
  ## be queued first.
  ##
  ## You may not queue audio on a device that is using an application-supplied
  ## callback; doing so returns an error. You have to use the audio callback
  ## or queue audio with this procedure, but not both.
  ##
  ## You should not call `lockAudio()` on the device before queueing; SDL
  ## handles locking internally for this procedure.
  ##
  ## `dev` The device ID to which we will queue audio.
  ##
  ## `data` The data to queue to the device for later playback.
  ##
  ## `len` The number of bytes (not samples!) to which (data) points.
  ##
  ## `Return` `0` on success, `-1` on error.
  ##
  ## **See also:**
  ## * `getQueuedAudioSize proc<#getQueuedAudioSize,AudioDeviceID>`_

proc dequeueAudio*(dev: AudioDeviceID, data: pointer, len: uint32): cint {.
  importc: "SDL_DequeueAudio".}
  ## Dequeue more audio on non-callback devices.
  ##
  ## (If you are looking to queue audio for output on a non-callback playback
  ## device, you want `sdl.queueAudio()` instead. This will always return
  ## `0` if you use it with playback devices.)
  ##
  ## SDL offers two ways to retrieve audio from a capture device: you can
  ## either supply a callback that SDL triggers with some frequency as the
  ## device records more audio data, (push method), or you can supply no
  ## callback, and then SDL will expect you to retrieve data at regular
  ## intervals (pull method) with this procedure.
  ##
  ## There are no limits on the amount of data you can queue, short of
  ## exhaustion of address space. Data from the device will keep queuing as
  ## necessary without further intervention from you. This means you will
  ## eventually run out of memory if you aren't routinely dequeueing data.
  ##
  ## Capture devices will not queue data when paused; if you are expecting
  ## to not need captured audio for some length of time, use
  ## `sdl.pauseAudioDevice()` to stop the capture device from queueing more
  ## data. This can be useful during, say, level loading times. When
  ## unpaused, capture devices will start queueing data from that point,
  ## having flushed any capturable data available while paused.
  ##
  ## This procedure is thread-safe, but dequeueing from the same device from
  ## two threads at once does not promise which thread will dequeued data
  ## first.
  ##
  ## You may not dequeue audio from a device that is using an
  ## application-supplied callback; doing so returns an error. You have to use
  ## the audio callback, or dequeue audio with this procedure, but not both.
  ##
  ## You should not call `sdl.lockAudio()` on the device before queueing;
  ## SDL handles locking internally for this procedure.
  ##
  ## `dev` The device ID from which we will dequeue audio.
  ##
  ## `data` A pointer into where audio data should be copied.
  ##
  ## `len` The number of bytes (not samples!) to which (data) points.
  ##
  ## `Return` number of bytes dequeued, which could be less than requested.
  ##
  ## **See also:**
  ## * `getQueuedAudioSize proc<#getQueuedAudioSize,AudioDeviceID>`_

proc pauseAudio*(pause_on: cint) {.importc: "SDL_PauseAudio".}
  ## Pause audio procedures.
  ##
  ## These procedures pause and unpause the audio callback processing.
  ## They should be called with a parameter of `0` after opening the audio
  ## device to start playing sound.  This is so you can safely initialize
  ## data for your callback procedure after opening the audio device.
  ## Silence will be written to the audio device during the pause.

proc pauseAudioDevice*(dev: AudioDeviceID; pause_on: cint) {.
  importc: "SDL_PauseAudioDevice".}
  ## Pause audio procedures.
  ##
  ## These procedures pause and unpause the audio callback processing.
  ## They should be called with a parameter of `0` after opening the audio
  ## device to start playing sound.  This is so you can safely initialize
  ## data for your callback procedure after opening the audio device.
  ## Silence will be written to the audio device during the pause.

proc loadWAV_RW*(src: ptr RWops; freesrc: cint;
                 spec: ptr AudioSpec; audio_buf: ptr ptr uint8;
                 audio_len: ptr uint32): ptr AudioSpec {.
  importc: "SDL_LoadWAV_RW".}
  ## Load the audio data of a WAVE file into memory.
  ##
  ## Loading a WAVE file requires `src`, `spec`, `audio_buf` and
  ## `audio_len` to be valid pointers. The entire data portion of the file
  ## is then loaded into memory and decoded if necessary.
  ##
  ## If `freesrc` is non-zero, the data source gets automatically closed and
  ## freed before the procedure returns.
  ##
  ## Supported are RIFF WAVE files with the formats PCM
  ## (8, 16, 24, and 32 bits), IEEE Float (32 bits), Microsoft ADPCM and IMA
  ## ADPCM (4 bits), and A-law and µ-law (8 bits). Other formats are currently
  ## unsupported and cause an error.
  ##
  ## If this procedure succeeds, the pointer returned by it is equal to
  ## `spec` and the pointer to the audio data allocated by the procedure is
  ## written to `audio_buf` and its length in bytes to `audio_len`.
  ## The `sdl.AudioSpec` members `freq`, `channels`, and `format` are
  ## set to the values of the audio data in the buffer. The `samples` member
  ## is set to a sane default and all others are set to zero.
  ##
  ## It's necessary to use `sdl.freeWAV()` to free the audio data returned
  ## in `audio_buf` when it is no longer used.
  ##
  ## Because of the underspecification of the Waveform format, there are many
  ## problematic files in the wild that cause issues with strict decoders. To
  ## provide compatibility with these files, this decoder is lenient in regards
  ## to the truncation of the file, the fact chunk, and the size of the RIFF
  ## chunk. The hints `sdl.HINT_WAVE_RIFF_CHUNK_SIZE`,
  ## `sdl.HINT_WAVE_TRUNCATION`, and `sdl.HINT_WAVE_FACT_CHUNK`
  ## can be used to tune the behavior of the loading process.
  ##
  ## Any file that is invalid (due to truncation, corruption, or wrong values
  ## in the headers), too big, or unsupported causes an error. Additionally,
  ## any critical I/O error from the data source will terminate the loading
  ## process with an error. The procedure returns `nil` on error and in all
  ## cases (with the exception of `src` being `nil`), an appropriate error
  ## message will be set.
  ##
  ## It is required that the data source supports seeking.
  ##
  ## Example:
  ##
  ## .. code-block:: nim
  ##   sdl.loadWAV_RW(sdl.rwFromFile("sample.wav", "rb"), 1, ...)
  ##
  ## `src` The data source with the WAVE data
  ##
  ## `freesrc` A integer value that makes the procedure close the data source
  ## if non-zero
  ##
  ## `spec` A pointer filled with the audio format of the audio data
  ##
  ## `audio_buf` A pointer filled with the audio data allocated by the
  ## procedure
  ##
  ## `audio_len` A pointer filled with the length of the audio data buffer
  ## in bytes
  ##
  ## `Return` `nil` on error, or non-`nil` on success.

template loadWAV*(file: string, spec: ptr AudioSpec, audio_buf: ptr ptr uint8, audio_len: ptr uint32): ptr AudioSpec =
  ## Loads a WAV from a file.
  ## Compatibility convenience template.
  loadWAV_RW(rwFromFile(file, "rb"), 1, spec, audio_buf, audio_len)

proc freeWAV*(audio_buf: ptr uint8) {.importc: "SDL_FreeWAV".}
  ## This procedure frees data previously allocated with `loadWAV_RW()`

proc buildAudioCVT*(cvt: ptr AudioCVT; src_format: AudioFormat;
                        src_channels: uint8; src_rate: cint;
                        dst_format: AudioFormat; dst_channels: uint8;
                        dst_rate: cint): cint {.
  importc: "SDL_BuildAudioCVT".}
  ## This procedure takes a source format and rate and a destination format
  ## and rate, and initializes the `cvt` object with information needed
  ## by `convertAudio()` to convert a buffer of audio data from one format
  ## to the other. An unsupported format causes an error and `-1` will be
  ## returned.
  ##
  ## `Return` `0` if no conversion is needed,
  ## `1` if the audio filter is set up, or `-1` on error.

proc convertAudio*(cvt: ptr AudioCVT): SDL_Return {.importc: "SDL_ConvertAudio", discardable.}
  ## Once you have initialized the `cvt` object using `buildAudioCVT()`,
  ## created an audio buffer `cvt.buf`, and filled it with `cvt.len` bytes
  ## of audio data in the source format, this procedure will convert it
  ## in-place to the desired format.
  ##
  ## The data conversion may expand the size of the audio data, so the buffer
  ## `cvt.buf` should be allocated after the `cvt` object is initialized
  ## by `buildAudioCVT()`, and should be `cvt.len*cvt.len_mult` bytes long.
  ##
  ## `Return` `0` on success or `-1` if `cvt.buf` is `nil`.

proc mixAudio*(dst: ptr uint8; src: ptr uint8; len: uint32; volume: cint) {.
  importc: "SDL_MixAudio".}
  ## This takes two audio buffers of the playing audio format and mixes
  ## them, performing addition, volume adjustment, and overflow clipping.
  ## The volume ranges from `0 - 128`, and should be set to `MIX_MAXVOLUME`
  ## for full audio volume.  Note this does not change hardware volume.
  ## This is provided for convenience -- you can mix your own audio data.

proc mixAudioFormat*(dst: ptr uint8; src: ptr uint8;
                     format: AudioFormat; len: uint32; volume: cint) {.
  importc: "SDL_MixAudioFormat".}
  ## This works like `mixAudio()`, but you specify the audio format instead
  ## of using the format of audio device `1`.
  ## Thus it can be used when no audio device is open at all.

proc lockAudio*() {.importc: "SDL_LockAudio".}
  ## Audio lock procedure.
  ##
  ## The lock manipulated by these procedures protects the callback procedure.
  ## During a `lockAudio()`/`unlockAudio()` pair, you can be guaranteed
  ## that the callback procedure is not running.  Do not call these from the
  ## callback procedure or you will cause deadlock.

proc lockAudioDevice*(dev: AudioDeviceID) {.importc: "SDL_LockAudioDevice".}
  ## Audio lock procedure.
  ##
  ## The lock manipulated by these procedures protects the callback procedure.
  ## During a `lockAudio()`/`unlockAudio()` pair, you can be guaranteed
  ## that the callback procedure is not running.  Do not call these from the
  ## callback procedure or you will cause deadlock.

proc unlockAudio*() {.importc: "SDL_UnlockAudio".}
  ## Audio unlock procedure.
  ##
  ## The lock manipulated by these procedures protects the callback procedure.
  ## During a `lockAudio()`/`unlockAudio()` pair, you can be guaranteed
  ## that the callback procedure is not running.  Do not call these from the
  ## callback procedure or you will cause deadlock.

proc unlockAudioDevice*(dev: AudioDeviceID) {.importc: "SDL_UnlockAudioDevice".}
  ## Audio unlock procedure.
  ##
  ## The lock manipulated by these procedures protects the callback procedure.
  ## During a `lockAudio()`/`unlockAudio()` pair, you can be guaranteed
  ## that the callback procedure is not running.  Do not call these from the
  ## callback procedure or you will cause deadlock.

proc closeAudio*() {.importc: "SDL_CloseAudio".}
  ## This procedure shuts down audio processing and closes the audio device.

proc closeAudioDevice*(dev: AudioDeviceID) {.importc: "SDL_CloseAudioDevice".}
  ## This procedure shuts down audio processing and closes the audio device.


proc newAudioStream*(
  src_format: AudioFormat;
  src_channels: uint8;
  src_rate: cint;
  dst_format: AudioFormat;
  dst_channels: uint8;
  dst_rate: cint): AudioStreamPtr {.importc: "SDL_NewAudioStream".}
  ## (Available since SDL 2.0.7)
  ## Create a new audio stream. return 0 on success, or -1
  ## on error.
  ## 
  ## Parameters:
  ## * `src_format` The format of the source audio
  ## * `src_channels` The number of channels of the source audio
  ## * `src_rate` The sampling rate of the source audio
  ## * `dst_format` The format of the desired audio output
  ## * `dst_channels` The number of channels of the desired audio output
  ## * `dst_rate The` sampling rate of the desired audio output
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_
  ## * `newAudioStream proc<#newAudioStream,AudioSpec,AudioSpec>`_

proc newAudioStream*(srcSpec, destSpec: AudioSpec): AudioStreamPtr =
  ## (Available since SDL 2.0.7)
  ## Create a new audio stream that converts from `srcSpec` to `destSpec`.
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_
  ## * `newAudioStream proc<#newAudioStream,AudioFormat,uint8,cint,AudioFormat,uint8,cint>`_
  newAudioStream(
    srcSpec.format, srcSpec.channels, srcSpec.freq,
    destSpec.format, destSpec.channels, destSpec.freq)

proc put*(
  stream: AudioStreamPtr,
  buf: pointer,
  len: cint): SDL_Return {.importc: "SDL_AudioStreamPut", discardable.}
  ## (Available since SDL 2.0.7)
  ## Add data to be converted/resampled to the stream.Returns 0 on success, or -1 on error.
  ##
  ## Returns 0 on success, or -1 on error.
  ##
  ## Parameters:
  ## * `stream` The stream the audio data is being added to
  ## * `buf` A pointer to the audio data to add
  ## * `len` The number of bytes to write to the stream
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc get*(
  stream: AudioStreamPtr,
  buf: pointer,
  len: cint): cint {.importc: "SDL_AudioStreamGet".}
  ## (Available since SDL 2.0.7)
  ## Get converted/resampled data from the stream.
  ## Returns the number of bytes read from the stream, or -1 on error.
  ## 
  ## Parameters:
  ## * `stream` The stream the audio is being requested from
  ## * `buf` A buffer to fill with audio data
  ## * `len` The maximum number of bytes to fill
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc available*(stream: AudioStreamPtr): cint {.
  importc: "SDL_AudioStreamAvailable".}
  ## (Available since SDL 2.0.7)
  ## Get the number of converted/resampled bytes available (BYTES, not samples!).
  ## The stream may be buffering data behind the scenes until it has enough to
  ## resample correctly, so this number might be lower than what you expect, or even
  ## be zero. Add more data or flush the stream if you need the data now.
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc flush*(stream: AudioStreamPtr): SDL_Return {.importc: "SDL_AudioStreamFlush", discardable.}
  ## (Available since SDL 2.0.7)
  ## Tell the stream that you're done sending data, and anything being buffered
  ## should be converted/resampled and made available immediately. Returns 0
  ## on success, -1 on error.
  ##
  ## It is legal to add more data to a stream after flushing, but there will
  ## be audio gaps in the output. Generally this is intended to signal the
  ## end of input, so the complete output becomes available.
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc clear*(stream: AudioStreamPtr) {.importc: "SDL_AudioStreamClear".}
  ## (Available since SDL 2.0.7)
  ## Clear any pending data in the stream without converting it.
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc destroy*(stream: AudioStreamPtr) {.importc: "SDL_FreeAudioStream".}
  ## (Available since SDL 2.0.7)
  ## Free an audio stream.
  ##
  ## **See also:**
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_


# vi: set ts=4 sw=4 expandtab:
when not defined(SDL_Static):
  {.pop.}
