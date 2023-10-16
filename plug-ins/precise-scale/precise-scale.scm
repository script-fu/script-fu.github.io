#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-precise-scale img drawables scaleX scaleY pix pX pY)
  (let*
    (
      (fileInfo (get-image-file-info img))(safeName "")
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (scAdj (percent-to-resolution scaleX scaleY width height))
      (scWdth (car scAdj))(scHght (cadr scAdj))(adjLst 0)(lckLst 0)
      (fileNoExt (vector-ref fileInfo 2))(noPrxyGrp 0)(brkTok DIR-SEPARATOR)
      (filePath (vector-ref fileInfo 3))(fileBase (vector-ref fileInfo 1))
      (mode INTERPOLATION-CUBIC) ; LINEAR ; CUBIC ; NOHALO ; LOHALO ; NONE
    )

    (if (> pix 0)(set! scWdth pX))(if (> pix 0)(set! scHght pY))

    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (gimp-context-set-interpolation mode)
    (gimp-selection-none img)

    (gimp-image-freeze-layers img)
    (set! lckLst (set-and-store-all-locks img 0 0))

    ; the image shouldn't alter, math adjustments to layer framing
    (set! adjLst (layer-size-adjust img scWdth scHght))

    ; scale with layer sizes and offsets that now avoid pixel rounding movement
    (gimp-message " * scaling image * ")
    (gimp-image-scale img scWdth scHght)
    (layer-size-restore adjLst)
    (restore-all-locks lckLst)

    (gimp-image-thaw-layers img)

    ; if the file has a save name, give it a new safe name
    (if (not (equal? (car(gimp-image-get-file img)) ""))
      (when (= (length (strbreakup fileNoExt "_scaled")) 1 )
        (set! safeName (string-append filePath brkTok fileNoExt "_scaled.xcf"))
        (gimp-image-set-file img safeName)
      )
    )

    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    (gimp-edit-copy-visible img)
    (gimp-message " * finished scaling * ")

  )
)


(script-fu-register-filter "script-fu-precise-scale"
 "Precise Scale"
 "Scales multi-layer images without layer pixel movement"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-ADJUSTMENT "Scale X %" (list 50 1 10000 1 10 0 SF-SPINNER)
 SF-ADJUSTMENT "Scale Y %" (list 50 1 10000 1 10 0 SF-SPINNER)
 SF-TOGGLE     "By Pixel"             FALSE
 SF-ADJUSTMENT "Pixel Width" (list 512 1 10000 1 10 0 SF-SPINNER)
 SF-ADJUSTMENT "Pixel Height" (list 512 1 10000 1 10 0 SF-SPINNER)
)
(script-fu-menu-register "script-fu-precise-scale" "<Image>/Image")

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

