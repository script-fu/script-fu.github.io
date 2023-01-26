(define (copyToLayer img sourceLayer targetLayer)
 (let*
 (
  (returnLayer 0)
  (floatingSelection 0)
  (name 0)
 )
 (set! name (car (gimp-item-get-name targetLayer)))
 (gimp-edit-copy sourceLayer)
 (set! floatingSelection (car (gimp-edit-paste targetLayer 1)))
 (gimp-floating-sel-anchor floatingSelection)
 (set! returnLayer  (car (gimp-image-get-active-drawable img)))
 (gimp-item-set-name returnLayer name)
 returnLayer
 )
)

(script-fu-register "copyToLayer"
 ""
 "copy an existing layer to another layer in the same image"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
