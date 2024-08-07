#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-collapse-all img drwbls)
  (let*
    (
      (actGrpLst (list->vector (get-all-groups img 0))) (i 0) (actG 0)
    )

    (while (< i (vector-length actGrpLst))
      (set! actG (vector-ref actGrpLst i))

      (if #f; debug
        (gimp-message
          (string-append " closing group -> " (car (gimp-item-get-name actG)))
        )
      )

      (gimp-item-set-expanded actG 0)
      (set! i (+ i 1))
    )

  )
)


(script-fu-register-filter "script-fu-collapse-all"
 "Collapse All Groups"
 "Collapses all groups for a tidy stack"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-collapse-all" "<Image>/Layer/Stack")

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


; finds only the groups and not the layers in all the image or inside a group
; (source image, source group/all image) set last parameter to 0 for all image
; returns a list of all the groups found including the given group
(define (get-all-groups img actL)
  (let*
    (
    (allGrp (get-sub-groups img actL))
    )

    ;add an initial group
    (when (and (> actL 0)
               (= (car (gimp-item-is-group actL)) 1)
          )
      (if (> (length allGrp) 1)(set! allGrp (reverse allGrp)))
      (set! allGrp (append allGrp (list actL)))
      (set! allGrp (reverse allGrp))
      (if (null? allGrp) (set! allGrp (list actL)))
    )

    (if debug
      (gimp-message
        (string-append " returning group length ->  "
                        (number->string (length allGrp))
        )
      )
    )

    allGrp
  )
)


; also used by (get-all-groups)
; finds only the groups and not the layers in all the image or inside a group
; (source image, source group/all image) set last parameter to 0 for all image
; returns a list of all the groups found not including the given group
(define (get-sub-groups img actL) ; recursive function
  (let*
    (
      (chldrn (list 0 #()))(lstL 0)(i 0)(allL ())(allGrp ())
      (grpTru 0)(actC 0)
    )

    (if (> actL 0)(set! grpTru (car (gimp-item-is-group actL))))
    (if (= grpTru 1)(set! chldrn (gimp-item-get-children actL)))
    (if (= actL 0)(set! chldrn (gimp-image-get-layers img)))

    (when (> (car chldrn) 0)
      (set! lstL (cadr chldrn))
      (while (< i (car chldrn))
        (set! actC (vector-ref lstL i))

        (if #f ;debug
          (gimp-message
            (string-append
              " group ->  "(car(gimp-item-get-name actL))
              "\n child ->  "(car(gimp-item-get-name actC))
            )
          )
        )

        (when (equal? (car (gimp-item-is-group actC)) 1)
          (if #f (gimp-message " child was a group "))
          (set! allGrp (append allGrp (list actC)))
          (set! allGrp (append allGrp (get-sub-groups img actC)))
        )

        (set! i (+ i 1))
      )


      (when (= (car chldrn) 0) ;debug
        (if #f
          (gimp-message 
            (string-append " an empty group ->  "
                          (car(gimp-item-get-name actL))
            )
          )
        )
      )
    )

    allGrp
  )
)

