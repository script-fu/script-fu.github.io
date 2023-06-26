; are there any grandchildren in a list of layers and folders, returns 1 / 0
(define (grandchildren lst)
  (let*
    (
      (i 0)(actC 0)(grandchild 0)(chldrn 0)(j 0)(gchldrn 0)(actL 0)
    )

    (if (list? lst )(set! lst (list->vector lst)))
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! j 0)
      (when (> (car (gimp-item-is-group actL)) 0)
        (set! chldrn (gimp-item-get-children actL))
        (while (< j (car chldrn))
          (set! actC (vector-ref (cadr chldrn) j))
          (when (> (car (gimp-item-is-group actC)) 0)
            (set! gchldrn (gimp-item-get-children actC))
            (when (> (car gchldrn) 0)
              (if #f (gimp-message " this list has grandchildren "))
              (set! grandchild 1)
              (set! i (vector-length lst))
              (set! j (car chldrn))
            )
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    grandchild
  )
)