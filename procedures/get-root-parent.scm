; returns the last parent group before root encountered at (-1)
(define (get-root-parent img actL)
  (let*
    (
      (parent 0)(prevParent 0)
    )

    (set! parent (car(gimp-item-get-parent actL)))
   
    (when (> parent 0)
      (while (> parent 0)
        (set! prevParent parent)
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )
   
    prevParent
  )
)
