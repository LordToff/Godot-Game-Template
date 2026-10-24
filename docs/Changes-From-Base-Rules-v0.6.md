# Ash & Oath
Changes from the base rules

Current prototype: v0.6 • Prepared 24 October 2026

Compared with Dice_Building_Boss_Battler_Master_Rules2.docx (Master Rules v10, 22 October 2026) and Action_Faces1.docx. This is a comparison of the playable implementation, not a replacement rulebook or a claim that every unresolved interpretation has been approved.

## How to use this document

Headings appear in Word’s Navigation Pane (View → Navigation Pane). Sections 1–3 give the short rule changes; section 4 audits every extended face; sections 5–8 cover limitations, corrections, interface work and version history. Matching Markdown is supplied for easy review and searching.

- 1. Main changes at a glance

- 2. First reward Soul: final wording

- 3. Boss changes and automation

- 4. Face-by-face interpretations and additions

- 5. Systems simplified, deferred or not implemented

- 6. Corrections that preserve intended rules

- 7. Interface and testing additions

- 8. Version history and test evidence

Labels: REQUESTED = a later user request changed the design; INTERPRETATION = a playable choice among ambiguous or conflicting drafts; LIMITATION = functionality not fully represented; FIX = an implementation correction; PRESENTATION = no intended rule change. Earlier historical answers inside the source documents are read in light of their later consolidated rules, not treated as new instructions.

## 1. Main changes at a glance

| Topic / status | Written baseline | Current v0.6 and reason |

| --- | --- | --- |

| Blank minimum — REQUESTED | Starting and first reward Souls require at least 3 Blanks on every Action Die; up to 9 non-Blank faces total. | Both Souls now require at least 2 Blanks per die: up to 4 abilities per die / 12 total. Reduces empty turns. Category and ownership limits still apply. |

| Starter build — INTERPRETATION / REQUESTED | 13-copy starter pool; players choose the actual 9-or-fewer equipped tiles. No fixed arrangement mandated. | Default equips 12: 4 Strike, 2 Step, 1 Stride, 2 Guard, 1 Reaction, 1 Focus, 1 First Aid. Shove remains owned but unequipped by default. Each die has 2 Blanks. A legal build remains editable. |

| Bonus ownership — REQUESTED | Extended designs are not automatically owned; the tutorial uses the starter pool. | Each hero chooses 2 distinct bonus designs freely from 47 extended faces, excluding the 8 starters and generated/penalty tiles. No random offers in the current version. An auto-build fits both while retaining First Aid. |

| Starting reroll — REQUESTED | Separate cap-1 Action, Numerical, Boss/Enemy and Mega banks; capacity does not grant a charge. | Each hero starts each encounter with 1 Action Reroll, cap 1. It is not a per-round refill. Focus remains a separate exception; Clairvoyance can replenish. Other reroll banks are not implemented. |

| Basic Strike — REQUESTED balance | Basic Strike deals a printed 1 damage. Boss Strike separately deals 2. | Tuned hero Strike deals 2; Original encounter mode uses 1. Boss Strike is still 2. This strengthens the starter attack without changing its adjacent-unit target rule. |

| Numeric Attack tuning — balance | Numeric baseline is 1,1,1,1,Blank,Blank; use the result as the base of a marked effect. | Tuned positive Numeric Attack results gain +1 before face-specific bonuses. Zero receives no new bonus; Gambler x0 remains absolute. Short Shot is capped at 1. Healing/Block do not receive this tuning. Original mode omits it. |

| Boss HP — balance | 18 HP, one phase. | Tuned: 16 HP; Original encounter: 18 HP. Tuned was 12 in earlier versions; raised for the fuller hero dice. |

| Boss Brace — balance | Gain 2 Block. | Tuned Brace gives 1; Original gives 2. Existing Block expiry remains at the boss’s next turn start. |

| Idle fallback — balance | If unable to resolve, move 1 closer; if unable to close, gain 1 Block. | In Tuned mode, when already adjacent and unable to close further, hold position without free Block. Original fallback remains available in Original mode. |

| Boss faces — REQUESTED | Three fixed dice listed in Action Faces. | Tuned replaces selected faces with Ashen Chain, Cinder Brand and Grave Tithe. Original retains the written dice. Section 3 gives exact lists and effects. |

| First reward Soul — REQUESTED v0.6 | 6 HP, 3 Blanks minimum, each eligible rolled Action Blank may be resolved as Move 2; no once-per-turn cap. | 6 HP, 2 Blanks minimum, at most ONE rolled Blank per hero turn can be spent as Move 2. See section 2. Starting Soul still grants no Blank movement. |

| Player control — LIMITATION / INTERPRETATION | Exactly 3 players, one hero per player. | Local hotseat: one person can operate all 3 heroes. Separate hero turns and initiative remain; there is no network multiplayer. |

| Deployment / facing — INTERPRETATION | Exact deployment deferred; facing and the 2×2 rear-space definition unresolved. | Boss starts D4 (2×2); heroes H3/H5/H7. Boss always faces north for relevant abilities; either southern-edge-adjacent cell counts as rear. No turning system. |

