# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/

This branch contains the tested Godot Web export of Ash & Oath 0.9. GitHub Pages publishes it from `gh-pages` / root. The initial deployment completed successfully on 26 October 2026.

The non-threaded export works without special cross-origin isolation headers. It includes 3D dice, Channel effects and the Test Soul toggle. Saved presets use browser-local storage. The source and Windows downloads are on the `ash-and-oath-prototype` branch.

To update, replace the export files on this branch while retaining `.nojekyll`. GitHub automatically rebuilds the Pages deployment.

Version 0.9 removes roll animations, adds ability category and timing labels, replaces the face picker with filterable cards, and adds painted arena and character art.
