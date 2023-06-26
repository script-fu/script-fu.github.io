; fills a layer with a RGB color
(define (fill-layer actL red green blue)
  (gimp-context-push)
  (gimp-context-set-opacity 100)
  (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
  (gimp-context-set-foreground (list red green blue))
  (gimp-drawable-fill actL 0)
  (gimp-context-pop)
)