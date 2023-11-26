#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-proxy-restore-all img drwbles)
  (let*
    (
      (preFxL " Saved in -> ")
      (prxGrps (get-proxy-groups img preFxL))
    )

    (script-fu-proxy 1 img (vector-length prxGrps) prxGrps)

  )
)

(define debug #f)

(script-fu-register-filter "script-fu-proxy-restore-all"
 "Proxy Restore All"
 "Restores all proxies from disk"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE

)
(script-fu-menu-register "script-fu-proxy-restore-all" "<Image>/Layer")





; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message (string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; returns all the children of an image or a group as a list
; (source image, source group) set group to zero for all children of the image
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


(define (get-proxy srcGrp preFxL)
  (let*
    (
     (chldrn 0)(name 0)(found 0)
    )
    ; check for src group being a -1 parent
    (when (> srcGrp 0)
      (when (= (car (gimp-item-is-group srcGrp)) 1)
        (set! chldrn (gimp-item-get-children srcGrp))
        (when (> (vector-length (cadr chldrn) ) 0)
          (set! name (car(gimp-item-get-name (vector-ref (cadr chldrn) 0))))
          (set! name (strbreakup name preFxL))
          (when (> (length name) 1)
            (set! name (cadr name))
            (set! found 1)
          )
        )
      )
    )
    found
  )
)


(define (get-proxy-groups img preFxL)
  (let*
    (
      (lstL 0)(numL 0)(actL 0)(prxLst())(i 0)(found 0)
    )

    (set! lstL (all-childrn img 0))
    (set! lstL (list->vector lstL))
    (set! numL (vector-length lstL))

    (while (< i numL)
      (set! actL (vector-ref lstL i))
      (set! found (get-proxy actL preFxL))

      (when (= found 1)
        (set! prxLst (append prxLst (list actL)))
      )
      (set! i (+ i 1))
    )

  (list->vector prxLst)
  )
)




