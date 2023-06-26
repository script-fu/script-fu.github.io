; finds a layer in an image by name
; (source image, "name")
; returns the layer id or 0
(define (find-layer img name)
  (let*
    (
      (foundID (car(gimp-image-get-layer-by-name img name)))
    )

  (if debug
    (if (> foundID 0)
    (gimp-message (string-append " found layer -> " name))
      (gimp-message (string-append " not found layer -> " name " ! "))
    )
  )

  (if (< foundID 0) (set! foundID 0))

  foundID
  )
)