| Boss route choice — INTERPRETATION | Players choose among shortest legal movement routes; target ties follow printed/random rules. | Boss path selection is automated and deterministic for equal shortest routes. Legal target ties are randomized. This removes the manual route choice. |

| Recovery order — LIMITATION | Players choose the order of multiple waiting full recovery turns. | Full recovery timing is implemented, but the queue is first-in-first-out rather than a selectable player order. |

| Channels — LIMITATION | Each eligible die may maintain its Channel, with choices at its owner’s turn start. | The model stores one active Channel per hero; multiple simultaneous Channels are not fully supported. Face-specific timing interpretations are listed below. |

| Reference modes — PRESENTATION | A written tutorial and face reference. | Added Ability Lab, live dice inspection, turn guide, searchable bonus choice, side chronicle and topic-based patch notes. Lab overrides are isolated testing tools, not legal normal-game actions. |

“Original rulebook” in the game is an encounter-balance preset, not a complete faithful implementation of every source rule. It retains original boss HP/dice, hero Strike 1, Brace 2 and old fallback, but still uses the later two-Blank construction rule, two bonus choices, starting Action Reroll and prototype face interpretations.

## 2. First reward Soul: final wording

First boss reward Soul — 6 maximum HP. Each Action Die must contain at least two Blank sides when legally built. Once per hero turn, during ordinary face resolution, you may resolve one rolled Action Die Blank as Movement: Move up to 2 orthogonal spaces, turning allowed. Spend that rolled result. The installed side remains Blank.

- The limit belongs to each hero independently, not to the whole party.

- A normal own turn refreshes the allowance. A full recovery turn is also a new turn and refreshes it.

- A failed/illegal destination does not consume the allowance or the die. Successfully moving does.

- Other rolled Blanks may be spent without effect or left unused. Declining a Blank does not consume the allowance.

- Action rerolls, Focus, a shared roll or a forced face change do not refill an already-used allowance during the same turn.

- Numeric Blanks remain zero-value results; this Soul applies only to rolled Action Dice Blanks.

- This is temporary resolution of a Blank as Movement, not permanent installation of a Movement face. It does not consume a separate equipped Movement tile.

- The starting Soul still has no Blank effect. The reward is available through a fresh rematch after victory; there is no implemented campaign Soul inventory.

Reason: the reward should help a hero reposition once without making several Blank results substitute for dedicated movement faces. General affliction interactions such as Slow remain outside the implemented prototype, as listed in section 5.

## 3. Boss changes and automation

| Die | Written / Original encounter | Current Tuned encounter |

| --- | --- | --- |

| I | Advance, Advance, Strike, Strike, Brace, Drive Back | Advance, Ashen Chain, Strike, Strike, Brace, Drive Back |

| II | Advance, Skirmish, Strike, Sweep, Brace, Distort | Skirmish, Cinder Brand, Strike, Sweep, Grave Tithe, Distort |

| III | Advance, Skirmish, Strike, Sweep, Drive Back, Fracture | Advance, Skirmish, Cinder Brand, Sweep, Drive Back, Fracture |

### Ashen Chain — new control action

Choose the closest standing hero within 3. Pull it 1 legal cell closer and remove up to 1 Block. No HP damage; occupied cells stop the pull, with no added collision penalty. If no target is available, use fallback. This is an explicit new face rule, not a replacement for general forced-movement collision rules.

### Cinder Brand — new delayed hazard

Choose the closest standing hero within 3 and mark its cell plus four orthogonal neighbors inside the arena. No immediate damage. At the START of the next boss turn, before ordinary boss dice, each non-dead hero on any marked cell takes 1 normal, blockable damage, once. This can affect a Downed hero under the ordinary protection/death rules. The hazard then clears. Existing marks cannot be stacked or replaced by another Brand before detonation.

### Grave Tithe — new defense pressure

Remove up to 1 Block from each standing hero within 2. Give the boss the total removed, capped at 2. No HP damage. Heroes outside range are unaffected.

### Unchanged boss faces

Advance, Skirmish, Strike, Sweep, Drive Back, Distort and Fracture retain their main effects and target rules; Brace and the adjacent idle fallback differ only in Tuned mode. Boss I → II → III order, legal retargeting and reaction pauses remain. Boss movement routes are automated, as noted above.

## 4. Face-by-face interpretations and additions

Every extended face available in the prototype is included below, along with generated tiles and both new movement abilities. “Current effect” is taken from the playable catalog; the global Tuned +1 positive Numeric Attack rule additionally applies to IDs 34–41. Names such as Guard Numeric and Focus Numeric distinguish source naming conflicts; they do not merge the starter and Numeric versions.

### 4.1 Starter faces

| Source name | Prototype name / behavior |

| --- | --- |

| Basic Strike | Strike: adjacent unit; printed 2 in Tuned, 1 in Original. Allies remain legal targets. |

| Basic Movement | Step: up to 1 orthogonal space; no intended rule change. |

| Tactical Movement | Stride: up to 3 in one straight orthogonal direction; no intended rule change. |

| Basic Defense | Guard: +1 Block; no intended rule change. |

