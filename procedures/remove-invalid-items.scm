; filters a list removing stuff that doesn't exist
; returns a filtered list
(define (remove-invalid-items itemsLst)
  (let*
      (
        (actL 0)(validLst ())
        (i 0)
      )

    (if (list? itemsLst) (set! itemsLst (list->vector itemsLst)))

    (while (< i (vector-length itemsLst))
      (set! actL (vector-ref itemsLst i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (set! validLst (append validLst (list actL)))
      )
      (set! i (+ i 1))
    )

    (list->vector validLst)
  )
)