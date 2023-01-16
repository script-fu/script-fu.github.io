## source to destination across images

If you need to copy a complex folder structure across images, copy and paste
might not work.

Here's a script that copies the active folder tree or layer from the source
image to a destination image, and goes several folders deep.

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



(define (layerNest startGroup srcImg dstImg)
(let*
 (
  (i 0)(j 0)(k 0)(l 0)(m 0)(n 0)
  (layer 0)
  (layerCount 0)
  (getChildren 0)
  (topTreeCount 0)
  (topTreeLayerList 0)
  (secondGetChildren 0)
  (secondGroupCount 0)
  (secondGroupList 0)
  (thirdGetChildren 0)
  (thirdGroupCount 0)
  (thirdGroupList 0)
  (fourthGetChildren 0)
  (fourthGroupCount 0)
  (fourthGroupList 0)
  (fithGetChildren 0)
  (fithGroupCount 0)
  (fithGroupList 0)
  (sixthGetChildren 0)
  (sixthGroupCount 0)
  (sixthGroupList 0)
  (returnList 0)
  (returnLayerList 0)
  (folder 0)
  (folderName 0)
  (secFolder 0)
  (secFolderName 0)
  (thirdFolder 0)
  (thirdFolderName 0)
  (fourthFolder 0)
  (fourthFolderName 0)
  (fithFolder 0)
  (fithFolderName 0)
  (sixthFolder 0)
  (sixthFolderName 0)
  (folderMask 0)
  (secFolderMask 0)
  (thirdFolderMask 0)
  (fourthFolderMask 0)
  (fithFolderMask 0)
  (sixthFolderMask 0)
  (folderMask 0)
 )

 (set! folderMask(car (gimp-layer-get-mask startGroup)))
 (set! folder (srcLayerToDst startGroup srcImg dstImg 0))
 (set! getChildren (gimp-item-get-children startGroup))
 (set! topTreeCount (car getChildren))
 (set! topTreeLayerList (cadr getChildren))

 (set! i (- topTreeCount 1))
 (while (> i -1)
  (set! layer (vector-ref topTreeLayerList i))
  (when (equal? (car (gimp-item-is-group layer)) FALSE)
   (srcLayerToDst layer srcImg dstImg folder)
  )

  (when (equal? (car (gimp-item-is-group layer)) TRUE)
   (set! secFolderMask(car (gimp-layer-get-mask layer)))
   (set! secondGetChildren (gimp-item-get-children layer))
   (set! secondGroupCount (car secondGetChildren))
   (set! secondGroupList (cadr secondGetChildren))
   (set! j (- secondGroupCount 1))
   (set! secFolder (srcLayerToDst layer srcImg dstImg folder))

   (when (> secondGroupCount 0)
    (while (> j -1)
     (set! layer (vector-ref secondGroupList j))
     (when (equal? (car (gimp-item-is-group layer)) FALSE)
      (srcLayerToDst layer srcImg dstImg secFolder)
     )

     (when (equal? (car (gimp-item-is-group layer)) TRUE)
      (set! thirdFolderMask(car (gimp-layer-get-mask layer)))
      (set! thirdGetChildren (gimp-item-get-children layer))
      (set! thirdGroupCount (car thirdGetChildren))
      (set! thirdGroupList (cadr thirdGetChildren))
      (set! k (- thirdGroupCount 1))
      (set! thirdFolder (srcLayerToDst layer srcImg dstImg secFolder))

      (when (> thirdGroupCount 0)
       (while (> k -1)
        (set! layer (vector-ref thirdGroupList k))
        (when (equal? (car (gimp-item-is-group layer)) FALSE)
         (srcLayerToDst layer srcImg dstImg thirdFolder)
        )

        (when (equal? (car (gimp-item-is-group layer)) TRUE)
         (set! fourthFolderMask(car (gimp-layer-get-mask layer)))
         (set! fourthGetChildren (gimp-item-get-children layer))
         (set! fourthGroupCount (car fourthGetChildren))
         (set! fourthGroupList (cadr fourthGetChildren))
         (set! l (- fourthGroupCount 1))
         (set! fourthFolder (srcLayerToDst layer srcImg dstImg thirdFolder))

         (when (> fourthGroupCount 0)
          (while (> l -1)
           (set! layer (vector-ref fourthGroupList l))

           (when (equal? (car (gimp-item-is-group layer)) FALSE)
            (srcLayerToDst layer srcImg dstImg fourthFolder)
           )

           (when (equal? (car (gimp-item-is-group layer)) TRUE)
            (set! fithFolderMask(car (gimp-layer-get-mask layer)))
            (set! fithGetChildren (gimp-item-get-children layer))
            (set! fithGroupCount (car fithGetChildren))
            (set! fithGroupList (cadr fithGetChildren))
            (set! m (- fithGroupCount 1))
            (set! fithFolder (srcLayerToDst layer srcImg dstImg fourthFolder))

            (when (> fithGroupCount 0)
             (while (> m -1)
              (set! layer (vector-ref fithGroupList m))

              (when (equal? (car (gimp-item-is-group layer)) FALSE)
               (srcLayerToDst layer srcImg dstImg fithFolder)
              )

              (when (equal? (car (gimp-item-is-group layer)) TRUE)
               (set! sixthFolderMask(car (gimp-layer-get-mask layer)))
               (set! sixthGetChildren (gimp-item-get-children layer))
               (set! sixthGroupCount (car sixthGetChildren))
               (set! sixthGroupList (cadr sixthGetChildren))
               (set! n (- sixthGroupCount 1))
               (set! sixthFolder (srcLayerToDst layer srcImg dstImg fithFolder))

               (when (> sixthGroupCount 0)
                (while (> n -1)
                 (set! layer (vector-ref sixthGroupList n))
                 (when (equal? (car (gimp-item-is-group layer)) TRUE)
                  (srcLayerToDst layer srcImg dstImg sixthFolder)
                 )

                 (when (equal? (car (gimp-item-is-group layer)) TRUE)
                  ;further nests
                 )

                 (if (= n 0)(updatefolderMask sixthFolderMask sixthFolder))
                 (set! n (- n 1))
                )
               )
              )
              (if (= m 0)(updatefolderMask fithFolderMask fithFolder))
              (set! m (- m 1))
             )
            )
           )
           (if (= l 0)(updatefolderMask fourthFolderMask fourthFolder))
           (set! l (- l 1))
          )
         )
        )
        (if (= k 0)(updatefolderMask thirdFolderMask thirdFolder))
        (set! k (- k 1))
       )
      )
     )
     (if (= j 0)(updatefolderMask secFolderMask secFolder))
     (set! j (- j 1))
    )
   )
  )
 (if (= i 0)(updatefolderMask folderMask folder))
 (set! i (- i 1))
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

 (when (equal? (car (gimp-item-is-group src)) FALSE)
  (srcLayerToDst src srcImg dstImg 0)
 )

 (when (equal? (car (gimp-item-is-group src)) TRUE)
  (layerNest src srcImg dstImg)
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
