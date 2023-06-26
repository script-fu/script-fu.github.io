; part of isolate selected
(define (restore-layer actL actT)
  (let*
    (
      (len (length (car(gimp-item-get-parasite-list actL))))
      (colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(dataStr "")
    )

    (when (> len 0)
      ; retrieve stored layer data
      (set! dataStr (caddar (gimp-item-get-parasite actL actT)))
      (set! dataStr (strbreakup dataStr "_"))
      (set! colTag (string->number (car dataStr)))
      (set! visTag (string->number (cadr dataStr)))
      (set! modeTag (string->number (caddr dataStr)))
      (set! opaTag (string->number (cadddr dataStr)))
      (gimp-item-set-color-tag actL colTag)
      (gimp-layer-set-opacity actL opaTag)

      ; special case
      (when (equal? "isolated" actT)
        (gimp-layer-set-mode actL modeTag)
        (gimp-item-set-visible actL visTag)
      )

      ; special case
      (when (equal? "isoParent" actT)
        (gimp-item-set-visible actL visTag)
      )

      (gimp-item-detach-parasite actL actT)
      (if (> (car(gimp-layer-get-mask actL)) 0)
        (gimp-layer-set-show-mask actL 0)
      )
    )
  )
)
