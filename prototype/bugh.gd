extends "res://prototype/battle.gd"
# The Cocoon Regent: delayed brood, with a reward for breaking its cradles.
const DICE = [["Lay the Cradle","Shed the Shell","Silken Mandate","Hatching Scream","Royal Feast","Carapace Crash"],["Carapace Crash","Lay the Cradle","Silken Mandate","Shed the Shell","Hatching Scream","Royal Feast"],["Shed the Shell","Carapace Crash","Royal Feast","Silken Mandate","Lay the Cradle","Hatching Scream"]]
var brood_queue: Array = []
var brood_active := false
var brood_finished := false
func boss_name() -> String:return "Bu’gh · The Cocoon Regent"
func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true, profile: Dictionary = {}) -> void:
 encounter_id = "bugh";brood_queue.clear();brood_active = false;brood_finished = false
 super.start(builds,seed_value,soul,balanced,profile)
func prepare_encounter() -> void:
 boss.hp = v("bugh.hp");boss.max_hp = boss.hp
 lay_cocoons(v("bugh.initial_cocoons"))
 note("BU’GH — COCOON REGENT: break cocoons for Block, strip the Regent’s Block and weaken it until its turn ends. No Soul Link. After three dice: age cocoons, hatch mature ones, then activate mites. Royal Feast consumes only enemy mites.")
func boss_dice() -> Array:return DICE.duplicate(true)
func activate() -> void:
 if cursor < order.size() and order[cursor] == 3:brood_finished = false;brood_active = false
 super.activate()
func kind_ids(kind: String) -> Array:
 return living_minions().filter(func(id):return unit_data(id).get("kind","") == kind)
func lay_cocoons(count: int) -> int:
 var spawned := 0
 for index in range(count):
  if living_minions().size() >= v("bugh.cap"):break
  var candidates: Array = []
  for y in range(9):
   for x in range(9):
    var cell := Vector2i(x,y)
    if legal(unit_count(),cell) and distance(unit_count(),3,cell) <= v("bugh.lay_radius"):candidates.append(cell)
  if candidates.is_empty():break
  var pos: Vector2i = candidates[rng.randi_range(0,candidates.size()-1)]
  var hp := v("bugh.cocoon_hp")+(v("bugh.cocoon_hp_phase") if phase_two else 0)
  minions.append({"name":"Regent Cocoon %d" % (minions.size()+1),"kind":"cocoon","faction":"enemy","hp":hp,"max_hp":hp,"block":0,"pos":pos,"dead":false,"age":0,"poison":0})
  record_event("summon","Bu’gh lays %s at %s: %d HP; hatch after %d brood phases." % [unit_name(unit_count()-1),cell_name(pos),hp,v("bugh.hatch_turns")],3,unit_count()-1)
  spawned += 1
 if spawned < count:note("Brood cap or occupied tiles prevented a cocoon.")
 return spawned
func hatch(id: int) -> void:
 var unit := unit_data(id)
 if unit.dead or unit.get("kind","") != "cocoon":return
 unit.kind = "mite";unit.name = "Regent Mite %d" % (id-3)
 unit.hp = v("bugh.mite_hp");unit.max_hp = unit.hp
 unit.block = v("bugh.mite_block_phase") if phase_two else 0
 record_event("hatch","%s hatches at %s: %d HP, %d Block. It can act in the next brood phase." % [unit_name(id),cell_name(unit.pos),unit.hp,unit.block],3,id)
func finish_turn() -> void:
 if outcome != "" or not pending.is_empty():return
 if active == 3 and not brood_finished:
  brood_finished = true;brood_active = true
  # Poison is an activation effect; a poisoned cocoon ticks before aging/hatching.
  for id in kind_ids("cocoon"):
   tick_poison(id)
   if unit_data(id).dead or outcome != "":continue
   unit_data(id).age += 1
   record_event("brood","%s ages to %d/%d." % [unit_name(id),unit_data(id).age,v("bugh.hatch_turns")],3,id)
   if unit_data(id).age >= v("bugh.hatch_turns"):hatch(id)
  brood_queue = kind_ids("mite")
  record_event("brood","BROOD PHASE: cocoons age; surviving mites move and bite after Bu’gh’s three dice.",3)
  activate_mite();return
 super.finish_turn()
