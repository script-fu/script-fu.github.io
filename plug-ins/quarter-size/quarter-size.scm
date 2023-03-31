#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-quarter-size srcImg drawables)
  (let*
    (
      (scale 0.25)
      (width  (car (gimp-image-get-width srcImg)))(dstW (* width scale))
      (height (car (gimp-image-get-height srcImg)))(dstH(* height scale))
      (fileInfo (get-file-info srcImg))(safeName "")
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
    (gimp-image-undo-group-start srcImg)
    (gimp-context-set-interpolation mode)
    (if (< dstW 1)(set! dstW 1))(if (< dstH 1)(set! dstH 1))
    (gimp-image-scale srcImg dstW dstH)
    (set! safeName (string-append filePath brkTok fileNoExt "_qSize.xcf"))
    (gimp-image-set-file srcImg safeName)
    (gimp-image-undo-group-end srcImg)
    (gimp-displays-flush)
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


(script-fu-register-filter "script-fu-quarter-size"
 "Quarter Size"
 "Scales the active image to a quarter of it's size and renames the image"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-quarter-size" "<Image>/Image")
