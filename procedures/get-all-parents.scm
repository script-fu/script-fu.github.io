(define (get-all-parents img actL)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent actL)))

    (if debug 
      (gimp-message 
        (string-append 
          "found parent ID: " 
          (number->string parent)
        )
      )
    )
    
    (when (> parent 0)
      (while (> parent 0)

        (set! allParents (append allParents (list parent)))
        (if debug 
          (gimp-message 
            (string-append 
              "found parent: " 
              (car(gimp-item-get-name parent))
            )
          )
        )
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )
    allParents
  )
)
