(define (adjustmentBaker img drawable)
 (let*
 (
  (returnList 0)
  (layerCount 0)
  (returnLayerList 0)
  (i 0)
  (j 0)
  (scanLayer 0)
  (foundParasite 0)
  (parasiteCount 0)
  (parasites 0)
  (parasiteList 0)
  (getChildren 0)
  (sourceLayer 0)
 )

 (gimp-context-push)
 (gimp-image-undo-group-start img)

 (set! returnList (layerScan img 0 0))
 (set! layerCount (car returnList))
 (set! returnLayerList (car(cdr returnList)))

 (while (< i layerCount)
  (set! scanLayer (vector-ref returnLayerList i))
  (set! parasiteCount (car(gimp-item-get-parasite-list scanLayer)))

  (when (> parasiteCount 0)
   (set! parasites (gimp-item-get-parasite-list scanLayer))
   (set! parasiteCount (car parasites))
   (set! parasiteList (list->vector(car(cdr parasites))))

   (set! j 0)
   (while(< j parasiteCount)
    (set! foundParasite (vector-ref parasiteList j))

    (when (equal? foundParasite "mixerSource")
     (set! getChildren (car(gimp-item-get-children scanLayer)))
     (if (= getChildren 0)
     (gimp-message "*** no source layer in original-source folder ***"))
     (if (> getChildren 0)
     (set! sourceLayer (vector-ref(cadr (gimp-item-get-children scanLayer)) 0)))
    )
    (set! j (+ j 1))
   )
  )
 (set! i (+ i 1))
 )

 (when (> sourceLayer 0)
  (set! i 0)
  (set! j 0)
  (while (< i layerCount)
   (set! scanLayer (vector-ref returnLayerList i))
   (set! parasiteCount (car(gimp-item-get-parasite-list scanLayer)))

   (when (> parasiteCount 0)
    (set! parasites (gimp-item-get-parasite-list scanLayer))
    (set! parasiteCount (car parasites))
    (set! parasiteList (list->vector(car(cdr parasites))))

    (set! j 0)
    (while(< j parasiteCount)
     (set! foundParasite (vector-ref parasiteList j))

     (when (equal? foundParasite "dodge")
      (gimp-item-set-lock-content scanLayer FALSE)
      (copyToLayer img sourceLayer scanLayer)
      (curve2Value img scanLayer 0 0 255 128)
      (gimp-item-set-lock-content scanLayer TRUE)
     )
     (when (equal? foundParasite "burn")
      (gimp-item-set-lock-content scanLayer FALSE)
      (copyToLayer img sourceLayer scanLayer)
      (curve2Value img scanLayer 0 128 255 255)
      (gimp-item-set-lock-content scanLayer TRUE)
     )
     (when (equal? foundParasite "sCurve")
      (gimp-item-set-lock-content scanLayer FALSE)
      (copyToLayer img sourceLayer scanLayer)
      (applyCurve_S img scanLayer)
      (gimp-item-set-lock-content scanLayer TRUE)
     )
     (when (equal? foundParasite "desaturate")
      (gimp-item-set-lock-content scanLayer FALSE)
      (copyToLayer img sourceLayer scanLayer)
      (gimp-drawable-desaturate scanLayer DESATURATE-AVERAGE)
      (gimp-item-set-lock-content scanLayer TRUE)
     )
     (when (equal? foundParasite "enhance")
      (gimp-item-set-lock-content scanLayer FALSE)
      (copyToLayer img sourceLayer scanLayer)
      (plug-in-color-enhance RUN-NONINTERACTIVE img scanLayer)
      (gimp-item-set-lock-content scanLayer TRUE)
     )

     (set! j (+ j 1))
    )
   )
  (set! i (+ i 1))
  )
 )

 (gimp-image-undo-group-end img)
 (gimp-context-pop)

 )
)


(script-fu-register "adjustmentBaker"
 "refreshMixer"
 "replaces mixer layers with the source layer"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
)
(script-fu-menu-register "adjustmentBaker" "<Image>/Script-Fu/adjustmentMixer")
