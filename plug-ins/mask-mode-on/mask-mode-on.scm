#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Under GNU GENERAL PUBLIC LICENSE Version 3"
; Use additional plugin "Mask Mode Off" to disable.
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3


(define (script-fu-mask-mode-on img)
  (let*
    (
      (timeDelay 0.001) ; mask-mode check frequency
      (mmPID 0)(pIDf 0)(actL 0)(msk 0)(colLst 0)(col 6)
    )

    ; set foreground colour to white, background to black
    (gimp-context-set-default-colors)
    (gimp-context-swap-colors)

    ; if mask-mode is not on
    (when (= (mask-mode-active "mask-mode-pid") 0)

      ; turn on
      (set! mmPID (mask-mode-on))

      ; store all the current layer colors and set them to indicate a "mode"
      (set! colLst (set-and-store-all-layer-colors img col))

      ; mask-mode loop, while a parasite with a PID exists
      (while (> (mask-mode-match-pid "mask-mode-pid" mmPID) 0)
        (when debug
          (set! pIDf (mask-mode-match-pid "mask-mode-pid" mmPID))
          (gimp-message
            (string-append
              " \n current mask-mode PID -> " (number->string pIDf)
            )
          )
        )

        (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img)) 0))
        (set! msk (car (gimp-layer-get-mask actL)))
        (if (> msk 0)(gimp-layer-set-edit-mask actL 1))

        (usleep (* 60 (* timeDelay 1000000)))
      ); mask mode loop

      (restore-all-layer-colors colLst)

      (if info
        (if(= (mask-mode-match-pid "mask-mode-pid" mmPID) 0)
          (gimp-message" mask-mode is now off ")
        )
      )

    )

  )
)


(define (mask-mode-on)
   (let*
    (
      (mmPID 0)
    )

    ; create a global parasite to record the mask-mode process ID
    (srand (realtime))
    (set! mmPID (number->string (rand 1000000)))
    (gimp-attach-parasite (list "mask-mode-pid" 0 mmPID))
    (gimp-message " mask-mode on ")
    (string->number mmPID)

  )
)


(define (mask-mode-active findNme)
  (let*
    (
      (i 0)(found 0)(actP 0)
      (para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP findNme)
        (gimp-message " mask-mode already active ")
        (set! found 1)
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

    found
  )
)


(define (mask-mode-match-pid findNme PID)
  (let*
    (
      (i 0)(fndPID 0)(actP 0)(para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP findNme)
        (set! fndPID (string->number (caddar(gimp-get-parasite findNme))))
        (set! i (vector-length para))
      )

      (if (not (= fndPID PID)) (set! fndPID 0))
      (set! i (+ i 1))
    )

    fndPID
  )
)


(define (set-and-store-all-layer-colors img col)
  (let*
    (
      (i 0)(lstL ())(actL 0)(colLst())(colT 0)
    )

    (set! lstL (all-childrn img 0))
    (set! lstL (list->vector lstL))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! colT (car(gimp-item-get-color-tag actL)))
      (set! colLst (append colLst (list actL colT)))
      (gimp-item-set-color-tag actL col)
      (set! i (+ i 1))
    )

    colLst
  )
)


(define (restore-all-layer-colors colLst)
  (let*
    (
      (actL 0)(i 0)(exst 0)
    )

    (if (list? colLst) (set! colLst (list->vector colLst)))
    (while (< i (vector-length colLst))
      (set! actL (vector-ref colLst i))
      (set! exst (car (gimp-item-id-is-valid actL)))
      (when (= exst 1)
        (gimp-item-set-color-tag actL (vector-ref colLst (+ i 1)))
      )
      (set! i (+ i 2))
    )

  )
)


(define (all-childrn img rootGrp) ; recursive
  (let*
    (
      (chldrn ())(lstL 0)(i 0)(actL 0)(allL ())
    )

    (if (= rootGrp 0)
      (set! chldrn (gimp-image-get-layers img))
        (if (equal? (car (gimp-item-is-group rootGrp)) 1)
          (set! chldrn (gimp-item-get-children rootGrp))
        )
    )

    (when (not (null? chldrn))
      (set! lstL (cadr chldrn))
      (while (< i (car chldrn))
        (set! actL (vector-ref lstL i))
        (set! allL (append allL (list actL)))
        (if (equal? (car (gimp-item-is-group actL)) 1)
          (set! allL (append allL (all-childrn img actL)))
        )
        (set! i (+ i 1))
      )
    )

    allL
  )
)


(script-fu-register "script-fu-mask-mode-on"
 "Mask Mode On" 
 "Forces the active layers mask to be active"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-IMAGE "Image" 0
)
(script-fu-menu-register "script-fu-mask-mode-on" "<Image>/Tools")

; debug and error tools
(define (err msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))
(define debug #f)  ; print information
(define info #t)  ; print information
(define (boolean->string bool) (if bool "#t" "#f"))