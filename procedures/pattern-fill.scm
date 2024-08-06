; fills a layer with given pattern
; pattern is an integer ID e.g the return of car(gimp-pattern-get-by-name "name")

(define (pattern-fill img dstL pattern mode opacity inv selection)
  (gimp-context-push)
  (gimp-context-set-pattern pattern)
  (gimp-context-set-opacity opacity)
  (gimp-context-set-paint-mode mode)
  (if (not selection) (gimp-selection-none img))
  (gimp-drawable-edit-fill dstL FILL-PATTERN)
  (if inv (gimp-drawable-invert dstL 1))
  (gimp-context-pop)
)