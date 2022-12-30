(define (reportImageTags img)
 (let*
 (
  (parasiteList 0)
  (paramCountImage 0)
  (paramListImage 0)
  (i 0)
  (currParam 0)
  (paramValue 0)
 )

 (set! parasiteList (gimp-image-get-parasite-list img))
 (set! paramCountImage (car parasiteList))
 (set! paramListImage (list->vector(car(cdr parasiteList))))

 (gimp-message (string-append " " (number->string paramCountImage)
                              " parameters on image ->" (number->string img)))

 (when (> paramCountImage 0)
  (while(< i paramCountImage)
   (set! currParam (vector-ref paramListImage i))
   (set! paramValue (caddr (car (gimp-image-get-parasite img currParam))))
   (gimp-message (string-append " image has tag --> " currParam
                                "\n with value of --> " paramValue
                                ))
   (set! i (+ i 1))
  )
 )

 (when (= paramCountImage 0)
  (gimp-message " actvie image has no tags/parasites")
 )

 )
)


(script-fu-register "reportImageTags"
 "reportImageTags"
 "reports image tags"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney"
 "2022"
 "*"
 SF-IMAGE       "Image"           		0
)
(script-fu-menu-register "reportImageTags" "<Image>/Script-Fu")
