## Layer Parasites

# * Tested in Gimp 2.99.14 *

This plug-in prints out a list of the selected layers and any attached parasites.
  
The plug-in should appear in the Tools menu.  
  
To download [**layer-parasites.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/layer-parasites/layer-parasites.scm)  
...follow the link, right click the page, Save as layer-parasites.scm, in a folder called layer-parasites, in a Gimp plug-ins location.  In Linux, set the file to be executable.
   
   

```scheme

#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-layer-parasites img lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(nme "")(para "")(actL 0)(j 0)(pV 0)(pN "")
      (para 0)(grp 0)(fileN (car(gimp-image-get-file img)))(len 0)
    )

    (if (list? lst )(set! lst (list->vector lst)))
    (set! len (number->string (vector-length lst)))

    ; create a formatted string
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! j 0)
      (set! nme (car(gimp-item-get-name actL)))
      (set! id (number->string actL))
      (set! grp (car (gimp-item-is-group actL)))
      (set! para (car (gimp-item-get-parasite-list actL)))
      (set! len (length para))
      (set! aStr (string-append aStr " item id : " id " : " nme ))
      (if (= grp 1) (set! aStr (string-append aStr " is a group \n"))
        (set! aStr (string-append aStr " \n"))
      )
      (if (= len 0)(set! aStr (string-append aStr " has no parasites \n\n")))

      (while (< j len)
        (set! pN (list-ref para j))
        (set! pV (get-item-parasite-string actL pN))
        (set! aStr (string-append aStr " has parasite : "pN" : "pV"\n"))
        (if (= j (- len 1))(set! aStr (string-append aStr "\n")))
        (set! j (+ j 1))
      )

      (set! i (+ i 1))
    )

    (gimp-message aStr)

    aStr
  )
)


(define (get-item-parasite-string actL paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-item-get-parasite-list actL))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message " found the parasite "))
        (set! fndV (caddar(gimp-item-get-parasite actL actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)


(script-fu-register-filter "script-fu-layer-parasites"
 "Layer Parasites" 
 "Prints out a list of the selected layers and attached parasites"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-parasites" "<Image>/Tools")


```