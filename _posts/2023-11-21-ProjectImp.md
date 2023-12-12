## Project Imp 

This is a 'GitLab' branch of GIMP, it is my stable working version of GIMP Dev. Where all the Script-Fu plug-ins here, should work. It also applies all the changes I've made to that version via 'C' code. If you're able to build GIMP locally already, then you should be able to fetch and switch to the Imp branch, and build Imp the same way you build GIMP. 

**Use at your own risk, it's not GIMP stable. Please make a backup of your 'gimprc' and 'shortcutrc', put them somewhere safe.** They can get messed up when switching between Imp and GIMP. Imp has some extra preferences. For example my active 'gimprc' and 'shortcutrc' for GIMP 2.99 live in home/.config/GIMP/2.99, I back those up all the time using Timeshift and also make manual copies. 

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
- Full Range Slider Interaction, no snagging on the number input
- Slider cursor is not a hand, it's an up arrow instead, like in v2.10
- The Opacity Slider is 100 rather than 100.0
- Slider overlay text is adjusted from the edge of the slider

## Painting
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

## Paths
- Paths are softly drawn, with more alpha
- Pick a path easily with 'Snap to Active Path' on, the path tool is excluded from the snap
- Paths have a visibility option on the Paths Tool, visible by default
- Paths have a pop up option "New Path", that starts the next path
- Paths have a lock handles checkbox, to keep curves smooth
- There is a "New Path" button on the Paths Tool

## Preferences ->
- Tool Options -> Show link to brush default buttons, allows you to hide those buttons
- Snapping -> Snapping Distance, increase snapping distance range 
- Image Windows -> Path handle size, makes path handles bigger
- Tools Options -> Show tag filtering, to hide filter entry boxes and tagging input

## Misc
- The blank canvas message says "Start Autosave"
- The error console doesn't shout the same warning at the user with every message
- Curve points in editors are bigger and easy to grab
- The icon size of 'Configure this tab' now scales with the preference set for icon sizes
- The Warp Tool warns the user that the next undo will cancel the warp 
- The Warp Tool never starts in Erase Mode (Although the GUI option may looks like it does)