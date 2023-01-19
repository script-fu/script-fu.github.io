(define (adjustmentLayers img drawable)
 (let*
  (
  (activeLayerAndMask 0)
  (drawableMask 0)
  (drawableName 0)
  (parent 0)
  (parentName 0)
  (position 0)
  (adjustmentGroup 0)
  (adjustmentLayers 0)
  (endAdjustments 0)
  (passThrough 61)
  (dodgeMode 42)
  (startDodge 107)
  (burnMode 43)
  (startBurn 107)
  (originalPosition 0)
  (dodgeLayer 0)
  (burnLayer 0)
  (whiteMask 0)
  (dodgeOpacity 5)
  (burnOpacity 5)
  )

  (gimp-image-undo-group-start img)
  (set! activeLayerAndMask (activeLayer img drawable))
  (set! drawable  (vector-ref activeLayerAndMask 0))
  (set! drawableMask (vector-ref activeLayerAndMask 1))
  (set! drawableName (vector-ref activeLayerAndMask 2))
  (set! originalPosition (car (gimp-image-get-item-position img drawable)))
  (set! parent (car (gimp-item-get-parent drawable)))
  (if (> parent 0) (set! parentName (car (gimp-item-get-name parent))))

  (set! adjustmentGroup (car (gimp-layer-group-new img)))
 	(gimp-image-insert-layer img adjustmentGroup parent position)
  (gimp-image-reorder-item img adjustmentGroup parent originalPosition)
 	(gimp-item-set-name adjustmentGroup "adjustmentGroup")

  (set! adjustmentLayers (car (gimp-layer-group-new img)))
  (gimp-image-insert-layer img adjustmentLayers adjustmentGroup position)
  (gimp-layer-set-mode adjustmentLayers passThrough)
  (gimp-item-set-name adjustmentLayers "adjustmentLayers")

  (set! endAdjustments (car (gimp-layer-group-new img)))
  (gimp-image-insert-layer img endAdjustments adjustmentGroup position)
  (gimp-item-set-name endAdjustments "adjustmentEnd")

  (gimp-image-reorder-item img drawable adjustmentGroup position)
  (gimp-image-raise-item-to-top img adjustmentLayers)
  (gimp-image-lower-item-to-bottom img endAdjustments)

  (set! dodgeLayer (addTonalLayer img
                                  adjustmentLayers
                                  position
                                  "adjustmentDodge"
                                  startDodge
                                  dodgeMode
  ))
  (gimp-item-set-lock-content dodgeLayer TRUE)
  (gimp-layer-set-opacity dodgeLayer dodgeOpacity)

  (set! burnLayer (addTonalLayer img
                                 adjustmentLayers
                                 position
                                 "adjustmentBurn"
                                 startBurn
                                 burnMode
  ))
  (gimp-item-set-lock-content burnLayer TRUE)
  (gimp-layer-set-opacity burnLayer burnOpacity)

  (gimp-layer-add-mask adjustmentLayers
                       (car(gimp-layer-create-mask adjustmentLayers whiteMask)))

  (gimp-displays-flush)
  (gimp-image-undo-group-end img)

 )
)


(script-fu-register "adjustmentLayers"
 "adjustmentGroup"
 "wraps the active layer in an adjustment folder"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
(script-fu-menu-register "adjustmentLayers" "<Image>/Script-Fu")
