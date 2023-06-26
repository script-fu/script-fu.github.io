; part of isolate selected
(define (revert-layer img lstL types)
  (let*
    (
      (tagLst 0)(i 0)(actL 0)(t 0)(actT "")(isoP 0)
    )

    ; isolatedParents are a special case for speed up reasons
    (set! types (list->vector types))
    (set! isoP (find-layers-tagged img lstL "isoParent"))
    (set! isoP (remove-duplicates isoP))
    (set-list-visibility isoP 0)

    ; restore every type apart from isoParent
    (while (< t (vector-length types))
      (set! actT (vector-ref types t))
      (if #f (gimp-message actT)) ;debug
      (set! tagLst (find-layers-tagged img lstL actT))
      (set! tagLst (remove-duplicates (vector->list tagLst)))
      (set! tagLst (list->vector tagLst))
      (when (> (vector-length tagLst) 0)
        (set! i 0)
        (while (< i (vector-length tagLst))
          (set! actL (vector-ref tagLst i))
          (if (not(member actL isoP)) (restore-layer actL actT))
          (set! i (+ i 1))
        )
      )
      (set! t (+ t 1))
    )

    ; final pass - restore isolatedParents
    (if (list? isoP) (set! isoP (list->vector isoP)))
    (when (> (vector-length isoP) 0)
      (set! i 0)
      (while (< i (vector-length isoP))
        (set! actL (vector-ref isoP i))
        (restore-layer actL "isoParent")
        (set! i (+ i 1))
      )
    )

  )
)