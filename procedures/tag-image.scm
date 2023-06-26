; tags an image with a parasite
; (layer id, "parasite name", attach mode, "value string")
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
(define (tag-image img name mode tagV)
  (gimp-image-attach-parasite img (list name 0 tagV))
)