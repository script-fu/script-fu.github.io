; sets a layers locks
; (layer id, lock content, lock position, lock visibility, lock alpha)
(define (set-lock-layer actL lckCon lckPos lckVis lckAlp)
  (gimp-item-set-lock-content actL lckCon)
  (gimp-item-set-lock-position actL lckPos)
  (gimp-item-set-lock-visibility actL lckVis)
  (gimp-layer-set-lock-alpha actL lckAlp)
)