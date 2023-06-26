; removes a specific layer parasite, untagging it, also resets colour to 0
(define (remove-layer-tag actL name colReset)
  (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
    (set! actL (car(gimp-layer-from-mask actL)))
  )
  (gimp-item-detach-parasite actL name)
  (if (= colReset 1)(gimp-item-set-color-tag actL 0))
)