## Isolate Selected Layers

# * Tested in GIMP 2.99.14 *

GIMP 3 allows multilayer selection, which is a great boost for plug-ins. This plugin allows the user to isolate a selection of layers or groups. If the selection hasn't changed since it last ran, it toggles the isolation mode off again. There's a second plugin, exit isolation that just exits the isolated state.  

I'm trying out a new approach with these plugins, they are very slow on big files due to the way GIMP works. So they now use a 'C' utility function that gives them a massive speed up. That function is just another plugin and can be found [here.](https://github.com/script-fu/script-fu.github.io/tree/main/plug-ins/set-items-visibility/); 
  
The Isolate plug-ins should appear in the Tools menu.  
  
To download [**isolateSelected.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/isolateSelected/isolateSelected.scm) and [**exitIsolation.scm**](https://raw.githubusercontent.com/script-fu/script-fu.github.io/main/plug-ins/exitIsolation/exitIsolation.scm)...
...follow the link, right click the page, Save as isolateSelected.scm, in a folder called isolateSelected, in a GIMP plug-ins location.  In Linux, set the file to be executable.

To download the required utility function [set-items-visibility](https://github.com/script-fu/script-fu.github.io/tree/main/plug-ins/set-items-visibility/set-items-visibility)...
...follow the link, download button, download raw file, in a GIMP plug-ins location.  


<!-- include-plugin "isolateSelected" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

;Under GNU GENERAL PUBLIC LICENSE Version 3
(define (script-fu-isolateSelected img drwbles)
  (let*
    (
      (lstL 0)(tgdLst 0)(isolated 0)(isoPLst 0)(changed 1)
      (types (vector "isolated" "hidden" "hiddenChld" "isoChild"))
    )

     (gimp-image-undo-group-start img)

    ; when the plugin is not locked
    (when (= (plugin-get-lock "isolateSelected") 0)
      (plugin-set-lock "isolateSelected" 1) ; now lock it
      (plugin-set-lock "exitIsolation" 1) ; and the exit plugin

      ; if user selected a mask to isolate, show mask and switch mask to a layer
      (set! drwbles (show-mask drwbles isolated))

      ; get all the layers and groups
      (set! lstL (all-childrn img 0))

      ; existing isolation mode? has selection changed since last time?
      (set! tgdLst (find-layers-tagged img lstL "isolated"))
      (when (> (vector-length tgdLst) 0)
        (set! isolated 1)
        (if debug (gimp-message " image in isolation mode ")) 
        (if (= (number-lists-match tgdLst drwbles) 1) (set! changed 0))
      )

      ; exit isolated mode and enter a new one if user selection has changed
      (when (= isolated 1)
        (revert-layer img lstL types)
        (if (= changed 1) (set! isolated 0)
        (if debug (gimp-message " exit isolation mode "))
        )
      )

      ; create a new isolation mode
      (when (= isolated 0)
        (if debug (gimp-message " isolation mode "))

        ; isolate and tag selected layers
        (set! isoPLst (isolate-selected-layers img drwbles))

        ; hide and process all the other layers
        (hide-layers img drwbles lstL isoPLst)
      )

      ; unlock the plugins
      (plugin-set-lock "isolateSelected" 0)
      (plugin-set-lock "exitIsolation" 0)
      (gimp-displays-flush)

    )

    (gimp-image-undo-group-end img)
  )
)


(define (hide-layers img drwbles lstL isoPLst)
  (let*
    (
      (i 0)(actL 0)(parent 0)(hdCol 6)
      (lstL (list->vector lstL))(visLst ())(isGrp 0)
    )

    ; look through all the layers for layers to hide
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))

      ; not a parent of, in the same group as the selected layer, hide it
      (when (not (member actL (vector->list drwbles)))
        (set! parent (car(gimp-item-get-parent actL)))
        (when (member parent isoPLst)
          (when (= (find-parasite-on-layer actL "isoParent") 0)
            (iso-tag-layer actL "hidden")
            (set! visLst (append visLst (list actL)))
          )
        )
      )

      (set! i (+ i 1))
    )

    (set! visLst (list->vector visLst))

    ;Experimental plug-in, hide all the list in one pass
    (pm-set-items-visibility 1 img (vector-length visLst) visLst 0)

  )
)


