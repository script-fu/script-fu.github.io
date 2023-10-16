## Set the Foreground to White

# * Tested in GIMP 2.99.17 *

Does the same as set default colors, but the foreground is set to white and the 
background is set to black. Then you can have a shortcut key to set white as the foreground.
It's not registered in the menu, you can find it by searching in keyboard shortcuts for
'set-foreground-white'.

To download [**set-foreground-white.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/set-foreground-white/set-foreground-white.scm)  
...follow the link, right click the page, Save as set-foreground-white.scm, in a folder called set-foreground-white, in a GIMP plug-ins location.  
In Linux, set the file to be executable.
   
<!-- include-plugin "set-foreground-white" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-set-foreground-white)
  (gimp-context-set-foreground (list 255 255 255))
  (gimp-context-set-background (list 0 0 0))
)

(script-fu-register "script-fu-set-foreground-white"
 "set-foreground-white"
 "Sets the foreground color to white, the background to black"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
 )

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3
```