| Tactical Defense | Reaction: held when rolled, +1 Block and optional Step 1 when targeted; no intended rule change. |

| Focus | Focus: reroll another unresolved Action Die during resolution; no intended rule change. |

| First Aid | First Aid: heal self/adjacent hero for 1, including Downed; no intended rule change. |

| Shove | Shove: adjacent directly-away push of 1, full boss footprint, no collision penalty. Equally valid directions are offered as legal choices. |

### 4.2 Gambler's Coin  [ID 9; Skill]

Source: choose an opposite Numeric pair for x0/x2; repeat roll blanks the face and grants Gold.

Current effect: Arm Numeric with x0 and x2. Roll again to gain 1 Gold and blank this face for the fight.

INTERPRETATION / LIMITATION: fixed software overlay rather than selecting physical opposite sides. The x2 branch doubles a sampled ordinary value (four successful outcomes out of five); it is not a complete customizable-die overlay simulation. Both arming and the later Gold/blanking result are player-resolved rather than a complete mandatory when-rolled transformation. Coin is non-rerollable; Gold has no spending economy. General Crit is not implemented.

### 4.3 Weak Point  [ID 10; Skill]

Source: conflicting personal Catalog marker and shared Tabletop boss mark; different durations/rechecks.

Current effect: Gain a personal backstab marker through next round. Your next adjacent Attack from below the north-facing boss repeats once.

INTERPRETATION / LIMITATION: personal marker through the following round, north-facing southern-edge rear condition, next rear Attack repeats once. Numeric repeats reuse the computed attack value rather than rerolling a fresh Numeric Die for every hit; repeated movement is not a general framework.

### 4.4 Conjure  [ID 11; Skill]

Source: visible immediate hero-face copy; Catalog resolves, Tabletop triggers when rolled; illegal copying damages/Blanks Conjure.

Current effect: Copy another visible immediate hero face. Select its hero and die; resolve the copy now. No setup/copy loops.

INTERPRETATION / LIMITATION: resolution-time picker with a fixed immediate-face whitelist; no setup/copy loops. It forces the copied result next. The source’s illegal-copy self-damage and blanking penalty are not implemented; invalid targets may be corrected or the result declined.

### 4.5 Blessing of Recovery  [ID 12; Skill]

Source: Catalog Recovery injection versus Tabletop negative-face cleansing. Recovery range is unspecified.

Current effect: Choose a hero and a specific Blank slot: install Recovery there. Recovery heals Numeric at range 1. After two placements this face becomes Blank.

INTERPRETATION: uses injection, explicit hero and Blank-slot selection, Recovery Numeric healing at self/adjacent range, two placements then source blanks. Cleansing variant is not implemented. With no destination Blank, selection is rejected rather than automatically spent.

### 4.6 Clairvoyance  [ID 13; Skill]

Source: conflicting self/Numeric/boss reroll tiles, placement rules and two/three-use corruption thresholds.

Current effect: Prototype: when rolled, gain 1 Action Reroll (cap 1). The bank begins with 1, so save this for replenishment.

INTERPRETATION / LIMITATION: when rolled, replenish the Action Reroll bank to cap 1. No tile placement, boss reroll bank or placement-corruption sequence.

### 4.7 Forgotten Strength  [ID 14; Skill]

Source: party-wide Catalog buff plus backlash versus caster-only Tabletop next damage.

Current effect: Tabletop variant: your next Numeric damage this turn gets +1. No party-wide buff or backlash.

INTERPRETATION: caster-only +1 to next Numeric damage this turn; resolved as an action rather than Tabletop’s when-rolled timing. No party-wide effect or backlash.

### 4.8 Passing Grace  [ID 15; Skill]

Source: heal/pass variants disagree about sight, recipient and no-Blank handling. Catalog heals even if the tile is lost.

Current effect: Heal another hero within 3 for Numeric, then pass this face to a Blank on that hero. No self-target; the source becomes Blank.

INTERPRETATION / DELIBERATE PROTOTYPE CHANGE: another hero within 3 and clear sight; heal and pass to that same hero’s first available Blank, source blanks. A recipient with no Blank is rejected without spending the source. This intentionally differs from heal-then-lose-the-tile wording.

### 4.9 Borrow Shape  [ID 16; Skill]

Source: Catalog swaps borrowed faces between heroes; Tabletop rotates a just-rolled die.

Current effect: Tabletop variant: rotate another unresolved die to one of its installed non-penalty faces and immediately resolve that result.

INTERPRETATION: uses rotate-another-unresolved-die version during resolution, including automatic handling of a newly selected reaction. No borrowed tile exchange or return at encounter end.

### 4.10 Numeric Echo  [ID 17; Skill]

Source: Catalog stores an ordinary Numeric result; Tabletop grants temporary roll-twice advantage.

Current effect: Roll and store one ordinary Numeric value. It replaces your next Numeric roll. A second stored value is not allowed.

INTERPRETATION: store a single ordinary 0/1 value, ignoring Gambler overlays, and substitute it for the next Numeric roll. Another use while full supplies no new stored value. Advantage version is not implemented.

### 4.11 Lethargic Bind  [ID 18; Skill]

