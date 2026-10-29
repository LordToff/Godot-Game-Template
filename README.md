# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.17

This branch contains the browser-tested Godot Web export of Ash & Oath 0.17. GitHub Pages publishes `gh-pages` / root.

v0.17 makes Focus targets and new results explicit, greys spent / held dice, separates usable rerolls from saved charges, and explains non-rerollable faces. Short descriptions show active values; full rules are optional. Weak Point has a persistent marker and rear highlights. Boss hits have heavier effects / sound, and half-HP upgrades have a permanent guide. [What changed and why](CHANGES_v0.17.md).

Focus now respects the existing non-rerollable restriction. No default HP, damage, dice odds, caps or Soul settings changed. Heavy impact effects can be disabled in Game options; Sound controls audio separately. Rolls remain instant.

The 30-suite regression run, 157 combat-clarity checks, 1,508 choice-layout checks and 180 encounter smoke trials passed. Browser checks cover Focus / restrictions, Weak Point, half-HP upgrades, actual drags, saved builds and the current patch notes, without console errors.

**Recorded v0.16 playtest report:** [View in browser](playtest-report.html) · [Download Excel](Ash-and-Oath-Playtest-v0.16.xlsx). The report explains team builds and preserves the recorded results; it is not labelled as a new v0.17 trial set.

**Menu → Game options → Balance workshop** edits 201 numeric parameters. Saved overrides stay active. The Soul ON/OFF switch stays separate. [Workshop guide](BALANCE_WORKSHOP.md).

The non-threaded export needs no special cross-origin isolation headers. Profiles / presets use browser-local storage. Source and older Windows builds remain on `ash-and-oath-prototype`. Retain `.nojekyll` when replacing export files.
