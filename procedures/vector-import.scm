; imports all the vector/paths
(define (vector-import img numV)
  (let*
    (
      (i 0)(vecFle "")
    )

    (while (< i numV)
      (set! vecFle (string-append "vector_" (number->string i)))
      (gimp-vectors-import-from-file img vecFle 0 1)
      (set! i (+ i 1))
    )

  )
)