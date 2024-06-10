## Get Image Filename Information

# * Tested in GIMP 2.99.14 *

A demonstration plugin that shows how you can find an image file's name and path.
  
The plug-in should appear in a Plugin menu.  
  
To download [**get-image-file-info.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/get-image-file-info/get-image-file-info.scm)  
...follow the link, right click the page, Save as get-image-file-info.scm, in a folder called get-image-file-info, in a GIMP plug-ins location.  In Linux, set the file to be executable.
   

<!-- include-plugin "get-image-file-info" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-get-image-file-info img drwbls)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(strL "")(fileInfo 0)
    )

    (set! fileInfo (get-image-file-info img))
    (set! fNme (vector-ref fileInfo 0))
    (set! fBse (vector-ref fileInfo 1))
    (set! fwEx (vector-ref fileInfo 2))
    (set! fPth (vector-ref fileInfo 3))

    (set! strL (string-append " file name -> " fNme "\n file base -> " fBse
                              "\n name no extension-> " fwEx 
                              "\n file path -> " fPth
                )
    )

    (gimp-message strL)
  )
)


(script-fu-register-filter "script-fu-get-image-file-info"
 "Get Image File Info"
 "Prints out file name information, demonstration plug-in"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-get-image-file-info" "<Image>/Plugin")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message (string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; finds the full file name, base name, stripped name, and path of a given image
; returns a vector list ("/here/myfile.xcf" "myfile.xcf" "myfile" "/here")
(define (get-image-file-info img)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(usr "")(strL "")
      (brkTok DIR-SEPARATOR)
    )

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

    (vector fNme fBse fwEx fPth)
  )
)

```
