use sdl2
import sdl2/Core

use deadlogger
import deadlogger/Log

use math

import ./ImageAsset
import ./utils
import ./config

Pipe: abstract class {

    logger := static Log getLogger(This name)

    side := static 64
    // Compute these percentages again if you modify the image
    holeOffset := static side * 0.325 + 0.5
    holeWidth := static side * 0.35 + 0.5
    angle: Double
    image: ImageAsset
    renderer: SdlRenderer
    passed: Double
    filled: Bool
    current: Bool { get set }
    flowDirection: Direction { get set }

    init: func (=renderer, path: String, angle := 0) {
        this angle = angle % 360
        if (this angle < 0) {
            this angle += 360
        }
        passed = 0.0
        filled = false
        current = false
        image = ImageAsset new(renderer, path)
    }

    draw: func(x, y: Int, dt: Double) {
        progress: Double = 0

        if (current) {
            passed += dt * Config speed

            if (passed > side) {
                current = false
                filled = true
                progress = 1
            } else {
                progress = passed / side as Double
            }

        } else if (filled) {
            progress = 1
        }

        drawWater(x, y, progress)
        SDL setRenderDrawColor(renderer, 255, 255, 255, 255)

        container := (x * side, y * side, side, side) as SdlRect
        SDL renderCopyEx(renderer, image texture, null, container&, angle, null, SDL_FLIP_NONE)

    }

    drawWater: abstract func (x, y: Int, progress: Double)

    nextDirection: abstract func -> Direction

}

StraightPipe: class extends Pipe {

    // TODO: load from config file
    PATH := static "assets/pipe.png"

    init: func (renderer: SdlRenderer, angle := 0) {
        super(renderer, PATH, angle)
    }

    drawWater: func(x, y: Int, progress: Double) {
        if (!(progress > 0)) return

        SDL setRenderDrawColor(renderer, 0x27, 0x90, 0xff, 255)

        water := (x * side, y * side, side, side) as SdlRect

        match (angle) {
            case 0 =>
                water w *= progress
                water h = holeWidth
                water y += holeOffset
                if (flowDirection == Direction left) {
                    water x += side - water w
                }
            case =>
                water h *= progress
                water w = holeWidth
                water x += holeOffset
                if (flowDirection == Direction up) {
                    water y += side - water h
                }
        }

        SDL renderFillRect(renderer, water&)
    }

    nextDirection: func -> Direction {
        flowDirection
    }
}

ElbowPipe: class extends Pipe {

    // TODO: load from config file
    PATH := static "assets/pipe-elbow.png"

    init: func (renderer: SdlRenderer, angle := 0) {
        super(renderer, PATH, angle)
    }

    drawWater: func(x, y: Int, progress: Double) {
        if (!(progress > 0)) return

        direction1, direction2: Direction

        (direction1, direction2) = (flowDirection, nextDirection())

        SDL setRenderDrawColor(renderer, 0x27, 0x90, 0xff, 255)

        treshold := 0.67

        progress1 := progress
        if (progress1 > treshold) {
            progress1 = treshold
        }

        water1 := (x * side, y * side, side, side) as SdlRect

        match direction1 {
            case Direction up =>
                water1 w = holeWidth
                water1 h *= progress1
                water1 x += holeOffset
                water1 y += side - water1 h
            case Direction down =>
                water1 w = holeWidth
                water1 h *= progress1
                water1 x += holeOffset
            case Direction left =>
                water1 w *= progress1
                water1 h = holeWidth
                water1 y += holeOffset
                water1 x += side - water1 w
            case Direction right =>
                water1 w *= progress1
                water1 h = holeWidth
                water1 y += holeOffset
        }

        SDL renderFillRect(renderer, water1&)

        progress2 := progress - treshold

        if (progress2 < 0) return

        water2 := (x * side, y * side, side, side) as SdlRect

        match direction2 {
            case Direction up =>
                water2 w = holeWidth
                water2 h *= progress2
                water2 x += holeOffset
                water2 y += holeOffset + holeWidth - water2 h
            case Direction down =>
                water2 w = holeWidth
                water2 h *= progress2
                water2 x += holeOffset
                water2 y += holeOffset + holeWidth
            case Direction left =>
                water2 w *= progress2
                water2 h = holeWidth
                water2 x += holeOffset + holeWidth - water2 w
                water2 y += holeOffset
            case Direction right =>
                water2 w *= progress2
                water2 h = holeWidth
                water2 x += holeOffset + holeWidth
                water2 y += holeOffset
        }

        SDL renderFillRect(renderer, water2&)
    }

    nextDirection: func -> Direction {
        match (angle as Int) {
            case 0 =>
                (flowDirection == Direction right) ? Direction up : Direction left
            case 90 =>
                (flowDirection == Direction down) ? Direction right : Direction up
            case 180 =>
                (flowDirection == Direction left) ? Direction down : Direction right
            case 270 =>
                (flowDirection == Direction right) ? Direction down : Direction left
        }
    }

}
