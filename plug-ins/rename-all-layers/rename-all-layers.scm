#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-rename-all-layers img drwbls newname)
  (let*
    (
      (chldrn (all-childrn img 0))(lstL 0)(i 0)(actL 0)(allL ())
      (selChldrn (list->vector (reverse chldrn)))
    )
    (gimp-image-set-selected-layers img (length chldrn ) selChldrn)
    (rename-layers chldrn newname)
  )
)

(define debug #f)

(script-fu-register-filter "script-fu-rename-all-layers"
 "Rename All Layers"
 "Renames all the layers in the stack"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-STRING "name" "newname"
)
(script-fu-menu-register "script-fu-rename-all-layers" "<Image>/Layer")

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


; returns all the children of an image or a group as a list
; (source image, source group) set group to zero for all children of the image
(define (all-childrn img rootGrp) ; recursive
  (let*
    (
      (chldrn ())(lstL 0)(i 0)(actL 0)(allL ())
    )

    (if (= rootGrp 0)
      (set! chldrn (gimp-image-get-layers img))
        (if (equal? (car (gimp-item-is-group rootGrp)) 1)
          (set! chldrn (gimp-item-get-children rootGrp))
        )
    )

    (when (not (null? chldrn))
      (set! lstL (cadr chldrn))
      (while (< i (car chldrn))
        (set! actL (vector-ref lstL i))
        (set! allL (append allL (list actL)))
        (if (equal? (car (gimp-item-is-group actL)) 1)
          (set! allL (append allL (all-childrn img actL)))
        )
        (set! i (+ i 1))
      )
    )

    allL
  )
)


; renames all the given layers
(define (rename-layers lstL nme)
  (let*
    (
      (i 0)(actL 0)
    )

    (set! nme (string-append nme " #1"))
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (gimp-item-set-name actL nme)
      )
      (set! i (+ i 1))
    )
  )
)