(define (isolate-selected-layers img drwbles)
  (let*
    (
      (i 0)(actL 0)(isoPLst ())(isoLst())(isGrp 0)(isoCol 2)(vis 1)
    )

    ; look through the selected layers
    (while (< i (vector-length drwbles))
      (set! actL (vector-ref drwbles i))

      (if debug
        (gimp-message
          (string-append "selected ->  " (car(gimp-item-get-name actL))
          )
        )
      )

      (iso-tag-layer actL "isolated")
      (set! isoLst (append isoLst (list actL)))

      ; list all the selected layers direct parents - used to hide siblings
      (set! isoPLst (append isoPLst (list (car(gimp-item-get-parent actL)))))
      (set! i (+ i 1))
    )

    (set! isoPLst (remove-duplicates isoPLst))
    (set! isoLst (list->vector isoLst))

    ; visual updates all at once
    (set! i 0)
    (while (< i (vector-length isoLst))
      (set! actL (vector-ref isoLst i))
      (set! isGrp (car (gimp-item-is-group actL)))
      ;(gimp-layer-set-opacity actL 100) 
      (gimp-item-set-color-tag actL isoCol)
      ; if it's not a group and is not in normal mode, set the layer to normal
      (if (and (= isGrp 0) (not (= (car (gimp-layer-get-mode actL)) 28)))
        (gimp-layer-set-mode actL LAYER-MODE-NORMAL))

      (set! vis (* vis (car(gimp-item-get-visible actL))))
      (set! i (+ i 1))
    )

    ; Experimental plug-in, make all isolated visible, if any were hidden
    (when (= vis 0)
      (if debug
        (gimp-message
          (string-append " vis ->  " (number->string vis)
                         " \ngoing to make all selected visible "
          )
        )
      )
      (pm-set-items-visibility 1 img (vector-length isoLst) isoLst 1)
    )

    isoPLst
  )
)


(define (iso-tag-layer actL tag)
  (let*
    (
      (visTag 0)(colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(mde 3)(dataStr "")
      (pLst 0)(marked "")(i 0)
      (types (list "isolated" "hidden" "hiddenChld" "isoChild"))
    )

    (set! pLst (car(gimp-item-get-parasite-list actL)))
    (when (> (length pLst) 0)
      (if debug (gimp-message " existing parasites found on layer! " )) 
      (while (< i (length pLst))
        (if (member (list-ref pLst i) types)(set! marked (list-ref pLst i)))
        (set! i (+ i 1))
      )
    )

    (when (not (equal? marked ""))
      (if debug
        (gimp-message
          (string-append
            " trying to tag as -> " tag
            "\n but already tagged ->  " (car(gimp-item-get-name actL))
            "\n as -> " marked
          )
        )
      )
    )

    (when (equal? marked "")
      (set! colTag (number->string (car(gimp-item-get-color-tag actL ))))
      (set! visTag (number->string (car(gimp-item-get-visible actL))))
      (set! modeTag (number->string (car(gimp-layer-get-mode actL))))
      (set! opaTag (number->string (car(gimp-layer-get-opacity actL))))
      (set! dataStr (string-append colTag "_" visTag "_" modeTag "_" opaTag))
      (gimp-item-attach-parasite actL (list tag mde dataStr))
    )

  )
)


(script-fu-register-filter "script-fu-isolateSelected"
  "Isolate" 
  "Isolates the selected layers" 
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE ;
)
(script-fu-menu-register "script-fu-isolateSelected" "<Image>/Tools")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; filters a list, removing duplicates, returns a new list
(define (remove-duplicates grpLst)
  (let*
    (
      (i 0)(actGrp 0)(uniqGrps ())
    )
    
    (if (list? grpLst) (set! grpLst (list->vector grpLst)))
    (while (< i (vector-length grpLst))
      (set! actGrp (vector-ref grpLst i))
      (when (not (member actGrp uniqGrps))
         (set! uniqGrps (append uniqGrps (list actGrp)))
       )
      (set! i (+ i 1))
    )

  uniqGrps
  )
)


; stores and sets the visibility state of a layer list
(define (set-list-visibility img lstL vis)
  (let*
    (
      (vLst())(i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))

    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! vLst (append vLst (list actL (car(gimp-item-get-visible actL)))))
      ;(gimp-item-set-visible actL vis)
      (set! i (+ i 1))
    )

    ;Experimental plug-in
    (pm-set-items-visibility 1 img (vector-length lstL) lstL vis)

    ;return the list of stored visibility states
    vLst
  )
)


