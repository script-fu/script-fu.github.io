; creates a list of all layers and color tag index and then sets the color index
; (source image, color tag value 0-8 )
; returns a list of the layers and old tag col, (layer ID, index color)
(define (set-and-store-all-layer-colors img col)
  (let*
    (
      (i 0)(lstL ())(actL 0)(colLst())(colT 0)
    )

    (gimp-image-undo-group-start img)
    (set! lstL (all-childrn img 0))
    (set! lstL (list->vector lstL))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! colT (car(gimp-item-get-color-tag actL)))
      (set! colLst (append colLst (list actL colT)))
      (gimp-item-set-color-tag actL col)
      (set! i (+ i 1))
    )
    (gimp-image-undo-group-end img)

    colLst
  )
)