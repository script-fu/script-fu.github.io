#!/usr/bin/env gimp-script-fu-interpreter-3.0


(define debug #f)

(define (script-fu-layer-parasites img lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(nme "")(para "")(actL 0)(j 0)(pV 0)(pN "")
      (para 0)(grp 0)(len 0)
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


(script-fu-register-filter "script-fu-layer-parasites"
 "Layer Parasites" 
 "Prints out a list of the selected layers and attached parasites"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-parasites" "<Image>/Layer/Tag")

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


; returns the value string of a parasite on a specified layer
; (layer id, parasite name)
(define (get-item-parasite-string actL paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-item-get-parasite-list actL))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fndV (caddar(gimp-item-get-parasite actL actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)

