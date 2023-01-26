(define (curveDropMid img drawable)
 (let*
  ()
 (curve3Value img drawable 0 0 160 65 255 255)
 (gimp-displays-flush)
 )
)

(script-fu-register "curveDropMid"
 "valueDropMid"
 "apply a specific curve to the image intensity levels"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
(script-fu-menu-register "curveDropMid" "<Image>/Script-Fu")
