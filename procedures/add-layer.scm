; adds a new RGBA layer to an image, inserts, names and fills with a color
; (img, parent, pos, name, mode, opacity, color (list (0-255)(0-255)(0-255))
; blend modes ...LAYER-MODE-NORMAL LAYER-MODE-MULTIPLY LAYER-MODE-ADDITION...
; returns the new layer id
(define (add-layer img actP pos name mode opa col)
  (let*
    (
      (actL 0)
      (wdth  (car (gimp-image-get-width img)))
      (hght (car (gimp-image-get-height img)))
      (typ RGBA-IMAGE)
    )

    (set! actL (car (gimp-layer-new img wdth hght typ name opa mode)))
    (gimp-image-insert-layer img actL actP pos)

    (gimp-context-push)
    (gimp-context-set-opacity 100)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
    (gimp-context-set-foreground col)
    (gimp-drawable-fill actL 0)
    (gimp-context-pop)

    actL
  )
)