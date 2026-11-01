extends "res://prototype/battle.gd"
# The Iron Warden rewards a deliberate guard / evade / counterattack rhythm.
const DICE = [["Iron Advance","Shield Bash","Iron Advance","Hammerfall","Raise Guard","Crushing Sweep"],["Shield Bash","Driving Blow","Iron Advance","Raise Guard","Crushing Sweep","Raise Guard"],["Driving Blow","Shield Bash","Crushing Sweep","Iron Advance","Crushing Sweep","Raise Guard"]]
var guard_broken := false
var sweep_tiles: Array = []
var sweep_threats: Array = []
var sweep_damage := 0
var sweep_due := false
func boss_name() -> String:return "Bu’gh · The Iron Warden"
func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true, profile: Dictionary = {}) -> void:
 encounter_id = "bugh";guard_broken = false;sweep_tiles.clear();sweep_threats.clear();sweep_due = false
 super.start(builds,seed_value,soul,balanced,profile)
func prepare_encounter() -> void:
 boss.hp = v("bugh.hp");boss.max_hp = boss.hp
 note("THE IRON WARDEN: Bulwark reduces normal damage by %d. Fully prevent a direct hit with Block / Damage Reduction, or move a threatened hero out of the marked sweep, to break it until his next turn. Breaking guard also removes his Block. Defend or evade, then counterattack. No cocoons or summons." % v("warden.armor"))
func boss_dice() -> Array:return DICE.duplicate(true)
func w(base: String, upgrade: String = "") -> int:
 return v("warden."+base)+(v("warden."+upgrade) if phase_two and upgrade != "" else 0)
func activate() -> void:
 var entering: bool = cursor < order.size() and order[cursor] == 3
 if entering:
  if guard_broken:record_event("expire","Bu’gh raises Bulwark at his next turn start.",3,3)
  guard_broken = false
 super.activate()
 if entering and active == 3 and outcome == "":
  sweep_due = not sweep_tiles.is_empty()
  if sweep_due:record_event("guide","SWEEP IMPACT comes before the three new dice. Reactions apply. Escaping its marked cells or fully guarding the hit creates an opening.",3)
func break_guard(reason: String, hero: int) -> void:
 if guard_broken or outcome != "":return
 guard_broken = true
 var stripped: int = boss.block;boss.block = 0
 record_event("guard_break","%s breaks the Warden’s guard: Bulwark OFF and %d boss Block removed. Counterattack before his next turn." % [reason,stripped],hero,3,stripped)
 last_boss_result = "GUARD BROKEN · Normal damage gets through until Bu’gh’s next turn."
func damage(id: int, amount: int, unavoidable: bool = false, reason: String = "", attacker: int = -1) -> void:
 var hp_before: int = unit_data(id).hp
 var block_before: int = unit_data(id).block
 var dr_before: int = int(unit_data(id).get("dr",0))
 if id == 3 and not unavoidable and not guard_broken and amount > 0:
  var stopped := mini(amount,v("warden.armor"));amount -= stopped
  record_event("armor","BULWARK stops %d damage. Fully guard a Warden attack or escape his marked sweep to expose him." % stopped,action_owner,3,stopped)
 super.damage(id,amount,unavoidable,reason,attacker)
 if outcome != "":return
 if id in [0,1,2] and attacker == 3 and not unavoidable and amount > 0 and hp_before > 0 and heroes[id].hp == hp_before and (heroes[id].block < block_before or dr_before > 0):
  break_guard("%s’s perfect guard" % unit_name(id),id)
 if id in [0,1,2] and attacker == 3 and action_label == "Driving Blow" and heroes[id].hp > 0 and heroes[id].hp < hp_before:
  for step in range(w("push","push_phase")):
   var moved := false
   for dir in away_dirs(3,id):
    if legal(id,heroes[id].pos+dir):heroes[id].pos += dir;moved = true;break
   if not moved:break
  record_event("move","Driving Blow pushes %s back; fully guarding prevents the push." % unit_name(id),3,id)
