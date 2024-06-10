#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-selectedDrawables image drawables) 
  (let*
    (
      (numDraw (vector-length drawables))
      (drawable 0)
      (i 0)
    )

    (gimp-message (string-append "  number of selected drawables -> "
                                   (number->string numDraw)))

    (while (< i numDraw)
      (set! drawable (vector-ref drawables i))
      (gimp-message (string-append "  selected drawable ID -> "
                                   (number->string drawable )))
      (set! i (+ i 1))
    )

  )
)

(script-fu-register-filter "script-fu-selectedDrawables"
  "selectedDrawables" 
  "how to access the selected drawables with a filter plugin" 
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  ;SF-ONE-DRAWABLE ;  limit the plug-in to a single selected drawable
  SF-ONE-OR-MORE-DRAWABLE  ; allow user to select many drawables 
)
(script-fu-menu-register "script-fu-selectedDrawables" "<Image>/Plugin")
