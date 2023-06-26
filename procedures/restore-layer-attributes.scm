; sets a layers attributes from a "store-layer-attributes" list
; (layer id, list)
(define (restore-layer-attributes actL actLAttr)
  (let*
    (
    (actLAttr (list->vector actLAttr))
    )

    (gimp-item-set-name actL (vector-ref actLAttr 1))
    (gimp-layer-set-opacity actL (vector-ref actLAttr 4))
    (gimp-layer-set-mode actL (vector-ref actLAttr 5))
    (gimp-item-set-visible actL (vector-ref actLAttr 6))
    (gimp-item-set-color-tag actL (vector-ref actLAttr 7))
    (gimp-item-set-lock-position actL (vector-ref actLAttr 8))
    (gimp-layer-set-lock-alpha actL (vector-ref actLAttr 9))
    (gimp-item-set-lock-content actL (vector-ref actLAttr 10))
    (gimp-item-set-lock-visibility actL (vector-ref actLAttr 11))

  )
)