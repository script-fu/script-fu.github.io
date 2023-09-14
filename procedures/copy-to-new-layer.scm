; copy all visible, or a drawable, paste into a destination layer or a new layer
; (src img, src layer/0, dst img, dst layer/0, parent, nme, crop to image size)
; returns the new layer id
(define (copy-to-new-layer img srcL dstImg dstL dstP name crop)
  (let*
    (
    (actL 0)(cur-width 0)(cur-height 0)(dstExst dstL)
    )

    (when (= srcL 0)
      (gimp-selection-none img)
      (gimp-edit-copy-visible img)
      (set! cur-width (car (gimp-image-get-width img)))
      (set! cur-height (car (gimp-image-get-height img)))
    )

    ; get size and ID of first drawable
    (when (> srcL 0)
      (gimp-selection-none img)
      (gimp-edit-copy 1 (vector srcL))
      (set! cur-width (car (gimp-drawable-get-width srcL)))
      (set! cur-height (car (gimp-drawable-get-height srcL)))
    )

    ;add a new destination layer if needed
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
      (gimp-image-insert-layer dstImg dstL dstP 0)
      (gimp-layer-set-composite-space dstL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    )

    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    
    ; floating selection to new layer or anchor to temporary layer?
    (if (= dstExst 1)(gimp-floating-sel-to-layer actL)
      (gimp-floating-sel-anchor actL)
    )

    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name actL name)
    (if (= crop 1)(gimp-layer-resize-to-image-size actL))
    actL
  )
)