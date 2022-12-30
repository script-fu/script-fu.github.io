
(define (reportFileInfo img)
(let*
 (
  (activeImageInfo 0)
  (fileName 0)
  (fileNameShort 0)
  (filePath 0)
 )

 (set! activeImageInfo (fileNameInfo img))
 (set! fileName (vector-ref activeImageInfo 0))
 (set! fileNameShort (vector-ref activeImageInfo 1))
 (set! filePath (vector-ref activeImageInfo 2))

 (gimp-message (string-append "  file -> " fileName
                              "\n  stripped -> " fileNameShort
                              "\n  path -> " filePath
                              ))
 )
)

(script-fu-register "reportFileInfo"
 "reportFileInfo"
 "prints the active file info to the error console"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
)
(script-fu-menu-register "reportFileInfo" "<Image>/Script-Fu")
