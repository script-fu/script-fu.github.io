## Image Add Parasite

# * Tested in GIMP 2.99.14 *

This plug-in adds a parasite to an image, a useful way to allow another plug-in 
to find a particular image. The plug-in should appear in the Image/Tag menu.  
  
To download [**image-set-parasite.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/image-set-parasite/image-set-parasite.scm)  
...follow the link, right click the page, Save as image-set-parasite.scm, in a folder called image-set-parasite, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   
   
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment

(define (script-fu-image-set-parasite img lst name mode tagV)

  (tag-image img name mode tagV)
  (gimp-message (string-append " added image parasite : " name))

)


(define (tag-image img name mode tagV)
  (gimp-image-attach-parasite img (list name mode tagV))
)


(script-fu-register-filter "script-fu-image-set-parasite"
 "Image Add Parasite" 
 "Attaches a specific parasite to the active image"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
 SF-STRING      "parasite name"   "ink"
 SF-ADJUSTMENT  "attach mode 0-3 " (list 3 0 6 1 1 0 SF-SPINNER)
 SF-STRING      "parasite data"   "ink source"
)
(script-fu-menu-register "script-fu-image-set-parasite" "<Image>/Image/Tag")
```