#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-threshold-foreground)
  (let*
    (
      (fg (car(gimp-context-get-foreground)))
      (r (car fg))
      (g (cadr fg))
      (b (caddr fg))
    )

    (if (or (> r 128) (> g 128) (> b 128))
      (gimp-context-set-foreground (list 255 255 255))
      (gimp-context-set-foreground (list 0 0 0))
    )

  )
)

(script-fu-register "script-fu-threshold-foreground"
 "Threshold Foreground"
 "Threshold the foreground color to black or white"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
 )

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3
