; closes a named image if it is open, compares the "filename.ext"
(define (find-and-remove-image findName)
  (let*
    (
      (openImages 0)(img 0)(fileName 0)(fileBase 0)(i 0)(brkTok "/")(valid 0)
    )
    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    (set! openImages (gimp-get-images))
    (while (< i (car openImages))
      (set! img (vector-ref (cadr openImages) i))
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (when (equal? fileBase findName)
          (set! valid (car (gimp-image-id-is-valid img)))
          (if (= valid 1) (gimp-image-delete img))
          (set! i (car openImages))
        )
      )
      (set! i (+ i 1))
    )

  )
)