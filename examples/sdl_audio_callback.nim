# Generate and playback a sine tone

import sdl2
import sdl2/audio
import math

# Audio settings:
const BufferSizeInSamples = 4096
const BytesPerSample = 2  # 16 bit PCM
const BufferSizeInBytes = BufferSizeInSamples * BytesPerSample
let SampleRate = 44100    # Hz

# What tone to generate:
let Frequence = 1000      # Hz
let Volume = 0.1          # [0..1]

# Current playback position
var x = 0 

# Generate a sine wave
let c = float(SampleRate) / float(Frequence)
proc SineAmplitude(): int16 = int16(round(sin(float(x mod int(c)) / c * 2 * PI) * 32767 * Volume))

# 3 different callback procedures which do the same thing:

# Write amplitude direct to hardware buffer
proc AudioCallback_1(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} = 
  for i in 0..BufferSizeInSamples - 1:
      cast[ptr int16](cast[int](stream) + i * BytesPerSample)[] = SineAmplitude()
      Inc(x)
  
# Write amplitude to own buffer, then copy buffer with copyMem()  
proc AudioCallback_2(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} = 
  var buffer: array[BufferSizeInSamples, int16]
  for i in 0..BufferSizeInSamples - 1:
      buffer[i] = SineAmplitude()
      Inc(x)
  copyMem(stream, addr(buffer[0]), BufferSizeInBytes)

# Write amplitude to own buffer, reset hardware buffer with 0, then output buffer with MixAudio() 
proc AudioCallback_3(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} = 
  var buffer: array[BufferSizeInSamples, int16]
  for i in 0..BufferSizeInSamples - 1:
      buffer[i] = SineAmplitude()
      Inc(x)
  for i in 0..BufferSizeInBytes - 1:
    (cast[ptr uint8](cast[int](stream) + i))[] = 0
  MixAudio(stream, cast[ptr uint8](addr(buffer[0])), BufferSizeInBytes, SDL_MIX_MAXVOLUME)
  
proc main() =
  # Init audio playback
  if Init(INIT_AUDIO) != SdlSuccess:
    echo("Couldn't initialize SDL\n")
    return
  var audioSpec: TAudioSpec
  audioSpec.freq = cint(SampleRate)
  audioSpec.format = AUDIO_S16 # 16 bit PCM
  audioSpec.channels = 1       # mono
  audioSpec.samples = BufferSizeInBytes
  audioSpec.padding = 0
  audioSpec.callback = AudioCallback_1
  audioSpec.userdata = nil
  if OpenAudio(addr(audioSpec), nil) != 0:
    echo("Couldn't open audio device. " & $GetError() & "\n")
    return
  # Playback audio for 2 seconds
  PauseAudio(0)
  Delay(2000)

main()
