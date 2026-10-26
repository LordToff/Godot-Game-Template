# v0.12 — changes from the previous browser build

These are the new **Tuned** defaults. Your deliberately saved custom values still override defaults. To try this balance, open **Menu → Game options → Balance workshop → Reset all → Apply**. This restarts the fight. The Soul ON/OFF switch is separate; Blank movement remains Move 2, once per hero turn unless you edit it.

| Change | New behavior | Why |
| --- | --- | --- |
| Basic Strike | 1 damage, previously 2. | Requested reduction in reliable flat damage. |
| Numeric die | The six ordinary sides are **2, 2, 1, 1, 1, 0**. Applies to attacks, healing and defense. The old Tuned +1 attack bonus is now 0. | Let the printed roll provide the strength, without an additional hidden flat bonus. |
| Short Shot | Final damage cap 2, including Mark Prey; previously 1. | Let the new Numeric 2 matter for the ranged attack. |
| Stonewake | Any actual HP loss, or **2 cumulative Block lost before your next own turn**, immediately ends its Channel. Damage, theft and voluntarily burned Block count. Fully prevented damage does not. The counter resets on your next own turn if the Channel survives. | Stop indefinite maintenance behind a shield. Separate one-Block losses add up. |
| Engrave | Only grows after dealing HP damage, at most once per hero turn. Adds a copy only to a Blank on its own die; maximum 3 copies. At 3 copies, +1 damage. Never overwrites another ability. | Stop rapid multiplication, growth from fully blocked hits and replacement of the whole die. |
| Boss durability and Strike | Tuned boss HP **16 → 12**; boss Strike damage **2 → 1**. Original base keeps its 18 HP / 2-damage boss Strike. | Compensate for halving starter Strike damage and adding a boss phase. |
| Cinder Brand | Marks a **3×3 square**, including corners, instead of a five-cell cross. Detonates at next boss turn start for 1 normal damage. Clipped at arena edges; no stacking. | A clearer and more useful area threat, with time to escape. |
| Half-health boss phase | At **50% HP or lower**, once per encounter, unlock **Furnace Roar**. The next unresolved boss die becomes Roar. It also replaces Brace on Die I for future rolls. | A visible change in boss behavior midway through the fight. |
| Furnace Roar | Attack every standing hero within 2 of the boss footprint for 1, then push survivors up to 1 legal cell away. Normal defensive reactions apply. Blocked pushes stop; no collision damage or Stun. | Pressure close formations without adding a large unavoidable damage spike. |

A broken Stonewake die stays spent until the next shared roll; its installed face is preserved. Voluntarily releasing it still rolls the released die immediately. New numeric parameters are available in the balance workshop.

## Reading and editing the dice

- Clicking a combat ability opens a **scrollable description on the far right**, temporarily replacing the log. It never covers the battlefield. Held reactions and Channels can also be inspected. Close it to restore the log. Boss intent buttons use the same panel.
- Hover a hero for their full status list, including values. The active hero also has an Effects summary; full explanations appear in the ability panel and hover text.
- Player HP uses dots again. With a custom maximum above 12, the display adds the exact number beneath the dots.
- Both the forge and View dice use your reference's unfolded net: four squares down the middle, with one square to either side of the second square. All 18 side assignments stay on their original dice. The net is a layout, not a change in roll odds.
- View dice retains rolled-side highlights, changed-face highlights and original-face history.
- Lab tools can force the next Numeric result to 0, 1 **or 2**.

## Rerolls

Blank rerolls are legal during the opening window. A reroll can land on Blank again, including the same side. It still spends the charge and keeps the new result. The log now prints old and new side numbers and face names, and explicitly explains repeated results.

The reroll button now uses the same eligibility check as the rules and explains why it is disabled. It cannot silently offer a spent die or bypass a result that Focus or another ability requires you to resolve next. The opening-window rule remains: spend ordinary Action Rerolls before your first normal action. Focus can still reroll another unresolved die later.

## Verification

100 seeded automated encounters with starter faces only: **47 hero wins / 53 boss wins / 0 stalls**. With the existing bonus-pair automated builds: **72 / 28 / 0 stalls**. Before reducing boss HP and Strike, the same new hero rules gave only 1 starter-build win in 100 against the old boss stats. These scripts use simple fixed strategies; the results are a comparison, not predicted human win rates.

Targeted checks cover cumulative Stonewake interruption, prevented/HP/stripped damage, own-turn resets, actual Numeric rolls and all six values, Engrave limits, square fire corners, the once-only half-HP transition, Roar reactions and pushing, and repeated-Blank rerolls. UI checks verify the nets, full status descriptions and a side panel that leaves the board unobstructed.
