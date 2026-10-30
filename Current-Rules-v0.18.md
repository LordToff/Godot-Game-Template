# Ash & Oath — Current Rules v0.18

Prepared 30 October 2026. Default Tuned profile, no custom overrides.


## 1. Start here

Current playable rules for Ash & Oath v0.18. Prepared 30 October 2026. This is a consolidated rulebook, not a change log.

### Which rules does this document describe?

The browser prototype using Tuned numbers, with no custom numeric overrides. Optional Blank movement is described separately. The supplied draft documents inspired the game; this document describes the implemented prototype, including its declared interpretations. Older patch notes are historical.

### Your goal

Control Vesper, Rook and Wren against one chosen boss. Defeat the boss to win. If all three heroes are dead or at zero HP together, the fight ends in defeat. Against Nu’gh, defeating the summoner also removes his remaining worms.

### Before entering the arena

Choose two different bonus faces for each hero from the full 47-face bonus pool. These are faces, not whole dice. Click to quick-equip or drag them onto a die or exact slot. Each hero has a separate build and separate ownership limits. After all choices, the review screen lets you choose The Hollow or Nu’gh, Tuned or Original numbers, and Blank movement OFF, Move 1 or Move 2. Check the displayed party and rules, then Enter fight.

### Default starting values

Each hero starts at 6 HP, 0 Block and 1 banked Action Reroll. The reroll bank cap is 1. The Hollow starts at 12 HP; Nu’gh starts at 10 HP with two 1-HP worms. The arena is a 9×9 grid. Each hero has three six-sided Action Dice. The boss occupies a 2×2 footprint.

### Where to look during play

The header names the active hero or boss and shows the round and boss intents. Click a die to read its effect in the side panel; the battlefield stays visible. Effects explains active buffs and durations. Hover a unit for its state. View dice shows every installed side, the current recorded result, and encounter mutations. Open the boss upgrade guide before or after the half-HP threshold. Full history provides detailed event ordering.

## 2. Dice construction and ownership

Limits apply to each hero individually. Do not confuse limits per die with limits across the hero’s three dice.

### Six sides; at least two Blanks per die

Each of the three dice has exactly six sides. Each die must start with at least two Blanks, leaving at most four equipped abilities. A Red Tile is a penalty face, not a Blank. There is no additional per-die category cap in the current implementation.

### Category caps across all three dice

A hero may equip at most 3 Movement faces, 3 Defense faces and 3 Skill faces in total across all three dice. Attack faces have no separate category cap, but ownership, six-side construction and minimum Blanks still restrict them. Extra Attack designs do not grant unlimited copies.

### Owned starting faces per hero

Strike ×4; Step ×2; Stride ×1; Guard ×2; Reaction ×1; Focus ×1; First Aid ×1; Shove ×1. Each of the hero’s two selected bonus designs adds one owned copy. Shove is available to build with, but is not installed in the default layout below.

### Default layout before bonus placement

Die I: Strike / Step / Guard / Strike / Blank / Blank. Die II: Strike / Stride / Reaction / Step / Blank / Blank. Die III: Strike / First Aid / Focus / Guard / Blank / Blank. Equipping bonus faces replaces existing sides as necessary to keep the build legal; inspect the final nets before entering.

### Changes during a fight

Generated faces, Engrave growth and other explicit mutations can change dice during combat; the opening construction validator is not reapplied to these effects. Mutations are for this encounter. A recorded result can remain usable even if its installed side later changes, unless the effect explicitly removes a held result. View dice distinguishes the installed side from the recorded roll. Rebuilding/retrying restores the recorded starting build.

## 3. Round and turn sequence

A round is one circuit of the initiative order. A turn is one hero’s or the boss’s activation. Dice roll together at round start, not at every normal hero turn.

### A. Set initiative once

At encounter start, each hero and the boss rolls initiative from 1 to 6. Higher goes first. The boss wins an initiative tie with a hero; hero ties use Vesper, then Rook, then Wren. This order stays fixed, except a temporary Break Rhythm delay that resets next round.

### B. Begin the shared round

Clear the previous round’s stored Reactions and Mark Prey. If a hero is still Stunned, choose a die to set aside before rolling; an actively Channeling die cannot be chosen. Roll each available Action Die once for all heroes and the boss. Held Channel dice do not roll. Reaction results automatically become held Reactions. When-rolled effects such as Clairvoyance trigger now.

### C. Start a hero turn

