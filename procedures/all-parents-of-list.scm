; finds every direct parent of a list if items, returns a list of parents
(define (all-parents-of-list lst)
  (let*
    (
      (allPs ())(parent 0)(i 0)(actL 0)
    )

    (if (list? lst) (set! lst (list->vector lst)))
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! parent (car(gimp-item-get-parent actL)))
      
      (if (and (not(member parent allPs)) (> parent 0))
        (set! allPs (append allPs (list parent)))
      )
      (set! i (+ i 1))
    )

   allPs
  )
)