; create a new image from a given group
(define (group-to-new-image img srcGrp)
  (let*
    (
      (dstImg 0)(allPrnts 0)(tone (list 128 128 128))(actL 0)(dstNme "")
      (treeL 0)(buffL 0)
    )
    (gimp-context-push)
    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcGrp))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! dstNme (car(gimp-item-get-name actL)))
    (set! allPrnts (get-all-parents dstImg actL))
    ;(gimp-display-new dstImg)

    ; layers copied in groups bring across parent groups, trim them out.
    ; can't make a layer a child of root directly, have to copy and insert
    (when (> (length allPrnts) 0)
      (set! buffL (car(gimp-layer-copy actL 0)))
      (gimp-image-remove-layer dstImg actL)
      (set! treeL (vector-ref (cadr (gimp-image-get-layers dstImg))0))
      (gimp-image-insert-layer dstImg buffL 0 0)
      (set! actL buffL)
      (gimp-image-remove-layer dstImg treeL)
      (gimp-item-set-name actL dstNme)
      
    )

    (gimp-context-pop)
    (list dstImg actL (car(gimp-layer-get-mask actL)))
  )
)