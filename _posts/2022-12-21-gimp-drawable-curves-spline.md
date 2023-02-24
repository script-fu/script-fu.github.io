## Adjustment curves - Script for Gimp 2

*A wrapper around this procedure can be useful, in this case
when I wanted a scripted "Colours->Curves" for the image value.*

```scheme
(define (curve3Value img drawable x1 y1 x2 y2 x3 y3)
 (let*
 (
  (points())
  (conv (/ 1 255))
 )

 (set! points (make-vector 6 'double))
 (vector-set! points 0 (* x1 conv) )
 (vector-set! points 1 (* y1 conv) )
 (vector-set! points 2 (* x2 conv) )
 (vector-set! points 3 (* y2 conv) )
 (vector-set! points 4 (* x3 conv) )
 (vector-set! points 5 (* y3 conv) )

 (gimp-drawable-curves-spline drawable 0 6 points)
 drawable
 )
)

(script-fu-register "curve3Value"
 ""
 "apply a 3 value scripted curve to the intensity levels"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)

```

*Here's a menu option, Script-Fu->curveDropMid*   


```scheme
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

```
