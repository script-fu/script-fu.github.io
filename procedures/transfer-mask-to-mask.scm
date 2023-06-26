; copies a mask to a mask, or layer to a mask
; (source image, src mask/layer, destination image, dst mask)
; returns the destination mask id
(define (transfer-mask-to-mask srcImg srcM dstImg dstM)
  (let*
    (
      (srcL 0)
      (offX 0)
      (offY 0)
    )

    (if (= (car (gimp-item-id-is-layer-mask srcM)) 1)
      (set! srcL (car(gimp-layer-from-mask srcM)))
        (set! srcL srcM)
    )

    (set! offX (car(gimp-drawable-get-offsets srcL )))
    (set! offY (cadr(gimp-drawable-get-offsets srcL )))

    (gimp-selection-none srcImg)
    (gimp-edit-copy 1 (vector srcM))
    (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0 ))
    (gimp-layer-set-offsets dstM offX offY)
    (gimp-floating-sel-anchor dstM)

    (set! dstM (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! dstM (car(gimp-layer-get-mask dstM)))

    dstM
  )
)