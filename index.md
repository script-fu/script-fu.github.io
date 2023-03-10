
# Quickstart in Script-Fu Plug-Ins - GIMP 3 

* Create a directory as a sandbox for plug-ins. e.g /home/username/plug-ins/        
  Add that directory in Gimp as a plug-ins folder, then restart Gimp.
  *Gimp->Edit->Preferences->Folders->Plug-ins*

* all [ plug-ins](https://github.com/script-fu/script-fu.github.io/blob/main/plug-ins) can be downloaded here...
  
* Right click an individual file to download, Save Link As... ...Save in a plug-ins **subfolder** of the same name. e.g /plug-ins/plug-in-name/plug-in-name.scm.

* The script file **must** also be set as an executable in the OS. If it's not, the plug-in won't appear...  
  In Linux, right click the file, *properties->permissions->allow executing file as program*

* Restart Gimp to see the plug-in menu.
  
* There is no need to refresh plug-ins after editing the script.  
  
* The first line of a plug-in script needs to be  
  ```#!/usr/bin/env gimp-script-fu-interpreter-3.0```  
  

### Quickstart in Script-Fu - GIMP 2

* Create a directory as a sandbox for new scripts. e.g /home/username/scripts/        
  Add that directory in Gimp as a scripts folder, then restart Gimp.
  *Gimp->Edit->Preferences->Folders->Scripts*     

* all [scripts](https://github.com/script-fu/script-fu.github.io/blob/main/scripts) can be downloaded here...

* Right click a file to download, Save Link As... ...Save in the scripts folder.
  
* After editing and saving a script, refresh scripts in Gimp.
  *Filters->Script-Fu->Refresh Scripts*
  It's easier to set up a keyboard shortcut to refresh scripts.

* Keep the Error Console window open. It's the only way I've been able to find to debug a script.  
  *Gimp->Windows->Dockable Dialogues->Error Console*  
  

* [Under GNU GENERAL PUBLIC LICENSE Version 3](https://github.com/script-fu/script-fu.github.io/blob/main/LICENSE)

