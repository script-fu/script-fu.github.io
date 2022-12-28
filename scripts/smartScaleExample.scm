(define (smartScaleExample img drawable)
	(let*
		(
		(scale 0.5)
		(mode 4)
		(pixels 0)
		(allLayers 1)
		)

    (gimp-image-undo-group-start img)
	  (smartScale img drawable pixels scale scale allLayers mode)
	  (gimp-displays-flush)
		(gimp-image-undo-group-end img)

	)
)

(script-fu-register "smartScaleExample"
	"smartScaleExample"
	"use the smartScale procedure"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
(script-fu-menu-register "smartScaleExample" "<Image>/Script-Fu")
