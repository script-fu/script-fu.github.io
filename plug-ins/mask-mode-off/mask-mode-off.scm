#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-mask-mode-off)
  (let*
    (
      (i 0)(actP 0)(para (list->vector (car(gimp-get-parasite-list))))
      (PID "mask-mode-pid")
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))

      ; found the mask-mode process id parasite
      (when (equal? actP PID)
        (if debug (gimp-message (string-append "removing PID -> " actP)))
        (gimp-detach-parasite actP)
      )

      (set! i (+ i 1))
    )

    (if debug (gimp-message " mask mode due to go off "))

  )
)

(define debug #f)

(script-fu-register "script-fu-mask-mode-off"
 "Mask Mode Off "
 "Turns off Mask Mode"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-mask-mode-off" "<Image>/Tools")




; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message(string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))

