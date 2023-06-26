; returns the given global parasites value string as a number, or 0
(define (get-global-parasite paraNme)
  (let*
    (
      (i 0)(actP 0)(fndVal 0)
      (para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message "found the global parasite"))
        (set! fndVal (string->number (caddar(gimp-get-parasite actP))))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndVal
  )
)