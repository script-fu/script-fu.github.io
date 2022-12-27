(define (findLayersTagged img tag)
(let*
	(
	(layerList (make-vector 999 'integer))
	(parasiteListCount 0)
	(parasiteCount 0)
	(parasiteName "")
	(finalList 0)
	(layer 0)
	(parameters 0)
	(paramCount 0)
	(paramList 0)
	(currParam 0)
	(paramValue 0)
	(i 0)
	(j 0)
	(returnList 0)
	(layerCount 0)
	(returnLayerList 0)
	(testlayerCount 0)
	(testReturnLayerList 0)
	(currentLayer 0)
	(currentLayerName 0)
	)

	(set! returnList (layerScan img 0 0))
	(set! layerCount (car returnList))
	(set! returnLayerList (car(cdr returnList)))

	(set! i 0)
	(while (< i layerCount)
	(set! layer (vector-ref returnLayerList i))
	(set! paramCount (car(gimp-item-get-parasite-list layer)))

	(when (> paramCount 0)
	(set! parameters (gimp-item-get-parasite-list layer))
	(set! paramCount (car parameters))
	(set! paramList (list->vector(car(cdr parameters))))

	(set! j 0)
	(while(< j paramCount)
	(set! currParam (vector-ref paramList j))
	(set! paramValue (caddr (car (gimp-item-get-parasite layer currParam)))) ; recover data

		(when (equal? currParam tag)
		;(gimp-message (string-append "  layer -> "  (number->string layer) " has tag -> " tag))
		(vector-set! layerList parasiteCount layer)
		(set! parasiteCount (+ parasiteCount 1))
		)
		(set! j (+ j 1))
	)
	)
	(set! i (+ i 1))
	)

	(set! finalList (make-vector parasiteCount 'integer))

	(set! i 0)
	(while (< i parasiteCount)
	(vector-set! finalList i (vector-ref layerList i))

	(set! i (+ i 1))
	)

	(set! returnList (list parasiteCount finalList))

  ; ********* demonstrates how to read from the returned list
	(set! testlayerCount (car returnList))
	(set! testReturnLayerList (car(cdr returnList)))
	(if(= testlayerCount 0) (gimp-message " * no layers found matching search tag *"))

	(when (> testlayerCount 0)

		(set! i 0)
		(while (< i testlayerCount)
		(set! currentLayer (vector-ref testReturnLayerList i))
		(set! currentLayerName (car(gimp-item-get-name currentLayer)))
    (gimp-message (string-append " layer named " currentLayerName " has tag " tag))
		;do scripty stuff to layer here
		(set! i (+ i 1))
		)
	)
  ; *********

	returnList
 )
)


(script-fu-register "findLayersTagged"
	"<Image>/Script-Fu/findLayersTagged"
	"returns a list of tagged layers" ;description
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2020"
	"*"
	SF-IMAGE       "Image"           		0
	SF-STRING      "Tag to Find" "storeLayer"
)
