; copies a mask to a mask, or layer to a mask with a mode and opacity
; (source image, src mask/layer, destination image, dst mask, mode, opaciy, invert)
; returns the destination mask id
(define (transfer-layer-to-mask-mode-opacity srcImg srcL dstImg dstM mode opa inv applyMask)
  (let*
    (
      (offX 0)
      (offY 0)
      (linear 1)
      (actMsk 0)
      (selection 0)
    )

    (set! offX (car(gimp-drawable-get-offsets srcL)))
    (set! offY (cadr(gimp-drawable-get-offsets srcL)))


    ; a layer may have a mask and alpha, select the mask area before copy?
    (set! actMsk (car (gimp-layer-get-mask srcL)))

    (when (and applyMask (> actMsk 0))
      (gimp-image-select-item srcImg CHANNEL-OP-REPLACE actMsk)
      (set! selection (car (gimp-selection-bounds srcImg)))
      (gimp-selection-none srcImg)
      ; (gimp-selection-invert srcImg)
    )

    ; does the layer have any content?
    (when (< actMsk 0)
      (gimp-image-select-item srcImg CHANNEL-OP-REPLACE srcL)
      (set! selection (car (gimp-selection-bounds srcImg)))
      (gimp-selection-none srcImg)
    )

    ; if there is a selection (first element of selection bounds)
    (when (> selection 0)
      (gimp-edit-copy 1 (vector srcL))

      (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0))
      (gimp-layer-set-offsets dstM offX offY)

      (gimp-selection-none srcImg)
      (gimp-drawable-desaturate dstM DESATURATE-AVERAGE)
      (if inv (gimp-drawable-invert dstM linear))
      (gimp-layer-set-mode dstM mode)
      (gimp-layer-set-opacity dstM opa)

      (gimp-floating-sel-anchor dstM)

      (set! dstM (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
      (set! dstM (car(gimp-layer-get-mask dstM)))
    )

    dstM
  )
)