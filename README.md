Factorio blueprint aligner mod
===

This is a small mod intended to help set the grid offset
for blueprints with absolute grid alignment.

![Mod thumbnail](./src/thumbnail.png)

Mod portal: https://mods.factorio.com/mod/blueprint-align


Usage
---

 1. Open the shortcut toolbar menu. There will be a new "Align blueprint" option there.
 2. Either add this shortcut to the toolbar and then click it while holding a blueprint,
    or just click the button in the toolbar menu.
 3. Place the blueprint in the world.
    The blueprint's offset will be updated to match your selected location.

The mod will by default print interaction feedback to the console to guide new users.
This can be turned off in the mod settings.

The blueprint alignment shortcut has an optional control input which is not set by default.


Caveats
---

- The "Align blueprint" action will initially set the blueprint to relative grid alignment.
  If you cancel the alignment by some method other than using the "clear cursor" keyboard shortcut,
  the previous grid offset will not be restored.

- Currently only works with blueprints from inventory, not from the library.

- The blueprint must already have a grid size set.


Rejected ideas
---

Ideas that have been tried and rejected.

- Place absolute grid the same way as aligning entities within grid

  This was the very first implementation, and it works well.
  However with the introduction of aligning entities within grid,
  this instead became about just placing the blueprint grid outline while ignoring the entities.
  This is a nonintuitive user interaction, and gets quite clunky
  if the blueprint grid is larger than what fits comfortably on one screen.

- Use WASD keys to move absolute grid while holding blueprint

  This works well - you can even keep the entities in the same place on the map while moving the grid!
  ...But it only for the natural blueprint orientation.
  I haven't found a way to tell the rotation state of the cursor without placing the blueprint,
  so I can't cancel out the grid movement by counter-translating the entities.
  That makes the utility quite limited, and it's no fun to align a blueprint one or two tiles at a time.
