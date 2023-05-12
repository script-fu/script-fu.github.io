## Autosave Plugin

# * Tested in GIMP 2.99.14 *
  
Incrementally autosaves any images that have changed in the current session. You have to activate it **every** session, it _never_ deletes files, and _never_ saves over the open files. An image is created to show it's on, close it if you like, it still saves. It makes a storage folder relative to "home" for an easy clean up.  
  
Use the additional plugin **Almost Autosave Off** to disable.  
  
This plugin has been designed to work with the [Proxy](https://script-fu.github.io/2023/04/15/Proxy.html) plug-in. That plug-in can dramatically reduce the file size and the save time. Which makes autosaving less intrusive.  
  

The plug-ins should appear in the File menu.  
  
To download [**almost-autosave.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/almost-autosave/almost-autosave.scm)  
...follow the link, right click the page, Save as almost-autosave.scm, in a folder called almost-autosave, in a GIMP plug-ins location.  
In Linux, set the file to be executable.
   
To download [**almost-autosave-off.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/almost-autosave-off/almost-autosave-off.scm)  
...follow the link, right click the page, Save as almost-autosave-off.scm, in a folder called almost-autosave-off, in a GIMP plug-ins location.  
In Linux, set the file to be executable.  
  


```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Under GNU GENERAL PUBLIC LICENSE Version 3"
; Incrementally autosaves any images that have changed in the current session
; *Almost* because you have to activate it *every* session
; Never deletes files, NEVER SAVES OVER THE OPENED FILE
; An image is created to show it's ON, close it if you like, it still saves.
; makes a storage folder relative to "home"
; User still needs to save changes to any opened file before closing
; Use additional plugin "Almost Autosave Off" to disable.
; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3


(define (script-fu-almost-autosave)
  (let*
    (

      ; *** tweak these numbers for user preference ***
      (timeDelay 10) ; minutes between autosaves
      (increments 6) ; number of incremental saves
      (save-location "Autosaved"); will be saved in "home/Autosaved/"
      (quiet 0) ; set to 1 to stop any repeating saving messages
      (indOn 1) ; set to 0 for no indicator image
      ; *** end user tweaks ***

      (i 0)(incr 1)(imgLst 0)(img 0)(imgOn 0)(asPID 0)(asOnR 0)(pIDf 0)(iDsp 0)
    )

    (proxy-active-test) ; pause, if there is a Proxy plugin process running

    ; if autosave is not on
    (when (= (autosave-active "autosave-pid") 0)

      ; turn on, makes an "on" icon and identification parasites
      (set! asOnR (autosave-on indOn))
      (set! asPID (cadr asOnR))
      (set! imgOn (car asOnR))

      ; autosave loop, while a parasite with a PID exists
      (while (> (autosave-match-pid "autosave-pid" asPID) 0)

        (proxy-active-test) ; pause, if there is a Proxy plugin process running
        (set! imgLst (gimp-get-images))

        (when #f ;debug
          (set! iDsp (get-global-parasite "autosave-display"))
          (set! pIDf (autosave-match-pid "autosave-pid" asPID))
          (gimp-message
            (string-append
              " display ID parasite -> " (number->string iDsp)
              " \n current autosave PID -> " (number->string pIDf)
            )
          )
        )

        ; check every open image for changes to autosave
        (set! i 0)
        (while (< i (car imgLst))
          (set! img (vector-ref (cadr imgLst) i))

          (when (and (not(= img imgOn))(> (car (gimp-image-id-is-valid img))0))
            (if (> (car (gimp-image-is-dirty img)) 0)
              (incremental-save img save-location (number->string incr) quiet)
            )
          )

          (set! i (+ i 1))
        )

        (usleep (* 60 (* timeDelay 1000000)))
        (set! incr (+ incr 1))
        (if (> incr increments) (set! incr 1))

      ); autosaving loop

      (if #f ;debug
        (if(= (autosave-match-pid "autosave-pid" asPID) 0)
          (gimp-message" autosave is now off ")
        )
      )

    )

  )
)


(define (proxy-active-test)

  (when (not (equal? () (car (file-glob "proxy" 0))))
    (when (equal? "proxy" (caar (file-glob "proxy" 0)))
      (if #f (gimp-message " found proxy plugin ")) ; debug
      (while (= (plugin-get-lock "proxy") 1)
        (gimp-message " auto-save paused until Proxy plugin completes ")
        (usleep (* 60 (* 1 300000)))
      )
    )
  )

)


(define (incremental-save img sLoc incr quiet)
  (let*
    (
      (fNme "")(fBse "")(fPth "")(fNoExt "")(sNme "")(selDraw 0)(brkTok "/")
    )

    (if (equal? () (car (file-glob "/usr" 0)))(set! brkTok "\\")); windows OS

    ; give a save name to untitled images
    (when (equal? (car(gimp-image-get-file img)) "")
      (set! fNoExt (string-append "ID_"(number->string img)))
      (set! fPth (string-append sLoc "/" "Untitled"))
    )

    ; base the save name on the existing name
    (when (not(equal? (car(gimp-image-get-file img)) ""))
      (set! fNme (car(gimp-image-get-file img)))
      (set! fBse (car (reverse (strbreakup fNme brkTok))))
      (set! fNoExt (car (strbreakup fBse ".")))
      (set! fPth sLoc)
    )

    ; save the file
    (make-dir-path (string-append "/" fPth "/" fNoExt))
    (set! sNme (string-append fPth "/" fNoExt "/" "autosave_" incr ".xcf" ))
    (set! selDraw(cadr(gimp-image-get-selected-layers img)))
    (gimp-xcf-save 0 img 0 selDraw sNme)
    (if (not(= quiet 1))(gimp-message(string-append" >>> "sNme)))

  )
)


(define (make-dir-path path)
   (let*
    (
      (brkP "")(i 2)(pDepth 0)(dirMake "")
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


(define (autosave-on indOn)
   (let*
    (
      (indInfo (list 0 0))(asPID 0)(dispID 0)
    )

    (when (= indOn 1)
      ; a disposable user indicator image and layer
      (set! indInfo (draw-indicator))
      (set! dispID (number->string (car indInfo)))

      ; create a global parasite to record the indicator display ID
      (gimp-attach-parasite (list "autosave-display" 0 dispID))
      (if #f (gimp-message (string-append " saving display ID -> " dispID)))
    )

    ; create a global parasite to record the autosave process ID
    (srand (realtime))
    (set! asPID (number->string (rand 1000000)))
    (gimp-attach-parasite (list "autosave-pid" 0 asPID))

    (gimp-message " autosave on ")
    (list (cadr indInfo) (string->number asPID))

  )
)


(define (draw-indicator)
  (let*
    (
      (indNme "autosave-on")(mde LAYER-MODE-NORMAL)
      (imgOn (car (gimp-image-new 64 64 RGB )))(dispID 0)
      (actL (car (gimp-layer-new imgOn 64 64 RGBA-IMAGE indNme 100 mde)))
      (indC '(120 150 95)); RGB colour of indicator
      (indH '(170 200 155)); RGB colour of indicator highlight
    )

    (gimp-image-insert-layer imgOn actL 0 0)
    (gimp-image-set-file imgOn indNme)
    (gimp-context-push)
    (gimp-context-set-foreground indC)
    (gimp-context-set-opacity 100)
    (gimp-drawable-edit-fill actL 0)
    (gimp-image-select-ellipse imgOn 2 8 8 48 48)
    (gimp-context-set-foreground indH)
    (gimp-drawable-edit-fill actL 0)
    (gimp-selection-none imgOn)
    (gimp-context-pop)
    (gimp-image-clean-all imgOn)
    (set! dispID (car(gimp-display-new imgOn)))
    (present-first-display)
    (gimp-displays-flush)
    (list dispID imgOn )

  )
)


(define (autosave-active findNme)
  (let*
    (
      (i 0)(found 0)(actP 0)
      (para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP findNme)
        (gimp-message " autosave already active ")
        (set! found 1)
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

    found
  )
)


(define (get-global-parasite paraNme)
  (let*
    (
      (i 0)(actP 0)(fndVal 0)
      (para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (if #f (gimp-message "found the global parasite"))
        (set! fndVal (string->number (caddar(gimp-get-parasite actP))))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndVal
  )
)


(define (autosave-match-pid findNme PID)
  (let*
    (
      (i 0)(fndPID 0)(actP 0)(para (list->vector (car(gimp-get-parasite-list))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP findNme)
        (set! fndPID (string->number (caddar(gimp-get-parasite findNme))))
        (set! i (vector-length para))
      )

      (if (not (= fndPID PID)) (set! fndPID 0))
      (set! i (+ i 1))
    )

    fndPID
  )
)


(define (present-first-display)
  (let*
    (
      (i 0)
    )

    (while (< i 100)
      (when (= (car (gimp-display-id-is-valid i)) 1)
        (gimp-display-present i)

        (set! i 100)
      )
      (set! i (+ i 1))
    )

  )
)


(define (plugin-get-lock plugin)
  (let*
    (
      (input (open-input-file plugin))
      (lockValue 0)
    )

    (if input (set! lockValue (read input)))
    (if input (close-input-port input))

    lockValue
  )
)


(script-fu-register "script-fu-almost-autosave"
 "Almost Autosave" 
 "saves all open files incrementally, if the content has changed" 
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-almost-autosave" "<Image>/File")
```
  
   
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
; Under GNU GENERAL PUBLIC LICENSE Version 3"
(define (script-fu-almost-autosave-off)
  (let*
    (
      (i 0)(fID 0)(actP 0)(para (list->vector (car(gimp-get-parasite-list))))
      (dspID "autosave-display")(PID "autosave-pid")
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))

      ; found the display ID parasite to remove the indicator image
      (when (equal? actP dspID)
        (set! fID(string->number (caddar(gimp-get-parasite actP))))
        (if #f ;debug
          (gimp-message
            (string-append
              "removing display ID -> " (number->string fID)
            )
          )
        )
        (gimp-detach-parasite actP)
        (if(= (car(gimp-display-id-is-valid fID)) 1)(gimp-display-delete fID))
      )

      ; found the autosave process id parasite
      (when (equal? actP PID)
        (if #f (gimp-message (string-append "removing PID -> " actP)))
        (gimp-detach-parasite actP)
      )

      (set! i (+ i 1))
    )

    (gimp-message " autosave off ")

  )
)


(script-fu-register "script-fu-almost-autosave-off"
 "Almost Autosave Off "
 "turns off autosave"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-almost-autosave-off" "<Image>/File")
```