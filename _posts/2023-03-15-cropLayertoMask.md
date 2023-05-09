## Crop Layers to Masks

# * Tested in Gimp 2.99.14 *

Crops a selection of layers to their mask content, with a safe border option.

The plug-in should appear in the "Layer" menu.  
  
To download [**crop-layer-to-mask.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/crop-layer-to-mask/crop-layer-to-mask.scm)  
...follow the link, right click the page, Save as crop-layer-to-mask.scm, in a folder called crop-layer-to-mask, in a Gimp plug-ins location.  In Linux, set the file to be executable.
   
   


```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-crop-layer-to-mask img lstL expand)
(let*
    (
      (actL 0)(pnts 0)(mskSel 0)(wdthL 0)(hghtL 0)(offX 0)(offY 0)(i 0)
      (crpW 0)(crpH 0)(actMsk 0)
    )

    (gimp-image-undo-group-start img)
    (gimp-context-push)
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      
      (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actL (car(gimp-layer-from-mask actL)))
      )
      
      (set! actMsk (car (gimp-layer-get-mask actL)))
      
      (when (> actMsk 0)
        (set! offX (car (gimp-drawable-get-offsets actL)))
        (set! offY (car (cdr (gimp-drawable-get-offsets actL))))
        (set! wdthL (car (gimp-drawable-get-width actL)))
        (set! hghtL (car (gimp-drawable-get-height actL)))
        (set! mskSel (gimp-image-select-item img CHANNEL-OP-REPLACE actMsk))
        
        (set! pnts (make-vector 4 'double))
        (vector-set! pnts 0 (car(cdr(gimp-selection-bounds img))))
        (vector-set! pnts 1 (car(cddr(gimp-selection-bounds img))))
        (vector-set! pnts 2 (car(cdddr(gimp-selection-bounds img))))
        (vector-set! pnts 3 (car(cddr(cddr(gimp-selection-bounds img)))))

        (vector-set! pnts 0 (- (vector-ref pnts 0) expand))
        (vector-set! pnts 1 (- (vector-ref pnts 1) expand))
        (vector-set! pnts 2 (+ (vector-ref pnts 2) expand))
        (vector-set! pnts 3 (+ (vector-ref pnts 3) expand))

        (set! crpW (- (vector-ref pnts 2) (vector-ref pnts 0)))
        (set! crpH (- (vector-ref pnts 3) (vector-ref pnts 1)))
        (set! offX (- offX (vector-ref pnts 0)))
        (set! offY (- offY (vector-ref pnts 1)))

        (gimp-layer-resize actL crpW crpH offX offY)
      )
      (set! i (+ i 1))
    )
    (gimp-selection-none img)
    (gimp-context-pop)
    (gimp-image-undo-group-end img)

  )
)

(script-fu-register-filter "script-fu-crop-layer-to-mask"
  "Crop Layer to Mask"
  "Crops layers to the mask area, with a border" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
  SF-ADJUSTMENT  "safe border (in pixels)" (list 64 0 5000 1 10 0 SF-SPINNER)
)
(script-fu-menu-register "script-fu-crop-layer-to-mask" "<Image>/Layer")

```