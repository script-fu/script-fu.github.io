; breaks a given string with a given break token and checks if any of the strings
; match another given string: ("the_name_has_a_keyword" "_" "keyword")
; returns true if the string is found within the string
(define (string-broken-has-string name breakToken findName)
  (let*
    (
      (i 0)
      (nameArray (strbreakup name breakToken))
      (has_string #f)
    )

    (set! nameArray (list->vector nameArray))

    (while (< i (vector-length nameArray))
      (if (equal? (vector-ref nameArray i) findName)
        (set! has_string #t)
      )
      (set! i (+ i 1))
    )

    has_string
  )
)