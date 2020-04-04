import sdl2
#
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
#
#*
#   \file SDL_audio.h
#
#   Access to the raw audio mixing buffer for the SDL library.
#

# Set up for C function definitions, even when using C++
#*
#   \brief Audio format flags.
#
#   These are what the 16 bits in AudioFormat currently mean...
#   (Unspecified bits are always zero).
#
#   \verbatim
#    ++-----------------------sample is signed if set
#    ||
#    ||       ++-----------sample is bigendian if set
#    ||       ||
#    ||       ||          ++---sample is float if set
#    ||       ||          ||
#    ||       ||          || +---sample bit size---+
#    ||       ||          || |                     |
#    15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
#    \endverbatim
#
#   There are macros in SDL 2.0 and later to query these bits.
#
type
  AudioFormat* = uint16
#*
#   \name Audio flags
#
# @{
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

#*
#   \name Audio format flags
#
#   Defaults to LSB byte order.
#
# @{
const
  AUDIO_U8* = 0x00000008    #*< Unsigned 8-bit samples
  AUDIO_S8* = 0x00008008    #*< Signed 8-bit samples
  AUDIO_U16LSB* = 0x00000010 #*< Unsigned 16-bit samples
  AUDIO_S16LSB* = 0x00008010 #*< Signed 16-bit samples
  AUDIO_U16MSB* = 0x00001010 #*< As above, but big-endian byte order
  AUDIO_S16MSB* = 0x00009010 #*< As above, but big-endian byte order
  AUDIO_U16* = AUDIO_U16LSB
  AUDIO_S16* = AUDIO_S16LSB

# @}
#*
#   \name int32 support
#
# @{
const
  AUDIO_S32LSB* = 0x00008020 #*< 32-bit integer samples
  AUDIO_S32MSB* = 0x00009020 #*< As above, but big-endian byte order
  AUDIO_S32* = AUDIO_S32LSB
# @}
#*
#   \name float32 support
#
# @{
const
  AUDIO_F32LSB* = 0x00008120 #*< 32-bit floating point samples
  AUDIO_F32MSB* = 0x00009120 #*< As above, but big-endian byte order
  AUDIO_F32* = AUDIO_F32LSB
# @}
#*
#   \name Native audio byte ordering
#
# @{
when false:
  ## TODO system.cpuEndian
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
# @}
#*
#   \name Allow change flags
#
#   Which audio format changes are allowed when opening a device.
#
# @{
const
  SDL_AUDIO_ALLOW_FREQUENCY_CHANGE* = 0x00000001
  SDL_AUDIO_ALLOW_FORMAT_CHANGE* = 0x00000002
  SDL_AUDIO_ALLOW_CHANNELS_CHANGE* = 0x00000004
  SDL_AUDIO_ALLOW_ANY_CHANGE* = (SDL_AUDIO_ALLOW_FREQUENCY_CHANGE or
      SDL_AUDIO_ALLOW_FORMAT_CHANGE or SDL_AUDIO_ALLOW_CHANNELS_CHANGE)
# @}
# @}
# Audio flags
#*
#   This function is called when the audio device needs more data.
#
#   \param userdata An application-specific parameter saved in
#                   the AudioSpec structure
#   \param stream A pointer to the audio data buffer.
#   \param len    The length of that buffer in bytes.
#
#   Once the callback returns, the buffer will no longer be valid.
#   Stereo samples are stored in a LRLRLR ordering.
#
type
  AudioCallback* = proc (userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.}
#*
#   The calculated values in this structure are calculated by SDL_OpenAudio().
#
type
  AudioSpec* = object
    freq*: cint             #*< DSP frequency -- samples per second
    format*: AudioFormat #*< Audio data format
    channels*: uint8        #*< Number of channels: 1 mono, 2 stereo
    silence*: uint8         #*< Audio buffer silence value (calculated)
    samples*: uint16        #*< Audio buffer size in samples (power of 2)
    padding*: uint16        #*< Necessary for some compile environments
    size*: uint32           #*< Audio buffer size in bytes (calculated)
    callback*: AudioCallback
    userdata*: pointer

  AudioCVT* {.packed.} = object
    needed*: cint           #*< Set to 1 if conversion possible
    src_format*: AudioFormat #*< Source audio format
    dst_format*: AudioFormat #*< Target audio format
    rate_incr*: cdouble     #*< Rate conversion increment
    buf*: ptr uint8         #*< Buffer to hold entire audio data
    len*: cint              #*< Length of original audio buffer
    len_cvt*: cint          #*< Length of converted audio buffer
    len_mult*: cint         #*< buffer must be len*len_mult big
    len_ratio*: cdouble     #*< Given len, final size is len*len_ratio
    filters*: array[10, AudioFilter] #*< Filter list
    filter_index*: cint     #*< Current audio conversion function

  AudioFilter* = proc (cvt: ptr AudioCVT; format: AudioFormat){.cdecl.}

