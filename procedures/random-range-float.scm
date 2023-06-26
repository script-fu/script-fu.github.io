; returns a random number within a min and max range, float
(define (random-range-float minV maxV)
  (let*
    (
     (randomFloat 0)
    )

    (set! minV (* minV 1000000))
    (set! maxV (* maxV 1000000))
    (set! randomFloat (- maxV minV))
    (set! randomFloat (rand randomFloat))
    (set! randomFloat (+ minV randomFloat))
    (set! randomFloat (/ randomFloat 1000000))

    randomFloat
  )
)