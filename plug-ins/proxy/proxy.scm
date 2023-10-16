#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-proxy img drwbles)
  (let*
    (
      (i 0)(isPrx 0)(srcGrp 0)(actL 0)(prxF "")(numDrw 0)
      (preFxL " Saved in -> ")
      (prxTag " ! Proxy ! ")
      (sDir "_proxySaves")
      (sveInfo "layerInfo")
      (prxGrps ())(prxDo 0)
      (fileName (car(gimp-image-get-file img)))
      (mode INTERPOLATION-CUBIC) ; LINEAR ; CUBIC ; NOHALO ; LOHALO ; NONE
    )

    (if (equal? fileName "") (exit "\nSave your image before using proxy"))

    (when (= (plugin-get-lock "proxy") 1)
      (exit " A proxy lock-out is on, try deleting the 'proxy' text 
              file in your Home directory in Linux or your User directory 
              in Windows.\n

              Then run the proxy plug-in again.")
    )

    (when (= (plugin-get-lock "proxy") 0)
      
      (plugin-set-lock "proxy" 1)

      (gimp-context-push)
      (gimp-image-undo-group-start img)
      (gimp-context-set-interpolation mode)
      (gimp-selection-none img) 
      (gimp-image-freeze-layers img)

      ; which items to process
      (set! drwbles (filter-selected img drwbles preFxL))
      (set! numDrw (vector-length drwbles))

      ; save or restore proxy
      (while (< i numDrw)
        (message-progress i numDrw "proxy plugin progress")
        (set! srcGrp (vector-ref drwbles i))
        (set! isPrx (get-proxy srcGrp preFxL))

        ; create a proxy
        (if (= isPrx 0)
         (set! prxF (store-group-in-file img srcGrp preFxL prxTag sDir sveInfo))
        )

        ; restore from a proxy
        (when (= isPrx 1)
          (set! actL (restore-group img srcGrp preFxL prxTag sveInfo))
          (if (> actL 0) (set! prxGrps (append prxGrps (list actL))))
        )
        (set! i (+ i 1))
      )

      ; restore selections
      (when (= isPrx 1)
        (set! prxGrps (remove-invalid-items prxGrps))
        (when (> (vector-length prxGrps) 0)
          (gimp-image-set-selected-layers img (vector-length prxGrps) prxGrps)
          (close-groups prxGrps)
        )
      )

      (when (= isPrx 0)
        (set! drwbles (remove-invalid-items drwbles))
        (when (> (vector-length drwbles) 0)
          (gimp-image-set-selected-layers img (vector-length drwbles) drwbles)
          (close-groups drwbles)
        )
      )

      (gimp-image-set-file img fileName)
      (gimp-image-thaw-layers img)
      (gimp-context-pop)
      (gimp-displays-flush)
      (gimp-image-undo-group-end img)
      (plugin-set-lock "proxy" 0)
    )

  )
)


(define (restore-proxy-attributes actL actLAttr)
  (let*
    (
    (actLAttr (list->vector actLAttr))
    )

    (gimp-layer-set-opacity actL (vector-ref actLAttr 4))
    (gimp-layer-set-mode actL (vector-ref actLAttr 5))
    (gimp-item-set-visible actL (vector-ref actLAttr 6))
    (gimp-item-set-lock-position actL (vector-ref actLAttr 8))
    (gimp-layer-set-lock-alpha actL (vector-ref actLAttr 9))
    (gimp-item-set-lock-content actL (vector-ref actLAttr 10))
    (gimp-item-set-lock-visibility actL (vector-ref actLAttr 11))
    (gimp-layer-set-composite-space actL (vector-ref actLAttr 12))

  )
)


(define (store-group-in-file img srcGrp preFxL prxTag sDir sveInfo)
  (let*
    (
    (selDraw 0)(fileInfo (get-image-file-info img))(saveNme "")
    (grpNme (car(gimp-item-get-name srcGrp)))
    (srcNme (string-append grpNme ".xcf" ))
    (fPth (vector-ref fileInfo 3))(fNoExt (vector-ref fileInfo 2))
    (prxD (string-append fNoExt sDir))(prxImg 0)
    (dirPth (string-append "/" fPth "/" fNoExt sDir "/" grpNme))(winPth "")
    (brkTok DIR-SEPARATOR)
    )

    (set! saveNme (string-append fPth brkTok prxD brkTok grpNme brkTok srcNme))
    (set! winPth (string-append fPth "/" fNoExt sDir "/" grpNme))

    ; make a proxy source group save file and a proxy layer replacement
    (set! prxImg (make-proxy-from-source img srcGrp preFxL prxTag sDir saveNme))

    ; save the new image as the proxy source
    (make-dir-path dirPth)
    (set! selDraw (cadr (gimp-image-get-selected-layers prxImg)))
    (gimp-xcf-save 0 prxImg 0 selDraw saveNme)

    ; record the image size when the proxy was created, delete the proxy source
    (save-layer-info img (string-append winPth brkTok sveInfo))
    (gimp-image-delete prxImg)

    saveNme
  )
)


(define (make-proxy-from-source img srcGrp preFxL prxTag sDir saveNme)
  (let*
    (
      (mskOn 0)(unlock 0)(allLcks 0)(placehL 0)(lckLst 0)(prxInfo 0)(prxImg 0)
      (prxL 0)(prxLMsk 0)(actL 0)(tmpL 0)(mde 28)(whte (list 255 255 255))
      (wdthL (car (gimp-drawable-get-width srcGrp)))
      (hghtL (car (gimp-drawable-get-height srcGrp)))
      (offX (car(gimp-drawable-get-offsets srcGrp)))
      (offY (cadr(gimp-drawable-get-offsets srcGrp)))
      (inkImg (get-image-parasite img "ink"))

    )

    (set! prxInfo (group-to-new-image img srcGrp))
    (set! prxImg (car prxInfo))
    (set! prxL (cadr prxInfo))
    (set! prxLMsk (caddr prxInfo))

    ; take a copy visible to act as a proxy, but turn off folder mask first
    (set! mskOn (car (gimp-layer-get-apply-mask prxL)))
    (if (> prxLMsk 0) (gimp-layer-set-apply-mask prxL 0))
    (gimp-selection-none prxImg)

    ; groups set up with multiply mode rather than normal mode need a background
    (when inkImg
      (gimp-message " working on a multiply mode group ")
      (set! tmpL (add-layer prxImg prxL 0 "temp" mde 100 whte))
      (gimp-image-lower-item-to-bottom prxImg tmpL)
    )

    (gimp-edit-copy-visible prxImg)

    ; remove the temporary white background for an ink image
    (if inkImg (gimp-image-remove-layer prxImg tmpL))

    (if (> prxLMsk 0) (gimp-layer-set-apply-mask prxL mskOn))

    ; unlock everything and place the proxy in the src group folder
    (set! lckLst (set-and-store-all-locks img allLcks unlock))
    (set! placehL (reduce-group img srcGrp preFxL prxTag sDir saveNme))
    (if inkImg (set! mde LAYER-MODE-MULTIPLY))
    (set! actL (paste-copied-layer img placehL 100 mde 1))
    ;crop to extent of original group
    (gimp-layer-resize actL wdthL hghtL (- 0 offX) (- 0 offY))
    (restore-all-locks lckLst)
    (set-lock-layer placehL 1 1 1 1)
    (gimp-item-set-color-tag srcGrp 8)

    prxImg
  )
)


