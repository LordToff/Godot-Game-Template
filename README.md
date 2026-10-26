# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.13

This branch contains the browser-tested Godot Web export of Ash & Oath 0.13. GitHub Pages publishes `gh-pages` / root.

Boss upgrades now activate only at half HP: Cinder Brand expands from a cross to a square, Ashen Chain adds Rooted, and Furnace Roar unlocks. Advance and Distort prefer highest current HP, Drive Back pushes automatically, and Smoking Strike creates / detonates persistent fire. Boss HP / Block appear beneath its sprite; phase II has a burning-crown sprite and transition effect.

Read [what changed and why](CHANGES_v0.13.md). **Lab tools → Test boss phase II** tests the real threshold. Reset test returns to phase one.

**Menu → Game options → Balance workshop** edits 201 numeric parameters. Saved overrides remain in force. The Soul ON/OFF switch stays separate. See the [workshop guide](BALANCE_WORKSHOP.md).

The non-threaded export needs no special cross-origin isolation headers. Profiles and presets use browser-local storage. Source and older Windows builds are on the `ash-and-oath-prototype` branch.

Retain `.nojekyll` when replacing export files. GitHub automatically deploys Pages updates.
