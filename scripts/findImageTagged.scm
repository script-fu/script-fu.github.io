(define (findImageTagged tag)
(let*
	(
	(allImages 0)
	(imageCount 0)
	(currImg 0)
	(i 0)
	(j 0)
	(name "")
	(valid 0)
	(strLength 0)
	(parametersImage 0)
	(paramCountImage 0)
	(paramListImage 0)
	(currParam 0)
	(paramValue 0)
	(foundImage 0)
	(imgName "")
	)

	(set! allImages (gimp-image-list))
	(set! imageCount (car allImages))

	(while (< i imageCount)
	(set! currImg (vector-ref (cadr allImages) i))
	(when (> (car (gimp-image-is-valid currImg)) 0)
	(set! parametersImage (gimp-image-get-parasite-list currImg))
	(set! paramCountImage (car parametersImage))
	(set! paramListImage (list->vector(car(cdr parametersImage))))

	(when (> paramCountImage 0)
	(set! j 0)
	(while(< j paramCountImage)
	(set! currParam (vector-ref paramListImage j))
	(set! paramValue (caddr (car (gimp-image-get-parasite currImg currParam))))

	(when (equal? tag currParam)
	(set! foundImage currImg)
	(set! j paramCountImage)
	(set! i imageCount)
	)

	(set! j (+ j 1))
	)
	)
	)
	(set! i (+ i 1))
	)

	(if(> foundImage 0)(gimp-message (string-append " found image tagged -> " tag
		"\n id -> " (number->string foundImage)
		))
		)

		foundImage
		)
		)

		(script-fu-register "findImageTagged"
		"<Image>/Script-Fu/testFindImageTagged"
		"finds image tagged with the tag name and returns it's ID"
		"Mark Sweeney"
		"copyright 2022, Mark Sweeney"
		"2022"
		""
		SF-STRING      "find image tagged with"   "findMe"
		)
