## Image Parasites

# * Tested in GIMP 2.99.14 *

This plug-in prints out a list of all open images and any attached parasites.
  
The plug-in should appear in the Image/Tag menu.  
  
To download [**image-parasites.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/image-parasites/image-parasites.scm)  
...follow the link, right click the page, Save as image-parasites.scm, in a folder called image-parasites, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   
<!-- include-plugin "image-parasites" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-image-parasites img lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(para "")(actImg 0)(j 0)(pV "")(pN "")
      (para 0)(len 0)(opnImgs 0)(fNme "")(fBse "")(brkTok DIR-SEPARATOR)
    )

    (set! opnImgs (gimp-get-images))

    ; create a formatted string
    (while (< i (car opnImgs))
      (set! actImg (vector-ref (cadr opnImgs) i))
      (when (not(equal? (car(gimp-image-get-file actImg)) ""))
        (set! fNme (car(gimp-image-get-file actImg)))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
      )
      (if (equal? (car(gimp-image-get-file actImg)) "")(set! fBse "untitled"))
      
      (set! j 0)

      (set! id (number->string actImg))
      (set! para (car (gimp-image-get-parasite-list actImg)))
      (set! len (length para))
      (set! aStr (string-append aStr " image id : " id " : " fBse ))
      (if (= len 0)(set! aStr (string-append aStr ", has no parasites \n")))
      (if (> len 0)(set! aStr (string-append aStr ", has parasites ")))
      (while (< j len)
        (set! pN (list-ref para j))
        (set! pV (get-image-parasite-string actImg pN))
        (set! aStr (string-append aStr "\n  : " pN " : " pV ))
        (set! j (+ j 1))
      )
      (if (> len 0)(set! aStr (string-append aStr "\n\n"))
        (set! aStr (string-append aStr "\n"))
      )
      (set! i (+ i 1))
    )

    (gimp-message aStr)

    aStr
  )
)

(script-fu-register-filter "script-fu-image-parasites"
 "Image Parasites" 
 "Prints out a list of all open images and attached parasites"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-image-parasites" "<Image>/Image/Tag")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message(string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; returns the value string of a parasite on a specified image
; (image id, parasite name)
(define (get-image-parasite-string img paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-image-get-parasite-list img))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message " found the parasite "))
        (set! fndV (caddar(gimp-image-get-parasite img actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)

```
