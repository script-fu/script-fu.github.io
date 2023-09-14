; adds a group to the image under a parent, stack position, name and blendmode
(define (add-group img parent pos nme mde)
 (let*
    (
      (actG 0)
    )

    (set! actG (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img actG parent pos)
    (gimp-item-set-name actG nme)
    (gimp-layer-set-mode actG mde)
    (gimp-layer-set-composite-space actG LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    actG
  )
)