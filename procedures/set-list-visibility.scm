; sets the visibility state of a layer list
(define (set-list-visibility lstL vis)
  (let*
    (
      (vLst())(i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! vLst (append vLst (list actL (car(gimp-item-get-visible actL)))))
      (gimp-item-set-visible actL vis)
      (set! i (+ i 1))
    )

    vLst
  )
)