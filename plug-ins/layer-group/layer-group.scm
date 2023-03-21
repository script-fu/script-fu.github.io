#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-layer-group img drawables)
  (let*
    (
      (drawable (vector-ref drawables 0))
      (numDraw (vector-length drawables))
      (parent (car (gimp-item-get-parent drawable)))
      (position (car (gimp-image-get-item-position img drawable)))
      (layerGrp 0)(i (- numDraw 1))
    )

    (gimp-image-undo-group-start img)
    (set! layerGrp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img layerGrp parent position)
    (gimp-item-set-name layerGrp "group")
    (gimp-layer-set-mode layerGrp LAYER-MODE-PASS-THROUGH)

    (while (> i -1)
      (set! drawable (vector-ref drawables i))
      (gimp-image-reorder-item img drawable layerGrp 0)
      (set! i (- i 1))
    )
    (gimp-image-undo-group-end img)

    layerGrp
  )
)

(script-fu-register-filter "script-fu-layer-group"
 "Group" 
 "Puts the selected layers in a pass-through group" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-group" "<Image>/Layer")
