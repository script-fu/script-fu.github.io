; given a list of layers the list is sorted into a vector of vector lists
; the sorting based on what parent a layer has. Finds groups of layers.
(define (layer-list-into-parent-group-buckets lst)
  (let*
    (
      (allPs ())(parent 0)(i 0)(j 0)(actL 0)(groups 0)(actP 0)
    )

    ; find all the parents of list items
    (set! allPs (list->vector (all-parents-of-list lst)))

    ; make a bucket list for the group sorting
    (set! groups (make-vector (vector-length allPs) #()))

    ; sort the list into group buckets based on which parent
    (set! i 0)
    (if (list? lst) (set! lst (list->vector lst)))
    (while (< i (vector-length lst))
      (set! actL (vector-ref lst i))
      (set! parent (car(gimp-item-get-parent actL)))
      (set! j 0)
      (when (> parent 0)
        (while (< j (vector-length allPs))
          (set! actP (vector-ref allPs j))
          (if (= actP parent)(set! groups (add-to-bucket groups j actL)))
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
      
    )
    

  groups
  )
)