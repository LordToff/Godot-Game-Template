# Ash & Oath v0.21 — worms, readable actions and movement

## What changes in a fight

- **Worms act after Nu’gh.** After his three dice, every surviving worm moves toward a standing hero and attempts an adjacent bite. Brood Command still gives extra activations. Resolve the brood before the next hero; Reactions pause individual bites normally. An empty automatic brood turn never summons worms.
- **Bites roll a special Numeric die: 1, 1, 0, 0, 0, 0.** A zero misses. A one deals normal damage, so Block and Reactions can prevent it. This replaces the old guaranteed bite damage for both Command and automatic activations.
- **HP damage from a bite applies Poison 1.** At the poisoned hero’s next own turn start, they lose 1 HP through Block, then Poison clears. More bites refresh the value rather than adding stacks. Downing clears Poison. A lethal turn-start tick ends that skipped turn normally. Green particles and a label identify poisoned knights; hover and Effects explain the timing.

**Why:** worms should threaten the party without waiting for a Command result. The weaker chance-based bite makes room for automatic activations and a delayed consequence that players can prevent with Block.

## What changes on screen

- **Numeric dice roll as projected 3D cubes.** They show the recorded side and value. Attacks, healing and Numeric Block use this feedback; worms use their special die. Stored values are labelled, and Gambler also shows its additional base roll. Animation never draws random numbers or changes outcomes. Action Dice remain instant.
- **Ability details appear on hover.** Hover hero dice, boss intents, the phase guide or Effects. Move onto the details to read or scroll them, or move away to restore the combat log. Selecting a die no longer pins a window. Duplicate native ability tooltips are removed.
- **The log includes declarations and rolls.** It also names worm movement, targets, blocked damage, HP actually lost, Poison application and its expiry. Damage after a Reaction retains the actual attacker’s name.
- **Face choices take fewer clicks.** Cards show a short effect and preview the full short description on hover. Click to equip; click an equipped card again to remove it. Chosen faces and counts remain beside the live dice. Dragging onto dice or exact squares still works and preserves construction limits.
- **Knight movement has weight.** Sprites step along legal orthogonal routes with a short lift, a landing dust ring and a soft armoured footfall. They do not slide straight across occupied cells. No landing effects play for units that have not moved.
- **Veyl’s meter and core changes have musical pulses.** Core opening/closing has a floating label. Existing attack waves, shields and phase effects remain.

**Why:** make causes and results visible while keeping the battlefield clear. Movement feedback is cosmetic and does not spend additional movement or change legal destinations.

## Settings and reference

Nu’gh’s bite damage, successful Numeric sides out of six, and Poison value are editable in the Balance Workshop. Existing saved values still apply. The updated [current rules](current-rules.html) and [PDF](AshAndOath-Current-Rules-v0.21.pdf) describe the same implementation. Other bosses’ numbers and Blank-movement options are unchanged.

## Verification

- 22 model / interface / simulation scripts passed, including 2,414 targeted brood checks 17 interface checks, and 52 Numeric-presentation checks. Construction tests still cover all 1,081 bonus-face pairs. The targeted bite sample rolled 111 successes in 300 seeded rolls; this is a sample, not a changed probability.
- Chromium checks exercise the real face picker, boss selection, Nu’gh turn progression, hover panel opening/closing, Numeric cube, combat log and movement. No game engine or browser console errors were reported.
- 900 scripted battles: Nu’gh 93 hero wins / 446 losses / one 50-round limit; Hollow 56 / 124 / zero limits; Veyl 53 / 127 / zero limits. Nu’gh used 30 seeds per build/movement scenario; the other bosses used 10. These are legal teams under the visible-board heuristic, not predicted human win rates.
- The Nu’gh limit was starting faces, Blank Move 1, seed 12. Continuing the same seed ended in defeat at round 53. It was a long attrition fight, not an input deadlock. Raw scenarios are in [Trial-results-v0.21.json](Trial-results-v0.21.json).

This release updates the browser game. The older Windows download remains its original version.
