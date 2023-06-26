; takes a layer and returns it's id, mask id and name as a vector
(define (get-layer-info img actL)
  (let*
    (
      (actMsk 0)(actNme "")
    )

    (when (= (car (gimp-item-id-is-valid actL)) 1)
      (when(=(car (gimp-item-id-is-layer-mask actL)) 0)
        (if(> (car (gimp-layer-get-mask actL)) 0)
          (set! actMsk (car (gimp-layer-get-mask actL)))
        )
        (set! actNme(car(gimp-item-get-name actL)))
      )

      (when(= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actMsk actL)
        (set! actL (car(gimp-layer-from-mask actMsk)))
        (set! actNme (car(gimp-item-get-name actL)))
      )
    )

    (vector actL actMsk actNme)
  )
)