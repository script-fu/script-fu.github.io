#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-copy-group-to-component img drawables)
  (let*
    (
      (dstL (vector-ref drawables 0))
      (numSel (vector-length drawables))
      (isGrp 0)
      (actL 0)
      (dstGrp 0)
    )

    (if (> numSel 2)
      (exit " before running the plug-in, please select a group and a layer ")
    )

    (if (< numSel 2)
      (exit " before running the plug-in, please select a group and a layer ")
    )

    (set! dstGrp (vector-ref drawables 1))

    (gimp-image-undo-group-start img)
    (gimp-selection-none img)

    ; sort the selection into a layer and group, is the layer the group?
    (set! isGrp (car (gimp-item-is-group dstL)))

    ; the group should be a group
    (when (= isGrp 0)
      (set! isGrp (car (gimp-item-is-group dstGrp)))
      (if (= isGrp 0 )
        (exit " before running the plug-in, please select a group and a layer ")
      )
    )

    ; switch around the variables so group is group, layer is layer
    (when (= isGrp 1)
      (set! actL dstGrp)
      (set! dstGrp dstL)
      (set! dstL actL)
    )

    (if debug
      (gimp-message
        (string-append
        " source group is -> " (car(gimp-item-get-name dstGrp))
        "\n destination layer is -> " (car(gimp-item-get-name dstL))
        )
      )
    )

    ; copy the group and set the component states
    (gimp-edit-copy 1 (vector dstGrp))

    (gimp-image-set-component-visible img CHANNEL-RED 1)
    (gimp-image-set-component-visible img CHANNEL-GREEN 0)
    (gimp-image-set-component-visible img CHANNEL-BLUE 0)
    (gimp-image-set-component-visible img CHANNEL-ALPHA 0)
    (gimp-image-set-component-active img CHANNEL-RED 1)
    (gimp-image-set-component-active img CHANNEL-GREEN 0)
    (gimp-image-set-component-active img CHANNEL-BLUE 0)
    (gimp-image-set-component-active img CHANNEL-ALPHA 0)

    ; paste and anchor
    (set! actL (vector-ref (cadr(gimp-edit-paste dstL 1)) 0 ))
    (gimp-selection-none img)
    (gimp-floating-sel-anchor actL)

    ; set the component states
    (gimp-image-set-component-visible img CHANNEL-RED 1)
    (gimp-image-set-component-visible img CHANNEL-GREEN 1)
    (gimp-image-set-component-visible img CHANNEL-BLUE 1)
    (gimp-image-set-component-visible img CHANNEL-ALPHA 1)
    (gimp-image-set-component-active img CHANNEL-RED 1)
    (gimp-image-set-component-active img CHANNEL-GREEN 1)
    (gimp-image-set-component-active img CHANNEL-BLUE 1)
    (gimp-image-set-component-active img CHANNEL-ALPHA 1)

    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(define debug #f)

(script-fu-register-filter "script-fu-copy-group-to-component"
 "Copy Group to Component"
 "copy a selected group to a selected layer and a specific component, like the red channel"
 "Mark Sweeney"
 "Under GNU GENERAL PUBLIC LICENSE Version 3"
 "2023"
 "*"
SF-ONE-OR-MORE-DRAWABLE

)
(script-fu-menu-register "script-fu-copy-group-to-component" "<Image>/Tools")



; copyright 2023, Mark Sweeney, Under GNU GENERAL PUBLIC LICENSE Version 3

; utility functions
(define (boolean->string bool) (if bool "#t" "#f"))
(define (exit msg)(gimp-message(string-append " >>> " msg " <<<"))(quit))
(define (here x)(gimp-message(string-append " >>> " (number->string x) " <<<")))

