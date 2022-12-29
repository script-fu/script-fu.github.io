(define (boundingBox img drawable expand)
	(let*
		(
			(points 0)
			(drawableName 0)
			(maskSelection 0)
			(layerWidth 0)
			(layerHeight 0)
			(layerOffsetWidth 0)
			(layerOffsetHeight 0)
			(isMask 0)
			(isAlpha 0)
			(isSelection 0)
		 )

		(when (= (car(gimp-selection-is-empty img)) 0)
 			(gimp-message (string-append " There is an active selection to bounding box"))
			(set! isSelection 1)
 		)

		(when (= isSelection 0)
			(set! drawableName (car(gimp-item-get-name drawable)))

			(when (= (car (gimp-item-is-layer-mask drawable)) 1)
				(gimp-message (string-append " boxing -> " drawableName))
				(set! isMask 1)
				)

			(when (= (car (gimp-item-is-layer-mask drawable)) 0)
				(set! isAlpha (car (gimp-drawable-has-alpha drawable)))
			)

			(when (= isAlpha 0)
				(when (= isMask 0)
					(gimp-message (string-append " no alpha channel on layer -> " drawableName))
					(when (> (car (gimp-layer-get-mask drawable)) 0)
						(gimp-message (string-append " using mask of layer -> " drawableName))
						(set! drawable (car (gimp-layer-get-mask drawable)))
					)
				)
			)

			(when (= isAlpha 1)
				(if (= isMask 0)(gimp-message (string-append " boxing alpha of layer -> " drawableName)))
			)
		)

		(when (= isSelection 0)
			(set! layerOffsetWidth (car (gimp-drawable-offsets drawable)))
			(set! layerOffsetHeight (car (cdr (gimp-drawable-offsets drawable))))
			(set! layerWidth (car (gimp-drawable-width drawable)))
			(set! layerHeight (car (gimp-drawable-height drawable)))
			(set! maskSelection (gimp-image-select-item img CHANNEL-OP-REPLACE drawable))
		)

		(set! points (make-vector 4 'double))
		(vector-set! points 0 (car(cdr(gimp-selection-bounds img))))
		(vector-set! points 1 (car(cdr(cdr(gimp-selection-bounds img)))))
		(vector-set! points 2 (car(cdr(cdr(cdr(gimp-selection-bounds img))))))
		(vector-set! points 3 (car(cdr(cdr(cdr(cdr(gimp-selection-bounds img)))))))

		(vector-set! points 0 (- (vector-ref points 0) expand))
		(vector-set! points 1 (- (vector-ref points 1) expand))
		(vector-set! points 2 (+ (vector-ref points 2) expand))
		(vector-set! points 3 (+ (vector-ref points 3) expand))

		(gimp-image-select-rectangle img
																	2
																	(vector-ref points 0)
																	(vector-ref points 1)
																	(- (vector-ref points 2) (vector-ref points 0))
																	(- (vector-ref points 3) (vector-ref points 1))
		)
		(gimp-displays-flush)
	 )
 )


(script-fu-register "boundingBox"
	"boundingBox"
	"convert current selection, layer alpha or layer mask to a bounding box"
	"Mark Sweeney"
	"copyright 2022, Mark Sweeney"
	"2022"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
	SF-ADJUSTMENT  "expand (in pixels)" (list 100 1 5000 1 10 0 SF-SPINNER)
 )
(script-fu-menu-register "boundingBox" "<Image>/Script-Fu")
