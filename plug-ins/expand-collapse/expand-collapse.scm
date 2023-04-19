#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-expand-collapse img drwbles)
  (let*
    (
      (i 0)(j 0)(allGrps ())(actGrps 0)(actG 0)(grpNme "")(expd 0)(topGrp 0)
    )

    ; filter the active selection
    (set! drwbles (exclude-children img drwbles))
    (set! drwbles (only-groups drwbles))

    ; create a list of group lists in the right order, deepest child first
    (while (< i (vector-length drwbles))
      (set! actG (vector-ref drwbles i))
      (set! actGrps (get-all-groups img actG))
      (set! actGrps (reverse actGrps))
      (set! allGrps (append allGrps (list actGrps)))
      (set! i (+ i 1))
    )

    ; toggle expand/collapse recursively based on the top level selected group
    (set! i 0)
    (set! allGrps (list->vector allGrps))

    (while (< i (vector-length allGrps))
      (set! actGrps (vector-ref allGrps i))
      (set! actGrps (list->vector actGrps))
        (set! topGrp (vector-ref actGrps (- (vector-length actGrps) 1)))
        (set! expd (car (gimp-item-get-expanded topGrp)))
        (set! j 0)

        (if #f ; debug
          (gimp-message
            (string-append
              " top group ->" (car (gimp-item-get-name topGrp))
            )
          )
        )

        (while (< j (vector-length actGrps))
          (set! actG (vector-ref actGrps j))

          (if #f ; debug
            (gimp-message
              (string-append " group -> " (car (gimp-item-get-name actG)))
            )
          )

          (if (= expd 1)(gimp-item-set-expanded actG 0))
          (if (= expd 0)(gimp-item-set-expanded actG 1))
          (set! j (+ j 1))
        )

      (set! i (+ i 1))
    )

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

      (when (= found 0)
        (set! excLst (append excLst (list actL)))
      )

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


(define (only-groups drwbles)
  (let*
    (
      (i 0)(actL 0)(grpLst())
    )

    (while (< i (vector-length drwbles))
      (set! actL (vector-ref drwbles i))
      (when (= (car (gimp-item-is-group actL)) 1)
        (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
          (set! actL (car(gimp-layer-from-mask actL)))
        )
        (set! grpLst (append grpLst (list actL)))
      )
      (set! i (+ i 1))
    )

    (list->vector grpLst)
  )
)


(define (get-all-groups img actL)
  (let*
    (
    (allGrp (get-sub-groups img actL))
    (grpTru 0)
    )

    ;add an initial group
    (if (> actL 0)(set! grpTru (car (gimp-item-is-group actL))))
    (when (= grpTru 1)
      (set! allGrp (reverse allGrp))
      (set! allGrp (append allGrp (list actL)))
      (set! allGrp (reverse allGrp))
    )

    allGrp
  )
)


(define (get-sub-groups img actL) ; recursive function
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(allL ())(allGrp ())
      (grpTru 0)
      
    )
    
    (if (> actL 0)(set! grpTru (car (gimp-item-is-group actL))))
    (if (= actL 0)(set! chldrn (gimp-image-get-layers img)))

    (when (> actL 0)
      (if (= grpTru 1)(set! chldrn (gimp-item-get-children actL)))
      (if (= grpTru 0)(set! chldrn (list 1 (list->vector (list actL)))))
    )

    (set! lstL (cadr chldrn))
    (while (< i (car chldrn))
      (set! actL (vector-ref lstL i))
      (when (equal? (car (gimp-item-is-group actL)) 1)
        (set! allGrp (append allGrp (list actL)))
        (set! allGrp (append allGrp (get-sub-groups img actL)))
      )
      (set! i (+ i 1))
    )

    allGrp
  )
)



(script-fu-register-filter "script-fu-expand-collapse"
 "Expand Group" 
 "Recursively expands or collapses the selection" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-expand-collapse" "<Image>/Tools")
