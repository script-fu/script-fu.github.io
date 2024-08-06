; returns #t or #f if an item name has a substring
(define (item-name-has-substring item substring)
  (let*
    (
      (breakList (strbreakup (car (gimp-item-get-name item)) substring))
    )

    (>= (length breakList) 2)
  )
)
