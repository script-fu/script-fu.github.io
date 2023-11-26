; special case of merging down to the layer below, keeps as a mask
(define (merge-down-keep-as-mask img upperL)
  (let*
    (
      (msk 0)(actL 0)
    )

    (set! actL (car(gimp-image-merge-down img upperL CLIP-TO-BOTTOM-LAYER)))
    (set! msk (car (gimp-layer-create-mask actL ADD-MASK-ALPHA-TRANSFER)))
    (gimp-layer-add-mask actL msk)
    
    ;return active layer
    (vector-ref (cadr(gimp-image-get-selected-layers img))0)
  )
)