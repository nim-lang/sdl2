# Generate and playback a sine tone

import sdl2
import sdl2/audio
import math

# Audio settings requested:
const RQBufferSizeInSamples = 4096
const RQBytesPerSample = 2  # 16 bit PCM
const RQBufferSizeInBytes = RQBufferSizeInSamples * RQBytesPerSample
let SampleRate = 44100    # Hz

# What tone to generate:
let Frequence = 1000      # Hz
let Volume = 0.1          # [0..1]

# Current playback position
var x = 0

# Variables
var buffer: array[RQBufferSizeInBytes*16, int16] # Allocate a safe amount of memory
var obtained: AudioSpec # Actual audio parameters SDL returns

# Generate a sine wave
let c = float(SampleRate) / float(Frequence)
proc SineAmplitude(): int16 = int16(round(sin(float(x mod int(c)) / c * 2 * PI) * 32767 * Volume))

# 3 different callback procedures which do the same thing:

# Write amplitude direct to hardware buffer
proc AudioCallback_1(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} =
  for i in 0..int16(obtained.samples)-1:
      cast[ptr int16](cast[int](stream) + i * RQBytesPerSample)[] = SineAmplitude()
      inc(x)

# Write amplitude to own buffer, then copy buffer with copyMem()
proc AudioCallback_2(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} =
  for i in 0..int16(obtained.samples)-1:
      buffer[i] = SineAmplitude()
      inc(x)
  copyMem(stream, addr(buffer[0]), RQBytesPerSample*int16(obtained.samples))

# Write amplitude to own buffer, reset hardware buffer with 0, then output buffer with MixAudio()
proc AudioCallback_3(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} =
  for i in 0..int16(obtained.samples-1):
      buffer[i] = SineAmplitude()
      inc(x)
  for i in 0..int16(obtained.samples-1):
    (cast[ptr int16](cast[int](stream) + i * RQBytesPerSample ))[] = 0
  mixAudio(stream, cast[ptr uint8](addr(buffer[0])), uint32(RQBytesPerSample*int(obtained.samples)), SDL_MIX_MAXVOLUME)

proc main() =
  # Init audio playback
  if init(INIT_AUDIO) != SdlSuccess:
    echo("Couldn't initialize SDL\n")
    return
  var audioSpec: AudioSpec
  audioSpec.freq = cint(SampleRate)
  audioSpec.format = AUDIO_S16 # 16 bit PCM
  audioSpec.channels = 1       # mono
  audioSpec.samples = RQBufferSizeInBytes
  audioSpec.padding = 0
  audioSpec.callback = AudioCallback_1
  audioSpec.userdata = nil
  if openAudio(addr(audioSpec), addr(obtained)) != 0:
    echo("Couldn't open audio device. " & $getError() & "\n")
    return
  echo("frequency: ", obtained.freq)
  echo("format: ", obtained.format)
  echo("channels: ", obtained.channels)
  echo("samples: ", obtained.samples)
  echo("padding: ", obtained.padding)
  if obtained.format != AUDIO_S16:
    echo("Couldn't open 16-bit audio channel.")
    return
  # Playback audio for 2 seconds
  pauseAudio(0)
  delay(2000)

main()
