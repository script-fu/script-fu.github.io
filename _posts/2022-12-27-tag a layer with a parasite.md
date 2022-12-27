## tag a layer with a parasite

*A function to tag a layer with a parasite*

```scheme
(define (tagLayer layer name tagValue colour)
(let*
  (
  )

  (when(= (car (gimp-item-is-layer-mask layer)) 1)
    (set! layer (car(gimp-layer-from-mask layer)))
    )

    (gimp-item-attach-parasite layer (list name 1 tagValue))
    (gimp-item-set-color-tag layer colour)
    (gimp-message (string-append " tagLayer -> " (car(gimp-item-get-name layer))))
  )
)

(script-fu-register "tagLayer"
  ""
  "tag layer with parasite data and set colour" ;description
  "Mark Sweeney"
  "copyright 2022, Mark Sweeney"
  "2022"
  ""
  SF-STRING      "layer tagged as"   "findMe"
)
```

*The menu item that uses the tagLayer function*

```scheme
(define (testTagLayer img layer tag)
(let*
	(
	(tagValue "42")
	(colour 0)
	)
  (tagLayer layer tag tagValue colour)
	)
	)


(script-fu-register "testTagLayer"
	"<Image>/Script-Fu/testTagLayer"
	"test tag layer"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
	SF-STRING      "layer tagged as"   "findMe"
)
```

*The menu item that reports what parasites are on the active layer*

```scheme
(define (sweeney_reportLayerTags img drawable)
(let*
	(
	(i 0)
	(parameters 0)
	(paramCount 0)
	(paramList 0)
	(currParam 0)
	(paramValue 0)
	)

	(set! parameters (gimp-item-get-parasite-list drawable))
	(set! paramCount (car parameters))
	(set! paramList (list->vector(car(cdr parameters))))

	(if (= paramCount 0)(gimp-message " no parameters stored on item "))

	(when (> paramCount 0)
	(gimp-message (string-append "  " (number->string paramCount) " parameters on layer --> " (car(gimp-item-get-name drawable))))

	(set! i 0)
	(while(< i paramCount)
	(set! currParam (vector-ref paramList i))
	(set! paramValue (caddr (car (gimp-item-get-parasite drawable currParam)))) ; recover data

		(gimp-message (string-append currParam " --> " paramValue))

		(set! i (+ i 1))
		)
	)

	)
)

(script-fu-register "sweeney_reportLayerTags"
	"<Image>/Script-Fu/reportLayerTags"
	"read layer parasites and print to error console" ;description
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
```

*The menu item that removes a specified tag*
```scheme
(define (removeTag img drawable name)
(let*
  (
  (activeLayer drawable)
  (layerName 0)
  (parasiteExists 0)
  (mask 0)
  )

  (set! layerName (car(gimp-item-get-name drawable)))
  (set! parasiteExists (findTagOnLayer drawable name))

  (when (> parasiteExists 0)
  (gimp-message (string-append " removing tag --> " name))
  (gimp-item-detach-parasite activeLayer name)
  (gimp-item-set-color-tag activeLayer 0)
  )

  (when (= parasiteExists 0)
  (gimp-message (string-append " tag --> " name " <-- not found on layer --> " layerName))
  )

  )
  )


(script-fu-register "removeTag"
  "<Image>/Script-Fu/removeLayerTag"
  "remove tag parasite data" ;description
  "Mark Sweeney"
  "copyright 2022, Mark Sweeney"
  "2022"
  "*"
  SF-IMAGE       "Image"           		0
  SF-DRAWABLE    "Drawable"        		0
  SF-STRING      " remove layer tag "   "findMe"
)
```

*This procedure returns a list of all layers with a specific tag*
```scheme
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
```

*This procedure finds if a layer has a specific tag*
```scheme
(define (findTagOnLayer drawable tag)
(let*
	(
	(i 0)
	(name "")
	(valid 0)
	(strLength 0)
	(parametersItem 0)
	(paramCountItem 0)
	(paramListItem 0)
	(currParam "")
	(paramValue "")
	(foundItem 0)
	)

	(set! parametersItem (gimp-item-get-parasite-list drawable))
	(set! paramCountItem (car parametersItem))
	(set! paramListItem (list->vector(car(cdr parametersItem))))

	(when (> paramCountItem 0)
	(while(< i paramCountItem)
	(set! currParam (vector-ref paramListItem i))
	(set! paramValue (caddr (car (gimp-item-get-parasite drawable currParam))))
		(when (equal? tag currParam)
		(set! foundItem 1)
		(set! i paramCountItem)
		)
		(set! i (+ i 1))
		)
		)

		foundItem
	)
)

(script-fu-register "findTagOnLayer"
	""
	"finds if current layer has a named tag, returns 0 or 1"
	"Mark Sweeney"
  "copyright 2022, Mark Sweeney"
  "2022"
  ""
	)
```
