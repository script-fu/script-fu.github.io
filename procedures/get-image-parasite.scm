; returns #t or #f if parasite is on a specified image
; (image id, parasite name)
(define (get-image-parasite img paraNme)
  (let*
    (
      (i 0)(actP 0)(fnd #f)
      (para (list->vector (car(gimp-image-get-parasite-list img))))
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