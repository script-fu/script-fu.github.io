(define (findLayersTagged img tag)
 (let*
 (
  (taggedList ())
  (parasiteCount 0)
  (layer 0)
  (parameters 0)
  (paramCount 0)
  (paramList 0)
  (currParam 0)
  (paramValue 0)
  (i 0)
  (j 0)
  (layerCount 0)
  (layerList 0)
  (testlayerCount 0)
  (currentLayer 0)
  (currentLayerName 0)
 )

 (set! layerList (layerScan img 0))
 (set! layerCount (length layerList))
 (set! layerList (list->vector layerList))

 (set! i 0)
 (while (< i layerCount)
  (set! layer (vector-ref layerList i))
  (set! paramCount (car(gimp-item-get-parasite-list layer)))

  (when (> paramCount 0)
   (set! parameters (gimp-item-get-parasite-list layer))
   (set! paramCount (car parameters))
   (set! paramList (list->vector(car(cdr parameters))))

   (set! j 0)
   (while(< j paramCount)
    (set! currParam (vector-ref paramList j))
    (set! paramValue (caddr (car (gimp-item-get-parasite layer currParam))))

    (when (equal? currParam tag)
     (set! taggedList (append taggedList (list layer)))
     ;(vector-set! layerList parasiteCount layer)
     (set! parasiteCount (+ parasiteCount 1))
    )
    (set! j (+ j 1))
   )
  )
 (set! i (+ i 1))
 )


 ; ********* demonstrates how to read from the returned list
 (set! testlayerCount (length taggedList))
 (set! taggedList (list->vector taggedList))
 (if(= testlayerCount 0) (gimp-message " * no layers found matching search *"))

 (when (> testlayerCount 0)
  (set! i 0)
  (while (< i testlayerCount)
   (set! currentLayer (vector-ref taggedList i))
   (set! currentLayerName (car(gimp-item-get-name currentLayer)))
   (gimp-message (string-append " layer -> " currentLayerName " has tag " tag))
   ;do scripty stuff to layer here
   (set! i (+ i 1))
  )
 )
  ; *********

 taggedList
 )
)


(script-fu-register "findLayersTagged"
 "findLayersTagged"
 "returns a list of tagged layers"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2020"
 "*"
 SF-IMAGE       "Image"             0
 SF-STRING      "Tag to Find" "findMe"
)
(script-fu-menu-register "findLayersTagged" "<Image>/Script-Fu")
