; returns 1, if a named image is open, compares the "filename.ext"
(define (image-exists findName)
  (let*
    (
      (openImages 0)(img 0)(exists 0)(fileName 0)(fileBase 0)(i 0)
      (brkTok DIR-SEPARATOR)
    )

    (set! openImages (gimp-get-images))
    (while (< i (car openImages))
      (set! img (vector-ref (cadr openImages) i))
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (if (equal? fileBase findName)(set! exists 1))
      )
      (set! i (+ i 1))
    )

    exists
  )
)