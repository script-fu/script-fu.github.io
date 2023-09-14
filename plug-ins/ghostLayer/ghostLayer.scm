#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-ghostLayer img drawables) 
  (let*
    (
      (ghostOpacity 70) ; default opacity value for ghosting
      (actL (vector-ref drawables 0))(inkL 0) (unlck 0)(whtL 0)
      (nme (car (gimp-item-get-name actL)))
      (ghostName (string-append "ghosted-original-" nme ))
      (blankName (string-append "ghost-opacity-" nme ))
      (mde LAYER-MODE-MULTIPLY)(vis 1)(ghstGrp 0)
      (isGrp (car (gimp-item-is-group actL)))
    )

    (when (= isGrp 0)
      (gimp-image-undo-group-start img)
      (gimp-item-set-lock-content actL 0)
      (set! inkL (duplicate-layer img actL "tmpNme" 100 mde vis))
      (gimp-drawable-fill inkL FILL-WHITE)
      (gimp-item-set-name actL ghostName)
      (gimp-item-set-name inkL nme)
      (set! mde LAYER-MODE-NORMAL)
      (set! whtL (duplicate-layer img inkL blankName ghostOpacity mde vis))
      (set! ghstGrp (layer-group img (vector whtL actL)))
      (gimp-item-set-expanded ghstGrp 0)
      (gimp-item-set-lock-content ghstGrp 1)
      (gimp-image-raise-item img inkL)
      (gimp-image-set-selected-layers img 1 (vector inkL))
      (gimp-displays-flush)
      (gimp-image-undo-group-end img)
    )
    (when (= isGrp 1) (gimp-message " not ghosting a group "))
   
  )
)

(script-fu-register-filter "script-fu-ghostLayer"
  "Ghost Layer"
  "Turns a layer into a underlay ghost, puts a blank multiply layer on top" 
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-ghostLayer" "<Image>/Layer")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; duplicates a layer and assigns specific attributes
; (source image, source layer, new layer name, opacity, mode, visibility)
; returns the new layer id
(define (duplicate-layer img srcL name opac mode vis)
  (let*
    (
      (actL 0)
      (parent 0)
      (pos 0)
      (compSpc 0)
    )

    ; what's the layers composite space?
    (set! compSpc (car(gimp-layer-get-composite-space srcL)))

    (set! parent (car (gimp-item-get-parent srcL)))
    (set! pos (car (gimp-image-get-item-position img srcL)))
    (set! actL (car (gimp-layer-new-from-drawable srcL img)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-opacity actL opac)
    (gimp-layer-set-mode actL mode)
    (gimp-item-set-name actL name)
    (gimp-item-set-visible actL vis)

    ; restore composite space, due to it being reset to linear by mode change
    (gimp-layer-set-composite-space actL compSpc)

  actL
  )
)


; puts a list of layers in a group based on the stack pos of the first element
; (source image, list/vector of layers)
; returns the new group id
(define (layer-group img drwbls)
 (let*
    (
      (mde LAYER-MODE-NORMAL) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
      (nme "groupNme")
      (numDraw 0)(actL 0)(parent 0)(i 0)(pos 0)(grp 0)
    )
    
    (if (list? drwbls) (set! drwbls (list->vector drwbls)))
    (set! numDraw (vector-length drwbls))
    (set! actL (vector-ref drwbls 0))
    (set! parent (car (gimp-item-get-parent actL)))
    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! i (- numDraw 1))
    (set! grp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img grp parent pos)
    (gimp-item-set-name grp nme)
    (gimp-layer-set-mode grp mde)
    (gimp-layer-set-composite-space grp LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (while (> i -1)
      (set! actL (vector-ref drwbls i))
      (gimp-image-reorder-item img actL grp 0)
      (set! i (- i 1))
    )

    grp

  )
)

