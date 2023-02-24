
### Quickstart in Script-Fu - GIMP 2

* Create a local directory as a sandbox for new scripts. Add that directory in 
  Gimp as a scripts folder.  
  *Gimp->Edit->Preferences->Folders->Scripts*  
  
* After editing and saving a script, refresh scripts in Gimp.  
  *Filters->Script-Fu->Refresh Scripts*  
  It's easier to set up a keyboard shortcut to refresh scripts.  

* Keep the Error Console window open. It's the only way I've been able to find to debug a script.  
  *Gimp->Windows->Dockable Dialogues->Error Console*

* Scripts copied from the blog posts should be saved as the same name as the define name. For example, a script defined as *bareBones* would be saved as *bareBones.scm* in a scripts folder.  
  

# Quickstart in Script-Fu Plug-Ins - GIMP 3 

* Create a local directory as a sandbox for new plug-ins. Create folders in that directory for each plug-in. Add that directory in Gimp as a plug-ins folder.  
  *Gimp->Edit->Preferences->Folders->Plug-ins*
  
* There is no need to refresh plug-ins after editing the script.  
  
* The first line of the script needs to be  
  ```#!/usr/bin/env gimp-script-fu-interpreter-3.0```

* The script file must also be set as an executable in the OS. If it's not, the plug-in won't appear. In Linux, new text files are not executable by default.  
  

* [Under GNU GENERAL PUBLIC LICENSE Version 3](https://github.com/script-fu/script-fu.github.io/blob/main/LICENSE)
* [all scripts](https://github.com/script-fu/script-fu.github.io/blob/main/scripts)
* [all plug-ins](https://github.com/script-fu/script-fu.github.io/blob/main/plug-ins)