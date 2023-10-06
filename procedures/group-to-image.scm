; copies a layer stack branch to another image. Uses 'layer-to-image.scm'
; (source image, source group, dest image, destination parent)
(define (group-to-image srcImg actG dstImg parent) ; recursive
  (let*
    (
      (chldrn 0)(lstL 0)(i 0)(actL 0)(actGMsk 0)(folder 0)(dstM 0)(chldC 0)
      (rtnL 0)(pos 0)
    )

    (set! actGMsk (car (gimp-layer-get-mask actG)))

    ; create a destination copy of the layer or group
    (set! rtnL (layer-to-image srcImg actG dstImg parent pos))

    (set! dstM (car(gimp-layer-get-mask rtnL)))
    (set! chldrn (gimp-item-get-children actG))
    (set! lstL (list->vector (reverse (vector->list (cadr chldrn)))))
    (set! chldC (car chldrn))

    ; repeat for any children, recursively
    (while (< i chldC)
      (set! actL (vector-ref lstL i))

      (if (equal? (car (gimp-item-is-group actL)) 1)
        (group-to-image srcImg actL dstImg rtnL)
          (layer-to-image srcImg actL dstImg rtnL pos)
      )

      ; last child of group, then update the group mask
      (when (= i (- chldC 1))
        (if (> actGMsk 0) (transfer-mask-to-mask srcImg actGMsk dstImg dstM))
      )
      (set! i (+ i 1))
    )

    ; set the active layer to the last created group
    (gimp-image-set-selected-layers dstImg 1 (vector rtnL))

  )
)