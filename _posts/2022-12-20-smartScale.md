## (gimp-image-scale)

*A few scaling related procedure calls, also finds the image and layer sizes*

```scheme
(define (smartScale img layer pixels scaleX scaleY allLayers interpolation)
 (let*
 (
  (imgWidth (car (gimp-image-width img)))
  (imgHeight (car (gimp-image-height img)))
  (layerWidth (car (gimp-drawable-width layer)))
  (layerHeight (car (gimp-drawable-height layer)))
 )

 (gimp-context-set-interpolation interpolation)

 (if(= pixels 1)
  (if(= allLayers 1)
   (gimp-image-scale img scaleX scaleY)
  )
 )

 (if(= pixels 0)
  (if(= allLayers 1)
   (gimp-image-scale img (* scaleX imgWidth) (* scaleY imgHeight))
  )
 )

 (if(= pixels 1)
  (if(= allLayers 0)
   (gimp-layer-scale layer scaleX scaleY TRUE)
  )
 )

 (if(= pixels 0)
  (if(= allLayers 0)
   (gimp-layer-scale layer (* scaleX layerWidth) (* scaleY layerHeight) TRUE)
  )
 )

 )
)


(script-fu-register "smartScale"
 ""
 "scale an image or layer by pixels or percent by interpolation method"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
```

*Here's a menu option, Script-Fu->smartScaleExample*   


```scheme
(define (smartScaleExample img drawable)
 (let*
 (
  (scale 0.5)
  (mode 4)
  (pixels 0)
  (allLayers 1)
 )

 (gimp-image-undo-group-start img)
 (smartScale img drawable pixels scale scale allLayers mode)
 (gimp-displays-flush)
 (gimp-image-undo-group-end img)

 )
)


(script-fu-register "smartScaleExample"
 "smartScaleExample"
 "use the smartScale procedure"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
(script-fu-menu-register "smartScaleExample" "<Image>/Script-Fu")

```
