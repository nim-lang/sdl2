import sdl2, sdl2.mixer

# sdl init
sdl2.init(INIT_EVERYTHING)

#var sound : Mix_ChunkPtr
var sound2 : Mix_MusicPtr

var channel : cint
var audio_rate : cint
var audio_format : uint16
var audio_buffers : cint    = 4096
var audio_channels : cint   = 2

if Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers) != 0:
    quit("There was a problem")

#sound = Mix_LoadWAV("SDL_PlaySound/sound.wav")
sound2 = Mix_LoadMUS("SDL_PlaySound/sound.ogg")
if isNil(sound2):
    quit("Unable to load sound file")

#channel = Mix_PlayChannel(-1, sound, 0); #wav
channel = Mix_PlayMusic(sound2, 0); #ogg/flac
if channel == -1:
    quit("Unable to play sound")

var 
    window: WindowPtr
    render: RendererPtr

window = createWindow("SDL Skeleton", 100, 100, 640,480, SDL_WINDOW_SHOWN)
render = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)

#let the sound finish
while Mix_Playing(channel) != 0:
    discard

# Mix_FreeChunk(sound) #clear wav
Mix_FreeMusic(sound2) #clear ogg
Mix_CloseAudio()
sdl2.quit()

# keep window open enough to hear sound, testing purposes
Delay(1000)

destroy render
destroy window