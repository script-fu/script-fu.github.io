(define (addMixerGroup img parent position name tag colour mode)
 (let*
 (
 (returnGroup 0)
 (tagValue "42")
 )
 (set! returnGroup (car (gimp-layer-group-new img)))
 (gimp-image-insert-layer img returnGroup parent position)
 (gimp-layer-set-mode returnGroup mode)
 (gimp-item-set-name returnGroup name)
 (tagLayerSilent returnGroup tag tagValue colour)
 returnGroup
 )
)


(define (addMixerLayer img source parent name tag mode)
 (let*
 (
  (mixerLayer 0)
  (zeroOpacity 0)
  (position 0)
  (black 0)
  (tagValue "42")
 )

 (set! mixerLayer (addTonalLayer img
                                 parent
                                 position
                                 name
                                 black
                                 mode
 ))

 (set! mixerLayer (copyToLayer img source mixerLayer))
 (gimp-layer-set-opacity mixerLayer zeroOpacity)
 (tagLayerSilent mixerLayer tag tagValue black)
 mixerLayer
 )
)

(define (tagLayerSilent layer name tagValue colour)
 (let*
 (
 )

 (when(= (car (gimp-item-is-layer-mask layer)) 1)
  (set! layer (car(gimp-layer-from-mask layer)))
 )

 (gimp-item-attach-parasite layer (list name 1 tagValue))
 (gimp-item-set-color-tag layer colour)
 )
)

