#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-helloAgain ) 
 (let*
 (
 (i 0)
 )
 
 (while (< i 30)
  (gimp-message "hello again")
  (usleep 500000)
  (set! i (+ i 1))
 )

)
)

(script-fu-register "script-fu-helloAgain"
 "helloAgain" 
 "hello again plug-in example with time loop" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-helloAgain" "<Image>/Fu-Plug-ins")
