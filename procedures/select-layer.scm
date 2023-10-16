; makes sure user selection is a layer and not a mask
(define (select-layer actL)
  (let*
    (
      (isMsk(car (gimp-item-id-is-layer-mask actL)))
    )

    (if(= isMsk 1)(set! actL (car(gimp-layer-from-mask actL))))

    actL
  )
)
