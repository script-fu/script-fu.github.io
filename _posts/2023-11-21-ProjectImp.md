# Project Imp

This is a 'GitLab' branch of GIMP, it is my stable working version of GIMP Dev. Where all the Script-Fu plug-ins here, should work. It also applies all the changes I've made to that version via 'C' code. If you're able to build GIMP locally already, then you should be able to fetch and switch to the Imp branch, and build Imp the same way you build GIMP. Imp is designed to be used at 4K, with options for larger Tool buttons and icon scaling that works for nearly all GUI elements.

**Use at your own risk**, it's _not_ GIMP stable. When working in Imp I use [incremental saving](https://script-fu.github.io/2024/05/16/IncrementalSave.html) and an [auto-save](https://script-fu.github.io/2023/04/26/AlmostAutosave.html). Imp is hardcoded to use a different .config folder called 'Imp'.

GitLab repo branch for [Imp](https://gitlab.gnome.org/pixelmixer/gimp-plugins/-/tree/Imp?ref_type=heads)

```bash
# Step 1: Set upstream remote URL to pixelmixer/gimp-plugins.git
git remote set-url upstream git@ssh.gitlab.gnome.org:pixelmixer/gimp-plugins.git

# Step 2: Fetch the Imp branch from upstream and create/update the local Imp branch
git fetch upstream Imp:Imp

# Step 3: Check out the local Imp branch
git checkout Imp

# Step 4: Reset the local Imp branch to match the upstream Imp branch
git reset --hard upstream/Imp

# Step 5: Set upstream remote URL back to GNOME/gimp.git
git remote set-url upstream git@ssh.gitlab.gnome.org:GNOME/gimp.git
```

Then build Imp like you would the Dev GIMP version. Imp is only possible with the good work of the GIMP developers, they make it feasible for an amateur to flavour the ice-cream. **Please support the GIMP Project anyway you can, testing, promoting or coding.** 

@pixelmixer

## Additional Features

- Includes additional, custom CSS [themes](https://youtu.be/G1WA8flcy-0) to enhance the GIMP GUI, especially at 4K
- Default
- Warm
- High Contrast
- Dark

## Sliders

- Full range slider interaction, no snagging on the number input
- Slider cursor is not a hand, it's an up arrow instead, like in v2.10
- The Opacity slider is 100 rather than 100.0

## Painting

- New design for the Paintbrush GUI
- [Paint dabbing](https://youtu.be/02qgbsv0J4o), a particle system to create dabs of paint and much more
- Smoothed brush pressure when using Smooth Stroke for good lines
- The painting cursor is enhanced, it has a contact point for pressure brushes
- There is a threshold pick option on brushes for mask painting, paint black or white
- Smooth Stroke option moved to top of paintbrush dockable for easy access
- Bigger color swatches on color dockable
- Bigger 'swap' and 'set to default' icons next to the swatches
- Crosshair cursor when sizing a brush
- The Free Select tool has options for blocking in with the foreground color
- Paint Dynamics has an adjusted and fixed velocity mapping
- Paint Dynamics has an adjusted brush spacing function, slider value is MAX
- Selecting a Tool preset, always restores the Tool and preset, even when already selected
- Preference option to have a large FG/BG color picker on the toolbox
- Additional options on apply tool presets, so that you can opt out of tool overwrites 
- Brush aspect ratio goes from -1 to 1, 1 being full aspect, 0 being a sliver
- The brush aspect ratio dynamic works in a linear way, a more natural response
- [Pick and snap to path option](https://youtu.be/f0mf1IGAkS0), pick a path and automatically snap the brush to it whilst painting
- A higher quality implementation of the 'Force' attribute is available to select 
- Smooth Stroke has an option to [smooth brush angles](https://youtu.be/yr1J40cQgYw), in Additional options
- Fixed: Tablet buttons Touch Ring were causing glitches when painting using dynamics
- A brush option to use a circle as a boundary, rather than a complex dynamic path
- Holding 'Alt' down when painting, toggles the paint mode to 'Erase'
- A shortcut is available to toggle the paint tool to the erase tool, Tools -> Toggle Eraser
- A shortcut is available to toggle the paint mode to 'Erase' Tools -> Paint Tools 
- Toggling to erase paint mode or the eraser tool is context sensitive, erase always toggles to paint
- Ctrl picking a colour in eraser mode changes the tool and paint mode ready to paint again
- When using a filter, GIMP changes the tool, in Imp, the old tool is restored after the filter ends
- [Colour Picker](https://youtu.be/dlbpdu8kk7Q) has an option to select the layer, useful for 'Ctrl' picking a layer when painting.
- An option to [delay the start of the stroke](https://youtu.be/3TVY4u6XoSg) to avoid initial condition glitches

## Paths

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
- View -> Show Paths, a global visibility for paths in the active view

## Preferences ->

- Help System -> General -> Preferences -> Help System -> General -> Show tool tips
- Tool Options -> Paint Options -> Keep the paint mode box at the top of the options
- Tool Options -> Paint Options -> Change the tool and paint mode after color picking
- Tool Options -> Paint Options -> Show link to brush default buttons, to hide those buttons
- Tool Options -> Paint Options -> Show reset to brush default buttons, to hide those buttons
- Tool Options -> Brush Options Sliders -> Pick and choose which sliders are visible at top level
- Tool Options -> Tool Preset Editor -> change the size of the tool preset icon
- Snapping -> Snapping Distance, increase snapping distance range for active paths 
- Image Windows -> Path handle size, makes path handles bigger
- Image Windows -> Curve editing handle size, makes adjustment curves easier to work with
- Tools Options -> Show tag filtering, hide filter entry boxes and tagging input
- Tools Options -> Tool Preset Editor, set the size of the icon displayed by the Tool Preset Editor
- Interface -> General -> Show available mode groups button, allows you to hide those buttons
- Interface -> Toolbox -> Flexible layout for the foreground and background color picker
- Interface -> Layer Stack -> Shows the layer stack column header
- Interface -> Layer Stack -> Shows the layer stack blending mode box
- Playground -> Insane Options -> GIMP quits without any warning dialog
- Image Windows -> Zoom and Resize behaviour -> Initial zoom percentage
- Folders -> Save asset changes on exit, to stop GIMP auto-saving asset changes

## Misc

- The error console doesn't shout the same warning at the user with every message
- [Layer Group Warping](https://youtu.be/h1gpXi3VCw0) is implemented via a proxy warp layer
- The Warp Tool warns the user that the next undo will cancel the warp 
- If the Warp Tool is in 'Erase Mode' when the tool changes, then the mode is switched to 'Move'
- The Warp tool always warps, if it can't 'Erase' or 'Smooth' it switches to 'Move'
- The Levels Tool has larger control handles on the sliders
- More of the tiny icons now respond to the user custom icon scale set in preferences
- Layout change to the brush picker in Painting Tool Options, avoids icon distortion
- Previews can be set to 256 or 512 in size
- Less .00 and .0 on GUI sliders
- Lock all guide positions in an image per session
- NDE option on filters to allow it to be turned off
- A 'Save' button for Tool Presets, Brushes, Palettes, Dynamics and Gradients that saves on the press.
- A 'Save Package' button for Tool Presets that saves all preset elements on the press
