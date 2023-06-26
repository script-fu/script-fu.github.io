; sets the opacity of a list of layers
(define (set-layers-opacity lstL opa)
  (let*
    (
      (i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (gimp-layer-set-opacity actL opa)
      (set! i (+ i 1))
    )
  )
)