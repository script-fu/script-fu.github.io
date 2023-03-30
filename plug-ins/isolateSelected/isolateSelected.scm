#!/usr/bin/env gimp-script-fu-interpreter-3.0
;Under GNU GENERAL PUBLIC LICENSE Version 3
(define (script-fu-isolateSelected img drawables) 
  (let*
    (
      (toggleMode 0) ; 1 for the plugin to toggle between isolate and normal
      (layerList 0)(layerCount 0)(i 0)(j 0)(layer 0)(taggedList 0)(isolate 1)
      (allParents ())(parent 0)(pExists 0)(isoParentsList ())(thisParent 0)
      (fileInfo (get-file-info img))(fileNme (vector-ref fileInfo 0))(fndP 0)
    )
    (gimp-image-undo-freeze img)
    ;(gimp-image-undo-group-start img)

    ; when the plugin is not locked via a text file
    (when (= (plugin-get-lock "isolateSelected") 0) 
      (plugin-set-lock "isolateSelected" 1) ; now lock it, in theory...
      (plugin-set-lock "exitIsolation" 1)
      (set! fndP (get-parasite-on-image img "isofilename"))

      ;check for mask selected and revert filename
      (when (= toggleMode 1)
        (filterSelection drawables)
        (when (= fndP 1)
          (set! fileNme (caddar(gimp-image-get-parasite img "isofilename")))
          (gimp-image-set-file img fileNme )
          (gimp-image-detach-parasite img "isofilename")
        )
      )

      ; store all the layers and groups
      (set! layerList (layerScan img 0))

      ; check for existing isolation state
      (set! taggedList (findLayersTagged img layerList "isolated"))
      (if (> (vector-length taggedList) 0) (set! isolate 0))

      ; revert from isolated state...
      (when (= isolate 0)
        (revertLayer img layerList "isolated") 
        (revertLayer img layerList "hidden")
        (revertLayer img layerList "isoParent")
      )

      ;check for mask selected
      (if (= toggleMode 0) (filterSelection drawables))

      ; enter new isolated state for selected drawables
      (if (= toggleMode 0)(set! isolate 1))
      (when (= isolate 1)
        (when (= fndP 0)
          (gimp-image-set-file img 
          " USE \"ISOLATE RESTORE\" OR TOGGLE ISOLATION OFF BEFORE SAVING   ")
          (tag-image img "isofilename" fileNme)
        )
      
        (set! i 0)
        (while (< i (vector-length drawables))
          (set! layer (vector-ref drawables i))
          (isoTagLayer layer "isolated" 2 1)
          (set! parent (car(gimp-item-get-parent layer))) 
          (set! isoParentsList (append isoParentsList (list parent)))
          (when (not (member parent (vector->list drawables)))
            (set! allParents (findAllParents img layer))
            (set! j 0)
            (while (< j (length allParents))
              (set! thisParent (nth j allParents))
              (if (not (member thisParent (vector->list drawables)))
                (isoTagLayer thisParent "isoParent" -1 1)
              )
              (set! j (+ j 1))
            )
          )
          (set! i (+ i 1))
        )

        ; now look through *all* the layers of the image
        (set! layerList (list->vector layerList))
        (set! layerCount (vector-length layerList))
        (set! i 0)
        (while (< i layerCount)
          (set! layer (vector-ref layerList i))
          (when (not (member layer (vector->list drawables)))
            (set! parent (car(gimp-item-get-parent layer)))

            ; if this layer is a member of the same group as an isolated layer
            (when (member parent isoParentsList)
              ; and if it's not been previously processed
              (set! pExists (findParasiteOnLayer layer "isoParent"))
              (if (= pExists 0) (isoTagLayer layer "hidden" 6 0))
            )
          )
          (set! i (+ i 1))
        )
      )

      (plugin-set-lock "isolateSelected" 0) ; unlock the plugin
      (plugin-set-lock "exitIsolation" 0)
      (gimp-displays-flush)
    )

    ;(gimp-image-undo-group-end img)
    (gimp-image-undo-thaw img)
    
  )
)


