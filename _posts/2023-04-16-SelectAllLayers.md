## Select All Layers

# * Tested in GIMP 2.99.14 *

This selects all the layers in the stack, useful if you want to apply another plugin to every layer. For example, you might select every layer, and then use the "Layer Parasites" plugin to find out what parasites are attached.
  
The plug-in should appear in the Layer menu.  
  
To download [**select-all-layers.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/select-all-layers/select-all-layers.scm)  
...follow the link, right click the page, Save as select-all-layers.scm, in a folder called select-all-layers, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-select-all-layers img drwbls)
  (let*
    (
      (quiet 1) ; set to zero for a error console list of layers and ID's
      (chldrn (all-childrn img 0))(lstL 0)(i 0)(actL 0)(allL ())
      (selChldrn (list->vector (reverse chldrn)))
    )
    (gimp-image-set-selected-layers img (length chldrn ) selChldrn)
    (if (= quiet 0)(print-layer-list img chldrn))
  )
)


(define (all-childrn img rootGrp) ; recursive
  (let*
    (
      (chldrn ())(lstL 0)(i 0)(actL 0)(allL ())
    )

    (if (= rootGrp 0)
      (set! chldrn (gimp-image-get-layers img))
        (if (equal? (car (gimp-item-is-group rootGrp)) 1)
          (set! chldrn (gimp-item-get-children rootGrp))
        )
    )

    (when (not (null? chldrn))
      (set! lstL (cadr chldrn))
      (while (< i (car chldrn))
        (set! actL (vector-ref lstL i))
        (set! allL (append allL (list actL)))
        (if (equal? (car (gimp-item-is-group actL)) 1)
          (set! allL (append allL (all-childrn img actL)))
        )
        (set! i (+ i 1))
      )
    )

    allL
  )
)


(define (print-layer-list img lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(nme "")(actL 0)(grp 0)(len 0)
    )

    (if (list? lst )(set! lst (list->vector lst)))
    (set! len (number->string (vector-length lst)))

    ; create a formatted string
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! nme (car(gimp-item-get-name actL)))
      (set! id (number->string actL))
      (set! grp (car (gimp-item-is-group actL)))
      (set! aStr (string-append aStr " item id : " id " : " nme ))
      (if (= grp 1) (set! aStr (string-append aStr " is a group \n"))
        (set! aStr (string-append aStr " \n"))
      )
      (set! i (+ i 1))
    )

    (gimp-message aStr)

    aStr
  )
)


(script-fu-register-filter "script-fu-select-all-layers"
 "Select All Layers"
 "Selects all the layers in the stack"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-select-all-layers" "<Image>/Layer")


```