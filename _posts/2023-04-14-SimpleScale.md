## Simple Scale

# * Tested in GIMP 2.99.14 *

Copies all visible to a new image and scales that. Saves time when all you usually
use scaling for is to make a half sized copy.

The plug-in should appear in the Image menu.  
  
To download [**simple-scale.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/simple-scale/simple-scale.scm)  
...follow the link, right click the page, Save as simple-scale.scm, in a folder called simple-scale, in a Gimp plug-ins location.  In Linux, set the file to be executable.
  


```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-simple-scale img drawables scaleX scaleY pix pX pY)
  (let*
    (
      (width (car (gimp-image-get-width img)))
      (height (car (gimp-image-get-height img)))
      (dstImg 0)(dstL 0)(fileInfo (get-file-info img))(safeName "")
      (fileNoExt (vector-ref fileInfo 2))(ScAdj 0)
      (filePath (vector-ref fileInfo 3))(fileBase (vector-ref fileInfo 1))
      (brkTok "/")
      (mode INTERPOLATION-CUBIC) ; LINEAR ; CUBIC ; NOHALO ; LOHALO ; NONE
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    ; adjust scale factors for rounded-up resolution
    (set! ScAdj (percent-to-resolution scaleX scaleY width height))
    (set! width (car ScAdj))
    (set! height (cadr ScAdj))
    (if (> pix 0)(set! width pX))(if (> pix 0)(set! height pY))

    (gimp-context-push)
    (gimp-edit-copy-visible img)
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
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


; % scale 0-100 to integer pixel size
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


(script-fu-register-filter "script-fu-simple-scale"
 "Simple Scale"
 "Creates a scaled copy of all visible in a new image"
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
(script-fu-menu-register "script-fu-simple-scale" "<Image>/Image")



```