(define (restore-group img srcGrp preFxL prxTag sveInfo)
  (let*
    (
      (globR "")(prxSrc 0)(lckLst 0)(unlock 0)(allLcks 0)(prxImg 0)
      (srcNme (car(gimp-item-get-name srcGrp)))(scale 0)(prxSrcGrp 0)
      (srcPos (car(gimp-image-get-item-position img srcGrp)))(buffL 0)
      (srcPrnt (car(gimp-item-get-parent srcGrp)))(scX 1)(scY 1)
      (fileNme "")(grpMsk 0)(prxSrcMsk 0)(prxInfo 0)(srcGrpAttr 0)
    )

    (set! srcGrpAttr (store-layer-attributes img srcGrp))

    ; recover data from proxy layer and txt file record
    (set! prxInfo (get-file-info-from-proxy img srcGrp preFxL prxTag sveInfo))
    (set! globR (vector-ref prxInfo 0))
    (set! fileNme (vector-ref prxInfo 1))
    (set! scale (vector-ref prxInfo 2))
    (set! srcNme (vector-ref prxInfo 3))
    (set! scX (vector-ref prxInfo 4))
    (set! scY (vector-ref prxInfo 5))

    ; no file?
    (if (equal? () globR) (gimp-message (string-append " gone!\n -> " fileNme)))
    (if (not (equal? () globR)) (set! globR (car globR)))

    ; load a proxy file as a layer if it's there on disk
    (when (equal? globR fileNme)
      (set! prxImg (car(gimp-file-load 0 globR)))
      ;(gimp-item-set-visible prxSrc 0)
      ;(gimp-image-insert-layer img prxSrc srcPrnt srcPos)

      ; if image and loaded proxy have scale mismatch, scale the proxy image
      (when (> scale 0)
        (precise-scale-proxy prxImg (* scX 100) (* scY 100))
        ;(gimp-display-new prxImg)
      )

      (set! prxSrcGrp (vector-ref (cadr (gimp-image-get-layers prxImg))0))
      (gimp-item-set-visible prxSrcGrp 0)

      ; add the loaded proxy group as a new group in the image
      (set! lckLst (store-all-locks prxImg prxSrcGrp))

      (group-to-image prxImg prxSrcGrp img 0)

      (set! prxSrcGrp (vector-ref(cadr(gimp-image-get-selected-layers img))0))
      (transfer-all-locks img prxSrcGrp lckLst)

      ; gimp api bug, workaround reorder
      (set! prxSrcGrp (reorder-item img prxSrcGrp srcPrnt srcPos))

      (set! lckLst (set-and-store-all-locks img allLcks unlock))

      ; update loaded group with the proxy mask, user may have edited it
      (set! grpMsk (car(gimp-layer-get-mask srcGrp)))
      (set! prxSrcMsk (car(gimp-layer-get-mask prxSrcGrp)))
      (if (> grpMsk 0)(transfer-mask-to-mask img grpMsk img prxSrcMsk))

      ; transfer attributes to loaded source from proxy and remove proxy
      (restore-proxy-attributes prxSrcGrp srcGrpAttr)
      (gimp-image-remove-layer img srcGrp)
      (gimp-image-delete prxImg)
      (gimp-item-set-name prxSrcGrp srcNme)

      (if (> (length lckLst) 0)(restore-all-locks lckLst))
    )

  prxSrcGrp
  )
)


(define (get-file-info-from-proxy img srcGrp preFxL prxTag sveInfo)
  (let*
    (
      (placehL 0)(globR "")(infoD 0)(fPth "")(wdthR 0)(hghtR 0)(scale 0)
      (srcNme (car(gimp-item-get-name srcGrp)))(fileNme "")(placehLNme "")
      (infoFNme)(fileBase "")(fNoExt "")(brkTok DIR-SEPARATOR)
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (recD 0)(scX 1)(scY 1)
    )

    ; recover data from proxy layer and txt file record
    (set! srcNme (car(reverse (strbreakup srcNme prxTag ))))
    (set! placehL (vector-ref (cadr (gimp-item-get-children srcGrp) )0))
    (set! placehLNme (car (gimp-item-get-name placehL)))
    (set! fileNme (car(reverse (cdr (strbreakup placehLNme preFxL)))))
    (set! globR (car(file-glob fileNme 0)))
    (set! fileBase (car (reverse (strbreakup fileNme brkTok))))
    (set! fNoExt (car (strbreakup fileBase ".")))
    (set! fPth (reverse (cdr (reverse (strbreakup fileNme brkTok)))))
    (set! fPth (unbreakupstr fPth brkTok))
    (set! infoFNme (string-append fPth brkTok sveInfo ))

    ; load recorded proxy information from data file, check for scale mismatch
    (set! infoD (load-layer-info infoFNme))
    ;(gimp-message (car infoD))
    ;(gimp-message (cadr infoD))
    (set! wdthR (string->number (car infoD)))
    (set! hghtR (string->number (cadr infoD)))
    (set! recD (caddr infoD))

    (when (or (not(= width wdthR)) (not(= height hghtR)))
      (when (= recD 1)
        (set! scX (/ width wdthR))
        (set! scY (/ height hghtR))
        (set! scale 1)
        ; (gimp-message
        ;   (string-append
        ;     " scale changed since proxy was made "
        ;     "  ratio :  ("
        ;     (number->string (/ (trunc (* scX 100 )) 100)) ", "
        ;     (number->string (/ (trunc (* scY 100 )) 100)) ")"
        ;   )
        ; )
      )
    )
    (/ (trunc (* 100 0.66565)) 100)
    (list->vector (list globR fileNme scale srcNme scX scY))
  )
)


(define (reduce-group img srcGrp preFxL prxTag sDir saveNme)
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(actL 0)(placehL)(placehLNme "")
      (srcNme (car(gimp-item-get-name srcGrp)))(mde LAYER-MODE-NORMAL)
    )

    ; find children in group before adding placeholder to group
    (set! chldrn (gimp-item-get-children srcGrp))
    (set! lstL (cadr chldrn))

    ; add placeholder
    (set! placehLNme (string-append preFxL saveNme))
    (set! placehL (add-image-size-layer img srcGrp 0 placehLNme mde))
    (gimp-item-set-name srcGrp (string-append prxTag srcNme))

    ; remove group children
    (while (< i (car chldrn))
      (set! actL (vector-ref lstL i))
      (gimp-image-remove-layer img actL)
      (set! i (+ i 1))
    )

    placehL
  )
)


