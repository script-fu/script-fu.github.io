(define (reportLayerTags img drawable)
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

(script-fu-register "reportLayerTags"
	"reportLayerTags"
	"read layer parasites and print to error console" ;description
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
)
(script-fu-menu-register "reportLayerTags" "<Image>/Script-Fu")
