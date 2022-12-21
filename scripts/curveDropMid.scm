;These scripts are free software: you can redistribute it and/or modify it under 
;the terms of the GNU General Public License as published by the Free Software 
;Foundation;

;This program is distributed in the hope that it will be useful, but WITHOUT ANY 
;WARRANTY without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
;PARTICULAR PURPOSE. See the GNU General Public License for more details.

(define (curveDropMid img drawable)
	(let*
	()
	(curve3Value img drawable 0 0 160 65 255 255)
	(gimp-displays-flush) 
	)
)

(script-fu-register "curveDropMid"
	"<Image>/Script-Fu/curveDropMid"
	"apply a specific curve to the image intensity levels"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
