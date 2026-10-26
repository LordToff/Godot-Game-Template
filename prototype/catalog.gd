class_name AshCatalog
extends RefCounted
# Playable catalog variants. Draft ambiguities are resolved here for this prototype,
# and printed on the offer card rather than silently altering the source document.
const EXTRA = [
 ["Gambler's Coin","Skill","Arm Numeric with x0 and x2. Roll again to gain 1 Gold and blank this face for the fight."],
 ["Weak Point","Skill","Gain a personal backstab marker through next round. Your next adjacent Attack from below the north-facing boss repeats once, with fresh Numeric rolls for each resolution."],
 ["Conjure","Skill","Copy another visible immediate hero face. Select its hero and die; resolve the copy now. No setup/copy loops."],
 ["Blessing of Recovery","Skill","Choose a hero and a specific Blank slot: install Recovery there. Recovery heals Numeric at range 1. After two placements this face becomes Blank."],
 ["Clairvoyance","Skill","Prototype: when rolled, gain 1 Action Reroll (cap 1). The bank begins with 1, so save this for replenishment."],
 ["Forgotten Strength","Skill","Tabletop variant: your next Numeric damage this turn gets +1. No party-wide buff or backlash."],
 ["Passing Grace","Skill","Heal another hero within 3 for Numeric, then pass this face to a Blank on that hero. No self-target; the source becomes Blank."],
 ["Borrow Shape","Skill","Tabletop variant: rotate another unresolved die to one of its installed non-penalty faces and immediately resolve that result."],
 ["Numeric Echo","Skill","Roll and store one ordinary Numeric value. It replaces your next Numeric roll. A second stored value is not allowed."],
 ["Lethargic Bind","Skill","Choose a boss die and face. Until your next turn, that face rolls as Bound (no action); you suffer 1 normal damage each time it triggers."],
 ["Restore","Skill","Heal another hero within 3 for Numeric, minimum 1. Cannot target yourself. Gambler x0 stays zero."],
 ["Focus Numeric","Skill","Your next Numeric roll this turn treats Blank as 1, then this benefit ends."],
 ["Mark Prey","Skill","Mark the boss until round end. The next damaging Attack when it has zero Block adds 1 damage, then removes the mark."],
 ["Last Word","Skill","After all your other non-Blank dice resolve, deal 1 unavoidable damage to the boss. Prototype range: visible anywhere."],
 ["Second Chance","Skill","Skip another unresolved non-Blank die, then repeat one already spent immediate face. Copy/repeat faces cannot chain into themselves."],
 ["Spiral Instability","Skill","Roll this die until an Attack appears, then resolve it twice at random legal adjacent units, including allies. No Attack on this die: no effect."],
 ["Contained Power","Skill","Channel: after maintaining at turn start, each future Blank grants 1 Block and each non-Blank adds Numeric +1 for that turn, capped +2. HP damage breaks it, deals 2 more and leaves a Red Tile."],
 ["Corruption Conversion","Skill","Prototype on resolution: choose an unresolved Blank die, then choose an installed ability on it and resolve that face. This face becomes a locked Red Tile for the fight."],
 ["Blood Bargain","Skill","Empower the next two Attacks against the boss by +1 damage. After the second, take 1 unavoidable damage."],
 ["Target Override","Skill","Reaction when personally targeted: force a different legal adjacent hero to be targeted. With no alternative the original target remains."],
 ["Debt","Skill","Your next Attack or Defense this turn gets +2 value. At your next turn, the first such face gets −2 value (minimum 0)."],
 ["Ill Omen","Skill","Prototype resolution choice: modify another unresolved Attack/Defense. d6: 1 gives −1, 2–4 gives +1, 5 gives Pierce 2 (Defense +2 Block), 6 repeats an Attack or doubles Defense Block."],
 ["Stonewake","Skill","Prototype Channel: gain 2 Block. While maintained, explicitly preserve existing Block at turn start and add 1 (cap 8). End to reroll the die."],
 ["Oath of Smoke","Skill","Prototype: resolve another rolled Step, Stride or Guard now; store it as a Reaction until the next shared roll. Movement reaction steps 1; Defense grants 1 Block."],
 ["Bone Mutation","Skill","Choose a Blank on one of your dice and replace it with Bone for this fight. Bone grants 1 Block, then optionally steps 1."],
 ["Strike Numeric","Attack","Adjacent unit: roll Numeric and deal that much damage."],
 ["Short Shot","Attack","Target a visible unit within 2. Damage capped at 1 per resolution, including Mark Prey; the mark is consumed on a damaging hit. Units block sight; no diagonal corner shooting."],
 ["Hooked Slash","Attack","Catalog variant: adjacent Numeric Attack. If at least 2 HP damage is dealt, gain that much Block."],
 ["Piercing Thrust","Attack","Adjacent Numeric Attack. Bypass 1 Block without destroying the bypassed portion."],
 ["Cleave","Attack","Adjacent Numeric Attack. A second enemy adjacent to that target takes 1. This encounter has only one enemy."],
 ["Flanking Blow","Attack","Prototype: adjacent Numeric Attack; add 1 when standing below the north-facing boss. Rear means its southern edge."],
 ["Break Rhythm","Attack","Adjacent Numeric Attack. If you break existing Block and deal HP damage, delay an upcoming boss activation one initiative slot when possible; normal initiative returns next round."],
 ["Engrave","Attack","Prototype adjacent Numeric Attack. After damage, copy Engrave into a Blank on this die (otherwise overwrite an unlocked non-Engrave). 3 copies: +1; 6 copies: +2."],
 ["Guard Numeric","Defense","Gain Block equal to a Numeric roll."],
 ["Brace Hero","Defense","If at zero Block, gain 3; otherwise gain 1."],
 ["Shield Wall","Defense","Reaction when an ally within 2 is attacked: give both that hero and yourself 1 Block before the hit."],
 ["Taunt","Defense","Reaction when another hero is attacked: become the target if adjacent to the boss. You must be a legal target."],
 ["Defy Death","Defense","Reaction before a lethal Attack: stay at 1 HP instead, gain Stunned, then blank this face. Prototype sets aside your first available result."],
 ["Bulwark","Defense","Gain Damage Reduction 1 and Weakness 1 until your next turn. Unavoidable damage bypasses reduction."],
 ["Echo of Pain","Defense","Reaction during a boss Attack: deal your actual HP damage taken this round to the boss (cap 3), then blank this face. If unused, take 1 unavoidable damage at next turn start."],
 ["Last Pulse","Defense","Channel: at each maintained turn start, heal 1 if no HP damage got through. HP damage breaks this Channel and blanks it."],
 ["Black Oath","Defense","Gain Numeric +1 Block. Prototype timing: at your turn end, lose 1 HP if Block remains."],
 ["Wither Ward","Defense","Prototype: gain Numeric Block. Until your next turn, an adjacent attacker causing HP loss receives Weakness 1 until its turn ends."],
 ["Ember Burst","Defense","Prototype: gain Numeric Block, then burn up to 2 Block; each deals normal damage to every adjacent unit, including allies. Choose how much to burn."],
 ["Leap of Echoes","Movement","Tabletop variant: leap up to 2 orthogonally over units, never land occupied. If ending adjacent to the boss, your next Numeric damage this turn gets +1."]
]
const GENERATED = [["Bone","Skill","Gain 1 Block and optionally step 1."],["Recovery","Skill","Heal yourself or an adjacent hero for Numeric."],["Red Tile","Penalty","Inert, non-rerollable, not a Blank, locked for this encounter."]]
const MOVEMENT = [["Ashstep","Movement","Slip through ash: move up to 2 orthogonal spaces, turning allowed, then gain 1 Block. Cannot pass through units."],["Oathbound Exchange","Movement","Swap positions with a living standing ally within 3 and clear sight. Both heroes gain 1 Block. Cannot swap with the boss or a Downed hero."]]
static func extended_ids() -> Array:
 return range(9,54) + [57,58]
