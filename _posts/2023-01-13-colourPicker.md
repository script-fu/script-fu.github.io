## Colour Picker

# * Tested in Gimp 2.10.30 *

Sometimes, in a script, it's *really* useful to find out what a pixel is doing.

*samples the active layer for a pixel colour, reports findings to error console*

```scheme
(define (colourPicker img sourceLayer xPoint yPoint merged average radius)
 (let*
 (
  (sampledColour 0)
  (redElement 0)
  (greenElement 0)
  (blueElement 0)
  (drawableOffsetWidth 0)
  (drawableOffsetHeight 0)
  (sourceLayerHeight 0)
  (sourceLayerWidth 0)
 )

 (set! sourceLayerWidth(car(gimp-drawable-width sourceLayer)))
 (set! sourceLayerHeight(car(gimp-drawable-height sourceLayer)))

 (if (> xPoint sourceLayerWidth)(set! xPoint (- sourceLayerWidth 1)))
 (if (> yPoint sourceLayerHeight)(set! yPoint (- sourceLayerHeight 1)))

 (gimp-message (string-append " ***  colour sample @ ***\n"
                              " (" (number->string xPoint) ","
                              (number->string yPoint)")"
                              ))

 (set! drawableOffsetWidth (car (gimp-drawable-offsets sourceLayer)))
 (set! drawableOffsetHeight (car (cdr (gimp-drawable-offsets sourceLayer))))

 (set! sampledColour (car (gimp-image-pick-color img
                                                 sourceLayer
                                                 (+ drawableOffsetWidth xPoint)
                                                 (+ drawableOffsetHeight yPoint)
                                                 merged
                                                 average
                                                 radius
                                                 )))

 (set! redElement (car sampledColour))
 (set! greenElement (car (cdr sampledColour)))
 (set! blueElement (car (reverse sampledColour)))

 (gimp-message (string-append " R : " (number->string redElement)
                              "\n G : " (number->string greenElement)
                              "\n B : " (number->string blueElement)
                              ))

 )
)

(script-fu-register "colourPicker"
 "colourPicker"
 "samples active image with pick colour function"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
 SF-ADJUSTMENT  "X sample point (pixels)" (list 100 1 10000 1 10 0 SF-SPINNER)
 SF-ADJUSTMENT  "Y sample point (pixels)" (list 100 1 10000 1 10 0 SF-SPINNER)
 SF-TOGGLE "Sample Merged" TRUE
 SF-TOGGLE "Sample Average" TRUE
 SF-ADJUSTMENT "radius of average (pixels)" (list 5 1 500 1 10 0 SF-SPINNER)
)
(script-fu-menu-register "colourPicker" "<Image>/Script-Fu")

```
