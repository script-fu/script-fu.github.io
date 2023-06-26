
(define (restore-all-layer-colors img colLst)
  (let*
    (
      (actL 0)(i 0)(exst 0)
    )

    ; ignore these steps in the undo stack
    (gimp-image-undo-freeze img)
    (if (list? colLst) (set! colLst (list->vector colLst)))
    (while (< i (vector-length colLst))
      (set! actL (vector-ref colLst i))
      (set! exst (car (gimp-item-id-is-valid actL)))
      (when (= exst 1)
        (gimp-item-set-color-tag actL (vector-ref colLst (+ i 1)))
      )
      (set! i (+ i 2))
    )
    (gimp-image-undo-thaw img)

  )
)