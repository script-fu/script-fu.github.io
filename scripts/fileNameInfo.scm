(define (fileNameInfo img)
 (let*
 (
  (fileName 0)
  (fileBase 0)
  (filePath 0)
  (returnInfo (make-vector 3 ""))
  (strippedfileName 0)
 )

 (when (not(equal? (car(gimp-image-get-filename img)) ""))
  (gimp-message " file has a name ")
  (set! fileName (car(gimp-image-get-filename img)))
  (set! fileBase (car (reverse (strbreakup fileName "/"))))
  (set! filePath (unbreakupstr (reverse (cdr (reverse
                 (strbreakup fileName "/")))) "/"))

  (set! strippedfileName (car (strbreakup fileBase ".")))

  (vector-set! returnInfo 0 fileBase)
  (vector-set! returnInfo 1 strippedfileName)
  (vector-set! returnInfo 2 filePath)
 )

 (when (equal? (car(gimp-image-get-filename img)) "")
  (gimp-message " file has no name ")
  (vector-set! returnInfo 0 "file not named")
  (vector-set! returnInfo 1 "file not named")
  (vector-set! returnInfo 2 "file not saved")
 )

 returnInfo
 )
)

(script-fu-register "fileNameInfo"
 ""
 "find file name and path" ;description
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
)
