#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-layer-group img drwbles)
  (let*
    (
      (addMask #f) ; puts a white mask on the group

      (mde LAYER-MODE-PASS-THROUGH) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
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
    (gimp-layer-set-composite-space grp LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (while (> i -1)
      (set! actL (vector-ref drwbles i))
      (gimp-image-reorder-item img actL grp 0)
      (set! i (- i 1))
    )

    (if addMask (add-mask grp ADD-MASK-WHITE))
    
    (gimp-image-undo-group-end img)

  )
)

(define debug #f)

(script-fu-register-filter "script-fu-layer-group"
 "Group Layers" 
 "Puts the selected layers in a pass-through group" 
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-layer-group" "<Image>/Layer")

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


; filters out children from a list of layers
; returns the top levels groups, or layers that are in the root and in the list
(define (exclude-children img lstL)
  (let*
    (
    (i 0)(actL 0)(excLst())(parent 0)(allParents 0)(j 0)(found 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! j 0)
      (set! found 0)
      (set! allParents (get-all-parents img actL))

      (while (< j (length allParents))
        (set! parent (nth j allParents))
          (when (and (member parent (vector->list lstL))
                (car (gimp-item-is-group actL)) )
            (set! found 1)
          )
      (set! j (+ j 1))
      )

      (when (= found 0)
        (set! excLst (append excLst (list actL)))
      )

      (set! i (+ i 1))
    )

  (list->vector excLst)
  )
)


(define (get-all-parents img actL)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent actL)))

    (if debug 
      (gimp-message 
        (string-append 
          "found parent ID: " 
          (number->string parent)
        )
      )
    )
    
    (when (> parent 0)
      (while (> parent 0)

        (set! allParents (append allParents (list parent)))
        (if debug 
          (gimp-message 
            (string-append 
              "found parent: " 
              (car(gimp-item-get-name parent))
            )
          )
        )
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )
    allParents
  )
)



; adds a mask to a layer of a given type;
; ADD-MASK-WHITE
; ADD-MASK-BLACK
; ADD-MASK-ALPHA
; ADD-MASK-ALPHA-TRANSFER
; ADD-MASK-SELECTION
; ADD-MASK-COPY
; ADD-MASK-CHANNEL
; returns the mask id
(define (add-mask actL type)
  (let*
    (
      (mask (car (gimp-layer-get-mask actL)))
    )

    (when (< mask 0)
      (set! mask (car (gimp-layer-create-mask actL type)))
      (gimp-layer-add-mask actL mask)
      (set! mask (car (gimp-layer-get-mask actL)))
      (if (equal? type ADD-MASK-WHITE)
        (gimp-message "white")
      )
    )

    mask
  )
)

