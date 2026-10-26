# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/

This branch contains the tested Godot Web export of Ash & Oath 0.11. GitHub Pages publishes it from `gh-pages` / root.

Open **Menu → Game options → Balance workshop** to experiment with implemented numeric values, including Blank movement / uses, abilities, passives, resources and boss actions. Apply saves locally and restarts the fight / test. Reset or import / export profiles; structural limits and inactive mechanics are identified. See [workshop guide](BALANCE_WORKSHOP.md).

The game retains the large pixel arena and compact UI. All heroes now use knight sprites, and Cinder Brand / Ember Burst have pixel fire effects.

The non-threaded export needs no special cross-origin isolation headers. Profiles and presets use browser-local storage. Source and older Windows builds are on the `ash-and-oath-prototype` branch.

To update, replace export files while retaining `.nojekyll`. GitHub automatically rebuilds the Pages deployment.
