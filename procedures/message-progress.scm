; prints a progress message (current amount, maximum amount, prefix "message")
(define (message-progress currAmt maxAmt message)
  (let*
    (
      (prg 0)
    )

    (set! prg (* (/ 1 maxAmt) (+ currAmt 1)))
    (set! prg (trunc (floor (* prg 100))))
    (set! message (string-append " >>> " message " > "(number->string prg) "%"))
    (gimp-message message)

  )
)