# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.14

This branch contains the browser-tested Godot Web export of Ash & Oath 0.14. GitHub Pages publishes `gh-pages` / root.

v0.14 adds one-click quick equip and drag-and-drop placement on live unfolded dice. Drop cards onto a die or exact square, swap installed faces, and start combat directly after choosing all heroes. Hero switching and starting combat preserve placements.

Blank movement uses one numeric counter and refreshes on each normal / recovery own turn. The UI distinguishes spent dice, exhausted allowance, Soul OFF and Rooted. Rooted and Weakness now have persistent effects on knight sprites, including inactive heroes.

Read [what changed and why](CHANGES_v0.14.md). Boss rules and balance numbers are unchanged.

**Menu → Game options → Balance workshop** edits 201 numeric parameters. Saved overrides remain in force. The Soul ON/OFF switch stays separate. See the [workshop guide](BALANCE_WORKSHOP.md).

The non-threaded export needs no special cross-origin isolation headers. Profiles and presets use browser-local storage. Source and older Windows builds are on the `ash-and-oath-prototype` branch. Retain `.nojekyll` when replacing export files.
