; returns a random number within a min and max range
(define (random-range minV maxV)
  (let*
    (
     (randomInt 0)
    )

    (set! randomInt (- maxV minV))
    (set! randomInt (rand randomInt))
    (set! randomInt (+ minV randomInt))

    randomInt
  )
)