func activate_mite() -> void:
 while not brood_queue.is_empty() and unit_data(brood_queue[0]).dead:brood_queue.pop_front()
 if brood_queue.is_empty():brood_active = false;super.finish_turn();return
 var id: int = brood_queue.pop_front()
 tick_poison(id)
 if outcome != "" or unit_data(id).dead:return
 action_owner = id;action_label = "Mite Bite";action_before = state_snapshot()
 move_summon(id,v("bugh.mite_move")+(v("bugh.mite_move_phase") if phase_two else 0))
 var options := attack_targets(id,v("bugh.mite_range"))
 if options.is_empty():last_boss_result = unit_name(id)+": no adjacent opponent.";note(last_boss_result);return
 var target := nearest_attacked(id,options);var side := rng.randi_range(0,5)
 var amount := v("bugh.mite_damage") if side < v("bugh.mite_hit_faces") else 0
 var faces: Array = []
 for index in range(6):faces.append(str(v("bugh.mite_damage") if index < v("bugh.mite_hit_faces") else 0))
 roll_presentations.append({"actor":unit_name(id),"kind":"Numeric · Mite Bite","faces":[faces],"sides":[side],"results":[str(amount)],"dice":[0]})
 record_event("roll","%s → %s: bite d6 side %d [%s] = %d. HP damage inflicts Weakness%s." % [unit_name(id),unit_name(target),side+1,", ".join(faces),amount," and Rooted" if phase_two else ""],id,target)
 last_targets = [target];last_boss_result = "%s → %s: bite %d." % [unit_name(id),unit_name(target),amount]
 if amount > 0:
  pending = {"kind":"attack","source":id,"action":"Mite Bite","range":v("bugh.mite_range"),"victims":[target],"reacted":[],"amount":amount};continue_attack()
 report_changes()
func on_enemy_bite(source: int, target: int, action: String) -> void:
 if action != "Mite Bite":return
 if target >= 4:
  unit_data(target).weak = v("bugh.mite_weakness")
  if phase_two:unit_data(target).rooted = v("bugh.mite_root_phase")
  record_event("debuff","Mite Bite weakens friendly Nu’gh%s until next boss turn." % (" and Roots it" if phase_two else ""),source,target)
  return
 if target == 3:return
 heroes[target].weak = true;heroes[target].weak_amount = v("bugh.mite_weakness")
 if phase_two:heroes[target].rooted = maxi(heroes[target].rooted,v("bugh.mite_root_phase"))
 record_event("debuff","%s inflicts Weakness %d%s on %s until next boss turn." % [unit_name(source),v("bugh.mite_weakness")," and Rooted" if phase_two else "",unit_name(target)],source,target)