(define (adjustmentMixer img drawable)
 (let*
 (
  (activeLayerAndMask 0)
  (drawableMask 0)
  (drawableName 0)
  (parent 0)
  (parentName 0)
  (position 0)
  (normalM 28)
  (linear 1)
  (adjustmentGroup 0)
  (adjustmentMixer 0)
  (endAdjustments 0)
  (sourceGroup 0)
  (adjustmentsMask 0)
  (passThrough 61)
  (zeroOpacity 0)
  (origPos 0)
  (whiteMask 0)
  (black 0)
  (blueFolder 1)
  (greenFolder 2)
  (yellowFolder 3)
  (orangeFolder 4)
  (redFolder 6)
  (noColour 0)
  (adjustTone 0)
  (adjustChroma 0)
  (adjustHue 0)
  (curve_S_layer 0)
  (burnLayer 0)
  (dodgeLayer 0)
  (chroma_zero_layer 0)
  (chroma_enhance_layer 0)
  (hue_tint_layer 0)
  (enhanceChroma 0)
 )

 (gimp-context-push)
 (gimp-image-undo-group-start img)

 (set! activeLayerAndMask (activeLayer img drawable))
 (set! drawable  (vector-ref activeLayerAndMask 0))
 (set! drawableMask (vector-ref activeLayerAndMask 1))
 (set! drawableName (vector-ref activeLayerAndMask 2))
 (set! origPos (car (gimp-image-get-item-position img drawable)))
 (set! parent (car (gimp-item-get-parent drawable)))
 (if (> parent 0) (set! parentName (car (gimp-item-get-name parent))))

 (set! adjustmentGroup (addMixerGroup img
                                      parent
                                      origPos
                                      "adjustmentGroup"
                                      "adjustmentRoot"
                                      noColour
                                      LAYER-MODE-NORMAL
                                      ))

 (set! adjustmentMixer (addMixerGroup img
                                      adjustmentGroup
                                      position
                                      "adjustmentMixer"
                                      "mixerRoot"
                                      noColour
                                      LAYER-MODE-PASS-THROUGH
                                      ))

 (set! enhanceChroma (addMixerGroup img
                                adjustmentMixer
                                position
                                "enhanceHue"
                                "enhanceRoot"
                                redFolder
                                LAYER-MODE-PASS-THROUGH
                                ))

 (set! adjustTone (addMixerGroup img
                                   adjustmentMixer
                                   position
                                   "adjustTone"
                                   "curvesRoot"
                                   greenFolder
                                   LAYER-MODE-PASS-THROUGH
                                   ))
 (gimp-layer-set-opacity adjustTone 50)

 (set! adjustChroma (addMixerGroup img
                                   adjustmentMixer
                                   position
                                   "adjustChroma"
                                   "chromaRoot"
                                   yellowFolder
                                   LAYER-MODE-PASS-THROUGH
                                   ))

 (set! sourceGroup (addMixerGroup img
                                  adjustmentGroup
                                  position
                                  "original-source"
                                  "mixerSource"
                                  orangeFolder
                                  LAYER-MODE-NORMAL
                                  ))

 (set! endAdjustments (addMixerGroup img
                                     adjustmentGroup
                                     position
                                     "adjustmentEnd"
                                     "mixerEnd"
                                     noColour
                                     LAYER-MODE-NORMAL
                                     ))


 (gimp-image-reorder-item img drawable sourceGroup position)
 (gimp-image-raise-item-to-top img adjustmentMixer)
 (gimp-image-lower-item-to-bottom img endAdjustments)
 (gimp-layer-add-mask adjustmentMixer
                     (car(gimp-layer-create-mask adjustmentMixer whiteMask)))
 (set! adjustmentsMask (car (gimp-layer-get-mask adjustmentMixer)))

 (set! curve_S_layer (addMixerLayer img
                                    drawable
                                    adjustTone
                                    "s-curve"
                                    "sCurve"
                                    LAYER-MODE-NORMAL
                                    ))
 (applyCurve_S img curve_S_layer)
 (gimp-item-set-lock-content curve_S_layer TRUE)
 (gimp-layer-set-opacity curve_S_layer zeroOpacity)

 (set! dodgeLayer (addMixerLayer img
                                 drawable
                                 adjustTone
                                 "dodge"
                                 "dodge"
                                 LAYER-MODE-DODGE
                                 ))
 (curve2Value img dodgeLayer 0 0 255 128)
 (gimp-item-set-lock-content dodgeLayer TRUE)
 (gimp-layer-set-opacity dodgeLayer zeroOpacity)

 (set! burnLayer (addMixerLayer img
                                drawable
                                adjustTone
                                "burn"
                                "burn"
                                LAYER-MODE-BURN
                                ))
 (curve2Value img burnLayer 0 128 255 255)
 (gimp-item-set-lock-content burnLayer TRUE)
 (gimp-layer-set-opacity burnLayer zeroOpacity)

 (set! chroma_zero_layer (addMixerLayer img
                                        drawable
                                        adjustChroma
                                        "desaturate"
                                        "desaturate"
                                        LAYER-MODE-LCH-CHROMA
                                        ))
 (gimp-drawable-desaturate chroma_zero_layer DESATURATE-AVERAGE)
 (gimp-item-set-lock-content chroma_zero_layer TRUE)
 (gimp-layer-set-opacity chroma_zero_layer zeroOpacity)

 (set! chroma_enhance_layer (addMixerLayer img
                                        drawable
                                        enhanceChroma
                                        "enhance"
                                        "enhance"
                                        LAYER-MODE-NORMAL
                                        ))
 (plug-in-color-enhance RUN-NONINTERACTIVE img chroma_enhance_layer)
 (gimp-item-set-lock-content chroma_enhance_layer TRUE)
 (gimp-layer-set-opacity chroma_enhance_layer zeroOpacity)

 (set! hue_tint_layer (addMixerLayer img
                                         drawable
                                         adjustChroma
                                         "tint"
                                         "tint"
                                         LAYER-MODE-LCH-COLOR
                                         ))
 (gimp-context-set-foreground (list 220 146 43))
 (gimp-context-set-opacity 100)
 (gimp-context-set-paint-mode normalM)
 (gimp-drawable-fill hue_tint_layer FILL-FOREGROUND)
 (gimp-context-set-default-colors)
 (gimp-layer-set-opacity hue_tint_layer zeroOpacity)

 (gimp-drawable-invert adjustmentsMask linear)
 (gimp-displays-flush)
 (gimp-image-undo-group-end img)
 (gimp-context-pop)

 )
)


(script-fu-register "adjustmentMixer"
 "createMixer"
 "wraps the active layer in an adjustment folder with a mixer for effects"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
(script-fu-menu-register "adjustmentMixer" "<Image>/Script-Fu/adjustmentMixer")
