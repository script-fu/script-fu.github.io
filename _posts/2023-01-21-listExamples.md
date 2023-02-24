## List examples - Script for Gimp 2

There's comes a time to build lists and access lists.

*examples of list use*

```scheme
(define (listsExample)
(let*
 (
  (listAlphabet '("a" "b" "c" "d" "e"))
  (listAlphabetAdd '("f" "g" "h" "i" "j"))
  (red 64)
  (green 128)
  (blue 256)
  (colourStore (list red green blue))
  (buildList ())
  (randomLength 0)
  (i 0)(j 0)
  (sublist ())
 )

 (gimp-message (string-append " find the list head with (car list) -> "
                              (car listAlphabet)
                              "\n number of list elements (length list)-> "
                              (number->string (length listAlphabet))
                              ))

 (gimp-message "\n\n reading all of list using map function ")
 (map (lambda (x) (gimp-message (string-append "list element ->  " x )))
  listAlphabet)

 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n reading all of list using list-ref and a while loop ")
 (set! i 0)
  (while (< i (length listAlphabet))
   (gimp-message (string-append "list element ->  " (list-ref listAlphabet i)))
   (set! i (+ i 1))
  )

 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n reading all of list using nth and a while loop ")
 (set! i 0)
 (while (< i (length listAlphabet))
  (gimp-message (string-append "list element ->  " (nth i listAlphabet)))
  (set! i (+ i 1))
 )

 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n appending two list ")
 (map (lambda (x) (gimp-message (string-append "list element ->  " x)))
  (append listAlphabet listAlphabetAdd))


 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n build a list of lists ")
 (set! buildList (list (list 1 2 3) (list 4 5 6) (list 7 8 9)))

 (set! i 0)
 (while (< i (length buildList))
  (gimp-message (string-append "\n\n sub list -> " (number->string (+ i 1))))
  (set! sublist (nth i buildList))
  (set! j 0)
   (while (< j (length sublist))
    (gimp-message (string-append " list element ->  "
                                 (number->string (nth j sublist))))
    (set! j (+ j 1))
   )
  (set! i (+ i 1))
 )

 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n another list of lists ")
 (set! buildList (list colourStore colourStore colourStore))

 (set! i 0)
 (while (< i (length buildList))
  (gimp-message (string-append "\n\n sub list -> " (number->string (+ i 1))))
  (set! sublist (nth i buildList))
  (set! j 0)
   (while (< j (length sublist))
    (gimp-message (string-append " list element ->  "
                                 (number->string (nth j sublist))))
    (set! j (+ j 1))
   )
  (set! i (+ i 1))
 )

 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n yet another list of lists ")
 (set! buildList '(("a" "c" "d") ("e" "f" "g") ("h" "i" "j")))

 (set! i 0)
 (while (< i (length buildList))
  (gimp-message (string-append "\n\n sub list -> " (number->string (+ i 1))))
  (set! sublist (nth i buildList))
  (set! j 0)
   (while (< j (length sublist))
    (gimp-message (string-append " list element ->  "
                                 (nth j sublist)))
    (set! j (+ j 1))
   )
  (set! i (+ i 1))
 )

 (gimp-message "\n\n ********************* ")
 (gimp-message "\n\n build a list of random length betweeb 10 and 39 ")
 (set! randomLength (+ (rand 30) 9))
 (gimp-message (string-append " *** random length -> "
                              (number->string randomLength)
                              " ***"
                              ))
 (set! buildList '())
 (set! i 0)
 (while (< i randomLength)
  (set! buildList (append buildList (list (number->string (rand 100))) ))
  (set! i (+ i 1))
 )

 (map (lambda (x) (gimp-message (string-append " random list element ->  " x )))
  buildList)


 )
)

(script-fu-register "listsExample"
 "list function examples"
 "demonstrates some list manipulation methods"
 "Mark Sweeney"
 "copyright 2022, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2022"
 ""
)
(script-fu-menu-register "listsExample" "<Image>/Script-Fu")

```
