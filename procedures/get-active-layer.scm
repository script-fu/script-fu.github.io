; macro to get the active drawable in an image, returns a layer/mask/group id
(define (get-active-layer img)
  (if (> (car(gimp-image-get-selected-layers img)) 0)
    (vector-ref (cadr(gimp-image-get-selected-layers img))0))
)
