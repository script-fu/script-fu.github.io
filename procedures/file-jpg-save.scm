; saves an image as a jpeg of a specified quality
(define (file-jpg-save img fileName quality)
  (let*
    (
      (exportName "")
    )

    (set! exportName (car (strbreakup fileName ".xcf")))
    (set! exportName (string-append exportName ".jpg"))

    (if debug (gimp-message (string-append " exporting : " exportName)))

    (file-jpeg-export 1
                      img
                      exportName
                      quality
                      0 ;smoothing
                      1 ;optimise
                      1 ;progressive
                      0 ; cmyk softproofing
                      "sub-sampling-1x1" ;subsampling 4:4:4
                      1 ;baseline
                      0 ;restart markers
                      "integer" ; dct integer
    )
  )

)