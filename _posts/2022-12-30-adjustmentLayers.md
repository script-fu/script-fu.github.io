## simple adjustment layers

Layers can be used as adjustments by selecting different modes and putting them
above a target layer.  Here is an example of that method.  It puts two layers
above the source that can be used to create non-linear intensity changes.
It also wraps up the target layer in a folder structure that limits the range
of the effect to just the source layer.  More layers doing different things
can be added manually, or just edit the script to suite your needs.

To use, install these two scripts, restart Gimp and load an image.  Then select
a layer and run *Script-Fu->AdjustmentGroup*  Then adjust the opacity of
the dodge and burn layers to give changes to the intensity levels.
Edit the adjustmentLayers mask to control the region adjusted.

Done as suggestion from CinnamonCajaCrunch on r/Gimp

*This script creates a wrapper around a layer that allows simple adjustments*  
```scheme
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
```

*This procedure is used to easily add extra layers to an image*
```scheme
(define (addTonalLayer img parent position name tone mode)
 (let*
  (
   (activeLayer 0)
   (toneLayer 0)
   (cur-width 0)
   (cur-height 0)
   (normalMode 28)
  )
  (gimp-context-push)
  (set! cur-width  (car (gimp-image-width img)))
  (set! cur-height (car (gimp-image-height img)))
  (set! toneLayer (car (gimp-layer-new img cur-width cur-height 0 name 100 28)))
  (gimp-image-insert-layer img toneLayer parent position)
  (gimp-layer-set-opacity toneLayer 100)
  (gimp-layer-set-mode toneLayer mode)
  (gimp-context-set-foreground (list tone tone tone))
  (gimp-context-set-opacity 100)
  (gimp-drawable-fill toneLayer 0)
  (gimp-context-pop)
  toneLayer
 )
)

(script-fu-register "addTonalLayer"
 ""
 "add a tonal layer, sized from the image"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
```
