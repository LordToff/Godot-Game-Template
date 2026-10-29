extends RefCounted
const Balance = preload("res://prototype/balance.gd")
var values: Dictionary = {}
var tuned := true
func n(key: String) -> int:return Balance.value(values,key,tuned)
func reach(f: int) -> String:
 var distance := n("face%d.range" % f)
 return "an adjacent unit" if distance == 1 else "a unit within %d" % distance
func face(f: int) -> String:
 match f:
  0:return "No ordinary effect. With the test Soul ON, spend a Blank as Move %d; at most %d per hero turn." % [n("soul.move"),n("soul.uses")]
  1:return "Deal %d damage to %s." % [n("face1.damage"),reach(f)]
  2:return "Move up to %d orthogonal spaces. Occupied cells block the path." % n("face2.move")
  3:return "Move up to %d spaces in a straight line. No turning or passing through units." % n("face3.move")
  4:return "Gain %d Block. Unspent Block expires at your next turn." % n("face4.block")
  5:return "When attacked, gain %d Block and optionally step %d before the hit." % [n("face5.block"),n("face5.move")]
  6:return "Click another READY die to reroll it. Resolve its new result next, or decline it.\n\nWorks after other actions. Uses this Focus face, not a reroll charge. Locked faces cannot be rerolled."
  7:return "Heal yourself or an ally within %d for %d HP. A Downed ally revives as Broken." % [n("face7.range"),n("face7.heal")]
  8:return "Push %s up to %d spaces away. No collision damage." % [reach(f),n("face8.move")]
  9:return "First use: arm Numeric ×0 / ×%d. Next use: gain %d Gold and turn this face Blank.\n\nNon-rerollable. Gold has no shop in this encounter." % [n("face9.multiplier"),n("face9.gold")]
  10:return "Arm Weak Point through the end of the next %d round(s). Your next Attack from the boss’s southern edge repeats %d extra time(s).\n\nThe gold marker stays until used or expired." % [n("face10.duration"),n("face10.repeat")]
  11:return "Copy another visible immediate hero ability within %d. Choose its hero and die, then resolve the copy.\n\nNo setup or copy chains. Non-rerollable." % n("face11.range")
  12:return "Install Recovery on a chosen Blank belonging to a hero. Recovery heals a rolled value at range 1.\n\nAfter %d placements, this face becomes Blank." % n("face12.placements")
  13:return "When rolled, gain %d Action Reroll, up to the bank cap of %d. A full bank gains nothing." % [n("face13.rerolls"),n("hero.reroll_cap")]
  14:return "Your next rolled damage this turn gets +%d." % n("face14.boost")
  15:return "Heal another hero within %d for a rolled value. Move this face to a Blank on that hero.\n\nCannot heal yourself. Non-rerollable." % n("face15.range")
  16:return "Choose an unresolved die and one of its installed faces. Turn it to that face and resolve it next. Red Tiles are unavailable."
  17:return "Roll and store one ordinary value. Use it instead of your next Numeric roll. Only one value can be stored."
  18:return "Bind a chosen boss die and face until your next turn. Each matching roll is skipped, but you take %d normal damage." % n("face18.backlash")
  19:return "Heal another hero within %d for a rolled value, at least %d. Clear sight required. Gambler ×0 stays zero." % [n("face19.range"),n("face19.minimum")]
  20:return "Your next Numeric roll this turn treats Blank as %d." % n("face20.blank_value")
  21:return "Mark the boss until round end. Its next damaging Attack hit while at zero Block gains %d damage, then removes the mark." % n("face21.damage")
  22:return "After your other non-Blank dice are spent, deal %d unavoidable damage to the boss." % n("face22.damage")
  23:return "Skip another unresolved non-Blank die. Repeat a different, already-spent immediate ability. No repeat or copy chains."
  24:return "Choose an Attack from this die and resolve it %d times at random legal targets, including allies. No Attack on this die means no effect." % n("face24.repeat")
  25:return "Maintain: future Blank rolls grant %d Block; other rolls add +%d to Numeric, capped at +%d.\n\nHP loss breaks it, causes %d normal backlash damage and leaves a Red Tile." % [n("face25.blank_block"),n("face25.boost"),n("face25.cap"),n("face25.backlash")]
  26:return "Choose an unresolved Blank die, then an ability installed on it. Resolve that result. This Conversion face becomes a locked Red Tile."
  27:return "The next %d Attacks against the boss gain +%d damage. After the last, you take %d unavoidable damage." % [n("face27.charges"),n("face27.damage"),n("face27.backlash")]
  28:return "When personally targeted, redirect to a different legal adjacent hero. With no alternative, the original target remains."
  29:return "Next Attack or Defense this turn: +%d. At your next turn, your first such face suffers −%d, minimum zero." % [n("face29.boost"),n("face29.penalty")]
  30:return "Modify an unresolved Attack or Defense with a random bonus, penalty, Pierce or repeat. Pick the affected die. See More rules for the six outcomes."
  31:return "Gain %d Block. Maintain: preserve Block and add %d, up to %d.\n\nAny HP loss or %d cumulative Block lost before your next turn interrupts this Channel." % [n("face31.initial"),n("face31.gain"),n("face31.cap"),n("face31.break_block")]
  32:return "Resolve another rolled Step, Stride or Guard now. Then store it as a Reaction until the next shared roll."
  33:return "Install Bone on one of your Blanks for this fight. Bone gains %d Block and may step %d." % [n("face54.block"),n("face54.move")]
  34:return "Roll for damage against %s." % reach(f)
  35:return "Roll for damage against a visible unit within %d. Final damage is capped at %d, including Mark Prey." % [n("face35.range"),n("face35.cap")]
  36:return "Roll for damage against %s. At least %d HP lost: gain that HP loss ×%d as Block." % [reach(f),n("face36.threshold"),n("face36.multiplier")]
  37:return "Roll for damage against %s. Bypass %d Block; the bypassed Block remains after this hit." % [reach(f),n("face37.pierce")]
  38:return "Roll for damage against %s. Also deal %d damage to one other enemy adjacent to the target." % [reach(f),n("face38.splash")]
  39:return "Roll for damage against %s. Add %d when standing at the boss’s southern edge." % [reach(f),n("face39.rear")]
  40:return "Roll for damage against %s. Break existing Block and damage HP to delay an upcoming boss activation by %d slot(s)." % [reach(f),n("face40.delay")]
  41:return "Roll for damage against %s. On HP damage, grow on this die up to %d time(s) per hero turn, capped at %d copies.\n\nAt %d copies: +%d damage. Never overwrites another ability." % [reach(f),n("face41.growth"),n("face41.cap"),n("face41.threshold2"),n("face41.bonus2")]
  42:return "Roll a value and gain that much Block."
  43:return "At zero Block: gain %d. Otherwise: gain %d." % [n("face43.empty"),n("face43.normal")]
  44:return "When an ally within %d is attacked, give them %d Block and yourself %d before the hit. Clear sight required." % [n("face44.range"),n("face44.ally"),n("face44.self")]
  45:return "When another hero is attacked, take their place if you are a legal target within %d. Cannot redirect Sweep or Furnace Roar." % n("face45.range")
  46:return "Before a lethal Attack, remain at %d HP instead and gain Stunned. This face becomes Blank." % n("face46.hp")
  47:return "Gain Damage Reduction %d and Weakness %d until your next turn. Unavoidable damage bypasses reduction." % [n("face47.reduction"),n("face47.weakness")]
  48:return "During a boss Attack, deal the HP damage you took this round to the boss, capped at %d. This face becomes Blank.\n\nUnused: take %d unavoidable damage at your next turn." % [n("face48.cap"),n("face48.penalty")]
  49:return "Maintain: heal %d at your turn start. Any HP loss interrupts the Channel and turns this face Blank." % n("face49.heal")
  50:return "Gain a rolled value +%d Block. At your turn end, lose %d HP if any Block remains." % [n("face50.block"),n("face50.penalty")]
  51:return "Gain rolled Block. Until your next turn, an adjacent boss Attack that removes HP gives the boss Weakness %d." % n("face51.weakness")
  52:return "Gain rolled Block, then burn up to %d Block. Each burned point deals %d damage to every other unit within %d, including allies." % [n("face52.burn"),n("face52.damage"),n("face52.range")]
  53:return "Leap up to %d spaces, over units but never onto them. End within %d of the boss to gain +%d on your next rolled damage this turn." % [n("face53.move"),n("face53.range"),n("face53.boost")]
  54:return "Gain %d Block and optionally step %d." % [n("face54.block"),n("face54.move")]
  55:return "Heal yourself or an ally within %d for a rolled value." % n("face55.range")
  56:return "No effect. Locked: cannot be rerolled and does not count as a Blank."
  57:return "Move up to %d spaces, turning allowed, then gain %d Block. Occupied cells block the path." % [n("face57.move"),n("face57.block")]
  58:return "Swap with a standing ally within %d and clear sight. Both gain %d Block. Rooted prevents the swap." % [n("face58.range"),n("face58.block")]
 return ""
