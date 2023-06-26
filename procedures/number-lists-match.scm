; compares two lists of numbers and tests for a perfect match
; returns 1 or 0
(define (number-lists-match lstA lstB)
  (let
    (
      (match 0)
    )

    (if (vector? lstA) (set! lstA (vector->list lstA)))
    (if (vector? lstB) (set! lstB (vector->list lstB)))

    (when (not (null? lstA))
      (when (= (length lstA) (length lstB))
        (set! lstA (bubble-sort (length lstA) lstA))
        (set! lstB (bubble-sort (length lstB) lstB))
        (if (equal? lstA lstB) (set! match 1))
      )
    )

  match
  )
)