(define (load-layer-info fileNme)
  (let*
    (
      (input 0)(inputLine 0)(inputString "")(inputList ())
      (globR (car(file-glob fileNme 0)))(recD 1)
    )
    (when (equal? () globR)
      (gimp-message (string-append "file missing \n -> " fileNme))
      (set! recD 0)
      (set! inputList (append inputList (list "42")))
      (set! inputList (append inputList (list "42")))
    )

    (if (not (equal? () globR)) (set! globR (car globR)))

    (when (equal? fileNme globR)

      (set! input (open-input-file fileNme))
      (set! inputLine (read input))

      (while (not (eof-object? inputLine))
        (set! inputString (atom->string inputLine))
        ;(gimp-message inputString)
        (set! inputList (append inputList (list inputString)))
        (newline)
        (set! inputLine (read input))
      )
      (close-input-port input)
    )

    (set! inputList (append inputList (list recD)))
    inputList
  )
)


(define (save-layer-info img fileNme)
  (let* 
    (
      (output 0)
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
    )
    (set! output (open-output-file fileNme))
    (display width output)
    (newline output)
    (display height output)
    (close-output-port output)
  )
)


(define (filter-selected img drwbles preFxL)
  (let*
    (
    (drawable (vector-ref drwbles 0))
    (isMsk (car (gimp-item-id-is-layer-mask drawable )))
    )

    ; one item is selected and it's a mask, switch it to the layer
    (if (and (= (vector-length drwbles) 1) (= isMsk 1))
      (vector-set! drwbles 0 (car(gimp-layer-from-mask drawable)))
    )

    (set! drwbles (exclude-children img drwbles))
    (set! drwbles (exclude-parents-of-proxy-children img drwbles preFxL))
    (set! drwbles (only-groups-proxy drwbles preFxL))

    drwbles
  )
)


(define (get-proxy srcGrp preFxL)
  (let*
    (
     (chldrn 0)(name 0)(found 0)
    )
    ; check for src group being a -1 parent
    (when (> srcGrp 0)
      (when (= (car (gimp-item-is-group srcGrp)) 1)
        (set! chldrn (gimp-item-get-children srcGrp))
        (when (> (vector-length (cadr chldrn) ) 0)
          (set! name (car(gimp-item-get-name (vector-ref (cadr chldrn) 0))))
          (set! name (strbreakup name preFxL))
          (when (> (length name) 1)
            (set! name (cadr name))
            (set! found 1)
          )
        )
      )
    )
    found
  )
)


(define (get-proxy-groups img preFxL)
  (let*
    (
      (lstL 0)(numL 0)(actL 0)(prxLst())(i 0)(found 0)
    )

    (set! lstL (all-childrn img 0))
    (set! lstL (list->vector lstL))
    (set! numL (vector-length lstL))

    (while (< i numL)
      (set! actL (vector-ref lstL i))
      (set! found (get-proxy actL preFxL))

      (when (= found 1)
        (set! prxLst (append prxLst (list actL)))
      )
      (set! i (+ i 1))
    )

  (list->vector prxLst)
  )
)


(define (exclude-parents-of-proxy-children img drwbles preFxL)
  (let*
    (
    (i 0)(actL 0)(excLst())(tagLst 0)
    (allChldLst 0)(j 0)(actChl 0)(found 0)
    )

    (set! tagLst (get-proxy-groups img preFxL))
    (set! tagLst (vector->list tagLst))

    (while (< i (vector-length drwbles))
      (set! j 0)
      (set! found 0)
      (set! actL (vector-ref drwbles i))
      (set! allChldLst (all-childrn img actL))

      (while (< j (length allChldLst))
        (set! actChl (nth j allChldLst))
        (when (member actChl tagLst)
          (set! found 1)
          (gimp-message " must not proxy a parent of a proxy ")
        )
        (set! j (+ j 1))
      )

      (if (= found 0)(set! excLst (append excLst (list actL))))
      (set! i (+ i 1))
    )

  (list->vector excLst)

  )
)


(define (close-tagged-group img tag)
  (let*
    (
    (i 0)(tagLst 0)
    )

    (set! tagLst (get-proxy-groups img tag))
    (while (< i (vector-length tagLst))
     (gimp-item-set-expanded (vector-ref tagLst i) 0)
     (set! i (+ i 1))
    )

  )
)


(define (only-groups-proxy drwbles preFxL)
 (let*
    (
    (i 0)(actL 0)(excLst())(parent 0)(allParents 0)
    )

    (while (< i (vector-length drwbles))
      (set! actL (vector-ref drwbles i))
      (set! parent (car(gimp-item-get-parent actL)))
      (when (= (car (gimp-item-is-group actL)) 1)
        (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
          (set! actL (car(gimp-layer-from-mask actL)))
        )
        (set! excLst (append excLst (list actL)))
      )
      (when (and (= (car (gimp-item-is-group actL)) 0)
                 (= (get-proxy parent preFxL) 1))
        ;(gimp-message " proxy layer found in selection")
        (set! excLst (append excLst (list parent)))
      )
      (when (and (= (car (gimp-item-is-group actL)) 0)
                 (= (get-proxy parent preFxL) 0))
        (gimp-message " only groups or proxy layers please ")
      )

      
      (set! i (+ i 1))
    )
    (list->vector excLst)

  )
)


(define (precise-scale-proxy img scaleX scaleY)
  (let*
    (
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (scAdj (percent-to-resolution scaleX scaleY width height))
      (scWdth (car scAdj))(scHght (cadr scAdj))
      (adjLst 0)(lckLst 0)
    )
    ;(gimp-message " * scaling proxy * ")
    ; the image shouldn't alter, math adjustments to layer framing
    (set! lckLst (set-and-store-all-locks img 0 0))
    (set! adjLst (layer-size-adjust img scWdth scHght))

    ; scale with layer sizes and offsets that now avoid pixel rounding movement
    (gimp-image-scale img scWdth scHght)
    ;(set! lckLst (set-and-store-all-locks img 0 0))
    (layer-size-restore adjLst)
    (restore-all-locks lckLst)
    ;(gimp-message " * finished scaling * ")
  )
)


(script-fu-register-filter "script-fu-proxy"
 "Proxy"
 "Replaces the folder contents with a proxy, or restores from disk"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE

)
(script-fu-menu-register "script-fu-proxy" "<Image>/Layer")


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


