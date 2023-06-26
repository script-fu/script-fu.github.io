; filters a vector list of drawables, returns a vector list of only the groups
(define (only-groups drwbls)
  (let*
    (
      (i 0)(actL 0)(grpLst())
    )

    (while (< i (vector-length drwbls))
      (set! actL (vector-ref drwbls i))
      (when (= (car (gimp-item-is-group actL)) 1)
        (if (= (car (gimp-item-id-is-layer-mask actL)) 1)
          (set! actL (car(gimp-layer-from-mask actL)))
        )
        (set! grpLst (append grpLst (list actL)))
      )
      (set! i (+ i 1))
    )

    (list->vector grpLst)
  )
)