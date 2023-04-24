#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-layer-group img drwbles)
  (let*
    (
      (mde LAYER-MODE-NORMAL) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
      (nme "groupName")

      (drwbles (exclude-children img drwbles))
      (numDraw (vector-length drwbles))(actL (vector-ref drwbles 0))
      (parent (car (gimp-item-get-parent actL)))(i (- numDraw 1))
      (pos (car (gimp-image-get-item-position img actL)))(grp 0)
    )

    (gimp-image-undo-group-start img)

    (set! grp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img grp parent pos)
    (gimp-item-set-name grp nme)
    (gimp-layer-set-mode grp mde)

    (while (> i -1)
      (set! actL (vector-ref drwbles i))
      (gimp-image-reorder-item img actL grp 0)
      (set! i (- i 1))
    )

    (gimp-image-undo-group-end img)

  )
)


(define (exclude-children img drwbles)
  (let*
    (
    (i 0)(actL 0)(excLst())(parent 0)(allParents 0)(j 0)(found 0)
    )

    (while (< i (vector-length drwbles))
      (set! actL (vector-ref drwbles i))
      (set! j 0)
      (set! found 0)
      (set! allParents (get-all-parents img actL))

      (while (< j (length allParents))
        (set! parent (nth j allParents))
          (when (and (member parent (vector->list drwbles)) 
                (car (gimp-item-is-group actL)) )
            (set! found 1)
          )
      (set! j (+ j 1))
      )

      (if (= found 0)(set! excLst (append excLst (list actL))))

      (set! i (+ i 1))
    )

  (list->vector excLst)
  )
)


(define (get-all-parents img drawable)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent drawable)))

    (when (> parent 0)
      (while (> parent 0)
        (set! allParents (append allParents (list parent)))
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )

    allParents
  )
)


(script-fu-register-filter "script-fu-layer-group"
 "Group" 
 "Puts the selected layers in a pass-through group" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-group" "<Image>/Tools")
