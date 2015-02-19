## Bare-bones SDL2 example 
import sdl2, sdl2/gfx 

discard sdl2.init(INIT_EVERYTHING)

var 
  window: WindowPtr
  render: RendererPtr

window = createWindow("SDL Skeleton", 100, 100, 640,480, SDL_WINDOW_SHOWN)
render = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)

var
  evt = Event(kind: QuitEvent)
  runGame = true
  fpsman: FpsManager
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
  fpsman.delay

destroy render
destroy window

