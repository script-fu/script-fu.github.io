#!/usr/bin/env gimp-script-fu-interpreter-3.0
;Under GNU GENERAL PUBLIC LICENSE Version 3
(define (script-fu-exitIsolation img)
  (let*
    (
      (lstL 0)(fileNme "")(fndP 0)
      (types (list "isolated" "hidden" "isoParent" "hiddenChld" "isoChild"))
    )

    (gimp-image-undo-group-start img)

    ; when the plugin is not locked via a text file
    (when (= (plugin-get-lock "exitIsolation") 0)

      (plugin-set-lock "exitIsolation" 1) ; now lock it
      (plugin-set-lock "isolateSelected" 1)

      ; store all the layers and groups
      (set! lstL (all-childrn img 0))
      (revert-layer img lstL types)

      (plugin-set-lock "exitIsolation" 0) ; unlock the plugin
      (plugin-set-lock "isolateSelected" 0) ; unlock the isolate plugin
      (gimp-displays-flush)
    )

    (gimp-message " exit isolation ")
    (gimp-image-undo-group-end img)

  )
)


(define (revert-layer img lstL types)
  (let*
    (
      (tagLst 0)(i 0)(actL 0)(t 0)(actT "")(isoP 0)
    )

    ; isolatedParents are a special case for speed up reasons
    (set! types (list->vector types))
    (set! isoP (find-layers-tagged img lstL "isoParent"))
    (set! isoP (remove-duplicates isoP))
    (set-list-visibility isoP 0)

    ; restore every type apart from isoParent
    (while (< t (vector-length types))
      (set! actT (vector-ref types t))
      (if #f (gimp-message actT)) ;debug
      (set! tagLst (find-layers-tagged img lstL actT))
      (set! tagLst (remove-duplicates (vector->list tagLst)))
      (set! tagLst (list->vector tagLst))
      (when (> (vector-length tagLst) 0)
        (set! i 0)
        (while (< i (vector-length tagLst))
          (set! actL (vector-ref tagLst i))
          (if (not(member actL isoP)) (restore-layer actL actT))
          (set! i (+ i 1))
        )
      )
      (set! t (+ t 1))
    )

    ; final pass - restore isolatedParents
    (if (list? isoP) (set! isoP (list->vector isoP)))
    (when (> (vector-length isoP) 0)
      (set! i 0)
      (while (< i (vector-length isoP))
        (set! actL (vector-ref isoP i))
        (restore-layer actL "isoParent")
        (set! i (+ i 1))
      )
    )

  )
)


(define (restore-layer actL actT)
  (let*
    (
      (len (length (car(gimp-item-get-parasite-list actL))))
      (colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(dataStr "")
    )

    (when (> len 0)
      ; retrieve stored layer data
      (set! dataStr (caddar (gimp-item-get-parasite actL actT)))
      (set! dataStr (strbreakup dataStr "_"))
      (set! colTag (string->number (car dataStr)))
      (set! visTag (string->number (cadr dataStr)))
      (set! modeTag (string->number (caddr dataStr)))
      (set! opaTag (string->number (cadddr dataStr)))
      (gimp-item-set-color-tag actL colTag)
      (gimp-layer-set-opacity actL opaTag)

      ; special case
      (when (equal? "isolated" actT)
        (gimp-layer-set-mode actL modeTag)
        (gimp-item-set-visible actL visTag)
      )

      ; special case
      (when (equal? "isoParent" actT)
        (gimp-item-set-visible actL visTag)
      )

      (gimp-item-detach-parasite actL actT)
      (if (> (car(gimp-layer-get-mask actL)) 0)
        (gimp-layer-set-show-mask actL 0)
      )
    )
  )
)


(define (plugin-get-lock plugin) 
  (let*
    (
      (input (open-input-file plugin))
      (lockValue 0)
    )

    (if input (set! lockValue (read input)))
    (if input (close-input-port input))

    lockValue
  )
)


(define (remove-duplicates grpLst)
  (let*
    (
      (i 0)(actGrp 0)(uniqGrps ())
    )
    
    (if (list? grpLst) (set! grpLst (list->vector grpLst)))
    (while (< i (vector-length grpLst))
      (set! actGrp (vector-ref grpLst i))
      (when (not (member actGrp uniqGrps))
         (set! uniqGrps (append uniqGrps (list actGrp)))
       )
      (set! i (+ i 1))
    )

  uniqGrps
  )
)


(define (set-list-visibility lstL vis)
  (let*
    (
      (vLst())(i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! vLst (append vLst (list actL (car(gimp-item-get-visible actL)))))
      (gimp-item-set-visible actL vis)
      (set! i (+ i 1))
    )

    vLst
  )
)


(define (plugin-set-lock plugin lock) 
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)


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


(define (find-layers-tagged img lstL tag)
  (let*
    (
      (tgdLst ())(pCountr 0)(actL 0)(paras 0)(pCount 0)
      (lstP 0)(pName 0)(i 0)(j 0)
    )

    (set! lstL (list->vector lstL))

    (set! i 0)
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paras (car (gimp-item-get-parasite-list actL)))
      (set! pCount (length paras))
      (when (> pCount 0)
        (set! lstP (list->vector paras))
        (set! j 0)
        (while(< j pCount)
          (set! pName (vector-ref lstP j))
          (when (equal? pName tag)
            (set! tgdLst (append tgdLst (list actL)))
            (set! pCountr (+ pCountr 1))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tgdLst)
  )
)


(script-fu-register "script-fu-exitIsolation"
  "Isolate Exit" 
  "Exit isolation mode" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-IMAGE       "Image"             0
)
(script-fu-menu-register "script-fu-exitIsolation" "<Image>/Tools")
