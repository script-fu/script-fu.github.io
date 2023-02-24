## Layers in an image - Script for Gimp 2

It's often essential to get a list of the layers in an image.

This procedure recursively scans through all the layers, building a list,
which it then returns.

```scheme
(define (layerScan img activeFolder)
(let*
 (
 (layerCount 0)
 (getChildren 0)
 (layerList 0)
 (i 0)
 (layer 0)
 (allLayerList ())
 )

 (if (= activeFolder 0)
  (set! getChildren (gimp-image-get-layers img));if true
  (if (equal? (car (gimp-item-is-group activeFolder)) TRUE); if false
   (set! getChildren (gimp-item-get-children activeFolder)) ;if true
   (set! getChildren (list 1 (list->vector (list activeFolder))));if false
  )
 )

 (set! layerCount (car getChildren))
 (set! layerList (cadr getChildren))

 (while (< i layerCount)
  (set! layer (vector-ref layerList i))
  (set! allLayerList (append allLayerList (list layer)))

  (when (equal? (car (gimp-item-is-group layer)) FALSE)
   ;do something to the layer
  )

  (when (equal? (car (gimp-item-is-group layer)) TRUE)
   ;do something to the folder

   (set! allLayerList (append allLayerList (layerScan img layer))) ;recursive
  )

 (set! i (+ i 1))
 )

 allLayerList
 )
)


(script-fu-register "layerScan"
 "layerScan"
 "finds all the layers in the image, or all the layers in a folder"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)

```

This menu item also use the scheme procedure *(map function list)*
Map takes a list and performs the function on every element in that list.
In this case that function prints out a message to the error console.

The function is neatly wrapped up by *(lambda (x) (commands on x))*

*The menu item that calls the scan and prints out all the layers and folders to the error console*

```scheme
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

```
