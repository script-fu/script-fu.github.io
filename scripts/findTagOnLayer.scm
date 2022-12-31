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
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
 )
