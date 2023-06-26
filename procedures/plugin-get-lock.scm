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