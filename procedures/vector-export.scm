; exports all the vector/paths to a file "vector_#", returns number of exports
(define (vector-export img )
  (let*
    (
      (allVec (gimp-image-get-vectors img))
      (i 0)(actV 0)()(vecFle "")
    )

    (while (< i (car allVec ))
      (set! actV (vector-ref (cadr allVec) i))
      (set! vecFle (string-append "vector_" (number->string i)))
      (gimp-vectors-export-to-file img vecFle actV)
      (gimp-image-remove-vectors img actV)
      (set! i (+ i 1))
    )

    i
  )
); copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3


