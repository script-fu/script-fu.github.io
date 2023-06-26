; first layer in a given list is set to show it's mask
(define (show-mask drwbles isolated)
  (let*
    (
      (actL (vector-ref drwbles 0))(size (vector-length drwbles))
      (show (- 1 isolated))
    )

    ; if it's a mask and the only item selected, switch to layer, show the mask
    (when (and (= size 1) (= (car (gimp-item-id-is-layer-mask actL )) 1))
      (if debug (gimp-message " only a mask selected "))
      (vector-set! drwbles 0 (car(gimp-layer-from-mask actL)))
      (gimp-layer-set-show-mask (vector-ref drwbles 0) show)
    )

  drwbles
  )
)