Expired temporary defenses clear, and ordinary old Block disappears. Stonewake is the exception that can preserve Block. Resolve an unused Echo of Pain penalty if due. Debt’s deferred penalty becomes active; the hero’s Lethargic Bind expires. Refresh that hero’s Blank-conversion allowance and Engrave growth allowance. If a Channel is active, choose Maintain or End before normal actions.

### D. Reroll first, if desired

The opening window allows a banked Action Reroll on one ready eligible die. It costs 1 charge. You keep the new result, even if it is another Blank or the same face. A reroll does not itself close the opening window. Resolving or declining an ordinary face closes it. Focus is a separate ability, explained in section 4.

### E. Resolve hero dice

Use ready immediate results in any order. Select a die, then click a legal board target or destination; use Resolve for untargeted effects. A legal resolution spends that die. Invalid targets spend nothing. Finish any pending choice or forced result before taking another ordinary action. You may end the turn with immediate dice unused; stored Reactions can still respond afterward, until the next shared roll.

### F. End a hero turn

Clear the hero’s Stunned state and unused turn-only boosts. If Black Oath is armed, pay its 1 unavoidable HP cost only if Block remains. Downed protection for all heroes ends when this full turn ends. Process queued recovery turns, then continue the initiative order.

### G. Take the boss turn

At boss turn start, Rooted from Ashen Chain and Distort’s Weakness expire. Armed Cinder Brand cells detonate, then old boss Block clears. Resolve boss dice I → II → III, finishing reactions and other choices before the next die. Click Resolve end of turn after all three. Boss Weakness from Wither Ward expires at boss turn end.

### H. Start the next round

After the last initiative slot and any recovery turns, return to the round-start sequence. Unspent immediate results are replaced by the new shared roll. Reroll charges do not automatically refill.

## 4. Timing: actions, rerolls, Reactions and Channels

Category describes the effect family. Timing describes when it can happen. For example, Shield Wall is Defense – Reaction; Stonewake is Skill – Channel.

### Ordinary actions

Attack, Defense, Skill and Movement results usually resolve during their owner’s turn. They are spent once resolved or declined. A grey card may be spent, held as a Reaction, or held as a Channel: inspect its state label. Clicking a grey card still lets you read it.

### Banked Action Reroll versus Focus

A banked reroll uses a saved charge and only works in the opening window. Focus spends its own rolled face to reroll another READY die, and can work after other actions. Its new result must resolve next or be declined. A Reaction result is stored instead. Neither method can reroll spent/held dice, a locked Red Tile, Gambler’s Coin, Conjure or Passing Grace. Focus cannot target itself. A displayed saved charge can exist while the opening window is CLOSED.

### When-rolled effects

Clairvoyance adds a charge as soon as rolled, up to the cap; it does not wait for the hero to click Resolve. Echo of Pain arms its unused-result penalty when rolled. Contained Power can respond to other dice rolling while maintained. Repeatedly rerolling a Blank is legal; a new Blank is not evidence of a failed reroll.

### Reaction window

A held Reaction is checked before a boss Attack applies damage. The interface pauses when its trigger is legal. Use spends it; Hold declines this opportunity while keeping the result for another eligible attack before the next shared roll. Basic Reaction gives Block and optional movement. Shield Wall protects an ally, Taunt and Target Override can redirect, Defy Death prevents a lethal hit, and Echo of Pain retaliates. Reactions do not normally respond to self-costs, collision damage or Brand hazards.

### After a Reaction changes position or target

A single-target Attack rechecks range and may retarget to another legal hero. Moving one hero away does not necessarily cancel the boss’s attack. Sweep and Furnace Roar check whether their selected victims remain in range and hit each once. Forced movement and a reaction step still obey their own movement restrictions.

### Channel start and maintenance

Only one Channel may be active per hero. Starting one holds its die; it does not become a normal ready result on shared rolls. At the next own turn, Maintain applies its maintained effect and keeps the die held. End releases the Channel and rolls that die immediately, including its when-rolled/Reaction handling. Starting another Channel cannot silently replace the first.

### Channel interruption

Contained Power breaks on actual HP loss, adds 2 normal backlash damage and leaves a Red Tile on its source side. Last Pulse breaks on actual HP loss and turns its source side Blank. Stonewake breaks on any HP loss or 2 cumulative Block lost within the window before the next own turn. Removing Block via a non-damage effect counts too. Block absorbing all damage does not break the first two Channels. Lethal HP loss still applies the relevant source-side mutation.

