;returns a list of groups representing the stack structure
(define (get-branches img drwbles)
  (let*
    (
       (i 0)(allGrpLsts ())(actGrpLst 0)(actG 0)
    )

    ; make list of group lists, in the right order, deepest child first
    (while (< i (vector-length drwbles))
      (set! actG (vector-ref drwbles i))
      (set! actGrpLst (get-all-groups img actG))
      (set! actGrpLst (reverse actGrpLst))
      (set! allGrpLsts (append allGrpLsts (list actGrpLst)))
      (if #f ;debug
        (gimp-message
          (string-append
            " selected ->  " (car(gimp-item-get-name actG ))
            "\n number of groups ->  " (number->string (length actGrpLst))
            "\n number of group lists ->  " (number->string (length allGrpLsts))
          )
        )
      )
      (set! i (+ i 1))
    )
  
  allGrpLsts
  )
)