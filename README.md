# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.19

**Current rules:** [Read here](current-rules.html) · [Download the v0.19 PDF](AshAndOath-Current-Rules-v0.19.pdf).

v0.19 rebuilds Nu’gh as a large human-worm. He retreats and uses **Brood Command** to move and attack with each worm; no worms means summon two instead. Commands finish before the next die, with Reactions between bites. His Soul Link breaks permanently at half HP. Summons cannot overlap heroes, the boss or other worms.

The Hollow’s positive Smoking Strikes ignite even when blocked. Ending a hero turn on fire burns; Brand deals 2 / 3 and phase-II Sweep deals 2 within 2. Movement and reading the intent matter. **LAST ENEMY RESULT** keeps fallback movement / Block visible during hero turns. [Changes and reasons](CHANGES_v0.19.md).

The final 1,620 scripted trials finished without stalls. The hazard-aware Hollow bot won 152/540 fights; ignoring hazards won 74/540. Nu’gh’s phase-aware bot won 100/540. These are results for specific scripted policies, not predicted human win rates. Starting-only and Soul-OFF stress tests are difficult; normal setup includes two bonus designs per hero. [Trial details](CHANGES_v0.19.md#final-scripted-trials) · [Raw results](Trial-results-v0.19.json).

The regression suites, encounter / UI checks and browser checks cover both encounters, command sequencing, actual worm reactions, phase guides and persistent results.

**Advanced numeric rules** on the review screen or **Menu → Game options → Balance workshop** edits values. Saved custom overrides still take precedence; reset the relevant sections and apply to try the new defaults. [Workshop guide](BALANCE_WORKSHOP.md).

**Historical v0.16 report:** [View](playtest-report.html) · [Excel](Ash-and-Oath-Playtest-v0.16.xlsx). It retains its original version and results.

This release updates the browser build. The older Windows download is unchanged.
