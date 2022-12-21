;These scripts are free software: you can redistribute it and/or modify it under
;the terms of the GNU General Public License as published by the Free Software
;Foundation;

;This program is distributed in the hope that it will be useful, but WITHOUT ANY
;WARRANTY without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
;PARTICULAR PURPOSE. See the GNU General Public License for more details.

(define (smartScale img layer pixels scaleX scaleY allLayers interpolation)
	(let*
		(
			(imgWidth (car (gimp-image-width img)))
			(imgHeight (car (gimp-image-height img)))
			(layerWidth (car (gimp-drawable-width layer)))
			(layerHeight (car (gimp-drawable-height layer)))
		)

	(gimp-context-set-interpolation interpolation) ;interpolation method

	(if(= pixels 1) ; if pixels and all layers then do scale to pixel size
		(if(= allLayers 1)
		(gimp-image-scale img scaleX scaleY)
		)
	 )

	(if(= pixels 0) ; not pixels and all layers then do relative scale
		(if(= allLayers 1)
		(gimp-image-scale img (* scaleX imgWidth) (* scaleY imgHeight))
		)
	 )

	(if(= pixels 1) ; if pixels and single layer then do scale to pixel size
		(if(= allLayers 0)
		(gimp-layer-scale layer scaleX scaleY TRUE)
		)
	 )

	(if(= pixels 0) ;if pixels and single layer then do relative scale
		(if(= allLayers 0)
		(gimp-layer-scale layer (* scaleX layerWidth) (* scaleY layerHeight) TRUE)
		)
	 )

	)
)

(script-fu-register "smartScale"
	""
	"scale an image or layer by pixels or percent by interpolation method"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