func arm_sweep() -> void:
 if not sweep_tiles.is_empty():note("The existing sweep stays marked; it does not stack or chase moving heroes.");return
 var reach := w("sweep_range","sweep_range_phase")
 for y in range(9):
  for x in range(9):
   var cell := Vector2i(x,y)
   if cell in cells(3):continue
   var nearest := 99
   for part in cells(3):nearest = mini(nearest,absi(cell.x-part.x)+absi(cell.y-part.y))
   if nearest <= reach:sweep_tiles.append(cell)
 sweep_damage = w("sweep_damage","sweep_damage_phase")
 sweep_threats.clear()
 for id in range(3):
  if heroes[id].hp > 0 and not heroes[id].dead and heroes[id].pos in sweep_tiles:sweep_threats.append(id)
 record_event("warning","CRUSHING SWEEP MARKED: %d damage on these fixed cells at the START of Bu’gh’s next turn. Move out or prepare enough Block / a Reaction. A threatened hero who escapes will break Bulwark." % sweep_damage,3)
func resolve_sweep() -> void:
 sweep_due = false
 begin_action(3,"Crushing Sweep")
 var victims: Array = []
 for id in [0,1,2]+living_minions("friendly"):
  if unit_data(id).hp > 0 and not unit_data(id).get("dead",false) and unit_data(id).pos in sweep_tiles:victims.append(id)
 last_targets = victims.duplicate()
 if victims.is_empty():after_enemy_attack(3,"Crushing Sweep",victims,[]);return
 pending = {"kind":"attack","source":3,"action":"Crushing Sweep","area":true,"range":99,"tiles":sweep_tiles.duplicate(),"victims":victims,"reacted":[],"amount":sweep_damage}
 continue_attack()
func after_enemy_attack(source: int, action: String, _declared: Array, _hit: Array) -> void:
 if source != 3 or action != "Crushing Sweep":return
 for hero in sweep_threats:
  if heroes[hero].hp > 0 and not heroes[hero].dead and heroes[hero].pos not in sweep_tiles:
   break_guard("%s’s sweep evasion" % unit_name(hero),hero);break
 sweep_tiles.clear();sweep_threats.clear()
 if not guard_broken:last_boss_result = "Sweep resolved. Bulwark remains; earn an opening with a full guard."
func finish_turn() -> void:
 if outcome != "" or not pending.is_empty():return
 if active == 3:arm_sweep()
 super.finish_turn()
func boss_display_action() -> String:return "Crushing Sweep · impact" if sweep_due else super.boss_display_action()
func boss_step_label() -> String:return "Resolve marked sweep →" if sweep_due else super.boss_step_label()
func boss_range(action: String) -> int:
 if action == "Hammerfall":return w("hammer_range","hammer_range_phase")
 if action in ["Shield Bash","Driving Blow"]:return v("warden.melee_range")
 if action == "Crushing Sweep":return 99
 return super.boss_range(action)
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if sweep_due:resolve_sweep();report_changes();return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index]
 begin_action(3,action,-1,boss_index);boss_index += 1;last_action = action;last_targets.clear();last_boss_result = action+" resolved."
 match action:
  "Bound":note("Lethargic Bind suppresses this result.")
  "Iron Advance":boss_move(w("advance","advance_phase"))
  "Raise Guard":boss.block += w("block","block_phase");note("Raise Guard: +%d Block. This does not restore a broken Bulwark." % w("block","block_phase"))
  "Crushing Sweep":arm_sweep()
  "Shield Bash","Hammerfall","Driving Blow":
   var options := attack_targets(3,boss_range(action))
   if options.is_empty():fallback()
   else:
    var victims: Array = options if action == "Hammerfall" else [nearest(options)]
    var amount := w("hammer_damage") if action == "Hammerfall" else (w("bash_damage","bash_damage_phase") if action == "Shield Bash" else w("drive_damage","drive_damage_phase"))
    last_targets = victims.duplicate();pending = {"kind":"attack","source":3,"action":action,"range":boss_range(action),"area":action == "Hammerfall","victims":victims,"reacted":[],"amount":amount};continue_attack()
  _:fallback()
 report_changes()
