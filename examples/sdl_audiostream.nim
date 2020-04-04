import sdl2, sdl2/audio

# demonstration of SDL2 audio streams. load in a wav file, use
# an audiostream to convert its encoding to the encoding your
# audio hardware's desired format, then plays that audio by
# queueing it.

# path of the .wav file to load
const wavFilePath = "example.wav"

const sampleRate = 48000
const bufferSizeInSamples = 4096
const bytesPerSample = 2  # 16 bit PCM
const nChannels = 1
const bufferSizeInBytes = nChannels * bytesPerSample * bufferSizeInSamples

proc main() =
  # start up SDL2
  if sdl2.init(INIT_AUDIO) != SdlSuccess:
    quit "failed to init SDL2!"

  # SDL 2.0.7 is the first version with audio streams. If you want
  # to convert audio from one format to another before 2.0.7, you
  # have to use AudioCVT.
  var version: SDL_Version
  getVersion(version)
  if (version.major <= 2'u8) and
    (version.minor <= 0'u8) and
    (version.patch < 7'u8):
    quit "your version of SDL2 does not support SDL_AudioStream!"

  # ask SDL how many output devices are available
  let ndevices = getNumAudioDevices(0.cint).cint
  if ndevices == 0:
    quit "no devices!"

  # get the name of the first available audio device. this is generally the one you want.
  let deviceName = getAudioDeviceName(0.cint, 0.cint)

  # set up the hardware's spec
  var hardwareSpec = AudioSpec()
  hardwareSpec.freq = sampleRate.cint
  hardwareSpec.format = AUDIO_S16 # 16-bit PCM
  hardwareSpec.channels = nChannels
  hardwareSpec.samples = bufferSizeInBytes
  hardwareSpec.padding = 0
  
  # opening the audio device here. If the device can't handle one of the
  # specs we've given it, openAudioDevice will tweak the contents of
  # hardwareSpec to match something the device can do.
  let deviceId = openAudioDevice(deviceName, 0.cint, addr hardwareSpec, nil, 0)

  echo deviceName
  echo "  frequency: ", hardwareSpec.freq
  echo "  format: ", hardwareSpec.format
  echo "  channels: ", hardwareSpec.channels
  echo "  samples: ", hardwareSpec.samples
  echo "  padding: ", hardwareSpec.padding
  
  # audio devices default to being paused, so turn off pause
  deviceId.pauseAudioDevice(0.cint)

  # load in the wav file. wavFileSpec will be filled in with the wav
  # file's encoding.
  var
    wavFileSpec = AudioSpec()
    wavBuffer: ptr uint8
    wavBufferLen: uint32

  if loadWav(wavFilePath, addr wavFileSpec, addr wavBuffer, addr wavBufferLen).isNil:
    echo $sdl2.getError()
    quit "failed to load " & wavFilePath

  # make sure to free the buffer before we exit
  defer: freeWav(wavBuffer)

  # print some info about the audio specs.
  echo "\n", wavFilePath
  echo "  frequency: ", wavFileSpec.freq
  echo "  format: ", wavFileSpec.format
  echo "  channels: ", wavFileSpec.channels
  echo "  samples: ", wavFileSpec.samples
  echo "  padding: ", wavFileSpec.padding

  # create a new audio stream that will convert from the wav file's spec,
  # to the audio device's spec.
  let stream = newAudioStream(wavFileSpec, hardwareSpec)

  # make sure to free the stream before we exit
  defer: stream.destroy()

  # put the wav file into the stream
  if stream.put(wavBuffer, wavBufferLen.cint) < 0:
    echo $sdl2.getError()
    quit "failed to put wavBuffer into stream"

  # push everything through the stream.
  if stream.flush() < 0:
    echo $sdl2.getError()
    quit "failed to flush the stream"

  echo "number of bytes at the stream's output: ", stream.available()
  
  # calculate the number of bytes in a single output sample.
  let nBytesPerSample = hardwareSpec.channels * (SDL_AUDIO_BITSIZE(hardwareSpec.format.uint32) div 8).uint8
  
  # make a buffer that's just one of those.
  var obuf = alloc(nBytesPerSample)
  defer: dealloc(obuf)
  echo "bytes per sample ", nBytesPerSample
  
  # add the stream's output to the audio device's queue, one sample at a time.
  var nread = stream.get(obuf, nBytesPerSample.cint)
  while nread > 0:
    if deviceId.queueAudio(obuf, nread.uint32) < 0:
      echo $sdl2.getError()
      quit "failed to queue audio!"
    nread = stream.get(obuf, nBytesPerSample.cint)
  
  # sit in a while loop until the audio device's queue is empty
  while deviceId.getQueuedAudioSize() > 0'u32:
    discard

main()
