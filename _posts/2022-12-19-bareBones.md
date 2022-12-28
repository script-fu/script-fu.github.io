## basic script

*saved as bareBones.scm in a scripts folder*

```scheme
;The script procedure
(define (bareBones img drawable) ; image and layer to work on
	(let*
		(
	  ;variables
		)
	;scripty stuff
	)
);end of script procedure

;This bit tells Gimp about it and can also create an interface
(script-fu-register "bareBones" ;script registered as this name
	"" ;name of menu item as it appears
	"" ;description - tooltip of menu item
	"" ;author
	"" ;copyright notice
	"" ;date
	"*";used on an image
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
;Gimp 3.0 menu item register method, if a menu item is needed
;(script-fu-menu-register "bareBones" "<Image>/Script-Fu")
```
