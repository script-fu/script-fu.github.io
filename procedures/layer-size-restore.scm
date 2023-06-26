; part of precise scaling
(define (layer-size-restore adjLst)
  (let*
    (
      (actNme 0)(i 0)(offX 0)(offY 0)(actL 0)(xScP 0)(yScP 0)(skip 0)(fixLst ())
      (wdthL 0)(hghtL 0)(offYPos #t)(offXPos #t)(actNme "")
      (adjOffX 0)(adjOffY 0)(scX 0)(scY 0)(buffer 8)
    )

    (set! adjLst (list->vector adjLst))
    (while (< i (vector-length adjLst))
      (message-progress i (vector-length adjLst) "completion progress")
      (set! actL (vector-ref adjLst (+ i 0)))
      (set! wdthL (vector-ref adjLst (+ i 1)))
      (set! hghtL (vector-ref adjLst (+ i 2)))
      (set! offX (vector-ref adjLst (+ i 3)))
      (set! offY (vector-ref adjLst (+ i 4)))
      (set! scX (vector-ref adjLst (+ i 5)))
      (set! scY (vector-ref adjLst (+ i 6)))
      (set! actNme (short-layer-name actL 10))

      (set! adjOffX (car(gimp-drawable-get-offsets actL)))
      (set! adjOffY (cadr(gimp-drawable-get-offsets actL)))

      ; scaled sizes with an additional buffer
      (set! wdthL (ceiling (* wdthL scX)))
      (set! hghtL (ceiling (* hghtL scY)))
      (set! wdthL (+ wdthL buffer))
      (set! hghtL (+ hghtL buffer))

      ; scaled offsets with an additional buffer
      (set! offX (ceiling (* offX scX)))
      (set! offY (ceiling (* offY scY)))
      (set! offX (- offX (/ buffer 2)))
      (set! offY (- offY (/ buffer 2)))

      ; old - new offsets
      (set! adjOffX (- adjOffX offX))
      (set! adjOffY (- adjOffY offY))

      (when debug
        (gimp-message
          (string-append
          " cropping layer -> " actNme
          "\n scX scY -> " (number->string scX)
          ", " (number->string scY)
          "\n wdthL hghtL -> " (number->string wdthL)
          ", " (number->string hghtL)
          "\n adjOffX adjOffY -> " (number->string adjOffX)
          ", " (number->string adjOffY)
          )
        )
      )

      (gimp-layer-resize actL wdthL hghtL adjOffX adjOffY)
      (set! i (+ i 7))
    )

  )
)
