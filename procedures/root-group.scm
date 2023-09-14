; moves a list of groups to the root of the layer stack
; bug workaround, can't reorder item to root 0
; returns a list of new groups
(define (root-group img grpLst)
  (let
    (
    (i 0)(actG 0)(tmpGrp 0)(tmpGrpLst ())(j 0)(actL 0)(chldrn 0)(lstL 0)(aStr 0)
    )

    (while (< i (vector-length grpLst))
      (set! actG (vector-ref grpLst i))
      (set! aStr (store-layer-attributes img actG))
      (set! tmpGrp (gimp-layer-group-new img))
      (set! tmpGrpLst (append tmpGrpLst tmpGrp))
      (gimp-image-insert-layer img (car tmpGrp) 0 0)
      (gimp-layer-set-composite-space tmpGrp LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

      (set! chldrn (gimp-item-get-children actG))
      (set! lstL (list->vector (reverse (vector->list (cadr chldrn)))))
      (set! j 0)
      (while (< j (car chldrn))
        (set! actL (vector-ref lstL j))
        (gimp-image-reorder-item img actL (car tmpGrp) 0)
        (set! j (+ j 1))
      )
      (set! i (+ i 1))
      (gimp-image-remove-layer img actG)
      (restore-layer-attributes (car tmpGrp) aStr)
    )

  tmpGrpLst
  )
)