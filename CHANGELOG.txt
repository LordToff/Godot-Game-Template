# v0.19 — active brood and dangerous ground

## Nu’gh rebuilt

- **New pixel sprite:** a large bare human torso and distorted face on a thick, segmented, coiled worm body. He no longer looks like a robed summoner holding a staff.
- **Retreating behavior:** Burrow moves toward safer legal positions, maximizing distance from the nearest hero; it moves 1, or 2 at half HP. No safer route gives 1 Block. Maw with no legal target retreats 1, or gains 1 Block if cornered.
- **Brood Command:** two sides on EACH boss die. Activate every living worm once: move up to 2 toward the nearest standing hero, then bite an adjacent hero for 1. At half HP movement becomes 3. Each bite opens normal Reaction windows, using the worm’s position and identity. Next-worm controls make activations readable; all worms finish before the next boss die.
- **No worms:** Command summons two instead (three at half HP); those new worms wait for another Command.
- **Soul Link:** hero worm kills deal 1 unavoidable damage only BEFORE half HP. At 5/10 HP the link breaks permanently, even if Nu’gh later heals. Kill worms to control incoming attacks; damage Nu’gh directly to finish him.
- **Less defensive stalling:** Brood Guard gives 1 base Block, with no extra default Block per living worm. At half HP it shields one worm with 1 non-stacking Block. Devour heals 1 in either phase; upgraded Devour additionally gives 1 Block. Nu’gh keeps 10 HP rather than gaining a large health pool.
- **Summon overlap fixed:** the former legality check ignored Vesper because it used Vesper’s movement query. The new check explicitly excludes all heroes (including Downed heroes), the full boss footprint and every living worm.

All six Nu’gh actions upgrade at half HP. Birth Cry summons an extra worm; Command moves worms farther / summons an extra worm when empty; Maw gets more reach and pressure; Burrow moves farther and leaves a worm; Guard shields one worm; Devour adds Block. The guide shows these values. Legacy Chorus settings remain marked unused so older saved numeric profiles still load.

## The Hollow: movement has a cost and a payoff

- **Positive Smoking Strikes ignite even when blocked or reduced.** Zero after Weakness still causes no ignition. This intentionally replaces the old HP-loss-only trigger: one Guard can stop the hit, but does not make standing still indefinitely safe.
- **End a hero turn on fire:** take 1 normal damage. Move off before ending to avoid it. Block and ordinary Damage Reduction still work. The tile remains; simply walking through does not detonate it.
- **Fire detonation:** a later positive Smoking Strike on that tile consumes it for 2 extra normal damage, or 3 in phase II.
- **Cinder Brand:** delayed damage rises from 1 to **2**, then **3 at half HP**. Cross in phase I, 3×3 square in phase II. Already armed warnings keep their original area; damage uses the current phase at detonation.
- **Phase-II Sweep:** hits within 2 for **2 damage**, once per hero. This punishes clustering at the boss’s feet. Phase-I Sweep remains 1, giving an easier first phase before the wider, harder sweep.
- **Restraint:** ordinary Strike, Skirmish, Drive Back and Roar are not all doubled. The final design puts pressure in visible hazards and the phase transition. The Hollow keeps 12 HP.

The early trial doubled several attacks at once; that proved excessively punishing and was not shipped. The final settings above preserve reactions, movement and defensive counterplay.

## Easier to read

- **LAST ENEMY RESULT** remains below the action/log columns during hero turns. Fallback records name the failed action and show exact origin/destination or Block gained.
- **Standing in fire** replaces the ordinary instruction with an explicit end-turn damage warning. Hovering fire states burn and detonation damage separately.
- Worm reaction windows name the actual attacker. Worm movement, attacks and results are recorded in the combat log, and use their own effect origins.
- Nu’gh’s dice nets now compare against his own original dice, rather than incorrectly marking them against The Hollow’s.
- The in-game rules overview links to the consolidated current rulebook. The browser version and PDF now describe v0.19.

## Final scripted trials

30 seeds × 6 legal team configurations × 3 Blank-movement settings = **540 fights per cohort**, **1,620 total**.

| Cohort | Hero wins | Boss wins | Stalls |
|---|---:|---:|---:|
| The Hollow, hazard-aware bot | 152 | 388 | 0 |
| The Hollow, ignores hazard penalties | 74 | 466 | 0 |
| Nu’gh, phase-aware target priority | 100 | 440 | 0 |

The Hollow comparison uses identical seeds, builds and settings, with a changed movement policy; decisions alter subsequent random draws. The hazard-aware policy avoids warned and burning cells, while the other continues approaching the boss without those penalties. This is evidence about these bot policies, not a human win-rate prediction.

**Starting faces only**, 30 fights for each setting:

| Boss | Blank OFF | Blank Move 1 | Blank Move 2 |
|---|---:|---:|---:|
| The Hollow | 0 wins / 30 losses | 3 / 27 | 10 / 20 |
| Nu’gh | 0 / 30 | 2 / 28 | 5 / 25 |

These stress tests are much harsher than the former passive fight. The normal setup also includes two bonus designs per hero; starter-only/Soul-OFF is difficult in this sample. Numeric-focused builds performed better. Further human playtesting is still needed; the bots are not expert players.

The regression suites and new encounter/UI checks cover summon exclusion, retreat legality, individual commanded attacks, reaction attribution, Soul Link cutoff and healing persistence, fire avoidance and mitigation, and visible fallback results.

Saved custom numeric overrides still take precedence. To try new defaults after previous experiments, reset the relevant boss sections (or reset all values) and apply.
