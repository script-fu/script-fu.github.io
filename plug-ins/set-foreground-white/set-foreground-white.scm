#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-set-foreground-white)
  (gimp-context-set-foreground (list 255 255 255))
  (gimp-context-set-background (list 0 0 0))
)

(script-fu-register "script-fu-set-foreground-white"
 "set-foreground-white"
 "Sets the foreground color to white, the background to black"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)


; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3
