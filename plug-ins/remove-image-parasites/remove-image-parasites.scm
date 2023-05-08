#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-remove-image-parasites actImg lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(para "")(j 0)(pV "")(pN "")
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
      (if (> len 0)(set! aStr (string-append aStr ", removing parasites ")))
      (while (< j len)
        (set! pN (list-ref para j))
        (set! pV (get-image-parasite-string actImg pN))
        (set! aStr (string-append aStr "\n  : " pN " : " pV ))
        (gimp-image-detach-parasite actImg pN)
        (set! j (+ j 1))
      )

    (gimp-message aStr)

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
        (if #f (gimp-message " found the parasite "))
        (set! fndV (caddar(gimp-image-get-parasite img actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)


(script-fu-register-filter "script-fu-remove-image-parasites"
 "Remove Image Parasites" 
 "Removes attached parasites from active image"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-remove-image-parasites" "<Image>/Image")