; filters a list removing stuff that doesn't exist
; returns a filtered list
(define (remove-invalid-items itemsLst)
  (let*
      (
        (actL 0)(validLst ())
        (i 0)
      )

    (if (list? itemsLst) (set! itemsLst (list->vector itemsLst)))

    (while (< i (vector-length itemsLst))
      (set! actL (vector-ref itemsLst i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (set! validLst (append validLst (list actL)))
      )
      (set! i (+ i 1))
    )

    (list->vector validLst)
  )
)


; returns a list of a layers attributes
; (source image, layer id)
(define (store-layer-attributes img actL)
  (let*
    (
      (parent 0)(pos 0)(lckVis 0)(nme "")(mde 0)(opac 0)(col 0)(vis 0)
      (lckPos 0)(lckAlp 0)(lckCnt 0)(id 0)(cmpSpc 0)
    )

    (set! id actL)
    (set! nme (car (gimp-item-get-name actL)))
    (set! parent (car (gimp-item-get-parent actL)))
    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! opac (car (gimp-layer-get-opacity actL)))
    (set! mde (car (gimp-layer-get-mode actL)))
    (set! vis (car(gimp-item-get-visible actL)))
    (set! col (car(gimp-item-get-color-tag actL)))
    (set! lckPos (car(gimp-item-get-lock-position actL)))
    (set! lckAlp (car(gimp-layer-get-lock-alpha actL)))
    (set! lckCnt (car(gimp-item-get-lock-content actL)))
    (set! lckVis (car(gimp-item-get-lock-visibility actL)))
    (set! cmpSpc (car(gimp-layer-get-composite-space actL)))

    (list id nme parent pos opac mde vis col lckPos lckAlp lckCnt lckVis cmpSpc)

  )
)



; sets a layers attributes from a "store-layer-attributes" list
; (layer id, list)
(define (restore-layer-attributes actL actLAttr)
  (let*
    (
    (actLAttr (list->vector actLAttr))
    )

    (gimp-item-set-name actL (vector-ref actLAttr 1))
    (gimp-layer-set-opacity actL (vector-ref actLAttr 4))
    (gimp-layer-set-mode actL (vector-ref actLAttr 5))
    (gimp-item-set-visible actL (vector-ref actLAttr 6))
    (gimp-item-set-color-tag actL (vector-ref actLAttr 7))
    (gimp-item-set-lock-position actL (vector-ref actLAttr 8))
    (gimp-layer-set-lock-alpha actL (vector-ref actLAttr 9))
    (gimp-item-set-lock-content actL (vector-ref actLAttr 10))
    (gimp-item-set-lock-visibility actL (vector-ref actLAttr 11))
    (gimp-layer-set-composite-space actL (vector-ref actLAttr 12))

  )
)


; adds a new RGBA layer to an image, inserts, names and fills with a color
; (img, parent, pos, name, mode, opacity, color (list (0-255)(0-255)(0-255))
; blend modes ...LAYER-MODE-NORMAL LAYER-MODE-MULTIPLY LAYER-MODE-ADDITION...
; returns the new layer id
(define (add-layer img actP pos name mode opa col)
  (let*
    (
      (actL 0)
      (wdth  (car (gimp-image-get-width img)))
      (hght (car (gimp-image-get-height img)))
      (typ RGBA-IMAGE)
    )

    (set! actL (car (gimp-layer-new img wdth hght typ name opa mode)))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    (gimp-image-insert-layer img actL actP pos)
    (gimp-context-push)
    (gimp-context-set-opacity 100)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
    (gimp-context-set-foreground col)
    (gimp-drawable-fill actL 0)
    (gimp-context-pop)

    actL
  )
)


; returns #t or #f if parasite is on a specified image
; (image id, parasite name)
(define (get-image-parasite img paraNme)
  (let*
    (
      (i 0)(actP 0)(fnd #f)
      (para (list->vector (car(gimp-image-get-parasite-list img))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fnd #t)
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fnd
  )
)


; reorder a single layer or group in the layer stack
; bug workaround, can't reorder item to root 0
; (source image, layer/group, new parent, new position)
; returns the item id
(define (reorder-item img actL parent pos)
  (let*
    (
      (buffL 0)(nme (car (gimp-item-get-name actL)))
    )
      
      (if (> parent 0)(gimp-image-reorder-item img actL parent pos))
      (gimp-selection-none img)
      ; bug workaround, can't reorder to root, remove and insert a copy at pos
      (when (= parent 0)
        (when (= (car (gimp-item-is-group actL)) 0)
          (set! buffL (car(gimp-layer-copy actL 0)))
          (gimp-image-remove-layer img actL)
          (gimp-image-insert-layer img buffL 0 pos)
          (gimp-item-set-name buffL nme)
          (set! actL buffL)
        )
        (when (= (car (gimp-item-is-group actL)) 1)
          (root-group img (vector actL))
        )
      )

    actL
  )
)


; adds a new layer the same size as the image
; image, parent layer or group, position in tree, name, blend mode
(define (add-image-size-layer img parent pos name mode)
 (let*
    (
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (actL 0)
    )

    (set! actL (car (gimp-layer-new img
                                    width
                                    height
                                    RGBA-IMAGE
                                    name
                                    100
                                    mode
                       )
                  )
    )

    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

  actL
  )
)



; copies a mask to a mask, or layer to a mask
; (source image, src mask/layer, destination image, dst mask)
; returns the destination mask id
(define (transfer-mask-to-mask srcImg srcM dstImg dstM)
  (let*
    (
      (srcL 0)
      (offX 0)
      (offY 0)
    )

    (if (= (car (gimp-item-id-is-layer-mask srcM)) 1)
      (set! srcL (car(gimp-layer-from-mask srcM)))
        (set! srcL srcM)
    )

    (set! offX (car(gimp-drawable-get-offsets srcL )))
    (set! offY (cadr(gimp-drawable-get-offsets srcL )))

    (gimp-selection-none srcImg)
    (gimp-edit-copy 1 (vector srcM))
    (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0 ))
    (gimp-layer-set-offsets dstM offX offY)
    (gimp-floating-sel-anchor dstM)

    (set! dstM (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! dstM (car(gimp-layer-get-mask dstM)))

    dstM
  )
)


; finds only the groups and not the layers in all the image or inside a group
; (source image, source group/all image) set last parameter to 0 for all image
; returns a list of all the groups found including the given group
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


; also used by (get-all-groups)
; finds only the groups and not the layers in all the image or inside a group
; (source image, source group/all image) set last parameter to 0 for all image
; returns a list of all the groups found not including the given group
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


; sets a layers locks
; (layer id, lock content, lock position, lock visibility, lock alpha)
(define (set-lock-layer actL lckCon lckPos lckVis lckAlp)
  (gimp-item-set-lock-content actL lckCon)
  (gimp-item-set-lock-position actL lckPos)
  (gimp-item-set-lock-visibility actL lckVis)
  (gimp-layer-set-lock-alpha actL lckAlp)
)


; finds only the layers and not the groups in all the image or inside a group
; (source image, source group/all image) set last parameter to 0 for all image
; returns a list of all the layers found
(define (get-layers img actL) ; recursive function
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(allL ())
    )

    (if (= actL 0)
      (set! chldrn (gimp-image-get-layers img))
      (if (equal? (car (gimp-item-is-group actL)) 1)
        (set! chldrn (gimp-item-get-children actL))
        (set! chldrn (list 1 (list->vector (list actL))))
      )
    )

    (set! lstL (cadr chldrn))
    (while (< i (car chldrn))
      (set! actL (vector-ref lstL i))
      (when (equal? (car (gimp-item-is-group actL)) 0)
        (set! allL (append allL (list actL)))
      )
      (when (equal? (car (gimp-item-is-group actL)) 1)
        (set! allL (append allL (get-layers img actL)))
      )
      (set! i (+ i 1))
    )

    allL
  )
)


; sets a layers locks
; (layer id, lock content, lock position, lock visibility, lock alpha)
(define (set-lock-layer actL lckCon lckPos lckVis lckAlp)
  (gimp-item-set-lock-content actL lckCon)
  (gimp-item-set-lock-position actL lckPos)
  (gimp-item-set-lock-visibility actL lckVis)
  (gimp-layer-set-lock-alpha actL lckAlp)
)


; create a new image from a given group
(define (group-to-new-image img srcGrp)
  (let*
    (
      (dstImg 0)(allPrnts 0)(tone (list 128 128 128))(actL 0)(dstNme "")
      (treeL 0)(buffL 0)
    )
    (gimp-context-push)
    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcGrp))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! dstNme (car(gimp-item-get-name actL)))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    (set! allPrnts (get-all-parents dstImg actL))
    ;(gimp-display-new dstImg)

    ; layers copied in groups bring across parent groups, trim them out.
    ; can't make a layer a child of root directly, have to copy and insert
    (when (> (length allPrnts) 0)
      (set! buffL (car(gimp-layer-copy actL 0)))
      (gimp-image-remove-layer dstImg actL)
      (set! treeL (vector-ref (cadr (gimp-image-get-layers dstImg))0))
      (gimp-image-insert-layer dstImg buffL 0 0)
      (set! actL buffL)
      (gimp-image-remove-layer dstImg treeL)
      (gimp-item-set-name actL dstNme)
      
    )

    (gimp-context-pop)
    (list dstImg actL (car(gimp-layer-get-mask actL)))
  )
)


