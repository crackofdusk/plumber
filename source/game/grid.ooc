use sdl2
import sdl2/Core

use gnaar
import gnaar/grid

use deadlogger
import deadlogger/Log

import pipe
import utils

GameGrid: class {

    logger := static Log getLogger(This name)
    grid: Grid<Pipe>

    current: Pipe
    currentX: Int
    currentY: Int

    init: func {
        grid = Grid<Pipe> new()
    }

    get: func(x, y: Int) -> Pipe {
        grid get(x, y)
    }

    setCurrent: func(x, y: Int, direction: Direction) {
        if (current != null) {
            current current = false
        }
        current = get(x, y)
        current current = true
        current flowDirection = direction
        (currentX, currentY) = (x, y)
    }

    put: func (x, y: Int, pipe: Pipe) {
        grid put(x, y, pipe)
    }

    draw: func(dt: Double) {
        if (current filled) {
            current current = false
            setupNext()
        }

        grid each (|x, y, item| item draw(x, y, dt))
    }

    setupNext: func {
        direction := current nextDirection()

        continueWith := func (x, y: Int) {
            if (grid get(x, y) == null) {
                logger info("Game over")
                return
            }

            logger debug("Continuing with (%d, %d)" format(x, y))
            setCurrent(x, y, direction)
        }

        match (direction) {
            case Direction left =>
                continueWith(currentX - 1, currentY)
            case Direction right =>
                continueWith(currentX + 1, currentY)
            case Direction up =>
                continueWith(currentX, currentY - 1)
            case Direction down =>
                continueWith(currentX, currentY + 1)
            case =>
                logger debug("Invalid flow direction")
        }
    }
}

Grid: class<T> extends SparseGrid<T> {

    each: func (f: Func(Int, Int, T)) {
        rows each (|j, row|
            row cols each (|i, value|
                f(i, j, value)
            )
        )
    }
}

