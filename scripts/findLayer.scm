(define (findLayer img name)
(let*
 (
 (matchedLayer 0)
 (matchName 0)
 (layerCount 0)
 (layerList 0)
 (i 0)
)

 (set! layerList (layerScan img 0))
 (set! layerCount (length layerList))
 (set! layerList (list->vector layerList))

 (while (< i layerCount)
  (set! matchName (car(gimp-item-get-name (vector-ref layerList i))))
  (when (equal? name matchName)
   (set! matchedLayer (vector-ref layerList i))
   (set! i layerCount)
   (gimp-message (string-append " found layer -> " name " : ID = "
                                (number->string matchedLayer)))
   ;(gimp-image-set-active-layer img matchedLayer) make it the active layer
  )
 (set! i (+ i 1))
 )

 (when (= matchedLayer 0)
  (gimp-message (string-append "* not found layer --> " name))
 )

 matchedLayer
 )
)

(script-fu-register "findLayer"
 "findLayerByName"
 "finds a layer by it's name, returns its ID"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2020"
 "*"
 SF-IMAGE       "Image"             0
 SF-STRING      "Layer to Find" "findMe"
)
(script-fu-menu-register "findLayer" "<Image>/Script-Fu")
