(define (reportActiveLayer img drawable)
 (let*
 (
  (parent 0)
  (position 0)
  (drawableMask 0)
  (drawableName "")
  (activeLayerAndMask 0)
  (parentName "layer has no parent")
 )

 (set! activeLayerAndMask (activeLayer img drawable))
 (set! drawable  (vector-ref activeLayerAndMask 0))
 (set! drawableMask (vector-ref activeLayerAndMask 1))
 (set! drawableName (vector-ref activeLayerAndMask 2))
 (set! parent (car (gimp-item-get-parent drawable)))
 (set! position (car (gimp-image-get-item-position img drawable)))
 (if (> parent 0) (set! parentName (car (gimp-item-get-name parent))))

 (gimp-message (string-append "  layer ID -> " (number->string drawable)
                              "\n  mask -> " (number->string drawableMask)
                              "\n  name -> " drawableName
                              "\n  tree position -> " (number->string position)
                              "\n  parent name -> "  parentName

                              ))
 )
)

(script-fu-register "reportActiveLayer"
 "reportActiveLayer"
 "prints the active layer to the error console"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
(script-fu-menu-register "reportActiveLayer" "<Image>/Script-Fu")
