#!/usr/bin/env gimp-script-fu-interpreter-3.0
    ; detach global persistant with these commands for a clean start after use
    ; (gimp-detach-parasite "persist-global-undoable : 3")
    ; (gimp-detach-parasite "persist-global-not-undoable : 1")


(define (script-fu-parasites img drawables)
  (let*
    (
      (actL (vector-ref drawables 0))
    )

    (gimp-context-push)
    (gimp-image-undo-group-start img)

    (gimp-message "\n\n\n ****************")
    (gimp-message "\n* parasites found before attaching :")
    (print-parasites img actL " global parasite -> " 0 0 1)
    (print-parasites img actL " image parasite -> " 0 1 0)
    (print-parasites img actL " layer parasite -> " 1 0 0)

    (gimp-message "\n * attaching parasites -> type : mode \n\n\n\n\n")

    ; global
    (gimp-attach-parasite (list "temp-global-not-undoable : 0" 0 "0"))
    (gimp-attach-parasite (list "persist-global-not-undoable : 1" 1 "0"))
    (gimp-attach-parasite (list "temp-global-undoable : 2" 2 "0"))
    (gimp-attach-parasite (list "persist-global-undoable : 3" 3 "0"))

    ; image
    (gimp-image-attach-parasite img (list "temp-image-not-undoable : 0" 0 "0"))
    (gimp-image-attach-parasite img (list "persist-image-not-undoable : 1" 1"0"))
    (gimp-image-attach-parasite img (list "temp-image-undoable : 2" 2 "0"))
    (gimp-image-attach-parasite img (list "persist-image-undoable : 3" 3 "0"))

    ; layer
    (gimp-item-attach-parasite actL (list "temp-layer-not-undoable : 0" 0 "0"))
    (gimp-item-attach-parasite actL (list "persist-layer-not-undoable : 1"1"0"))
    (gimp-item-attach-parasite actL (list "temp-layer-undoable : 2" 2 "0"))
    (gimp-item-attach-parasite actL (list "persist-layer-undoable : 3" 3 "0"))

    (gimp-message " * \n parasites found after attaching :\n")
    (print-parasites img actL " global parasite -> " 0 0 1)
    (print-parasites img actL " image parasite -> " 0 1 0)
    (print-parasites img actL " layer parasite -> " 1 0 0)

    (gimp-message " \n * try undoing, and running the plug-in again :\n")
    (gimp-message " \n * then save->quit->restart->load, and run the plug-in" )

    (gimp-image-undo-group-end img)
    (gimp-context-pop)
    (gimp-displays-flush)

  )
)

(define (print-parasites img actL message layer image global)
  (let*
    (
    (pLst ())(i 0)
    )

    (if (= layer 1)
      (set! pLst (list->vector (car (gimp-item-get-parasite-list actL))))
    )
    (if (= image 1)
      (set! pLst (list->vector (car (gimp-image-get-parasite-list img))))
    )
    (if (= global 1)(set! pLst (list->vector (car (gimp-get-parasite-list)))))

    (while (< i (vector-length pLst))
      (gimp-message
        (string-append
          message (vector-ref pLst i)
        )
      )
      (set! i (+ i 1))
    )
  )
)


(script-fu-register-filter "script-fu-parasites"
 "parasites" 
 "testing parasites" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
  "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-parasites" "<Image>/Fu-Plugin")