# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.18

This branch contains the browser-tested Godot Web export of Ash & Oath 0.18. GitHub Pages publishes `gh-pages` / root.

Choose two bonus faces per hero, then review the boss and rules before entering. Pick **Nu’gh** for the new worm-summoner encounter. Living worms strengthen attacks; killing them reduces pressure and deals Soul Link damage to their master. Worms occupy cells and block sight, but take no separate attack turn.

The combat header now holds party cards and boss intents. Stunned heroes show orbiting stars. Every boss action has a half-HP upgrade, explained by the permanent phase guide. [Changes and reasons](CHANGES_v0.18.md).

The regression suites, encounter and interface checks passed. The final 1,620 scripted battles completed without stalls; [cohort results and limits](CHANGES_v0.18.md#automated-checks-and-their-limits) and [raw results](Trial-results-v0.18.json). These are bot results, not predicted human win rates.

**Recorded v0.16 playtest report:** [View in browser](playtest-report.html) · [Download Excel](Ash-and-Oath-Playtest-v0.16.xlsx). This historical report retains its original version and results.

Open **Advanced numeric rules** on the review screen or **Menu → Game options → Balance workshop** in combat to edit values, including Nu’gh, phase bonuses and Blank movement. Saved overrides stay active. [Workshop guide](BALANCE_WORKSHOP.md).

Rolls remain instant. Heavy effects and sound are independently configurable. This release updates the browser build; the older Windows download is unchanged.
