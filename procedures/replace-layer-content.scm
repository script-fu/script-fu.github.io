; replaces, source to destination layer in the same image, crops to image size
(define (replace-layer-content img srcL dstL)
  (let*
    (
      (actL 0)(name 0)
      (offX (car (gimp-drawable-get-offsets srcL)))
      (offY (cadr (gimp-drawable-get-offsets srcL)))
    )

    (set! name (car (gimp-item-get-name dstL)))
    (gimp-drawable-edit-clear dstL)

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector srcL))
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-selection-none img)
    (gimp-layer-set-offsets actL offX offY)

    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (gimp-item-set-name actL name)
    (gimp-layer-resize-to-image-size actL)

    actL
  )
)