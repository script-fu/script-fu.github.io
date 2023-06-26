; apply a brightning curve to a layer
(define (apply-bright-curve img actL)
  (curve-3-value img actL 0 0 159 222 255 255)
)