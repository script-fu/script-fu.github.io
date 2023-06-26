; adds a new value to the end of a vector
; (vector, value)
; returns the new vector
(define (vector-append vect v)
  (let*
    (
      (len (vector-length vect ))
      (tmpV (make-vector (+ 1 len) v))
      (i 0)
    )

    (when (> len 0)
      (while (< i len)
        (vector-set! tmpV i (vector-ref vect i))
        (set! i (+ i 1))
      )
    )

    (set! vect tmpV)
  )
)