(define (get-file-info img)
  (let*
    (
      (fileInfo (vector "" "" "" ""))
      (fileName "")
      (fileBase "")
      (fileNoExt "")
      (filePath "")
      (brkTok "/")
    )
    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (set! fileNoExt (car (strbreakup fileBase ".")))
        (set! filePath (unbreakupstr (reverse (cdr(reverse (strbreakup fileName
                                                           brkTok)
                                                  )
                                              )
                                     ) 
                                     brkTok
                       )
        )
        (vector-set! fileInfo 0 fileName)
        (vector-set! fileInfo 1 fileBase)
        (vector-set! fileInfo 2 fileNoExt)
        (vector-set! fileInfo 3 filePath)
      )
    )

    fileInfo
  )
)


(define (filterSelection drawables)
    (when (= (vector-length drawables) 1)
            (when (= (car (gimp-item-id-is-layer-mask 
                          (vector-ref drawables 0))) 1)
                          (vector-set! drawables 0 (car(gimp-layer-from-mask 
                          (vector-ref drawables 0))))
                          (gimp-layer-set-show-mask (vector-ref drawables 0) 1)
            )
    )
    drawables
)


(define (isoTagLayer layer tag col vis)
  (let*
    (
    (isGroup 0)(visTag 0)(colTag 0)(modeTag 0)(opaTag 0)(visTag 0)
    )

    (set! isGroup (car (gimp-item-is-group layer)))
    (set! colTag (car(gimp-item-get-color-tag layer )))
    (set! colTag (number->string colTag))
    (set! visTag (car(gimp-item-get-visible layer)))
    (set! visTag (number->string visTag))
    (set! modeTag (car(gimp-layer-get-mode layer)))
    (set! modeTag (number->string modeTag))
    (set! opaTag (car(gimp-layer-get-opacity layer)))
    (set! opaTag (number->string opaTag))
    (gimp-item-attach-parasite layer (list tag 0 "1"))
    (gimp-item-attach-parasite layer (list "colTag" 0 colTag))
    (gimp-item-attach-parasite layer (list "visTag" 0 visTag))
    (gimp-item-attach-parasite layer (list "modeTag" 0 modeTag))
    (gimp-item-attach-parasite layer (list "opaTag" 0 opaTag))
    (if (> col -1) (gimp-item-set-color-tag layer col))
    (if (= isGroup 0) (gimp-layer-set-mode layer LAYER-MODE-NORMAL))
    (gimp-layer-set-opacity layer 100)
    (gimp-item-set-visible layer vis)

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

;static find layer tagged, uses supplied layer list
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


(define (findParasiteOnLayer drawable tag)
  (let*
    (
      (i 0)(parameters 0)(paramCount 0)(paramList 0)(pName "")(found 0)
    )

    (set! parameters (car (gimp-item-get-parasite-list drawable)))
    (set! paramCount (length parameters))
    (set! paramList (list->vector parameters))

    (when (> paramCount 0)
      (while(< i paramCount)
        (set! pName (vector-ref paramList i))
        
        (when (equal? tag pName)
          (set! found 1)
          (set! i paramCount)
        )
      (set! i (+ i 1))
      )
    )

    found
  )
)


(define (findAllParents img drawable)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent drawable)))

    (when (> parent 0)
      (while (> parent 0)
        (set! allParents (append allParents (list parent)))
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )

    allParents
  )
)


(define (tag-image img name tagV)
  (gimp-image-attach-parasite img (list name 0 tagV))
)


(define (get-parasite-on-image img tag)
  (let*
    (
      (i 0)(param 0)(paramC 0)(paramLst 0)(pName "")(found 0)
    )

    (set! param (car (gimp-image-get-parasite-list img)))
    (set! paramC (length param))
    (set! paramLst (list->vector param))

    (when (> paramC 0)
      (while(< i paramC)
        (set! pName (vector-ref paramLst i))
        
        (when (equal? tag pName)
          (set! found 1)
          (set! i paramC)
        )
      (set! i (+ i 1))
      )
    )

    found
  )
)
(script-fu-register-filter "script-fu-isolateSelected"
  "Isolate" 
  "Isolates the selected layers" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE ;
)
(script-fu-menu-register "script-fu-isolateSelected" "<Image>/Layer")
