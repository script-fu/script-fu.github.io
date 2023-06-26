; apply an "s curve" to a layer, increases contrast
(define (apply-s-curve img actL)
  (curve-4-value img actL 0 0 77 32 174 220 255 255)
)