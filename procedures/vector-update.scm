; updates a vector with a new set of values from another vector
; something to do with how vectors are assigned memory made this necessary,maybe
(define (vector-update vec valVec)
  (let*
    (
      (i 0)
    )

    (while (< i (vector-length vec))
      (vector-set! vec i (vector-ref valVec i))
      (set! i (+ i 1))
    )

  )
)