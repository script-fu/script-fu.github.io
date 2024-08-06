; return a filtered list of layers if with the substring in the layer name
(define (items-names-have-substring lstL substring)
  (let*
    (
      (i 0)
      (actL 0)
      (foundLayers #())
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))

    ; check every given item name for the substring
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))

      (when (and (= (car (gimp-item-id-is-valid actL)) 1)
                 (item-name-has-substring actL substring)
            )
        (set! foundLayers (vector-append foundLayers actL))
      )

      (set! i (+ i 1))
    )

    foundLayers
  )
)