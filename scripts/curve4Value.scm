(define (curve4Value img drawable x1 y1 x2 y2 x3 y3 x4 y4)
 (let*
 (
  (points())
  (conv (/ 1 255))
 )

 (set! points (make-vector 8 'double))
 (vector-set! points 0 (* x1 conv))
 (vector-set! points 1 (* y1 conv))
 (vector-set! points 2 (* x2 conv))
 (vector-set! points 3 (* y2 conv))
 (vector-set! points 4 (* x3 conv))
 (vector-set! points 5 (* y3 conv))
 (vector-set! points 6 (* x4 conv))
 (vector-set! points 7 (* y4 conv))

 (gimp-drawable-curves-spline drawable 0 8 points)

 )
)


(script-fu-register "curve4Value"
 ""
 "apply a 4 value scripted curve to the intensity levels"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
 )
