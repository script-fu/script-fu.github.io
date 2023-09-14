; paste buffer to a destination layer, set opacity mode and visibility
(define (paste-copied-layer img dstL opacity mode vis)
  (let*
    (
      (actL 0)(mask 0)
    )

    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (set! mask (car (gimp-item-id-is-layer-mask actL)))
    (if (= mask 1)(set! actL (car (gimp-layer-from-mask actL))))
    (gimp-layer-set-opacity actL opacity)
    (gimp-layer-set-mode actL mode)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    (gimp-item-set-visible actL vis)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
      (set! actL (car(gimp-layer-from-mask actL)))
    )

    actL
  )
)
