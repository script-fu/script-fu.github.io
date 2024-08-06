; paste buffer to a destination layer, set opacity, and mode of the layer before merging
(define (paste-copied-layer-with-adjustments img dstL opacity mode)
  (let*
    (
      (actL 0)
    )

    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-layer-set-opacity actL opacity)
    (gimp-layer-set-mode actL mode)
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    actL
  )
)
