# Play Ash & Oath in a browser

This branch contains the tested Godot Web export of Ash & Oath 0.8.1.

## One-time GitHub Pages activation

Repository owner: open Settings → Pages. Under Build and deployment, choose **Deploy from a branch**, then **gh-pages** and **/ (root)**, and Save.

Expected play URL after GitHub finishes deployment:
https://lordtoff.github.io/Godot-Game-Template/

This is a non-threaded Web export, so special cross-origin isolation headers are not required. It includes the 3D dice, Channel effects and Test Soul toggle. Saved build presets use browser-local storage.

The source and Windows downloads are on the ash-and-oath-prototype branch. To update the browser game, replace the export files on this branch while retaining .nojekyll.