; restores layer and lock states stored in a list
(define (restore-all-locks lckLst)
  (let*
    (
      (actL 0)(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)(i 0)(exst 0)
    )

    (if (list? lckLst) (set! lckLst (list->vector lckLst)))
    (while (< i (vector-length lckLst))
      (set! actL (vector-ref lckLst i))
      (set! exst (car (gimp-item-id-is-valid actL)))
      (when (= exst 1)
        (gimp-item-set-lock-content actL (vector-ref lckLst (+ i 1)))
        (gimp-item-set-lock-position actL (vector-ref lckLst (+ i 2)))
        (gimp-item-set-lock-visibility actL (vector-ref lckLst (+ i 3)))
        (gimp-layer-set-lock-alpha actL (vector-ref lckLst (+ i 4)))
      )
      (set! i (+ i 5))
    )

  )
)


; creates a list of layers and their locks and then sets all the locks on/off
; (source image, group/0, lock value 0/1 ) set group to zero for all layers
; returns a list of what the layers locks used to be
(define (set-and-store-all-locks img rootGrp lock)
  (let*
    (
      (i 0)(lstL ())(actL 0)(lckLst())(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)
    )

    (set! lstL (all-childrn img rootGrp))
    (set! lstL (list->vector lstL))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! lckPos (car(gimp-item-get-lock-position actL)))
      (set! lckAlp (car(gimp-layer-get-lock-alpha actL)))
      (set! lckCnt (car(gimp-item-get-lock-content actL)))
      (set! lckVis (car(gimp-item-get-lock-visibility actL)))
      (set! lckLst (append lckLst (list actL lckCnt lckPos lckVis lckAlp)))
      (gimp-item-set-lock-content actL lock)
      (gimp-item-set-lock-position actL lock)
      (gimp-item-set-lock-visibility actL lock)
      (gimp-layer-set-lock-alpha actL lock)
      (set! i (+ i 1))
    )

    ; also set and store the root group locks
    (when (> rootGrp 0)
      (set! lckPos (car(gimp-item-get-lock-position rootGrp)))
      (set! lckAlp (car(gimp-layer-get-lock-alpha rootGrp)))
      (set! lckCnt (car(gimp-item-get-lock-content rootGrp)))
      (set! lckVis (car(gimp-item-get-lock-visibility rootGrp)))
      (set! lckLst (append lckLst (list rootGrp lckCnt lckPos lckVis lckAlp)))
      (gimp-item-set-lock-content rootGrp lock)
      (gimp-item-set-lock-position rootGrp lock)
      (gimp-item-set-lock-visibility rootGrp lock)
      (gimp-layer-set-lock-alpha rootGrp lock)
    )

    lckLst
  )
)


; paste buffer to a destination layer, set opacity mode and visibility
(define (paste-copied-layer img dstL opacity mode vis)
  (let*
    (
      (actL 0)(mask 0)
    )

    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (set! mask (car (gimp-item-id-is-layer-mask actL)))
    (if (= mask 1)(set! actL (car (gimp-layer-from-mask actL))))
    (gimp-layer-set-opacity actL opacity)
    (gimp-layer-set-mode actL mode)
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
    (gimp-item-set-visible actL vis)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
      (set! actL (car(gimp-layer-from-mask actL)))
    )

    actL
  )
)



; makes a directory in the "home" directory with a string "/path/like/this"
; in WindowsOS relative to "C:\Users\username"  keep using "/" to denote path
(define (make-dir-path path)
   (let*
    (
      (brkP 0)(i 2)(pDepth 0)(dirMake "")
    )

    (set! brkP (strbreakup path "/"))
    (set! pDepth  (length brkP))
    (set! dirMake (list-ref brkP 1)) ; skip empty element
    (dir-make dirMake) ; make root

    (while (< i pDepth)
      (set! dirMake (string-append dirMake "/" (list-ref brkP i)))     
      (set! i (+ i 1))
      (dir-make dirMake) ; make tree
    )

  )
)


; finds the full file name, base name, stripped name, and path of a given image
; returns a vector list ("/here/myfile.xcf" "myfile.xcf" "myfile" "/here")
(define (get-image-file-info img)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(usr "")(strL "")
      (brkTok DIR-SEPARATOR)
    )

    (if (equal? "/" brkTok)(set! usr(getenv"HOME"))(set! usr(getenv"HOMEPATH")))

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fNme (car(gimp-image-get-file img)))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth (reverse (cdr(reverse (strbreakup fNme brkTok)))))
        (set! fPth (unbreakupstr fPth brkTok))
      )

      (when (equal? (car(gimp-image-get-file img)) "")
        (set! fNme (string-append usr brkTok "Untitled.xcf"))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth usr)
      )
    )

    (vector fNme fBse fwEx fPth)
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



; finds the full file name, base name, stripped name, and path of a given image
; returns a vector list ("/here/myfile.xcf" "myfile.xcf" "myfile" "/here")
(define (get-image-file-info img)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(usr "")(strL "")
      (brkTok DIR-SEPARATOR)
    )

    (if (equal? "/" brkTok)(set! usr(getenv"HOME"))(set! usr(getenv"HOMEPATH")))

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fNme (car(gimp-image-get-file img)))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth (reverse (cdr(reverse (strbreakup fNme brkTok)))))
        (set! fPth (unbreakupstr fPth brkTok))
      )

      (when (equal? (car(gimp-image-get-file img)) "")
        (set! fNme (string-append usr brkTok "Untitled.xcf"))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth usr)
      )
    )

    (vector fNme fBse fwEx fPth)
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


