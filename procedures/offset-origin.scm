; returns (offset X, offset Y, max W, max H) - the canvas origin and size
(define (offset-origin img)
  (let*
    (
      (chldrn (gimp-image-get-layers img))(lstL 0)(actL 0)(i 0)
      (maxW 0)(maxH 0)(offX 0)(offY 0)(minW 0)(minH 0)(wdth 0)(hght 0)
      (minY 0)(maxY 0)(minX 0)
    )
    (set! lstL (cadr chldrn))
    (while (< i (car chldrn))
      (set! actL (vector-ref lstL i))
      (set! offX (car(gimp-drawable-get-offsets actL)))
      (set! offY (cadr(gimp-drawable-get-offsets actL)))
      (set! wdth (car(gimp-drawable-get-width actL)))
      (set! hght (car(gimp-drawable-get-height actL)))
      
      (if (> minX offX)(set! minX offX))
      (if (< maxW wdth)(set! maxW wdth))
      (if (> minY offY)(set! minY offY))
      (if (< maxH hght)(set! maxH hght))
      (set! i (+ i 1))
    )

    (list (abs minX) (abs minY) (abs maxW) (abs maxH))

  )
)
