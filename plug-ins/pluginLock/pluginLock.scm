#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-pluginLock img drawables) 
  (let*
    (
    )

      (when (= (plugin-get-lock "pluginLock") 0)  ; plugin locked?
        (plugin-set-lock "pluginLock" 1) ; lock it
        (gimp-message " script locked plugin for 10 seconds")
        (usleep 10000000) ; do stuff
        (gimp-message " plugin finished")
        (plugin-set-lock "pluginLock" 0) ; unlock it
        (gimp-message " script unlocked plugin")
      )

  )
)


(define (plugin-get-lock plugin) 
  (let*
    (
      (input (open-input-file plugin))
      (lockValue 0)
    )

    (if input (set! lockValue (read input)))
    (if input (close-input-port input))

    lockValue
  )
)


(define (plugin-set-lock plugin lock) 
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)


(script-fu-register-filter "script-fu-pluginLock"
  "pluginLock" 
  "example of locking a plugin with an external text file" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-pluginLock" "<Image>/Fu-Plugin")
