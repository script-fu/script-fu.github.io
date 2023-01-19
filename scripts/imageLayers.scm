
(define (imageLayers img)
 (let*
 (
  (returnedLayerList ())
 )

 (set! returnedLayerList (layerScan img 0))
 (map (lambda (x) (gimp-message (string-append "found layer ->  "
  (car (gimp-item-get-name x))))) returnedLayerList)

 )
)

(script-fu-register "imageLayers"
 "imageLayers"
 "prints all the layers and folders to the error console"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
)
(script-fu-menu-register "imageLayers" "<Image>/Script-Fu")
