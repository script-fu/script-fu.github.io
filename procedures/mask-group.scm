; creates a folder group with a mask
; (source image, layers, parent, masktype)
; ADD-MASK-WHITE
; ADD-MASK-BLACK
; ADD-MASK-ALPHA
; ADD-MASK-ALPHA-TRANSFER
; ADD-MASK-SELECTION
; ADD-MASK-COPY
; ADD-MASK-CHANNEL
; returns the new group id
(define (mask-group img drwbls parent pos masktype)
 (let*
    (
      (mde LAYER-MODE-PASS-THROUGH) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
      (nme "groupNme")
      (numDraw 0)
      (actL 0)
      (i 0)
      (grp 0)
      (mask 0)
    )

    (if (list? drwbls) (set! drwbls (list->vector drwbls)))
    (set! numDraw (vector-length drwbls))
    (set! actL (vector-ref drwbls 0))
    (set! i (- numDraw 1))
    (set! grp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img grp parent pos)
    (gimp-item-set-name grp nme)
    (gimp-layer-set-mode grp mde)
    (gimp-layer-set-composite-space grp LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (while (> i -1)
      (set! actL (vector-ref drwbls i))
      (gimp-image-reorder-item img actL grp 0)
      (set! i (- i 1))
    )

    (when (>= masktype 0)
       (set! mask (car (gimp-layer-create-mask grp masktype)))
       (gimp-layer-add-mask grp mask)
    )

    grp
  )
)