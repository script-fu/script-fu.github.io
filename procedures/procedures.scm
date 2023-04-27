
; Tested in Gimp 2.99.14
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3
; last updated April 2023

;                            * File Procedures *                                


; makes a directory in the "home" directory with a string "/path/like/this"
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


; exports all the vector/paths to a file "vector_#", returns number of exports
(define (vector-export img )
  (let*
    (
      (allVec (gimp-image-get-vectors img))
      (i 0)(actV 0)()(vecFle "")
    )

    (while (< i (car allVec ))
      (set! actV (vector-ref (cadr allVec) i))
      (set! vecFle (string-append "vector_" (number->string i)))
      (gimp-vectors-export-to-file img vecFle actV)
      (gimp-image-remove-vectors img actV)
      (set! i (+ i 1))
    )

    i
  )
)


; imports all the vector/paths
(define (vector-import img numV)
  (let*
    (
      (i 0)(vecFle "")
    )

    (while (< i numV)
      (set! vecFle (string-append "vector_" (number->string i)))
      (gimp-vectors-import-from-file img vecFle 0 1)
      (set! i (+ i 1))
    )

  )
)


; finds the full file name, base name, stripped name, and path of a given image
; (image id)
; returns a vector list ("/here/myfile.xcf" "myfile.xcf" "myfile" "/here")
(define (get-image-file-info img)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(brkTok "/")(usr "")(strL "")
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS
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

    (set! strL (string-append " file name -> " fNme "\n file base -> " fBse
                              "\n name no extension-> " fwEx 
                              "\n file path -> " fPth
                )
    )
    (gimp-message strL)

    (vector fNme fBse fwEx fPth)
  )
)


; saves an image as a jpeg of a specified quality
(define (file-jpg-save img fileName quality)
  (file-jpeg-save 1
                       img
                       1 ;number of drawables to save
                       (cadr(gimp-image-get-selected-layers img))
                        fileName
                        quality
                        0 ;smoothing
                        1 ;optimise
                        1 ;progressive
                        0 ; cmyk softproofing
                        2 ;subsampling 4:4:4
                        1 ;baseline
                        0 ;restart markers
                        0 ; dct integer

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



;                           * Image Procedures *                                


; creates a new RGB image of a specified precision
; (width, height, type/RGB), precision/PRECISION-U32-LINEAR)
; returns the new image and a new layer ID in a list (img layer)
(define (new-image-with-precision width height type precision)
  (let*
    (
      (img 0)(actL 0)(nme "Background")(mde LAYER-MODE-NORMAL)
      ; precision = PRECISION-U8-NON-LINEAR (150)
      ; precision = PRECISION-U16-LINEAR (200)
      ; precision = PRECISION-U32-LINEAR (300)
      ; type = RGB, GRAY , INDEXED
    )
    

    (set! img (car(gimp-image-new-with-precision width height type precision)))
    (set! actL (car(gimp-layer-new img width height RGBA-IMAGE nme 100 mde)))
    (gimp-image-insert-layer img actL 0 0)

    (list img actl)
  )
)


; returns (offset X, offset Y, max W, max H) - the canvas origin and size
(define (offset-origin img)
  (let*
    (
      (chldrn (gimp-image-get-layers img))(lstL 0)(actL 0)(i 0)
      (maxW 0)(maxH 0)(offX 0)(offY 0)(minW 0)(minH 0)(wdth 0)(hght 0)
      (minY 0)(maxY 0)(minX 0)
    )
    (set! lstL (cadr chldrn))
    (while (< i (car chldrn))
      (set! actL (vector-ref lstL i))
      (set! offX (car(gimp-drawable-get-offsets actL)))
      (set! offY (cadr(gimp-drawable-get-offsets actL)))
      (set! wdth (car(gimp-drawable-get-width actL)))
      (set! hght (car(gimp-drawable-get-height actL)))
      
      (if (> minX offX)(set! minX offX))
      (if (< maxW wdth)(set! maxW wdth))
      (if (> minY offY)(set! minY offY))
      (if (< maxH hght)(set! maxH hght))
      (set! i (+ i 1))
    )

    (list (abs minX) (abs minY) (abs maxW) (abs maxH))

  )
)


; returns 1, if a named image is open, compares the "filename.ext"
(define (image-exists findName)
  (let*
    (
      (openImages 0)(img 0)(exists 0)(fileName 0)(fileBase 0)(i 0)(brkTok "/")
    )
    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    (set! openImages (gimp-get-images))
    (while (< i (car openImages))
      (set! img (vector-ref (cadr openImages) i))
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (if (equal? fileBase findName)(set! exists 1))
      )
      (set! i (+ i 1))
    )

    exists
  )
)