; collapses a list of groups
(define (close-groups grpLst)
  (let*
    (
      (i 0)(actG 0)
    )

    (while (< i (vector-length grpLst))
     (set! actG (vector-ref grpLst i))
     (if (> (car (gimp-item-is-group actG)) 0) (gimp-item-set-expanded actG 0))
     (set! i (+ i 1))
    )

  )
)


; sets a layers locks to the values found in a given list
(define (restore-layer-locks actL lckLst)
  (let*
    (
      (lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)
    )

    (set! lckLst (list->vector lckLst))
    (if (= actL 0)(set! actL (vector-ref lckLst 0)))
    (gimp-item-set-lock-content actL (vector-ref lckLst 1))
    (gimp-item-set-lock-position actL (vector-ref lckLst 2))
    (gimp-item-set-lock-visibility actL (vector-ref lckLst 3))
    (gimp-layer-set-lock-alpha actL (vector-ref lckLst 4))

  )
)


; sets a layers locks and returns a list of what they were before the set
; (layer id, lock value)
(define (set-and-store-layer-locks actL lock)
  (let*
    (
      (lckLst())(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)
    )

    (set! lckPos (car(gimp-item-get-lock-position actL)))
    (set! lckAlp (car(gimp-layer-get-lock-alpha actL)))
    (set! lckCnt (car(gimp-item-get-lock-content actL)))
    (set! lckVis (car(gimp-item-get-lock-visibility actL)))
    (set! lckLst (append lckLst (list actL lckCnt lckPos lckVis lckAlp)))
    (gimp-item-set-lock-content actL lock)
    (gimp-item-set-lock-position actL lock)
    (gimp-item-set-lock-visibility actL lock)
    (gimp-layer-set-lock-alpha actL lock)

    lckLst
  )
)


; calculation useful to layer size scaling
(define (find-nearest-multiple message n multiplier dir)
  (let*
    (
      (q (/ 1 multiplier))
      (p (/ n q))
      (r (ceiling p))
      (f (- r p ))
      (initN n)
      (tol 0.01)
      (buffer 32)
    )

    ;intuitive fix
    (set! dir (* -1 dir))

    ; give a bit of border padding, start searching after buffer
    (if (> dir 0)(set! n (- n buffer)))

    (while (> (abs f) tol)
      (set! n (- n dir))
      (set! q (/ 1 multiplier))
      (set! p (/ n q))
      (set! r (ceiling p))
      (set! f (- r p ))
      (when debug
        (gimp-message 
          (string-append message
                          " : number -> " (number->string n)
                          "\n : fraction -> " (number->string f)
          )
        )
      )
    )

    (when debug
      (gimp-message 
        (string-append message
                        ": start number -> " (number->string initN)
                        "\n multipler -> " (number->string multiplier)
                        "\n\n * nearest found multiple -> " (number->string n)
                        "\n q : (inverse scale) -> " (number->string q)
                        "\n p : (search number / q) -> " (number->string p)
                        "\n r : (ceiling of p) -> " (number->string r)
                        "\n f : (r - p), 0 is the target -> " (number->string f)
                        "\n tolerance factor -> " (number->string tol)
                        "\n search direction -> " (number->string (* -1 dir))
        )
      )
    )

    n
  )
)



; trims the given string to a new character length and returns it
(define (short-layer-name actL length)
  (let*
    (
      (actNme "")
    )
    (set! actNme (car (gimp-item-get-name actL)))
    (when (> (string-length actNme) length)
      (set! actNme (substring actNme 0 length))
      (set! actNme (string-append actNme "..."))
    )
    actNme
  )
)


; removes a list of layers from an image
; (source image, list of layers)
(define (remove-layers img lstL)
  (let*
    (
      (i 0)(actL 0)
    )

    (if (list? lstL)(set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (if (= (car (gimp-item-id-is-valid actL)) 1)
        (gimp-image-remove-layer img actL)
      )
      (set! i (+ i 1))
    )

  )
)


; when the source branch matches dst branch, it's possible to transfer locks
; (source image, destination group, list of locks)
(define (transfer-all-locks img dstGrp lckLst)
  (let*
    (
      (actL 0)(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)(i 0)(exst 0)(lstL 0)
      (j 0)
    )
    (set! lstL (all-childrn img dstGrp))
    (set! lstL (list->vector lstL))

    (set! lckLst (list->vector lckLst))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
        (gimp-item-set-lock-content actL (vector-ref lckLst (+ j 1)))
        (gimp-item-set-lock-position actL (vector-ref lckLst (+ j 2)))
        (gimp-item-set-lock-visibility actL (vector-ref lckLst (+ j 3)))
        (gimp-layer-set-lock-alpha actL (vector-ref lckLst (+ j 4)))
      (set! i (+ i 1))
      (set! j (+ j 5))
    )

    (gimp-item-set-lock-content dstGrp (vector-ref lckLst (+ j 1)))
    (gimp-item-set-lock-position dstGrp (vector-ref lckLst (+ j 2)))
    (gimp-item-set-lock-visibility dstGrp (vector-ref lckLst (+ j 3)))
    (gimp-layer-set-lock-alpha dstGrp (vector-ref lckLst (+ j 4)))

  )
)



; given a 1-100 scale, and the current dimensions, it returns the new size
; (1-100, 1-100, current width, current height)
(define (percent-to-resolution scaleX scaleY width height)
  (let*
    (
      (scaleX (/ scaleX 100.0))
      (scaleY (/ scaleY 100.0))
      (width (round (* width scaleX)))
      (height (round (* height scaleY)))
    )

    (list width height)
  )
)



; stores all the locks of all the layers in a list and returns that list
(define (store-all-locks img rootGrp)
  (let*
    (
      (i 0)(lstL ())(actL 0)(lckLst())(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)
    )

    (set! lstL (all-childrn img rootGrp))
    (set! lstL (list->vector lstL))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! lckPos (car(gimp-item-get-lock-position actL)))
      (set! lckAlp (car(gimp-layer-get-lock-alpha actL)))
      (set! lckCnt (car(gimp-item-get-lock-content actL)))
      (set! lckVis (car(gimp-item-get-lock-visibility actL)))
      (set! lckLst (append lckLst (list actL lckCnt lckPos lckVis lckAlp)))

      (set! i (+ i 1))
    )

    ; also set and store the root group locks
    (when (> rootGrp 0)
      (set! lckPos (car(gimp-item-get-lock-position rootGrp)))
      (set! lckAlp (car(gimp-layer-get-lock-alpha rootGrp)))
      (set! lckCnt (car(gimp-item-get-lock-content rootGrp)))
      (set! lckVis (car(gimp-item-get-lock-visibility rootGrp)))
      (set! lckLst (append lckLst (list rootGrp lckCnt lckPos lckVis lckAlp)))
    )

    lckLst
  )
)



