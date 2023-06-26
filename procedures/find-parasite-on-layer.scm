; does the layer have a specific parasite
(define (find-parasite-on-layer actL tag)
  (let*
    (
      (i 0)(paras 0)(pCount 0)(lstP 0)(pName "")(found 0)
    )

    (set! paras (car (gimp-item-get-parasite-list actL)))
    (set! pCount (length paras))
    (set! lstP (list->vector paras))

    (when (> pCount 0)
      (while(< i pCount)
        (set! pName (vector-ref lstP i))
        
        (when (equal? tag pName)
          (set! found 1)
          (set! i pCount)
        )
      (set! i (+ i 1))
      )
    )

    found
  )
)