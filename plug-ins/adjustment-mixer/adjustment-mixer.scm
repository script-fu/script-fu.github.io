#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-adjustment-mixer img drawables)
  (let*
    (
      (tint (list 220 146 43)) ; default tint RGB
      (actL 0)(srcGrp 0)(srcL 0)(layerLst (layer-scan img 0))
      (mxGrp (get-layers-tagged img layerLst "mixer"))
      (update (vector-ref mxGrp 0))
    )

    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (gimp-selection-none img)

    ; initial set up
    (when (= update 0)
      (resolve-name-conflicts img)
      (set! srcGrp (source-group img))
      (set! mxGrp (add-mix-grp img 0 0 "mixer" LAYER-MODE-PASS-THROUGH))
      (set! srcL (paste-copy img 0 img 0 mxGrp "! no edit !" 0 ))
      (tag-layer srcL  "source copy" "42" 0)
      (gimp-item-set-lock-content srcL 1) 
      (gimp-item-set-expanded srcGrp 0)
      (gimp-item-set-visible srcGrp 0)
      (gimp-image-lower-item img mxGrp)
    )

    ; Or update a mixer
    (when (> update 0)
      (set! mxGrp (vector-ref mxGrp 0))
      (gimp-item-set-visible mxGrp 0)
      (set! srcGrp (vector-ref (get-layers-tagged img layerLst "source") 0))
      (set! srcL (get-layers-tagged img layerLst "source copy"))
      (set! srcL (vector-ref srcL 0 ))
      (when (= srcL 0)
        (set! srcL (paste-copy img 0 img 0 mxGrp "! no edit please !" 0 ))
        (tag-layer srcL  "source copy" "42" 0)
      )
      (set! srcGrp (vector-ref (get-layers-tagged img layerLst "source") 0)) 
      (gimp-item-set-lock-content srcL 0)
      (set! srcL (transfer-layer-preserve img srcGrp srcL))
      (gimp-item-set-lock-content srcL 1)
      (gimp-item-set-visible mxGrp 1)
      (gimp-item-set-visible srcGrp 0)
      (gimp-item-set-expanded srcGrp 0)
      (gimp-item-set-expanded mxGrp 1)
    )

    ; add some adjustment layers
    (set! actL (add-mix img srcL mxGrp "bright" LAYER-MODE-LIGHTEN-ONLY update))
    (when (> actL 0)
      (apply-lighten-curve img actL)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "contrast" LAYER-MODE-NORMAL update))
    (when (> actL 0)
      (gimp-drawable-brightness-contrast actL 0 0.1)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "s-curve" LAYER-MODE-NORMAL update))
    (when (> actL 0)
      (apply-s-curve img actL)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "dodge" LAYER-MODE-DODGE update))
    (when (> actL 0)
      (curve-2-value img actL 0 0 255 128)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "burn" LAYER-MODE-BURN update))
    (when (> actL 0)
      (curve-2-value img actL 0 128 255 255)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "b&w" LAYER-MODE-LCH-CHROMA update))
    (when (> actL 0)
      (gimp-drawable-desaturate actL DESATURATE-AVERAGE)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "chroma" LAYER-MODE-NORMAL update))
    (when (> actL 0)
      (gimp-drawable-hue-saturation actL 0 0 0 100 100)
      (gimp-item-set-lock-content actL 1)
    )

    ; more adjustment layers here, possible to extend

    ; tint layer is a special intial creation case
    (when (= update 0)
      (set! actL(add-mix img srcL mxGrp "tint" LAYER-MODE-LCH-COLOR update))
      (when (> actL 0)
        (gimp-context-set-foreground tint)
        (gimp-context-set-opacity 100)
        (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
        (gimp-drawable-fill actL FILL-FOREGROUND)
      )
    )

    (gimp-displays-flush)
    (gimp-image-undo-group-end img)
    (gimp-context-pop)
  )
)


(define (source-group img)
  (let*
    (
      (rootL (gimp-image-get-layers img))
      (srcGrp 0)
    )
    (when (> (car rootL) 1)
      (set! srcGrp (layer-group img (cadr rootL)))
      (gimp-item-set-name srcGrp "source")
      (tag-layer srcGrp "source" "42" 0)
    )
    (when (= (car rootL) 1)
      (set! srcGrp (vector-ref (cadr rootL) 0))
      (tag-layer srcGrp "source" "42" 0)
    )
    (gimp-item-set-visible srcGrp 1)
    srcGrp
  )
)


