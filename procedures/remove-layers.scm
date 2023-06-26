; removes a list of layers from an image
; (source image, list of layers)
(define (remove-layers img lstL)
  (let*
    (
      (i 0)(actL 0)
    )

    (if (list? lstL)(set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (if (= (car (gimp-item-id-is-valid actL)) 1)
        (gimp-image-remove-layer img actL)
      )
      (set! i (+ i 1))
    )

  )
)