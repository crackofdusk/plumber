use sdl2
use deadlogger

import sdl2/Core
import deadlogger/Log

import ./SurfaceLoader

ImageAsset: class {

    logger := static Log getLogger(This name)

    width, height: Int

    texture: SdlTexture { get set }

    init: func (renderer: SdlRenderer, path: String) {
        surface := SurfaceLoader load(path)
        (width, height) = (surface@ w, surface@ h)

        texture = SDL createTextureFromSurface(renderer, surface)

        if (texture == 0) {
            logger warn("Failed to create texture: %s" format(SDL getError()))
        }

        SDL freeSurface(surface)
    }

}
