(define (findLayer img name)
(let*
	(
	(matchedLayer 0)
	(matchName 0)
	(returnList 0)
	(layerCount 0)
	(returnLayerList 0)
	(i 0)
	)

	(set! returnList (layerScan img 0 0))
	(when (> (car returnList) 0)
	(set! layerCount (car returnList))
	(set! returnLayerList (car(cdr returnList)))
	)

	(while (< i layerCount)
	(set! matchName (car(gimp-item-get-name (vector-ref returnLayerList i))))
	(when (equal? name matchName)
	(set! matchedLayer (vector-ref returnLayerList i))
	(set! i layerCount)
	(gimp-message (string-append " found layer -> " name " : ID = " (number->string matchedLayer)))
	)
	(set! i (+ i 1))
	)

	(when (= matchedLayer 0)
	(gimp-message (string-append "* not found layer --> " name))
	)

	matchedLayer
	)
)


(script-fu-register "findLayer"
"<Image>/Script-Fu/findLayer"
"finds a layer by it's name, returns its ID"
"Mark Sweeney"
"copyright 2022, Mark Sweeney"
"2020"
"*"
SF-IMAGE       "Image"           		0
SF-STRING      "Layer to Find" "findMe"
)
