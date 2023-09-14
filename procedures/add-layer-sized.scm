; adds a new layer to an image with options and returns the new layer ID
; (source image, parent of new layer, position in layer stack, width, height,
; offset X, offset Y, name, blend mode, opacity, filled colour, visibility)
(define (add-layer-sized img parent pos wdth hght offX offY nme mde opa col vis)
  (let*
    (
      (actL 0)
      (typ RGBA-IMAGE)
    )

    (set! actL (car (gimp-layer-new img wdth hght typ nme opa mde)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    (gimp-layer-set-offsets actL offX offY)
    (gimp-context-push)
    (gimp-context-set-opacity 100)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
    (gimp-context-set-foreground col)
    (gimp-drawable-fill actL 0)
    (gimp-item-set-visible actL vis)
    (gimp-context-pop)

    actL
  )
)
