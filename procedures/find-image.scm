; finds a named image if it is open, compares the "filename.ext", returns the ID
(define (find-image findName)
  (let*
    (
      (openImages 0)(img 0)(fileName 0)(fileBase 0)(i 0)(valid 0)
      (brkTok DIR-SEPARATOR)(foundID 0)
    )

    (set! openImages (gimp-get-images))
    (while (< i (car openImages))
      (set! img (vector-ref (cadr openImages) i))
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (when (equal? fileBase findName)
          (set! valid (car (gimp-image-id-is-valid img)))
          (if (= valid 1) (set! foundID img))
          (set! i (car openImages))
        )
      )
      (set! i (+ i 1))
    )

  foundID
  )
)