(define (get-proxy srcGrp preFxL)
  (let*
    (
     (chldrn 0)(name 0)(found 0)
    )
    ; check for src group being a -1 parent
    (when (> srcGrp 0)
      (when (= (car (gimp-item-is-group srcGrp)) 1)
        (set! chldrn (gimp-item-get-children srcGrp))
        (when (> (vector-length (cadr chldrn) ) 0)
          (set! name (car(gimp-item-get-name (vector-ref (cadr chldrn) 0))))
          (set! name (strbreakup name preFxL))
          (when (> (length name) 1)
            (set! name (cadr name))
            (set! found 1)
          )
        )
      )
    )
    found
  )
)