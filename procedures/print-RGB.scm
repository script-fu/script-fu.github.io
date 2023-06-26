(define (print-RGB msg lst)
  (let*
    (
      (red 0)(grn 0)(blu 0)
    )
    
    (if (list? lst) (set! lst (list->vector lst)))
    (set! red (number->string (vector-ref lst 0)))
    (set! grn (number->string (vector-ref lst 1)))
    (set! blu (number->string (vector-ref lst 2)))
    (gimp-message (string-append msg " RGB : " red ", " grn ", " blu))

  )
)