### Forced choices

Focus, Borrow Shape, copied/repeated effects and mutation picks can require a particular result or selection next. The interface pauses until that choice is complete. A failed or illegal choice does not grant a free alternate action. Choosing an ability’s target and inspecting that ability are separate from spending it.

## 5. Movement, targeting and damage

An ability’s own text takes precedence over these general procedures.

### Grid distance and adjacency

Normal distance counts orthogonal grid steps, not diagonals. Adjacent means distance 1. Distance to the 2×2 boss uses the nearest square of its footprint. Units block occupied cells. A dead worm frees its cell; a Downed but living hero still occupies theirs.

### Movement types

Step and Ashstep may turn along a clear path. Stride is a straight line and cannot turn. Leap of Echoes may jump over units but must land on an empty legal cell. Shove pushes away without collision damage. Drive Back pushes automatically along its incoming direction; players do not choose the direction. Rooted blocks voluntary moves and swaps, but not forced pushes/pulls.

### Line of sight and targets

Abilities that require sight use a straight grid ray; units can obstruct it, including worms, and blocked diagonal corners prevent shooting through. Do not assume every ability needs sight: follow its text. Several Attacks may target allies; the interface asks for confirmation. Hero healing cannot target bosses or worms. Dead heroes cannot be healed.

### Numeric die: what it means

The default ordinary Numeric die has faces 2, 2, 1, 1, 1, 0. “Roll for damage”, “rolled Block” and “heal a rolled value” mean roll this die when resolving that effect. An Action Die chooses the ability; the Numeric die determines its value. Strike deals a fixed 1 and does not roll Numeric. Strike Numeric rolls it. There is no extra default +1 bonus just for being a Numeric Attack.

### Damage order

Compute the attack’s value and relevant modifiers, then apply Weakness (minimum zero). Normal damage consumes Block first, then the remaining amount is reduced by Damage Reduction, and only the remainder removes HP. Unavoidable damage skips Block and ordinary Damage Reduction. Effects requiring HP damage only trigger if HP actually decreases. Pierce bypasses the stated amount of Block for that hit; the bypassed Block is preserved.

### Repeated Attacks

A repeat is another hit, not just doubled damage. Each hit rechecks target legality, range and any required sight; Numeric repeats roll again. A dead target stops later hits. Conditional riders such as Hooked Slash and Engrave check qualifying HP damage. Short Shot’s final per-hit cap is 2, including Mark Prey. A consumed mark or limited charge does not remain for every repeat.

### Gambler and Numeric modifiers

Gambler replaces the final two ordinary Numeric sides with ×0 and ×2. ×2 rolls an ordinary Numeric value and doubles it. ×0 is an absolute zero: boosts do not rescue it. Numeric Echo stores one ordinary value for the next Numeric roll. Focus Numeric changes the next Numeric Blank to 1. Forgotten Strength and Leap bonuses apply to the next rolled damage this turn, not fixed Strike damage.

### Fire is not one universal effect

Smoking Strike leaves persistent cell fire only after HP damage; another qualifying Smoking Strike on an already-burning cell consumes it for extra normal damage. Merely walking onto that cell does not detonate it. Cinder Brand is a separate delayed marked area that detonates at the next boss turn. Ember Burst is an immediate chosen Block-burn effect that can hurt allies and worms.

## 6. Status, Downed heroes and recovery

Read the duration on each source. “Until your next turn” is different from “until the next boss turn” or “until round end”.

### Block and Damage Reduction

Block is a consumable pool, not extra maximum HP. Old Block normally clears at the owner’s next turn start. Damage Reduction removes damage after Block and clears at the hero’s next turn start. Stonewake can preserve Block while maintained. Brood Guard’s worm shield persists until consumed; repeated shielding does not stack above its stated amount.

### Weakness

Weakness reduces Attack damage, to a minimum of zero. Distort lasts until the next boss turn start; Bulwark’s self-Weakness lasts until the hero’s next turn. When both apply, use the greater reduction, not their sum. Wither Ward gives the boss Weakness after an adjacent boss Attack actually removes HP; it lasts until the boss turn ends.

### Rooted

No voluntary movement while active, including reaction steps and Oathbound Exchange. Forced movement remains legal. Upgraded Ashen Chain applies Rooted 1 until the next boss turn begins. The sprite has a persistent root effect.

### Stunned

