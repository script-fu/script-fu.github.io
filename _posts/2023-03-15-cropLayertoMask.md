## Crop Layers to Masks

# * Tested in GIMP 2.99.14 *

Crops a selection of layers to their mask content, with a safe border option.

The plug-in should appear in the "Layer" menu.  
  
To download [**crop-layer-to-mask.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/crop-layer-to-mask/crop-layer-to-mask.scm)  
...follow the link, right click the page, Save as crop-layer-to-mask.scm, in a folder called crop-layer-to-mask, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   


```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-crop-layer-to-mask img drwbls expand)
  (let*
    (
      (actL 0)(pnts 0)(mskSel 0)(wdth 0)(hgt 0)(offX 0)(offY 0)(i 0)(drwMsk 0)
    )

    (gimp-context-push)
    (gimp-image-undo-group-start img)

    (while (< i (vector-length drwbls))
      (set! actL (vector-ref drwbls i))

      (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actL (car(gimp-layer-from-mask actL)))
      )

      (set! drwMsk (car (gimp-layer-get-mask actL)))

      (when (> drwMsk 0)
        (set! offX (car (gimp-drawable-get-offsets actL)))
        (set! offY (cadr (gimp-drawable-get-offsets actL)))
        (set! wdth (car (gimp-drawable-get-width actL)))
        (set! hgt (car (gimp-drawable-get-height actL)))
        (set! mskSel (gimp-image-select-item img CHANNEL-OP-REPLACE drwMsk))

        (set! pnts (list->vector(cdr (gimp-selection-bounds img))))
        (vector-set! pnts 0 (- (vector-ref pnts 0) expand))
        (vector-set! pnts 1 (- (vector-ref pnts 1) expand))
        (vector-set! pnts 2 (+ (vector-ref pnts 2) expand))
        (vector-set! pnts 3 (+ (vector-ref pnts 3) expand))

        (set! wdth (- (vector-ref pnts 2) (vector-ref pnts 0)))
        (set! hgt (- (vector-ref pnts 3) (vector-ref pnts 1)))
        (set! offX (- offX (vector-ref pnts 0)))
        (set! offY (- offY (vector-ref pnts 1)))

        (gimp-layer-resize actL wdth hgt offX offY)
      )

      (set! i (+ i 1))
    )

    (gimp-selection-none img)
    (gimp-context-push)
    (gimp-image-undo-group-end img)

  )
)


(script-fu-register-filter "script-fu-crop-layer-to-mask"
  "Crop Layer to Mask"
  "Crops layers to the mask area, with a border" 
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
  SF-ADJUSTMENT  "safe border (in pixels)" (list 64 0 5000 1 10 0 SF-SPINNER)
)
(script-fu-menu-register "script-fu-crop-layer-to-mask" "<Image>/Layer")


```