#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Works best if the following preference is set 1:1
; Edit->Preferences->Image Windows->initial zoom ratio 1:1
; Otherwise ensure image is set to 100% zoom, keyboard "1"

(define (script-fu-monitor-scale img drawables)
  (let*
    (
      (dpiX (car(gimp-image-get-resolution img))) 
      (dpiY (cadr(gimp-image-get-resolution img)))
      (scaleX (/ (car(gimp-get-monitor-resolution)) dpiX))
      (scaleY (/ (cadr(gimp-get-monitor-resolution)) dpiY))
      (dstImg 0)
      (origW (car (gimp-image-get-width img)))
      (width (* scaleX origW))
      (origH (car (gimp-image-get-height img)))
      (height (* scaleY origH))
    )

    (gimp-edit-copy-visible img)
    (set! dstImg (car(gimp-edit-paste-as-new-image)))
    (gimp-image-scale dstImg width height)
    (gimp-image-set-file dstImg (string-append "*** Display DPI is "
                                        (number->string (trunc 
                                        (car(gimp-get-monitor-resolution))))
                                        ":  If printed at " 
                                        (number->string (trunc dpiX)) " DPI"
                                        " and if the zoom is at 100% "
                                        " the image should look this size on "
                                        " paper ***   "
                                )
    )
    (gimp-display-new dstImg)
    (gimp-image-clean-all dstImg)

  )
)


(script-fu-register-filter "script-fu-monitor-scale"
 "Monitor Scale" 
 "Creates a new image showing how big the printed image would look on paper"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-monitor-scale" "<Image>/View")
