## Find All Layers

# * Tested in Gimp 2.99.14 *

This isn't a plug-in, just an example of how to find all those nested layers.

*Returns a list of all the layers in an image, or all layers below a given folder*

```scheme
(define (layerScan img rootFolder) ; recursive function
  (let*
    (
      (getChildren 0)(layerList 0)(i 0)(layer 0)(allLayerList ())
    )

    (if (= rootFolder 0)
      (set! getChildren (gimp-image-get-layers img))
      (if (equal? (car (gimp-item-is-group rootFolder)) 1)
        (set! getChildren (gimp-item-get-children rootFolder))
        (set! getChildren (list 1 (list->vector (list rootFolder))))
      )
    )

    (set! layerList (cadr getChildren))
    (while (< i (car getChildren))
      (set! layer (vector-ref layerList i))
      (set! allLayerList (append allLayerList (list layer)))
      (if (equal? (car (gimp-item-is-group layer)) 1)
        (set! allLayerList (append allLayerList (layerScan img layer)))
      )
      (set! i (+ i 1))
    )

    allLayerList
  )
)

```