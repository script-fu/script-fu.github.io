; adds a mask to a layer of a given type;
; ADD-MASK-WHITE
; ADD-MASK-BLACK
; ADD-MASK-ALPHA
; ADD-MASK-ALPHA-TRANSFER
; ADD-MASK-SELECTION
; ADD-MASK-COPY
; ADD-MASK-CHANNEL
; returns the mask id
(define (add-mask actL type)
  (let*
    (
      (mask (car (gimp-layer-get-mask actL)))
    )

    (when (< mask 0)
      (set! mask (car (gimp-layer-create-mask actL type)))
      (gimp-layer-add-mask actL mask)
      (set! mask (car (gimp-layer-get-mask actL)))
      (if (equal? type ADD-MASK-WHITE)
        (gimp-message "white")
      )
    )

    mask
  )
)