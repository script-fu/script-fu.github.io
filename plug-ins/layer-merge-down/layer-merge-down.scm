#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-layer-merge-down img drwbles)
  (gimp-image-undo-group-start img)
  (merge-down-keep-as-mask img (select-layer (vector-ref drwbles 0)))
  (gimp-image-undo-group-end img)
)

(define debug #f)

(script-fu-register-filter "script-fu-layer-merge-down"
 "Merge Down Keep Mask" 
 "Merges the top layer down and keeps the mask" 
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-merge-down" "<Image>/Layer")

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


; special case of merging down to the layer below, keeps as a mask
(define (merge-down-keep-as-mask img upperL)
  (let*
    (
      (msk 0)(actL 0)
    )

    (set! actL (car(gimp-image-merge-down img upperL CLIP-TO-BOTTOM-LAYER)))
    (set! msk (car (gimp-layer-create-mask actL ADD-MASK-ALPHA-TRANSFER)))
    (gimp-layer-add-mask actL msk)
    
    ;return active layer
    (vector-ref (cadr(gimp-image-get-selected-layers img))0)
  )
)


; makes sure user selection is a layer and not a mask
(define (select-layer actL)
  (let*
    (
      (isMsk(car (gimp-item-id-is-layer-mask actL)))
    )

    (if(= isMsk 1)(set! actL (car(gimp-layer-from-mask actL))))

    actL
  )
)


