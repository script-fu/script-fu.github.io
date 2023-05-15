## Image Remove Parasites

# * Tested in GIMP 2.99.14 *

This plug-in removes all parasites, or a specific parasite, on the active image.
  
The plug-in should appear in the Image/Tag menu.  
  
To download [**image-remove-parasites.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/image-remove-parasites/image-remove-parasites.scm)  
...follow the link, right click the page, Save as image-remove-parasites.scm, in a folder called image-remove-parasites, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-image-remove-parasites actImg lst allP actP )
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(para "")(pV "")(pN "")(det #f)
      (para 0)(len 0)(opnImgs 0)(fNme "")(fBse "")(brkTok "/")
    )
    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

  ; create a formatted string
    (when (not(equal? (car(gimp-image-get-file actImg)) ""))
      (set! fNme (car(gimp-image-get-file actImg)))
      (set! fBse (car (reverse (strbreakup fNme brkTok))))
    )
    (if (equal? (car(gimp-image-get-file actImg)) "")(set! fBse "untitled"))

    (set! id (number->string actImg))
    (set! para (car (gimp-image-get-parasite-list actImg)))
    (set! len (length para))
    (set! aStr (string-append aStr " image id : " id " : " fBse ))
    (if (= len 0)(set! aStr (string-append aStr ", has no parasites \n")))

    (while (< i len)
      (set! pN (list-ref para i))
      (set! pV (get-image-parasite-string actImg pN))

      ; remove all?
      (when (= allP 1)
        (if debug (gimp-message (string-append " detatching parasite: " pN)))
        (gimp-image-detach-parasite actImg pN)
        (set! aStr (string-append aStr "\n removed : " pN ))
        (set! det #t)
      )

      ; remove specified?
      (when (and (= allP 0) (equal? actP pN))
        (if debug (gimp-message (string-append " found the parasite: " pN )))
        (gimp-image-detach-parasite actImg pN)
        (set! aStr (string-append aStr "\n removed : " pN ))
        (set! det #t)
      )

      (set! i (+ i 1))
    )

    (if det (gimp-message aStr))
    (if (not det) (gimp-message " no parasites detatched "))

    aStr
  )
)


(define (get-image-parasite-string img paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-image-get-parasite-list img))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fndV (caddar(gimp-image-get-parasite img actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)

(define (err msg)(gimp-message(string-append " >>> " msg " <<<"))↑read-warning↑)
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))
(define debug #f) ; print all debug information
(define info #t)  ; print information

(script-fu-register-filter "script-fu-image-remove-parasites"
 "Image Remove Parasites" 
 "Removes attached parasites from active image"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-TOGGLE     "All Parasites"             TRUE
 SF-STRING     "Specific Parasite"   "ink"
)
(script-fu-menu-register "script-fu-image-remove-parasites" "<Image>/Image/Tag")

```