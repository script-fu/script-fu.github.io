; fills a layer with a color list
(define (fill-layer-list actL col)
  (gimp-context-push)
  (gimp-context-set-opacity 100)
  (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
  (gimp-context-set-foreground col)
  (gimp-drawable-fill actL 0)
  (gimp-context-pop)
)
