## Parasites

# * Tested in GIMP 2.99.14 *

This plugin demonstrates how parasites currently work inGIMP . Parasites are useful for scripting in many ways. You can store data, tag layers or set variables. Typically I'd use a parasite like this;  
  
```scm
(gimp-item-attach-parasite layerID (list "name" mode "data as a string"))
```
  
Mode option for layers and images are:  
0 -> temporary and not undoable attachment  
1 -> persistent and not undoable attachment  
2 -> temporary and undoable attachment  
3 -> persistent and undoable attachment  
  
For global parasites, the modes are:  
0 -> temporary and not undoable attachment  
1 -> persistent and not undoable attachment  

  
Temporary parasites are not saved with the file. Image and layer persistent parasites are saved with the file. Persistent global parasites are restored for each GIMP session.  
  
You can see that a parasite is just a three element list. The name is used to identify, and the data can be stored as a string. Use functions like; (number->string) (string->number) or (strbreakup) to encode or decode the data.  
  
The parasite is returned as a list in a list. (list (list "name" 0 "data" )) To retrieve data from the parasite use;  
  
```scm
(set! data (caddar(gimp-item-get-parasite layerID "parasite name")))
```
  
caddar is a Scheme, the programming language Script-fu is based on, short-cut for unwrapping the list and grabbing the third item...  
  
(caar (parasite)) grabs the first item, the name.  
(cadar (parasite)) grabs the second item, the mode.  
(caddar (parasite)) grabs the third item, the data.  
  
  
  
The plug-in should appear in a Fu-Plugin menu.  
  
To download [**parasites.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/parasites/parasites.scm)  
...follow the link, right click the page, Save as parasites.scm, in a folder called parasites, in a GIMP plug-ins location.  In Linux, set the file to be executable.
  

<!-- include-plugin "parasites" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-parasites img drawables)
  (let*
    (
      (actL (vector-ref drawables 0))
    )

    (gimp-context-push)
    (gimp-image-undo-group-start img)

    (gimp-message "\n\n\n ****************")
    (gimp-message "\n* parasites found before attaching :")
    (print-parasites img actL " global parasite -> " 0 0 1)
    (print-parasites img actL " image parasite -> " 0 1 0)
    (print-parasites img actL " layer parasite -> " 1 0 0)

    (gimp-message "\n * attaching parasites -> type : mode \n\n\n\n\n")

    ; global
    (gimp-attach-parasite (list "temp-global-not-undoable : 0" 0 "0"))
    (gimp-attach-parasite (list "persist-global-not-undoable : 1" 1 "0"))

    ; image
    (gimp-image-attach-parasite img (list "temp-image-not-undoable : 0" 0 "0"))
    (gimp-image-attach-parasite img (list "persist-image-not-undoable: 1" 1"0"))
    (gimp-image-attach-parasite img (list "temp-image-undoable : 2" 2 "0"))
    (gimp-image-attach-parasite img (list "persist-image-undoable : 3" 3 "0"))

    ; layer
    (gimp-item-attach-parasite actL (list "temp-layer-not-undoable : 0" 0 "0"))
    (gimp-item-attach-parasite actL (list "persist-layer-not-undoable : 1"1"0"))
    (gimp-item-attach-parasite actL (list "temp-layer-undoable : 2" 2 "0"))
    (gimp-item-attach-parasite actL (list "persist-layer-undoable : 3" 3 "0"))

    (gimp-message " * \n parasites found after attaching :\n")
    (print-parasites img actL " global parasite -> " 0 0 1)
    (print-parasites img actL " image parasite -> " 0 1 0)
    (print-parasites img actL " layer parasite -> " 1 0 0)

    (gimp-message " \n * try undoing, and running the plug-in again :\n")
    (gimp-message " \n * then undo->save->quit->restart->load, run the plug-in")

    (gimp-image-undo-group-end img)
    (gimp-context-pop)
    (gimp-displays-flush)

  )
)

(define (print-parasites img actL message layer image global)
  (let*
    (
    (pLst ())(i 0)
    )

    (if (= layer 1)
      (set! pLst (list->vector (car (gimp-item-get-parasite-list actL))))
    )
    (if (= image 1)
      (set! pLst (list->vector (car (gimp-image-get-parasite-list img))))
    )
    (if (= global 1)(set! pLst (list->vector (car (gimp-get-parasite-list)))))

    (while (< i (vector-length pLst))
      (gimp-message
        (string-append
          message (vector-ref pLst i)
        )
      )
      (set! i (+ i 1))
    )
  )
)


(script-fu-register-filter "script-fu-parasites"
 "parasites" 
 "testing parasites" 
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
  "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-parasites" "<Image>/Fu-Plugin")
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

```
