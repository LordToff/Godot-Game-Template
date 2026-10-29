# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.16

This branch contains the browser-tested Godot Web export of Ash & Oath 0.16. GitHub Pages publishes `gh-pages` / root.

v0.16 fixes Black Oath cost expiry, Wither Ward triggering from non-attacks, zero-count Fracture and missing killing-hit rewards. It adds a new readable trial-results page to What changed. [Results, exact teams and fixes](CHANGES_v0.16.md).

7,200 matched trial battles (3,600 before / 3,600 after), no stalls. Per setting, 200 trials: random-bonus team wins 99 with Soul OFF, 166 with Blank Move 1, 178 with Move 2. These are fixed-strategy bot comparisons, not human win predictions. Base numbers are unchanged. [Raw outcomes and metrics](Trial-results-v0.16.json).

The drag-and-drop face picker, per-own-turn Blank movement and Rooted / Weakness sprite effects remain. Browser checks cover the new results page, real mouse drags, saved placements, repeated Blank movement, preset save / restore / load and invalid JSON feedback.

**Menu → Game options → Balance workshop** edits 201 numeric parameters. Saved overrides remain in force. The Soul ON/OFF switch stays separate. See the [workshop guide](BALANCE_WORKSHOP.md).

The non-threaded export needs no special cross-origin isolation headers. Profiles and presets use browser-local storage. Source and older Windows builds are on the `ash-and-oath-prototype` branch. Retain `.nojekyll` when replacing export files.
