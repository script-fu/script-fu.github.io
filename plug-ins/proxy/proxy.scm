#!/usr/bin/env gimp-script-fu-interpreter-3.0
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

    (when (= (plugin-get-lock "proxy") 0)(plugin-set-lock "proxy" 1)

      (gimp-context-push)
      (gimp-image-undo-group-start img)
      (gimp-context-set-interpolation mode)
      (gimp-selection-none img) 
      (gimp-image-freeze-layers img)
      (gimp-progress-init "proxy process" -1)

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


(define (store-layer-attributes img actL)
  (let*
    (
      (parent 0)(pos 0)(lckVis 0)(nme "")(mde 0)(opac 0)(col 0)(vis 0)
      (lckPos 0)(lckAlp 0)(lckCnt 0)(id 0)
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

    (list id nme parent pos opac mde vis col lckPos lckAlp lckCnt lckVis)

  )
)


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

  )
)


(define (store-group-in-file img srcGrp preFxL prxTag sDir sveInfo)
  (let*
    (
    (brkTok "/")(selDraw 0)(fileInfo (get-file-info img))(saveNme "")
    (grpNme (car(gimp-item-get-name srcGrp)))
    (srcNme (string-append grpNme ".xcf" ))
    (fPth (vector-ref fileInfo 3))(fNoExt (vector-ref fileInfo 2))
    (prxD (string-append fNoExt sDir))(prxImg 0)
    (dirPth (string-append "/" fPth "/" fNoExt sDir "/" grpNme))(winPth "")
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS
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
      (prxL 0)(prxLMsk 0)(actL 0)
      (wdthL (car (gimp-drawable-get-width srcGrp)))
      (hghtL (car (gimp-drawable-get-height srcGrp)))
      (offX (car(gimp-drawable-get-offsets srcGrp)))
      (offY (cadr(gimp-drawable-get-offsets srcGrp)))
    )

    (set! prxInfo (group-to-new-image img srcGrp))
    (set! prxImg (car prxInfo))
    (set! prxL (cadr prxInfo))
    (set! prxLMsk (caddr prxInfo))

    ; take a copy visible to act as a proxy, but turn off folder mask first
    (set! mskOn (car (gimp-layer-get-apply-mask prxL)))
    (if (> prxLMsk 0) (gimp-layer-set-apply-mask prxL 0))
    (gimp-selection-none prxImg)
    (gimp-edit-copy-visible prxImg)
    (if (> prxLMsk 0) (gimp-layer-set-apply-mask prxL mskOn))

    ; unlock everything and place the proxy in the src group folder
    (set! lckLst (set-and-store-all-locks img allLcks unlock))
    (set! placehL (reduce-group img srcGrp preFxL prxTag sDir saveNme))
    (set! actL (paste-copied-layer img placehL 100 LAYER-MODE-NORMAL 1))
    ;crop to extent of original group
    (gimp-layer-resize actL wdthL hghtL (- 0 offX) (- 0 offY))
    (restore-all-locks lckLst)
    (set-lock-layer placehL 1 1 1 1)
    (gimp-item-set-color-tag srcGrp 2)

    prxImg
  )
)


(define (reorder-item img actL parent pos)
  (let*
    (
      (buffL 0)
    )

      (if (> parent 0)(gimp-image-reorder-item img actL parent pos))

      ; bug workaround, can't reorder to root, remove and insert a copy at pos
      (when (< parent 0)
        (set! buffL (car(gimp-layer-copy actL 0)))
        (gimp-image-remove-layer img actL)
        (gimp-image-insert-layer img buffL 0 pos)
        (set! actL buffL)
      )

    actL
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
        (precise-scale prxImg (* scX 100) (* scY 100))
        ;(gimp-display-new prxImg)
      )

      (set! prxSrcGrp (vector-ref (cadr (gimp-image-get-layers prxImg))0))
      (gimp-item-set-visible prxSrcGrp 0)

      ; add the loaded proxy group as a new group in the image
      (set! lckLst (store-all-locks prxImg prxSrcGrp))

      (group-to-image prxSrcGrp prxImg img 0)

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
      (infoFNme)(brkTok "/")(fileBase "")(fNoExt "")
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (recD 0)(scX 1)(scY 1)
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS
    
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
      (srcNme (car(gimp-item-get-name srcGrp)))(mode LAYER-MODE-NORMAL)
    )


    ; find children in group before adding placeholder to group
    (set! chldrn (gimp-item-get-children srcGrp))
    (set! lstL (cadr chldrn))

    ; add placeholder
    (set! placehLNme (string-append preFxL saveNme))
    (set! placehL (add-image-size-layer img srcGrp 0 placehLNme mode))
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

  actL
  )
)


