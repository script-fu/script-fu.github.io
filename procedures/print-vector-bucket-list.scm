; prints a vector of vector lists, e.g a vector of groups and child layers
(define (print-vector-bucket-list lst)
  (let*
    (
      (actG 0)(actP 0)(strL "")(i 0)(j 0)(grp 0)(nme "")(actL 0)
    )

    (while (< i (vector-length lst))
      (set! actG (vector-ref lst i))
      (set! j 0)
      (while (< j (vector-length actG))
        (set! actL (vector-ref actG j))
        (set! nme (car (gimp-item-get-name actL)))
        (set! grp (number->string i))
        (set! strL (string-append strL "\n group " grp " : child : " nme))
        (set! j (+ j 1))
      )
      (set! strL (string-append strL "\n"))
      (set! i (+ i 1))
    )
    (gimp-message strL)
  )
)