; creates a "plugin" file on disk and writes the first line, lock (0/1)
(define (plugin-set-lock plugin lock)
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)




; looks for a "plugin" file on disk and reads the first line
; returns the first line. used to see if a plugin is already active/locked
(define (plugin-get-lock plugin) 
  (let*
    (
      (input (open-input-file plugin))
      (lockValue 0)
    )

    (if input (set! lockValue (read input)))
    (if input (close-input-port input))

    lockValue
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


; given a list of layers and a "parasite" name it returns those layers with it
(define (find-layers-tagged img lstL tag)
  (let*
    (
      (tgdLst ())(pCountr 0)(actL 0)(paras 0)(pCount 0)
      (lstP 0)(pName 0)(i 0)(j 0)
    )

    (set! lstL (list->vector lstL))

    (set! i 0)
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paras (car (gimp-item-get-parasite-list actL)))
      (set! pCount (length paras))
      (when (> pCount 0)
        (set! lstP (list->vector paras))
        (set! j 0)
        (while(< j pCount)
          (set! pName (vector-ref lstP j))
          (when (equal? pName tag)
            (set! tgdLst (append tgdLst (list actL)))
            (set! pCountr (+ pCountr 1))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tgdLst)
  )
)


; does the layer have a specific parasite
(define (find-parasite-on-layer actL tag)
  (let*
    (
      (i 0)(paras 0)(pCount 0)(lstP 0)(pName "")(found 0)
    )

    (set! paras (car (gimp-item-get-parasite-list actL)))
    (set! pCount (length paras))
    (set! lstP (list->vector paras))

    (when (> pCount 0)
      (while(< i pCount)
        (set! pName (vector-ref lstP i))
        
        (when (equal? tag pName)
          (set! found 1)
          (set! i pCount)
        )
      (set! i (+ i 1))
      )
    )

    found
  )
)


; compares two lists of numbers and tests for a perfect match
; returns 1 or 0
(define (number-lists-match lstA lstB)
  (let
    (
      (match 0)
    )

    (if (vector? lstA) (set! lstA (vector->list lstA)))
    (if (vector? lstB) (set! lstB (vector->list lstB)))

    (when (not (null? lstA))
      (when (= (length lstA) (length lstB))
        (set! lstA (bubble-sort (length lstA) lstA))
        (set! lstB (bubble-sort (length lstB) lstB))
        (if (equal? lstA lstB) (set! match 1))
      )
    )

  match
  )
)


; bubble sorting from;
; https://stackoverflow.com/users/2860713/avery-poole
; https://stackoverflow.com/users/201359/%c3%93scar-l%c3%b3pez
; thanks!
(define (bubble-up lst)
  (if (null? (cdr lst))
    lst
     (if (< (car lst) (cadr lst))
       (cons (car lst) (bubble-up (cdr lst)))
         (cons (cadr lst) (bubble-up (cons (car lst) (cddr lst))))
     )
  )
)
(define (bubble-sort len lst)
  (cond ((= len 1) (bubble-up lst))
    (else (bubble-sort (- len 1) (bubble-up lst)))
  )
)


; filters out children from a list of layers
; returns the top levels groups, or layers that are in the root and in the list
(define (exclude-children img lstL)
  (let*
    (
    (i 0)(actL 0)(excLst())(parent 0)(allParents 0)(j 0)(found 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! j 0)
      (set! found 0)
      (set! allParents (get-all-parents img actL))

      (while (< j (length allParents))
        (set! parent (nth j allParents))
          (when (and (member parent (vector->list lstL))
                (car (gimp-item-is-group actL)) )
            (set! found 1)
          )
      (set! j (+ j 1))
      )

      (when (= found 0)
        (set! excLst (append excLst (list actL)))
      )

      (set! i (+ i 1))
    )

  (list->vector excLst)
  )
)


(define (get-all-parents img actL)
  (let*
    (
      (parent 0)(allParents ())(i 0)
    )

    (set! parent (car(gimp-item-get-parent actL)))

    (when (> parent 0)
      (while (> parent 0)
        (set! allParents (append allParents (list parent)))
        (set! parent (car(gimp-item-get-parent parent)))
      )
    )

    allParents
  )
)



; first layer in a given list is set to show it's mask
(define (show-mask drwbles isolated)
  (let*
    (
      (actL (vector-ref drwbles 0))(size (vector-length drwbles))
      (show (- 1 isolated))
    )

    ; if it's a mask and the only item selected, switch to layer, show the mask
    (when (and (= size 1) (= (car (gimp-item-id-is-layer-mask actL )) 1))
      (if debug (gimp-message " only a mask selected "))
      (vector-set! drwbles 0 (car(gimp-layer-from-mask actL)))
      (gimp-layer-set-show-mask (vector-ref drwbles 0) show)
    )

  drwbles
  )
)



; part of isolate selected
(define (revert-layer img lstL types)
  (let*
    (
      (tagLst 0)(i 0)(actL 0)(t 0)(actT "")(isoP 0)(hLst())(vLst())(visTag 0)
    )

    ; restore every type
    (while (< t (vector-length types))
      (set! actT (vector-ref types t))
      (if debug (gimp-message actT))
      (set! tagLst (find-layers-tagged img lstL actT))
      (set! tagLst (remove-duplicates (vector->list tagLst)))
      (set! tagLst (list->vector tagLst))
      (when (> (vector-length tagLst) 0)
        (set! i 0)
        (while (< i (vector-length tagLst))
          (set! visTag 0)
          (set! actL (vector-ref tagLst i))
          (set! visTag (restore-layer actL actT))

          (if (= visTag 1) (set! vLst (append vLst (list actL))))
          (if (= visTag 0) (set! hLst (append hLst (list actL))))

          (set! i (+ i 1))
        )
      )
      (set! t (+ t 1))
    )

    (when debug (gimp-message " restore visible layers:")
      (print-layer-id-name vLst)
    )

    (when debug (gimp-message " restore hidden layers: ")
      (print-layer-id-name hLst)
    )

    (set! vLst (list->vector vLst))
    (set! hLst (list->vector hLst))

    ; final pass - restore visibility for tagged layers
    (pm-set-items-visibility 1 img (vector-length vLst) vLst 1)
    (pm-set-items-visibility 1 img (vector-length hLst) hLst 0)

  )
)


; part of isolate selected
(define (restore-layer actL actT)
  (let*
    (
      (len (length (car(gimp-item-get-parasite-list actL))))
      (colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(dataStr "")
    )

    (when (> len 0)
      ; retrieve stored layer data
      (set! dataStr (caddar (gimp-item-get-parasite actL actT)))
      (set! dataStr (strbreakup dataStr "_"))
      (set! colTag (string->number (car dataStr)))
      (set! visTag (string->number (cadr dataStr)))
      (set! modeTag (string->number (caddr dataStr)))
      (set! opaTag (string->number (cadddr dataStr)))
      (gimp-item-set-color-tag actL colTag)
      (gimp-layer-set-opacity actL opaTag)

      ; special case, restore mode of isolated layer
      (if (equal? "isolated" actT) (gimp-layer-set-mode actL modeTag))

      (gimp-item-detach-parasite actL actT)
      (if (> (car(gimp-layer-get-mask actL)) 0)
        (gimp-layer-set-show-mask actL 0)
      )
    )

  visTag
  )
)



; prints the layer name and id of every layer in a list in one string
(define (print-layer-id-name lstL)
  (let*
    (
      (i 0)(strL "")(msg " ")(actL 0)(id "")(nme "")
    )
    (if (list? lstL) (set! lstL (list->vector lstL)))
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (when (= (car (gimp-item-id-is-valid actL)) 1)
        (set! id (number->string actL))
        (set! nme (car(gimp-item-get-name actL)))
        (set! strL (string-append strL msg id " : " nme "\n"))
      )
      (set! i (+ i 1))
    )
    (gimp-message strL)
  )
)

```
  
*a second plug-in to exit the isolated state*  

<!-- include-plugin "exitIsolation" -->
```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define debug #f)

;Under GNU GENERAL PUBLIC LICENSE Version 3
(define (script-fu-exitIsolation img drwbles)
  (let*
    (
      (lstL 0)(fileNme "")(fndP 0)
      (types (vector "isolated" "hidden" "isoParent" "hiddenChld" "isoChild"))
    )

    (gimp-image-undo-group-start img)

    ; when the plugin is not locked via a text file
    (when (= (plugin-get-lock "exitIsolation") 0)

      (plugin-set-lock "exitIsolation" 1) ; now lock it
      (plugin-set-lock "isolateSelected" 1)

      ; store all the layers and groups
      (set! lstL (all-childrn img 0))
      (revert-layer img lstL types)

      (plugin-set-lock "exitIsolation" 0) ; unlock the plugin
      (plugin-set-lock "isolateSelected" 0) ; unlock the isolate plugin
      (gimp-displays-flush)
    )

    (gimp-message " exit isolation ")
    (gimp-image-undo-group-end img)

  )
)

(script-fu-register-filter "script-fu-exitIsolation"
  "Isolate Exit" 
  "Exit isolation mode" 
  "Mark Sweeney"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2023"
  "*"
  SF-ONE-OR-MORE-DRAWABLE ;
)
(script-fu-menu-register "script-fu-exitIsolation" "<Image>/Tools")

; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))


; creates a "plugin" file on disk and writes the first line, lock (0/1)
(define (plugin-set-lock plugin lock)
  (let*
    (
      (output (open-output-file plugin))
    )

    (display lock output)
    (close-output-port output)

  )
)




; looks for a "plugin" file on disk and reads the first line
; returns the first line. used to see if a plugin is already active/locked
(define (plugin-get-lock plugin) 
  (let*
    (
      (input (open-input-file plugin))
      (lockValue 0)
    )

    (if input (set! lockValue (read input)))
    (if input (close-input-port input))

    lockValue
  )
)


; filters a list, removing duplicates, returns a new list
(define (remove-duplicates grpLst)
  (let*
    (
      (i 0)(actGrp 0)(uniqGrps ())
    )
    
    (if (list? grpLst) (set! grpLst (list->vector grpLst)))
    (while (< i (vector-length grpLst))
      (set! actGrp (vector-ref grpLst i))
      (when (not (member actGrp uniqGrps))
         (set! uniqGrps (append uniqGrps (list actGrp)))
       )
      (set! i (+ i 1))
    )

  uniqGrps
  )
)


; stores and sets the visibility state of a layer list
(define (set-list-visibility img lstL vis)
  (let*
    (
      (vLst())(i 0)(actL 0)
    )

    (if (list? lstL) (set! lstL (list->vector lstL)))

    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! vLst (append vLst (list actL (car(gimp-item-get-visible actL)))))
      ;(gimp-item-set-visible actL vis)
      (set! i (+ i 1))
    )

    ;Experimental plug-in
    (pm-set-items-visibility 1 img (vector-length lstL) lstL vis)

    ;return the list of stored visibility states
    vLst
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


; given a list of layers and a "parasite" name it returns those layers with it
(define (find-layers-tagged img lstL tag)
  (let*
    (
      (tgdLst ())(pCountr 0)(actL 0)(paras 0)(pCount 0)
      (lstP 0)(pName 0)(i 0)(j 0)
    )

    (set! lstL (list->vector lstL))

    (set! i 0)
    (while (< i (vector-length lstL))
      (set! actL (vector-ref lstL i))
      (set! paras (car (gimp-item-get-parasite-list actL)))
      (set! pCount (length paras))
      (when (> pCount 0)
        (set! lstP (list->vector paras))
        (set! j 0)
        (while(< j pCount)
          (set! pName (vector-ref lstP j))
          (when (equal? pName tag)
            (set! tgdLst (append tgdLst (list actL)))
            (set! pCountr (+ pCountr 1))
          )
          (set! j (+ j 1))
        )
      )
      (set! i (+ i 1))
    )

    (list->vector tgdLst)
  )
)


; part of isolate selected
(define (revert-layer img lstL types)
  (let*
    (
      (tagLst 0)(i 0)(actL 0)(t 0)(actT "")(isoP 0)(hLst())(vLst())(visTag 0)
    )

    ; restore every type
    (while (< t (vector-length types))
      (set! actT (vector-ref types t))
      (if debug (gimp-message actT))
      (set! tagLst (find-layers-tagged img lstL actT))
      (set! tagLst (remove-duplicates (vector->list tagLst)))
      (set! tagLst (list->vector tagLst))
      (when (> (vector-length tagLst) 0)
        (set! i 0)
        (while (< i (vector-length tagLst))
          (set! visTag 0)
          (set! actL (vector-ref tagLst i))
          (set! visTag (restore-layer actL actT))

          (if (= visTag 1) (set! vLst (append vLst (list actL))))
          (if (= visTag 0) (set! hLst (append hLst (list actL))))

          (set! i (+ i 1))
        )
      )
      (set! t (+ t 1))
    )

    (when debug (gimp-message " restore visible layers:")
      (print-layer-id-name vLst)
    )

    (when debug (gimp-message " restore hidden layers: ")
      (print-layer-id-name hLst)
    )

    (set! vLst (list->vector vLst))
    (set! hLst (list->vector hLst))

    ; final pass - restore visibility for tagged layers
    (pm-set-items-visibility 1 img (vector-length vLst) vLst 1)
    (pm-set-items-visibility 1 img (vector-length hLst) hLst 0)

  )
)


; part of isolate selected
(define (restore-layer actL actT)
  (let*
    (
      (len (length (car(gimp-item-get-parasite-list actL))))
      (colTag 0)(modeTag 0)(opaTag 0)(visTag 0)(dataStr "")
    )

    (when (> len 0)
      ; retrieve stored layer data
      (set! dataStr (caddar (gimp-item-get-parasite actL actT)))
      (set! dataStr (strbreakup dataStr "_"))
      (set! colTag (string->number (car dataStr)))
      (set! visTag (string->number (cadr dataStr)))
      (set! modeTag (string->number (caddr dataStr)))
      (set! opaTag (string->number (cadddr dataStr)))
      (gimp-item-set-color-tag actL colTag)
      (gimp-layer-set-opacity actL opaTag)

      ; special case, restore mode of isolated layer
      (if (equal? "isolated" actT) (gimp-layer-set-mode actL modeTag))

      (gimp-item-detach-parasite actL actT)
      (if (> (car(gimp-layer-get-mask actL)) 0)
        (gimp-layer-set-show-mask actL 0)
      )
    )

  visTag
  )
)


```
