(define (get-proxy-groups img preFxL)
  (let*
    (
      (lstL 0)(numL 0)(actL 0)(prxLst())(i 0)(found 0)
    )

    (set! lstL (all-childrn img 0))
    (set! lstL (list->vector lstL))
    (set! numL (vector-length lstL))

    (while (< i numL)
      (set! actL (vector-ref lstL i))
      (set! found (get-proxy actL preFxL))

      (when (= found 1)
        (set! prxLst (append prxLst (list actL)))
      )
      (set! i (+ i 1))
    )

  (list->vector prxLst)
  )
)


