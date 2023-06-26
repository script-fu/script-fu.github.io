; returns a list of a layers attributes
; (source image, layer id)
(define (store-layer-attributes img actL)
  (let*
    (
      (parent 0)(pos 0)(lckVis 0)(nme "")(mde 0)(opac 0)(col 0)(vis 0)
      (lckPos 0)(lckAlp 0)(lckCnt 0)(id 0)
    )

    (set! id actL)
    (set! nme (car (gimp-item-get-name actL)))
    (set! parent (car (gimp-item-get-parent actL)))
    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! opac (car (gimp-layer-get-opacity actL)))
    (set! mde (car (gimp-layer-get-mode actL)))
    (set! vis (car(gimp-item-get-visible actL)))
    (set! col (car(gimp-item-get-color-tag actL)))
    (set! lckPos (car(gimp-item-get-lock-position actL)))
    (set! lckAlp (car(gimp-layer-get-lock-alpha actL)))
    (set! lckCnt (car(gimp-item-get-lock-content actL)))
    (set! lckVis (car(gimp-item-get-lock-visibility actL)))

    (list id nme parent pos opac mde vis col lckPos lckAlp lckCnt lckVis)

  )
)
