#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-select-all-paths img drwbls)
  (let*
    (
      (pathInfo (gimp-image-get-vectors img))
      (numPaths (car pathInfo))
      (paths (cadr pathInfo))
      (i 0)(actPth 0)
    )

    (while (< i numPaths)
      (set! actPth (vector-ref paths i))
      (gimp-item-set-visible actPth 0)
      (set! i (+ i 1))
    )
    
  )
)



(script-fu-register-filter "script-fu-select-all-paths"
 "Select All Paths"
 "Selects all the paths"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-select-all-paths" "<Image>/Tools")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message (string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))

