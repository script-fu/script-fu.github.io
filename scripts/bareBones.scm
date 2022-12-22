
;The script procedure
(define (bareBones img drawable) ; image and layer to work on
	(let*
		(
	  ;variables
		)
	;scripty stuff
	)
);end of script procedure

;This bit tells Gimp about it, registering, and can also create an interface
(script-fu-register "bareBones"
	"" ;menu item
	"" ;description
	"" ;author
	"" ;copyright notice
	"" ;date
	"*";used on an image
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
