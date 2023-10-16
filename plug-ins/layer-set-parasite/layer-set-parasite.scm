#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-layer-set-parasite img lst name mode tagV col)
  (let*
    (
      (i 0)(actL 0)
    ) 

    (if (list? lst )(set! lst (list->vector lst)))

    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (tag-layer actL name mode tagV col)
      (set! i (+ i 1))
    )
    (gimp-message (string-append " added layer parasite : " name))

  )
)

(script-fu-register-filter "script-fu-layer-set-parasite"
 "Layer Add Parasite" 
 "Attaches a specific parasite to the selected layers"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-STRING      "parasite _name"   "skin"
 SF-ADJUSTMENT  "attach _mode 0-3 " (list 3 0 6 1 1 0 SF-SPINNER)
 SF-STRING      "parasite _data"   "pale skin"
 SF-ADJUSTMENT  "layer color _0-8 " (list 0 0 8 1 1 0 SF-SPINNER)
)
(script-fu-menu-register "script-fu-layer-set-parasite" "<Image>/Layer/Tag")


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


; tags a layer with a parasite and an optional layer colour
; (layer id, "parasite name", attach mode, "value string", layer color)
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
; color (0-8) (none, blue, green, yellow, orange, brown, red, violet, grey)
(define (tag-layer actL name mode tagV col)
  (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
    (set! actL (car(gimp-layer-from-mask actL)))
  )
  (gimp-item-attach-parasite actL (list name mode tagV))
  (gimp-item-set-color-tag actL col)
)


