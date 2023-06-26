#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-adjustment-mixer img drawables)
  (let*
    (
      (tint (list 220 146 43)) ; default tint RGB
      (actL 0)(srcL 0)(layerLst (all-childrn img 0))
      (mxGrp (get-layers-tagged img layerLst "mixer"))
      (srcGrp (get-layers-tagged img layerLst "sourceGrp"))
      (isMxr (vector-length mxGrp))
      (isSrc (vector-length srcGrp))
    )
    
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (gimp-selection-none img)

    ; initial set up, look for an existing source group, mixer may be deleted
    (when (= isMxr 0)
      (resolve-name-conflicts img)
      (if (= isSrc 0)(set! srcGrp (source-group img))
        (set! srcGrp (vector-ref srcGrp 0))
      )
      (set! mxGrp (add-mix-grp img 0 0 "mixer" LAYER-MODE-PASS-THROUGH))
      (set! srcL (paste-copy img srcGrp img mxGrp "! no edit !"))
      (gimp-item-set-lock-content srcL 1) 
      (gimp-item-set-expanded srcGrp 0)
      (gimp-item-set-visible srcGrp 0)
      (gimp-image-lower-item-to-bottom img mxGrp)
      (tag-layer mxGrp "mixer" 3 "mixer" 0)
      (tag-layer srcGrp "sourceGrp" 3 "sourceGrp" 0)
    )

    ; Or update a mixer if one was found
    (when (> isMxr 0)
      (set! mxGrp (vector-ref mxGrp 0))
      (gimp-item-set-visible mxGrp 0)

      ; deal with a possible untagged source group from older mixed files
      (if (> isSrc 0) (set! srcGrp (vector-ref srcGrp 0)))
      (if (= isSrc 0)(set! srcGrp (find-layer img "source" 0)))
      (if (= srcGrp 0)(exit "no 'source' group found"))

      (set! srcL (find-layer img "! no edit !" ))

      (when (= srcL 0)
        (set! srcL (paste-copy img srcGrp img mxGrp "! no edit !"))
        (gimp-image-lower-item-to-bottom img srcL)
      )

      (gimp-item-set-lock-content srcL 0)
      (set! srcL (replace-layer-content img srcGrp srcL))
      (gimp-item-set-lock-content srcL 1)
      (gimp-item-set-visible mxGrp 1)
      (gimp-item-set-visible srcGrp 0)
      (gimp-item-set-expanded srcGrp 0)
      (gimp-item-set-expanded mxGrp 1)
    )

    ; add some adjustment layers
    (set! actL (add-mix img srcL mxGrp "bright" LAYER-MODE-LIGHTEN-ONLY isMxr))
    (when (> actL 0)
      (apply-lighten-curve img actL)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "contrast" LAYER-MODE-NORMAL isMxr))
    (when (> actL 0)
      (gimp-drawable-brightness-contrast actL 0 0.1)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "s-curve" LAYER-MODE-NORMAL isMxr))
    (when (> actL 0)
      (apply-s-curve img actL)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "dodge" LAYER-MODE-DODGE isMxr))
    (when (> actL 0)
      (curve-2-value img actL 0 0 255 128)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "burn" LAYER-MODE-BURN isMxr))
    (when (> actL 0)
      (curve-2-value img actL 0 128 255 255)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "b&w" LAYER-MODE-LCH-CHROMA isMxr))
    (when (> actL 0)
      (gimp-drawable-desaturate actL DESATURATE-AVERAGE)
      (gimp-item-set-lock-content actL 1)
    )

    (set! actL (add-mix img srcL mxGrp "chroma" LAYER-MODE-NORMAL isMxr))
    (when (> actL 0)
      (gimp-drawable-hue-saturation actL 0 0 0 100 100)
      (gimp-item-set-lock-content actL 1)
    )

    ; more adjustment layers here, possible to extend

    ; tint layer is a special intial creation case
    (when (= isMxr 0)
      (set! actL(add-mix img srcL mxGrp "tint" LAYER-MODE-LCH-COLOR isMxr))
      (when (> actL 0)
        (gimp-context-set-foreground tint)
        (gimp-context-set-opacity 100)
        (gimp-context-set-paint-mode LAYER-MODE-NORMAL)
        (gimp-drawable-fill actL FILL-FOREGROUND)
      )
    )
    
    (gimp-message " finished adjustment mixer ")
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

    (set! srcGrp (layer-group img (cadr rootL)))
    (gimp-item-set-name srcGrp "source")
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
    actL
  )
)


(define (add-mix img srcL parent name mode update)
  (let*
    (
      (actL 0)
    )

    (when (= update 0)
      (set! actL (paste-copy img srcL img parent name))
      (gimp-layer-set-opacity actL 0)
      (gimp-layer-set-mode actL mode)
      (gimp-layer-set-opacity actL 0)
    )

    (when (> update 0)
      (set! actL (find-layer img name) 0)
      (when (> actL 0)
        (gimp-item-set-lock-content actL 0)
        (set! actL (replace-layer-content img srcL actL))
      )
    )

    actL
  )
)


(define (apply-s-curve img actL)
  (curve-4-value img actL 0 0 44 32 174 220 255 255)
)


(define (apply-lighten-curve img actL)
  (curve-4-value img actL 0 0 96 174 159 237 255 255)
  (curve-4-value img actL 0 0 96 174 159 237 255 255)
)


