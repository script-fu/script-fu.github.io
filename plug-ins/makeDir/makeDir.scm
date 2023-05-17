#!/usr/bin/env gimp-script-fu-interpreter-3.0

; makes a directory relative to "home/username"  path format /my/new/directory
; in WindowsOS relative to "C:\Users\username"  keep using "/" to denote path
(define (makeDir path)
  (let*
    (
      (brkP 0) (i 2) (pDepth 0) (dirMake "")
    )

    (set! brkP (strbreakup path "/"))
    (set! pDepth  (length brkP))
    (set! dirMake (list-ref brkP 1)) ; skip empty element
    (dir-make dirMake) ; make root

    (while (< i pDepth)
      (set! dirMake (string-append dirMake "/" (list-ref brkP i)))     
      (set! i (+ i 1))
      (dir-make dirMake) ; make tree
    )
  )
)

(script-fu-register "makeDir"
 "makeDir"
 "makes a directory relative to \"home/username\", use forward slashes" 
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
 SF-STRING      "path"   "/my/new/directory"
)

(script-fu-menu-register "makeDir" "<Image>/Fu-Plugin")





