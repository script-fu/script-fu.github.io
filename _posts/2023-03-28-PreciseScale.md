## Precise Scale

# * Tested in Gimp 2.99.14 *

A scale transform that preserves all the positional relationships of the layers 
and avoids any pixel movement artifacts. Preserve Scale is a slower scale than the 
current Gimp default.
  
The plug-in should appear in the Image menu.  
  

To download [**precise-scale.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/precise-scale/precise-scale.scm)  
...follow the link, right click the page, Save as precise-scale.scm, in a folder called precise-scale, in a Gimp plug-ins location.  In Linux, set the file to be executable.


```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-precise-scale img drawables scaleX scaleY pix pX pY)
  (let*
    (
      (fileInfo (get-file-info img))(safeName "")
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (scAdj (percent-to-resolution scaleX scaleY width height))
      (scWdth (car scAdj))(scHght (cadr scAdj))(adjLst 0)(lckLst 0)
      (fileNoExt (vector-ref fileInfo 2))(noPrxyGrp 0)(brkTok "/")
      (filePath (vector-ref fileInfo 3))(fileBase (vector-ref fileInfo 1))
      (mode INTERPOLATION-CUBIC) ; LINEAR ; CUBIC ; NOHALO ; LOHALO ; NONE
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS
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


(define (all-childrn img rootGrp) ; recursive function
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(actL 0)(allL ())
    )

    (if (= rootGrp 0)
      (set! chldrn (gimp-image-get-layers img))
      (if (equal? (car (gimp-item-is-group rootGrp)) 1)
        (set! chldrn (gimp-item-get-children rootGrp))
        (set! chldrn (list 1 (list->vector (list rootGrp))))
      )
    )

    (set! lstL (cadr chldrn))
    (while (< i (car chldrn))
      (set! actL (vector-ref lstL i))
      (set! allL (append allL (list actL)))
      (if (equal? (car (gimp-item-is-group actL)) 1)
        (set! allL (append allL (all-childrn img actL)))
      )
      (set! i (+ i 1))
    )

    allL
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

      (gimp-message
        (string-append
          " preparing -> " actNme
                               " : "  (number->string (+ i 1)) " of "
                                 (number->string (vector-length allL))
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

      (gimp-message (string-append " completing -> " actNme))

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
    (if (= (car(gimp-drawable-has-alpha actL)) 0)(gimp-layer-add-alpha actL))
    (gimp-layer-resize actL adjWdth adjHght (- offX xScP) (- offY yScP))

    (restore-layer-locks lckLst)

    actL
  )
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


(define (get-file-info img)
  (let*
    (
      (fileInfo (vector "" "" "" ""))
      (fileName "")
      (fileBase "")
      (fileNoExt "")
      (filePath "")
      (brkTok "/")
    )
    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (set! fileNoExt (car (strbreakup fileBase ".")))
        (set! filePath (unbreakupstr (reverse (cdr(reverse (strbreakup fileName
                                                           brkTok)
                                                  )
                                              )
                                     ) 
                                     brkTok
                       )
        )
        (vector-set! fileInfo 0 fileName)
        (vector-set! fileInfo 1 fileBase)
        (vector-set! fileInfo 2 fileNoExt)
        (vector-set! fileInfo 3 filePath)
      )
    )

    fileInfo
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
    (if (= grpTru 1)(set! allGrp (append allGrp (list actL))))
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



(script-fu-register-filter "script-fu-precise-scale"
 "Precise Scale"
 "Scales multi-layer images without layer pixel movement"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
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



```