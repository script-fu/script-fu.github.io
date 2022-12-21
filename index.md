### Quickstart in Script-Fu

First create a local directory as a sandbox for new scripts. Add that directory in Gimp as a Scripts folder.
*Gimp->Edit->Preferences->Folders->Scripts (add new folder).*

Restart Gimp, any scripts in that new folder should appear as menu items
or useable procedures. 

After editing and saving a script I press the "#" key in Gimp, 
which can be set as a keyboard shortcut to refresh scripts.
\
*Gimp->Edit->Keyboard Shortcuts (Refresh Scripts)*

I keep the Error Console window open. It's the only way I've been able to find to debug a script.\
*Gimp->Windows->Dockable Dialogues->Error Console*

Check out the Procedure Browser.
\
*Gimp->Help->Procedure Browser*

https://docs.gimp.org/en/gimp-concepts-script-fu.html

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
	"Mark Sweeney" ;author
	"copyright 2022, Mark Sweeney" ;copyright notice
	"2022" ;date
	"*";used on an image
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
```
