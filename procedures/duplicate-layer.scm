; duplicates a layer and assigns specific attributes
; (source image, source layer, new layer name, opacity, mode, visibility)
; returns the new layer id
(define (duplicate-layer img srcL name opac mode vis)
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
    (gimp-layer-set-opacity actL opac)
    (gimp-layer-set-mode actL mode)
    (gimp-item-set-name actL name)
    (gimp-item-set-visible actL vis)

  actL
  )
)