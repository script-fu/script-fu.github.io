(define (paintbrush)
 (let*
 (
 (fadeout 128)
 (num-strokes 4)
 (strokes 0)
 (gradient-length 256)
 (displayReturn 0)
 (newImg 0)
 (activeLayer 0)
 (width 1000)
 (height 1000)
 (type 0); RGB
 (precision 150) ;8bit
 (black 0)
 (white 256)
 (currentBrush 0)
 (radius 16)
 (spacing 0.1)
 )

 (gimp-context-push)

 (set! currentBrush (car(gimp-context-get-brush)))
 (gimp-context-set-brush-size radius)
 (gimp-context-set-brush-spacing spacing)
 (gimp-context-set-default-colors)
 (gimp-context-set-gradient "FG to BG (RGB)")


 (set! displayReturn (newDisplay width height type precision))
 (set! newImg (vector-ref displayReturn 1))
 (set! activeLayer (vector-ref displayReturn 0))

 (gimp-context-set-foreground (list black black black))
 (gimp-context-set-opacity 100)
 (gimp-drawable-edit-fill activeLayer 0)
 (gimp-context-set-foreground (list white white white))

 (set! strokes (make-vector 4 'double))
 (vector-set! strokes 0 200 )
 (vector-set! strokes 1 200 )
 (vector-set! strokes 2 800 )
 (vector-set! strokes 3 200 )

 (gimp-paintbrush activeLayer
                  fadeout
                  num-strokes
                  strokes
                  PAINT-CONSTANT
                  gradient-length
                  )

 (gimp-displays-flush)

 (vector-set! strokes 0 200 )
 (vector-set! strokes 1 800 )
 (vector-set! strokes 2 800 )
 (vector-set! strokes 3 200 )

 (set! fadeout 0)
 (gimp-paintbrush activeLayer
                  fadeout
                  num-strokes
                  strokes
                  PAINT-CONSTANT
                  gradient-length
                  )

 (gimp-displays-flush)

 (vector-set! strokes 0 800 )
 (vector-set! strokes 1 800 )
 (vector-set! strokes 2 200 )
 (vector-set! strokes 3 800 )

 (set! fadeout 256)
 (gimp-paintbrush activeLayer
                  fadeout
                  num-strokes
                  strokes
                  PAINT-CONSTANT
                  gradient-length
                  )

 (gimp-displays-flush)
 (gimp-context-pop)
 )
)

(script-fu-register "paintbrush"
 "paintbrushDemo"
 "draws some procedural strokes with the active brush"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)

(script-fu-menu-register "paintbrush" "<Image>/Script-Fu")
