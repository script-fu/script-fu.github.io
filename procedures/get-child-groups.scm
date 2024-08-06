; returns a vector list of the groups found in the first level of a given group
(define (get-child-groups actG)
  (let*
    (
      (children (gimp-item-get-children actG))
      (childList 0)
      (actL 0)
      (subGrps ())
      (i 0)
    )

    (when (> (car children) 0)
      (set! childList (cadr children))

      (while (< i (car children))
        (set! actL (vector-ref childList i))
          (if (= (car (gimp-item-is-group actL)) 1)
            (set! subGrps (append subGrps (list actL)))
          )
        (set! i (+ i 1))
      )
    )

    (list->vector subGrps)
  )
)
