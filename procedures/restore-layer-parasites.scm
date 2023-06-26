; attachs a list of parasites to a layer
(define (restore-layer-parasites actL paraStrLst)
  (let*
    (
    (paraVal 0)(i 0)(actP 0)(paraName "")
    )
    
    (while (< i (length paraStrLst))
      (set! paraName (vector-ref (list->vector paraStrLst) i))
      (set! paraVal (vector-ref (list->vector paraStrLst) (+ i 2)))
      (gimp-item-attach-parasite actL (list paraName 0 paraVal))
      (set! i (+ i 3))
    )

  )
)