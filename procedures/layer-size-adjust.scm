; part of precise scaling
(define (layer-size-adjust img dstWdth dstHght)
  (let*
    (
      (allL 0)(i 0)(offX 0)(offY 0)(actL 0)(xScP 0)(yScP 0)(skip 0)(fixLst ())
      (wdthL 0)(hghtL 0)(offYPos #t)(offXPos #t)(actNme "")(adjLst ())(adjL 0)
      (srcWdth (car (gimp-image-get-width img)))(all 0)
      (srcHght (car (gimp-image-get-height img)))
      (scX (/ dstWdth srcWdth))
      (scY (/ dstHght srcHght))
    )

    (set! allL (get-layers img all))
    (set! fixLst (group-mask-protect img)) ; protect group masks from deletion

    ; scale any layers that are not groups
    (set! allL (list->vector allL))
    (while (< i (vector-length allL))
      (message-progress i (vector-length allL) "precise scale progress")
      (set! actL (vector-ref allL i))
      (set! skip 0)
      (set! actNme (short-layer-name actL 10))
      (set! offXPos #t)
      (set! offYPos #t)
      (if debug (gimp-message (string-append " adjusting layer -> " actNme)))

      ; get layer sizes and offsets
      (set! wdthL (car (gimp-drawable-get-width actL)))
      (set! hghtL (car (gimp-drawable-get-height actL)))
      (set! offX (car(gimp-drawable-get-offsets actL)))
      (set! offY (cadr(gimp-drawable-get-offsets actL)))
      
      (if (< offX 0) (set! offXPos #f))
      (if (< offY 0) (set! offYPos #f))

      ; find a new local origin for the layer that is a close multiple
      ; of the scale applied, offsets are then scaled close to integer values
      (set! xScP (find-nearest-multiple " xScP " (abs offX) scX -1))
      (if (> xScP 0)(if (not offXPos) (set! xScP(* -1 xScP))))

      (set! yScP (find-nearest-multiple " yScP " (abs offY) scY -1))
      (if (> yScP 0)(if (not offYPos)(set! yScP (* -1 yScP))))

      (when debug
        (gimp-message
          (string-append
          " adjusting layer -> " actNme
          "\n scX scY -> " (number->string scX)
          ", " (number->string scY)
          "\n wdthL hghtL -> " (number->string wdthL)
          ", " (number->string hghtL)
          "\n offX offY -> " (number->string offX)
          ", " (number->string offY)
          "\n xOrig yScP -> (" (number->string xScP)
          ", " (number->string yScP) ")"
          )
        )
      )

      ; this layers size and offsets make it the same as the image, skip it
      (when (and (= srcWdth wdthL) (= srcHght hghtL))
        (when (and (= offX 0) (= offY 0))
          (if debug (gimp-message "skip layer, matches image size and position"))
          (set! skip 1)
        )
      )

      ; reframe the layer by merging to a new layer with friendly dimensions
      (when (= skip 0)
        (set! adjL (layer-reframe img actL xScP yScP scX scY))

        (set! adjLst (append adjLst (list adjL wdthL hghtL offX offY scX scY)))
      )

      (if debug (gimp-message (string-append " adjusted layer -> " actNme)))
      (set! i (+ i 1))
    )

    (if (> (length fixLst) 0)(remove-layers img fixLst))

    adjLst
  )
)