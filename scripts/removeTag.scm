(define (removeTag img drawable name)
(let*
  (
  (activeLayer drawable)
  (layerName 0)
  (parasiteExists 0)
  (mask 0)
  )

  (set! layerName (car(gimp-item-get-name drawable)))
  (set! parasiteExists (findTagOnLayer drawable name))

  (when (> parasiteExists 0)
  (gimp-message (string-append " removing tag --> " name))
  (gimp-item-detach-parasite activeLayer name)
  (gimp-item-set-color-tag activeLayer 0)
  )

  (when (= parasiteExists 0)
  (gimp-message (string-append " tag --> " name " <-- not found on layer --> " layerName))
  )

  )
  )


(script-fu-register "removeTag"
  "<Image>/Script-Fu/removeLayerTag"
  "remove tag parasite data" ;description
  "Mark Sweeney"
  "copyright 2022, Mark Sweeney"
  "2022"
  "*"
  SF-IMAGE       "Image"           		0
  SF-DRAWABLE    "Drawable"        		0
  SF-STRING      " remove layer tag "   "findMe"
)
