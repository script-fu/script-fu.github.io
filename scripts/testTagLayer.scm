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
 "testTagLayer"
 "test tag layer"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 "*"
 SF-IMAGE       "Image"             0
 SF-DRAWABLE    "Drawable"          0
 SF-STRING      "layer tagged as"   "findMe"
)
(script-fu-menu-register "testTagLayer" "<Image>/Script-Fu")
