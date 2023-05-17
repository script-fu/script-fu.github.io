## Layer Add Parasite

# * Tested in GIMP 2.99.14 *

This plug-in adds a parasite to the selected layers, a useful way to allow another plug-in to find those layers. The plug-in should appear in the Layer/Tag menu.  
  
To download [**layer-set-parasite.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/layer-set-parasite/layer-set-parasite.scm)  
...follow the link, right click the page, Save as layer-set-parasite.scm, in a folder called layer-set-parasite, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment

(define (script-fu-layer-set-parasite img lst name mode tagV col)
  (let*
    (
      (i 0)(actL 0)
    ) 

    (if (list? lst )(set! lst (list->vector lst)))

    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (tag-layer actL name mode tagV col)
      (set! i (+ i 1))
    )
    (gimp-message (string-append " added layer parasite : " name))

  )
)


(define (tag-layer actL name mode tagV col)
  (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
    (set! actL (car(gimp-layer-from-mask actL)))
  )
  (gimp-item-attach-parasite actL (list name mode tagV))
  (gimp-item-set-color-tag actL col)
)


(script-fu-register-filter "script-fu-layer-set-parasite"
 "Layer Add Parasite" 
 "Attaches a specific parasite to the selected layers"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-STRING      "parasite name"   "skin"
 SF-ADJUSTMENT  "attach mode 0-3 " (list 3 0 6 1 1 0 SF-SPINNER)
 SF-STRING      "parasite data"   "pale skin"
 SF-ADJUSTMENT  "layer color 0-8 " (list 0 0 8 1 1 0 SF-SPINNER)
)
(script-fu-menu-register "script-fu-layer-set-parasite" "<Image>/Layer/Tag")

;SF-ADJUSTMENT "label" '(value, lower, upper, step_inc, page_inc, digits, type)
```