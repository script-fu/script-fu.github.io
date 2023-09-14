; creates an image size copy of a layer or folder
; (src img, src layer/folder, dst img, dst layer/0, parent for copy, name)
; returns the new layer id
(define (paste-copy img srcL dstImg dstP name)
  (let*
    (
    (actL 0)(cur-width 0)(cur-height 0)(dstL 0)(offX 0)(offY 0)
    )

    ; make a copy of the source group
    (gimp-edit-copy 1 (vector srcL))
    (set! cur-width (car (gimp-drawable-get-width srcL)))
    (set! cur-height (car (gimp-drawable-get-height srcL)))
    (set! offX (car (gimp-drawable-get-offsets srcL)))
    (set! offY (cadr (gimp-drawable-get-offsets srcL)))

    ;add a new destination layer
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
    (gimp-layer-set-offsets dstL offX offY)
    (gimp-layer-set-composite-space dstL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    ; paste onto the destination layer
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))

    ; anchor to temporary layer and resize to image
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-layer-resize-to-image-size actL)
    (gimp-item-set-name actL name)

    actL
  )
)