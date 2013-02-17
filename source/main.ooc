use sdl2
use deadlogger

import sdl2/[Core, Event]
import deadlogger/[Log, Handler, Level, Formatter, Filter]

import game/[grid, pipe, utils]

main: func (argc: Int, argv: CString*) {

    setupLogger()
    logger := Log getLogger("main")

    SDL init(SDL_INIT_EVERYTHING)

    window := SDL createWindow(
        "YAY!",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        600, 400, SDL_WINDOW_SHOWN)

    renderer := SDL createRenderer(window, -1, SDL_RENDERER_ACCELERATED)

    grid := GameGrid new()

    grid put(0, 0, StraightPipe new(renderer))
    grid put(1, 0, StraightPipe new(renderer))
    grid put(2, 0, ElbowPipe new(renderer, -90.0))
    grid put(2, 1, StraightPipe new(renderer, 90.0))
    grid put(2, 2, ElbowPipe new(renderer, 90.0))

    grid setCurrent(0, 0, Direction right)

    SDL setRenderDrawColor(renderer, 255, 255, 255, 255)

    running := true

    framRate: Double = 60
    MAX_FRAME_DURATION := 16.667 // 1000 / 60

    dt: Double

    t1 := SDL getTicks()

    while (running) {
        e: SdlEvent

        if (SdlEvent poll(e&)) {
            match (e type) {
                case SDL_QUIT => running = false
            }
        }

        SDL renderClear(renderer)
        grid draw(dt)
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