On application, choose an unused die to lose if one exists. If no unused die remains, the status stays visible; if still Stunned before the next shared roll, choose a non-Channel die to set aside for that roll. Gaining Stunned while already Stunned causes 1 unavoidable damage instead of granting another die choice. Stunned clears at the hero’s turn end. Orbiting stars show the current status.

### Weak Point, Mark Prey and Blood Bargain

Weak Point is personal: the next qualifying rear Attack repeats once, and the marker lasts through the end of the next round unless spent. Rear means the boss’s southern edge. Mark Prey is a boss mark, ending at the next shared round or after its next damaging hit while at zero Block. Blood Bargain empowers the next two Attacks against the boss and charges its owner 1 unavoidable damage after the second.

### Downed at zero HP

The first time a hero reaches zero HP without already being Broken, they become Downed. Their Block, Reactions, Channel and temporary effects are cleared; their reroll bank becomes zero. They cannot take normal actions. Protection prevents death from further damage for the remainder of the current full turn. After that protection ends, further positive HP damage can kill them. If everyone is Downed/dead together, defeat happens immediately.

### Healing a Downed hero

Positive healing revives them and marks them Broken. At the end of the currently active full turn, the revived hero receives a fresh, immediate recovery turn with rerolled Action Dice. Their later normal slot in that round is replaced rather than added as a second turn. Their Blank-conversion allowance refreshes for recovery, but a starting reroll is not automatically restored.

### Broken and dead

Broken means the next fall to zero HP is lethal. Dead heroes cannot act or revive during the encounter. Physical die mutations remain through Downing/revival, while temporary combat statuses do not. Retry starts a clean encounter using the saved starting build and selected rules.

## 7. Blank movement and custom rules

Optional movement is one explicit rule choice, separate from an ordinary Blank’s lack of effect.

### Blank movement OFF

A rolled Action Die Blank has no normal effect. It can be spent without moving. It is not a free Numeric roll, a reroll charge, or a movement resource.

### Blank → Move 1 or Move 2

With the Soul option ON, each hero may convert at most one rolled Action Die Blank during each of their own turns. Spend the Blank to move up to the selected distance. It still stays Blank on the installed die. Other Blanks can be spent without movement. Rooted prevents the voluntary movement. A successful conversion consumes the allowance; an invalid move does not.

### Exactly when it resets

Reset at that hero’s next normal own turn or full recovery turn. The allowance is separate for each hero. A shared round roll, reroll, Focus, or toggling the Soul OFF and ON does not refresh it. The default is one conversion, not one per die and not one per entire combat.

### Original preset

Original changes the ordinary Numeric die to 1, 1, 1, 1, 0, 0 and The Hollow to 18 HP, Smoking Strike 2, Brace 2 and its older boss dice. It also enables 1 idle fallback Block. Construction, timing and most current systems remain in place: Original is a prototype preset, not a complete recreation of every supplied draft rule. Nu’gh keeps his own boss values; the preset can still affect shared hero Numeric values.

### Advanced numeric rules

Open Advanced numeric rules on review, or Menu → Game options → Balance workshop. Search and change values; Apply saves the profile and restarts the current fight/test. Saved local overrides take precedence over the selected preset and this document’s defaults. Reset all values and Apply to restore that preset’s defaults. JSON imports remain a draft until applied. Applying incompatible construction limits returns you to the forge.

### What is saved

Build presets store the three heroes’ legal layouts and bonus ownership; balance profiles store numeric overrides and a base preset. These do not save a campaign or a mid-fight checkpoint. Retry preserves your selected boss and reviewed fight settings. In-fight mutations reset for the fresh encounter.

### The Hollow’s Original dice

Die 1: Advance, Advance, Smoking Strike, Smoking Strike, Brace, Drive Back | Die 2: Advance, Skirmish, Smoking Strike, Sweep, Brace, Distort | Die 3: Advance, Skirmish, Smoking Strike, Sweep, Drive Back, Fracture

## 8. Practice and prototype scope

Use the Ability Lab to test interactions without rebuilding a normal team.

### Practice tools

The guided tutorial introduces play; the Ability Lab can prepare individual abilities, combine a second face, force Numeric values, reroll prepared results, trigger test attacks, reset and copy a reproducible log. Lab fixture HP/Block differs from ordinary encounter defaults, and has its own numeric settings.

### Implemented limits

