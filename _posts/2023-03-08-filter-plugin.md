## Filter Plug-in

# * Tested in Gimp 2.99.14 *

In Gimp 3 the user can select more than one layer.  Plug-ins can also take in
more than one layer, as a vector, which is a list of drawables.  This is enabled 
by using a new type of script-fu register, *script-fu-register-filter*  
  
*In this example I've used that new method to access the selected drawables*

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-selectedDrawables image drawables) 
  (let*
    (
      (numDraw (vector-length drawables))
      (drawable 0)
      (i 0)
    )

    (gimp-message (string-append "  number of selected drawables -> "
                                   (number->string numDraw)))

    (while (< i numDraw)
      (set! drawable (vector-ref drawables i))
      (gimp-message (string-append "  selected drawable ID -> "
                                   (number->string drawable )))
      (set! i (+ i 1))
    )

  )
)

(script-fu-register-filter "script-fu-selectedDrawables"
  "selectedDrawables" 
  "how to access the selected drawables with a filter plugin" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  ;SF-ONE-DRAWABLE ;  limit the plug-in to a single selected drawable
  SF-ONE-OR-MORE-DRAWABLE  ; allow user to select many drawables 
)
(script-fu-menu-register "script-fu-selectedDrawables" "<Image>/Fu-Plugin")
```