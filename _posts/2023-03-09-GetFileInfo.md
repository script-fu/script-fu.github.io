## Get Image Filename Information

# * Tested in GIMP 2.99.14 *

A demonstration plugin that shows how you can find an image file's name and path.
  
The plug-in should appear in a Fu-Plugin menu.  
  
To download [**get-image-file-info.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/get-image-file-info/get-image-file-info.scm)  
...follow the link, right click the page, Save as get-image-file-info.scm, in a folder called get-image-file-info, in a Gimp plug-ins location.  In Linux, set the file to be executable.
   
   

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-get-image-file-info img drwbls)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(brkTok "/")(usr "")(strL "")
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS
    (if (equal? "/" brkTok)(set! usr(getenv"HOME"))(set! usr(getenv"HOMEPATH")))

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fNme (car(gimp-image-get-file img)))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth (reverse (cdr(reverse (strbreakup fNme brkTok)))))
        (set! fPth (unbreakupstr fPth brkTok))
      )

      (when (equal? (car(gimp-image-get-file img)) "")
        (set! fNme (string-append usr brkTok "Untitled.xcf"))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth usr)
      )
    )

    (set! strL (string-append " file name -> " fNme "\n file base -> " fBse
                              "\n name no extension-> " fwEx 
                              "\n file path -> " fPth
                )
    )
    (gimp-message strL)

    (vector fNme fBse fwEx fPth)
  )
)


(script-fu-register-filter "script-fu-get-image-file-info"
 "Get Image File Info"
 "Prints out file name information, demonstration plug-in"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-get-image-file-info" "<Image>/Fu-Plugin")

```