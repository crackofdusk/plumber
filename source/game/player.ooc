use sdl2
import sdl2/Core

use deadlogger
import deadlogger/Log

import game/[config]

Player: class {

    logger := static Log getLogger(This name)

    renderer: SdlRenderer

    x: Int { get set }
    y: Int { get set }

    side := static Config side

    init: func (=renderer)

    draw: func (dt: Double) {
        SDL setRenderDrawColor(renderer, 0x27, 0x90, 0xff, 255)
        player := (x * side, y * side, side, side) as SdlRect
        SDL renderDrawRect(renderer, player&)
        SDL setRenderDrawColor(renderer, 255, 255, 255, 255)
    }
}
