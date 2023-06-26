; duplicates a layer
; (source image, source layer, new layer name)
; returns the new layer id
(define (basic-duplicate-layer img srcL name)
  (let*
    (
      (actL 0)
      (parent 0)
      (pos 0)
    )

    (set! parent (car (gimp-item-get-parent srcL)))
    (set! pos (car (gimp-image-get-item-position img srcL)))
    (set! actL (car (gimp-layer-new-from-drawable srcL img)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-item-set-name actL name)

  actL
  )
)