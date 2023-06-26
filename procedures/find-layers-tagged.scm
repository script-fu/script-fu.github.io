; given a list of layers and a "parasite" name it returns those layers with it
(define (find-layers-tagged img lstL tag)
  (let*
    (
      (tgdLst ())(pCountr 0)(actL 0)(paras 0)(pCount 0)
      (lstP 0)(pName 0)(i 0)(j 0)
    )

    (set! lstL (list->vector lstL))

    (set! i 0)
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paras (car (gimp-item-get-parasite-list actL)))
      (set! pCount (length paras))
      (when (> pCount 0)
        (set! lstP (list->vector paras))
        (set! j 0)
        (while(< j pCount)
          (set! pName (vector-ref lstP j))
          (when (equal? pName tag)
            (set! tgdLst (append tgdLst (list actL)))
            (set! pCountr (+ pCountr 1))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tgdLst)
  )
)