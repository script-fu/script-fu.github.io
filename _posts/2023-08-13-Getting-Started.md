
## Plugin Examples - Getting Started

The bare essentials of a Script-Fu plugin for GIMP 3 are described below.

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-basic-plugin image drawables)
  (let*
    (
      (message " hello world ")
      (returnValue 42)
    )

    (gimp-message message)

    returnValue
  )
)

(script-fu-register-filter "script-fu-basic-plugin"
  "Basic Plugin Demo"
  "tests a basic Script-Fu filter plugin"
  "Author Name"
  "License"
  "Date written"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
)

(script-fu-menu-register "script-fu-basic-plugin" "<Image>/Plugin")
```

Copy the text and save as _basic-plugin.scm_ in a folder called _basic-plugin_ in a GIMP plugins folder. A GIMP plugins folder is _any_ folder included in _GIMP->Edit->Preferences->Folders->Plug-ins_. Once installed it will appear in a new menu called Plugin.  

<sub>The first line makes the script work as a plugin in GIMP 3</sub>

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0  
```  

<sub>The main procedure definition, "script-fu-basic-plugin". It has two arguments, the active image and the selected drawables</sub>

```scheme
(define (script-fu-basic-plugin image drawables) 
```

<sub>A _let*_ statement defines a scope, declares variables and contains expressions</sub>

```scheme
(let*
  (
    (message " hello world ") ; this defines a variable that is a string
    (returnValue 42)          ; an integer variable
  )

  (gimp-message message)      ; an expression to be evaluated

  returnValue                 ; the last value of the procedure and so it becomes the  
                              ; return value of the procedure
)
```

<sub>The main procedure is registered with GIMP as a filter plugin via a register function call with mainly string arguments</sub>

```scheme
(script-fu-register-filter "script-fu-basic-plugin" ; register the main procedure
  "Basic Plugin Demo"                               ; the name as it appears in the GIMP menu
  "tests a basic Script-Fu filter plugin"           ; tool-tip
  "Author Name"                                     ; give yourself some credit
  "License"                                         ; license
  "Date written"                                    ; date written
  "*"                                               ; * means this plugin needs an image
  SF-ONE-OR-MORE-DRAWABLE                           ; needs one or more layers selected
)

```

<sub>The plugin is registered with GIMP for a menu location</sub>

```scheme
(script-fu-menu-register "script-fu-basic-plugin" "<Image>/Plugin")
```

## Shorter Variable Names

The same plugin can be given made more concise with shorter variable names.  Which I've learned makes the script _more_ readable as each line of code is shorter.

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-basic-plugin img selV)
  (let*
    (
      (msg " hello world ")(retV 42)
    )

    (gimp-message msg)

    retV
  )
)

(script-fu-register-filter "script-fu-basic-plugin"
  "Basic Plugin Demo"
  "tests a basic Script-Fu filter plugin"
  "Author Name"
  "License"
  "Date written"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
)

(script-fu-menu-register "script-fu-basic-plugin" "<Image>/Plugin")
```

## Without a let* Statement

In this case we don't really need the _(let*)_  statement scope, variables or the return value.

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-basic-plugin img selV) (gimp-message " hello world "))

(script-fu-register-filter "script-fu-basic-plugin"
  "Basic Plugin Demo"
  "tests a basic Script-Fu filter plugin"
  "Author Name"
  "License"
  "Date written"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
)

(script-fu-menu-register "script-fu-basic-plugin" "<Image>/Plugin")

```

## Working Without an Image

If you don't need an image or layers to work on, we can define the most basic plugin. Notice there are no arguments for the main procedure, the "*" argument has become an empty string, and the line with SF-ONE-OR-MORE-DRAWABLE has gone.

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (script-fu-basic-plugin) (gimp-message " hello world "))

(script-fu-register "script-fu-basic-plugin" 
  "Basic Plugin Demo" 
  "tests a basic Script-Fu plugin"
  "Author Name" "License" "Date written" ""
)

(script-fu-menu-register "script-fu-basic-plugin" "<Image>/Plugin")
```

## Four Lines

A four line plugin is all you need to get started writing your own tools.

```scheme
#!/usr/bin/env gimp-script-fu-interpreter-3.0
(define (script-fu-basic-plugin) (gimp-message " hello world "))
(script-fu-register "script-fu-basic-plugin" "Basic" "test" "me" "free" "2023" "")
(script-fu-menu-register "script-fu-basic-plugin" "<Image>/Plugin")
```
