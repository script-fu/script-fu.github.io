; stores and sets the visibility state of a layer list
(define (set-list-visibility img lstL vis)
  (let*
    (
      (vLst())(i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))

    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! vLst (append vLst (list actL (car(gimp-item-get-visible actL)))))
      ;(gimp-item-set-visible actL vis)
      (set! i (+ i 1))
    )
      (gimp-message (string-append " lstL -> " 
              (number->string (vector-length lstL))
              )
      )
    ;Experimental plug-in
    (if (> (vector-length lstL) 0)
      (pm-set-items-visibility 1 img (vector-length lstL) lstL vis)
    )

    ;return the list of stored visibility states
    vLst
  )
)