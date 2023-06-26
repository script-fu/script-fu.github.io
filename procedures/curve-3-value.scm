; apply a 3 value curve to a layer with specified points
; (image, layer id, curve point (x,y), (x,y), (x,y))
(define (curve-3-value img actL x1 y1 x2 y2 x3 y3)
  (let*
    (
      (points())
      (conv (/ 1 255))
    )

    (set! points (make-vector 6 'double))
    (vector-set! points 0 (* x1 conv))
    (vector-set! points 1 (* y1 conv))
    (vector-set! points 2 (* x2 conv))
    (vector-set! points 3 (* y2 conv))
    (vector-set! points 4 (* x3 conv))
    (vector-set! points 5 (* y3 conv))

    (gimp-drawable-curves-spline actL 0 6 points)
    actL
  )
)