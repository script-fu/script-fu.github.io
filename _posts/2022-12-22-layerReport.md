## active layer information

*This procedure gathers some active layer information and returns it in an array*

```scheme
(define (activeLayer img drawable)
(let*
 (
 (drawableMask 0)
 (drawableName "")
 (returnActive 0)
 )

 (when(=(car (gimp-item-is-layer-mask drawable)) 0)
   (when(> (car (gimp-layer-get-mask drawable)) 0)
		(set! drawableMask (car (gimp-layer-get-mask drawable)))
    )
   (set! drawableName (car(gimp-item-get-name drawable)))
   )

   (when(= (car (gimp-item-is-layer-mask drawable)) 1)
   (set! drawableMask drawable)
   (set! drawable (car(gimp-layer-from-mask drawableMask)))
   (set! drawableName (car(gimp-item-get-name drawable))) 
   )

  (set! returnActive (make-vector 3 'double))
  (vector-set! returnActive 0 drawable)
  (vector-set! returnActive 1 drawableMask)
  (vector-set! returnActive 2 drawableName)

  returnActive
  )
 )

(script-fu-register "activeLayer"
	""
	"returns the active layer, mask and layer name"
  "Mark Sweeney"
  "copyright 2022, Mark Sweeney"
  "2022"
  "*"
  SF-IMAGE       "Image"           		0
  SF-DRAWABLE    "Drawable"        		0
  )
```

*In this menu function, it's being used to provide layer information for printing using (gimp-message) and the error console window*
```scheme

(define (reportActiveLayer img drawable) 
(let*
	(
	(parent 0)
	(position 0)
	(drawableMask 0)
	(drawableName "")
	(activeLayerAndMask 0)
	(parentName "layer has no parent")
	)
	
	(set! activeLayerAndMask (activeLayer img drawable))
	(set! drawable  (vector-ref activeLayerAndMask 0))
	(set! drawableMask (vector-ref activeLayerAndMask 1))
	(set! drawableName (vector-ref activeLayerAndMask 2))
	(set! parent (car (gimp-item-get-parent drawable)))
	(set! position (car (gimp-image-get-item-position img drawable)))
	(if (> parent 0) (set! parentName (car (gimp-item-get-name parent))))
	
	(gimp-message (string-append "  layer ID -> " (number->string drawable)
	"\n  mask -> " (number->string drawableMask)
	"\n  name -> " drawableName
	"\n  tree position -> " (number->string position)
	"\n  parent name -> "  parentName
	
	))
 )
)
	
(script-fu-register "reportActiveLayer"
"<Image>/Script-Fu/reportActiveLayer"
"prints the active layer to the error console"
"Mark Sweeney"
"copyright 2022, Mark Sweeney"
"2022"
"*"
SF-IMAGE       "Image"           		0
SF-DRAWABLE    "Drawable"        		0
)

```



