## basic script

*saved as bareBones.scm in a scripts folder*

```scheme
;The script procedure
(define (bareBones img drawable) ; image and layer to work on
	(let*
	 (
	 ;variables
	 ;(i 0)
	 )
	 ;*************
	 ;scripty stuff here
	 ;*************
	) ;end of let*
);end of script procedure


;This bit tells Gimp about it and can also create an interface
(script-fu-register "bareBones" ;script registered as this name
	"justTheBones" ;just the name of menu item as it appears
	"does nothing" ;description - tooltip of menu item
	"textHere" ;author
	"textHere" ;copyright notice
	"textHere" ;date
	"*"; * indictates this is script that operates on an image
	SF-IMAGE       "Image"           		0    ;pass the active image
	SF-DRAWABLE    "Drawable"        		0    ;pass the active drawable
)
;***** Gimp 3.0 menu item register method, if a menu item is needed *****
;(script-fu-menu-register "bareBones" "<Image>/Script-Fu")
```