Gold is recorded but there is no shop. Conjure and Second Chance only support the listed immediate abilities and prevent copy/repeat loops. One Channel per hero is an explicit prototype limit. The two bosses are selectable standalone fights, not a full campaign or progression economy. Generated Bone/Recovery and Red Tile are not normal bonus-pool offers.

### Reading an uncertain outcome

First inspect the exact face, active effects, reroll state and current dice net; then check Full history. A zero Numeric roll, blocked hit, same-result reroll, expired marker or closed opening window can be a legal outcome. The following catalog describes current default effects, including prototype interpretations.

## 9. Starting abilities

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Blank · Blank

No ordinary effect. With the test Soul ON, spend a Blank as Move 2; at most 1 per hero turn.

### Strike · Attack

Deal 1 damage to an adjacent unit.

### Step · Movement

Move up to 1 orthogonal spaces. Occupied cells block the path.

### Stride · Movement

Move up to 3 spaces in a straight line. No turning or passing through units.

### Guard · Defense

Gain 1 Block. Unspent Block expires at your next turn.

### Reaction · Defense - Reaction

When attacked, gain 1 Block and optionally step 1 before the hit.

### Focus · Skill

Click another READY die to reroll it. Resolve its new result next, or decline it. Works after other actions. Uses this Focus face, not a reroll charge. Locked faces cannot be rerolled.

### First Aid · Skill

Heal yourself or an ally within 1 for 1 HP. A Downed ally revives as Broken.

### Shove · Skill

Push an adjacent unit up to 1 spaces away. No collision damage.

## 10. Bonus Skills

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Gambler's Coin · Skill

First use: arm Numeric ×0 / ×2. Next use: gain 1 Gold and turn this face Blank. Non-rerollable. Gold has no shop in this encounter.

### Weak Point · Skill

Arm Weak Point through the end of the next 1 round(s). Your next Attack from the boss’s southern edge repeats 1 extra time(s). The gold marker stays until used or expired. The repeat requires an Attack against the boss from its southern edge, not merely standing behind another enemy.

### Conjure · Skill

Copy another visible immediate hero ability within 99. Choose its hero and die, then resolve the copy. No setup or copy chains. Non-rerollable.

### Blessing of Recovery · Skill

Install Recovery on a chosen Blank belonging to a hero. Recovery heals a rolled value at range 1. After 2 placements, this face becomes Blank.

### Clairvoyance · Skill

When rolled, gain 1 Action Reroll, up to the bank cap of 1. A full bank gains nothing.

### Forgotten Strength · Skill

Your next rolled damage this turn gets +1.

### Passing Grace · Skill

Heal another hero within 3 for a rolled value. Move this face to a Blank on that hero. Cannot heal yourself. Non-rerollable. Passing Grace requires a recipient with a Blank; if no legal recipient slot exists, it does not destroy itself.

### Borrow Shape · Skill

Choose an unresolved die and one of its installed faces. Turn it to that face and resolve it next. Red Tiles are unavailable.

### Numeric Echo · Skill

Roll and store one ordinary value. Use it instead of your next Numeric roll. Only one value can be stored.

### Lethargic Bind · Skill

Bind a chosen boss die and face until your next turn. Each matching roll is skipped, but you take 1 normal damage.

### Restore · Skill

Heal another hero within 3 for a rolled value, at least 1. Clear sight required. Gambler ×0 stays zero.

### Focus Numeric · Skill

Your next Numeric roll this turn treats Blank as 1.

### Mark Prey · Skill

Mark the boss until round end. Its next damaging Attack hit while at zero Block gains 1 damage, then removes the mark.

### Last Word · Skill

After your other non-Blank dice are spent, deal 1 unavoidable damage to the boss.

### Second Chance · Skill

Skip another unresolved non-Blank die. Repeat a different, already-spent immediate ability. No repeat or copy chains.

### Spiral Instability · Skill

Choose an Attack from this die and resolve it 2 times at random legal targets, including allies. No Attack on this die means no effect.

### Contained Power · Skill - Channel

Maintain: future Blank rolls grant 1 Block; other rolls add +1 to Numeric, capped at +2. HP loss breaks it, causes 2 normal backlash damage and leaves a Red Tile.

### Corruption Conversion · Skill

Choose an unresolved Blank die, then an ability installed on it. Resolve that result. This Conversion face becomes a locked Red Tile.

### Blood Bargain · Skill

The next 2 Attacks against the boss gain +1 damage. After the last, you take 1 unavoidable damage.

### Target Override · Skill - Reaction

