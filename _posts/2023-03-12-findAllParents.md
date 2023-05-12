## Find All The Parents

# * Tested in GIMP 2.99.14 *

This isn't a plug-in, just an example of how to find all those parents.

*Returns a list of all the parents of a given folder*

```scheme
(define (findAllParents img drawable)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent drawable)))

    (when (> parent 0)
      (while (> parent 0)
        (set! allParents (append allParents (list parent)))
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )

    allParents
  )
)
```