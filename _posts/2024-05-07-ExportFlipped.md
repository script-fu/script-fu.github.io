## Exports the Image as a Flipped Grayscale Version

# * Tested in GIMP source 2.99.19, latest version only for 2.99.19 onwards *

This exports the active image as a flipped and grayscale jpg.

I use it to see the image I'm working on in a fresh way, this makes problem areas apparent.
The exported image is kept open in an image viewer, on a second monitor. The plug-in is set to a keyboard shortcut, when activated, it exports the image and the image viewer updates automatically to give me the power of second sight.

To download [**export-flipped.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/export-flipped/export-flipped.scm)  
...follow the link, right click the page, Save as export-flipped.scm, in a folder called export-flipped, in a GIMP plug-ins location.  
In Linux, set the file to be executable.
   
<!-- include-plugin "export-flipped" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-export-flipped img drawables)
  (let*
    ( 
      (quality (/ 90 100)) ; jpeg quality e.g (/ 85 100) for 85%
      (finalSNmeBw "bw.xcf")
      (fileInfo 0)(fileName 0)(fileBase 0)(fileNoExt 0)(filePath 0)
      (actL 0)(dstImg 0)(b&w 0)(saveNBw "")
    )

    (gimp-selection-none img)
    (set! b&w (car(gimp-image-get-base-type img)))

    ; establish file names
    (set! fileInfo (get-image-file-info img))
    (set! fileName (vector-ref fileInfo 0))
    (set! fileBase (vector-ref fileInfo 1))
    (set! fileNoExt (vector-ref fileInfo 2))
    (set! filePath (vector-ref fileInfo 3))

    ; copy visible and create a new display, flip it, turn it grayscale
    (gimp-edit-copy-visible img)
    (set! dstImg (car(gimp-edit-paste-as-new-image)))
    (set! actL (get-active-layer dstImg))
    (if (= b&w 0)(gimp-drawable-desaturate actL 3))
    (gimp-item-transform-flip-simple actL ORIENTATION-HORIZONTAL 1 0)

    ; save as jpg
    (set! saveNBw (string-append filePath "/" fileNoExt "_" finalSNmeBw))
    (gimp-image-set-file dstImg saveNBw)
    (file-jpg-save dstImg saveNBw quality)
    (gimp-image-delete dstImg)
  )
)


(script-fu-register-filter "script-fu-export-flipped"
 "Export flipped" 
 "Exports the image as a flipped and grayscale jpg"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2024"
 "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-export-flipped" "<Image>/Image")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message (string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; saves an image as a jpeg of a specified quality
(define (file-jpg-save img fileName quality)
  (let*
    (
      (exportName "")
    )

    (set! exportName (car (strbreakup fileName ".xcf")))
    (set! exportName (string-append exportName ".jpg"))

    (if debug (gimp-message (string-append " exporting : " exportName)))

    (file-jpeg-export 1
                      img
                      exportName
                      quality
                      0 ;smoothing
                      1 ;optimise
                      1 ;progressive
                      0 ; cmyk softproofing
                      "sub-sampling-1x1" ;subsampling 4:4:4
                      1 ;baseline
                      0 ;restart markers
                      "integer" ; dct integer
    )
  )

)


; macro to get the active drawable in an image, returns a layer/mask/group id
(define (get-active-layer img)
  (if (> (car(gimp-image-get-selected-layers img)) 0)
    (vector-ref (cadr(gimp-image-get-selected-layers img))0))
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

```
