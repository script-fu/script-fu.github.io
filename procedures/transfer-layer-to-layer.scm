; copies a layer to a layer, returns layer ID
;(source image, source layer, destination image, destination layer)
(define (transfer-layer-to-layer srcImg srcL dstImg dstL)
    (gimp-selection-none srcImg)
    (gimp-edit-copy 1 (vector srcL))
    (set! dstL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor dstL)

    (vector-ref (cadr(gimp-image-get-selected-layers srcImg)) 0)
)