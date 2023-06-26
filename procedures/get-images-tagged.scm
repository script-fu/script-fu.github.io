; finds any images that have an attached parasite "tag"
; ("tag/parasite name") 
; returns a list of found images
(define (get-images-tagged tag)
  (let*
    (
      (tLst ())(img 0)(paraLst 0)(pNme 0)(i 0)(j 0)(allImgs 0)
    )

    (set! allImgs (gimp-get-images))
    (while (< i (car allImgs))
      (set! img (vector-ref (cadr allImgs) i))
      (set! paraLst (list->vector (car (gimp-image-get-parasite-list img))))
      (when (> (vector-length paraLst) 0)
        (set! j 0)
        (while(< j (vector-length paraLst))
          (set! pNme (vector-ref paraLst j))
          (when (equal? pNme tag)
            (set! tLst (append tLst (list img)))
            (set! j (vector-length paraLst))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tLst)
  )
)