func boss_visible_index() -> int:return 3 if brood_active else boss_index
func boss_display_action() -> String:return "Regent brood phase" if brood_active else super.boss_display_action()
func boss_step_label() -> String:return "Next mite / finish brood →" if brood_active else super.boss_step_label()
func boss_range(action: String) -> int:
 if action == "Carapace Crash":return v("bugh.crash_range")+(v("bugh.crash_range_phase") if phase_two else 0)
 if action == "Mite Bite":return v("bugh.mite_range")
 return super.boss_range(action)
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if brood_active:activate_mite();return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index]
 begin_action(3,action,-1,boss_index);boss_index += 1;last_action = action;last_targets.clear();last_boss_result = action+" resolved."
 match action:
  "Bound":note("Bound suppresses this die.")
  "Lay the Cradle":lay_cocoons(v("bugh.lay_count"))
  "Shed the Shell":
   var block := v("bugh.shell_block")+(v("bugh.shell_phase") if phase_two else 0)
   boss.block += block;lay_cocoons(v("bugh.lay_count"));note("Shed the Shell: +%d Block." % block)
  "Silken Mandate":
   var options := targets(v("bugh.mandate_range"))
   if options.is_empty():fallback()
   else:
    var highest := 0
    for id in options:highest = maxi(highest,heroes[id].hp)
    options = options.filter(func(id):return heroes[id].hp == highest)
    var target: int = options[rng.randi_range(0,options.size()-1)]
    heroes[target].weak = true;heroes[target].weak_amount = v("bugh.mandate_weakness")
    if phase_two:heroes[target].rooted = maxi(heroes[target].rooted,v("bugh.mandate_root_phase"))
    last_targets = [target];note("Silken Mandate: %s suffers Weakness%s until next boss turn." % [unit_name(target)," and Rooted" if phase_two else ""])
  "Hatching Scream":
   var cocoons := kind_ids("cocoon")
   if cocoons.is_empty():note("Hatching Scream: no cocoons to hatch.")
   elif phase_two:
    for id in cocoons:hatch(id)
   else:hatch(cocoons[0])
  "Royal Feast":
   var mites := kind_ids("mite")
   if mites.is_empty():note("Royal Feast: no enemy mite; nothing consumed.")
   else:
    mites.sort_custom(func(a,b):return distance(3,a)<distance(3,b))
    var id: int = mites[0];unit_data(id).dead = true;unit_data(id).hp = 0;unit_data(id).poison = 0
    var healed := mini(v("bugh.feast_heal"),boss.max_hp-boss.hp);boss.hp += healed
    var block := v("bugh.feast_block")+(v("bugh.feast_block_phase") if phase_two else 0);boss.block += block
    record_event("consume","Royal Feast consumes %s: heal %d, gain %d Block. No Soul Link." % [unit_name(id),healed,block],3,id)
  "Carapace Crash":
   boss_move(v("bugh.crash_move")+(v("bugh.crash_move_phase") if phase_two else 0))
   var options := attack_targets(3,boss_range(action))
   if options.is_empty():note("Carapace Crash: approach complete; no target in reach.")
   else:
    var victims: Array = options if phase_two else [nearest(options)]
    last_targets = victims.duplicate()
    pending = {"kind":"attack","action":action,"area":phase_two,"victims":victims,"reacted":[],"amount":v("bugh.crash_damage_phase") if phase_two else v("bugh.crash_damage")};continue_attack()
  _:fallback()
 report_changes()
func fallback() -> void:
 var moved := boss_move(v("bugh.fallback_move"))
 last_boss_result = action_label+(": approaches." if moved else ": holds; no legal approach.")
 note(last_boss_result)
