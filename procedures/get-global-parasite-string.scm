; if global parasite exists, returns the string stored , otherwise returns ""
(define (get-global-parasite-string paraNme)
  (let*
    (
      (i 0)(actP 0)(fndStr "")
      (para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message "found the global parasite"))
        (set! fndStr (string->number (caddar(gimp-get-parasite actP))))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndStr
  )
)