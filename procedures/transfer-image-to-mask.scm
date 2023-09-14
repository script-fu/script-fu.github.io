; copies an image to a mask
; (source image, destination image, dst mask)
; returns the destination mask id
(define (transfer-image-to-mask srcImg dstImg dstM)
  (let*
    (
      (srcL 0)
      (offX 0)
      (offY 0)
    )

    (gimp-selection-none srcImg)
    (gimp-edit-copy-visible srcImg)
    (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0 ))
    (gimp-floating-sel-anchor dstM)
    (set! dstM (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! dstM (car(gimp-layer-get-mask dstM)))

    dstM
  )
)