; when the source branch matches dst branch, it's possible to transfer locks
; (source image, destination group, list of locks)
(define (transfer-all-locks img dstGrp lckLst)
  (let*
    (
      (actL 0)(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)(i 0)(exst 0)(lstL 0)
      (j 0)
    )
    (set! lstL (all-childrn img dstGrp))
    (set! lstL (list->vector lstL))

    (set! lckLst (list->vector lckLst))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
        (gimp-item-set-lock-content actL (vector-ref lckLst (+ j 1)))
        (gimp-item-set-lock-position actL (vector-ref lckLst (+ j 2)))
        (gimp-item-set-lock-visibility actL (vector-ref lckLst (+ j 3)))
        (gimp-layer-set-lock-alpha actL (vector-ref lckLst (+ j 4)))
      (set! i (+ i 1))
      (set! j (+ j 5))
    )

    (gimp-item-set-lock-content dstGrp (vector-ref lckLst (+ j 1)))
    (gimp-item-set-lock-position dstGrp (vector-ref lckLst (+ j 2)))
    (gimp-item-set-lock-visibility dstGrp (vector-ref lckLst (+ j 3)))
    (gimp-layer-set-lock-alpha dstGrp (vector-ref lckLst (+ j 4)))

  )
)