; copies a layer stack branch to another image. Uses 'layer-to-image.scm'
; (source image, source group, dest image, destination parent)
(define (group-to-image srcImg actG dstImg parent) ; recursive
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(actL 0)(actGMsk 0)(folder 0)(dstM 0)(chldC 0)
      (rtnL 0)(pos 0)
    )

    (set! actGMsk (car (gimp-layer-get-mask actG)))

    ; create a destination copy of the layer or group
    (set! rtnL (layer-to-image srcImg actG dstImg parent pos))

    (set! dstM (car(gimp-layer-get-mask rtnL)))
    (set! chldrn (gimp-item-get-children actG))
    (set! lstL (list->vector (reverse (vector->list (cadr chldrn)))))
    (set! chldC (car chldrn))

    ; repeat for any children, recursively
    (while (< i chldC)
      (set! actL (vector-ref lstL i))

      (if (equal? (car (gimp-item-is-group actL)) 1)
        (group-to-image srcImg actL dstImg rtnL)
          (layer-to-image srcImg actL dstImg rtnL pos)
      )

      ; last child of group, then update the group mask
      (when (= i (- chldC 1))
        (if (> actGMsk 0) (transfer-mask-to-mask srcImg actGMsk dstImg dstM))
      )
      (set! i (+ i 1))
    )

    ; set the active layer to the last created group
    (gimp-image-set-selected-layers dstImg 1 (vector rtnL))

  )
)


; copies a layer to another image, attributes included
; (source image, source layer, dst image, dst parent, dst position)
; returns the new layer id
(define (layer-to-image srcImg srcL dstImg prnt pos)
  (let*
    (
      (wdth (car(gimp-drawable-get-width srcL)))
      (hght (car(gimp-drawable-get-height srcL)))
      (offX (car (gimp-drawable-get-offsets srcL)))
      (offY (cadr (gimp-drawable-get-offsets srcL)))(unlock 0)
      (dstL 0)(actLAttr 0)(actL 0)(paraStr 0)(srcM 0)(dstM 0)(grp 0)(lckLst 0)
    )

    (set! actLAttr (store-layer-attributes srcImg srcL))
    (set! paraStr (store-layer-parasites srcL))

    (when(> (car (gimp-layer-get-mask srcL)) 0)
      (set! srcM (car (gimp-layer-get-mask srcL)))
    )

   ; if its a layer, create a destination, then copy it across
    (when (equal? (car (gimp-item-is-group srcL)) 0)
      (set! dstL (car (gimp-layer-new dstImg
                                      wdth
                                      hght
                                      RGBA-IMAGE
                                      "tmp"
                                      100
                                      LAYER-MODE-NORMAL
                        )
                  )
      )

      (gimp-image-insert-layer dstImg dstL prnt pos)
      (gimp-edit-copy 1 (vector srcL))
      (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0))
      (gimp-floating-sel-to-layer actL)
      (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
      (set-lock-layer actL unlock unlock unlock unlock)
      (gimp-layer-set-offsets actL offX offY)
      (gimp-image-remove-layer dstImg dstL)
    )

    ; if it's a group, insert a new group in the destination image
    (when (equal? (car (gimp-item-is-group srcL)) TRUE)
      (set! actL (car (gimp-layer-group-new dstImg)))
      (gimp-image-insert-layer dstImg actL prnt 0)
      (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
      (gimp-layer-set-offsets actL offX offY)
      (set! grp 1)
    )

    ; if it exists, create and copy over a mask to the new layer
    (when (and (> srcM 0) (= grp 1))
      (set! dstM (car(gimp-layer-create-mask actL 0)))
      (gimp-layer-add-mask actL dstM)
      (gimp-edit-copy 1 (vector srcM))
      (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0))
      (gimp-floating-sel-anchor dstM)
    )

    (restore-layer-attributes actL actLAttr)
    (set-lock-layer actL unlock unlock unlock unlock)
    (restore-layer-parasites actL paraStr)


    actL
  )
)


; attachs a list of parasites to a layer
(define (restore-layer-parasites actL paraStrLst)
  (let*
    (
      (paraVal 0)(i 0)(actP 0)(paraName "")
    )
    
    (while (< i (length paraStrLst))
      (set! paraName (vector-ref (list->vector paraStrLst) i))
      (set! paraVal (vector-ref (list->vector paraStrLst) (+ i 2)))
      (gimp-item-attach-parasite actL (list paraName 3 paraVal))
      (set! i (+ i 3))
    )

  )
)


; returns a list of lists of all the parasites on a layer
(define (store-layer-parasites actL)
  (let*
    (
    (paraLst 0)(parasite 0)(paraStrLst ())(i 0)(actP 0)
    )
    
    (set! paraLst (car (gimp-item-get-parasite-list actL)))
    
    (when (> (length paraLst) 0)
      (while(< i (length paraLst))
        (set! actP (vector-ref (list->vector paraLst) i))
        (set! parasite (car(gimp-item-get-parasite actL actP)))
        (set! paraStrLst (append paraStrLst parasite))
        (set! i (+ i 1))
      )
    )

    paraStrLst
  )
)



; prints a progress message (current amount, maximum amount, prefix "message")
(define (message-progress currAmt maxAmt message)
  (let*
    (
      (prg 0)
    )

    (set! prg (* (/ 1 maxAmt) (+ currAmt 1)))
    (set! prg (trunc (floor (* prg 100))))
    (set! message (string-append " >>> " message " > "(number->string prg) "%"))
    (gimp-message-set-handler 0)
    (gimp-message message)
    (gimp-message-set-handler 2)

  )
)


; part of precise scaling
(define (layer-reframe img actL xScP yScP scX scY)
  (let*
    (
      (parent (car (gimp-item-get-parent actL)))(unlock 0)(lckLst 0)
      (pos (car (gimp-image-get-item-position img actL)))
      (dstL 0)(paraStrLst 0)(buffer 32)(adjWdth 0)(adjHght 0)(actLAttr 0)
      (wdthL (car (gimp-drawable-get-width actL)))
      (hghtL (car (gimp-drawable-get-height actL)))
      (offX (car(gimp-drawable-get-offsets actL)))
      (offY (cadr(gimp-drawable-get-offsets actL)))
    )

    (set! lckLst (set-and-store-layer-locks actL unlock))

    ; reframe layer size to scale precisely at a given scale
    (set! adjWdth (+ buffer (+ wdthL (abs (- offX xScP)))))
    (set! adjHght (+ buffer (+ hghtL (abs (- offY yScP)))))
    (set! adjWdth (find-nearest-multiple " width " adjWdth scX 1))
    (set! adjHght (find-nearest-multiple " height " adjHght scY 1))

    (when debug
      (gimp-message
        (string-append
          " increasing layer size -> (" (number->string adjWdth) ", "
                                        (number->string adjHght) ")"
          "\n original layer size -> (" (number->string wdthL) ", "
                                        (number->string hghtL) ")"
        )
      )
    )

    ; add an alpha and then resize the layer to new size and offsets
    (if (= (car(gimp-drawable-has-alpha actL)) 0)(gimp-layer-add-alpha actL))
    (gimp-layer-resize actL adjWdth adjHght (- offX xScP) (- offY yScP))

    (restore-layer-locks actL lckLst)

    actL
  )
)



