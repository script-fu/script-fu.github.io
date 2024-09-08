; part of isolate selected
(define (revert-layer img lstL types)
  (let*
    (
      (tagLst 0)(i 0)(actL 0)(t 0)(actT "")(isoP 0)(hLst())(vLst())(visTag 0)
    )

    ; restore every type
    (while (< t (vector-length types))
      (set! actT (vector-ref types t))
      (if debug (gimp-message actT))
      (set! tagLst (find-layers-tagged img lstL actT))
      (set! tagLst (remove-duplicates (vector->list tagLst)))
      (set! tagLst (list->vector tagLst))
      (when (> (vector-length tagLst) 0)
        (set! i 0)
        (while (< i (vector-length tagLst))
          (set! visTag 0)
          (set! actL (vector-ref tagLst i))
          (set! visTag (restore-layer actL actT))

          (if (= visTag 1) (set! vLst (append vLst (list actL))))
          (if (= visTag 0) (set! hLst (append hLst (list actL))))

          (set! i (+ i 1))
        )
      )
      (set! t (+ t 1))
    )

    (when debug (gimp-message " restore visible layers:")
      (print-layer-id-name vLst)
    )

    (when debug (gimp-message " restore hidden layers: ")
      (print-layer-id-name hLst)
    )

    (set! vLst (list->vector vLst))
    (set! hLst (list->vector hLst))

    ; final pass - restore visibility for tagged layers
    (if (> (vector-length vLst) 0)
      (gimp-items-set-visible (vector-length vLst) vLst 1)
    )
    (if (> (vector-length hLst) 0)
      (gimp-items-set-visible (vector-length hLst) hLst 0)
    )

  )
)