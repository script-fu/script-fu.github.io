; copy an area determined by the destination mask size from a layer to the mask
; (src img, src layer, dst mask)

(define (copy-mask-area-from-layer-to-mask img src dstMask)
  (gimp-image-select-item img CHANNEL-OP-REPLACE dstMask)
  (gimp-edit-copy 1 (vector src))
  (set! dstMask (vector-ref (cadr(gimp-edit-paste dstMask 1)) 0 ))
  (gimp-floating-sel-anchor dstMask)
)