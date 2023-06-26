; expands or collapses a list of groups
(define (expand-collapse-branch actGrpLst state)
  (let*
    (
       (i 0)(actG 0)(chldrn 0)
    )

    (while (< i (- (vector-length actGrpLst) 1))
      (set! actG (vector-ref actGrpLst i))

      (if debug
        (gimp-message
          (string-append " testing group -> "
                         (car (gimp-item-get-name actG)))
                         " set expand to ->  " (number->string (- state 1))
        )
      )

      (set! chldrn (gimp-item-get-children actG))
      (when (> (car chldrn) 0)
        (if (= state 1)(gimp-item-set-expanded actG 0))
        (if (= state 0)(gimp-item-set-expanded actG 1))
      )

      (set! i (+ i 1))
    )

  )
)