Source: when-rolled suppression of a chosen boss die/face, with 1 blockable backlash per matching roll until next turn.

Current effect: Choose a boss die and face. Until your next turn, that face rolls as Bound (no action); you suffer 1 normal damage each time it triggers.

INTERPRETATION / LIMITATION: selected during face resolution, tracked as Bound until the binder’s next turn. Uses the current encounter’s boss faces; no general boss-reroll system.

### 4.12 Restore  [ID 19; Skill]

Source: ally within 3, Numeric healing minimum 1; sight wording unresolved and Gambler x0 absolute.

Current effect: Heal another hero within 3 for Numeric, minimum 1. Cannot target yourself. Gambler x0 stays zero.

INTERPRETATION: requires clear sight, never self-targets, respects the ordinary floor but preserves absolute Gambler zero.

### 4.13 Focus Numeric  [ID 20; Skill]

Source: next Numeric Blank this turn becomes 1; Gambler interaction was open.

Current effect: Your next Numeric roll this turn treats Blank as 1, then this benefit ends.

INTERPRETATION: next Numeric roll treats ordinary Blank as 1 and consumes the benefit; Gambler x0 stays zero. Source Focus Numeric is kept distinct from starter Focus.

### 4.14 Mark Prey  [ID 21; Skill]

Source: mark visible enemy; range and precise impact/added-damage wording unresolved.

Current effect: Mark the boss until round end. The next damaging Attack when it has zero Block adds 1 damage, then removes the mark.

INTERPRETATION: boss-only round-duration mark with no explicit range or sight check; consumed by the next damaging Attack when boss Block is zero, then adds 1 normal damage. No multiple-enemy mark target selector.

### 4.15 Last Word  [ID 22; Skill]

Source: 1 unavoidable finisher after other non-Blank results; range unspecified.

Current effect: After all your other non-Blank dice resolve, deal 1 unavoidable damage to the boss. Prototype range: visible anywhere.

INTERPRETATION: boss target anywhere in this open arena without an explicit sight check; spent/declined non-Blank results satisfy the prerequisite. Not treated as an Attack.

### 4.16 Second Chance  [ID 23; Skill]

Source: skip an unresolved non-Blank, repeat a resolved face; eligibility/bookkeeping unfinished.

Current effect: Skip another unresolved non-Blank die, then repeat one already spent immediate face. Copy/repeat faces cannot chain into themselves.

INTERPRETATION: explicit two-stage choice; skipped die cannot count as a previously resolved source. Repeat eligibility is a fixed immediate-face whitelist; copy/setup chains excluded.

### 4.17 Spiral Instability  [ID 24; Skill]

Source: reroll until Attack, resolve twice at random valid units; cannot use if no Attack.

Current effect: Roll this die until an Attack appears, then resolve it twice at random legal adjacent units, including allies. No Attack on this die: no effect.

INTERPRETATION / LIMITATION: samples an installed Attack directly, with a random target per repetition, including allies. With no installed Attack the result may be spent without effect. No complete locked/non-rerollable rejection-sampling framework.

### 4.18 Contained Power  [ID 25; Skill]

Source: Channel converts future Blank/non-Blank rolls to Block/Numeric power; break/backlash and Red Tile permanence unfinished.

Current effect: Channel: each future Blank grants 1 Block and each non-Blank adds Numeric +1 for that turn, capped +2. HP damage breaks it, deals 2 more and leaves a Red Tile.

INTERPRETATION: automatic future-roll Block/power, boost capped +2 per turn, HP loss breaks Channel, adds 2 damage and leaves a fight-long Red Tile. No general permanent corruption/progression model. Downed cleanup clears Channel before the later break rider, so lethal break aftermath is not fully implemented.

### 4.19 Corruption Conversion  [ID 26; Skill]

Source: rolled Blank becomes another installed face; trigger and permanent removal window undefined.

Current effect: Prototype on resolution: choose an unresolved Blank die, then choose an installed ability on it and resolve that face. This face becomes a locked Red Tile for the fight.

INTERPRETATION: actively resolve Conversion, pick an unresolved Blank die and then its installed eligible replacement result. Forces that result next; stores reactions correctly and runs when-rolled handling. Source becomes a locked Red Tile only for this encounter, not a permanent inventory loss.

### 4.20 Blood Bargain  [ID 27; Skill]

Source: choose +1 on next two attacks OR all-Block bypass on next attack, then 1 unavoidable backlash.

Current effect: Empower the next two Attacks against the boss by +1 damage. After the second, take 1 unavoidable damage.

INTERPRETATION / LIMITATION: only the two-attacks +1 option, boss-only, with backlash after the second empowered attack. No bypass-option selector; remains pending until used or encounter ends.

### 4.21 Target Override  [ID 28; Skill]

Source: Reaction to enemy Attack or Ability target, forcing another legal target.

Current effect: Reaction when personally targeted: force a different legal adjacent hero to be targeted. With no alternative the original target remains.

LIMITATION: triggers on personally targeted boss Attacks; chooses another legal adjacent hero automatically. Non-Attack enemy ability targeting is not covered. With no alternative, original target remains.