static func name_for(id: int) -> String:
 if id < 9: return ["Blank","Strike","Step","Stride","Guard","Reaction","Focus","First Aid","Shove"][id]
 if id >= 57: return MOVEMENT[id-57][0]
 return EXTRA[id-9][0] if id < 54 else GENERATED[id-54][0]
static func category(id: int) -> String:
 if id < 9: return ["Blank","Attack","Movement","Movement","Defense","Defense","Skill","Skill","Skill"][id]
 if id >= 57: return "Movement"
 return EXTRA[id-9][1] if id < 54 else GENERATED[id-54][1]
static func text(id: int) -> String:
 if id in [25,31,49]: return EXTRA[id-9][2] + " Prototype limit: one active Channel per hero; a second cannot replace it."
 if id >= 57: return MOVEMENT[id-57][2]
 return EXTRA[id-9][2] if id < 54 else GENERATED[id-54][2]
static func draft_ids() -> Array:
 return range(1,54) + [57,58]
static func is_reaction(id: int) -> bool:
 return id in [5,28,44,45,46,48]
static func is_attack(id: int) -> bool:
 return category(id) == "Attack"
static func can_copy(id: int) -> bool:
 return id in [1,2,3,4,7,8,19,20,21,22,34,35,36,37,38,39,40,42,43,47,50,51,52,53,54,55,57,58]

static func readiness(id: int) -> String:
 if id in [9,11,38]: return "LIMITED · see effect notes"
 if id < 9 or id in [42,43,44,47,54,55,56,57,58]: return "IMPLEMENTED"
 return "PLAYTEST VERSION"


static func timing(id: int) -> String:
 if is_reaction(id): return "Reaction"
 if id in [25,31,49]: return "Channel"
 return "Action"

static func classification(id: int) -> String:
 var suffix := " - " + timing(id) if timing(id) != "Action" else ""
 return category(id) + suffix

static func display_name(id: int) -> String:
 if id == 0: return name_for(id)
 return name_for(id) + " (" + classification(id) + ")"
