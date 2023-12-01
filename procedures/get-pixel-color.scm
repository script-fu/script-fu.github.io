; returns a pixl colour as a list at a px py location on a given layer and image
(define (get-pixel-color img actL px py)
  (let*
    (
      (offX 0)(offY 0)(col 0)
    )

    ; take into account layer offset
    (set! offX (+ (car (gimp-drawable-get-offsets actL)) px))
    (set! offY (+ (cadr (gimp-drawable-get-offsets actL)) py))
    (set! col (car (gimp-image-pick-color img 1 (vector actL) offX offY 0 0 1)))

    (if debug
      (gimp-message
        (string-append
          " colour picking "
          "\n sample layer is " (car (gimp-item-get-name actL))
          "\n image ID is " (number->string img)
          "\n sample offset is : ("(number->string px) ", " 
                                   (number->string py) ")"
          "\n sample point is : (" (number->string offX) ", "
                                   (number->string offY) ")"
        )
      )
    )

    (if debug (print-RGB "freshly picked" col))

    col
  )
)
