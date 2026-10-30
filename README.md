# Play Ash & Oath in a browser

**Live game:** https://lordtoff.github.io/Godot-Game-Template/?v=0.20

**Current rules:** [Read here](current-rules.html) · [Download the v0.20 PDF](AshAndOath-Current-Rules-v0.20.pdf).

**New optional third boss: Veyl, the Brass Cantor.** Select Veyl after choosing all heroes’ faces. The walking bell reliquary has original pixel sprites, six unique abilities, sound-wave effects and bell audio. Attack faces charge Resonance; own-turn Skills and Defenses calm it. Crescendo opens a core damage window while charging the next dangerous chime. Every ability upgrades at half HP. No boss summons or terrain hazards.

**Starter Reaction now grants 2 Block with no movement.** Its dialog has no direction buttons, and old movement overrides cannot restore its step. Other named Reactions keep their own stated effects. [Changes and reasons](CHANGES_v0.20.md).

The new boss completed 540 final scripted trials: 184 hero wins, 356 boss wins, no stalls. The existing 30-script regression suite and dedicated model / interface checks pass. Browser checks cover the real third-boss selection, meter, phase guide, turn progression and block-only Reaction. These are results for specific scripted policies, not predicted human win rates. Other boss cohorts and one Nu’gh round-limit attrition timeout are documented in the [trial notes](CHANGES_v0.20.md#verification) and [raw results](Trial-results-v0.20.json).

**Advanced numeric rules** on review or **Menu → Game options → Balance workshop** edits values, including Brass Cantor HP, Resonance, abilities and phase bonuses. Saved custom overrides still take precedence. [Workshop guide](BALANCE_WORKSHOP.md).

**Historical v0.16 report:** [View](playtest-report.html) · [Excel](Ash-and-Oath-Playtest-v0.16.xlsx). It retains its original version and results.

This release updates the browser build. The older Windows download is unchanged.