func damage_minion(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 var cocoon: bool = not friendly(id) and unit_data(id).get("kind","") == "cocoon"
 var alive: bool = not unit_data(id).dead
 super.damage_minion(id,amount,unavoidable,reason)
 if alive and unit_data(id).dead and cocoon and action_owner in [0,1,2]:
  heroes[action_owner].block += v("bugh.break_block")
  var stripped := remove_block(3,v("bugh.break_strip"))
  boss.weak = true;boss.weak_amount = v("bugh.break_weakness")
  record_event("cocoon_break","%s breaks a cocoon: +%d Block, strips %d boss Block, boss Weakness %d until Bu’gh’s turn ends. No Soul Link." % [unit_name(action_owner),v("bugh.break_block"),stripped,v("bugh.break_weakness")],action_owner,3)
func check_phase() -> void:
 if phase_two or boss.hp <= 0 or boss.hp*100 > boss.max_hp*v("boss.phase.percent"):return
 phase_two = true
 record_event("phase","BU’GH — THE CRADLE OPENS: new cocoons have extra HP; newborn mites gain Block; mites move farther and Root on HP damage. Scream hatches all. Crash becomes a wider, lower-damage area attack.",3)
func default_boss_help(action: String) -> String:
 match action:
  "Lay the Cradle":return "Lay %d cocoon(s), within %d of Bu’gh; enemy brood cap %d. New cocoon HP %d. Hatch after %d brood phases. Breaking one with a hero: +%d Block, remove up to %d boss Block, boss Weakness %d until Bu’gh’s turn ends. No Soul Link." % [v("bugh.lay_count"),v("bugh.lay_radius"),v("bugh.cap"),v("bugh.cocoon_hp")+(v("bugh.cocoon_hp_phase") if phase_two else 0),v("bugh.hatch_turns"),v("bugh.break_block"),v("bugh.break_strip"),v("bugh.break_weakness")]
  "Shed the Shell":return "Gain %d Block, then lay a cocoon (brood cap still applies)." % [v("bugh.shell_block")+(v("bugh.shell_phase") if phase_two else 0)]
  "Silken Mandate":return "Highest-HP standing hero within %d suffers Weakness %d%s until the next boss turn. Ties random." % [v("bugh.mandate_range"),v("bugh.mandate_weakness")," and Rooted" if phase_two else ""]
  "Hatching Scream":return "Hatch all cocoons immediately." if phase_two else "Hatch the oldest living cocoon immediately. It may act in the brood phase after the three dice."
  "Royal Feast":return "Consume one ENEMY mite (never a friendly Nu’gh) to heal %d and gain %d Block. No mite: no effect." % [v("bugh.feast_heal"),v("bugh.feast_block")+(v("bugh.feast_block_phase") if phase_two else 0)]
  "Carapace Crash":return "Move %d, reach %d: %s for %d damage before defenses. Reactions apply." % [v("bugh.crash_move")+(v("bugh.crash_move_phase") if phase_two else 0),boss_range(action),"hit every opponent in range" if phase_two else "attack closest opponent",v("bugh.crash_damage_phase") if phase_two else v("bugh.crash_damage")]
  "Regent brood phase":return "After all three boss dice: age cocoons, hatch at %d, then activate each mite. Mites: %d HP, Move %d, reach %d, Numeric 1,1,0,0,0,0. HP-damaging bites inflict Weakness%s until next boss turn." % [v("bugh.hatch_turns"),v("bugh.mite_hp"),v("bugh.mite_move")+(v("bugh.mite_move_phase") if phase_two else 0),v("bugh.mite_range")," and Rooted" if phase_two else ""]
  "Bound":return "Suppressed by Lethargic Bind."
 return "Resolve three dice, then the Regent brood phase."
func phase_upgrades() -> Array:
 return [["Lay the Cradle","New cocoon HP +%d; existing cocoon HP is unchanged." % v("bugh.cocoon_hp_phase")],["Shed the Shell","Block +%d; upgraded new cocoons." % v("bugh.shell_phase")],["Silken Mandate","Also Rooted %d." % v("bugh.mandate_root_phase")],["Hatching Scream","Hatch ALL cocoons. Newborn mites gain %d Block; Move +%d; HP-damaging bites also Root." % [v("bugh.mite_block_phase"),v("bugh.mite_move_phase")]],["Royal Feast","Block +%d; healing unchanged." % v("bugh.feast_block_phase")],["Carapace Crash","Move +%d, reach +%d; becomes area damage %d." % [v("bugh.crash_move_phase"),v("bugh.crash_range_phase"),v("bugh.crash_damage_phase")]]]
func turn_explanation() -> String:return "BU’GH: break cocoons for Block and boss Weakness. Mites act after three dice. No Soul Link. "+super.turn_explanation()
func summon_description(id: int) -> String:
 if friendly(id):return super.summon_description(id)
 var unit := unit_data(id)
 var text := "Cocoon: age %d/%d. Hero breaks grant Block and weaken Bu’gh; no Soul Link." % [unit.get("age",0),v("bugh.hatch_turns")] if unit.get("kind","") == "cocoon" else default_boss_help("Regent brood phase")
 if unit.get("poison",0) > 0:text += " Poison %d at next brood activation." % unit.poison
 return text
func status_description(id: int) -> String:
 if id != 3:return super.status_description(id)
 var text := "%s. Enemy brood %d/%d: %d cocoons, %d mites. No Soul Link." % ["Phase II: The Cradle Opens" if phase_two else "Phase I",living_minions().size(),v("bugh.cap"),kind_ids("cocoon").size(),kind_ids("mite").size()]
 if boss.weak:text += " Weakness %d until this boss turn ends." % boss_weakness()
 if boss.get("poison",0) > 0:text += " Poison %d: unavoidable HP damage at next boss activation, then clears." % boss.poison
 return text
