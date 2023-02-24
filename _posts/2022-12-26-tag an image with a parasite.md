## Tag an image with a parasite - Script for Gimp 2

*A function to tag an image with a parasite*

Sounds horrible, but is useful.  Let's you tag an image so that you can
find it easily again. The tag is saved with the image as a parasite.


```scheme
(define (testTagImage img tag)
 (let*
 (
  (tagValue "42")
 )

 (gimp-image-attach-parasite img (list tag 1 tagValue))
 (gimp-message (string-append " attached tag --> " tag))
 )
)


(script-fu-register "testTagImage"
 "testTagImage"
 "test tag image"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
SF-IMAGE       "Image"             0
SF-STRING      "image tagged as"   "findMe"
)
(script-fu-menu-register "testTagImage" "<Image>/Script-Fu")
```

*The menu item that finds the image again*

```scheme
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
  "\n id -> " (number->string foundImage))))

 foundImage
 )
)

(script-fu-register "findImageTagged"
 "testFindImageTagged"
 "finds image tagged with the tag name and returns it's ID"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
 SF-STRING      "find image tagged with"   "findMe"
)
(script-fu-menu-register "findImageTagged" "<Image>/Script-Fu")

```

*The menu item that reports what parasites are on the active image*

```scheme
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
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"           		0
)
(script-fu-menu-register "reportImageTags" "<Image>/Script-Fu")

```
