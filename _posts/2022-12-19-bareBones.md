## Basic script

*saved as bareBones.scm in a scripts folder*

```scheme
;The script procedure
(define (bareBones img drawable) ;image and layer to work on
	(let*
	    (
	    ;variables here
	    )
	
	;scripty stuff here
	
	)
);end of script procedure

;This bit tells Gimp about it, and can also create an interface
(script-fu-register "bareBones"
	"<Image>/Script-Fu/bareBones" ;menu item
	"an empty script" ;description
	"Your Name" ;author
	"copyright 2022, Your Name" ;copyright notice
	"2022" ;date
	"*";used on an image
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
```
