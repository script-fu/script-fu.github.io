; crops layer list to the mask area, plus a safe border
; (image, list of layers, border width)
(define (mask-box-crop img drwbls expand)
  (let*
    (
      (actL 0)(pnts 0)(mskSel 0)(wdth 0)(hgt 0)(offX 0)(offY 0)(i 0)(drwMsk 0)
    )

    (gimp-context-push)

    (while (< i (vector-length drwbls))
      (set! actL (vector-ref drwbls i))

      (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actL (car(gimp-layer-from-mask actL)))
      )

      (set! drwMsk (car (gimp-layer-get-mask actL)))

      (when (> drwMsk 0)
        (set! offX (car (gimp-drawable-get-offsets actL)))
        (set! offY (cadr (gimp-drawable-get-offsets actL)))
        (set! wdth (car (gimp-drawable-get-width actL)))
        (set! hgt (car (gimp-drawable-get-height actL)))
        (set! mskSel (gimp-image-select-item img CHANNEL-OP-REPLACE drwMsk))

        (set! pnts (list->vector(cdr (gimp-selection-bounds img))))
        (vector-set! pnts 0 (- (vector-ref pnts 0) expand))
        (vector-set! pnts 1 (- (vector-ref pnts 1) expand))
        (vector-set! pnts 2 (+ (vector-ref pnts 2) expand))
        (vector-set! pnts 3 (+ (vector-ref pnts 3) expand))

        (set! wdth (- (vector-ref pnts 2) (vector-ref pnts 0)))
        (set! hgt (- (vector-ref pnts 3) (vector-ref pnts 1)))
        (set! offX (- offX (vector-ref pnts 0)))
        (set! offY (- offY (vector-ref pnts 1)))

        (gimp-layer-resize actL wdth hgt offX offY)
      )

      (set! i (+ i 1))
    )

    (gimp-selection-none img)
    (gimp-context-push)

  )
)