; part of precise scaling
(define (layer-reframe img actL xScP yScP scX scY)
  (let*
    (
      (parent (car (gimp-item-get-parent actL)))(unlock 0)(lckLst 0)
      (pos (car (gimp-image-get-item-position img actL)))
      (dstL 0)(paraStrLst 0)(buffer 32)(adjWdth 0)(adjHght 0)(actLAttr 0)
      (wdthL (car (gimp-drawable-get-width actL)))
      (hghtL (car (gimp-drawable-get-height actL)))
      (offX (car(gimp-drawable-get-offsets actL)))
      (offY (cadr(gimp-drawable-get-offsets actL)))
    )

    (set! lckLst (set-and-store-layer-locks actL unlock))

    ; reframe layer size to scale precisely at a given scale
    (set! adjWdth (+ buffer (+ wdthL (abs (- offX xScP)))))
    (set! adjHght (+ buffer (+ hghtL (abs (- offY yScP)))))
    (set! adjWdth (find-nearest-multiple " width " adjWdth scX 1))
    (set! adjHght (find-nearest-multiple " height " adjHght scY 1))

    (when debug
      (gimp-message
        (string-append
          " increasing layer size -> (" (number->string adjWdth) ", "
                                        (number->string adjHght) ")"
          "\n original layer size -> (" (number->string wdthL) ", "
                                        (number->string hghtL) ")"
        )
      )
    )

    ; add an alpha and then resize the layer to new size and offsets
    (if (= (car(gimp-drawable-has-alpha actL)) 0)(gimp-layer-add-alpha actL))
    (gimp-layer-resize actL adjWdth adjHght (- offX xScP) (- offY yScP))

    (restore-layer-locks actL lckLst)

    actL
  )
)
