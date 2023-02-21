#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-helloWorld ) 
 (let*
 (
 (i 0)
 )
 
 (while (< i 30)
  (gimp-message "hello world")
  (usleep 1000000)
  (set! i (+ i 1))
 )

)
)

(script-fu-register "script-fu-helloWorld"
 "helloWorld" 
 "hello world plug-in example with time loop" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-helloWorld" "<Image>/Fu-Plug-ins")
