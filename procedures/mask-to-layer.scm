; copies a mask to a layer or creates a new layer for the copy
; (source image, src mask, destination image, dst layer, dst parent, name)
; returns the destination layer id
(define (mask-to-layer img srcM dstImg dstL dstP name)
  (let*
    (
      (actL 0)(cur-width 0)(cur-height 0)(dstExst dstL)(nmeL "")
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcM))
    (set! cur-width (car (gimp-drawable-get-width srcM)))
    (set! cur-height (car (gimp-drawable-get-height srcM)))
    (when (= dstExst 0)
      (set! dstL (car (gimp-layer-new dstImg
                                      cur-width
                                      cur-height
                                      RGBA-IMAGE
                                      "dstL"
                                      100
                                      LAYER-MODE-NORMAL
                       )
                  )
      )
      (gimp-item-set-visible dstL 0)
      (gimp-image-insert-layer dstImg dstL dstP 0)
      (gimp-layer-set-composite-space dstL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    )
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! nmeL (car (gimp-item-get-name (car (gimp-layer-from-mask srcM)))))
    (gimp-item-set-name actL (string-append nmeL "-" name))

    actL
  )
)