# v0.16 — trial battles and fixes

## What changed

| Ability / rule | Fix | Why |
| --- | --- | --- |
| Black Oath | Its cost expires at the end of the casting turn, including when no Block remains. | Previously an unused cost could survive and charge HP after a later Guard. |
| Wither Ward | Only HP damage from an adjacent boss Attack applies Weakness to the boss. | Self-costs, friendly fire and Cinder Brand hazards have no attacking unit. They previously weakened the boss anyway. Fully prevented damage still does not trigger Ward. |
| Fracture in the workshop | A destruction count of 0 removes no faces and opens no destructive choice. | Zero previously still forced one face to be removed. Positive counts retain their existing behavior. |
| Engrave / Hooked Slash | A qualifying killing hit still grants its die growth / Block. | Victory previously skipped these printed on-hit effects. No further attack damage resolves after victory. |
| Combat log | Black Oath's HP cost names the correct hero and cause. | Its old label could come from a different previous action. |

Default HP, damage, Numeric odds and Soul settings are retained. The normal fight still starts with Blank movement OFF. Move 1 / Move 2 remain workshop experiments; the Soul toggle controls whether conversion is enabled.

## Trial results

**7,200 completed fights:** 3,600 before and 3,600 after the fixes, using matched seeds. **Zero stalls or detected invalid HP / Block / dead states.** Every win/loss count below was unchanged after the fixes; the targeted regression tests reproduce the edge cases these encounters did not expose in their outcomes.

Each cell is **player wins / boss wins out of 200** after the fixes. Every hero uses the standard starting body, plus two bonus designs unless the row says starting faces only. New boss attacks and the real half-HP phase are active.

| Team build | Blank: no movement | One Blank → Move 1 | One Blank → Move 2 |
| --- | ---: | ---: | ---: |
| Starting faces only | 67 / 133 | 141 / 59 | 170 / 30 |
| Random bonus pairs | 99 / 101 | 166 / 34 | 178 / 22 |
| Numeric attacks | 158 / 42 | 196 / 4 | 199 / 1 |
| Support / defense | 80 / 120 | 134 / 66 | 167 / 33 |
| Channels + attacks | 118 / 82 | 170 / 30 | 185 / 15 |
| Growth / sustain | 149 / 51 | 185 / 15 | 195 / 5 |

The allowance is **once per hero's own turn**, including a full recovery turn. These tests do not change it to a shared party or per-combat cap.

### What the results suggest

- **The normal random-bonus encounter is close:** 99/200 wins (49.5%) with Soul OFF. This does not support a general boss HP reduction.
- **Mobility is a large advantage:** random bonuses reach 83% with Move 1 and 89% with Move 2. Starting-only teams go from 33.5% to 85%. Treat the test Soul as a substantial difficulty change.
- **Attack-heavy teams finish the boss sooner:** the Numeric team wins 79% without Soul and averages 10.49 rounds; random bonuses average 12.85. They spend fewer rounds exposed to boss attacks. With Move 2 they win 199/200, so that combination is especially forgiving.
- **Support teams are slower:** 40% wins and 15.15 rounds without Soul. This bot does not optimize party rescue, deliberate tanking or long-term support combinations. A whole support kit versus a whole attack kit cannot identify which individual face needs a buff; changing every defense value from this sample would be premature.
- **The boss still applies pressure:** Smoking Strike, Sweep and Skirmish were the largest aggregate HP-damage sources in the random-bonus / Soul-OFF trials. 191/200 reached phase II. Cinder Brand still dealt damage despite an explicit escape heuristic, because movement was not always available.

These are fixed-strategy automated comparisons, **not predicted human win rates**. Different layouts, timing choices and human tactics can change the results. The previous simple starter bot still reports 17/100 wins; the new heuristic reaches 67/200 by prioritizing healing / revivals and moving out of delayed hazards. Those policies must not be compared as if they were the same experiment.

## Exact teams and method

Bonus pairs in Vesper / Rook / Wren order:

- **Numeric:** Strike Numeric + Piercing Thrust; Short Shot + Flanking Blow; Hooked Slash + Break Rhythm.
- **Support:** Restore + Brace Hero; Guard Numeric + Shield Wall; Bulwark + Oathbound Exchange.
- **Channel:** Contained Power + Piercing Thrust; Stonewake + Flanking Blow; Last Pulse + Short Shot.
- **Growth:** Engrave + Bone Mutation; Blessing of Recovery + Restore; Engrave + Brace Hero.
- **Random pairs:** two distinct designs per hero, uniformly drawn from all 47 extended designs using a separate deterministic generator seeded with encounter seed × 173. The model's normal `bonus_build` places them legally.

The bot reads visible rolls and board state. It prioritizes injured allies, setup effects and legal attacks; moves toward the boss while penalizing marked Brand cells, existing fire and board edges; spends opening rerolls on unusable Blanks; and resolves all supported choice / reaction windows. It keeps Channels. It uses the same explicit “spend with no effect” option as the UI when a copy effect has no legal source. It does not inspect future RNG outcomes, alter combat state to guarantee abilities or optimize all possible moves. Stalls are capped at 1,600 decision steps or 50 rounds and fail the run; none occurred.

Raw before/after outcomes, per-ability usage, damage totals, phase rates and mean rounds: [Trial-results-v0.16.json](Trial-results-v0.16.json).

## Reproduce

```bash
ASH_TRIAL_COUNT=200 ASH_TRIAL_REPORT=/tmp/ash-trial-report.json   godot --headless --path . --script prototype/tests/trial_battles.gd
godot --headless --path . --script prototype/tests/trial_regression_test.gd
```

The dedicated regressions cover cost expiry, a later Guard, the legitimate cost, Ward from a real hit versus self-cost / friendly fire / hazards / prevention, zero-count Fracture and killing-hit rewards. The existing rules, catalog, all 1,081 bonus pairs, loadouts, presets, Soul refresh, boss phases and UI tests are retained.
