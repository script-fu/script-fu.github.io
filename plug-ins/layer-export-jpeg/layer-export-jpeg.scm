#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-layer-export-jpeg img drwbls expNme expDir)
  (let*
    (
      (quality 0.85)(filePth "")(isGrp 0)
      (lstL (all-childrn img 0))(i 0)(actL 0)(expL 0)(expImg 0)(expInfo 0)
    )

    (make-dir-path (string-append "/" expDir))

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
         (set! isGrp (car (gimp-item-is-group actL)))
         (when (= isGrp 0)
           (set! expInfo (layer-to-hidden-image img actL))
           (set! expImg (car expInfo))
           (set! expL (cadr expInfo))
           (set! filePth (string-append expDir "/" ))
           (set! filePth (string-append filePth expNme "_" ))
           (set! filePth (string-append filePth (number->string (+ i 1))))
           (if debug (gimp-message (string-append " exporting to -> " filePth)))
           (file-jpg-save expImg filePth quality)
           (gimp-image-delete expImg)
         )
      )
      (set! i (+ i 1))
    )

    (gimp-message " finished exporting layers ")

  )
)


(script-fu-register-filter "script-fu-layer-export-jpeg"
 "Export All Layers as Jpeg"
 "exports all the layers to a named 'Home' folder as jpegs"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-STRING "file prefix" "layer"
 SF-STRING "name of storage folder" "exported-layers"
)
(script-fu-menu-register "script-fu-layer-export-jpeg" "<Image>/File")


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


; creates a new image with a copy of a source layer
; (source image, source layer)
; returns a new image, and the new layer
(define (layer-to-hidden-image img actL)
  (let*
    (
      (dstImg 0)(dstDsp 0)
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (list dstImg actL)
  )
)


; saves an image as a jpeg of a specified quality
(define (file-jpg-save img fileName quality)
  (let*
    (
      (exportName "")
    )

    (set! exportName (car (strbreakup fileName ".xcf")))
    (set! exportName (string-append exportName ".jpg"))

    (if debug (gimp-message (string-append " exporting : " exportName)))

    (file-jpeg-save 1
                    img
                    1 ;number of drawables to save
                    (cadr(gimp-image-get-selected-layers img))
                    exportName
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

)


; makes a directory in the "home" directory with a string "/path/like/this"
; in WindowsOS relative to "C:\Users\username"  keep using "/" to denote path
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

