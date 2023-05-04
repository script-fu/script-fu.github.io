## Ghost Layer

# * Tested in Gimp 2.99.14 *
  
A little timesaver to set up a pencil layer for inking.
The plug-ins should appear in the Layer menu.  
  
To download [**ghostLayer.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/ghostLayer/ghostLayer.scm)  
...follow the link, right click the page, Save as ghostLayer.scm, in a folder called ghostLayer, in a Gimp plug-ins location.  
In Linux, set the file to be executable.
   

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-ghostLayer img drawables) 
  (let*
    (
      (ghostOpacity 70) ; default opacity value for ghosting
      (actL (vector-ref drawables 0))(inkL 0) (unlck 0)(whtL 0)
      (nme (car (gimp-item-get-name actL)))
      (ghostName (string-append "ghosted-original-" nme ))
      (blankName (string-append "ghost-opacity-" nme ))
      (mde LAYER-MODE-MULTIPLY)(vis 1)(ghstGrp 0)
      (isGrp (car (gimp-item-is-group actL)))
    )

    (when (= isGrp 0)
      (gimp-image-undo-group-start img)
      (gimp-item-set-lock-content actL 0)
      (set! inkL (duplicate-layer img actL "tmpNme" 100 mde vis))
      (gimp-drawable-fill inkL FILL-WHITE)
      (gimp-item-set-name actL ghostName)
      (gimp-item-set-name inkL nme)
      (set! mde LAYER-MODE-NORMAL)
      (set! whtL (duplicate-layer img inkL blankName ghostOpacity mde vis))
      (set! ghstGrp (layer-group img (vector whtL actL)))
      (gimp-item-set-expanded ghstGrp 0)
      (gimp-item-set-lock-content ghstGrp 1)
      (gimp-image-raise-item img inkL)
      (gimp-image-set-selected-layers img 1 (vector inkL))
      (gimp-displays-flush)
      (gimp-image-undo-group-end img)
    )
    (when (= isGrp 1) (gimp-message " not ghosting a group "))
   
  )
)


(define (duplicate-layer img srcL name opac mode vis)
  (let*
    (
      (actL 0)(parent 0)(pos 0)
    )

    (set! parent (car (gimp-item-get-parent srcL)))
    (set! pos (car (gimp-image-get-item-position img srcL)))
    (set! actL (car (gimp-layer-new-from-drawable srcL img)))
    (gimp-image-insert-layer img actL parent pos)
    (gimp-layer-set-opacity actL opac)
    (gimp-layer-set-mode actL mode)
    (gimp-item-set-name actL name)
    (gimp-item-set-visible actL vis)

  actL
  )
)


(define (layer-group img drwbls)
 (let*
    (
      (mde LAYER-MODE-NORMAL) ; LAYER-MODE-NORMAL ; LAYER-MODE-MULTIPLY
      (nme "ghost")
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

(script-fu-register-filter "script-fu-ghostLayer"
  "Ghost Layer"
  "Turns a layer into a underlay ghost, puts a blank multiply layer on top" 
  "Mark Sweeney"
  "copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-DRAWABLE
)
(script-fu-menu-register "script-fu-ghostLayer" "<Image>/Layer")

```