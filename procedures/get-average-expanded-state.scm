; given a list of groups, it finds the average expanded state
(define (get-average-expanded-state grpLst)
 (let*
    (
       (i 0)(actG 0)(chldrn 0)(average 0)(total 0)(chldrn 0)(c 0)(expand 0)
    )

    ; don't count the top group or empty groups
    (while (< i (- (vector-length grpLst) 1))
      (set! actG (vector-ref grpLst i))
      (set! chldrn (gimp-item-get-children actG))
      (when (> (car chldrn) 0)
        (set! total (+ total (car(gimp-item-get-expanded actG))))
        (set! c (+ c 1))
      )
      (set! i (+ i 1))
    )
   
    (if (> c 0)(set! average (/ total c)))
    (if (>= average 0.5)(set! expand 0))
    (if (< average 0.5)(set! expand 1))
    (if (= average 0)(set! expand 0))
    (if (= average 1)(set! expand 1))
    (if debug
      (gimp-message
        (string-append
          " average expanded state -> " (number->string average)
          "\n state for toggle -> "(number->string (trunc expand))

        )
      )
    )

  expand
  )
)