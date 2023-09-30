; removes all the parasites from a list of layers and prints the results
; needs additional include of (load (include "get-item-parasite-string"))
; in the calling plug-in
(define (remove-layer-parasites img lst)
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
        (set! aStr (string-append aStr " removing parasite : "pN" : "pV"\n"))
        (if (= j (- len 1))(set! aStr (string-append aStr "\n")))
        (gimp-item-detach-parasite actL pN)
        (set! j (+ j 1))
      )

      (set! i (+ i 1))
    )

    (if debug (gimp-message aStr))

    aStr
  )
)

