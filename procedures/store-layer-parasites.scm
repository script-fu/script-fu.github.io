; returns a list of lists of all the parasites on a layer
(define (store-layer-parasites actL)
  (let*
    (
    (paraLst 0)(parasite 0)(paraStrLst ())(i 0)(actP 0)
    )
    
    (set! paraLst (car (gimp-item-get-parasite-list actL)))
    
    (when (> (length paraLst) 0)
      (while(< i (length paraLst))
        (set! actP (vector-ref (list->vector paraLst) i))
        (set! parasite (car(gimp-item-get-parasite actL actP)))
        (set! paraStrLst (append paraStrLst parasite))
        (set! i (+ i 1))
      )
    )

    paraStrLst
  )
)
