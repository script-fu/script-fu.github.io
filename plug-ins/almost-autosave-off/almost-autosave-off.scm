#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Under GNU GENERAL PUBLIC LICENSE Version 3"
(define (script-fu-almost-autosave-off)
  (let*
    (
      (i 0)(fID 0)(actP 0)(para (list->vector (car(gimp-get-parasite-list))))
      (dspID "autosave-display")(PID "autosave-pid")
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))

      ; found the display ID parasite to remove the indicator image
      (when (equal? actP dspID)
        (set! fID(string->number (caddar(gimp-get-parasite actP))))
        (if #f ;debug
          (gimp-message
            (string-append
              "removing display ID -> " (number->string fID)
            )
          )
        )
        (gimp-detach-parasite actP)
        (if(= (car(gimp-display-id-is-valid fID)) 1)(gimp-display-delete fID))
      )

      ; found the autosave process id parasite
      (when (equal? actP PID)
        (if #f (gimp-message (string-append "removing PID -> " actP)))
        (gimp-detach-parasite actP)
      )

      (set! i (+ i 1))
    )

    (gimp-message " autosave off ")

  )
)


(script-fu-register "script-fu-almost-autosave-off"
 "Almost Autosave Off "
 "turns off autosave"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-almost-autosave-off" "<Image>/File")