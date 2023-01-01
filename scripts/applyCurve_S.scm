(define (applyCurve_S img drawable)
 (let*
 ()

 (curve4Value img drawable 0 0 77 32 174 220 255 255)
 (gimp-displays-flush)

 )
)


(script-fu-register "applyCurve_S"
 ""
 "apply a specified curve to the layer intensity levels"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
