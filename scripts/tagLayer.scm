(define (tagLayer layer name tagValue colour)
(let*
  (
  )

  (when(= (car (gimp-item-is-layer-mask layer)) 1)
    (set! layer (car(gimp-layer-from-mask layer)))
    )

    (gimp-item-attach-parasite layer (list name 1 tagValue))
    (gimp-item-set-color-tag layer colour)
    (gimp-message (string-append " tagLayer -> " (car(gimp-item-get-name layer))))
  )
)

(script-fu-register "tagLayer"
  ""
  "tag layer with parasite data and set colour" ;description
  "Mark Sweeney"
  "copyright 2022, Mark Sweeney"
  "2022"
  ""
  SF-STRING      "layer tagged as"   "findMe"
)