; closes a named image if it is open, compares the "filename.ext"
(define (find-and-remove-image findName)
  (let*
    (
      (openImages 0)(img 0)(fileName 0)(fileBase 0)(i 0)(brkTok "/")(valid 0)
    )
    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    (set! openImages (gimp-get-images))
    (while (< i (car openImages))
      (set! img (vector-ref (cadr openImages) i))
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (when (equal? fileBase findName)
          (set! valid (car (gimp-image-id-is-valid img)))
          (if (= valid 1) (gimp-image-delete img))
          (set! i (car openImages))
        )
      )
      (set! i (+ i 1))
    )

  )
)


; scans through possible display id's and brings the first it finds to the fore
(define (present-first-display)
  (let*
    (
      (i 0)
    )

    (while (< i 100)
      (when (= (car (gimp-display-id-is-valid i)) 1)
        (gimp-display-present i)

        (set! i 100)
      )
      (set! i (+ i 1))
    )

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



;                           * Layer Procedures *                                


; copies a mask to a layer or creates a new layer for the copy
; (source image, src mask, destination image, dst layer, dst parent, name)
; returns the destination layer id
(define (mask-to-layer img srcM dstImg dstL dstP name)
  (let*
    (
      (actL 0)(cur-width 0)(cur-height 0)(dstExst dstL)(nmeL "")
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcM))
    (set! cur-width (car (gimp-drawable-get-width srcM)))
    (set! cur-height (car (gimp-drawable-get-height srcM)))
    (when (= dstExst 0)
      (set! dstL (car (gimp-layer-new dstImg
                                      cur-width
                                      cur-height
                                      RGBA-IMAGE
                                      "dstL"
                                      100
                                      LAYER-MODE-NORMAL
                       )
                  )
      )
      (gimp-item-set-visible dstL 0)
      (gimp-image-insert-layer dstImg dstL dstP 0)
    )
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! nmeL (car (gimp-item-get-name (car (gimp-layer-from-mask srcM)))))
    (gimp-item-set-name actL (string-append nmeL "-" name))

    actL
  )
)


