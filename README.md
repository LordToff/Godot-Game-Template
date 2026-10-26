# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/

This branch contains the tested Godot Web export of Ash & Oath 0.10. GitHub Pages publishes it from `gh-pages` / root.

Version 0.10 replaces the painted images with original pixel sprites and tiles, enlarges the visible arena by about 91% in area, and groups combat controls beside it. Secondary commands are under Menu and Lab tools. Dice resolve instantly; ability timing labels and the Soul ON/OFF switch remain.

The non-threaded export works without special cross-origin isolation headers. Saved presets use browser-local storage. The source and older Windows downloads are on the `ash-and-oath-prototype` branch.

To update, replace the export files on this branch while retaining `.nojekyll`. GitHub automatically rebuilds the Pages deployment.