type
  AudioStream = object
    # The AudioStream object. SDL2 doesn't make the contents of this object
    # visible to users of the C API, so we don't make it visible either.
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
    resampler_func*: proc(stream: AudioStreamPtr, inbuf: pointer, inbuflen: cint, outbuf: pointer, outbuflen: cint): cint
    reset_resampler_func*: proc(stream: AudioStreamPtr)
    cleanup_resampler_func*: proc(stream: AudioStreamPtr)
  
  AudioStreamPtr* = ptr AudioStream
    ## (Available since SDL 2.0.7)
    ## A pointer to an `SDL_AudioStream`_. Audio streams were added to SDL2
    ## in version 2.0.7, to provide an easier-to-use alternative to 
    ## `SDL_AudioCVT`_.
    ##
    ## .. _SDL_AudioStream: https://wiki.libsdl.org/Tutorials/AudioStream
    ## .. _SDL_AudioCVT: https://wiki.libsdl.org/SDL_AudioCVT
    ##
    ## See Also:
    ## * `newAudioStream proc<#newAudioStream,AudioFormat,uint8,cint,AudioFormat,uint8,cint>`_
    ## * `newAudioStream proc<#newAudioStream,AudioSpec,AudioSpec>`_
    ## * `put proc<#put,AudioStreamPtr,pointer,cint>`_
    ## * `get proc<#get,AudioStreamPtr,pointer,cint>`_
    ## * `available proc<#available,AudioStreamPtr>`_
    ## * `flush proc<#flush,AudioStreamPtr>`_
    ## * `clear proc<#clear,AudioStreamPtr>`_
    ## * `destroy proc<#destroy,AudioStreamPtr>`_

when false:
  #*
  #   A structure to hold a set of audio conversion filters and buffers.
  #
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

#*
#   SDL Audio Device IDs.
#
#   A successful call to SDL_OpenAudio() is always device id 1, and legacy
#   SDL audio APIs assume you want this device ID. SDL_OpenAudioDevice() calls
#   always returns devices >= 2 on success. The legacy calls are good both
#   for backwards compatibility and when you don't care about multiple,
#   specific, or capture devices.
#
type
  AudioDeviceID* = uint32

#*
#   \name Audio state
#
#   Get the current audio state.
#
# @{
type
  AudioStatus* {.size: sizeof(cint).} = enum
    SDL_AUDIO_STOPPED = 0, SDL_AUDIO_PLAYING, SDL_AUDIO_PAUSED
const
  SDL_MIX_MAXVOLUME* = 128

when defined(SDL_Static):
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."
else:
  {.push callConv: cdecl, dynlib: LibName.}

# Function prototypes
#*
#   \name Driver discovery functions
#
#   These functions return the list of built in audio drivers, in the
#   order that they are normally initialized by default.
#
# @{
proc getNumAudioDrivers*(): cint {.
  importc: "SDL_GetNumAudioDrivers".}
proc getAudioDriver*(index: cint): cstring {.
  importc: "SDL_GetAudioDriver".}
# @}
#*
#   \name Initialization and cleanup
#
#   \internal These functions are used internally, and should not be used unless
#             you have a specific need to specify the audio driver you want to
#             use.  You should normally use SDL_Init() or SDL_InitSubSystem().
#
# @{
proc audioInit*(driver_name: cstring): cint {.
  importc: "SDL_AudioInit".}
proc audioQuit*() {.
  importc: "SDL_AudioQuit".}
# @}
#*
#   This function returns the name of the current audio driver, or NULL
#   if no driver has been initialized.
#
proc getCurrentAudioDriver*(): cstring {.
  importc: "SDL_GetCurrentAudioDriver".}
