(define (newDisplay width height type precision)
 (let*
 (
  (activeLayer 0)
  (newImg 0)
  (theDisplay 0)
  (returnImg 0)
  (fullOpacity 100)
  (normalMode 28)
  (parent 0)
  (position 0)
 )

  (set! newImg (car (gimp-image-new-with-precision width
                                                   height
                                                   type
                                                   precision
                                                   )))

  (set! theDisplay (car (gimp-display-new newImg)))

  (set! activeLayer (car (gimp-layer-new newImg
                                         width
                                         height
                                         type
                                         "blank"
                                         fullOpacity
                                         normalMode
                                         )))

  (gimp-image-insert-layer newImg activeLayer parent position)

  (set! returnImg (make-vector 3 'double))
  (vector-set! returnImg 0 activeLayer)
  (vector-set! returnImg 1 newImg)
  (vector-set! returnImg 2 theDisplay)

  returnImg
 )
)


(script-fu-register "newDisplay"
 ""
 "creates a new display returns the display, image, layer"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
