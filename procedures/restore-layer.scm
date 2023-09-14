; part of isolate selected
(define (restore-layer actL actT)
  (let*
    (
      (len (length (car(gimp-item-get-parasite-list actL))))
      (colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(dataStr "")(spcTag 0)
    )

    (when (> len 0)
      ; retrieve stored layer data
      (set! dataStr (caddar (gimp-item-get-parasite actL actT)))
      (set! dataStr (strbreakup dataStr "_"))
      (set! colTag (string->number (car dataStr)))
      (set! visTag (string->number (cadr dataStr)))
      (set! modeTag (string->number (caddr dataStr)))
      (set! opaTag (string->number (cadddr dataStr)))
      (set! spcTag (string->number (cadddr (cdr dataStr))))
      (gimp-item-set-color-tag actL colTag)
      (gimp-layer-set-opacity actL opaTag)

      ; special case, restore mode of isolated layer
      (if (equal? "isolated" actT) (gimp-layer-set-mode actL modeTag))

      ; restore layer composite space
      (gimp-layer-set-composite-space actL spcTag)

      (gimp-item-detach-parasite actL actT)
      (if (> (car(gimp-layer-get-mask actL)) 0)
        (gimp-layer-set-show-mask actL 0)
      )
    )

  visTag
  )
)
