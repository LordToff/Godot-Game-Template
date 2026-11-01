# v0.22.2 — Combat targeting and status bug sweep

Reviewed combat, friendly/enemy summons, reactions, loadouts/presets, statuses, workshop values and browser controls. No numeric balance values changed.

## Fixed

- **Target Override redirected attacks onto friendly worms.** It now considers only another legal standing hero, as its rule states. With no valid hero alternative, the original hero remains the target. Positive and no-alternative cases were reproduced before fixing.
- **Custom boss Weakness showed incorrect incoming damage.** Reaction previews, boss hover and status-change logs now use the actual applied Weakness strength, including Bu’gh’s editable cocoon-break value, instead of assuming Wither Ward’s default.
- **Friendly summon hover hid movement locks and damage penalties.** It now includes Rooted, Weakness and Poison values and expiry, so a genuinely Rooted worm can be distinguished from a movement problem. The v0.22.1 detour fix remains in place.
- **Bu’gh’s custom hover omitted Poison.** It now shows Poison and the actual boss Weakness value.
- **Combat history omitted important Bu’gh events.** The Combat filter now retains cocoon breaks, hatching, brood phases, consumption, phase transitions and fire/hazard events. The Turns filter remains separate.
- **Status logs misclassified Poison as a buff** and named every Weakness expiry “Distort.” Poison gains now count as harmful debuffs; expiry names the status. Wither Ward’s static catalog wording now matches its existing restriction to adjacent boss Attacks.

## Validation

The new bug reproductions initially failed on the published source. After fixes: 14 model checks and 11 rendered UI checks pass. The UI checks exercise real reaction controls, preview/mitigation agreement, actual summon hover and real Bu’gh events in the Combat history filter.

All 25 selected regression scripts pass. The broader regression pass covers rules, reliability, balance overrides, the full catalog, all loadout placements, presets, Numeric feedback, Nu’gh brood, Cantor, summons, worm detours, reactions, soul movement, combat presentation and current hover controls. Historical pre-v0.21 click-pinned inspector scripts remain historical and are not claimed to pass.

180 seeded trial encounters used starting, mixed and summoner builds against all four bosses with Blank movement OFF, Move 1 and Move 2 (five seeds per setting). Results: **55 hero wins, 122 boss wins, three Bu’gh round limits; no script/state errors.** Raw scenarios: [Trial-results-v0.22.2.json](Trial-results-v0.22.2.json). These are heuristic checks, not human win-rate estimates. Bu’gh remains provisional.

The actual browser export is checked in Chromium/WebGL. Published game data uses a versioned pack URL to avoid an older cached build hiding the fixes. The current v0.22 rulebook already describes these intended targeting, movement and status rules. The older Windows build is unchanged.
