import random

import sdl2
import sdl2/ttf

const
    WINDOW_WIDTH = 640
    WINDOW_HEIGHT = 480

    PADDLE_WIDTH = 16
    PADDLE_HEIGHT = 64
    PADDLE_SPEED = 400.0

    BALL_RADIUS = 8

    MAX_BALL_COMPONENT_SPEED = 1000'f32

    TEXT_WIDTH = 128
    TEXT_HEIGHT = 64

type
    Paddle = ref object
        x, y: float32

    Ball = ref object
        x, y: float32
        vx, vy: float32

    Input {.pure.} = enum
        up,
        down,
        none

    Game = ref object
        running: bool
        
        inputs: array[Input, bool]
        player, opponent: Paddle
        ball: Ball

        scores: tuple[player: uint, opponent: uint]

proc newPaddle(x: float32): Paddle =
    Paddle(
        x: x,
        y: (WINDOW_HEIGHT + PADDLE_HEIGHT) / 2,
    )

proc newBall(): Ball =
    Ball(
        x: WINDOW_WIDTH / 2 - BALL_RADIUS,
        y: WINDOW_HEIGHT / 2 - BALL_RADIUS,
        vx: (rand(2.0) - 1) * 100,
        vy: (rand(2.0) - 1) * 300
    ) 

func collision(ball: Ball, paddle: Paddle): bool =
    return not (
        ball.x > paddle.x + PADDLE_WIDTH or
        ball.x + 2 * BALL_RADIUS < paddle.x or
        ball.y > paddle.y + PADDLE_HEIGHT or
        ball.y + 2 * BALL_RADIUS < paddle.y
    )

proc updatePlayer(g: Game, dt: float32) =
    if g.inputs[Input.up]:
        g.player.y -= PADDLE_SPEED * dt
    if g.inputs[Input.down]:
        g.player.y += PADDLE_SPEED * dt

    if g.player.y < 0:
        g.player.y = 0
    elif g.player.y + PADDLE_HEIGHT > WINDOW_HEIGHT:
        g.player.y = WINDOW_HEIGHT - PADDLE_HEIGHT

proc updateOpponent(g: Game, dt: float32) =
    let dist = (g.ball.y + BALL_RADIUS) - (g.opponent.y + PADDLE_HEIGHT / 2)
    var dy: float32

    if dist > 0:
        dy = min(dist, PADDLE_SPEED * dt)
    elif dist < 0:
        dy = max(dist, -PADDLE_SPEED * dt)

    g.opponent.y += dy
    g.opponent.y = max(g.opponent.y, 0)
    g.opponent.y = min(g.opponent.y, WINDOW_HEIGHT - PADDLE_WIDTH)

proc bounce(v: var float32) =
    v *= -1

    v = max(v, -MAX_BALL_COMPONENT_SPEED)
    v = min(v,  MAX_BALL_COMPONENT_SPEED)

proc speedup(v: var float32) =
    v *= (1 + rand(0.5))

    v = max(v, -MAX_BALL_COMPONENT_SPEED)
    v = min(v,  MAX_BALL_COMPONENT_SPEED)
        
proc updateBall(g: Game, dt: float32) =
    g.ball.x += g.ball.vx * dt
    g.ball.y += g.ball.vy * dt

    # bounce on upper and lower borders, add speedup on bounce
    if g.ball.y < 0:
        g.ball.y = 0
        bounce(g.ball.vy)
        speedup(g.ball.vx)
    elif g.ball.y + 2 * BALL_RADIUS > WINDOW_HEIGHT:
        g.ball.y = WINDOW_HEIGHT - 2 * BALL_RADIUS
        bounce(g.ball.vy)
        speedup(g.ball.vx)

    # bounce on paddles
    if g.ball.collision g.player:
        g.ball.x = g.player.x + PADDLE_WIDTH
        bounce(g.ball.vx)
        speedup(g.ball.vy)
    elif g.ball.collision g.opponent:
        g.ball.x = g.opponent.x - 2 * BALL_RADIUS
        bounce(g.ball.vx)
        speedup(g.ball.vy)

    # opponent scored
    if g.ball.x + 2 * BALL_RADIUS < 0:
        inc g.scores.opponent
        g.ball = newBall()

    # player scored
    elif g.ball.x > WINDOW_WIDTH:
        inc g.scores.player
        g.ball = newBall()


proc draw(renderer: RendererPtr, paddle: Paddle) =
    renderer.setDrawColor 255, 255, 255, 255 # white
    var r = rect(
        cint(paddle.x), cint(paddle.y),
        cint(PADDLE_WIDTH), cint(PADDLE_HEIGHT)
    )
    renderer.fillRect(r)

proc draw(renderer: RendererPtr, ball: Ball) =
    renderer.setDrawColor 255, 255, 255, 255 # white
    var r = rect(
        cint(ball.x), cint(ball.y),
        cint(2 * BALL_RADIUS), cint(2 * BALL_RADIUS)
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
        (WINDOW_WIDTH - TEXT_WIDTH) div 2,
        0,
        TEXT_WIDTH,
        TEXT_HEIGHT
    )
    renderer.copy texture, nil, addr r

proc newGame(): Game =
    Game(
        running: true,
        player: newPaddle(PADDLE_WIDTH),
        opponent: newPaddle(WINDOW_WIDTH - 2 * PADDLE_WIDTH),
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
    of SDL_SCANCODE_UP: Input.up
    of SDL_SCANCODE_DOWN: Input.down
    else: Input.none

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
        w = WINDOW_WIDTH,
        h = WINDOW_HEIGHT,
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

    let font = ttf.openFont("liberation-sans.ttf", TEXT_HEIGHT)
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