; copies a mask to a mask, or layer to a mask
; (source image, src mask/layer, destination image, dst mask)
; returns the destination mask id
(define (transfer-mask-to-mask srcImg srcM dstImg dstM)
  (let*
    (
      (srcL (car(gimp-layer-from-mask srcM)))
      (offX (car(gimp-drawable-get-offsets srcL )))
      (offY (cadr(gimp-drawable-get-offsets srcL )))
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


; special case of merging down to the layer below, keeps and restores the mask
(define (merge-down-keep-upper-mask img upperL lowerL)
  (let*
    (
      (msk (car (gimp-layer-get-mask upperL)))(actL 0)(dstMsk 0)
      (offX (car(gimp-drawable-get-offsets upperL)))
      (offY (cadr(gimp-drawable-get-offsets upperL)))
    )

    ; save the mask
    (when (> msk 0)
      (gimp-edit-copy 1 (vector msk))
      (gimp-layer-remove-mask upperL MASK-DISCARD)
    )

    (set! actL (car(gimp-image-merge-down img upperL CLIP-TO-BOTTOM-LAYER)))

    ; restore the mask
    (when (> msk 0)
      (gimp-item-set-visible actL 0)
      (set! dstMsk (car (gimp-layer-create-mask actL ADD-MASK-BLACK)))
      (gimp-layer-add-mask actL dstMsk)
      (set! dstMsk(car (gimp-layer-get-mask actL)))
      (set! dstMsk (vector-ref (cadr(gimp-edit-paste dstMsk 1)) 0 ))
      (gimp-layer-set-offsets dstMsk offX offY)
      (gimp-floating-sel-anchor dstMsk)
    )

    ;return active layer
    (vector-ref (cadr(gimp-image-get-selected-layers img))0)
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


; sets the visibility state of a layer list
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


; finds a layer in an image by name
; (source image, "name")
; returns the layer id or 0
(define (find-layer img name)
  (let*
    (
      (matchL 0)(matchNme 0)(i 0)(lstL ())
    )

    (set! lstL (all-childrn img 0))
    (if (list? lst )(set! lst (list->vector lst)))

    (while (< i (vector-length lstL))
      (set! matchNme (car(gimp-item-get-name (vector-ref lstL i))))
      (when (equal? name matchNme)
        (set! matchL (vector-ref lstL i))
        (set! i (vector-length lstL))
        ; (gimp-message (string-append " found layer -> " name " : ID = "
        ;                               (number->string matchL)
        ;               )
        ; )
      )
      (set! i (+ i 1))
    )

    matchL
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


; returns a list of the lock states of a layer stack "branch"
(define (get-layer-locks img rootGrp)
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

    ; also get the root group locks
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


; copies a layer stack branch to another image
; (source image, source group, dest image, destination parent)
(define (group-to-image srcImg actG dstImg parent) ; recursive
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


; duplicates a layer and assigns specific attributes
; (source image, source layer, new layer name, opacity, mode, visibility)
; returns the new layer id
(define (duplicate-layer img srcL name opac mode vis)
  (let*
    (
      (actL 0)
      (parent 0)
      (pos 0)
    )

    (set! parent (car (gimp-item-get-parent srcL)))
    (set! pos (car (gimp-image-get-item-position img srcL)))
    (set! actL (car (gimp-layer-new-from-drawable srcL img)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-opacity actL opac)
    (gimp-layer-set-mode actL mode)
    (gimp-item-set-name actL name)
    (gimp-item-set-visible actL vis)

  actL
  )
)


; duplicates a layer
; (source image, source layer, new layer name)
; returns the new layer id
(define (basic-duplicate-layer img srcL name)
  (let*
    (
      (actL 0)
      (parent 0)
      (pos 0)
    )

    (set! parent (car (gimp-item-get-parent srcL)))
    (set! pos (car (gimp-image-get-item-position img srcL)))
    (set! actL (car (gimp-layer-new-from-drawable srcL img)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-item-set-name actL name)

  actL
  )
)

; puts a list of layers in a group based on the stack pos of the first element
; (source image, list/vector of layers)
; returns the new group id
(define (layer-group img drwbls)
 (let*
    (
      (mde LAYER-MODE-NORMAL) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
      (nme "groupNme")
      (numDraw 0)(actL 0)(parent 0)(i 0)(pos 0)(grp 0)
    )
    
    (if (list? drwbls) (set! drwbls (list->vector drwbls)))
    (set! numDraw (vector-length drwbls))
    (set! actL (vector-ref drwbls 0))
    (set! parent (car (gimp-item-get-parent actL)))
    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! i (- numDraw 1))
    (set! grp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img grp parent pos)
    (gimp-item-set-name grp nme)
    (gimp-layer-set-mode grp mde)

    (while (> i -1)
      (set! actL (vector-ref drwbls i))
      (gimp-image-reorder-item img actL grp 0)
      (set! i (- i 1))
    )

    grp

  )
)


; takes a layer and returns it's id, mask id and name as a vector
(define (get-layer-info img actL)
  (let*
    (
      (actMsk 0)(actNme "")
    )

    (when (= (car (gimp-item-id-is-valid actL)) 1)
      (when(=(car (gimp-item-id-is-layer-mask actL)) 0)
        (if(> (car (gimp-layer-get-mask actL)) 0)
          (set! actMsk (car (gimp-layer-get-mask actL)))
        )
        (set! actNme(car(gimp-item-get-name actL)))
      )

      (when(= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actMsk actL)
        (set! actL (car(gimp-layer-from-mask actMsk)))
        (set! actNme (car(gimp-item-get-name actL)))
      )
    )

    (vector actL actMsk actNme)
  )
)


; macro to get the active drawable in an image, returns a layer/mask/group id
(define (get-active-layer img)
  (vector-ref (cadr(gimp-image-get-selected-layers img))0)
)


; creates a new image and display with a copy of a source layer
; (source image, source layer)
; returns a new image, a new display and the new layer
(define (layer-to-new-image img actL)
  (let*
    (
      (dstImg 0)(dstDsp 0)
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! dstDsp (car(gimp-display-new dstImg)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))

    (list dstImg dstDsp actL)
  )
)


; copy all visible, or a drawable, paste into a destination layer or a new layer
; (src img, src layer/0, dst img, dst layer/0, parent, nme, crop to image size)
; returns the new layer id
(define (copy-to-new-layer img srcL dstImg dstL dstP name crop)
  (let*
    (
    (actL 0)(cur-width 0)(cur-height 0)(dstExst dstL)
    )

    (when (= srcL 0)
      (gimp-selection-none img)
      (gimp-edit-copy-visible img)
      (set! cur-width (car (gimp-image-get-width img)))
      (set! cur-height (car (gimp-image-get-height img)))
    )

    ; get size and ID of first drawable
    (when (> srcL 0)
      (gimp-selection-none img)
      (gimp-edit-copy 1 (vector srcL))
      (set! cur-width (car (gimp-drawable-get-width srcL)))
      (set! cur-height (car (gimp-drawable-get-height srcL)))
    )

    ;add a new destination layer if needed
    (when (= dstExst 0)
      (set! dstL (car (gimp-layer-new dstImg
                                      cur-width
                                      cur-height
                                      RGBA-IMAGE
                                      "dstL"
                                      100
                                      LAYER-MODE-NORMAL
                       )
                  )
      )
      (gimp-image-insert-layer dstImg dstL dstP 0)
    )

    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    
    ; floating selection to new layer or anchor to temporary layer?
    (if (= dstExst 1)(gimp-floating-sel-to-layer actL)
      (gimp-floating-sel-anchor actL)
    )

    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name actL name)
    (if (= crop 1)(gimp-layer-resize-to-image-size actL))
    actL
  )
)


; copies a layer to a channel
;(source image, source layer, destination channel)
(define (transfer-layer-to-channel img srcL dstChn)
    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcL))
    (set! dstChn (vector-ref (cadr(gimp-edit-paste dstChn 1)) 0 ))
    (gimp-floating-sel-anchor dstChn)
)


; fills a layer with a RGB color
(define (fill-layer actL red green blue)
  (gimp-context-push)
  (gimp-context-set-opacity 100)
  (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
  (gimp-context-set-foreground (list red green blue))
  (gimp-drawable-fill actL 0)
  (gimp-context-pop)
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
    )

    mask
  )
)


; crops layer list to the mask area, plus a safe border
; (image, list of layers, border width)
(define (mask-box-crop img lstL expand)
(let*
    (
      (actL 0)(pnts 0)(mskSel 0)(wdthL 0)(hghtL 0)(offX 0)(offY 0)(i 0)
      (crpW 0)(crpH 0)(actMsk 0)
    )

    (gimp-image-undo-group-start img)
    (gimp-context-push)
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      
      (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
        (set! actL (car(gimp-layer-from-mask actL)))
      )
      
      (set! actMsk (car (gimp-layer-get-mask actL)))
      
      (when (> actMsk 0)
        (set! offX (car (gimp-drawable-get-offsets actL)))
        (set! offY (car (cdr (gimp-drawable-get-offsets actL))))
        (set! wdthL (car (gimp-drawable-get-width actL)))
        (set! hghtL (car (gimp-drawable-get-height actL)))
        (set! mskSel (gimp-image-select-item img CHANNEL-OP-REPLACE actMsk))
        
        (set! pnts (make-vector 4 'double))
        (vector-set! pnts 0 (car(cdr(gimp-selection-bounds img))))
        (vector-set! pnts 1 (car(cddr(gimp-selection-bounds img))))
        (vector-set! pnts 2 (car(cdddr(gimp-selection-bounds img))))
        (vector-set! pnts 3 (car(cddr(cddr(gimp-selection-bounds img)))))

        (vector-set! pnts 0 (- (vector-ref pnts 0) expand))
        (vector-set! pnts 1 (- (vector-ref pnts 1) expand))
        (vector-set! pnts 2 (+ (vector-ref pnts 2) expand))
        (vector-set! pnts 3 (+ (vector-ref pnts 3) expand))

        (set! crpW (- (vector-ref pnts 2) (vector-ref pnts 0)))
        (set! crpH (- (vector-ref pnts 3) (vector-ref pnts 1)))
        (set! offX (- offX (vector-ref pnts 0)))
        (set! offY (- offY (vector-ref pnts 1)))

        (gimp-layer-resize actL crpW crpH offX offY)
      )
      (set! i (+ i 1))
    )
    (gimp-selection-none img)
    (gimp-context-pop)
    (gimp-image-undo-group-end img)

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


; sets a layers locks
; (layer id, lock content, lock position, lock visibility, lock alpha)
(define (set-lock-layer actL lckCon lckPos lckVis lckAlp)
  (gimp-item-set-lock-content actL lckCon)
  (gimp-item-set-lock-position actL lckPos)
  (gimp-item-set-lock-visibility actL lckVis)
  (gimp-layer-set-lock-alpha actL lckAlp)
)


; apply an "s curve" to a layer, increases contrast
(define (apply-s-curve img actL)
  (curve-4-value img actL 0 0 77 32 174 220 255 255)
)


; apply a brightning curve to a layer
(define (apply-bright-curve img actL)
  (curve-3-value img actL 0 0 159 222 255 255)
)


(define (get-all-parents img actL)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent actL)))

    (when (> parent 0)
      (while (> parent 0)
        (set! allParents (append allParents (list parent)))
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )

    allParents
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


; moves a list of groups to the root of the layer stack
; bug workaround, can't reorder item to root 0
; returns a list of new groups
(define (root-group img grpLst)
  (let
    (
    (i 0)(actG 0)(tmpGrp 0)(tmpGrpLst ())(j 0)(actL 0)(chldrn 0)(lstL 0)(aStr 0)
    )

    (while (< i (vector-length grpLst))
      (set! actG (vector-ref grpLst i))
      (set! aStr (store-layer-attributes img actG))
      (set! tmpGrp (gimp-layer-group-new img))
      (set! tmpGrpLst (append tmpGrpLst tmpGrp))
      (gimp-image-insert-layer img (car tmpGrp) 0 0)

      (set! chldrn (gimp-item-get-children actG))
      (set! lstL (list->vector (reverse (vector->list (cadr chldrn)))))
      (set! j 0)
      (while (< j (car chldrn))
        (set! actL (vector-ref lstL j))
        (gimp-image-reorder-item img actL (car tmpGrp) 0)
        (set! j (+ j 1))
      )
      (set! i (+ i 1))
      (gimp-image-remove-layer img actG)
      (restore-layer-attributes (car tmpGrp) aStr)
    )

  tmpGrpLst
  )
)


; returns a list of a layers attributes
; (source image, layer id)
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

  )
)



;                        * Parasite Procedures *                                


; tags a layer with a parasite and an optional layer colour
; (layer id, "parasite name", attach mode, "value string", layer color)
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
; color (0-8) (none, blue, green, yellow, orange, brown, red, violet, grey)
(define (tag-layer actL name mode tagV col)
  (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
    (set! actL (car(gimp-layer-from-mask actL)))
  )
  (gimp-item-attach-parasite actL (list name mode tagV))
  (gimp-item-set-color-tag actL col)
)


; tags an image with a parasite
; (layer id, "parasite name", attach mode, "value string")
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
(define (tag-image img name mode tagV)
  (gimp-image-attach-parasite img (list name 0 tagV))
)


; given a list of layers it finds and prints the parasites on each layer
(define (print-layer-parasites lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(nme "")(para "")(actL 0)(j 0)(pV 0)(pN "")
      (para 0)(grp 0)(len 0)
    )

    (if (list? lst )(set! lst (list->vector lst)))
    (set! len (number->string (vector-length lst)))

    ; create a formatted string
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! j 0)
      (set! nme (car(gimp-item-get-name actL)))
      (set! id (number->string actL))
      (set! grp (car (gimp-item-is-group actL)))
      (set! para (car (gimp-item-get-parasite-list actL)))
      (set! len (length para))
      (set! aStr (string-append aStr " item id : " id " : " nme ))
      (if (= grp 1) (set! aStr (string-append aStr " is a group \n"))
        (set! aStr (string-append aStr " \n"))
      )
      (if (= len 0)(set! aStr (string-append aStr " has no parasites \n\n")))

      (while (< j len)
        (set! pN (list-ref para j))
        (set! pV (get-item-parasite-string actL pN))
        (set! aStr (string-append aStr " has parasite : "pN" : "pV"\n"))
        (if (= j (- len 1))(set! aStr (string-append aStr "\n")))
        (set! j (+ j 1))
      )

      (set! i (+ i 1))
    )

    (gimp-message aStr)

    aStr
  )
)


; returns the value string of a parasite on a specified layer
; (layer id, parasite name)
(define (get-layer-parasite-string actL paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-item-get-parasite-list actL))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message " found the parasite "))
        (set! fndV (caddar(gimp-item-get-parasite actL actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)


; removes all the parasites from a list of layers and prints the results
(define (remove-layer-parasites img lst)
  (let*
    (
      (len "")(id 0)(i 0)(aStr "")(nme "")(para "")(actL 0)(j 0)(pV 0)(pN "")
      (para 0)(grp 0)(len 0)
    )

    (if (list? lst )(set! lst (list->vector lst)))
    (set! len (number->string (vector-length lst)))

    ; create a formatted string
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! j 0)
      (set! nme (car(gimp-item-get-name actL)))
      (set! id (number->string actL))
      (set! grp (car (gimp-item-is-group actL)))
      (set! para (car (gimp-item-get-parasite-list actL)))
      (set! len (length para))
      (set! aStr (string-append aStr " item id : " id " : " nme ))
      (if (= grp 1) (set! aStr (string-append aStr " is a group \n"))
        (set! aStr (string-append aStr " \n"))
      )
      (if (= len 0)(set! aStr (string-append aStr " has no parasites \n\n")))

      (while (< j len)
        (set! pN (list-ref para j))
        (set! pV (get-item-parasite-string actL pN))
        (set! aStr (string-append aStr " removing parasite : "pN" : "pV"\n"))
        (if (= j (- len 1))(set! aStr (string-append aStr "\n")))
        (gimp-item-detach-parasite actL pN)
        (set! j (+ j 1))
      )

      (set! i (+ i 1))
    )

    (gimp-message aStr)

    aStr
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


; attachs a list of parasites to a layer
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


; if global parasite exists, returns the string stored , otherwise returns ""
(define (get-global-parasite-string paraNme)
  (let*
    (
      (i 0)(actP 0)(fndStr "")
      (para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message "found the global parasite"))
        (set! fndStr (string->number (caddar(gimp-get-parasite actP))))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndStr
  )
)


; given a list of layers it returns a list of those layers with a parasite "tag"
; (source image, list of layers, "tag/parasite name")
(define (get-layers-tagged img lstL tag)
  (let*
    (
      (tLst ())(actL 0)(paraLst 0)(pNme 0)(i 0)(j 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paraLst (list->vector (car (gimp-item-get-parasite-list actL))))
      (when (> (vector-length paraLst) 0)
        (set! j 0)
        (while(< j (vector-length paraLst))
          (set! pNme (vector-ref paraLst j))
          (if (equal? pNme tag)(set! tLst (append tLst (list actL))))
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tLst)
  )
)


; finds any images that have an attached parasite "tag"
; ("tag/parasite name") 
; returns a list of found images
(define (get-images-tagged tag)
  (let*
    (
      (tLst ())(img 0)(paraLst 0)(pNme 0)(i 0)(j 0)(allImgs 0)
    )

    (set! allImgs (gimp-get-images))
    (while (< i (car allImgs))
      (set! img (vector-ref (cadr allImgs) i))
      (set! paraLst (list->vector (car (gimp-image-get-parasite-list img))))
      (when (> (vector-length paraLst) 0)
        (set! j 0)
        (while(< j (vector-length paraLst))
          (set! pNme (vector-ref paraLst j))
          (when (equal? pNme tag)
            (set! tLst (append tLst (list img)))
            (set! j (vector-length paraLst))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tLst)
  )
)


; returns the value string of a parasite on a specified image
; (image id, parasite name)
(define (get-image-parasite-string img paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-image-get-parasite-list img))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message " found the parasite "))
        (set! fndV (caddar(gimp-image-get-parasite img actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)



;                       * Filter Lists Procedures *                             

; filters a vector list of drawables, returns a vector list of only the groups
(define (only-groups drwbls)
  (let*
    (
      (i 0)(actL 0)(grpLst())
    )

    (while (< i (vector-length drwbls))
      (set! actL (vector-ref drwbls i))
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


; finds every direct parent of a list if items, returns a list of parents
(define (all-parents-of-list lst)
  (let*
    (
      (allPs ())(parent 0)(i 0)(actL 0)
    )

    (if (list? lst) (set! lst (list->vector lst)))
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! parent (car(gimp-item-get-parent actL)))
      
      (if (and (not(member parent allPs)) (> parent 0))
        (set! allPs (append allPs (list parent)))
      )
      (set! i (+ i 1))
    )

   allPs
  )
)

; given a list of layers the list is sorted into a vector of vector lists
; the sorting based on what parent a layer has. Finds groups of layers.
(define (layer-list-into-parent-group-buckets lst)
  (let*
    (
      (allPs ())(parent 0)(i 0)(j 0)(actL 0)(groups 0)(actP 0)
    )

    ; find all the parents of list items
    (set! allPs (list->vector (all-parents-of-list lst)))

    ; make a bucket list for the group sorting
    (set! groups (make-vector (vector-length allPs) #()))

    ; sort the list into group buckets based on which parent
    (set! i 0)
    (if (list? lst) (set! lst (list->vector lst)))
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! parent (car(gimp-item-get-parent actL)))
      (set! j 0)
      (when (> parent 0)
        (while (< j (vector-length allPs))
          (set! actP (vector-ref allPs j))
          (if (= actP parent)(set! groups (add-to-bucket groups j actL)))
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
      
    )
    

  groups
  )
)


; adds a value to a vector in a vector list
(define (add-to-bucket vectVect bucket n)
  (vector-set! vectVect bucket (vector-append (vector-ref vectVect bucket) n))
)




;                       * Print Lists Procedures *                              


; prints a vector of vector lists, e.g a vector of groups and child layers
(define (print-vector-bucket-list lst)
  (let*
    (
      (actG 0)(actP 0)(strL "")(i 0)(j 0)(grp 0)(nme "")(actL 0)
    )

    (while (< i (vector-length lst))
      (set! actG (vector-ref lst i))
      (set! j 0)
      (while (< j (vector-length actG))
        (set! actL (vector-ref actG j))
        (set! nme (car (gimp-item-get-name actL)))
        (set! grp (number->string i))
        (set! strL (string-append strL "\n group " grp " : child : " nme))
        (set! j (+ j 1))
      )
      (set! strL (string-append strL "\n"))
      (set! i (+ i 1))
    )
    (gimp-message strL)
  )
)


; prints the layer name and id of every layer in a list in one string
(define (print-layer-id-name lstL)
  (let*
    (
      (i 0)(strL "")(msg " ")(actL 0)(id "")(nme "")
    )
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (set! id (number->string actL))
        (set! nme (car(gimp-item-get-name actL)))
        (set! strL (string-append strL msg id " : " nme "\n"))
      )
      (set! i (+ i 1))
    )
    (gimp-message strL)
  )
)


; compares two lists of numbers and tests for a perfect match
; returns 1 or 0
(define (number-lists-match lstA lstB)
  (let
    (
      (match 0)
    )

    (if (vector? lstA) (set! lstA (vector->list lstA)))
    (if (vector? lstB) (set! lstB (vector->list lstB)))

    (when (not (null? lstA))
      (when (= (length lstA) (length lstB))
        (set! lstA (bubble-sort (length lstA) lstA))
        (set! lstB (bubble-sort (length lstB) lstB))
        (if (equal? lstA lstB) (set! match 1))
      )
    )

  match
  )
)



;                            * Misc Procedures *                                

; bubble sorting from;
; https://stackoverflow.com/users/2860713/avery-poole
; https://stackoverflow.com/users/201359/%c3%93scar-l%c3%b3pez
; thanks!
(define (bubble-up lst)
  (if (null? (cdr lst))
    lst
     (if (< (car lst) (cadr lst))
       (cons (car lst) (bubble-up (cdr lst)))
         (cons (cadr lst) (bubble-up (cons (car lst) (cddr lst))))
     )
  )
)
(define (bubble-sort len lst)
  (cond ((= len 1) (bubble-up lst))
    (else (bubble-sort (- len 1) (bubble-up lst)))
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
    (gimp-message message)

  )
)


; returns a random number within a min and max range, can be switched to float
(define (random-range minV maxV)
  (let*
    (
     (randomInt 0)
     (randomFloat 0)
    )

    (set! randomInt (- maxV minV))
    (set! randomInt (rand randomInt))
    (set! randomInt (+ minV randomInt))
    (set! minV (* minV 1000000))
    (set! maxV (* maxV 1000000))
    (set! randomFloat (- maxV minV))
    (set! randomFloat (rand randomFloat))
    (set! randomFloat (+ minV randomFloat))
    (set! randomFloat (/ randomFloat 1000000))

    randomInt
    ;randomFloat
  )
)


; apply a 4 value curve to a layer with specified points
; (image, layer id, curve point (x,y), (x,y), (x,y), (x,y))
(define (curve-4-value img actL x1 y1 x2 y2 x3 y3 x4 y4)
  (let*
    (
      (points())
      (conv (/ 1 255))
    )

    (set! points (make-vector 8 'double))
    (vector-set! points 0 (* x1 conv))
    (vector-set! points 1 (* y1 conv))
    (vector-set! points 2 (* x2 conv))
    (vector-set! points 3 (* y2 conv))
    (vector-set! points 4 (* x3 conv))
    (vector-set! points 5 (* y3 conv))
    (vector-set! points 6 (* x4 conv))
    (vector-set! points 7 (* y4 conv))

    (gimp-drawable-curves-spline actL 0 8 points)
    actL
  )
)


; apply a 3 value curve to a layer with specified points
; (image, layer id, curve point (x,y), (x,y), (x,y))
(define (curve-3-value img actL x1 y1 x2 y2 x3 y3)
  (let*
    (
      (points())
      (conv (/ 1 255))
    )

    (set! points (make-vector 6 'double))
    (vector-set! points 0 (* x1 conv))
    (vector-set! points 1 (* y1 conv))
    (vector-set! points 2 (* x2 conv))
    (vector-set! points 3 (* y2 conv))
    (vector-set! points 4 (* x3 conv))
    (vector-set! points 5 (* y3 conv))

    (gimp-drawable-curves-spline actL 0 6 points)
    actL
  )
)


; apply a 2 value curve to a layer with specified points
; (image, layer id, curve point (x,y), (x,y))
(define (curve-2-value img actL x1 y1 x2 y2)
  (let*
    (
      (points())
      (conv (/ 1 255))
    )

    (set! points (make-vector 4 'double))
    (vector-set! points 0 (* x1 conv) )
    (vector-set! points 1 (* y1 conv) )
    (vector-set! points 2 (* x2 conv) )
    (vector-set! points 3 (* y2 conv) )

    (gimp-drawable-curves-spline actL 0 4 points)
    actL
  )
)


; adds a new value to the end of a vector
; (vector, value)
; returns the new vector
(define (vector-append vect v)
  (let*
    (
      (len (vector-length vect ))
      (tmpV (make-vector (+ 1 len) v))
      (i 0)
    )

    (when (> len 0)
      (while (< i len)
        (vector-set! tmpV i (vector-ref vect i))
        (set! i (+ i 1))
      )
    )

    (set! vect tmpV)
  )
)








