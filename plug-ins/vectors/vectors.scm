#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-vectors)
  (let*
    (
      (emptyVector #())
      (myIntV #(1 2 3))
      (myStrV #("a" "b" "c"))
      (loopV (make-vector 3 #())) ; vector of 3 empty vectors
      (i 0) (tmpV 0)
    )

    (print-vector-list myIntV)

    ; set! can assign a vectors
    (set! emptyVector myStrV)
    (print-vector-list emptyVector)

    ; vector-set! for each vector index value)
    (vector-set! myStrV 0 "this")
    (vector-set! myStrV 1 "is a")
    (vector-set! myStrV 2 "vector")
    (print-vector-list myStrV)

    (set! myIntV (vector-append myIntV 4))
    (set! myIntV (vector-append myIntV 5))
    (set! myIntV (vector-append myIntV 6))
    (print-vector-list myIntV)
    
    ;(make-vector length value)
    (set! tmpV (make-vector 3 "testing"))
    (print-vector-list tmpV)

    ; fill a vector of vectors
    (while (< i 3)
      ; make a three element vector using append
      (set! tmpV (make-vector 3 "testing"))
      (vector-set! tmpV 0 "hello")
      (vector-set! tmpV 1 "vector")
      (vector-set! tmpV 2 (string-append "list # " (number->string i)))
      (vector-set! loopV i tmpV)
      (set! i (+ i 1))
    )

    ;print a vector of vectors
    (set! i 0)
    (while (< i 3)
      (print-vector-list (vector-ref loopV i))
      (set! i (+ i 1))
    )

  )
)


(define (print-vector-list vect)
  (let* ((i 0) (lstr "")(actV 0))

    (if (list? vect) (set! vect (list->vector vect)))
    (while (< i (vector-length vect))
      (set! actV (vector-ref vect i))
      (if (not (string? actV)) (set! actV (number->string actV)))
      (set! lstr (string-append lstr " vector element ->  " actV "\n" ))
      (set! i (+ i 1))
    )

    (gimp-message lstr)
  )
)


(define (vector-append vect v)
  (let*
    (
      (len (vector-length vect ))
      (tmpV (make-vector (+ 1 len) v))
      (i 0)
    )

    (when (> len 0)
      (while (< i len)
        (vector-set! tmpV i (vector-ref vect i))
        (set! i (+ i 1))
      )
    )

    (set! vect tmpV)

  )
)


(script-fu-register"script-fu-vectors"
 "vectors" 
 "Demonstrating use of vectors" 
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-vectors" "<Image>/Fu-Plugin")
