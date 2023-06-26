; add alpha to a layer, checking it's not a mask or group first
(define (add-alpha-to-layer actL)
  (let*
    (
      (isMsk(car (gimp-item-id-is-layer-mask actL)))
      (actNme 0)(isGrp 0)(alpha 0)
    )

    (if(= isMsk 1)(set! actL (car(gimp-layer-from-mask actL))))
    (set! actNme (car (gimp-item-get-name actL)))
    (set! isGrp (car (gimp-item-is-group actL )))
    (set! alpha (car (gimp-drawable-has-alpha actL)))
    (if (and (= isGrp 0) (= alpha 0)) (gimp-layer-add-alpha actL))

    actL
  )
)
