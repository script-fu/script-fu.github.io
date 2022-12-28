(define (fileNameInfo img)
(let*
	(
	(fileName 0)
	(fileBase 0)
	(filePath 0)
	(returnInfo (make-vector 3 ""))
	(strippedfileName 0)
	)

	(set! fileName (car(gimp-image-get-filename img)))
	(set! fileBase (car (reverse (strbreakup fileName "/"))))
	(set! filePath (unbreakupstr (reverse (cdr (reverse (strbreakup fileName "/")))) "/"))
	(set! strippedfileName (car (strbreakup fileBase ".")))

	(vector-set! returnInfo 0 fileBase)
	(vector-set! returnInfo 1 strippedfileName)
	(vector-set! returnInfo 2 filePath)

	returnInfo
	)
	)

	(script-fu-register "fileNameInfo"
	""
	"find file name and path" ;description
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	)