Factorio blueprint aligner mod
===

This is a small mod intended to help set the grid offset
for blueprints with absolute grid alignment.

To use it:

 1. Open the shortcut toolbar menu. There will be a new "Align blueprint" option there.
 2. Either add this shortcut to the toolbar and then click it while holding a blueprint,
    or just click the button in the toolbar menu.
 3. Place the blueprint in the world.
    The blueprint's offset will be updated to match your selected location.

The mod will by default print interaction feedback to the console to guide new users.
This can be turned off in the mod settings.


Caveats
---

- The "Align blueprint" action will initially set the blueprint to relative grid alignment.
  If you cancel the alignment by clearing the cursor, the previous grid offset will not be restored.

- Currently only works with blueprints from inventory, not from the library.
  I'm not entirely sure why that difference is.

- Currently works only if the blueprint has the alignment grid
  (the setting labeled "Grid position" in the blueprint GUI)
  at offset (0, 0).
  It seems like the mod API doesn't make this setting readable,
  so the mod cannot compensate for it when setting the grid offset.
  I would love to be proven wrong about this.

- The blueprint must already have a grid size set.
