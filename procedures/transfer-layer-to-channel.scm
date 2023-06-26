; copies a layer to a channel
;(source image, source layer, destination channel)
(define (transfer-layer-to-channel img srcL dstChn)
    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcL))
    (set! dstChn (vector-ref (cadr(gimp-edit-paste dstChn 1)) 0 ))
    (gimp-floating-sel-anchor dstChn)
)