#*
#   This function opens the audio device with the desired parameters, and
#   returns 0 if successful, placing the actual hardware parameters in the
#   structure pointed to by \c obtained.  If \c obtained is NULL, the audio
#   data passed to the callback function will be guaranteed to be in the
#   requested format, and will be automatically converted to the hardware
#   audio format if necessary.  This function returns -1 if it failed
#   to open the audio device, or couldn't set up the audio thread.
#
#   When filling in the desired audio spec structure,
#     - \c desired->freq should be the desired audio frequency in samples-per-
#       second.
#     - \c desired->format should be the desired audio format.
#     - \c desired->samples is the desired size of the audio buffer, in
#       samples.  This number should be a power of two, and may be adjusted by
#       the audio driver to a value more suitable for the hardware.  Good values
#       seem to range between 512 and 8096 inclusive, depending on the
#       application and CPU speed.  Smaller values yield faster response time,
#       but can lead to underflow if the application is doing heavy processing
#       and cannot fill the audio buffer in time.  A stereo sample consists of
#       both right and left channels in LR ordering.
#       Note that the number of samples is directly related to time by the
#       following formula:  \code ms = (samples*1000)/freq \endcode
#     - \c desired->size is the size in bytes of the audio buffer, and is
#       calculated by SDL_OpenAudio().
#     - \c desired->silence is the value used to set the buffer to silence,
#       and is calculated by SDL_OpenAudio().
#     - \c desired->callback should be set to a function that will be called
#       when the audio device is ready for more data.  It is passed a pointer
#       to the audio buffer, and the length in bytes of the audio buffer.
#       This function usually runs in a separate thread, and so you should
#       protect data structures that it accesses by calling SDL_LockAudio()
#       and SDL_UnlockAudio() in your code.
#     - \c desired->userdata is passed as the first parameter to your callback
#       function.
#
#   The audio device starts out playing silence when it's opened, and should
#   be enabled for playing by calling \c SDL_PauseAudio(0) when you are ready
#   for your audio callback function to be called.  Since the audio driver
#   may modify the requested size of the audio buffer, you should allocate
#   any local mixing buffers after you open the audio device.
#
proc openAudio*(desired: ptr AudioSpec; obtained: ptr AudioSpec): cint {.
  importc: "SDL_OpenAudio".}

#*
#   Get the number of available devices exposed by the current driver.
#   Only valid after a successfully initializing the audio subsystem.
#   Returns -1 if an explicit list of devices can't be determined; this is
#   not an error. For example, if SDL is set up to talk to a remote audio
#   server, it can't list every one available on the Internet, but it will
#   still allow a specific host to be specified to SDL_OpenAudioDevice().
#
#   In many common cases, when this function returns a value <= 0, it can still
#   successfully open the default device (NULL for first argument of
#   SDL_OpenAudioDevice()).
#
proc getNumAudioDevices*(iscapture: cint): cint {.
  importc: "SDL_GetNumAudioDevices".}
#*
#   Get the human-readable name of a specific audio device.
#   Must be a value between 0 and (number of audio devices-1).
#   Only valid after a successfully initializing the audio subsystem.
#   The values returned by this function reflect the latest call to
#   SDL_GetNumAudioDevices(); recall that function to redetect available
#   hardware.
#
#   The string returned by this function is UTF-8 encoded, read-only, and
#   managed internally. You are not to free it. If you need to keep the
#   string for any length of time, you should make your own copy of it, as it
#   will be invalid next time any of several other SDL functions is called.
#
proc getAudioDeviceName*(index: cint; iscapture: cint): cstring {.
  importc: "SDL_GetAudioDeviceName".}
#*
#   Open a specific audio device. Passing in a device name of NULL requests
#   the most reasonable default (and is equivalent to calling SDL_OpenAudio()).
#
#   The device name is a UTF-8 string reported by SDL_GetAudioDeviceName(), but
#   some drivers allow arbitrary and driver-specific strings, such as a
#   hostname/IP address for a remote audio server, or a filename in the
#   diskaudio driver.
#
#   \return 0 on error, a valid device ID that is >= 2 on success.
#
#   SDL_OpenAudio(), unlike this function, always acts on device ID 1.
#
proc openAudioDevice*(device: cstring; iscapture: cint;
                      desired: ptr AudioSpec;
                      obtained: ptr AudioSpec; allowed_changes: cint): AudioDeviceID {.
  importc: "SDL_OpenAudioDevice".}

proc getAudioStatus*(): AudioStatus {.
  importc: "SDL_GetAudioStatus".}
proc getAudioDeviceStatus*(dev: AudioDeviceID): AudioStatus {.
  importc: "SDL_GetAudioDeviceStatus".}

