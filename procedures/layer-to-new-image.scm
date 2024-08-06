; creates a new image and display with a copy of a source layer
; (source image, source layer)
; returns a new image, a new display and the new layer
(define (layer-to-new-image img actL createDisplay selection)
  (let*
    (
      (dstImg 0)
      (dstDsp 0)
      (rootP 0)
    )

    (if (not selection) (gimp-selection-none img))
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (if createDisplay (set! dstDsp (car(gimp-display-new dstImg))))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    ; finds inherited group hierarchy
    (set! rootP (get-root-parent dstImg actL))

    ; puts the paint layer on root and removes any group nests
    (set! actL (reorder-item dstImg actL 0 0))
    (if (> rootP 0) (gimp-image-remove-layer dstImg rootP))

    (vector dstImg dstDsp actL)
  )
)