## Project Imp 

This is a 'GitLab' branch of GIMP, it is my stable working version of GIMP Dev. Where all the Script-Fu plug-ins here, should work. It also applies all the changes I've made to that version via 'C' code. If you're able to build GIMP locally already, then you should be able to fetch and switch to the Imp branch, and build Imp the same way you build GIMP. 

**Use at your own risk, it's not GIMP stable. Please make a backup of your 'gimprc, 'shortcutrc', 'sessionrc' and 'toolsrc' put them somewhere safe.** They can get messed up when switching between Imp and GIMP. Imp has some extra preferences. For example my active 'gimprc' and 'shortcutrc' for GIMP 2.99 live in home/.config/GIMP/2.99, I back those up all the time using Timeshift and also make manual copies. 

GitLab repo branch for [Imp](https://gitlab.gnome.org/pixelmixer/gimp-plugins/-/tree/Imp?ref_type=heads)

```
git remote set-url upstream git@ssh.gitlab.gnome.org:pixelmixer/gimp-plugins.git
git fetch upstream Imp:Imp
git remote set-url upstream git@ssh.gitlab.gnome.org:GNOME/gimp.git
git checkout Imp
```

Then build Imp like you would the Dev GIMP version. Imp is only possible with the good work of the GIMP developers, they make it feasible for an amateur to flavour the ice-cream. **Please support the GIMP Project anyway you can, testing, promoting or coding.**  

@pixelmixer

## Additional Features
- Includes additional themes, custom CSS themes to enhance the GIMP GUI
- Default
- Warm
- High Contrast
- Dark
- Light

## Sliders
- Full range slider interaction, no snagging on the number input
- Slider cursor is not a hand, it's an up arrow instead, like in v2.10
- The Opacity slider is 100 rather than 100.0
- Slider overlay text is adjusted from the edge of the slider

## Painting
- New design for the Paintbrush GUI
- Smoothed brush pressure when using Smooth Stroke for good lines
- The painting cursur is enhanced, it has a contact point for pressure brushes
- There is a threshold pick option on brushes for mask painting, paint black or white
- Smooth Stroke option moved to top of paintbrush dockable for easy access
- Bigger color swatches on color dockable
- Bigger 'swap' and 'set to default' icons next to the swatches
- Crosshair cursor when sizing a brush
- The Free Select tool has options for blocking in with the foreground color
- Paint Dynamics has an adjusted and fixed velocity mapping
- Paint Dynamics has an adjusted brush spacing function, slider value is MAX
- Selecting a Tool preset, always restores the Tool and preset, even when already selected
- Preference option to have a large FG/BG colour picker on the toolbox
- Additional options on apply tool presets, so that you can opt out of tool overwrites 
- Brush aspect ratio goes from -1 to 1, 1 being full aspect, 0 being a sliver
- The brush aspect ratio dynamic works in a linear way, a more natural response
- Pick and snap to path option, pick a path and automatically snap the brush to it whilst painting
- A higher quality implementation of the 'Force' attribute is available to select 

## Paths
- Paths are softly drawn, with more alpha
- Pick a path easily with 'Snap to Active Path' on, the path tool is excluded from the snap
- Paths have a visibility option on the Paths Tool, visible by default
- Paths have a pop up option "New Path", also switches to Design mode
- Paths have a lock handles checkbox, to keep curves smooth
- There is an "End Edit Mode" button on the Paths Tool, stops the editing mode
- Path movement has been changed so that when 'Move' is selected, paths can be easily moved
- The Path Tool will only automatically switch to Design mode when there are no paths
- The Path Tool starts a session in Design mode
- 'Enter' deactivates the current path, letting the user make another path or pick a path
- Close a path by clicking one end, and then the other end
- View -> Show Paths, a global visibliity for paths in the active view

## Preferences ->
- Help System -> General -> Preferences -> Help System -> General -> Show tool tips
- Tool Options -> Paint Options -> Keep the paint mode box at the top of the options
- Tool Options -> Paint Options -> Show link to bsrush default buttons, allows you to hide those buttons
- Tool Options -> Paint Options -> Show reset to brush default buttons, allows you to hide those buttons
- Tool Options -> Brush Options Sliders -> Pick and choose which sliders are visible at top level
- Tool Options -> Tool Preset Editor -> change the size of the tool preset icon
- Snapping -> Snapping Distance, increase snapping distance range for active paths 
- Image Windows -> Path handle size, makes path handles bigger
- Image Windows -> Curve editing handle size, makes adjustment curves easier to work with
- Tools Options -> Show tag filtering, to hide filter entry boxes and tagging input
- Tools Options -> Tool Preset Editor, to set the size of the icon displayed by the Tool Preset Editor
- Interface -> General -> Show available mode groups button, allows you to hide those buttons
- Interface -> Toolbox -> Flexible layout for the foreground and background colour picker
- Interface -> Layer Stack -> Shows the layer stack column header
- Interface -> Layer Stack -> Shows the layer stack blending mode box
- Playground -> Insane Options -> GIMP quits without any warning dialog
- Image Windows -> Zoom and Resize Behaviour -> Initial zoom percentage

## Misc
- The blank canvas message says "Start Autosave"
- The error console doesn't shout the same warning at the user with every message
- The Warp Tool warns the user that the next undo will cancel the warp 
- If the Warp Tool is in 'Erase Mode' when the tool changes, then the mode is switched to 'Move'
- The Warp tool always warps, if it can't 'Erase' or 'Smooth' it switches to 'Move'
- The Levels Tool has larger control handles on the sliders
- More of the tiny icons now respond to the user custom icon scale set in preferences
- Layout change to the brush picker in Painting Tool Options, avoids icon distortion
- Previews can be set to 256 or 512 in size
- Less .00 and .0 on GUI sliders
- Lock all guide positions in an image per session
