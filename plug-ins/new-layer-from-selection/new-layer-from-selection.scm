#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

; a list of common names used for layers, add more "stuff"
(define layerNames (list "new" "eyes" "face" "neck" "hair" "pupils" "mouth" "brow"
                         "nose" "fur"
                         "jumper" "pants" "shorts" "dress" "skirt" "tongue"
                         "shoes" "socks" "t-shirt" "highlight" "background"
                         "sky" "ground" "stuff"
                   )
)

(define (script-fu-new-layer-from-selection img drwbls forcePick name nameSel mode alpha)
  (let*
    (
      (msk 0)
      (pVec 0)
      (pos 0)
      (actP 0)
      (actL (vector-ref drwbls 0))
      (actName 0)
      (wdth 0)
      (hgt 0)
      (i 0)
      (names 0)
    )

    (gimp-image-undo-group-start img)

    ; convert the name option integer to a string from the global names list
    (when (or (= (string-length name) 0) (equal? name "pick name") (= forcePick 1))
      (set! names (list->vector layerNames))
      (while (< i (vector-length names))
        (set! actName (vector-ref names i))
        (when (= i nameSel)
          (set! name actName)
          (set! i (vector-length names))
        )

        (set! i (+ i 1))
      )
    )

    (if (= (car(gimp-selection-is-empty img)) 1) (gimp-selection-all img))
    (set! actL (select-layer actL))

    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! actP (car (gimp-item-get-parent actL)))
    (set! pVec (list->vector (gimp-selection-bounds img)))
    (set! wdth (- (vector-ref pVec 3) (vector-ref pVec 1)))
    (set! hgt (- (vector-ref pVec 4) (vector-ref pVec 2)))

    (if (= mode 0) (set! mode 28))
    (if (= mode 1) (set! mode 30))
    (set! actL (car(gimp-layer-new img wdth hgt RGBA-IMAGE name 100 mode)))

    (gimp-layer-set-offsets actL (vector-ref pVec 1) (vector-ref pVec 2))
    (gimp-context-set-opacity 100)
    (gimp-image-insert-layer img actL actP pos)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (if (= alpha 0) (set! msk ADD-MASK-BLACK))
    (if (= alpha 1) (set! msk ADD-MASK-WHITE))
    (when (< alpha 2)
      (gimp-drawable-fill actL FILL-FOREGROUND)
      (add-mask actL msk)
    )

    (gimp-image-set-selected-layers img 1 (vector actL))
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register-filter "script-fu-new-layer-from-selection"
  "Layer From Selection"
  "creates a new layer from the selection area size"
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-DRAWABLE
  SF-TOGGLE     "_force pick name"      1
  SF-STRING     "_name"                 "pick name"
  SF-OPTION     "_pick name"            layerNames
  SF-OPTION     "_mode"                 (list "normal" "multiply")
  SF-OPTION     "_alpha"                (list "black mask" "white mask" "transparent")
)
(script-fu-menu-register "script-fu-new-layer-from-selection" "<Image>/Layer")
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


; makes sure user selection is a layer and not a mask
(define (select-layer actL)
  (let*
    (
      (isMsk(car (gimp-item-id-is-layer-mask actL)))
    )

    (if(= isMsk 1)(set! actL (car(gimp-layer-from-mask actL))))

    actL
  )
)


