
### Quickstart in Script-Fu - GIMP 2.10.30

* Create a local directory as a sandbox for new scripts.
*YourPath->scripts*

Add that directory in Gimp as a scripts folder
*Gimp->Edit->Preferences->Folders->Scripts*
Restart Gimp, any scripts in that new folder should appear as menu items or
useable procedures.

* After editing and saving a script, refresh scripts in Gimp,
*Filters->Script-Fu->Refresh Scripts*
It's easier to set up a keyboard shortcut to refresh scripts. 
*Gimp->Edit->Keyboard Shortcuts*

* Keep the Error Console window open. It's the only way I've been able to find
to debug a script.
*Gimp->Windows->Dockable Dialogues->Error Console*

* Scripts copied from the blog posts should be saved as the same name as the
define name.For example, a script defined as *bareBones* would be saved as
*bareBones.scm* in a scripts folder.

### Quickstart in Script-Fu Plug-Ins - GIMP 2.99.14 - in developement

* Create a local directory as a sandbox for new plug-ins. *YourPath->plug-ins*

Add that directory in Gimp as a plug-ins folder. 
*Gimp->Edit->Preferences->Folders->Plug-Ins*
Create folders in that directory for each plug-in.

* There is no need to refresh plug-ins
* The first line of the script needs to be 
  *#!/usr/bin/env gimp-script-fu-interpreter-3.0*

* The script file must also be set as an executable in the OS.
If it's not the plug-in won't appear. In Linux, new text files are *not* 
executable by default. 


* [Under GNU GENERAL PUBLIC LICENSE Version 3](https://github.com/script-fu/script-fu.github.io/blob/main/LICENSE)
* [Download all scripts](https://downgit.github.io/#/home?url=https://github.com/script-fu/script-fu.github.io/tree/main/scripts)
* [Download all plug-ins](https://downgit.github.io/#/home?url=https://github.com/script-fu/script-fu.github.io/tree/main/plug-ins)