When personally targeted, redirect to a different legal adjacent hero. With no alternative, the original target remains.

### Debt · Skill

Next Attack or Defense this turn: +2. At your next turn, your first such face suffers −2, minimum zero.

### Ill Omen · Skill

Modify an unresolved Attack or Defense with a random bonus, penalty, Pierce or repeat. Pick the affected die. See More rules for the six outcomes. Ill Omen uses a d6: 1 = −1 value; 2–4 = +1 value; 5 = Pierce 2 on an Attack or +2 Block on a Defense; 6 = repeat an Attack once or double Defense Block.

### Stonewake · Skill - Channel

Gain 2 Block. Maintain: preserve Block and add 1, up to 8. Any HP loss or 2 cumulative Block lost before your next turn interrupts this Channel.

### Oath of Smoke · Skill

Resolve another rolled Step, Stride or Guard now. Then store it as a Reaction until the next shared roll. The stored movement Reaction steps 1; the stored Guard Reaction grants 1 Block. It expires at the next shared roll.

### Bone Mutation · Skill

Install Bone on one of your Blanks for this fight. Bone gains 1 Block and may step 1.

## 11. Bonus Attacks

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Strike Numeric · Attack

Roll for damage against an adjacent unit.

### Short Shot · Attack

Roll for damage against a visible unit within 2. Final damage is capped at 2, including Mark Prey.

### Hooked Slash · Attack

Roll for damage against an adjacent unit. At least 2 HP lost: gain that HP loss ×1 as Block.

### Piercing Thrust · Attack

Roll for damage against an adjacent unit. Bypass 1 Block; the bypassed Block remains after this hit.

### Cleave · Attack

Roll for damage against an adjacent unit. Also deal 1 damage to one other enemy adjacent to the target. The secondary splash applies when the main target is an enemy; attacking an ally does not trigger it.

### Flanking Blow · Attack

Roll for damage against an adjacent unit. Add 1 when standing at the boss’s southern edge.

### Break Rhythm · Attack

Roll for damage against an adjacent unit. Break existing Block and damage HP to delay an upcoming boss activation by 1 slot(s).

### Engrave · Attack

Roll for damage against an adjacent unit. On HP damage, grow on this die up to 1 time(s) per hero turn, capped at 3 copies. At 6 copies: +1 damage. Never overwrites another ability. Growth fills one Blank on this die per qualifying turn, up to 3 copies; at 3 copies the attack gains +1. It cannot overwrite another ability.

## 12. Bonus Defenses

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Guard Numeric · Defense

Roll a value and gain that much Block.

### Brace Hero · Defense

At zero Block: gain 3. Otherwise: gain 1.

### Shield Wall · Defense - Reaction

When an ally within 2 is attacked, give them 1 Block and yourself 1 before the hit. Clear sight required.

### Taunt · Defense - Reaction

When another hero is attacked, take their place if you are a legal target within 1. Cannot redirect Sweep or Furnace Roar.

### Defy Death · Defense - Reaction

Before a lethal Attack, remain at 1 HP instead and gain Stunned. This face becomes Blank. Defy Death automatically spends the first available unused result when applying its Stunned consequence; this is a specific exception to the usual die-choice window.

### Bulwark · Defense

Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction.

### Echo of Pain · Defense - Reaction

During a boss Attack, deal the HP damage you took this round to the boss, capped at 3. This face becomes Blank. Unused: take 1 unavoidable damage at your next turn. The unused penalty is armed when rolled and is checked at the next own turn start; spending the Reaction disarms it.

### Last Pulse · Defense - Channel

Maintain: heal 1 at your turn start. Any HP loss interrupts the Channel and turns this face Blank.

### Black Oath · Defense

Gain a rolled value +1 Block. At your turn end, lose 1 HP if any Block remains.

### Wither Ward · Defense

Gain rolled Block. Until your next turn, an adjacent boss Attack that removes HP gives the boss Weakness 1.

### Ember Burst · Defense

Gain rolled Block, then burn up to 2 Block. Each burned point deals 1 damage to every other unit within 1, including allies.

## 13. Bonus Movement and generated faces

Numbers below use the default Tuned profile. “Rolled” means the Numeric die in section 5.

### Leap of Echoes · Movement

Leap up to 2 spaces, over units but never onto them. End within 1 of the boss to gain +1 on your next rolled damage this turn.

### Ashstep · Movement

Move up to 2 spaces, turning allowed, then gain 1 Block. Occupied cells block the path.

