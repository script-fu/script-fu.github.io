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

