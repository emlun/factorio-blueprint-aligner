Factorio blueprint aligner mod
===

This is a small mod intended to help set blueprint grid size and offsets
by drawing the grid and placing the blueprint in the world.

![Mod thumbnail](./src/thumbnail.png)

Mod portal: https://mods.factorio.com/mod/blueprint-align


Usage
---

The mod adds two toolbar shortcuts:

- **Set blueprint grid**

  Activate while holding a blueprint,
  then select the area you would like to be one cell of the blueprint grid.
  The grid size and offset will be set on the blueprint.

- **Align blueprint entities**

  Activate while holding a blueprint with an alignment grid set,
  then place the blueprint in the world.
  The entities in the blueprint will be moved within the alignment grid
  to match the selected location.

Demo video: https://www.youtube.com/watch?v=45pQEFdYXsg

Both shortcuts have hotkeys, which can be changed in the control settings.

In addition, while holding a blueprint with absolute alignment you can use
<kbd>Shift + WASD</kbd> to move the absolute offset.
These key bindings can also be changed in the control settings.

The mod will by default print interaction feedback to the console to guide new users.
This can be turned off in the mod settings.


Caveats
---

- The "Align blueprint entities" action will initially set the blueprint to relative grid alignment.
  If you cancel the alignment by some method other than using the "clear cursor" keyboard shortcut,
  the previous absolute grid offset will not be restored.

- Currently only works with blueprints from inventory, not from the library.


Rejected ideas
---

Ideas that have been tried and rejected.

- Place absolute grid the same way as aligning entities within grid

  This was the very first implementation, and it works well.
  However with the introduction of aligning entities within grid,
  this instead became about just placing the blueprint grid outline while ignoring the entities.
  This is a nonintuitive user interaction, and gets quite clunky
  if the blueprint grid is larger than what fits comfortably on one screen.

- Keep blueprint entities in place when moving offset with <kbd>Shift+WASD</kbd>

  This works... but only for the natural blueprint orientation.
  I haven't found a way to tell the rotation state of the cursor without placing the blueprint,
  which means the blueprint entities drift in different directions
  depending on how you have the blueprint rotated while holding it.


License
---

This is free and unencumbered software released into the public domain.
For more information, please refer to [http://unlicense.org]().

Graphics assets are licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
