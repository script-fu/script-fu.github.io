#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-newlayerFromSelection img drawables name colour layermode)
  (let*
    (
      (points 0)
      (newLayer 0)
      (originalPosition 0)
      (parent 0)
      (srcOffsetWidth 0)
      (srcOffsetHeight 0)
      (drawable (vector-ref drawables 0))
    )

    (gimp-context-push)

    (if (= layermode 1) (set! layermode 30)
      (set! layermode 28)
    )
    
    (if (= (car(gimp-selection-is-empty img)) 1)(gimp-selection-all img))

    (if (= (car (gimp-item-id-is-layer-mask drawable)) 1)
      (set! drawable (car(gimp-layer-from-mask drawable)))
    )

    (set! originalPosition (car (gimp-image-get-item-position img drawable)))
    (set! parent (car (gimp-item-get-parent drawable)))
    (set! srcOffsetWidth (car (gimp-drawable-get-offsets drawable)))
    (set! srcOffsetHeight (car (cdr (gimp-drawable-get-offsets drawable))))
    (set! points (make-vector 4 'double))
    (vector-set! points 0 (car(cdr(gimp-selection-bounds img))))
    (vector-set! points 1 (car(cdr(cdr(gimp-selection-bounds img)))))
    (vector-set! points 2 (car(cdr(cdr(cdr(gimp-selection-bounds img))))))
    (vector-set! points 3 (car(cdr(cdr(cdr(cdr(gimp-selection-bounds img)))))))

    (set! newLayer (car(gimp-layer-new img
                                 (- (vector-ref points 2) (vector-ref points 0))
                                 (- (vector-ref points 3) (vector-ref points 1))
                                 RGBA-IMAGE
                                 name 
                                 100
                                 layermode)))

    
    (gimp-layer-set-offsets newLayer(vector-ref points 0) (vector-ref points 1))
    (gimp-context-set-background colour)
    (gimp-image-insert-layer img newLayer parent originalPosition)
    (gimp-drawable-edit-fill newLayer FILL-BACKGROUND)
    (gimp-image-set-selected-layers img 1 (vector newLayer)) 
    (gimp-displays-flush)
    (gimp-context-pop)
    
  )
)

(script-fu-register-filter "script-fu-newlayerFromSelection"
  "newlayerFromSelectedArea" 
  "creates a new layer from the selection area size"
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-DRAWABLE
  SF-STRING      "name"   "newLayer"
  SF-COLOR      "fill colour"   "white"
  SF-TOGGLE     "multiply"             TRUE
)
(script-fu-menu-register "script-fu-newlayerFromSelection" "<Image>/Fu-Plugin")