### 4.22 Debt  [ID 29; Skill]

Source: +2 next Attack/Defense this turn, −2 next turn; unpaid penalty persistence unresolved.

Current effect: Your next Attack or Defense this turn gets +2 value. At your next turn, the first such face gets −2 value (minimum 0).

INTERPRETATION: positive benefit expires at own turn end; negative penalty persists until an eligible face pays it, minimum zero. Effects operate through the prototype’s value-modifier path.

### 4.23 Ill Omen  [ID 30; Skill]

Source: when rolled, choose another Attack/Defense; d6 modifies value/Pierce/Echo. Defense Pierce conversion undefined.

Current effect: Prototype resolution choice: modify another unresolved Attack/Defense. d6: 1 gives −1, 2–4 gives +1, 5 gives Pierce 2 (Defense +2 Block), 6 repeats an Attack or doubles Defense Block.

INTERPRETATION: a resolution-time choice. Defense Pierce 2 becomes +2 Block; Defense Echo doubles Block. Attack repeats are finite but reuse the calculated attack value rather than the full separate-resolution framework.

### 4.24 Stonewake  [ID 31; Skill]

Source: gain 2 Block and optional Channel; old round-end persistence conflicts with current turn-start Block expiry.

Current effect: Prototype Channel: gain 2 Block. While maintained, explicitly preserve existing Block at turn start and add 1 (cap 8). End to reroll the die.

INTERPRETATION: explicit maintained Channel preserves existing Block at own turn start, adds 1, cap 8. Ending releases/rerolls the die. This supplies a new persistence timing, rather than claiming the unresolved source already approved it.

### 4.25 Oath of Smoke  [ID 32; Skill]

Source: store a resolved Movement/Defense until next round before own turn; expiry/value/Numeric behavior unfinished.

Current effect: Prototype: resolve another rolled Step, Stride or Guard now; store it as a Reaction until the next shared roll. Movement reaction steps 1; Defense grants 1 Block.

INTERPRETATION / LIMITATION: only Step, Stride or basic Guard can be stored. Reaction lasts until next shared roll, not a guaranteed next-round window; movement reaction steps 1, defense grants 1 Block. No stored Numeric defense or full original movement repeat.

### 4.26 Bone Mutation  [ID 33; Skill]

Source: unnamed Bone mutation candidate; Bone category and no-Blank behavior unresolved.

Current effect: Choose a Blank on one of your dice and replace it with Bone for this fight. Bone grants 1 Block, then optionally steps 1.

INTERPRETATION: named Bone Mutation; exact Blank-slot selection on own dice, generated Bone classified Skill. Bone grants Block and optional Step 1, including a stay-only resolution. No Blank means action is rejected.

### 4.27 Strike Numeric  [ID 34; Attack]

Source: Numeric Strike, enemy versus generic target versions; normal Crit/Gambler modifiers.

Current effect: Adjacent unit: roll Numeric and deal that much damage.

INTERPRETATION: adjacent unit, including allies; Tuned positive Numeric +1 applies. No general Crit status/system.

### 4.28 Short Shot  [ID 35; Attack]

Source: Catalog caps at 1; Tabletop does not.

Current effect: Target a visible unit within 2. Numeric damage capped at 1 per resolution. Units block sight; no diagonal corner shooting.

INTERPRETATION: uses capped Catalog version, range 2, straight sight blocked by units and diagonal corners. Cap enforced after damage buffs. Tuned boost cannot raise final damage above 1.

### 4.29 Hooked Slash  [ID 36; Attack]

Source: Catalog grants Block after ≥2 damage; Tabletop pulls; Catalog Block expires round end.

Current effect: Catalog variant: adjacent Numeric Attack. If at least 2 HP damage is dealt, gain that much Block.

INTERPRETATION / DEVIATION: uses the HP-loss-based Block rider, not pull; gained Block follows ordinary next-own-turn expiry rather than the Catalog’s special round-end duration. Tuned Numeric boost makes its threshold easier to meet.

### 4.30 Piercing Thrust  [ID 37; Attack]

Source: adjacent enemy Numeric attack bypassing 1 Block without destroying it.

Current effect: Adjacent Numeric Attack. Bypass 1 Block without destroying the bypassed portion.

INTERPRETATION / DEVIATION: prototype permits adjacent unit targets, including allies. Bypassed Block is restored after calculation; Tuned Numeric boost applies.

### 4.31 Cleave  [ID 38; Attack]

Source: adjacent enemy hit and 1 secondary damage to another adjacent enemy; secondary mechanics unfinished.

Current effect: Adjacent Numeric Attack. A second enemy adjacent to that target takes 1. This encounter has only one enemy.

LIMITATION: single-boss encounter provides no secondary enemy, so only primary attack is observable. No minion/secondary-target implementation; prototype primary unit targeting can include allies.

### 4.32 Flanking Blow  [ID 39; Attack]

Source: behind bonus; complete range/target and large-unit rear space unfinished.

Current effect: Prototype: adjacent Numeric Attack; add 1 when standing below the north-facing boss. Rear means its southern edge.

