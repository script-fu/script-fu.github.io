; part of precise scaling
(define (group-mask-protect img)
  (let*
    (
      (grpLst 0)(i 0)(grpWidth 0)(grpHeight 0)(grpMskFxL 0)(actG 0)(fixLst ())
      (offX 0)(offY)
    )

    (set! grpLst (get-all-groups img 0))
    (set! grpLst (list->vector grpLst))
    (while (< i (vector-length grpLst))
      (set! actG (vector-ref grpLst i))

      ; add a new layer to protect the mask
      (when (> (car (gimp-layer-get-mask actG)) 0)
        (set! offX (car(gimp-drawable-get-offsets actG)))
        (set! offY (cadr(gimp-drawable-get-offsets actG)))
        (set! grpWidth (car (gimp-drawable-get-width actG)))
        (set! grpHeight (car (gimp-drawable-get-height actG)))
        (set! grpMskFxL (car (gimp-layer-new img grpWidth 
                                                grpHeight
                                                RGBA-IMAGE 
                                                "groupMaskFix"
                                                0
                                                LAYER-MODE-NORMAL
                                )
                        )
        )

        (gimp-image-insert-layer img grpMskFxL actG 0)
        (gimp-layer-set-offsets grpMskFxL offX offY)
        (set! fixLst (append fixLst (list grpMskFxL)))
      )

      (set! i (+ i 1))
    )

    fixLst
  )
)