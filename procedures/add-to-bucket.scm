; adds a value to a vector in a vector list
(define (add-to-bucket vectVect bucket n)
  (vector-set! vectVect bucket (vector-append (vector-ref vectVect bucket) n))
)