### Oathbound Exchange · Movement

Swap with a standing ally within 3 and clear sight. Both gain 1 Block. Rooted prevents the swap.

### Bone · Skill

Gain 1 Block and optionally step 1.

### Recovery · Skill

Heal yourself or an ally within 1 for a rolled value.

### Red Tile · Penalty

No effect. Locked: cannot be rerolled and does not count as a Blank.

## 14. The Hollow

12 starting HP. At 6 HP or less, phase II begins immediately and never reverses. Every action upgrades. Newly armed Brands use the new shape; already marked cells do not expand. Furnace Roar replaces the next unresolved boss die once, then replaces Brace on Die I in later rolls.

### Advance

Pursue the standing hero with the highest current HP, up to 2 cells; highest-HP ties are random. If already adjacent to ANY tied highest-HP hero, stay and gain 1 Block. Cannot path to the chosen hero: gain 1 Block. HALF-HP UPGRADE: Movement +1; adjacent Block +1.

### Ashen Chain

Pull the closest standing hero within 3 up to 1 legal cells closer; strip 1 Block. Phase I: no Rooted. At half HP this upgrades to Rooted until the next boss turn. HALF-HP UPGRADE: Also applies Rooted 1 until next boss turn.

### Smoking Strike

Attack the closest standing hero within 1 for 1 damage (distance ties: lowest Block, then random). Only if HP is lost: put a fire tile under that hero. If a Smoking Strike fire tile is already there, consume it to deal 1 extra normal damage on that cell instead. Fire remains on its cell if the hero moves; stepping on it alone does not detonate it. HALF-HP UPGRADE: Fire detonation damage +1.

### Skirmish

Move 1 toward the closest hero, then attack within 1 for 1. Reactions happen before damage. HALF-HP UPGRADE: Movement +1.

### Sweep

Attack EVERY hero within 1 for 1 each, including Downed heroes. Each hero is hit once. HALF-HP UPGRADE: Reach +1 (still hits each hero once).

### Brace

Gain 1 Block. Damage consumes Block; any left expires at the boss’s next turn. HALF-HP UPGRADE: Block +1; Die I instead becomes Furnace Roar.

### Drive Back

Attack within 1 for 1, then automatically push 1 cells along the direction from the boss to the hero. No player direction choice. Collision: 1 unavoidable damage + Stunned; two equally aligned directions are resolved randomly. HALF-HP UPGRADE: Push distance +1.

### Distort

Target a highest-current-HP standing hero within 2. If no globally highest-HP hero is in reach, target the closest standing hero in reach. HP / distance ties are random. Inflict Weakness 1 until the next boss turn. With no reachable hero, use fallback. HALF-HP UPGRADE: Weakness +1.

### Fracture

Closest hero within 1 chooses 1 installed ability face(s) to become Blank for this fight. Earlier rolled results stay. HALF-HP UPGRADE: Reach +1; destruction count stays the same.

### Cinder Brand

Mark a cross beneath the closest hero within 3. At NEXT boss turn start, each hero on any marked cell takes 1 normal damage. Move away to evade. No stacking. Phase I uses a cross; Phase II uses a square. Already armed cells do not expand mid-countdown. HALF-HP UPGRADE: New warnings become 3×3 squares; already armed cells stay unchanged.

### Grave Tithe

Remove 1 Block from each standing hero within 2. Gain the stolen Block, capped at 2. No HP damage. HALF-HP UPGRADE: Steal +1 Block per hero; gain cap +1.

### Furnace Roar

Unlocked at 50% boss HP. Attack every standing hero within 2 for 1 damage, then push survivors up to 1 cells away. Reactions apply; occupied cells stop the push without collision damage. Replaces Brace on Die I for the rest of the fight. The first Roar replaces the next unresolved boss die. HALF-HP UPGRADE: Unlocks; reach +1 over its base test value.

### Boss dice, phase I

Die 1: Advance, Ashen Chain, Smoking Strike, Smoking Strike, Brace, Drive Back | Die 2: Skirmish, Cinder Brand, Smoking Strike, Sweep, Grave Tithe, Distort | Die 3: Advance, Skirmish, Cinder Brand, Sweep, Drive Back, Fracture

### Fallback and targeting

A result without a valid target can use fallback: if already adjacent to a hero, hold position and gain 0 idle Block in Tuned; otherwise move 1 toward a hero, or gain 1 Block if movement fails. Tuned gives no extra idle Block just for already being adjacent. Advance has its own highest-HP/adjacent-Block rule. Read each action’s target priority; they do not all choose the same hero.

