## Crop Layers to Masks

# * Tested in GIMP 2.99.14 *

Crops a selection of layers to their mask content, with a safe border option.

The plug-in should appear in the "Layer" menu.  
  
To download [**crop-layer-to-mask.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/crop-layer-to-mask/crop-layer-to-mask.scm)  
...follow the link, right click the page, Save as crop-layer-to-mask.scm, in a folder called crop-layer-to-mask, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   

<!-- include-plugin "crop-layer-to-mask" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-crop-layer-to-mask img drwbls expand)
  (gimp-image-undo-group-start img)
  (mask-box-crop img drwbls expand)
  (gimp-image-undo-group-end img)
)

(define debug #f)

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

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; crops layer list to the mask area, plus a safe border
; (image, list of layers, border width)
(define (mask-box-crop img drwbls expand)
  (let*
    (
      (actL 0)(pnts 0)(mskSel 0)(wdth 0)(hgt 0)(offX 0)(offY 0)(i 0)(drwMsk 0)
      (imgWidth (car (gimp-image-get-width img)))
      (imgHeight (car (gimp-image-get-height img)))
      (oldOffX 0)(oldOffY 0)
    )

    (gimp-context-push)

    (while (< i (vector-length drwbls))
      (set! actL (vector-ref drwbls i))

      (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actL (car(gimp-layer-from-mask actL)))
      )

      (set! drwMsk (car (gimp-layer-get-mask actL)))

      (when (> drwMsk 0)
        (set! oldOffX (car (gimp-drawable-get-offsets actL)))
        (set! oldOffY (cadr (gimp-drawable-get-offsets actL)))
        (set! mskSel (gimp-image-select-item img CHANNEL-OP-REPLACE drwMsk))

        (set! pnts (list->vector(cdr (gimp-selection-bounds img))))
        (vector-set! pnts 0 (- (vector-ref pnts 0) expand))
        (vector-set! pnts 1 (- (vector-ref pnts 1) expand))
        (vector-set! pnts 2 (+ (vector-ref pnts 2) expand))
        (vector-set! pnts 3 (+ (vector-ref pnts 3) expand))

        (set! wdth (- (vector-ref pnts 2) (vector-ref pnts 0)))
        (set! hgt (- (vector-ref pnts 3) (vector-ref pnts 1)))
        (set! offX  (vector-ref pnts 0))
        (set! offY  (vector-ref pnts 1))

        (if debug
          (gimp-message
            (string-append
              " image width = " (number->string imgWidth)
              "\n selection width = " (number->string wdth)
              "\n selection offset X = " (number->string offX)
              "\n image height = " (number->string imgHeight)
              "\n selection height = " (number->string hgt)
              "\n selection offset Y = " (number->string offY)
              "\n old offset X = " (number->string oldOffX)
              "\n old offset Y = " (number->string oldOffY)
            )
          )
        )

        ;clamp layer size to extent of image size
        (when (< offX 0)
          (set! offX 0)
          (gimp-message " clamping offset X to 0 ")
        )

        (when (< imgWidth (+ wdth offX))
         (set! wdth (- imgWidth offX))
         (gimp-message
           (string-append
             " image width = " (number->string imgWidth)
             "\n resize width = " (number->string wdth)
           )
         )
        )

        (when (< offY 0)
          (set! offY 0)
          (gimp-message " clamping offset Y to 0 ")
        )

        (when (< imgHeight (+ hgt offY))
         (set! hgt (- imgHeight offY))
         (gimp-message
           (string-append
             " image height = " (number->string imgHeight)
             "\n resize height = " (number->string hgt)
           )
         )
        )

        ; (gimp-image-select-rectangle img 2 offX offY wdth hgt)
        ; (gimp-displays-flush)
        ; (exit "here")

        (gimp-layer-resize actL wdth hgt (- oldOffX offX) (- oldOffY offY))
      )

      (set! i (+ i 1))
    )

    (gimp-selection-none img)
    (gimp-context-push)

  )
)

```
