; prints a vector as a single string
(define (print-vector-list vect)
  (let* ((i 0) (lstr "")(actV 0))

    (if (list? vect) (set! vect (list->vector vect)))
    (while (< i (vector-length vect))
      (set! actV (vector-ref vect i))
      (if (not (string? actV)) (set! actV (number->string actV)))
      (set! lstr (string-append lstr " vector element ->  " actV "\n" ))
      (set! i (+ i 1))
    )

    (gimp-message lstr)
  )
)