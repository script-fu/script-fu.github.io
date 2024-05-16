## Transparent Layer From Selected Area

# * Tested in GIMP 2.99.19 *

I'll often need to create a new layer of a certain area. I've hotkeyed this plug-in to do that. Select an area, then the plugin will make a transparent layer above, sized to fit the selected area.
  
To download the [plug-in](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/transparent-layer-from-selection/transparent-layer-from-selection.scm)...  
  
...follow the link, right click, Save As...
  
*Creates a new layer, above the active layer, of the same size as the selection*

<!-- include-plugin "transparent-layer-from-selection" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-transparent-layer-from-selection img drwbls)
  (let*
    (
      (pVec 0)(pos 0)(actP 0)(actL (vector-ref drwbls 0))(wdth 0)(hgt 0)
    )
    
    (gimp-image-undo-group-start img)

    (if (= (car(gimp-selection-is-empty img)) 1)(gimp-selection-all img))

    (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
      (set! actL (car(gimp-layer-from-mask actL)))
    )

    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! actP (car (gimp-item-get-parent actL)))
    (set! pVec (list->vector (gimp-selection-bounds img)))
    (set! wdth (- (vector-ref pVec 3) (vector-ref pVec 1)))
    (set! hgt (- (vector-ref pVec 4) (vector-ref pVec 2)))

    (set! actL (car(gimp-layer-new img wdth hgt RGBA-IMAGE "new" 100 28)))

    (gimp-layer-set-offsets actL (vector-ref pVec 1) (vector-ref pVec 2))
    (gimp-image-insert-layer img actL actP pos)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    (gimp-image-set-selected-layers img 1 (vector actL))
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)

    (gimp-displays-flush)
  )
)

(script-fu-register-filter "script-fu-transparent-layer-from-selection"
  "Transparent Layer From Selection" 
  "creates a new transparent layer from the selection area size"
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2024"
  "*"
  SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-transparent-layer-from-selection" "<Image>/Layer")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message (string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))

```
