; finds only the groups and not the layers in all the image or inside a group
; (source image, source group/all image) set last parameter to 0 for all image
; returns a list of all the groups found including the given group
(define (get-all-groups img actL)
  (let*
    (
    (allGrp (get-sub-groups img actL))
    )

    ;add an initial group
    (when (and (> actL 0)
               (= (car (gimp-item-is-group actL)) 1)
          )
      (if (> (length allGrp) 1)(set! allGrp (reverse allGrp)))
      (set! allGrp (append allGrp (list actL)))
      (set! allGrp (reverse allGrp))
      (if (null? allGrp) (set! allGrp (list actL)))
    )

    (if debug
      (gimp-message
        (string-append " returning group length ->  "
                        (number->string (length allGrp))
        )
      )
    )

    allGrp
  )
)