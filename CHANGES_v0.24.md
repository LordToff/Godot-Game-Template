# Ash & Oath v0.24 — Bu’gh, the Iron Warden

Bu’gh’s cocoon-and-mite encounter has been replaced. The fourth encounter now rewards guarding, reading a fixed area warning and moving to create an opening. The Hollow, Nu’gh, Veyl, friendly Summon/Command Nu’gh, the original soundtrack and the polished interface remain available. The older Windows build is unchanged.

## Guard or evade, then counterattack

Bu’gh has 12 HP and Bulwark, reducing normal incoming damage by 1. A positive-damage attack fully prevented by a hero’s Block or Damage Reduction breaks Bulwark and removes all boss Block. A threatened hero escaping a marked sweep also exposes him when it resolves. Counterattack during the opening; Bulwark returns at his next activation. Defy Death alone, friendly-worm defenses and zero-damage attacks do not grant openings. Unavoidable damage bypasses Bulwark.

Golden cells show the exact sweep area and damage. Warnings remain fixed if the boss moves or changes phase. Impact resolves before his next three dice, with Reactions; movement Reactions can escape the marked cells. A sweep that never threatened a hero grants no free opening. Every completed boss turn leaves a warning if one is not already armed. Warnings do not stack.

## Six abilities and phase II

- **Iron Advance:** Move 1 → 2.
- **Shield Bash:** range 1, damage 1 → 2.
- **Hammerfall:** area damage 2, reach 1 → 2.
- **Raise Guard:** Block 1 → 2. Cannot restore broken Bulwark early.
- **Crushing Sweep:** fixed warning reach 1 → 2, damage 1 → 2.
- **Driving Blow:** damage 1 → 2; HP-damaging hits push 1 → 2. Full guard prevents the push.

Phase II starts at half HP and cannot be reversed by healing. Active values are exposed in Balance Workshop. Old cocoon override keys remain compatible with saved profiles but are inactive and hidden from current boss controls. Original 32×32 shield-and-hammer sprites replace the former boss artwork, including an ember-cracked second phase.

## Validation and limits

The focused Warden mechanics suite passes 38 checks, including perfect versus partial guard, Damage Reduction, actual Reactions, movement Reactions, fixed warning timing, phase snapshots, multi-target damage, pushes, friendly worms, Poison and legacy balance overrides. The UI fixture exercises encounter selection, warning text, board movement input, explicit sweep resolution, opening indicators and phase-II warnings.

450 deterministic trial battles used starting, mixed, Numeric, defensive and summoner builds, each with Blank movement OFF / 1 / 2 and ten seeds:

| Bot policy | Wins | Defeats | Reached trial cap |
| --- | ---: | ---: | ---: |
| Approach, then attack only; decline defenses/Reactions | 0 | 150 | 0 |
| Remain beside boss; use defenses/Reactions | 7 | 140 | 3 |
| Adapt movement to warnings; use defenses/Reactions | 20 | 127 | 3 |

The capped mixed-build trials reached the bounded simulation limit; they are not counted as victories. These are limited heuristic bots, not human win rates or proof of balance. Results show a benefit from defense and movement, but difficulty remains provisional and demanding. The initial, more attack-heavy Warden was reduced before release. Full results: [Trial-results-v0.24.json](Trial-results-v0.24.json).

The current HTML, Markdown and PDF rulebook describe the Warden. Historical patch notes retain the former cocoon design as release history.

Additional verification: 25 core regression scripts passed. Rendered fixtures for the Warden, Summon Nu’gh, worm detours, status/history, presentation/audio controls and face-choice layout passed. Chromium ran the actual web export through face selection and Warden entry without console/page errors; Web Audio was measured playing, at zero volume, restored and muted. Native fixture screenshots verify warning cells and open/phase-II states. Some older UI scripts still expect the retired pinned inspector and are not current release gates; this is not a claim that every historical UI script passes.
