; adds a new layer the same size as the image
; image, parent layer or group, position in tree, name, blend mode
(define (add-image-size-layer img parent pos name mode)
 (let*
    (
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (actL 0)
    )

    (set! actL (car (gimp-layer-new img
                                    width
                                    height
                                    RGBA-IMAGE
                                    name
                                    100
                                    mode
                       )
                  )
    )

    (gimp-image-insert-layer img actL parent pos)

  actL
  )
)
