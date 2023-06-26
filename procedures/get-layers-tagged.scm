; given a list of layers it returns a list of those layers with a parasite "tag"
; (source image, list of layers, "tag/parasite name")
(define (get-layers-tagged img lstL tag)
  (let*
    (
      (tLst ())(actL 0)(paraLst 0)(pNme 0)(i 0)(j 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paraLst (list->vector (car (gimp-item-get-parasite-list actL))))
      (when (> (vector-length paraLst) 0)
        (set! j 0)
        (while(< j (vector-length paraLst))
          (set! pNme (vector-ref paraLst j))
          (if (equal? pNme tag)(set! tLst (append tLst (list actL))))
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tLst)
  )
)