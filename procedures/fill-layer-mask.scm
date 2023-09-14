; fills a mask with a RGB color
(define (fill-layer-mask mask val)
  (gimp-context-push)
  (gimp-context-set-opacity 100)
  (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
  (gimp-context-set-foreground (list val val val))
  (gimp-drawable-fill mask 0)
  (gimp-context-pop)
)