func fallback() -> void:
 var moved := boss_move(v("warden.fallback_move"));last_boss_result = action_label+(": approaches the party." if moved else ": holds; the party blocks the route.");note(last_boss_result)
func check_phase() -> void:
 if phase_two or boss.hp <= 0 or boss.hp*100 > boss.max_hp*v("boss.phase.percent"):return
 phase_two = true
 record_event("phase","BU’GH — IRON VOW: longer advances, stronger bashes and pushes, wider Hammerfall, stronger Guard and wider / harder future sweeps. Existing warning cells and damage stay fixed. Guarding and evading still expose him.",3)
func phase_upgrades() -> Array:
 return [["Iron Advance","Move +%d." % v("warden.advance_phase")],["Shield Bash","Damage +%d." % v("warden.bash_damage_phase")],["Hammerfall","Area reach +%d." % v("warden.hammer_range_phase")],["Raise Guard","Block +%d; cannot restore Bulwark early." % v("warden.block_phase")],["Crushing Sweep","Future warning reach +%d; damage +%d. Existing warnings do not expand." % [v("warden.sweep_range_phase"),v("warden.sweep_damage_phase")]],["Driving Blow","Damage +%d; HP-hit push +%d." % [v("warden.drive_damage_phase"),v("warden.push_phase")]]]
func default_boss_help(action: String) -> String:
 match action:
  "Iron Advance":return "Advance up to %d toward the party. Occupied tiles block the full 2×2 footprint." % w("advance","advance_phase")
  "Shield Bash":return "Closest opponent within %d: %d normal damage. Fully preventing HP loss with Block / Damage Reduction breaks Bulwark and removes his Block. Reactions apply." % [boss_range(action),w("bash_damage","bash_damage_phase")]
  "Hammerfall":return "Attack each opponent within %d for %d normal damage. Spread out or guard. One fully defended hero hit breaks Bulwark. Reactions apply." % [boss_range(action),w("hammer_damage")]
  "Raise Guard":return "Gain %d Block. Does not restore a broken Bulwark before his next turn." % w("block","block_phase")
  "Crushing Sweep","Crushing Sweep · impact":return "Marked cells take %d damage before his next three dice. The warning is fixed: move a threatened hero out to break Bulwark, or fully guard the impact. Reactions apply; movement Reactions can escape. After every boss turn a sweep is armed if none is already marked. Future warning reach %d." % [sweep_damage if not sweep_tiles.is_empty() else w("sweep_damage","sweep_damage_phase"),w("sweep_range","sweep_range_phase")]
  "Driving Blow":return "Closest opponent within %d: %d damage. A hero who loses HP is pushed up to %d; occupied cells stop the push. Fully guarding prevents the push and breaks Bulwark." % [boss_range(action),w("drive_damage","drive_damage_phase"),w("push","push_phase")]
  "Bound":return "Suppressed by Lethargic Bind."
 return "Defend / evade → break Bulwark → counterattack. Resolve the marked sweep, then I → II → III."
func turn_explanation() -> String:return "IRON WARDEN: %s Fully guard his direct attack or move a threatened hero off the sweep warning to break Bulwark until his next turn. Counterattack during that opening. " % ("BULWARK BROKEN: normal damage gets through." if guard_broken else "BULWARK ON: −%d normal incoming damage." % v("warden.armor"))+super.turn_explanation()
func status_description(id: int) -> String:
 if id != 3:return super.status_description(id)
 var text := "BULWARK BROKEN until next boss turn: counterattack." if guard_broken else "BULWARK: −%d normal incoming damage. Fully guard a hit or escape a marked sweep to expose him." % v("warden.armor")
 if not sweep_tiles.is_empty():text += " Sweep: %d damage on marked cells before his next three dice." % sweep_damage
 if boss.get("poison",0) > 0:text += " Poison %d: unavoidable HP damage at next activation, then clears." % boss.poison
 if boss.weak:text += " Weakness %d until this boss turn ends." % boss_weakness()
 return text