INTERPRETATION: adjacent Numeric attack, +1 on boss from its southern edge under fixed north facing. No dynamic turning or single-space rear restriction. Tuned positive Numeric boost applies separately.

### 4.33 Break Rhythm  [ID 40; Attack]

Source: break all Block and cause HP loss, delay next turn one initiative step; edge cases open.

Current effect: Adjacent Numeric Attack. If you break existing Block and deal HP damage, delay an upcoming boss activation one initiative slot when possible.

INTERPRETATION / LIMITATION: requires existing Block >0. Can move a still-upcoming boss slot back one slot only when a later slot exists. The changed order array persists; not a complete one-use future-activation delay/status system.

### 4.34 Engrave  [ID 41; Attack]

Source: add Engrave to Blank or overwrite non-Engrave; target/range/overwrite selection unfinished.

Current effect: Prototype adjacent Numeric Attack. After damage, copy Engrave into a Blank on this die (otherwise overwrite an unlocked non-Engrave). 3 copies: +1; 6 copies: +2.

INTERPRETATION: adjacent Numeric unit attack; after resolving, fills first Blank on that die, otherwise first unlocked non-Engrave. No manual overwrite choice. 3/6-copy bonuses apply; Red Tiles protected. Combat changes may exceed normal construction limits.

### 4.35 Guard Numeric  [ID 42; Defense]

Source: Numeric Guard, distinct from starter printed +1 Defense.

Current effect: Gain Block equal to a Numeric roll.

IMPLEMENTATION: Numeric Block with supported buffs/debuffs. Renamed Guard Numeric for clarity; no Tuned Numeric Attack bonus on Block.

### 4.36 Brace Hero  [ID 43; Defense]

Source: zero Block gives 3, otherwise 1.

Current effect: If at zero Block, gain 3; otherwise gain 1.

IMPLEMENTATION: printed-value hero Brace, distinct from boss Brace. Supported value modifiers apply; no intended base change.

### 4.37 Shield Wall  [ID 44; Defense]

Source: ally within 2 and sight attacked; give both 1 Block before attack.

Current effect: Reaction when an ally within 2 is attacked: give both that hero and yourself 1 Block before the hit.

IMPLEMENTATION: stored reaction to boss Attack, both heroes receive 1 Block. No general multi-enemy targeting framework.

### 4.38 Taunt  [ID 45; Defense]

Source: become a monster’s attack target only if legal.

Current effect: Reaction when another hero is attacked: become the target if adjacent to the boss. You must be a legal target.

INTERPRETATION: only when another hero is targeted; user must be adjacent to boss. Does not redirect Sweep’s multi-target area. Applies to implemented boss Attacks, not a generic enemy system.

### 4.39 Defy Death  [ID 46; Defense]

Source: prevent lethal Attack, stay 1, Stunned, blank face; Broken/non-attack interactions open.

Current effect: Reaction before a lethal Attack: stay at 1 HP instead, gain Stunned, then blank this face. Prototype sets aside your first available result.

INTERPRETATION / LIMITATION: avoids reaching zero from that Attack, including a Broken hero; sets aside first available die for Stunned rather than opening the ordinary player die picker. No prevention for arbitrary non-Attack damage sources.

### 4.40 Bulwark  [ID 47; Defense]

Source: DR1 and Attack-only Weakness1 until next turn, unavoidable bypasses DR.

Current effect: Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction.

IMPLEMENTATION: supported base stance; no intended rule change. Weakness reduces Attacks, not healing/Block.

### 4.41 Echo of Pain  [ID 48; Defense]

Source: during monster turn, damage enemy for actual damage this round, cap3, blank; unused costs 1 next turn.

Current effect: Reaction during a boss Attack: deal your actual HP damage taken this round to the boss (cap 3), then blank this face. If unused, take 1 unavoidable damage at next turn start.

INTERPRETATION: reaction window is any boss Attack. Boss-only retaliation uses actual HP damage taken this round, capped3; not blocked damage. No arbitrary monster-ability/turn window selector.

### 4.42 Last Pulse  [ID 49; Defense]

Source: maintained Channel heals 1 if no damage passed Block; damage breaks and blanks.

Current effect: Channel: at each maintained turn start, heal 1 if no HP damage got through. HP damage breaks this Channel and blanks it.

IMPLEMENTATION / LIMITATION: own-start maintain/release and actual HP-loss break implemented within single-Channel-per-hero model. Downed cleanup can precede the face-blanking rider, so lethal break aftermath is incomplete.

### 4.43 Black Oath  [ID 50; Defense]

Source: Numeric+1 Block; lose 1 HP if Block remains at ambiguous “battle turn” end.

Current effect: Gain Numeric +1 Block. Prototype timing: at your turn end, lose 1 HP if Block remains.

INTERPRETATION: owner’s turn end. Cost is routed as unavoidable damage, bypassing Block/DR, rather than a separate fully general direct-HP-loss event system.

### 4.44 Wither Ward  [ID 51; Defense]

Source: Numeric Block and ambiguous unblocked-damage / Weakened rider.

Current effect: Prototype: gain Numeric Block. Until your next turn, an adjacent attacker causing HP loss receives Weakness 1 until its turn ends.

