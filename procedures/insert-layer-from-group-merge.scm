; merge a given group and insert it as a named layer, option to discard mask
; MASK-APPLY (0), MASK-DISCARD (1)
(define (insert-layer-from-group-merge img actG name discardMask vis)
  (let*
    (
      (actL 0)
      (parent (car(gimp-item-get-parent actG)))
      (mask 0)
    )

  ; copy the group to a new layer in the item folder
  (set! actL (car(gimp-layer-copy actG 1)))
  (gimp-image-insert-layer img actL parent 0)

  (gimp-item-set-visible actL vis)

  (set! actL (car(gimp-image-merge-layer-group img actL)))

  (gimp-item-set-visible actL vis)

  (when (>= discardMask 0)
    (set! mask (car(gimp-layer-get-mask actL)))
    (if (> mask 0) (gimp-layer-remove-mask actL discardMask))
  )

  (gimp-item-set-name actL name)

  actL
  )
)
