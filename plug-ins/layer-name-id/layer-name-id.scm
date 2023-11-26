#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-layer-name-id img lstL)
  (print-layer-id-name lstL)
)

(script-fu-register-filter "script-fu-layer-name-id"
 "Layer ID"
 "Prints a list of all selected layers and ID"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-name-id" "<Image>/Layer")

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


; prints the layer name and id of every layer in a list in one string
(define (print-layer-id-name lstL)
  (let*
    (
      (i 0)(strL "")(msg " ")(actL 0)(id "")(nme "")
    )
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (set! id (number->string actL))
        (set! nme (car(gimp-item-get-name actL)))
        (set! strL (string-append strL msg id " : " nme "\n"))
      )
      (set! i (+ i 1))
    )
    (gimp-message strL)
  )
)

