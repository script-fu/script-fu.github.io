; copies a layer to another image, attributes included
; (source image, source layer, dst image, dst parent, dst position)
; returns the new layer id
(define (layer-to-image srcImg srcL dstImg prnt pos)
  (let*
    (
      (wdth (car(gimp-drawable-get-width srcL)))
      (hght (car(gimp-drawable-get-height srcL)))
      (offX (car (gimp-drawable-get-offsets srcL)))
      (offY (cadr (gimp-drawable-get-offsets srcL)))(unlock 0)
      (dstL 0)(actLAttr 0)(actL 0)(paraStr 0)(srcM 0)(dstM 0)(grp 0)(lckLst 0)
    )

    (set! actLAttr (store-layer-attributes srcImg srcL))
    (set! paraStr (store-layer-parasites srcL))

    (when(> (car (gimp-layer-get-mask srcL)) 0)
      (set! srcM (car (gimp-layer-get-mask srcL)))
    )

   ; if its a layer, create a destination, then copy it across
    (when (equal? (car (gimp-item-is-group srcL)) 0)
      (set! dstL (car (gimp-layer-new dstImg
                                      wdth
                                      hght
                                      RGBA-IMAGE
                                      "tmp"
                                      100
                                      LAYER-MODE-NORMAL
                        )
                  )
      )

      (gimp-image-insert-layer dstImg dstL prnt pos)
      (gimp-edit-copy 1 (vector srcL))
      (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0))
      (gimp-floating-sel-to-layer actL)
      (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
      (set-lock-layer actL unlock unlock unlock unlock)
      (gimp-layer-set-offsets actL offX offY)
      (gimp-image-remove-layer dstImg dstL)
    )

    ; if it's a group, insert a new group in the destination image
    (when (equal? (car (gimp-item-is-group srcL)) TRUE)
      (set! actL (car (gimp-layer-group-new dstImg)))
      (gimp-image-insert-layer dstImg actL prnt 0)
      (gimp-layer-set-offsets actL offX offY)
      (set! grp 1)
    )

    ; if it exists, create and copy over a mask to the new layer
    (when (and (> srcM 0) (= grp 1))
      (set! dstM (car(gimp-layer-create-mask actL 0)))
      (gimp-layer-add-mask actL dstM)
      (gimp-edit-copy 1 (vector srcM))
      (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0))
      (gimp-floating-sel-anchor dstM)
    )

    (restore-layer-attributes actL actLAttr)
    (set-lock-layer actL unlock unlock unlock unlock)
    (restore-layer-parasites actL paraStr)


    actL
  )
)