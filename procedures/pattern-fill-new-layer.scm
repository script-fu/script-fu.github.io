; fills a new image sized layer with given pattern
; pattern is an integer ID e.g the return of car(gimp-pattern-get-by-name "name")

(define (pattern-fill-new-layer img name mode pattern opacity vis inv)
  (let*
    (
      (actL 0)
    )
    ;(gimp-patterns-refresh)
    (set! actL (add-image-size-layer img 0 0 name mode))
    (gimp-item-set-visible actL vis)
    (gimp-context-set-pattern pattern)
    (gimp-context-set-opacity opacity)
    (gimp-selection-none img)
    (gimp-drawable-edit-fill actL FILL-PATTERN)
    (if inv (gimp-drawable-invert actL 1))

    actL
  )
)