## 15. Nu’gh, Worm Summoner

10 starting HP. At 5 HP or less, Brood Frenzy begins immediately and never reverses, even if Nu’gh heals. Living worms raise his attack damage: cap +1 in phase I, +2 in phase II.

### The brood and Soul Link

Start with two 1-HP worms, up to four living at once. They occupy one cell, block movement/sight and have no separate attack turn. Hero kills deal 1 unavoidable Soul Link damage to Nu’gh. His own consumption of a worm does not trigger Soul Link. Corpses free their cells. Summons use free legal cells within 2 of Nu’gh, preferring the front/bottom side; upgraded Burrow summons near his old location. Crowding or the cap can prevent a summon.

### Why clear worms?

They increase attack pressure and feed Nu’gh’s defensive and healing actions. Killing them both reduces future pressure and damages Nu’gh. Their deaths are not required for victory: killing Nu’gh ends the fight and removes the brood.

### Birth Cry

Summon 1 screaming worm(s), up to 4 living. Each has 1 HP and occupies a cell.

Current worm bonus: +1. Kill worms to lower it. HALF-HP UPGRADE: Summon +1 worm(s).

### Screaming Chorus

Attack the closest standing hero within 4 for 1 base + 1 worm pressure damage. Screaming Chorus spends one worm when empowered.

Current worm bonus: +1. Kill worms to lower it. HALF-HP UPGRADE: Maximum worm bonus damage +1.

### Gnashing Maw

Attack the closest standing hero within 1 for 1 base + 1 worm pressure damage.

Current worm bonus: +1. Kill worms to lower it. HALF-HP UPGRADE: Reach +1; also uses the stronger worm pressure.

### Burrow

Move up to 2 toward the closest hero. No route: gain 1 Block. HALF-HP UPGRADE: Also summon 1 worm(s) near the old location.

### Brood Guard

Gain 1 Block + one per living worm, worm bonus capped at 1. HALF-HP UPGRADE: Shield one worm with 1 non-stacking Block.

### Devour Brood

Consume the nearest worm and heal 1 HP. No worms: summon 1 instead. HALF-HP UPGRADE: Healing +1 and gain 1 Block.

### Boss dice, phase I

Die 1: Birth Cry, Birth Cry, Burrow, Gnashing Maw, Brood Guard, Devour Brood | Die 2: Birth Cry, Screaming Chorus, Screaming Chorus, Gnashing Maw, Burrow, Brood Guard | Die 3: Screaming Chorus, Gnashing Maw, Birth Cry, Brood Guard, Burrow, Devour Brood

### No target for Maw or Chorus

Move up to 2 toward a hero instead; if movement fails, gain 1 Block. An empowered Chorus spends a worm before damage, but its declared damage retains that worm bonus during the Reaction window. Future pressure can therefore be lower than the already declared hit.

## 16. Quick timing reference

Use this page during a fight; the preceding chapters explain each rule in full.

### Before the shared roll

Set aside a die for any still-Stunned hero. Then roll available dice together; hold Reactions, keep Channel dice held, trigger when-rolled effects.

### At your turn start

Resolve due costs and expiry, refresh Blank allowance, decide Maintain/End Channel. Ordinary old Block disappears; Stonewake can preserve it.

### Before your first action

Optional banked reroll. A charge does not refill automatically. Locked/spent/held results cannot be selected.

### During your turn

Resolve ready dice in any order; finish mandatory choices first. Focus can reroll another eligible ready die after actions but forces its result next.

### Before a boss Attack hits

Resolve eligible held Reactions. Recheck targets/range after movement or redirection. Then apply Block → reduction → HP.

### At the end of a full turn

Clear Downed protection; process any queued recovery turn. Hero turn end also clears Stunned/turn boosts and checks Black Oath. Boss turn end clears its Ward Weakness.

### At the next boss turn start

Rooted and Distort expire, Brand detonates, then old boss Block clears. Resolve new boss dice in order.

### At the next round

Reset temporary initiative delay, expire old Reactions and Mark Prey, and roll available dice together. This is not a new Blank-conversion allowance unless it is also that hero’s own turn.

### At half boss HP

Upgrade immediately once, using current maximum HP and the threshold. Healing does not return the boss to phase I. Open the phase guide for each upgraded action.
