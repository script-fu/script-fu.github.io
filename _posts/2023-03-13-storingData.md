## Storing Data

# * Tested in GIMP 2.99.14 *

When you need to store and retrieve data, write it to a file.

*Example that demonstrates data storage in Script-fu*

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-dataFile img drawables dataFile) 
  (let*
    (
      (input 0)
      (output 0)
      (inputLine 0)
      (inputString "")
      (inputList())
      (numberData 12345)
      (stringData "56789")
      (dataList (list "a" "b" "c" "d"))
      (listOfLists (list (list 22 33 44) (list 55 66 77)))
      (getList 0)
      (i 0)(j 0)
      (element 0)
      (stringBreak 0)
    )

    ; *** simple data write, read and store ***
    (gimp-message (string-append " writing to data file -> " dataFile
                                " \n numberData -> " (number->string numberData)
                                " \n stringData -> " stringData
                  )
    )
    (set! output (open-output-file dataFile))
    (display numberData output)
    (newline output)
    (display stringData output)
    (close-output-port output)

    (gimp-message (string-append " reading data from file-> " dataFile))
    (set! input (open-input-file dataFile))
    (set! inputLine (read input))
    (while (not (eof-object? inputLine))
      (set! inputString (atom->string inputLine))
      (gimp-message (string-append " store data in a list -> " inputString ))
      (set! inputList (append inputList (list inputString)))
      (newline)
      (set! inputLine (read input))
    )
    (close-input-port input)

    (gimp-message (string-append " \n reading from list -> inputList"
                                 " \n head of list -> " (car inputList)
                                 " \n length of list  -> " (number->string
                                 (length inputList))
                  )
    )

    (while (< i (length inputList))
      (set! element (nth i inputList))
      (gimp-message (string-append " sub list -> " (number->string (+ i 1))
                                   " -> " element
                    )
      )
      (set! i (+ i 1))
    )


    ; *** list write and read ***
    (set! dataFile (string-append dataFile "List"))
    (gimp-message (string-append " \n\n writing a list to file -> " dataFile))
    (set! output (open-output-file dataFile))

    (set! i 0)
    (while (< i (length dataList))
      (set! element (nth i dataList))
      (gimp-message (string-append " list element -> " element))
      (display element output)
      (newline output)
      (set! i (+ i 1))
    )
    (close-output-port output)

    (gimp-message (string-append " reading data list -> " dataFile))
    (set! input (open-input-file dataFile))
    (set! inputLine (read input))
    (while (not (eof-object? inputLine))
      (set! inputString (atom->string inputLine))
      (gimp-message (string-append " data file line -> " inputString))
      (newline)
      (set! inputLine (read input))
    )
    (close-input-port input)


    ; *** list of lists write and read ***
    (set! dataFile (string-append dataFile "s"))
    (gimp-message (string-append " \n\n writing lists to file -> " dataFile))
    (set! output (open-output-file dataFile))

    (set! i 0)
    (while (< i (length listOfLists))
      (set! element (nth i listOfLists))
      (set! j 0)
      (while (< j (length element))
        (gimp-message (string-append " inner list element ->  "
                                    (number->string (nth j element))))
        (display (nth j element) output)
        (if (< j (- (length element) 1)) (display "*" output))
        (set! j (+ j 1))
      )
      (newline output)
      (set! i (+ i 1))
    )
    (close-output-port output)

    (gimp-message (string-append " reading data -> " dataFile))
    (set! input (open-input-file dataFile))
    (set! inputLine (read input))
    (while (not (eof-object? inputLine))
      (set! inputString (atom->string inputLine))
      (gimp-message (string-append " data file line -> " inputString))
      (set! stringBreak (strbreakup inputString "*"))
      (set! i 0)
      (while (< i (length stringBreak))
        (gimp-message (string-append " seperated list element ->  "
                                     (nth i stringBreak)))
        (set! i (+ i 1))
      )
      (newline)
      (set! inputLine (read input))
    )
    (close-input-port input)

  )
)


(script-fu-register-filter "script-fu-dataFile"
  "dataFile" 
  "example plugin that writes dataFiles to the home directory" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-DRAWABLE
  SF-STRING     "filename"   "mydata"
)
(script-fu-menu-register "script-fu-dataFile" "<Image>/Fu-Plugin")

```