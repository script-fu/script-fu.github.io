; calculation useful to layer size scaling
(define (find-nearest-multiple message n multiplier dir)
  (let*
    (
      (q (/ 1 multiplier))
      (p (/ n q))
      (r (ceiling p))
      (f (- r p ))
      (initN n)
      (tol 0.01)
      (buffer 32)
    )

    ;intuitive fix
    (set! dir (* -1 dir))

    ; give a bit of border padding, start searching after buffer
    (if (> dir 0)(set! n (- n buffer)))

    (while (> (abs f) tol)
      (set! n (- n dir))
      (set! q (/ 1 multiplier))
      (set! p (/ n q))
      (set! r (ceiling p))
      (set! f (- r p ))
      (when debug
        (gimp-message 
          (string-append message
                          " : number -> " (number->string n)
                          "\n : fraction -> " (number->string f)
          )
        )
      )
    )

    (when debug
      (gimp-message 
        (string-append message
                        ": start number -> " (number->string initN)
                        "\n multipler -> " (number->string multiplier)
                        "\n\n * nearest found multiple -> " (number->string n)
                        "\n q : (inverse scale) -> " (number->string q)
                        "\n p : (search number / q) -> " (number->string p)
                        "\n r : (ceiling of p) -> " (number->string r)
                        "\n f : (r - p), 0 is the target -> " (number->string f)
                        "\n tolerance factor -> " (number->string tol)
                        "\n search direction -> " (number->string (* -1 dir))
        )
      )
    )

    n
  )
)
