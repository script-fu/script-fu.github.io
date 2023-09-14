; creates a new RGB image of a specified precision
; (width, height, type/RGB), precision/PRECISION-U32-LINEAR)
; returns the new image and a new layer ID in a list (img layer)
(define (new-image-with-precision width height type precision)
  (let*
    (
      (img 0)(actL 0)(nme "Background")(mde LAYER-MODE-NORMAL)
      ; precision = PRECISION-U8-NON-LINEAR (150)
      ; precision = PRECISION-U16-LINEAR (200)
      ; precision = PRECISION-U16-NON-LINEAR (250)
      ; precision = PRECISION-U32-LINEAR (300)
      ; type = RGB, GRAY , INDEXED
    )

    (set! img (car(gimp-image-new-with-precision width height type precision)))
    (set! actL (car(gimp-layer-new img width height RGBA-IMAGE nme 100 mde)))
    (gimp-image-insert-layer img actL 0 0)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (list img actL)
  )
)