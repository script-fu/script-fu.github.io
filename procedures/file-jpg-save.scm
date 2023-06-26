; saves an image as a jpeg of a specified quality
(define (file-jpg-save img fileName quality)
  (let*
    (
      (exportName "")
    )

    (set! exportName (car (strbreakup fileName ".xcf")))
    (set! exportName (string-append exportName ".jpg"))

    (if debug (gimp-message (string-append " exporting : " exportName)))

    (file-jpeg-save 1
                    img
                    1 ;number of drawables to save
                    (cadr(gimp-image-get-selected-layers img))
                    exportName
                    quality
                    0 ;smoothing
                    1 ;optimise
                    1 ;progressive
                    0 ; cmyk softproofing
                    2 ;subsampling 4:4:4
                    1 ;baseline
                    0 ;restart markers
                    0 ; dct integer
    )
  )

)

