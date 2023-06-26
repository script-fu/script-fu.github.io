; filters a list, removing duplicates, returns a new list
(define (remove-duplicates grpLst)
  (let*
    (
      (i 0)(actGrp 0)(uniqGrps ())
    )
    
    (if (list? grpLst) (set! grpLst (list->vector grpLst)))
    (while (< i (vector-length grpLst))
      (set! actGrp (vector-ref grpLst i))
      (when (not (member actGrp uniqGrps))
         (set! uniqGrps (append uniqGrps (list actGrp)))
       )
      (set! i (+ i 1))
    )

  uniqGrps
  )
)