#*
#   \brief Use this function to get the number of bytes of still-queued audio.
#
#   \param dev the device ID of which we will query queued audio size
#
#   \return the number of bytes (not samples!) of queued audio.
#
#   \sa SDL_GetQueuedAudioSize()
#
proc getQueuedAudioSize*(dev: AudioDeviceID): uint32 {.
  importc: "SDL_GetQueuedAudioSize".}

#*
#   \brief Use this function to queue more audio on non-callback devices.
#
#   \param dev  the device ID to which we will queue audio
#   \param data the data to queue to the device for later playback
#   \param len  the number of bytes (not samples!) to which (data) points
#
#   \return 0 on success or a negative error code on failure; call SDL_GetError() for more information.
#
#   \sa SDL_QueueAudio()
#
proc queueAudio*(dev: AudioDeviceID, data: pointer, len: uint32): cint {.
  importc: "SDL_QueueAudio".}

# @}
# Audio State
#*
#   \name Pause audio functions
#
#   These functions pause and unpause the audio callback processing.
#   They should be called with a parameter of 0 after opening the audio
#   device to start playing sound.  This is so you can safely initialize
#   data for your callback function after opening the audio device.
#   Silence will be written to the audio device during the pause.
#
# @{
proc pauseAudio*(pause_on: cint) {.
  importc: "SDL_PauseAudio".}
proc pauseAudioDevice*(dev: AudioDeviceID; pause_on: cint) {.
  importc: "SDL_PauseAudioDevice".}
# @}
# Pause audio functions
#*
#   This function loads a WAVE from the data source, automatically freeing
#   that source if \c freesrc is non-zero.  For example, to load a WAVE file,
#   you could do:
#   \code
#       SDL_LoadWAV_RW(SDL_RWFromFile("sample.wav", "rb"), 1, ...);
#   \endcode
#
#   If this function succeeds, it returns the given AudioSpec,
#   filled with the audio data format of the wave data, and sets
#   \c *audio_buf to a malloc()'d buffer containing the audio data,
#   and sets \c *audio_len to the length of that audio buffer, in bytes.
#   You need to free the audio buffer with SDL_FreeWAV() when you are
#   done with it.
#
#   This function returns NULL and sets the SDL error message if the
#   wave file cannot be opened, uses an unknown data format, or is
#   corrupt.  Currently raw and MS-ADPCM WAVE files are supported.
#

proc loadWAV_RW*(src: ptr RWops; freesrc: cint;
                 spec: ptr AudioSpec; audio_buf: ptr ptr uint8;
                 audio_len: ptr uint32): ptr AudioSpec {.
  importc: "SDL_LoadWAV_RW".}

#*
#   Loads a WAV from a file.
#   Compatibility convenience function.
#
template loadWAV*(file: string, spec: ptr AudioSpec, audio_buf: ptr ptr uint8, audio_len: ptr uint32): ptr AudioSpec =
  loadWAV_RW(rwFromFile(file, "rb"), 1, spec, audio_buf, audio_len)

#*
#   This function frees data previously allocated with SDL_LoadWAV_RW()
#
proc freeWAV*(audio_buf: ptr uint8) {.
  importc: "SDL_FreeWAV".}
#*
#   This function takes a source format and rate and a destination format
#   and rate, and initializes the \c cvt structure with information needed
#   by SDL_ConvertAudio() to convert a buffer of audio data from one format
#   to the other.
#
#   \return -1 if the format conversion is not supported, 0 if there's
#   no conversion needed, or 1 if the audio filter is set up.
#
proc buildAudioCVT*(cvt: ptr AudioCVT; src_format: AudioFormat;
                        src_channels: uint8; src_rate: cint;
                        dst_format: AudioFormat; dst_channels: uint8;
                        dst_rate: cint): cint {.
  importc: "SDL_BuildAudioCVT".}
#*
#   Once you have initialized the \c cvt structure using SDL_BuildAudioCVT(),
#   created an audio buffer \c cvt->buf, and filled it with \c cvt->len bytes of
#   audio data in the source format, this function will convert it in-place
#   to the desired format.
#
#   The data conversion may expand the size of the audio data, so the buffer
#   \c cvt->buf should be allocated after the \c cvt structure is initialized by
#   SDL_BuildAudioCVT(), and should be \c cvt->len*cvt->len_mult bytes long.
#
proc convertAudio*(cvt: ptr AudioCVT): cint {.
  importc: "SDL_ConvertAudio".}

