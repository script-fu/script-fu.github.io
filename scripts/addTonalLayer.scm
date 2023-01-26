(define (addTonalLayer img parent position name tone mode)
 (let*
  (
   (activeLayer 0)
   (toneLayer 0)
   (cur-width 0)
   (cur-height 0)
   (normalMode 28)
  )
  (gimp-context-push)
  (set! cur-width  (car (gimp-image-width img)))
  (set! cur-height (car (gimp-image-height img)))
  (set! toneLayer (car (gimp-layer-new img cur-width cur-height 0 name 100 28)))
  (gimp-image-insert-layer img toneLayer parent position)
  (gimp-layer-set-opacity toneLayer 100)
  (gimp-layer-set-mode toneLayer mode)
  (gimp-context-set-foreground (list tone tone tone))
  (gimp-context-set-opacity 100)
  (gimp-drawable-fill toneLayer 0)
  (gimp-context-pop)
  toneLayer
 )
)

(script-fu-register "addTonalLayer"
 ""
 "add a tonal layer, sized from the image"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
