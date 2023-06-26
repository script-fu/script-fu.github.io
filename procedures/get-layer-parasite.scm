; returns #t or #f if parasite is on a specified layer
; (layer id, parasite name)
(define (get-layer-parasite actL paraNme)
  (let*
    (
      (i 0)(actP 0)(fnd #f)
      (para (list->vector (car(gimp-item-get-parasite-list actL))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fnd #t)
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fnd
  )
)