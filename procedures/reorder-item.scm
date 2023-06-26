; reorder a single layer or group in the layer stack
; bug workaround, can't reorder item to root 0
; (source image, layer/group, new parent, new position)
; returns the item id
(define (reorder-item img actL parent pos)
  (let*
    (
      (buffL 0)(nme (car (gimp-item-get-name actL)))
    )
      
      (if (> parent 0)(gimp-image-reorder-item img actL parent pos))
      (gimp-selection-none img)
      ; bug workaround, can't reorder to root, remove and insert a copy at pos
      (when (= parent 0)
        (when (= (car (gimp-item-is-group actL)) 0)
          (set! buffL (car(gimp-layer-copy actL 0)))
          (gimp-image-remove-layer img actL)
          (gimp-image-insert-layer img buffL 0 pos)
          (gimp-item-set-name buffL nme)
          (set! actL buffL)
        )
        (when (= (car (gimp-item-is-group actL)) 1)
          (root-group img (vector actL))
        )
      )

    actL
  )
)