INTERPRETATION: ward lasts to next own turn; when an adjacent boss causes actual HP loss, it receives Weakness1 until its boss turn ends. Replaces undefined Weakened with Weakness; no broad enemy-status system.

### 4.45 Ember Burst  [ID 52; Defense]

Source: Numeric Block, burn up to2 for undefined white damage to all adjacent units.

Current effect: Prototype: gain Numeric Block, then burn up to 2 Block; each deals normal damage to every adjacent unit, including allies. Choose how much to burn.

INTERPRETATION: player chooses 0–2 from available Block (not tracked specifically as newly gained Block), normal blockable damage including allies, one hit per unit. Whole area resolves before outcome checking. No separate white-damage keyword.

### 4.46 Leap of Echoes  [ID 53; Movement]

Source: Catalog projection/return teleport versus Tabletop two-space leap and damage buff.

Current effect: Tabletop variant: leap up to 2 orthogonally over units, never land occupied. If ending adjacent to the boss, your next Numeric damage this turn gets +1.

INTERPRETATION: Tabletop leap up to2 orthogonally (Manhattan range), may cross units but not land occupied; boss adjacency grants next Numeric damage +1 this turn. No projection origin, return teleport or displacement routine.

### 4.47 Bone  [ID 54; Skill]

Source: Bone tile described under unnamed mutation; classification unresolved.

Current effect: Gain 1 Block and optionally step 1.

INTERPRETATION: generated Skill, +1 Block then optional Step1; not part of the starting gift pool.

### 4.48 Recovery  [ID 55; Skill]

Source: generated Recovery uses Numeric healing, range unspecified.

Current effect: Heal yourself or an adjacent hero for Numeric.

INTERPRETATION: self or adjacent hero, Numeric healing; generated by Blessing, not a selectable starter gift.

### 4.49 Red Tile  [ID 56; Penalty]

Source: revised inert, non-Blank, non-rerollable penalty; permanence pending.

Current effect: Inert, non-rerollable, not a Blank, locked for this encounter.

INTERPRETATION: inert locked tile for current encounter; cannot normally mutate/reroll, does not count as Blank. No permanent curse/event cleansing or post-fight carryover.

### 4.50 Ashstep  [ID 57; Movement]

No matching face in supplied baseline.

Current effect: Slip through ash: move up to 2 orthogonal spaces, turning allowed, then gain 1 Block. Cannot pass through units.

NEW REQUESTED DESIGN: Ashstep. Normal orthogonal path up to2, can turn, +1 Block only after a legal move. Units block traversal. Added to gift pool and Lab; counts as Movement.

### 4.51 Oathbound Exchange  [ID 58; Movement]

No matching face in supplied baseline.

Current effect: Swap positions with a living standing ally within 3 and clear sight. Both heroes gain 1 Block. Cannot swap with the boss or a Downed hero.

NEW REQUESTED DESIGN: Oathbound Exchange. Swap with a standing living ally within3 and clear sight; both +1 Block. Cannot swap with boss/Downed/dead hero. Added to gift pool and Lab; counts as Movement.

## 5. Systems simplified, deferred or not implemented

These are omissions or prototype limits, not rules deleted from the designer’s game. An unexercised keyword is not silently assigned a new effect.

- Only a single open-arena boss encounter and fresh rematches exist. No campaign, between-boss Event Pool, E012/E013 content, persistent inventory, permanent injuries/curses, resurrection, save/load progression, layer acquisition or fourth-die milestone.

- No full selectable Memory/Soul/Body inventory. Starting Memory is empty, Broken Body limits are checked, and the reward Soul is a rematch option. Surviving/dead campaign state is not carried across fresh tests.

- Only Action Reroll is implemented as a stored bank. Numerical, Boss/Enemy and Mega banks and their permission windows are absent. Numeric Die face customization and general Crit/Echo statuses are absent.

- No general Poison, Burn, Slow, Haste, Fear, Dazed, Confused, Disoriented, Doom, Decay, Regeneration, Severed or full keyword engine. Weakness, Block, Stunned, Broken, selected face-specific marks/wards/reduction/Channels and Downed/death are implemented. This also limits the full source affliction interactions of Soul movement.

- Generic multi-category construction/combat classification is not implemented: the catalog assigns one prototype category to each offered face.

- Wandering Curse is not offered/implemented. Hamstring lacks a completed source range and is not a tutorial boss face. Heart/Vital Die remains archived as in the source. Gold is recorded, but there is no shop/economy.

- No extra enemies or minions, summons, boss facing turns, general projections or campaign hazard system. Cinder Brand is a new specific supported hazard. Cleave cannot demonstrate its secondary enemy effect.

- Multiple active Channels, player-chosen ordering of queued recoveries, full copy/repeat per-resolution Numeric/cost/movement semantics, and all automatic when-rolled timing variants are not fully represented.

- Ordinary UI buttons permit spending beneficial results without effect; mandatory-penalty handling is limited to implemented faces. Red Tiles are inert rather than a general negative-effect framework.

