# v0.17 — read the fight

## Focus and rerolls

- Selecting **Focus** marks legal dice **FOCUS TARGET**. Click one: Focus turns grey / SPENT, the new result is selected and shown in the ability panel, and that die is marked **RESOLVE NEXT**. The instruction and battle log show the old result → new result. Results appear instantly; rolling animations stay removed.
- Focus is a separate ability: it still works after an ordinary action closes the banked-reroll window and does not spend a banked charge. Its new result must be resolved or declined before another ordinary die.
- A new Reaction result is stored and labelled **REACTION HELD** instead of leaving a nonexistent forced action.
- Banked rerolls explicitly show **OPEN**, **CLOSED**, **PAUSED**, **NO CHARGES** or **CANNOT REROLL THIS DIE**. A closed window labels remaining charges **saved**, with their next usable timing.
- Gambler’s Coin, Conjure and Passing Grace are non-rerollable under the supplied face rules; Red Tiles are locked. Cards show **NO REROLL** and the disabled reroll control explains the restriction. Focus now respects the same restriction; it previously bypassed it. A rejected Focus attempt spends nothing and writes no false action declaration.

## Less text, more room

- Spent dice and held reactions / Channels are grey. They remain clickable for inspection; clicking one cannot select it for an action or interrupt a forced result.
- All 59 faces have short effect descriptions. The normal inspector shows the name, type / timing and effect, with active custom values. **More rules / custom values** opens the long reference when needed. The unrelated full hero-status dump no longer gets appended to every ability.
- Boss actions also have short summaries using the encounter’s active settings.
- Fixed-width buttons clip / wrap instead of growing through neighbouring controls. Choice grids use wrapped 12 px text rather than shrinking names to 10 px. Small forge / draft faces use larger names; side numbers remain available in tooltips / View dice. View dice puts type information in its details area rather than repeating it on every square.
- UI text uses smooth sampling. Pixel sprites and portraits retain nearest-neighbour sampling. Disabled controls are grey but have higher text contrast.
- The battlefield remains 684 × 684, HP dots stay, and ability / effect panels remain beside the battlefield.

## Active effects

- **Weak Point READY** has a persistent gold marker on its hero, an activation label and a prominent Effects button. The active hero’s valid rear squares are outlined and labelled **REAR**.
- The effect panel explains when Weak Point expires and how to consume it. Its internal Backstab marker now uses the ability’s familiar name in activation logs.
- Click **Effects** to read all current buffs and debuffs, including their timing. Effects on inactive heroes remain available by hovering over their sprite or party card.

## Boss attacks and half-health upgrades

- Boss attacks have a stronger lunge, broad hit effects, impact rings, sparks and heavier Sweep / Roar shockwaves. Hits cause a brief shake of the arena only; the UI stays still. HP hits use a low thump and blocks a metallic sound. These sounds use the existing SFX bus and obey Sound OFF.
- **Menu → Game options → Combat impact effects** disables the heavy effects, recoil and arena shake. Sound is controlled separately.
- A persistent **Upgrades at … HP / view changes** button uses the actual boss HP threshold. Its panel shows all three changes together: Cinder Brand’s cross becomes a square, Ashen Chain adds Rooted until the next boss turn, and Furnace Roar unlocks.
- Crossing the threshold opens this explanation automatically alongside the existing phase transition and burning boss sprite. The button remains available afterward.

## Rules and verification

Default HP, damage, dice odds, caps, Soul allowance and boss phase rules are unchanged. The sole eligibility correction is applying the written non-rerollable restriction consistently to Focus. Saved balance profiles remain active.

Checks cover Focus after the opening window, correct new-face inspection, all four non-rerollable faces, spent / forced / held states, saved versus usable reroll charges, Weak Point activation and expiry, all 59 short descriptions, active custom values, half-health explanations, effect opt-out and modal choice layout. The existing combat, preset, loadout, Soul and boss suites remain in use. Browser checks exercise the real controls and look for script / console errors.

The [explained trial report](https://lordtoff.github.io/Godot-Game-Template/playtest-report.html) remains a report of the recorded **v0.16** trials; it is not relabelled as a new v0.17 playtest.

Final verification: 157 combat-clarity checks and 1,508 choice-layout checks passed; the existing 30-suite regression run passed. A 180-encounter smoke set finished with no stalls. Browser testing covers Focus, reroll restrictions, Weak Point, phase upgrades, drag placement and saved builds.
