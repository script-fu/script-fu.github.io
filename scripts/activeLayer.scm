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