(script-fu-register-filter "script-fu-adjustment-mixer"
 "Adjustment Mixer" 
 "Creates a layer tree structure that allows mixing of adjusted copies"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-OR-MORE-DRAWABLE
)
(script-fu-menu-register "script-fu-adjustment-mixer" "<Image>/Image")


; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; puts a list of layers in a group based on the stack pos of the first element
; (source image, list/vector of layers)
; returns the new group id
(define (layer-group img drwbls)
 (let*
    (
      (mde LAYER-MODE-NORMAL) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
      (nme "groupNme")
      (numDraw 0)(actL 0)(parent 0)(i 0)(pos 0)(grp 0)
    )
    
    (if (list? drwbls) (set! drwbls (list->vector drwbls)))
    (set! numDraw (vector-length drwbls))
    (set! actL (vector-ref drwbls 0))
    (set! parent (car (gimp-item-get-parent actL)))
    (set! pos (car (gimp-image-get-item-position img actL)))
    (set! i (- numDraw 1))
    (set! grp (car (gimp-layer-group-new img)))
    (gimp-image-insert-layer img grp parent pos)
    (gimp-item-set-name grp nme)
    (gimp-layer-set-mode grp mde)

    (while (> i -1)
      (set! actL (vector-ref drwbls i))
      (gimp-image-reorder-item img actL grp 0)
      (set! i (- i 1))
    )

    grp

  )
)


; apply a 4 value curve to a layer with specified points
; (image, layer id, curve point (x,y), (x,y), (x,y), (x,y))
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



; apply a 2 value curve to a layer with specified points
; (image, layer id, curve point (x,y), (x,y))
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


; creates an image size copy of a layer or folder
; (src img, src layer/folder, dst img, dst layer/0, parent for copy, name)
; returns the new layer id
(define (paste-copy img srcL dstImg dstP name)
  (let*
    (
    (actL 0)(cur-width 0)(cur-height 0)(dstL 0)(offX 0)(offY 0)
    )

    ; make a copy of the source group
    (gimp-edit-copy 1 (vector srcL))
    (set! cur-width (car (gimp-drawable-get-width srcL)))
    (set! cur-height (car (gimp-drawable-get-height srcL)))
    (set! offX (car (gimp-drawable-get-offsets srcL)))
    (set! offY (cadr (gimp-drawable-get-offsets srcL)))

    ;add a new destination layer
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
    (gimp-layer-set-offsets dstL offX offY)

    ; paste onto the destination layer
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))

    ; anchor to temporary layer and resize to image
    (gimp-floating-sel-anchor actL)
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (gimp-layer-resize-to-image-size actL)
    (gimp-item-set-name actL name)

    actL
  )
)


; finds a layer in an image by name
; (source image, "name")
; returns the layer id or 0
(define (find-layer img name)
  (let*
    (
      (foundID (car(gimp-image-get-layer-by-name img name)))
    )

  (if debug
    (if (> foundID 0)
    (gimp-message (string-append " found layer -> " name))
      (gimp-message (string-append " not found layer -> " name " ! "))
    )
  )

  (if (< foundID 0) (set! foundID 0))

  foundID
  )
)



; returns all the children of an image or a group as a list
; (source image, source group) set group to zero for all children of the image
(define (all-childrn img rootGrp) ; recursive
  (let*
    (
      (chldrn ())(lstL 0)(i 0)(actL 0)(allL ())
    )

    (if (= rootGrp 0)
      (set! chldrn (gimp-image-get-layers img))
        (if (equal? (car (gimp-item-is-group rootGrp)) 1)
          (set! chldrn (gimp-item-get-children rootGrp))
        )
    )

    (when (not (null? chldrn))
      (set! lstL (cadr chldrn))
      (while (< i (car chldrn))
        (set! actL (vector-ref lstL i))
        (set! allL (append allL (list actL)))
        (if (equal? (car (gimp-item-is-group actL)) 1)
          (set! allL (append allL (all-childrn img actL)))
        )
        (set! i (+ i 1))
      )
    )

    allL
  )
)


; tags a layer with a parasite and an optional layer colour
; (layer id, "parasite name", attach mode, "value string", layer color)
; modes:
; 0 -> temporary and not undoable attachment
; 1 -> persistent and not undoable attachment
; 2 -> temporary and undoable attachment
; 3 -> persistent and undoable attachment
; color (0-8) (none, blue, green, yellow, orange, brown, red, violet, grey)
(define (tag-layer actL name mode tagV col)
  (if(= (car (gimp-item-id-is-layer-mask actL)) 1)
    (set! actL (car(gimp-layer-from-mask actL)))
  )
  (gimp-item-attach-parasite actL (list name mode tagV))
  (gimp-item-set-color-tag actL col)
)



; given a list of layers it returns a list of those layers with a parasite "tag"
; (source image, list of layers, "tag/parasite name")
(define (get-layers-tagged img lstL tag)
  (let*
    (
      (tLst ())(actL 0)(paraLst 0)(pNme 0)(i 0)(j 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paraLst (list->vector (car (gimp-item-get-parasite-list actL))))
      (when (> (vector-length paraLst) 0)
        (set! j 0)
        (while(< j (vector-length paraLst))
          (set! pNme (vector-ref paraLst j))
          (if (equal? pNme tag)(set! tLst (append tLst (list actL))))
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tLst)
  )
)


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

