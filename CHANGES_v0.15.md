# v0.15 — bug scan and fixes

This update fixes reproduced problems. It does not change the default HP, damage, dice odds, Soul allowance or boss phase rules.

## Combat fixes

| Problem | Fix |
| --- | --- |
| A Drive Back collision skipped Stunned when the hero had no unused dice. | Stunned is always applied after a surviving collision. There is no impossible immediate die-choice prompt if all dice are spent; an active Stunned status is handled before the next shared roll. Channel-held dice are disabled in that choice window. |
| A Broken hero killed during its turn could still resolve unused dice. | Killed heroes lose temporary effects and cannot act or reroll. Combat disables their dice and explains that the turn can be ended. |
| Setting Blood Bargain to zero charges created a bonus that never ran out. | Zero charges arms no bonus or backlash. An exhausted bargain cannot empower an attack. |
| Rear attacks incorrectly used Wither Ward’s range setting. | Weak Point / rear positioning now depend on the boss’s southern edge and adjacency, independently of Ward tuning. |
| Wither Ward could trigger when Defy Death prevented all HP loss. | Ward checks actual HP loss after prevention. |
| Some combat log descriptions always said Weakness 1, Reduction 1 or Debt 2 despite edited values. | Those entries now show the actual active values. |
| A zero-positive-sides Numeric die could still roll its higher-value sides. | Higher-value side count is capped by the positive-side count. Setting positive sides to zero now produces the configured Blank value on all six ordinary sides. |

## Controls and saved builds

- Invalid die indices and obsolete choice callbacks no longer resolve another die or access a missing pending choice.
- Reaction handling no longer unnecessarily indexes an empty held-reaction list when an explicit reaction die is available.
- Loadouts are checked for exactly three six-sided dice, known face IDs and whole numbers. Invalid face values cannot become negative array indices or silently round down.
- Preset loading validates the complete team and option types before applying anything. Invalid data gives an error and keeps the current team intact. Whole-number JSON values remain compatible with existing presets; optional owned bonus designs may still be left unequipped in a manual build.
- Malformed JSON imports show a useful message without producing an engine error or applying the draft.
- Restore balanced build preserves the selected bonus designs and equips them in a legal starter layout. If those designs cannot fit the current custom profile, the current build stays intact and the game explains why.
- Initiative sorting now uses a strict comparison for equal entries.

## Verification

Focused regression tests reproduce the combat failures before the fixes and verify the corrected behavior afterward. Additional tests cover malformed / fractional preset data, successful JSON round-trips, preserving builds after a rejected load, disabled dead-hero controls, held-Channel Stunned choices and invalid profile import feedback. Existing rules, ability catalog, all 1,081 bonus pairs, normal-combat Blank refresh, drag placement and interface checks are retained.

The 100-seed starter-only simulation finished **17 wins / 83 losses / no stalls**. Bonus-pair simulation finished **58 / 42 / no stalls**. The previous bonus result was 59 / 41; correcting missing effects can change outcomes even when base numbers stay the same. These fixed-strategy simulations are comparisons, not human win-rate predictions.
