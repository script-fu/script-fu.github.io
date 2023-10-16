; tests for a color already being stored in a list
; (color as a list (R G B), list of lists ((color)(color)...
; returns #t or #f
(define (color-in-list col colLst)
  (let*
    (
      (i 0)(actCol 0)(match 0)(colorMatch #f)(actRed 0)(actGrn 0)(actBlu 0)
      (red 0)(grn 0)(blu 0)(msg "\n searching list for a matching RGB:\n ")
    )

    (if (list? colLst) (set! colLst (list->vector colLst)))
    (while (< i (vector-length colLst))
      (set! actCol (vector-ref colLst i))
      (set! match 0)
      (set! colorMatch #f)

      (set! actRed (car actCol))
      (set! actGrn (cadr actCol))
      (set! actBlu (caddr actCol))

      (set! msg (string-append msg "\n palette RGB : " 
                  (number->string actRed)  ", " 
                  (number->string actGrn)  ", "
                  (number->string actBlu) 
                )
      )

      (set! red (car col))
      (set! grn (cadr col))
      (set! blu (caddr col))

      (set! msg (string-append msg "\n add RGB ? : " 
                  (number->string red) ", " 
                  (number->string grn) ", " 
                  (number->string blu)
                )
      )
      
      (if (= actRed red) (set! match (+ match 1)))
      (if (= actGrn grn) (set! match (+ match 1)))
      (if (= actBlu blu) (set! match (+ match 1)))

      (when (= match 3) 
        (set! colorMatch #t)
        (set! i (vector-length colLst))
        (set! msg (string-append msg "\n not adding, match found "))
      )

      (set! i (+ i 1))
    )

    (if debug (gimp-message msg))

  colorMatch
  )
)