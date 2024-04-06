; renames all the given layers
(define (rename-layers lstL nme)
  (let*
    (
      (i 0)(actL 0)
    )

    (set! nme (string-append nme " #1"))
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (gimp-item-set-name actL nme)
      )
      (set! i (+ i 1))
    )
  )
)