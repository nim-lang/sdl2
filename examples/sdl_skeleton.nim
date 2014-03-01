## Bare-bones SDL2 example 
import sdl2, sdl2/gfx 

discard SDL_Init(INIT_EVERYTHING)

var 
  window: PWindow
  render: PRenderer

window = CreateWindow("SDL Skeleton", 100, 100, 640,480, SDL_WINDOW_SHOWN)
render = CreateRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)

var
  evt: TEvent
  runGame = true
  fpsman: TFPSmanager
fpsman.init

while runGame:
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break
  
  let dt = fpsman.getFramerate() / 1000
  
  render.setDrawColor 0,0,0,255
  render.clear
  
  render.present

destroy render
destroy window