; part of precise scaling
(define (group-mask-protect img)
  (let*
    (
      (grpLst 0)(i 0)(grpWidth 0)(grpHeight 0)(grpMskFxL 0)(actG 0)(fixLst ())
      (offX 0)(offY)
    )

    (set! grpLst (get-all-groups img 0))
    (set! grpLst (list->vector grpLst))
    (while (< i (vector-length grpLst))
      (set! actG (vector-ref grpLst i))

      ; add a new layer to protect the mask
      (when (> (car (gimp-layer-get-mask actG)) 0)
        (set! offX (car(gimp-drawable-get-offsets actG)))
        (set! offY (cadr(gimp-drawable-get-offsets actG)))
        (set! grpWidth (car (gimp-drawable-get-width actG)))
        (set! grpHeight (car (gimp-drawable-get-height actG)))
        (set! grpMskFxL (car (gimp-layer-new img grpWidth 
                                                grpHeight
                                                RGBA-IMAGE 
                                                "groupMaskFix"
                                                0
                                                LAYER-MODE-NORMAL
                                )
                        )
        )

        (gimp-image-insert-layer img grpMskFxL actG 0)
        (gimp-layer-set-offsets grpMskFxL offX offY)
        (set! fixLst (append fixLst (list grpMskFxL)))
      )

      (set! i (+ i 1))
    )

    fixLst
  )
)


; part of precise scaling
(define (layer-size-restore adjLst)
  (let*
    (
      (actNme 0)(i 0)(offX 0)(offY 0)(actL 0)(xScP 0)(yScP 0)(skip 0)(fixLst ())
      (wdthL 0)(hghtL 0)(offYPos #t)(offXPos #t)(actNme "")
      (adjOffX 0)(adjOffY 0)(scX 0)(scY 0)(buffer 8)
    )

    (set! adjLst (list->vector adjLst))
    (while (< i (vector-length adjLst))
      (message-progress i (vector-length adjLst) "completion progress")
      (set! actL (vector-ref adjLst (+ i 0)))
      (set! wdthL (vector-ref adjLst (+ i 1)))
      (set! hghtL (vector-ref adjLst (+ i 2)))
      (set! offX (vector-ref adjLst (+ i 3)))
      (set! offY (vector-ref adjLst (+ i 4)))
      (set! scX (vector-ref adjLst (+ i 5)))
      (set! scY (vector-ref adjLst (+ i 6)))
      (set! actNme (short-layer-name actL 10))

      (set! adjOffX (car(gimp-drawable-get-offsets actL)))
      (set! adjOffY (cadr(gimp-drawable-get-offsets actL)))

      ; scaled sizes with an additional buffer
      (set! wdthL (ceiling (* wdthL scX)))
      (set! hghtL (ceiling (* hghtL scY)))
      (set! wdthL (+ wdthL buffer))
      (set! hghtL (+ hghtL buffer))

      ; scaled offsets with an additional buffer
      (set! offX (ceiling (* offX scX)))
      (set! offY (ceiling (* offY scY)))
      (set! offX (- offX (/ buffer 2)))
      (set! offY (- offY (/ buffer 2)))

      ; old - new offsets
      (set! adjOffX (- adjOffX offX))
      (set! adjOffY (- adjOffY offY))

      (when debug
        (gimp-message
          (string-append
          " cropping layer -> " actNme
          "\n scX scY -> " (number->string scX)
          ", " (number->string scY)
          "\n wdthL hghtL -> " (number->string wdthL)
          ", " (number->string hghtL)
          "\n adjOffX adjOffY -> " (number->string adjOffX)
          ", " (number->string adjOffY)
          )
        )
      )

      (gimp-layer-resize actL wdthL hghtL adjOffX adjOffY)
      (set! i (+ i 7))
    )

  )
)



; part of precise scaling
(define (layer-size-adjust img dstWdth dstHght)
  (let*
    (
      (allL 0)(i 0)(offX 0)(offY 0)(actL 0)(xScP 0)(yScP 0)(skip 0)(fixLst ())
      (wdthL 0)(hghtL 0)(offYPos #t)(offXPos #t)(actNme "")(adjLst ())(adjL 0)
      (srcWdth (car (gimp-image-get-width img)))(all 0)
      (srcHght (car (gimp-image-get-height img)))
      (scX (/ dstWdth srcWdth))
      (scY (/ dstHght srcHght))
    )

    (set! allL (get-layers img all))
    (set! fixLst (group-mask-protect img)) ; protect group masks from deletion

    ; scale any layers that are not groups
    (set! allL (list->vector allL))
    (while (< i (vector-length allL))
      (message-progress i (vector-length allL) "precise scale progress")
      (set! actL (vector-ref allL i))
      (set! skip 0)
      (set! actNme (short-layer-name actL 10))
      (set! offXPos #t)
      (set! offYPos #t)
      (if debug (gimp-message (string-append " adjusting layer -> " actNme)))

      ; get layer sizes and offsets
      (set! wdthL (car (gimp-drawable-get-width actL)))
      (set! hghtL (car (gimp-drawable-get-height actL)))
      (set! offX (car(gimp-drawable-get-offsets actL)))
      (set! offY (cadr(gimp-drawable-get-offsets actL)))
      
      (if (< offX 0) (set! offXPos #f))
      (if (< offY 0) (set! offYPos #f))

      ; find a new local origin for the layer that is a close multiple
      ; of the scale applied, offsets are then scaled close to integer values
      (set! xScP (find-nearest-multiple " xScP " (abs offX) scX -1))
      (if (> xScP 0)(if (not offXPos) (set! xScP(* -1 xScP))))

      (set! yScP (find-nearest-multiple " yScP " (abs offY) scY -1))
      (if (> yScP 0)(if (not offYPos)(set! yScP (* -1 yScP))))

      (when debug
        (gimp-message
          (string-append
          " adjusting layer -> " actNme
          "\n scX scY -> " (number->string scX)
          ", " (number->string scY)
          "\n wdthL hghtL -> " (number->string wdthL)
          ", " (number->string hghtL)
          "\n offX offY -> " (number->string offX)
          ", " (number->string offY)
          "\n xOrig yScP -> (" (number->string xScP)
          ", " (number->string yScP) ")"
          )
        )
      )

      ; this layers size and offsets make it the same as the image, skip it
      (when (and (= srcWdth wdthL) (= srcHght hghtL))
        (when (and (= offX 0) (= offY 0))
          (if debug (gimp-message "skip layer, matches image size and position"))
          (set! skip 1)
        )
      )

      ; reframe the layer by merging to a new layer with friendly dimensions
      (when (= skip 0)
        (set! adjL (layer-reframe img actL xScP yScP scX scY))

        (set! adjLst (append adjLst (list adjL wdthL hghtL offX offY scX scY)))
      )

      (if debug (gimp-message (string-append " adjusted layer -> " actNme)))
      (set! i (+ i 1))
    )

    (if (> (length fixLst) 0)(remove-layers img fixLst))

    adjLst
  )
)

