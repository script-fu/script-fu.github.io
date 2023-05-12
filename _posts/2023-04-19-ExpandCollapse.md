## Expand or Collapse Groups

# * Tested in GIMP 2.99.14 *

A simple tool that smartly expands or collapses nested groups. Detects the how it should behave depending on the groups content. Finds the average expanded state of a groups sub-groups, and conforms all groups to that. Once the sub-groups are aligned it toggles the expanded state of the sub groups whilst keeping the top group open. Works best when connected to a keyboard shortcut.
  
The plug-in should appear in the "Layer/Stack" menu.  
  
To download [**expand-collapse.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/expand-collapse/expand-collapse.scm)  
...follow the link, right click the page, Save as expand-collapse.scm, in a folder called expand-collapse, in a Gimp plug-ins location.  In Linux, set the file to be executable.
   
   

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"

(define (script-fu-expand-collapse img drwbles)
  (let*
    (
      (i 0)(allGrpLsts 0)(actGrpLst 0)(actG 0)(expd 0)(topGrp 0)(expdT 0)
      (grnChld 0)
    )

    ; filter the active selection
    (set! drwbles (exclude-children img drwbles))
    (set! drwbles (only-groups drwbles))

    ; create a list of group lists, branches of the layer tree
    (set! allGrpLsts (list->vector (get-branches img drwbles)))

    (while (< i (vector-length allGrpLsts))
      (set! actGrpLst (vector-ref allGrpLsts i))
      (set! actGrpLst (list->vector actGrpLst))
      (set! grnChld (grandchildren actGrpLst))

      ; find the top group in this list and expand if it's closed
      (set! topGrp (vector-ref actGrpLst (- (vector-length actGrpLst) 1)))
      (set! expdT (car (gimp-item-get-expanded topGrp)))
      (if (= expdT 0) (gimp-item-set-expanded topGrp 1))

      ; collapse the top level group if it has no grandchildren
      (if (and (= expdT 1) (= grnChld 0)) (gimp-item-set-expanded topGrp 0))

      ; find the average expanded state the group list
      (set! expd (get-average-expanded-state actGrpLst))

      (if #f ; debug
        (gimp-message
          (string-append
            " top group -> " (car (gimp-item-get-name topGrp))
            "\n expanded state -> " (number->string expdT)
            "\n expanded state beneath -> " (number->string expd)
            "\n grandchildren? -> " (number->string grnChld)
          )
        )
      )

      (expand-collapse-branch actGrpLst expd)

      (set! i (+ i 1))
    )

  )
)


(define (get-average-expanded-state grpLst)
 (let*
    (
       (i 0)(actG 0)(chldrn 0)(average 0)(total 0)(chldrn 0)(c 0)(expand 0)
    )

    ; don't count the top group or empty groups
    (while (< i (- (vector-length grpLst) 1))
      (set! actG (vector-ref grpLst i))
      (set! chldrn (gimp-item-get-children actG))
      (when (> (car chldrn) 0)
        (set! total (+ total (car(gimp-item-get-expanded actG))))
        (set! c (+ c 1))
      )
      (set! i (+ i 1))
    )
   
    (if (> c 0)(set! average (/ total c)))
    (if (>= average 0.5)(set! expand 0))
    (if (< average 0.5)(set! expand 1))
    (if (= average 0)(set! expand 0))
    (if (= average 1)(set! expand 1))
    (if #f ; debug
      (gimp-message
        (string-append
          " average expanded state -> " (number->string average)
          "\n state for toggle -> "(number->string (trunc expand))

        )
      )
    )

  expand
  )
)


(define (expand-collapse-branch actGrpLst state)
  (let*
    (
       (i 0)(actG 0)(chldrn 0)
    )

    (while (< i (- (vector-length actGrpLst) 1))
      (set! actG (vector-ref actGrpLst i))

      (if #f ; debug
        (gimp-message
          (string-append " testing group -> " (car (gimp-item-get-name actG)))
        )
      )

      (set! chldrn (gimp-item-get-children actG))
      (when (> (car chldrn) 0)
        (if (= state 1)(gimp-item-set-expanded actG 0))
        (if (= state 0)(gimp-item-set-expanded actG 1))
      )

      (set! i (+ i 1))
    )

  )
)


(define (get-branches img drwbles)
  (let*
    (
       (i 0)(allGrpLsts ())(actGrpLst 0)(actG 0)
    )

    ; make list of group lists, in the right order, deepest child first
    (while (< i (vector-length drwbles))
      (set! actG (vector-ref drwbles i))
      (set! actGrpLst (get-all-groups img actG))
      (set! actGrpLst (reverse actGrpLst))
      (set! allGrpLsts (append allGrpLsts (list actGrpLst)))
      (if #f ;debug
        (gimp-message
          (string-append
            " selected ->  " (car(gimp-item-get-name actG ))
            "\n number of groups ->  " (number->string (length actGrpLst))
            "\n number of group lists ->  " (number->string (length allGrpLsts))
          )
        )
      )
      (set! i (+ i 1))
    )
  
  allGrpLsts
  )
)


(define (grandchildren lst)
  (let*
    (
      (i 0)(actC 0)(grandchild 0)(chldrn 0)(j 0)(gchldrn 0)(actL 0)
    )

    (if (list? lst )(set! lst (list->vector lst)))
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! j 0)
      (when (> (car (gimp-item-is-group actL)) 0)
        (set! chldrn (gimp-item-get-children actL))
        (while (< j (car chldrn))
          (set! actC (vector-ref (cadr chldrn) j))
          (when (> (car (gimp-item-is-group actC)) 0)
            (set! gchldrn (gimp-item-get-children actC))
            (when (> (car gchldrn) 0)
              (if #f (gimp-message " this list has grandchildren "))
              (set! grandchild 1)
              (set! i (vector-length lst))
              (set! j (car chldrn))
            )
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    grandchild
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
    )

    ;add an initial group
    (when (> actL 0)
      (when (= (car (gimp-item-is-group actL)) 1)
        (if #f ;debug
          (gimp-message
            (string-append " initial group ->  "
                            (car(gimp-item-get-name actL))
                          "\n number of sub groups -> " 
                          (number->string (length allGrp))
            )
          )
        )
        (if (> (length allGrp) 1)(set! allGrp (reverse allGrp)))
        (set! allGrp (append allGrp (list actL)))
        (set! allGrp (reverse allGrp))
        (if (null? allGrp) (set! allGrp (list actL)))
      )
    )
    
    (if #f ;debug
      (gimp-message 
        (string-append " returning group length ->  "
                        (number->string (length allGrp))
        )
      )
    )

    allGrp
  )
)


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


(script-fu-register-filter "script-fu-expand-collapse"
 "Expand Group" 
 "Recursively expands or collapses the selection" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-expand-collapse" "<Image>/Layer/Stack")


```