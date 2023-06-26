; scans through possible display id's and brings the first it finds to the fore
(define (present-first-display)
  (let*
    (
      (i 0)
    )

    (while (< i 100)
      (when (= (car (gimp-display-id-is-valid i)) 1)
        (gimp-display-present i)

        (set! i 100)
      )
      (set! i (+ i 1))
    )

  )
)