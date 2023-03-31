## Half and Quarter

# * Tested in Gimp 2.99.14 *

A quartet of plugins that perform halving or quartering, either on the image or copying
the result to a new image.  If it's on the image then it is also renamed for 
safety, avoiding accidental loss of the original scale.
  
The plug-ins should appear in the Image menu.  
  

To download [**half-size.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/half-size/half-size.scm)  
...follow the link, right click the page, Save as half-size.scm, in a folder called half-size, in a Gimp plug-ins location.  In Linux, set the file to be executable.
  
To download [**quarter-size.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/quarter-size/quarter-size.scm)  
  
To download [**half-size-copy.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/half-size-copy/half-size-copy.scm)  
  
To download [**quarter-size-copy.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/quarter-size-copy/quarter-size-copy.scm)  



```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-half-size srcImg drawables)
  (let*
    (
      (scale 0.5)
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
    (set! safeName (string-append filePath brkTok fileNoExt "_hSize.xcf"))
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


(script-fu-register-filter "script-fu-half-size"
 "Half Size"
 "Scales the active image to half of it's size and renames the image"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-half-size" "<Image>/Image")

```
  
    
```scheme
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

```
  
    
```scheme
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
    (set! safeName (string-append filePath brkTok fileNoExt "_hSizeFlat.xcf"))
    (gimp-image-set-file dstImg safeName)
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
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-half-size-copy" "<Image>/Image")

```
  
    
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-quarter-size-copy srcImg drawables)
  (let*
    (
      (scale 0.25)
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
    (set! safeName (string-append filePath brkTok fileNoExt "_qSizeFlat.xcf"))
    (gimp-image-set-file dstImg safeName)
    (set! dstL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name dstL "quarter-size-copy")
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


(script-fu-register-filter "script-fu-quarter-size-copy"
 "Quarter Size Copy"
 "Quarter size copy of all visible"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-quarter-size-copy" "<Image>/Image")


```