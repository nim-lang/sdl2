import random

import sdl2
import sdl2/ttf

const
  WindowWidth = 640
  WindowHeight = 480

  PaddleWidth = 16
  PaddleHeight = 64
  PaddleSpeed = 400.0

  BallRadius = 8

  MaxBallComponentSpeed = 1000'f32

  TextWidth = 128
  TextHeight = 64

type
  Paddle = ref object
    x, y: float32

  Ball = ref object
    x, y: float32
    vx, vy: float32

  Input {.pure.} = enum
    Up,
    Down,
    None

  Game = ref object
    running: bool
    
    inputs: array[Input, bool]
    player, opponent: Paddle
    ball: Ball

    scores: tuple[player: uint, opponent: uint]

proc newPaddle(x: float32): Paddle =
  Paddle(
    x: x,
    y: (WindowHeight + PaddleHeight) / 2,
  )

proc newBall(): Ball =
  Ball(
    x: WindowWidth / 2 - BallRadius,
    y: WindowHeight / 2 - BallRadius,
    vx: (rand(2.0) - 1) * 100,
    vy: (rand(2.0) - 1) * 300
  ) 

func collision(ball: Ball, paddle: Paddle): bool =
  return not (
    ball.x > paddle.x + PaddleWidth or
    ball.x + 2 * BallRadius < paddle.x or
    ball.y > paddle.y + PaddleHeight or
    ball.y + 2 * BallRadius < paddle.y
  )

proc updatePlayer(g: Game, dt: float32) =
  if g.inputs[Input.Up]:
    g.player.y -= PaddleSpeed * dt
  if g.inputs[Input.Down]:
    g.player.y += PaddleSpeed * dt

  if g.player.y < 0:
    g.player.y = 0
  elif g.player.y + PaddleHeight > WindowHeight:
    g.player.y = WindowHeight - PaddleHeight

proc updateOpponent(g: Game, dt: float32) =
  let dist = (g.ball.y + BallRadius) - (g.opponent.y + PaddleHeight / 2)
  var dy: float32

  if dist > 0:
    dy = min(dist, PaddleSpeed * dt)
  elif dist < 0:
    dy = max(dist, -PaddleSpeed * dt)

  g.opponent.y += dy
  g.opponent.y = max(g.opponent.y, 0)
  g.opponent.y = min(g.opponent.y, WindowHeight - PaddleWidth)

proc bounce(v: var float32) =
  v *= -1

  v = max(v, -MaxBallComponentSpeed)
  v = min(v,  MaxBallComponentSpeed)

proc speedup(v: var float32) =
  v *= (1 + rand(0.5))

  v = max(v, -MaxBallComponentSpeed)
  v = min(v,  MaxBallComponentSpeed)
    
proc updateBall(g: Game, dt: float32) =
  g.ball.x += g.ball.vx * dt
  g.ball.y += g.ball.vy * dt

  # bounce on upper and lower borders, add speedup on bounce
  if g.ball.y < 0:
    g.ball.y = 0
    bounce(g.ball.vy)
    speedup(g.ball.vx)
  elif g.ball.y + 2 * BallRadius > WindowHeight:
    g.ball.y = WindowHeight - 2 * BallRadius
    bounce(g.ball.vy)
    speedup(g.ball.vx)

  # bounce on paddles
  if g.ball.collision g.player:
    g.ball.x = g.player.x + PaddleWidth
    bounce(g.ball.vx)
    speedup(g.ball.vy)
  elif g.ball.collision g.opponent:
    g.ball.x = g.opponent.x - 2 * BallRadius
    bounce(g.ball.vx)
    speedup(g.ball.vy)

  # opponent scored
  if g.ball.x + 2 * BallRadius < 0:
    inc g.scores.opponent
    g.ball = newBall()

  # player scored
  elif g.ball.x > WindowWidth:
    inc g.scores.player
    g.ball = newBall()


proc draw(renderer: RendererPtr, paddle: Paddle) =
  renderer.setDrawColor 255, 255, 255, 255 # white
  var r = rect(
    cint(paddle.x), cint(paddle.y),
    cint(PaddleWidth), cint(PaddleHeight)
  )
  renderer.fillRect(r)

proc draw(renderer: RendererPtr, ball: Ball) =
  renderer.setDrawColor 255, 255, 255, 255 # white
  var r = rect(
    cint(ball.x), cint(ball.y),
    cint(2 * BallRadius), cint(2 * BallRadius)
  )
  renderer.fillRect(r)

proc drawScores(
  renderer: RendererPtr, font: FontPtr, scores: tuple[player: uint, opponent: uint]
) =
  let
    color = color(255, 255, 255, 0)
    text = $scores.player & " : " & $scores.opponent
    surface = ttf.renderTextSolid(font, text, color)
    texture = renderer.createTextureFromSurface(surface)

  surface.freeSurface
  defer: texture.destroy

  var r = rect(
    (WindowWidth - TextWidth) div 2,
    0,
    TextWidth,
    TextHeight
  )
  renderer.copy texture, nil, addr r

proc newGame(): Game =
  Game(
    running: true,
    player: newPaddle(PaddleWidth),
    opponent: newPaddle(WindowWidth - 2 * PaddleWidth),
    ball: newBall(),
    scores: (0'u, 0'u)
  )

proc update(g: Game, dt: float32) =
  g.updatePlayer dt
  g.updateOpponent dt
  g.updateBall dt

proc draw(g: Game, renderer: RendererPtr, font: FontPtr) =
  renderer.setDrawColor 0, 0, 0, 255 # black
  renderer.clear()

  renderer.draw(g.player)
  renderer.draw(g.opponent)
  renderer.draw(g.ball)

  renderer.drawScores(font, g.scores)
  
  renderer.present()
  
func toInput(key: Scancode): Input =
  case key
  of SDL_SCANCODE_UP: Input.Up
  of SDL_SCANCODE_DOWN: Input.Down
  else: Input.None

type SDLException = object of Defect

template sdlFailIf(condition: typed, reason: string) =
  if condition: raise SDLException.newException(
    reason & ", SDL error " & $getError()
  )

proc main =
  sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)):
    "SDL2 initialization failed"
  defer: sdl2.quit()

  let window = createWindow(
    title = "Pong",
    x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED,
    w = WindowWidth,
    h = WindowHeight,
    flags = SDL_WINDOW_SHOWN
  )

  sdlFailIf window.isNil: "window could not be created"
  defer: window.destroy()

  let renderer = createRenderer(
    window = window,
    index = -1,
    flags = Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture
  )
  sdlFailIf renderer.isNil: "renderer could not be created"
  defer: renderer.destroy()

  sdlFailIf(not ttfInit()): "SDL_TTF initialization failed"
  defer: ttfQuit()

  let font = ttf.openFont("liberation-sans.ttf", TextHeight)
  sdlFailIf font.isNil: "font could not be created"

  var
    running = true
    game = newGame()

    dt: float32

    counter: uint64
    previousCounter: uint64

  counter = getPerformanceCounter()

  while running:
    previousCounter = counter
    counter = getPerformanceCounter()

    dt = (counter - previousCounter).float / getPerformanceFrequency().float

    var event = defaultEvent

    while pollEvent(event):
      case event.kind
      of QuitEvent:
        running = false
        break

      of KeyDown:
        game.inputs[event.key.keysym.scancode.toInput] = true
      of KeyUp:
        game.inputs[event.key.keysym.scancode.toInput] = false
      else:
        discard

    game.update(dt)
    game.draw(renderer, font)

main()
