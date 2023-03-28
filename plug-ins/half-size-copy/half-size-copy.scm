#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-half-size-copy srcImg drawables)
  (let*
    (
      (scale 0.5)
      (width  (car (gimp-image-get-width srcImg)))(dstW (* width scale))
      (height (car (gimp-image-get-height srcImg)))(dstH (* height scale))
      (dstDsp 0)(dstImg 0)(dstL 0)(fileInfo (get-file-info srcImg))(safeName "")
      (fileNoExt (vector-ref fileInfo 2))
      (filePath (vector-ref fileInfo 3))(fileBase (vector-ref fileInfo 1))
      (brkTok "/")
      (mode INTERPOLATION-CUBIC)
      ;INTERPOLATION-LINEAR
      ;INTERPOLATION-CUBIC
      ;INTERPOLATION-NOHALO
      ;INTERPOLATION-LOHALO
      ;INTERPOLATION-NONE
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    (gimp-context-push)
    (gimp-edit-copy-visible srcImg)
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (gimp-context-set-interpolation mode)
    (if (< dstW 1)(set! dstW 1))(if (< dstH 1)(set! dstH 1))
    (gimp-image-scale dstImg dstW dstH)
    (gimp-image-set-file dstImg "half-size")
    (set! dstL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name dstL "half-size-copy")
    (gimp-edit-copy-visible dstImg)
    (gimp-image-clean-all dstImg)
    (gimp-display-new dstImg)
    (gimp-context-pop)

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


(script-fu-register-filter "script-fu-half-size-copy"
 "Half Size Copy"
 "Half size copy of all visible"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-half-size-copy" "<Image>/Image")