- General direct HP loss and unavoidable damage are not separate fully implemented event classes; several self-costs use the unavoidable-damage path. Actual HP loss still drives the supported Downed/death/retaliation counters.

## 6. Corrections that preserve intended rules

- Short Shot’s chosen Catalog cap is enforced after buffs, including Blood Bargain and Debt; a damage buff does not bypass the final cap.

- Gambler x0 remains absolute zero for supported Numeric damage, minimum-heal logic and Blood Bargain bonuses.

- Negative damage is clamped to zero so it cannot create healing or Block.

- Ember Burst area damage resolves as one batch before outcome checking; simultaneous whole-party defeat keeps loss priority.

- Debt’s unused positive benefit expires at turn end, while an unpaid penalty remains until an eligible face resolves.

- Blocked hits do not count as HP loss. Damage logs distinguish incoming, absorbed, reduction and actual HP loss. Pierce bypasses rather than destroys the ignored Block.

- Invalid Bone movement cannot grant free Block. Invalid Soul movement cannot spend or refill its allowance.

- Removing supporting faces clears stored reactions and Channels. Recorded rolled results can remain valid after an installed mutation, as the source requires.

- Line of sight uses a straight supercover grid ray; it cannot bend around a unit or pass through a blocked diagonal corner.

- Legal auto-builds are checked across all 1,081 distinct gift pairs, retaining First Aid. Bone/Recovery slot choice and Conversion’s chosen installed face are exposed explicitly.

- UI click audio is owned by the persistent template controller so scene restarts do not use a freed audio player.

## 7. Interface and testing additions

- Playable forge with searchable/filterable full-pool two-face selection per hero, descriptions, ownership validation and editable die-side assignments.

- Large side chronicle with causal action/result entries, round/event IDs, exact HP/Block changes, coordinates, statuses, full history filters and copy controls.

- Large active-turn banner, initiative display, active hero card border and board TURN arrow. Contextual turn help explains reroll windows, targets, spent/held dice, shared rolls and next action.

- Live View dice window for all 18 sides of any hero and all boss sides. Highlights current rolled sides and face changes relative to encounter start; lists original face and recorded result separately.

- Boss intent descriptions, staged manual I/II/III resolution, reaction/mutation/Channel/Fracture prompts, marked hazard cells and outcome history review.

- Ability Lab offers all 59 face IDs, prepared targets and support dice, optional next Numeric0/1, manual boss hits, next-round advancement, chosen-face rerolls, reset and reproducible copied logs. These overrides are explicitly outside ordinary battle rules and preserve normal loadouts.

- Restrained battlefield backdrop and unit art, dice-roll animation, eased movement, attacks, blue shields, green buffs/heals and purple debuffs. Animation never changes final dice outcomes.

- Topic-based short patch-note pages, Previous/Next, page counter, Escape and return controls. Template settings, audio controls, Scene Loader and music/UI sound plugins remain integrated.

- Windows/Linux/Web exports, versioned ZIP downloads, checksums, source/test documentation and this comparison. Windows is cross-exported; native Linux/browser behavior is tested.

## 8. Version history and test evidence

| Version | Main evolution |

| --- | --- |

| Initial prototype | Single local encounter, forge, shared rolls, initiative, starter effects, boss actions, reactions, Downed/death/recovery and reward rematch. |

| v0.2 | One starting Action Reroll, boss effect explanations, roll animation, Tuned/Original encounter options and early one-face starter offers. |

| v0.3 | Two distinct gifts chosen freely from full extended pool replaced random offers. Legal build preserves healing. Causal logs, battlefield art/effects and cap/timing fixes. |

| v0.4 | Large side log, clear turn indication, smoother movement, all-face Lab, exact mutation/conversion choices, sight/recipient fixes, positive Numeric Attack tuning and in-game reasons. |

| v0.5 | Two-Blank minimum and 12-face defaults, two new movement designs, live dice viewer, topic-based notes, turn guide and varied boss. Tuned HP became16. |

| v0.6 | First reward Soul conversion is capped at one Blank per hero turn, with correct normal/recovery-turn reset and UI feedback. Added this base-rules comparison. |

The larger recent starting-face-only test used 1,000 fresh seeds (101–1100), current Tuned boss16HP, no bonus faces and no reward Soul: 694 player wins / 306 losses / 0 stalls. A matched run using the older sparse three-Blank starter build against the SAME current boss gave 249 wins / 751 losses / 0 stalls. This tests the combined loadout change, not the Blank minimum in isolation.

Earlier v0.5 100-seed checks gave 74/26 for default starter builds and 81/19 across eight representative bonus-pair builds, with no stalls. Bots use a simple fixed greedy strategy; these are regression/tuning signals, not human win-rate predictions or proof that all builds are balanced. These no-reward tests do not measure the v0.6 reward-Soul cap.

Verification includes construction/rule tests, all gift-pair legality, face/Lab execution, boss mechanics, graphical UI input, turn guidance and the v0.6 per-hero Soul cap including recovery-turn reset. The source test scripts are retained with the project. Any discrepancy between a printed draft and a behavior listed as LIMITATION should be reviewed before using this prototype as an authoritative rules implementation.
