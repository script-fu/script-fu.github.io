## Source to destination across images - Script for Gimp 2

If you need to copy a complex folder structure across images via script.

Update : Found out that you can also drag a folder structure from one canvas to
         another manually.

*copies the active layer or folder from a source image to a destination image*

```scheme
(define (updatefolderMask src dst)
 (let*
 (
  (srcPixLock 0)
  (dstMask 0)
  (srcLayer 0)
 )
 (when (> src 0)
  (set! srcLayer (car(gimp-layer-from-mask src)))
  (gimp-edit-copy src)
  (set! srcPixLock (car(gimp-item-get-lock-content srcLayer)))
  (set! dstMask (car (gimp-edit-paste (car (gimp-layer-get-mask dst)) 1)))
  (gimp-floating-sel-anchor dstMask)
  (if(> srcPixLock 0)(gimp-item-set-lock-content dst TRUE))
 )
 dstMask
 )
)



(define (layerTree activeFolder srcImg dstImg parent)
(let*
 (
 (layerCount 0)
 (getChildren 0)
 (layerList 0)
 (i 0)
 (layer 0)
 (folderMask 0)
 (folder 0)
 )

 (set! folderMask(car (gimp-layer-get-mask activeFolder)))
 (set! folder (srcLayerToDst activeFolder srcImg dstImg parent))
 (set! getChildren (gimp-item-get-children activeFolder))
 (set! layerCount (car getChildren))
 (set! layerList (cadr getChildren))
 (set! layerList (list->vector (reverse (vector->list layerList))))

 (while (< i layerCount)
  (set! layer (vector-ref layerList i))

  (if (equal? (car (gimp-item-is-group layer)) TRUE)
   (layerTree layer srcImg dstImg folder) ;true - recursive
   (srcLayerToDst layer srcImg dstImg folder) ;false
  )

 (if (= i (- layerCount 1))(updatefolderMask folderMask folder))
 (set! i (+ i 1))
 )

 )
)



(define (srcLayerToDst src srcImg dstImg parent)
 (let*
 (
  (srcLayerWidth 0)
  (srcLayerHeight 0)
  (srcOffsetWidth 0)
  (srcOffsetHeight 0)
  (srcPixLock 0)
  (srcTranLock 0)
  (srcAlphaLock 0)
  (srcName 0)
  (srcMask 0)
  (srcType 0)
  (srcMode 0)
  (srcOpacity 0)
  (srcVis 0)
  (dstLayer 0)
  (dstMask 0)
  (colourTag 0)
 )

 (when(=(car (gimp-item-is-layer-mask src)) 0)
  (when(> (car (gimp-layer-get-mask src)) 0)
   (set! srcMask (car (gimp-layer-get-mask src)))
  )
  (set! srcName (car(gimp-item-get-name src)))
 )

 (set! srcOffsetWidth (car (gimp-drawable-offsets src)))
 (set! srcOffsetHeight (car (cdr (gimp-drawable-offsets src))))
 (set! srcLayerWidth(car(gimp-drawable-width src)))
 (set! srcLayerHeight(car(gimp-drawable-height src)))

 (set! srcType (car(gimp-drawable-type src)))
 (set! srcMode (car(gimp-layer-get-mode src)))
 (set! srcOpacity (car(gimp-layer-get-opacity src)))
 (set! colourTag (car(gimp-item-get-color-tag src)))
 (set! srcVis (car(gimp-item-get-visible src)))

 (set! srcPixLock (car(gimp-item-get-lock-content src)))
 (set! srcTranLock (car(gimp-item-get-lock-position src)))
 (set! srcAlphaLock (car(gimp-layer-get-lock-alpha src)))

 (when (equal? (car (gimp-item-is-group src)) FALSE)
  (set! dstLayer (car (gimp-layer-new dstImg
                                      srcLayerWidth
                                      srcLayerHeight
                                      srcType
                                      srcName
                                      srcOpacity
                                      srcMode
                                      )))

  (gimp-image-insert-layer dstImg
                           dstLayer
                           parent
                           0
                           )

  (gimp-layer-set-offsets dstLayer srcOffsetWidth srcOffsetHeight)
  (gimp-item-set-color-tag dstLayer colourTag)
  (gimp-edit-copy src)
  (set! dstLayer (car(gimp-edit-paste dstLayer TRUE)))
  (gimp-floating-sel-anchor dstLayer)
  (set! dstLayer (car(gimp-image-get-active-drawable dstImg)))
  (gimp-item-set-visible dstLayer srcVis)
 )

 (when (equal? (car (gimp-item-is-group src)) TRUE)
  (set! dstLayer (car (gimp-layer-group-new dstImg)))
  (gimp-image-insert-layer dstImg dstLayer parent 0)
  (gimp-item-set-name dstLayer srcName)
  (gimp-layer-set-offsets dstLayer srcOffsetWidth srcOffsetHeight)
  (gimp-item-set-color-tag dstLayer colourTag)
  (gimp-layer-set-opacity dstLayer srcOpacity)
  (gimp-layer-set-mode dstLayer srcMode)
  (gimp-item-set-visible dstLayer srcVis)
 )

 (when (> srcMask 0)
  (set! dstMask (car(gimp-layer-create-mask dstLayer 0)))
  (gimp-layer-add-mask dstLayer dstMask)
  (gimp-edit-copy srcMask)
  (set! dstMask (car (gimp-edit-paste dstMask 1)))
 	(gimp-floating-sel-anchor dstMask)
 )

 (when (equal? (car (gimp-item-is-group src)) FALSE)
  (gimp-item-set-lock-position dstLayer srcTranLock)
  (gimp-layer-set-lock-alpha dstLayer srcAlphaLock)
  (gimp-item-set-lock-content dstLayer srcPixLock)
 )

 dstLayer
 )
)



(define (sourceToDestination image src srcImg dstImg)
 (let*
 (
 )

 (gimp-context-push)
 (gimp-selection-none srcImg)
 (gimp-image-undo-group-start dstImg)

 (if(=(car (gimp-item-is-layer-mask src)) 1)
  (set! src (car(gimp-layer-from-mask src)))
 )

 (if (equal? (car (gimp-item-is-group src)) FALSE)
  (srcLayerToDst src srcImg dstImg 0)
  (layerTree src srcImg dstImg 0)
 )

 (gimp-image-undo-group-end dstImg)
 (gimp-context-pop)
 (gimp-displays-flush)
 )
)


(script-fu-register "sourceToDestination"
"sourceToDestination"
"copies layers or folders from a source image to a destination image"
"Mark Sweeney"
"copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
"2023"
"*"
SF-IMAGE       "Image"             0
SF-DRAWABLE    "Drawable"          0
SF-IMAGE       "src Image"       0
SF-IMAGE       "dst Image"       0
)
(script-fu-menu-register "sourceToDestination" "<Image>/Script-Fu")


```
