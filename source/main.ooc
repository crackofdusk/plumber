use sdl2
import sdl2/[Core, Event]

use deadlogger
import deadlogger/[Log, Handler, Level, Formatter, Filter]

import game/[config, grid, input, pipe, player, utils]

main: func (argc: Int, argv: CString*) {

    setupLogger()
    logger := Log getLogger("main")

    SDL init(SDL_INIT_EVERYTHING)

    window := SDL createWindow(
        "Plumber",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        10 * Config side, 10 * Config side, SDL_WINDOW_SHOWN)

    SDL showCursor(false)

    renderer := SDL createRenderer(window, -1, SDL_RENDERER_ACCELERATED)

    grid := GameGrid new()

    grid put(0, 0, StraightPipe new(renderer))
    grid put(1, 0, StraightPipe new(renderer))
    grid put(2, 0, ElbowPipe new(renderer, -90.0))
    grid put(2, 1, StraightPipe new(renderer, 90.0))
    grid put(2, 2, ElbowPipe new(renderer, 90.0))

    grid setCurrent(0, 0, Direction right)

    SDL setRenderDrawColor(renderer, 255, 255, 255, 255)

    player := Player new(renderer)

    input := Input new()

    running := true

    input onExit(|| running = false)

    input onMouseMove(|event|
        player x = event x / Config side
        player y = event y / Config side
    )

    input onMouseRelease(SDL_BUTTON_LEFT, |event|
        logger debug("Button released %d %d" format(event x, event y))
    )

    framRate: Double = 60
    MAX_FRAME_DURATION := 1000 / framRate

    dt: Double

    t1 := SDL getTicks()

    while (running) {
        input poll()

        SDL renderClear(renderer)
        grid draw(dt)
        player draw(dt)
        SDL renderPresent(renderer)

        t2 := SDL getTicks()
        dt = t2 - t1

        if (dt < 0) {
            dt = 0
        }

        if (dt > MAX_FRAME_DURATION) {
            dt = MAX_FRAME_DURATION
        }

        SDL delay(dt)
        dt = t2 - t1

        t1 = t2
    }

    SDL destroyRenderer(renderer)
    SDL destroyWindow(window)
    SDL quit()
}

setupLogger: static func {
    console := StdoutHandler new()
    console setFormatter(ColoredFormatter new(NiceFormatter new()))
    Log root attachHandler(console)
}
