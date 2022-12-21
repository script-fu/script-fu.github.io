;These scripts are free software: you can redistribute it and/or modify it under
;the terms of the GNU General Public License as published by the Free Software
;Foundation;

;This program is distributed in the hope that it will be useful, but WITHOUT ANY
;WARRANTY without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
;PARTICULAR PURPOSE. See the GNU General Public License for more details.

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
	"<Image>/Script-Fu/smartScaleExample"
	"use the smartScale procedure"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
