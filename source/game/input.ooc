use deadlogger
import deadlogger/Log

use sdl2
import sdl2/[Core, Event]

import structs/ArrayList

Input: class {

    logger := static Log getLogger(This name)

    _mouseX: Int
    _mouseY: Int

    listeners := ArrayList<Listener> new()

    onEvent: func (cb: Func(ListenerEvent)) -> Listener {
        listener := Listener new(cb)
        listeners add(listener)
        listener
    }

    onExit: func (cb: Func) -> Listener {
        onEvent(|ev|
            match (ev) {
                case xv: ExitEvent => cb()
            }
        )
    }

    onMouseMove: func (cb: Func(MouseMotion)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case mm: MouseMotion => cb(mm)
            }
        )
    }

    onMouseRelease: func (which: UInt, cb: Func(MouseRelease)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case mr: MouseRelease =>
                    if (mr button == which) cb(mr)
            }
        )
    }

    _mouseReleased: func (button: Int) {
        _notifyListeners(MouseRelease new(_mouseX, _mouseY, button))
    }

    _mouseMoved: func (x, y: Int) {
        (_mouseX, _mouseY) = (x, y)
        _notifyListeners(MouseMotion new(x, y))
    }

    _quit: func {
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




