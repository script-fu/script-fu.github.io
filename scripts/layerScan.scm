(define (layerScan img activeFolder)
(let*
 (
 (layerCount 0)
 (getChildren 0)
 (layerList 0)
 (i 0)
 (layer 0)
 (allLayerList ())
 )

 (if (= activeFolder 0)
  (set! getChildren (gimp-image-get-layers img));if true
  (if (equal? (car (gimp-item-is-group activeFolder)) TRUE); if false
   (set! getChildren (gimp-item-get-children activeFolder)) ;if true
   (set! getChildren (list 1 (list->vector (list activeFolder))));if false
  )
 )

 (set! layerCount (car getChildren))
 (set! layerList (cadr getChildren))

 (while (< i layerCount)
  (set! layer (vector-ref layerList i))
  (set! allLayerList (append allLayerList (list layer)))

  (when (equal? (car (gimp-item-is-group layer)) FALSE)
   ;do something to the layer
  )

  (when (equal? (car (gimp-item-is-group layer)) TRUE)
   ;do something to the folder

   (set! allLayerList (append allLayerList (layerScan img layer))) ;recursive
  )

 (set! i (+ i 1))
 )

 allLayerList
 )
)


(script-fu-register "layerScan"
 "layerScan"
 "finds all the layers in the image, or all the layers in a folder"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
