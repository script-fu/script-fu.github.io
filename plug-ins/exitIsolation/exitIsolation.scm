#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

;Under GNU GENERAL PUBLIC LICENSE Version 3
(define (script-fu-exitIsolation img drwbles)
  (let*
    (
      (lstL 0)(fileNme "")(fndP 0)
      (types (vector "isolated" "hidden" "isoParent" "hiddenChld" "isoChild"))
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

(script-fu-register-filter "script-fu-exitIsolation"
  "Isolate Exit" 
  "Exit isolation mode" 
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE ;
)
(script-fu-menu-register "script-fu-exitIsolation" "<Image>/Tools")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message(string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; creates a "plugin" file on disk and writes the first line, lock (0/1)
(define (plugin-set-lock plugin lock)
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)



; looks for a "plugin" file on disk and reads the first line
; returns the first line. used to see if a plugin is already active/locked
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


; filters a list, removing duplicates, returns a new list
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


; stores and sets the visibility state of a layer list
(define (set-list-visibility img lstL vis)
  (let*
    (
      (vLst())(i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))

    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! vLst (append vLst (list actL (car(gimp-item-get-visible actL)))))
      ;(gimp-item-set-visible actL vis)
      (set! i (+ i 1))
    )

    ;Experimental plug-in
    (pm-set-items-visibility 1 img (vector-length lstL) lstL vis)

    ;return the list of stored visibility states
    vLst
  )
)


; returns all the children of an image or a group as a list
; (source image, source group) set group to zero for all children of the image
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


; given a list of layers and a "parasite" name it returns those layers with it
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


; part of isolate selected
(define (revert-layer img lstL types)
  (let*
    (
      (tagLst 0)(i 0)(actL 0)(t 0)(actT "")(isoP 0)(hLst())(vLst())(visTag 0)
    )

    ; restore every type
    (while (< t (vector-length types))
      (set! actT (vector-ref types t))
      (if debug (gimp-message actT))
      (set! tagLst (find-layers-tagged img lstL actT))
      (set! tagLst (remove-duplicates (vector->list tagLst)))
      (set! tagLst (list->vector tagLst))
      (when (> (vector-length tagLst) 0)
        (set! i 0)
        (while (< i (vector-length tagLst))
          (set! visTag 0)
          (set! actL (vector-ref tagLst i))
          (set! visTag (restore-layer actL actT))

          (if (= visTag 1) (set! vLst (append vLst (list actL))))
          (if (= visTag 0) (set! hLst (append hLst (list actL))))

          (set! i (+ i 1))
        )
      )
      (set! t (+ t 1))
    )

    (when debug (gimp-message " restore visible layers:")
      (print-layer-id-name vLst)
    )

    (when debug (gimp-message " restore hidden layers: ")
      (print-layer-id-name hLst)
    )

    (set! vLst (list->vector vLst))
    (set! hLst (list->vector hLst))

    ; final pass - restore visibility for tagged layers
    (pm-set-items-visibility 1 img (vector-length vLst) vLst 1)
    (pm-set-items-visibility 1 img (vector-length hLst) hLst 0)

  )
)


; part of isolate selected
(define (restore-layer actL actT)
  (let*
    (
      (len (length (car(gimp-item-get-parasite-list actL))))
      (colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(dataStr "")(spcTag 0)
    )

    (when (> len 0)
      ; retrieve stored layer data
      (set! dataStr (caddar (gimp-item-get-parasite actL actT)))
      (set! dataStr (strbreakup dataStr "_"))
      (set! colTag (string->number (car dataStr)))
      (set! visTag (string->number (cadr dataStr)))
      (set! modeTag (string->number (caddr dataStr)))
      (set! opaTag (string->number (cadddr dataStr)))
      (set! spcTag (string->number (cadddr (cdr dataStr))))
      (gimp-item-set-color-tag actL colTag)
      (gimp-layer-set-opacity actL opaTag)

      ; special case, restore mode of isolated layer
      (if (equal? "isolated" actT) (gimp-layer-set-mode actL modeTag))

      ; restore layer composite space
      (gimp-layer-set-composite-space actL spcTag)

      (gimp-item-detach-parasite actL actT)
      (if (> (car(gimp-layer-get-mask actL)) 0)
        (gimp-layer-set-show-mask actL 0)
      )
    )

  visTag
  )
)


