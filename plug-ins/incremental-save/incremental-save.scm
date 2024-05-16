#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-incremental-save img)
  (let*
    (
      (increments 10) ; number of incremental saves
      (fileInfo 0)(fNme "")(fBse "")(fPth "")(fwEx "")(sNme "")
      (brkTok DIR-SEPARATOR)
      (paraNme "incSave")(mode 3)(inc 1)(incStr "1")
    )
    
    ; prompt the user to save an unsaved image
    (if (equal? (car(gimp-image-get-file img)) "")
      (exit "save the file to a location before using incremental save")
    )

    ; base the save name on the existing name
    (set! fileInfo (get-image-file-info img))
    (set! fNme (vector-ref fileInfo 0))
    (set! fBse (vector-ref fileInfo 1))
    (set! fwEx (vector-ref fileInfo 2))
    (set! fPth (vector-ref fileInfo 3))

    ; if the image has not been tagged with an increment parasite, tag it
    (if (not (get-image-parasite img paraNme))
      (tag-image img paraNme mode incStr)
    )

    ; get the increment value from the parasite on the image as a string
    (set! incStr (get-image-parasite-string img paraNme))

    ; save the file
    (set! sNme (string-append fPth "/" fwEx "_saves/" fwEx "_" incStr ".xcf" ))
    (if debug (gimp-message(string-append" >>> "sNme)))

    ; convert the string number to a integer and increment
    (set! inc (string->number incStr))
    (set! inc (+ inc 1))
    (if (> inc increments) (set! inc 1))

    ; tag the image with the new increment
    (set! incStr (number->string inc))
    (tag-image img paraNme mode incStr)

    ; save the file
    (make-dir-path (string-append "/" fPth "/" fwEx "_saves"))
    (gimp-xcf-save 0 img sNme)
  )
)

(script-fu-register "script-fu-incremental-save"
 "Incremental Save" 
 "Saves the file incrementally" 
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2024"
 "*"
 SF-IMAGE "Image" 0
)
(script-fu-menu-register "script-fu-incremental-save" "<Image>/File")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message (string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; finds the full file name, base name, stripped name, and path of a given image
; returns a vector list ("/here/myfile.xcf" "myfile.xcf" "myfile" "/here")
(define (get-image-file-info img)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(usr "")(strL "")
      (brkTok DIR-SEPARATOR)
    )

    (if (equal? "/" brkTok)(set! usr(getenv"HOME"))(set! usr(getenv"HOMEPATH")))

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fNme (car(gimp-image-get-file img)))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth (reverse (cdr(reverse (strbreakup fNme brkTok)))))
        (set! fPth (unbreakupstr fPth brkTok))
      )

      (when (equal? (car(gimp-image-get-file img)) "")
        (set! fNme (string-append usr brkTok "Untitled.xcf"))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth usr)
      )
    )

    (vector fNme fBse fwEx fPth)
  )
)


; returns #t or #f if parasite is on a specified image
; (image id, parasite name)
(define (get-image-parasite img paraNme)
  (let*
    (
      (i 0)(actP 0)(fnd #f)
      (para (list->vector (car(gimp-image-get-parasite-list img))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fnd #t)
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fnd
  )
)


; returns the value string of a parasite on a specified image
; (image id, parasite name)
(define (get-image-parasite-string img paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-image-get-parasite-list img))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message " found the parasite "))
        (set! fndV (caddar(gimp-image-get-parasite img actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)


; tags an image with a parasite
; (layer id, "parasite name", attach mode, "value string")
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
(define (tag-image img name mode tagV)
  (gimp-image-attach-parasite img (list name 0 tagV))
)


; makes a directory in the "home" directory with a string "/path/like/this"
; in WindowsOS relative to "C:\Users\username"  keep using "/" to denote path
(define (make-dir-path path)
   (let*
    (
      (brkP 0)(i 2)(pDepth 0)(dirMake "")
    )

    (set! brkP (strbreakup path "/"))
    (set! pDepth  (length brkP))
    (set! dirMake (list-ref brkP 1)) ; skip empty element
    (dir-make dirMake) ; make root

    (while (< i pDepth)
      (set! dirMake (string-append dirMake "/" (list-ref brkP i)))     
      (set! i (+ i 1))
      (dir-make dirMake) ; make tree
    )

  )
)