(define (transfer-mask-to-mask srcImg srcM dstImg dstM)
  (let*
    (
      (srcL (car(gimp-layer-from-mask srcM)))
      (offX (car(gimp-drawable-get-offsets srcL )))
      (offY (cadr(gimp-drawable-get-offsets srcL )))
      (grpTru 0)
    )

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
      (chldrn 0)(lstL 0)(i 0)(allL ())(allGrp ())
      (grpTru 0)(actC 0)
    )

    (if (> actL 0)(set! grpTru (car (gimp-item-is-group actL))))
    (if (= grpTru 1)(set! chldrn (gimp-item-get-children actL)))
    (if (= actL 0)(set! chldrn (gimp-image-get-layers img)))

    (when (= grpTru 1)
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


(define (set-lock-layer actL lckCon lckPos lckVis lckAlp)
  (gimp-item-set-lock-content actL lckCon)
  (gimp-item-set-lock-position actL lckPos)
  (gimp-item-set-lock-visibility actL lckVis)
  (gimp-layer-set-lock-alpha actL lckAlp)
)


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
    (set! drwbles (only-groups drwbles preFxL))
    drwbles
  )
)


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


(define (restore-all-locks lckLst)
  (let*
    (
      (actL 0)(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)(i 0)(exst 0)
    )

    (set! lckLst (list->vector lckLst))
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
    (gimp-item-set-visible actL vis)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
      (set! actL (car(gimp-layer-from-mask actL)))
    )

    actL
  )
)


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


