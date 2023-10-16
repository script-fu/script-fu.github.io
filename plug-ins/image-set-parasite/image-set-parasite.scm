#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-image-set-parasite img lst name mode tagV)

  (tag-image img name mode tagV)
  (gimp-message (string-append " added image parasite : " name))

)

(script-fu-register-filter "script-fu-image-set-parasite"
 "Image Add Parasite" 
 "Attaches a specific parasite to the active image"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-STRING      "parasite name"   "ink"
 SF-ADJUSTMENT  "attach mode 0-3 " (list 3 0 6 1 1 0 SF-SPINNER)
 SF-STRING      "parasite data"   "ink source"
)
(script-fu-menu-register "script-fu-image-set-parasite" "<Image>/Image/Tag")

;SF-ADJUSTMENT "label" '(value, lower, upper, step_inc, page_inc, digits, type)
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message(string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; tags an image with a parasite
; (layer id, "parasite name", attach mode, "value string")
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
(define (tag-image img name mode tagV)
  (gimp-image-attach-parasite img (list name 0 tagV))
)

