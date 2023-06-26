; collapses a list of groups
(define (close-groups grpLst)
  (let*
    (
      (i 0)(actG 0)
    )

    (while (< i (vector-length grpLst))
     (set! actG (vector-ref grpLst i))
     (if (> (car (gimp-item-is-group actG)) 0) (gimp-item-set-expanded actG 0))
     (set! i (+ i 1))
    )

  )
)