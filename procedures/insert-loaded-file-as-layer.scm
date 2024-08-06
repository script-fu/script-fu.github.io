(define (insert-loaded-file-as-layer img filePath parent pos name vis randOffset)
  (let*
    (
       (actL 0)
       (offX 0)
       (offY 0)
       (wdth 0)
       (hght 0)
       (randX 0)
       (randY 0)
       (deltaX 0)
       (deltaY 0)
    )

    (if debug (gimp-message (string-append "loading file as layer: " filePath)))

    (set! actL (car(gimp-file-load-layer 1 img filePath)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-item-set-name actL name)

    (when randOffset
      (srand (realtime))
      (set! offX (car(gimp-drawable-get-offsets actL)))
      (set! offY (cadr(gimp-drawable-get-offsets actL)))
      (set! wdth (car(gimp-drawable-get-width actL)))
      (set! hght (car(gimp-drawable-get-height actL)))

      (set! deltaX (- wdth (car(gimp-image-get-width img))))
      (set! deltaY (- hght (car(gimp-image-get-height img))))

      (if (> deltaX 2) (set! randX (random-range 0 deltaX)))
      (if (> deltaY 2) (set! randY (random-range 0 deltaY)))

      (gimp-layer-set-offsets actL (- offX randX)  (- offY randY))
    )

    (gimp-item-set-visible actL vis)
    (gimp-layer-resize-to-image-size actL)

    actL
  )
)