#*
#   This takes two audio buffers of the playing audio format and mixes
#   them, performing addition, volume adjustment, and overflow clipping.
#   The volume ranges from 0 - 128, and should be set to ::SDL_MIX_MAXVOLUME
#   for full audio volume.  Note this does not change hardware volume.
#   This is provided for convenience -- you can mix your own audio data.
#
proc mixAudio*(dst: ptr uint8; src: ptr uint8; len: uint32; volume: cint) {.
  importc: "SDL_MixAudio".}
#*
#   This works like SDL_MixAudio(), but you specify the audio format instead of
#   using the format of audio device 1. Thus it can be used when no audio
#   device is open at all.
#
proc mixAudioFormat*(dst: ptr uint8; src: ptr uint8;
                         format: AudioFormat; len: uint32; volume: cint) {.
  importc: "SDL_MixAudioFormat".}
#*
#   \name Audio lock functions
#
#   The lock manipulated by these functions protects the callback function.
#   During a SDL_LockAudio()/SDL_UnlockAudio() pair, you can be guaranteed that
#   the callback function is not running.  Do not call these from the callback
#   function or you will cause deadlock.
#
# @{
proc lockAudio*() {.
  importc: "SDL_LockAudio".}
proc lockAudioDevice*(dev: AudioDeviceID) {.
  importc: "SDL_LockAudioDevice".}
proc unlockAudio*() {.
  importc: "SDL_UnlockAudio".}
proc unlockAudioDevice*(dev: AudioDeviceID) {.
  importc: "SDL_UnlockAudioDevice".}
# @}
# Audio lock functions
#*
#   This function shuts down audio processing and closes the audio device.
#
proc closeAudio*() {.
  importc: "SDL_CloseAudio".}
proc closeAudioDevice*(dev: AudioDeviceID) {.
  importc: "SDL_CloseAudioDevice".}
# Ends C function definitions when using C++


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
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_
  ## * `newAudioStream proc<#newAudioStream,AudioSpec,AudioSpec>`_

proc newAudioStream*(srcSpec, destSpec: AudioSpec): AudioStreamPtr =
  ## (Available since SDL 2.0.7)
  ## Create a new audio stream that converts from `srcSpec` to `destSpec`.
  ##
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_
  ## * `newAudioStream proc<#newAudioStream,AudioFormat,uint8,cint,AudioFormat,uint8,cint>`_
  newAudioStream(
    srcSpec.format, srcSpec.channels, srcSpec.freq,
    destSpec.format, destSpec.channels, destSpec.freq)

proc put*(
  stream: AudioStreamPtr,
  buf: pointer,
  len: cint): cint {.importc: "SDL_AudioStreamPut".}
  ## (Available since SDL 2.0.7)
  ## Add data to be converted/resampled to the stream. Returns 0 on success, or -1 on error.
  ## 
  ## Parameters:
  ## * `stream` The stream the audio data is being added to
  ## * `buf` A pointer to the audio data to add
  ## * `len` The number of bytes to write to the stream
  ##
  ## See also:
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
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc available*(stream: AudioStreamPtr): cint {.importc: "SDL_AudioStreamAvailable".}
  ## (Available since SDL 2.0.7)
  ## Get the number of converted/resampled bytes available (BYTES, not samples!).
  ## The stream may be buffering data behind the scenes until it has enough to
  ## resample correctly, so this number might be lower than what you expect, or even
  ## be zero. Add more data or flush the stream if you need the data now.
  ##
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc flush*(stream: AudioStreamPtr): cint {.importc: "SDL_AudioStreamFlush".}
  ## (Available since SDL 2.0.7)
  ## Tell the stream that you're done sending data, and anything being buffered
  ## should be converted/resampled and made available immediately. Returns 0
  ## on success, -1 on error.
  ##
  ## It is legal to add more data to a stream after flushing, but there will
  ## be audio gaps in the output. Generally this is intended to signal the
  ## end of input, so the complete output becomes available.
  ##
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc clear*(stream: AudioStreamPtr) {.importc: "SDL_AudioStreamClear".}
  ## (Available since SDL 2.0.7)
  ## Clear any pending data in the stream without converting it.
  ##
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_

proc destroy*(stream: AudioStreamPtr) {.importc: "SDL_FreeAudioStream".}
  ## (Available since SDL 2.0.7)
  ## Free an audio stream.
  ##
  ## See also:
  ## * `AudioStreamPtr type<#AudioStreamPtr>`_


# vi: set ts=4 sw=4 expandtab:
when not defined(SDL_Static):
  {.pop.}
