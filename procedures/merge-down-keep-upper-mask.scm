; special case of merging down to the layer below, keeps and restores the mask
(define (merge-down-keep-as-mask img upperL)
  (let*
    (
      (msk (car (gimp-layer-get-mask upperL)))(actL 0)(dstMsk 0)
      (offX (car(gimp-drawable-get-offsets upperL)))
      (offY (cadr(gimp-drawable-get-offsets upperL)))
    )

    ; save the mask
    (when (> msk 0)
      (gimp-edit-copy 1 (vector msk))
      (gimp-layer-remove-mask upperL MASK-DISCARD)
    )

    (set! actL (car(gimp-image-merge-down img upperL CLIP-TO-BOTTOM-LAYER)))

    ; restore the mask
    (when (> msk 0)
      (gimp-item-set-visible actL 0)
      (set! dstMsk (car (gimp-layer-create-mask actL ADD-MASK-BLACK)))
      (gimp-layer-add-mask actL dstMsk)
      (set! dstMsk(car (gimp-layer-get-mask actL)))
      (set! dstMsk (vector-ref (cadr(gimp-edit-paste dstMsk 1)) 0 ))
      (gimp-layer-set-offsets dstMsk offX offY)
      (gimp-floating-sel-anchor dstMsk)
    )

    ;return active layer
    (vector-ref (cadr(gimp-image-get-selected-layers img))0)
  )
)