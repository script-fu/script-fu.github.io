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
