## layers in an image

It's essential to get a list of the layers in an image.
Unfortunately I couldn't find an elegant way to do this.
So what we have here is something I hacked together instead.

*This procedure scans through all the layers taking folder groups
into consideration, and nested groups. It returns a total and list*

```scheme
(define (layerScan img startGroup noGroups)
(let*
 (
  (i 0)
  (j 0)
  (k 0)
  (l 0)
  (m 0)
  (n 0)
  (layer 0)
  (layerList (make-vector 9999 'integer))
  (finalList 0)
  (layerCount 0)
  (getLayers 0)
  (topTreeCount 0)
  (topTreeLayerList 0)
  (secondInnerGetLayers 0)
  (secondInnerGroupCount 0)
  (secondInnerGroupList 0)
  (thirdInnerGetLayers 0)
  (thirdInnerGroupCount 0)
  (thirdInnerGroupList 0)
  (fourthInnerGetLayers 0)
  (fourthInnerGroupCount 0)
  (fourthInnerGroupList 0)
  (fithInnerGetLayers 0)
  (fithInnerGroupCount 0)
  (fithInnerGroupList 0)
  (sixthInnerGetLayers 0)
  (sixthInnerGroupCount 0)
  (sixthInnerGroupList 0)
  (returnList 0)
  (returnLayerList 0)
 )

 (when (> img 0)
  (if(= startGroup 0)(set! getLayers (gimp-image-get-layers img)))
  (if(> startGroup 0)(set! getLayers (gimp-item-get-children startGroup)))
  (set! topTreeCount (car getLayers))
  (set! topTreeLayerList (cadr getLayers))

  (while (< i topTreeCount)
   (set! layer (vector-ref topTreeLayerList i))

   (when (equal? (car (gimp-item-is-layer layer)) TRUE)
    (vector-set! layerList layerCount layer)
    (set! layerCount (+ layerCount 1))
   )

   (when (equal? (car (gimp-item-is-group layer)) TRUE)
    (if(= noGroups 1)(set! layerCount (- layerCount 1)))
    (if(= noGroups 0)(vector-set! layerList layerCount layer))

    (set! secondInnerGetLayers (gimp-item-get-children layer))
    (set! secondInnerGroupCount (car secondInnerGetLayers))
    (set! secondInnerGroupList (cadr secondInnerGetLayers))
    (set! j 0)

    (when (> secondInnerGroupCount 0)
     (while (< j secondInnerGroupCount)
      (set! layer (vector-ref secondInnerGroupList j))

      (when (equal? (car (gimp-item-is-layer layer)) TRUE)
       (vector-set! layerList layerCount layer)
       (set! layerCount (+ layerCount 1))
      )

      (when (equal? (car (gimp-item-is-group layer)) TRUE)
       (if(= noGroups 1)(set! layerCount (- layerCount 1)))
       (if(= noGroups 0)(vector-set! layerList layerCount layer))

       (set! thirdInnerGetLayers (gimp-item-get-children layer))
       (set! thirdInnerGroupCount (car thirdInnerGetLayers))
       (set! thirdInnerGroupList (cadr thirdInnerGetLayers))
       (set! k 0)

       (when (> thirdInnerGroupCount 0)
        (while (< k thirdInnerGroupCount)
         (set! layer (vector-ref thirdInnerGroupList k))

         (when (equal? (car (gimp-item-is-layer layer)) TRUE)
          (vector-set! layerList layerCount layer)
          (set! layerCount (+ layerCount 1))
         )

         (when (equal? (car (gimp-item-is-group layer)) TRUE)
          (if(= noGroups 1)(set! layerCount (- layerCount 1)))
          (if(= noGroups 0)(vector-set! layerList layerCount layer))

          (set! fourthInnerGetLayers (gimp-item-get-children layer))
          (set! fourthInnerGroupCount (car fourthInnerGetLayers))
          (set! fourthInnerGroupList (cadr fourthInnerGetLayers))
          (set! l 0)

          (when (> fourthInnerGroupCount 0)
           (while (< l fourthInnerGroupCount)
           (set! layer (vector-ref fourthInnerGroupList l))

           (when (equal? (car (gimp-item-is-layer layer)) TRUE)
            (vector-set! layerList layerCount layer)
            (set! layerCount (+ layerCount 1))
           )

           (when (equal? (car (gimp-item-is-group layer)) TRUE)
            (if(= noGroups 1)(set! layerCount (- layerCount 1)))
            (if(= noGroups 0)(vector-set! layerList layerCount layer))

            (set! fithInnerGetLayers (gimp-item-get-children layer))
            (set! fithInnerGroupCount (car fithInnerGetLayers))
            (set! fithInnerGroupList (cadr fithInnerGetLayers))
            (set! m 0)

            (when (> fithInnerGroupCount 0)
             (while (< m fithInnerGroupCount)
              (set! layer (vector-ref fithInnerGroupList m))

              (when (equal? (car (gimp-item-is-layer layer)) TRUE)
               (vector-set! layerList layerCount layer)
               (set! layerCount (+ layerCount 1))
              )

              (when (equal? (car (gimp-item-is-group layer)) TRUE)
               (if(= noGroups 1)(set! layerCount (- layerCount 1)))
               (if(= noGroups 0)(vector-set! layerList layerCount layer))

               (set! sixthInnerGetLayers (gimp-item-get-children layer))
               (set! sixthInnerGroupCount (car sixthInnerGetLayers))
               (set! sixthInnerGroupList (cadr sixthInnerGetLayers))
               (set! n 0)

               (when (> sixthInnerGroupCount 0)
                (while (< n sixthInnerGroupCount)
                 (set! layer (vector-ref sixthInnerGroupList n))

                 (when (equal? (car (gimp-item-is-layer layer)) TRUE)
                  (vector-set! layerList layerCount layer)
                  (set! layerCount (+ layerCount 1))
                 )

                 (when (equal? (car (gimp-item-is-group layer)) TRUE)
                  (if(= noGroups 1)(set! layerCount (- layerCount 1)))
                  (if(= noGroups 0)(vector-set! layerList layerCount layer))
                 )
                 (set! n (+ n 1))
                )
               )
              )
             (set! m (+ m 1))
             )
            )
           )
          (set! l (+ l 1))
          )
         )
        )
        (set! k (+ k 1))
       )
      )
     )
    (set! j (+ j 1))
    )
   )
  )
  (set! i (+ i 1))
  )


  (set! finalList (make-vector layerCount 'integer))

  (set! i 0)
  (while (< i layerCount)
   (vector-set! finalList i (vector-ref layerList i))
   (set! i (+ i 1))
  )
 )
 (set! returnList (list layerCount finalList))

 returnList
 )
)

(script-fu-register "layerScan"
 ""
 "how many layers does the active image have"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
)

```

*The menu item that calls the scan and prints out all the layers and folders to the error console*

```scheme

(define (imageLayers img)
 (let*
 (
  (layerCount 0)
  (returnList 0)
  (returnLayerList 0)
  (i 0)
  (ignoreFolders 1)
  (includeFolders 0)
 )

 (set! returnList (layerScan img 0 includeFolders))

 (when (> (car returnList) 0)
  (set! layerCount (car returnList))
  (set! returnLayerList (car(cdr returnList)))
 )

 (while (< i layerCount)
  (gimp-message (string-append " layer #" (number->string (+ i 1))
                               " \n ID --> " (number->string
                               (vector-ref returnLayerList i))
                               " \n name --> " (car (gimp-item-get-name
                               (vector-ref returnLayerList i)))
                               " \n"
                               ))
  (set! i (+ i 1))
 )

 )
)

(script-fu-register "imageLayers"
 "imageLayers"
 "prints all the layers and folders to the error console"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
)
(script-fu-menu-register "imageLayers" "<Image>/Script-Fu")

```
