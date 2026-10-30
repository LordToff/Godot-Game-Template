# v0.20 — Veyl, the Brass Cantor

## Optional third boss

Choose **Veyl · Brass Cantor** on the review screen after selecting all heroes’ faces. The Hollow and Nu’gh remain independently selectable. The three preview cards fit the existing screen, and the review still preserves dice, rule choices and numeric overrides.

Veyl is an original walking bell reliquary with four metal legs, a hammer, a tuning fork and a suspended crystal clapper. It has original pixel sprites for both phases, a glowing exposed core, blue sound-wave attacks and a synthesized bell sound. Its fight uses no boss summons or terrain hazards.

## The Resonance lesson

- Veyl starts at **14 HP**, with **0/6 Resonance**.
- Each resolved hero **Attack face adds 1** Resonance, once per spent face, not per repeated hit.
- An own-turn **Skill or Defense removes 1**. Movement, Blanks, declines and held Reactions do neither. Invalid actions change nothing.
- Resonance persists across turns and rounds. The header shows its value, six pips and whether the core is open. Logs name each face and meter change.
- **Crescendo** creates a risk/reward window: it charges the meter, but exposes the core until Veyl’s next turn. Hero Attack hits gain **+1 before Block**, rising to **+2 at half HP**. Short Shot’s final cap and Gambler’s absolute-zero rule still apply.

| Ability | Default effect | Half-HP upgrade |
|---|---|---|
| Gathering Note | Gain 2 Resonance. | Gain 3. |
| Crescendo | Gain 2 Resonance; open the core for +1 damage per hero Attack hit. | Gain 3; exposed-core bonus becomes +2. |
| Seal the Bell | Gain 2 Block. Does not close an open core. | Gain 3 Block. |
| Toll of Reckoning | Every standing hero within 3 takes 1 + floor(Resonance / 2). Spend the whole meter when declared. | Reach 4. |
| Hushed Chime | Closest standing hero within 3 takes 1 + floor(Resonance / 3); spend up to 2 Resonance. | Reach 4. |
| Tuning Fork | Advance 1, then attack an adjacent hero for 1. | Advance 2. |

Reactions happen before damage. Toll hits each selected hero once; Taunt / Target Override cannot turn it into a single-target hit. Damage is fixed when declared even though the meter has already been spent. If an attack has no targets, fallback advances or gains Block; Toll / Chime keep their unspent meter. Old Block and an open core expire at the next boss turn start. At 7/14 HP, Grand Peal permanently upgrades every ability.

**Why:** give the third encounter a different lesson: plan attack bursts and use support faces to control a shared resource. It rewards damage windows instead of focusing on fire avoidance or clearing a summoner’s brood.

## Starter Reaction: Block, no free step

The named starter **Reaction (Defense – Reaction)** now grants **2 Block** and no movement. Its former 1 Block + optional step gave both mitigation and a chance to avoid or redirect an attack for one face. Raising Block compensates for removing the step.

The reaction window offers **Gain 2 Block** and **Hold reaction**, with no directional buttons for this face. Old saved `face5.move` overrides cannot restore its movement; that numeric field remains labelled legacy / unused for profile compatibility. This rule applies in both presets.

Oath of Smoke’s explicitly stored Step / Stride still has its own movement Reaction; storing Guard does not grant a step. Other named Reaction faces keep their stated effects. Area attacks now consistently reject whole-area redirection by Taunt / Target Override.

## Current rules and settings

The consolidated browser rulebook and PDF are updated to v0.20, with a Veyl chapter and the new Reaction wording. Veyl’s HP, Resonance, calm / charge amounts, damage, ranges, movement, core bonuses and phase bonuses are editable under **Boss · Brass Cantor** in Advanced numeric rules / Balance workshop.

The long boss name uses **VEYL’S TURN** in the turn banner so it cannot overlap the round number. Its full title remains in the boss header and dice viewer. Combat logs use the short name Veyl.

## Verification

- The existing 30-script regression suite passes.
- Dedicated model checks cover charge / calm, declines, zero rolls, core damage and repeats, area attacks, fixed declaration damage, phase upgrades, fallback and legacy Reaction movement overrides.
- Interface checks cover all three boss choices, actual Attack / Defense clicks, the meter, core display, the new block-only reaction button, the phase guide and dice viewer.
- Final trials: 30 seeds × six legal team configurations × three Blank-movement settings = 540 fights per boss.

| Boss | Hero wins | Boss wins | Round-limit timeouts |
|---|---:|---:|---:|
| Veyl | 184 | 356 | 0 |
| The Hollow | 161 | 379 | 0 |
| Nu’gh | 124 | 415 | 1 |

The Nu’gh timeout was a long attrition fight with a lone Stonewake survivor; the bot reached the 50-round cutoff with no pending input. It was not a frozen control. These are scripted policy results, not human win-rate predictions. The old v0.16 spreadsheet remains a historical report.
