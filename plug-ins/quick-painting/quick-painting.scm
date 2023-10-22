#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

(define (script-fu-quick-painting img drwbls)
  (let*
    (
      (actL (vector-ref drwbls 0))(actNme "")(quickPaintLayer #f)
      (quickInfo 0)(quickImg 0)(quickDsp 0)(quickL 0)(saveN "")(tmpL 0)
      (fileInfo 0)(fileBase 0)(fileNoExt 0)(filePath 0)(srcNme "")
      (actMsk 0)(srcMsk 0)(mde 0)(opac 100)(rootP 0)(srcImg 0)(srcL 0)
      (fileName 0)(isGrp 0)
    )
    
    (if (equal? fileName "") (exit "Please save your image before painting"))
    (set! isGrp (car (gimp-item-is-group actL)))
    (if (= isGrp 1) (exit "Not implemented group mask painting yet"))
    (if (> (vector-length drwbls) 1) (exit "Only select one layer please"))
     
    (set! fileName (car(gimp-image-get-file img)))

    (set! actL (add-alpha-to-layer actL))
    (set! actNme (car(gimp-item-get-name actL)))
    (set! quickPaintLayer (get-layer-parasite actL "quickpainting"))
    (set! opac (car (gimp-layer-get-opacity actL)))
    (set! mde (car (gimp-layer-get-mode actL)))
    
    ; create a painting image
    (when (not quickPaintLayer)

      ; establish file names
      
      (set! fileInfo (get-image-file-info img))
      (set! fileName (vector-ref fileInfo 0))
      (set! fileBase (vector-ref fileInfo 1))
      (set! fileNoExt (vector-ref fileInfo 2))
      (set! filePath (vector-ref fileInfo 3))

      ; create a new image to paint on
      (set! quickInfo (layer-to-hidden-image img actL))
      (set! quickImg (car quickInfo))
      (set! quickL (cadr quickInfo))

      ; finds inherited group hierarchy 
      (set! rootP (get-root-parent quickImg quickL))

      (if debug (gimp-message 
                  (string-append 
                    "found root parent: " 
                    (car(gimp-item-get-name rootP))
                  )
                )
      )

      ; puts the paint layer on root and removes any group nests
      (set! quickL (reorder-item quickImg quickL 0 0))
      (if (> rootP 0) (gimp-image-remove-layer quickImg rootP))

      (gimp-layer-set-composite-space quickL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
      (set! saveN (string-append filePath "/" fileNoExt "_" actNme "_quickPaint.xcf"))
      (gimp-image-set-file quickImg saveN)
      (gimp-layer-set-opacity quickL opac)
      (gimp-layer-set-mode quickL mde)

      ; take a snapshot of the image without the paint layer visible
      (gimp-item-set-visible actL 0)
      (gimp-edit-copy-visible img)
      (gimp-item-set-visible actL 1)

      ; use it as a background for the new painting image
      (set! tmpL (vector-ref (cadr(gimp-edit-paste quickL 1)) 0 ))
      (gimp-floating-sel-to-layer tmpL)
      (set! tmpL (get-active-layer quickImg))
      (gimp-image-lower-item-to-bottom quickImg tmpL)
      (gimp-item-set-name tmpL fileNoExt)
      (gimp-layer-set-offsets tmpL 0 0)

      ; set up ready to paint
      (gimp-image-set-selected-layers quickImg 1 (vector quickL))
      (if(> (car (gimp-layer-get-mask quickL)) 0) (gimp-layer-set-edit-mask quickL 1))
      (set! quickDsp (car(gimp-display-new quickImg)))

      (tag-layer quickL "quickpainting" 3 fileName 0)
      (tag-layer quickL "displayID" 3 (number->string quickDsp) 0)
    )

    ; return a painting image to the source image
    (when quickPaintLayer

      ; find the source image from the layer parasite
      (set! srcNme (get-item-parasite-string actL "quickpainting"))
      (set! fileBase (car (reverse (strbreakup srcNme DIR-SEPARATOR))))
      (set! srcImg (find-image fileBase))
      
      (set! quickDsp (string->number (get-item-parasite-string actL "displayID")))

      (when (> srcImg 0)
        (gimp-message (string-append " source image -> " srcNme))
        
        (set! srcL (find-layer srcImg actNme))
        (set! srcMsk (car (gimp-layer-get-mask srcL)))
        
        (if debug (gimp-message (string-append " source layer -> " (car(gimp-item-get-name srcL)))))

        (set! srcL (transfer-layer-to-layer img actL srcImg srcL))
        (set! actMsk (car (gimp-layer-get-mask actL)))
        (if (> actMsk 0) (transfer-mask-to-mask img actMsk srcImg srcMsk))
        (gimp-layer-set-composite-space srcL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

        (gimp-display-delete quickDsp)
      )
    )

  )
)


(script-fu-register-filter "script-fu-quick-painting"
 "Quick painting"
 "Creates a seperate image to paint the active layer in"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
 SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-quick-painting" "<Image>/Tools")


; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))

(define (exit msg)
  (gimp-message-set-handler 0)
  (gimp-message(string-append " >>> " msg " <<<"))
  (gimp-message-set-handler 2)
  (quit)
)

(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; creates a new image and display with a copy of a source layer
; (source image, source layer)
; returns a new image, a new display and the new layer
(define (layer-to-new-image img actL)
  (let*
    (
      (dstImg 0)(dstDsp 0)
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! dstDsp (car(gimp-display-new dstImg)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (list dstImg dstDsp actL)
  )
)


; creates a new image with a copy of a source layer
; (source image, source layer)
; returns a new image, and the new layer
(define (layer-to-hidden-image img actL)
  (let*
    (
      (dstImg 0)(dstDsp 0)
    )

    (gimp-selection-none img)
    (gimp-edit-copy 1 (vector actL))
    (set! dstImg (car (gimp-edit-paste-as-new-image)))
    (set! actL (vector-ref (cadr(gimp-image-get-selected-layers dstImg)) 0))
    (gimp-layer-set-composite-space actL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)

    (list dstImg actL)
  )
)


; finds the full file name, base name, stripped name, and path of a given image
; returns a vector list ("/here/myfile.xcf" "myfile.xcf" "myfile" "/here")
(define (get-image-file-info img)
  (let*
    (
      (fNme "")(fBse "")(fwEx "")(fPth "")(usr "")(strL "")
      (brkTok DIR-SEPARATOR)
    )

    (if (equal? "/" brkTok)(set! usr(getenv"HOME"))(set! usr(getenv"HOMEPATH")))

    (when (> (car (gimp-image-id-is-valid img)) 0)
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fNme (car(gimp-image-get-file img)))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth (reverse (cdr(reverse (strbreakup fNme brkTok)))))
        (set! fPth (unbreakupstr fPth brkTok))
      )

      (when (equal? (car(gimp-image-get-file img)) "")
        (set! fNme (string-append usr brkTok "Untitled.xcf"))
        (set! fBse (car (reverse (strbreakup fNme brkTok))))
        (set! fwEx (car (strbreakup fBse ".")))
        (set! fPth usr)
      )
    )

    (vector fNme fBse fwEx fPth)
  )
)


; reorder a single layer or group in the layer stack
; bug workaround, can't reorder item to root 0
; (source image, layer/group, new parent, new position)
; returns the item id
(define (reorder-item img actL parent pos)
  (let*
    (
      (buffL 0)(nme (car (gimp-item-get-name actL)))
    )
      
      (if (> parent 0)(gimp-image-reorder-item img actL parent pos))
      (gimp-selection-none img)
      ; bug workaround, can't reorder to root, remove and insert a copy at pos
      (when (= parent 0)
        (when (= (car (gimp-item-is-group actL)) 0)
          (set! buffL (car(gimp-layer-copy actL 0)))
          (gimp-image-remove-layer img actL)
          (gimp-image-insert-layer img buffL 0 pos)
          (gimp-item-set-name buffL nme)
          (set! actL buffL)
        )
        (when (= (car (gimp-item-is-group actL)) 1)
          (root-group img (vector actL))
        )
      )

    actL
  )
)


; copy all visible, or a drawable, paste into a destination layer or a new layer
; (src img, src layer/0, dst img, dst layer/0, parent, nme, crop to image size)
; returns the new layer id
(define (copy-to-new-layer img srcL dstImg dstL dstP name crop)
  (let*
    (
    (actL 0)(cur-width 0)(cur-height 0)(dstExst dstL)
    )

    (when (= srcL 0)
      (gimp-selection-none img)
      (gimp-edit-copy-visible img)
      (set! cur-width (car (gimp-image-get-width img)))
      (set! cur-height (car (gimp-image-get-height img)))
    )

    ; get size and ID of first drawable
    (when (> srcL 0)
      (gimp-selection-none img)
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
      (gimp-layer-set-composite-space dstL LAYER-COLOR-SPACE-RGB-PERCEPTUAL)
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


; macro to get the active drawable in an image, returns a layer/mask/group id
(define (get-active-layer img)
  (if (> (car(gimp-image-get-selected-layers img)) 0)
    (vector-ref (cadr(gimp-image-get-selected-layers img))0))
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



; add alpha to a layer, checking it's not a mask or group first
(define (add-alpha-to-layer actL)
  (let*
    (
      (isMsk(car (gimp-item-id-is-layer-mask actL)))
      (actNme 0)(isGrp 0)(alpha 0)
    )

    (if(= isMsk 1)(set! actL (car(gimp-layer-from-mask actL))))
    (set! actNme (car (gimp-item-get-name actL)))
    (set! isGrp (car (gimp-item-is-group actL )))
    (set! alpha (car (gimp-drawable-has-alpha actL)))
    (if (and (= isGrp 0) (= alpha 0)) (gimp-layer-add-alpha actL))

    actL
  )
)



; returns #t or #f if parasite is on a specified layer
; (layer id, parasite name)
(define (get-layer-parasite actL paraNme)
  (let*
    (
      (i 0)(actP 0)(fnd #f)
      (para (list->vector (car(gimp-item-get-parasite-list actL))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fnd #t)
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fnd
  )
)


; returns the value string of a parasite on a specified layer
; (layer id, parasite name)
(define (get-item-parasite-string actL paraNme)
  (let*
    (
      (i 0)(actP 0)(fndV "")
      (para (list->vector (car(gimp-item-get-parasite-list actL))))
    )

    (while (< i (vector-length para))
      (set! actP (vector-ref para i))
      (when (equal? actP paraNme)
        (set! fndV (caddar(gimp-item-get-parasite actL actP)))
        (set! i (vector-length para))
      )
      (set! i (+ i 1))
    )

  fndV
  )
)


; finds a named image if it is open, compares the "filename.ext", returns the ID
(define (find-image findName)
  (let*
    (
      (openImages 0)(img 0)(fileName 0)(fileBase 0)(i 0)(valid 0)
      (brkTok DIR-SEPARATOR)(foundID 0)
    )

    (set! openImages (gimp-get-images))
    (while (< i (car openImages))
      (set! img (vector-ref (cadr openImages) i))
      (when (not(equal? (car(gimp-image-get-file img)) ""))
        (set! fileName (car(gimp-image-get-file img)))
        (set! fileBase (car (reverse (strbreakup fileName brkTok))))
        (when (equal? fileBase findName)
          (set! valid (car (gimp-image-id-is-valid img)))
          (if (= valid 1) (set! foundID img))
          (set! i (car openImages))
        )
      )
      (set! i (+ i 1))
    )

  foundID
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



; copies a layer to a layer, returns layer ID
;(source image, source layer, destination image, destination layer)
(define (transfer-layer-to-layer srcImg srcL dstImg dstL)
    (gimp-selection-none srcImg)
    (gimp-edit-copy 1 (vector srcL))
    (set! dstL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-floating-sel-anchor dstL)

    (vector-ref (cadr(gimp-image-get-selected-layers srcImg)) 0)
)


; copies a mask to a mask, or layer to a mask
; (source image, src mask/layer, destination image, dst mask)
; returns the destination mask id
(define (transfer-mask-to-mask srcImg srcM dstImg dstM)
  (let*
    (
      (srcL 0)
      (offX 0)
      (offY 0)
    )

    (if (= (car (gimp-item-id-is-layer-mask srcM)) 1)
      (set! srcL (car(gimp-layer-from-mask srcM)))
        (set! srcL srcM)
    )

    (set! offX (car(gimp-drawable-get-offsets srcL )))
    (set! offY (cadr(gimp-drawable-get-offsets srcL )))

    (gimp-selection-none srcImg)
    (gimp-edit-copy 1 (vector srcM))
    (set! dstM (vector-ref (cadr(gimp-edit-paste dstM 1)) 0 ))
    (gimp-layer-set-offsets dstM offX offY)
    (gimp-floating-sel-anchor dstM)

    (set! dstM (vector-ref (cadr(gimp-image-get-selected-layers dstImg))0))
    (set! dstM (car(gimp-layer-get-mask dstM)))

    dstM
  )
)


; returns the last parent group before root encountered at (-1)
(define (get-root-parent img actL)
  (let*
    (
      (parent 0)(prevParent 0)
    )

    (set! parent (car(gimp-item-get-parent actL)))
   
    (when (> parent 0)
      (while (> parent 0)
        (set! prevParent parent)
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )
   
    prevParent
  )
)


