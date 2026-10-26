# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.12

This branch contains the tested Godot Web export of Ash & Oath 0.12. GitHub Pages publishes it from `gh-pages` / root.

v0.12 changes Stonewake, Engrave, Strike and Numeric dice; adds a half-health boss phase and 3×3 delayed fire; restores HP dots; and uses side descriptions and unfolded dice nets. Read [what changed and why](CHANGES_v0.12.md).

**Menu → Game options → Balance workshop** edits 198 numeric parameters, including Blank movement / uses. Applying saves locally and restarts the fight or Lab. Saved custom overrides remain authoritative: Reset all and Apply to try the new defaults. The Soul ON/OFF switch stays separate. See the [workshop guide](BALANCE_WORKSHOP.md).

The non-threaded export needs no special cross-origin isolation headers. Profiles and presets use browser-local storage. Current source and older Windows builds are on the `ash-and-oath-prototype` branch.

To update, replace export files while retaining `.nojekyll`. GitHub automatically rebuilds the Pages deployment.
