#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-layer-remove-parasites img lst allP actP)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(nme "")(para "")(actL 0)(j 0)(pV 0)(pN "")
      (para 0)(grp 0)(len 0)(det #f)
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
      (if (= grp 1) (set! aStr (string-append aStr " is a group ")))

      (if (= len 0)(set! aStr (string-append aStr " has no parasites \n\n")))

      (while (< j len)
        (set! pN (list-ref para j))
        (set! pV (get-item-parasite-string actL pN))

        ; remove all?
        (when (= allP 1)
          (if debug (gimp-message (string-append " detatching parasite: " pN)))
          (gimp-item-detach-parasite actL pN)
          (set! aStr (string-append aStr "\n removed : " pN ))
          (set! det #t)
        )

        ; remove specified?
        (when (and (= allP 0) (equal? actP pN))
          (if debug (gimp-message (string-append " found the parasite: " pN )))
          (gimp-item-detach-parasite actL pN)
          (set! aStr (string-append aStr "\n removed : " pN ))
          (set! det #t)
        )

        (if (= j (- len 1))(set! aStr (string-append aStr "\n")))
        (set! j (+ j 1))
      )

      (set! i (+ i 1))
    )

    (if det (gimp-message aStr))
    (if (not det) (gimp-message " no parasites detatched "))

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
        (set! fndV (caddar(gimp-item-get-parasite actL actP)))
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

(script-fu-register-filter "script-fu-layer-remove-parasites"
 "Layer Remove Parasites"
 "Removes all parasites from the selected layers"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-TOGGLE     "All Parasites"             TRUE
 SF-STRING     "Specific Parasite"   "name"
)
(script-fu-menu-register "script-fu-layer-remove-parasites" "<Image>/Layer/Tag")
