## Paper Scale

# * Tested in GIMP 2.99.14 *

This plug-in creates temporary image that approximates how big the original
would appear on paper if it was printed out. For example if your monitor was at
100 DPI, and you printed at 300 DPI, then the printed image would look a third
the size it does on screen. Good for getting peek at the final scale.  
  
The plug-in should appear at the bottom of the Image menu.  
  
Works best if the following preference is set 1:1  
*Edit->Preferences->Image Windows->initial zoom ratio 1:1*  
Otherwise ensure image is set to 100% zoom or press keyboard "1" to make it so.

To download [**paper-scale.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/paper-scale/paper-scale.scm)
  
...follow the link, right click the page, Save as paper-scale.scm, in a folder called paper-scale, in a GIMP plug-ins location.  In Linux, set the file to be executable.


*Creates a new image showing how big the printed image would look on paper*

<!-- include-plugin "paper-scale" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Works best if the following preference is set 1:1
; Edit->Preferences->Image Windows->initial zoom ratio 1:1
; Otherwise ensure image is set to 100% zoom, keyboard "1"

(define debug #f)

(define (script-fu-paper-scale img drawables)
  (let*
    (
      (placeOnPaper #t)
      (dpiX (car(gimp-image-get-resolution img))) 
      (dpiY (cadr(gimp-image-get-resolution img)))
      (scaleX (/ (car(gimp-get-monitor-resolution)) dpiX))
      (scaleY (/ (cadr(gimp-get-monitor-resolution)) dpiY))
      (paperX (* scaleX (* 2480 (/ dpiX 300)))); A4 at 300DPI
      (paperY (* scaleY (* 3508 (/ dpiY 300)))); A4 at 300DPI
      (dstImg 0)(dstL 0)
      (origW (car (gimp-image-get-width img)))
      (width (* scaleX origW))
      (origH (car (gimp-image-get-height img)))
      (height (* scaleY origH))
    )

    (gimp-context-push)
    (gimp-edit-copy-visible img)
    (set! dstImg (car(gimp-edit-paste-as-new-image)))

    (gimp-image-scale dstImg width height)

    (when placeOnPaper
      (gimp-image-resize dstImg paperX paperY (/ (- paperX width) 2)
                                            (/ (- paperY height) 4)
      )
      (gimp-context-set-background (list 225 225 225))
      (gimp-image-flatten dstImg)
    )
    (set! dstL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name dstL "paper-scaled")
    (gimp-layer-set-composite-space dstL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (gimp-display-new dstImg)

    (gimp-image-set-file dstImg (string-append "*** Display DPI is "
                                        (number->string (trunc 
                                        (car(gimp-get-monitor-resolution))))
                                        ":  If printed at " 
                                        (number->string (trunc dpiX)) " DPI"
                                        " and if the display zoom is at 100% "
                                        " the image should look this size on "
                                        " paper ***   " ".xcf"
                                )
    )

    (gimp-image-clean-all dstImg)
    (gimp-context-pop)

  )
)


(script-fu-register-filter "script-fu-paper-scale"
 "Paper Scale" 
 "Creates a new image showing how big the printed image would look on paper"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-paper-scale" "<Image>/Image")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))

```
