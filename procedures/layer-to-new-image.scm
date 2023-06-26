; creates a new image and display with a copy of a source layer
; (source image, source layer)
; returns a new image, a new display and the new layer
(define (layer-to-new-image img actL)
  (let*
    (
      (dstImg 0)(dstDsp 0)
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! dstDsp (car(gimp-display-new dstImg)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))

    (list dstImg dstDsp actL)
  )
)