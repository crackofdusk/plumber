use deadlogger
import deadlogger/Log

use sdl2
import sdl2/[Core, Event]

import structs/ArrayList

Input: class {

    logger := static Log getLogger(This name)

    listeners := ArrayList<Listener> new()

    onEvent: func (cb: Func(ListenerEvent)) -> Listener {
        listener := Listener new(cb)
        listeners add(listener)
        listener
    }

    onExit: func (cb: Func) -> Listener {
        onEvent(|ev|
            match (ev) {
                // TODO: ask nddrylliog about case names
                case xv: ExitEvent => cb()
            }
        )
    }

    _mouseReleased: func (button: Int) {
        logger debug("Mouse button up")

    }

    _mouseMoved: func (x, y: Int) {
        logger debug("Mouse moved")
    }

    _quit: func {
        logger debug("SDL quit event")
        _notifyListeners(ExitEvent new())
    }

    _notifyListeners: func (ev: ListenerEvent) {
        for (l in listeners) {
            l cb(ev)
        }
    }

    poll: func {
        event: SdlEvent

        while(SdlEvent poll(event&)) {
            match (event type) {
                case SDL_MOUSEBUTTONUP =>
                    _mouseReleased(event button button)
                case SDL_MOUSEMOTION =>
                    _mouseMoved(event motion x, event motion y)
                case SDL_QUIT =>
                    _quit()
            }
        }
    }

}

Listener: class {

    cb: Func(ListenerEvent)

    init: func(=cb)

}

ListenerEvent: class {}

ExitEvent: class extends ListenerEvent {}

MouseEvent: class extends ListenerEvent {

    x, y: Int

    init: func(=x, =y)

}

MouseMotion: class extends MouseEvent {

    init: super func

}

MouseRelease: class extends MouseEvent {

    button: Int

    init: func(=x, =y, =button)

}