(define (resolve-name-conflicts img)
  (let*
    (
      (actL 0)
    )
    (set! actL (find-layer img "tint"))
    (if (> actL 0) (gimp-item-set-name actL "tint-layer"))
    (set! actL (find-layer img "source copy"))
    (if (> actL 0) (gimp-item-set-name actL "source-copy"))
    (set! actL (find-layer img "s-curve"))
    (if (> actL 0) (gimp-item-set-name actL "s-curve-layer"))
    (set! actL (find-layer img "dodge"))
    (if (> actL 0) (gimp-item-set-name actL "dodge-layer"))
    (set! actL (find-layer img "burn"))
    (if (> actL 0) (gimp-item-set-name actL "burn-layer"))
    (set! actL (find-layer img "b&w"))
    (if (> actL 0) (gimp-item-set-name actL "b&w-layer"))
    (set! actL (find-layer img "chroma"))
    (if (> actL 0) (gimp-item-set-name actL "chroma-layer"))
    (set! actL (find-layer img "brighten"))
    (if (> actL 0) (gimp-item-set-name actL "brighten-layer"))
    (set! actL (find-layer img "contrast"))
    (if (> actL 0) (gimp-item-set-name actL "contrast-layer"))
  )
)


(define (add-mix-grp img parent pos name mode)
  (let*
    (
      (actL 0)
    )
    (set! actL (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-mode actL mode)
    (gimp-item-set-name actL name)
    (tag-layer actL name "42" 0)
    actL
  )
)


(define (add-mix img srcL parent name mode update)
  (let*
    (
      (actL 0)(layerLst (layer-scan img 0))
    )

    (when (= update 0)
      (set! actL (paste-copy img srcL img actL parent name 0))
      (gimp-layer-set-opacity actL 0)
      (gimp-layer-set-mode actL mode)
      (gimp-layer-set-opacity actL 0)
      (tag-layer actL name "42" 0)
    )

    (when (> update 0)
      (set! actL (vector-ref (get-layers-tagged img layerLst name) 0))
      (when (> actL 0)
        (gimp-item-set-lock-content actL 0)
        (set! actL (transfer-layer-preserve img srcL actL))
      )
    )

    actL
  )
)


(define (layer-group img drawables)
  (let*
    (
      (drawable (vector-ref drawables 0))
      (numDraw (vector-length drawables))
      (parent (car (gimp-item-get-parent drawable)))
      (pos (car (gimp-image-get-item-position img drawable)))
      (layerGrp 0)(i (- numDraw 1))
    )

    (gimp-image-undo-group-start img)
    (set! layerGrp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img layerGrp parent pos)
    (gimp-item-set-name layerGrp "group")
    (gimp-layer-set-mode layerGrp LAYER-MODE-PASS-THROUGH)

    (while (> i -1)
      (set! drawable (vector-ref drawables i))
      (gimp-image-reorder-item img drawable layerGrp 0)
      (set! i (- i 1))
    )
    (gimp-image-undo-group-end img)

    layerGrp
  )
)


(define (tag-layer layer name tagV col)
  (if(= (car (gimp-item-id-is-layer-mask layer)) 1)
    (set! layer (car(gimp-layer-from-mask layer)))
  )
  (gimp-item-attach-parasite layer (list name 0 tagV))
  (gimp-item-set-color-tag layer col)
)


(define (apply-s-curve img actL)
  (curve-4-value img actL 0 0 77 32 174 220 255 255)
)


(define (apply-lighten-curve img actL)
  (curve-4-value img actL 0 0 96 174 159 237 255 255)
  (curve-4-value img actL 0 0 96 174 159 237 255 255)
)


(define (curve-4-value img actL x1 y1 x2 y2 x3 y3 x4 y4)
  (let*
    (
      (points())
      (conv (/ 1 255))
    )

    (set! points (make-vector 8 'double))
    (vector-set! points 0 (* x1 conv))
    (vector-set! points 1 (* y1 conv))
    (vector-set! points 2 (* x2 conv))
    (vector-set! points 3 (* y2 conv))
    (vector-set! points 4 (* x3 conv))
    (vector-set! points 5 (* y3 conv))
    (vector-set! points 6 (* x4 conv))
    (vector-set! points 7 (* y4 conv))

    (gimp-drawable-curves-spline actL 0 8 points)
    actL
  )
)


(define (curve-2-value img actL x1 y1 x2 y2)
  (let*
    (
      (points())
      (conv (/ 1 255))
    )

    (set! points (make-vector 4 'double))
    (vector-set! points 0 (* x1 conv) )
    (vector-set! points 1 (* y1 conv) )
    (vector-set! points 2 (* x2 conv) )
    (vector-set! points 3 (* y2 conv) )

    (gimp-drawable-curves-spline actL 0 4 points)
    actL
  )
)


(define (paste-copy img srcL dstImg dstL dstP name crop)
  (let*
    (
    (actL 0)(cur-width 0)(cur-height 0)(dstExst dstL)
    )

    (when (= srcL 0)
      (gimp-edit-copy-visible img)
      (set! cur-width (car (gimp-image-get-width img)))
      (set! cur-height (car (gimp-image-get-height img)))
    )

    ; get size and ID of first drawable
    (when (> srcL 0)
      (gimp-edit-copy 1 (vector srcL))
      (set! cur-width (car (gimp-drawable-get-width srcL)))
      (set! cur-height (car (gimp-drawable-get-height srcL)))
    )

    ;add a new destination layer if needed
    (when (= dstExst 0)
      (set! dstL (car (gimp-layer-new dstImg
                                      cur-width
                                      cur-height
                                      RGBA-IMAGE
                                      "dstL"
                                      100
                                      LAYER-MODE-NORMAL
                       )
                  )
      )
      (gimp-image-insert-layer dstImg dstL dstP 0)
    )

    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    
    ; floating selection to new layer or anchor to temporary layer?
    (if (= dstExst 1)(gimp-floating-sel-to-layer actL)
      (gimp-floating-sel-anchor actL)
    )

    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-item-set-name actL name)
    (if (= crop 1)(gimp-layer-resize-to-image-size actL))
    actL
  )
)


(define (find-layer img name)
  (let*
    (
      (matchedLayer 0)(matchName 0)(i 0)(layerList ())
    )

    (set! layerList (layer-scan img 0))
    (set! layerList (list->vector layerList))

    (while (< i (vector-length layerList))
      (set! matchName (car(gimp-item-get-name (vector-ref layerList i))))
      (when (equal? name matchName)
        (set! matchedLayer (vector-ref layerList i))
        (set! i (vector-length layerList))
        ; (gimp-message (string-append " found layer -> " name " : ID = "
        ;                               (number->string matchedLayer)
        ;               )
        ; )
      )
      (set! i (+ i 1))
    )

    matchedLayer
  )
)


(define (layer-scan img rootGrp)
  (let*
    (
      (getChildren 0)(layerList 0)(i 0)(layer 0)(allLayerList ())
    )

    (if (= rootGrp 0)
      (set! getChildren (gimp-image-get-layers img))
      (if (equal? (car (gimp-item-is-group rootGrp)) 1)
        (set! getChildren (gimp-item-get-children rootGrp))
        (set! getChildren (list 1 (list->vector (list rootGrp))))
      )
    )

    (set! layerList (cadr getChildren))
    (while (< i (car getChildren))
      (set! layer (vector-ref layerList i))
      (set! allLayerList (append allLayerList (list layer)))
      (if (equal? (car (gimp-item-is-group layer)) 1)
        (set! allLayerList (append allLayerList (layer-scan img layer)))
      )
      (set! i (+ i 1))
    )

    allLayerList
  )
)


(define (get-layers-tagged img layerList tag)
  (let*
    (
      (taggedList ())(parasiteCount 0)(layer 0)(param 0)(paramC 0)
      (paramLst 0)(pName 0)(i 0)(j 0)(layerCount 0)
    )

    (set! layerList (list->vector layerList))
    (set! layerCount (vector-length layerList))

    (set! i 0)
    (while (< i layerCount)
      (set! layer (vector-ref layerList i))
      (set! param (car (gimp-item-get-parasite-list layer)))
      (set! paramC (length param))
      (when (> paramC 0)
        (set! paramLst (list->vector param))
        (set! j 0)
        (while(< j paramC)
          (set! pName (vector-ref paramLst j))
          (when (equal? pName tag)
            (set! taggedList (append taggedList (list layer)))
            (set! parasiteCount (+ parasiteCount 1))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (if (= (length taggedList) 0)(set! taggedList (append taggedList (list 0))))
    (list->vector taggedList)
  )
)


(define (transfer-layer-preserve img srcLayer dstL)
  (let*
    (
      (actL 0)(name 0)
    )

    (set! name (car (gimp-item-get-name dstL)))
    (gimp-edit-copy 1 (vector srcLayer))
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers img))0))
    (gimp-item-set-name actL name)
    actL

  )
)


(script-fu-register-filter "script-fu-adjustment-mixer"
 "Adjustment Mixer" 
 "Creates a layer tree structure that allows mixing of adjusted copies"
 "Mark Sweeney"
 "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-adjustment-mixer" "<Image>/Layer")
