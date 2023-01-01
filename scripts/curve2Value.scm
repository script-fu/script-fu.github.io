(define (curve2Value img drawable x1 y1 x2 y2)
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

 (gimp-drawable-curves-spline drawable 0 4 points)
 drawable
 )
)

(script-fu-register "curve2Value"
 ""
 "apply a 2 value scripted curve to the intensity levels"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
