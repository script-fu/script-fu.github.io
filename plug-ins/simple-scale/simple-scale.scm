#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-simple-scale img drawables scaleX scaleY pix pX pY crop)
  (let*
    (
      (width 0)(height 0)(cropMsk 0)(cropBx 0)(opac 0)
      (dstImg 0)(dstL 0)(fileInfo (get-image-file-info img))(safeName "")
      (fileNoExt (vector-ref fileInfo 2))(ScAdj 0)(brkTok DIR-SEPARATOR)
      (filePath (vector-ref fileInfo 3))(fileBase (vector-ref fileInfo 1))
      (mode INTERPOLATION-CUBIC) ; LINEAR ; CUBIC ; NOHALO ; LOHALO ; NONE
    )

    (gimp-context-push)

    ; look for a cropping layer and create a selection from its mask
    (set! cropBx (car(gimp-image-get-layer-by-name img "crop")))
    (if (> cropBx 0 ) (set! cropMsk (car(gimp-layer-get-mask cropBx))))

    (when (and (< cropMsk 0 ) (= crop 1))
      (gimp-message "make a masked layer that frames the image called \"crop\"")
    )

    (when (> cropMsk 0 )
      (when (> crop 0)
        (gimp-image-select-item img CHANNEL-OP-REPLACE cropMsk)
        (gimp-selection-invert img )
      )
      (when (= crop 0)
        (set! opac (car (gimp-layer-get-opacity cropBx)))
        (gimp-layer-set-opacity cropBx 0)
      )
    )

    ; copy visible in selected area
    (gimp-edit-copy-visible img)

    ; restore opacity if crop box was ignored
    (if (> opac 0) (gimp-layer-set-opacity cropBx opac))
    (gimp-selection-none img )

    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! width (car (gimp-image-get-width dstImg)))
    (set! height (car (gimp-image-get-height dstImg)))

    ; adjust scale factors for rounded-up resolution
    (set! ScAdj (percent-to-resolution scaleX scaleY width height))
    (set! width (car ScAdj))
    (set! height (cadr ScAdj))
    (if (> pix 0)(set! width pX))(if (> pix 0)(set! height pY))

    (gimp-context-set-interpolation mode)
    (if (< width 1)(set! width 1))(if (< height 1)(set! height))
    (gimp-image-scale dstImg width height)

    ; if the file has a save name, give it a new safe name
    (when (= (length (strbreakup fileNoExt "_scaled")) 1 )
      (set! safeName (string-append filePath brkTok fileNoExt "_scaled.xcf"))
      (gimp-image-set-file dstImg safeName)
    )

    ; if the file already has a safe name, don't repeat
    (when (> (length (strbreakup fileNoExt "_scaled")) 1 )
      (set! safeName (string-append filePath brkTok fileNoExt ".xcf"))
      (gimp-image-set-file dstImg safeName)
    )

    (set! dstL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name dstL "scaled-copy")
    (gimp-edit-copy-visible dstImg)
    (gimp-image-clean-all dstImg)
    (gimp-display-new dstImg)
    (gimp-context-pop)

  )
)

(define debug #f)

(script-fu-register-filter "script-fu-simple-scale"
 "Simple Scale"
 "Creates a scaled copy of all visible in a new image"
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
 SF-TOGGLE     "Use Crop Layer"             TRUE
)
(script-fu-menu-register "script-fu-simple-scale" "<Image>/Image")



; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


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


