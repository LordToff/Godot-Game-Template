# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.15

This branch contains the browser-tested Godot Web export of Ash & Oath 0.15. GitHub Pages publishes `gh-pages` / root.

v0.15 fixes reproduced bugs in Stunned collisions, dead-hero actions, zero-charge Blood Bargain, rear-position checks, Ward / prevention interactions, custom-value logs, Numeric side counts, stale choices and preset validation. Restore keeps the selected bonus designs. Read [what changed and why](CHANGES_v0.15.md). Default balance numbers are unchanged.

The drag-and-drop face picker, per-own-turn Blank movement and Rooted / Weakness sprite effects remain. Browser checks cover actual mouse drags, preserved placements, repeated Blank movement in normal combat, preset save / restore / load, and rejected invalid JSON without console errors.

**Menu → Game options → Balance workshop** edits 201 numeric parameters. Saved overrides remain in force. The Soul ON/OFF switch stays separate. See the [workshop guide](BALANCE_WORKSHOP.md).

The non-threaded export needs no special cross-origin isolation headers. Profiles and presets use browser-local storage. Source and older Windows builds are on the `ash-and-oath-prototype` branch. Retain `.nojekyll` when replacing export files.
