#!/usr/bin/env gimp-script-fu-interpreter-3.0
;Under GNU GENERAL PUBLIC LICENSE Version 3
(define (script-fu-exitIsolation img drawables) 
  (let*
    (
      (layerList 0)
    )

    (gimp-image-undo-group-start img)

    ; when the plugin is not locked via a text file
    (when (= (plugin-get-lock "exitIsolation") 0) 
      (plugin-set-lock "exitIsolation" 1) ; now lock it, in theory...
      ; store all the layers and groups
      (set! layerList (layerScan img 0))
      (revertLayer img layerList "isolated") 
      (revertLayer img layerList "hidden")
      (revertLayer img layerList "isoParent")
      (plugin-set-lock "exitIsolation" 0) ; unlock the plugin
      (plugin-set-lock "isolateSelected" 0) ; unlock the isolate plugin
      (gimp-displays-flush)
    )

    (gimp-image-undo-group-end img)

  )
)


(define (revertLayer img layerList tag)
  (let*
    (
      (taggedList 0)(taggedCount 0)(i 0)(layer 0)(parasites 0)
      (visTag 0)(colTag 0)(modeTag 0)(opaTag 0)(visTag 0)
    )

    (set! taggedList (findLayersTagged img layerList tag))
    (set! taggedCount (vector-length taggedList))
    (when (> taggedCount 0)
      (set! i 0)
      (while (< i taggedCount)
        (set! layer (vector-ref taggedList i))
        (set! parasites (length (car(gimp-item-get-parasite-list layer))))
        (when (> parasites 0)
            (set! visTag (caddar (gimp-item-get-parasite layer "visTag")))
            (set! visTag (string->number visTag))
            (set! colTag (caddar (gimp-item-get-parasite layer "colTag")))
            (set! colTag (string->number colTag))
            (set! modeTag (caddar (gimp-item-get-parasite layer "modeTag")))
            (set! modeTag (string->number modeTag))
            (set! opaTag (caddar (gimp-item-get-parasite layer "opaTag")))
            (set! opaTag (string->number opaTag))
            (gimp-item-set-visible layer visTag)
            (gimp-item-set-color-tag layer colTag )
            (gimp-layer-set-mode layer modeTag)
            (gimp-layer-set-opacity layer opaTag)
            (gimp-item-detach-parasite layer tag)
            (gimp-item-detach-parasite layer "visTag")
            (gimp-item-detach-parasite layer "colTag")
            (gimp-item-detach-parasite layer "modTag")
            (gimp-item-detach-parasite layer "opaTag") 
            (if (> (car(gimp-layer-get-mask layer)) 0)
              (gimp-layer-set-show-mask layer 0)
            )
        )
        (set! i (+ i 1))
      )
    )

  )
)


(define (plugin-get-lock plugin) 
  (let*
    (
      (input (open-input-file plugin))
      (lockValue 0)
    )

    (if input (set! lockValue (read input)))
    (if input (close-input-port input))

    lockValue
  )
)


(define (plugin-set-lock plugin lock) 
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)


(define (layerScan img rootFolder) ; recursive function
  (let*
    (
      (getChildren 0)(layerList 0)(i 0)(layer 0)(allLayerList ())
    )

    (if (= rootFolder 0)
      (set! getChildren (gimp-image-get-layers img))
      (if (equal? (car (gimp-item-is-group rootFolder)) 1)
        (set! getChildren (gimp-item-get-children rootFolder))
        (set! getChildren (list 1 (list->vector (list rootFolder))))
      )
    )

    (set! layerList (cadr getChildren))
    (while (< i (car getChildren))
      (set! layer (vector-ref layerList i))
      (set! allLayerList (append allLayerList (list layer)))
      (if (equal? (car (gimp-item-is-group layer)) 1)
        (set! allLayerList (append allLayerList (layerScan img layer)))
      )
      (set! i (+ i 1))
    )

    allLayerList
  )
)


(define (findLayersTagged img layerList tag)
  (let*
    (
      (taggedList ())(parasiteCount 0)(layer 0)(parameters 0)(paramCount 0)
      (paramList 0)(pName 0)(i 0)(j 0)(layerCount 0)
    )

    (set! layerList (list->vector layerList))
    (set! layerCount (vector-length layerList))

    (set! i 0)
    (while (< i layerCount)
      (set! layer (vector-ref layerList i))
      (set! parameters (car (gimp-item-get-parasite-list layer)))
      (set! paramCount (length parameters))
      (when (> paramCount 0)
        (set! paramList (list->vector parameters))
        (set! j 0)
        (while(< j paramCount)
          (set! pName (vector-ref paramList j))
          (when (equal? pName tag)
            (set! taggedList (append taggedList (list layer)))
            (set! parasiteCount (+ parasiteCount 1))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector taggedList)
  )
)


(script-fu-register-filter "script-fu-exitIsolation"
  "Isolate Restore" 
  "Restores from isolation mode" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE ;
)
(script-fu-menu-register "script-fu-exitIsolation" "<Image>/Layer")