(define (get-file-info img)
  (let*
    (
      (fileInfo (vector "" "" "" ""))
      (fileName "")
      (fileBase "")
      (fNoExt "")
      (fPth "")
      (brkTok "/")
      (usr "")
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS
    (if (equal? "/" brkTok)(set! usr(getenv"HOME"))(set! usr(getenv"HOMEPATH")))

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (set! fNoExt (car (strbreakup fileBase ".")))
        (set! fPth (unbreakupstr (reverse (cdr(reverse (strbreakup fileName
                                                           brkTok)
                                                  )
                                              )
                                     ) 
                                     brkTok
                       )
        )
      )

      (when (equal? (car(gimp-image-get-file img)) "")
        (set! fileName (string-append usr brkTok "Untitled.xcf"))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (set! fNoExt (car (strbreakup fileBase ".")))
        (set! fPth usr)
      )

      (vector-set! fileInfo 0 fileName)
      (vector-set! fileInfo 1 fileBase)
      (vector-set! fileInfo 2 fNoExt)
      (vector-set! fileInfo 3 fPth)
    )

    fileInfo
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


(define (plugin-set-lock plugin lock) 
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)


(define (only-groups drwbles preFxL)
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
            ;(set! j (length allParents))
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


(define (close-groups grpLst)
  (let*
    (
    (i 0)
    )

    (while (< i (vector-length grpLst))
     (gimp-item-set-expanded (vector-ref grpLst i) 0)
     (set! i (+ i 1))
    )

  )
)


(define (precise-scale img scaleX scaleY)
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


(define (restore-layer-locks lckLst)
  (let*
    (
      (actL 0)(lckPos 0)(lckAlp 0)(lckCnt 0)(lckVis 0)
    )

    (set! lckLst (list->vector lckLst))
    (set! actL (vector-ref lckLst 0))
    (gimp-item-set-lock-content actL (vector-ref lckLst 1))
    (gimp-item-set-lock-position actL (vector-ref lckLst 2))
    (gimp-item-set-lock-visibility actL (vector-ref lckLst 3))
    (gimp-layer-set-lock-alpha actL (vector-ref lckLst 4))

  )
)


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
      (when #f
        (gimp-message 
          (string-append message
                          " : number -> " (number->string n)
                          "\n : fraction -> " (number->string f)
          )
        )
      )
    )

    (when #f
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


(define (layer-size-adjust img dstWdth dstHght)
  (let*
    (
      (allL 0)(i 0)(offX 0)(offY 0)(actL 0)(xScP 0)(yScP 0)(skip 0)(fixLst ())
      (wdthL 0)(hghtL 0)(offYPos #t)(offXPos #t)(actNme "")(adjLst ())(adjL 0)
      (srcWdth (car (gimp-image-get-width img)))
      (srcHght (car (gimp-image-get-height img)))
      (scX (/ dstWdth srcWdth))
      (scY (/ dstHght srcHght))
    )

    (set! allL (get-layers img 0))
    (set! fixLst (group-mask-protect img)) ; protect group masks from deletion

    ; scale any layers that are not groups
    (set! allL (list->vector allL))
    (while (< i (vector-length allL))
      ;(message-progress i (vector-length allL) "precise scale progress")
      (set! actL (vector-ref allL i))
      (set! skip 0)
      (set! actNme (short-layer-name actL 10))
      (set! offXPos #t)
      (set! offYPos #t)
      (if #f (gimp-message (string-append " adjusting layer -> " actNme)))

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

      (when #f ; debug
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
          (if #f (gimp-message "skip layer, matches image size and position"))
          (set! skip 1)
        )
      )

      ; reframe the layer by merging to a new layer with friendly dimensions
      (when (= skip 0)
        (set! adjL (layer-reframe img actL xScP yScP scX scY))

        (set! adjLst (append adjLst (list adjL wdthL hghtL offX offY scX scY)))
      )

      (if #f (gimp-message (string-append " adjusted layer -> " actNme)))
      (set! i (+ i 1))
    )

    (if (> (length fixLst) 0)(remove-layers img fixLst))

    adjLst
  )
)


(define (layer-size-restore adjLst)
  (let*
    (
      (actNme 0)(i 0)(offX 0)(offY 0)(actL 0)(xScP 0)(yScP 0)(skip 0)(fixLst ())
      (wdthL 0)(hghtL 0)(offYPos #t)(offXPos #t)(actNme "")
      (adjOffX 0)(adjOffY 0)(scX 0)(scY 0)(buffer 8)
    )

    (set! adjLst (list->vector adjLst))
    (while (< i (vector-length adjLst))
      ;(message-progress i (vector-length adjLst) "completion progress")
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

      (when #f ; debug
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

      ;(gimp-message (string-append " completing -> " actNme))

      (gimp-layer-resize actL wdthL hghtL adjOffX adjOffY)
      (set! i (+ i 7))
    )

  )
)


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


(define (remove-layers img lstL)
  (let*
    (
      (i 0)
    )

    (set! lstL (list->vector lstL))
    (while (< i (vector-length lstL))
      (gimp-image-remove-layer img (vector-ref lstL i))
      (set! i (+ i 1))
    )

  )
)


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

    (when #f ; debug
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
    (when (= (car(gimp-drawable-has-alpha actL)) 0)(gimp-layer-add-alpha actL))
    (gimp-layer-resize actL adjWdth adjHght (- offX xScP) (- offY yScP))

    (restore-layer-locks lckLst)

    actL
  )
)


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


(define (group-to-image actG srcImg dstImg parent) ; recursive
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(actL 0)(actGMsk 0)(folder 0)(dstM 0)(chldC 0)
      (rtnL 0)
    )

    (set! actGMsk (car (gimp-layer-get-mask actG)))
 
    ; create a destination copy of the layer or group
    (set! rtnL (layer-to-image actG srcImg dstImg parent))

    (set! dstM (car(gimp-layer-get-mask rtnL)))
    (set! chldrn (gimp-item-get-children actG))
    (set! lstL (list->vector (reverse (vector->list (cadr chldrn)))))
    (set! chldC (car chldrn))

    ; repeat for any children, recursively
    (while (< i chldC)
      (set! actL (vector-ref lstL i))

      (if (equal? (car (gimp-item-is-group actL)) 1)
        (group-to-image actL srcImg dstImg rtnL)
          (layer-to-image actL srcImg dstImg rtnL)
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


(define (layer-to-image srcL srcImg dstImg prnt)
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

      (gimp-image-insert-layer dstImg dstL prnt 0)
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


(define (restore-layer-parasites actL paraStrLst)
  (let*
    (
    (paraVal 0)(i 0)(actP 0)(paraName "")
    )
    
    (while (< i (length paraStrLst))
      (set! paraName (vector-ref (list->vector paraStrLst) i))
      (set! paraVal (vector-ref (list->vector paraStrLst) (+ i 2)))
      (gimp-item-attach-parasite actL (list paraName 0 paraVal))
      (set! i (+ i 3))
    )

  )
)


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


(define (message-progress currAmt maxAmt message)
  (let*
    (
      (prg 0)
    )

    (set! prg (* (/ 1 maxAmt) (+ currAmt 1)))
    (set! prg (trunc (floor (* prg 100))))
    (set! message (string-append " >>> " message " > "(number->string prg) "%"))
    (gimp-message message)

  )
)


(script-fu-register-filter "script-fu-proxy"
 "Proxy"
 "Replaces the folder contents with a proxy, or restores from disk"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE

)
(script-fu-menu-register "script-fu-proxy" "<Image>/Layer")
