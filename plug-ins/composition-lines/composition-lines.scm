#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-composition-lines img drwbls center thirds quarters fifths 
                                     golden overVal width opa)
  (let*
    (
      (actL (vector-ref drwbls 0)) (parent 0) (pos 0) (actNme "lines")
      (origL actL) (black (list 0 0 0)) (percent 0) (vertical #t) (actG 0)
      (horizontal #f) (opaC opa) (grp 0) (lineL 0) (actGrpLst()) (i 0)
    )

    (gimp-image-undo-group-start img)
    (set! actL (select-layer actL))
    (set! parent (car (gimp-item-get-parent actL)))
    (set! pos (car (gimp-image-get-item-position img actL)))
 
    (when (> center 0)
      (set! grp (car (gimp-layer-group-new img)))
      (gimp-image-insert-layer img grp parent pos)
      (gimp-item-set-name grp (string-append "Center_" actNme ))
      (gimp-layer-set-mode grp LAYER-MODE-PASS-THROUGH)
      (set! opaC (+ opaC 20))
      (if (> opaC 100) (set! opaC 100))
      (gimp-layer-set-opacity grp opaC) 

      (set! percent 50)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)

      (set! actGrpLst (append actGrpLst (list grp)))
    )

    (when (> thirds 0)
      (set! grp (car (gimp-layer-group-new img)))
      (gimp-image-insert-layer img grp parent pos)
      (gimp-item-set-name grp (string-append "Third_" actNme ))
      (gimp-layer-set-mode grp LAYER-MODE-PASS-THROUGH)
      (gimp-layer-set-opacity grp opa) 

      (set! percent 33)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
      
      (set! percent 66)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)

      (set! actGrpLst (append actGrpLst (list grp)))
    )

    (when (> quarters 0)
      (set! grp (car (gimp-layer-group-new img)))
      (gimp-image-insert-layer img grp parent pos)
      (gimp-item-set-name grp (string-append "Quarter_" actNme ))
      (gimp-layer-set-mode grp LAYER-MODE-PASS-THROUGH)
      (gimp-layer-set-opacity grp opa) 

      (set! percent 25)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
      
      (set! percent 50)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)

      (set! percent 75)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
    
      (set! actGrpLst (append actGrpLst (list grp)))
    )

    (when (> fifths 0)
      (set! grp (car (gimp-layer-group-new img)))
      (gimp-image-insert-layer img grp parent pos)
      (gimp-item-set-name grp (string-append "Fifth_" actNme ))
      (gimp-layer-set-mode grp LAYER-MODE-PASS-THROUGH)
      (gimp-layer-set-opacity grp opa) 

      (set! percent 20)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
      
      (set! percent 40)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)

      (set! percent 60)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
      
      (set! percent 80)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)

      (set! actGrpLst (append actGrpLst (list grp)))
    )

    (when (> golden 0)
      (set! grp (car (gimp-layer-group-new img)))
      (gimp-image-insert-layer img grp parent pos)
      (gimp-item-set-name grp (string-append "GoldenRatio_" actNme ))
      (gimp-layer-set-mode grp LAYER-MODE-PASS-THROUGH)
      (gimp-layer-set-opacity grp opa) 

      (set! percent 38.2)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
      
      (set! percent 61.8)
      (set! lineL (sketch-guide img parent width black percent vertical overVal))
      (gimp-image-reorder-item img lineL grp 0)
      (set! lineL (sketch-guide img parent width black percent horizontal overVal))
      (gimp-image-reorder-item img lineL grp 0)
      
      (set! actGrpLst (append actGrpLst (list grp)))
    )

    (when (not (null? actGrpLst))
      (set! actGrpLst (list->vector actGrpLst))
      (while (< i (vector-length actGrpLst))
        (set! actG (vector-ref actGrpLst i))
        (gimp-item-set-expanded actG 0)
        (set! i (+ i 1))
      )
    )

    (gimp-image-undo-group-end img)
    (gimp-displays-flush)

  )
)


(define (sketch-guide img parent width color percent vertical overVal)
  (let*
    (
      (wdth (car (gimp-image-get-width img)))
      (hght (car (gimp-image-get-height img)))
      (actL 0) (typ RGBA-IMAGE) (mde LAYER-MODE-NORMAL)
      (pos 0) (offX 0) (offY 0)
      (nme (string-append "sketch-guide-" (number->string percent) "%"))
    )

    (when vertical 
      (set! offX (* (/ percent 100) wdth))
      (set! offY (- offY overVal))
      (set! wdth width)
      (set! nme (string-append nme "-vertical"))
      (set! actL (car (gimp-layer-new img wdth (+ hght (* 2 overVal)) typ nme 100 mde)))
    )

    (when (not vertical)
      (set! offY (* (/ percent 100) hght))
      (set! offX (- offX overVal))
      (set! hght width)
      (set! nme (string-append nme "-horizontal"))
      (set! actL (car (gimp-layer-new img (+ wdth (* 2 overVal)) hght typ nme 100 mde)))
    )
    
    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-offsets actL offX offY)
    (gimp-context-push)
    (gimp-context-set-opacity 100)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
    (gimp-context-set-foreground color)
    (gimp-drawable-fill actL 0)
    (gimp-context-pop)

    actL
  )
)


(script-fu-register-filter "script-fu-composition-lines"
 "Composition Lines"
 "Creates guide lines for sketching"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-TOGGLE     "Cent_er"   TRUE
 SF-TOGGLE     "_Thirds"   FALSE
 SF-TOGGLE     "_Quarters" FALSE
 SF-TOGGLE     "_Fifths"   FALSE
 SF-TOGGLE     "_Golden"   FALSE
 SF-ADJUSTMENT "Line O_ver" (list 16 0 100 1 10 0 SF-SPINNER)
 SF-ADJUSTMENT "Line _Width" (list 4 0 100 1 10 0 SF-SPINNER)
 SF-ADJUSTMENT "Layer Opacit_y" (list 30 0 100 1 10 0 SF-SPINNER)
)
(script-fu-menu-register "script-fu-composition-lines" "<Image>/Tools")
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


