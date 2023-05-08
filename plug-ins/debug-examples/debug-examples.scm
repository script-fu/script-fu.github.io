#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-debug-examples)
  (let*
    (
    (msg "")(i 0)
    )

    (here 1)

    (if debug (gimp-message " This is a debug flag controlled message "))
    (if info (gimp-message " This is an info flag controlled message "))

    (if info
      (gimp-message
        " usually error messages are printed in the error console dockable "
      )
    )

    (here 2)

    (if info
      (gimp-message
        " sadly, every message gets a loud warning prefix "
      )
    )

    (if info
      (gimp-message
        (string-append
        " (gimp-message-set-handler 1) redirects all debug messages to the"
        " terminal \n bring the terminal to the foreground to see the message "
        )
      )
    )

    (here 3)

    (gimp-message-set-handler 1)

    (if info (gimp-message " This is a message sent to the terminal window"))

    (here 4)

    (gimp-message-set-handler 2)

    (if info
      (gimp-message
        " (gimp-message-set-handler 2) sends them back to the console "
      )
    )

    (if info (gimp-message " This is a message sent to the error console"))

    (if info
      (gimp-message
        " if the error console is closed, errors get sent to the status bar "
      )
    )

    (if info
      (gimp-message
        " (gimp-message-set-handler 0) also redirects them to the status bar "
      )
    )

    (gimp-message-set-handler 0)

     (if info (gimp-message " sent to the status bar "))

    (if info
      (gimp-message
         (string-append
           " if the message sent to the status bar has a newline or is too long"
           "\n to fit in the bar, then a pop-up warning box will appear "
         )
      )
    )

    (gimp-message-set-handler 2)

    (if info
      (gimp-message
        (string-append
        " a debug message can be created inside a loop and then printed out "
        " to avoid a lots of warnings "
        )
      )
    )

    (here 5)

    (while (< i 10)
      (set! info (number->string i))
      (set! msg (string-append msg " information from a loop : " info "\n"))
      (set! i (+ i 1))
    )

    (if info (gimp-message msg))

    (here 5.1)

  )
)


(define (here x)
  (if debug (gimp-message (string-append " >>> " (number->string x) " <<< ")))
)

(define debug #t) ; print all debug information
(define info #t)  ; print information

(script-fu-register "script-fu-debug-examples"
 "Debug Examples"
 "An example of debugging methods in Script-Fu"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 ""
)
(script-fu-menu-register "script-fu-debug-examples" "<Image>/Fu-Plugin")
