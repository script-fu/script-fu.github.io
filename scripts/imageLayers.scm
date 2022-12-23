
(define (imageLayers img)
	(let*
		(
		(layerCount 0)
		(returnList 0)
		(returnLayerList 0)
    (i 0)
		(ignoreFolders 1)
		(includeFolders 0)
		)

	 (set! returnList (layerScan img 0 includeFolders))

	 (when (> (car returnList) 0)
	  (set! layerCount (car returnList))
	  (set! returnLayerList (car(cdr returnList)))
	 )

   (while (< i layerCount)
	  (gimp-message (string-append " layer #" (number->string (+ i 1))
			                           " \n ID --> " (number->string (vector-ref returnLayerList i))
                                 " \n name --> " (car (gimp-item-get-name (vector-ref returnLayerList i)))
																 " \n"
																	 ))
 	  (set! i (+ i 1))
   )

  )
)


(script-fu-register "imageLayers"
	"<Image>/Script-Fu/imageLayers"
	"prints all the layers and folders to the error console"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
)
