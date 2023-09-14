; creates a new image with a copy of a source layer
; (source image, source layer)
; returns a new image, and the new layer
(define (layer-to-hidden-image img actL)
  (let*
    (
      (dstImg 0)(dstDsp 0)
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (list dstImg actL)
  )
)