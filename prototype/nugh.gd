extends "res://prototype/battle.gd"
const DICE = [["Birth Cry","Brood Command","Burrow","Brood Command","Gnashing Maw","Brood Guard"],["Brood Command","Brood Command","Birth Cry","Burrow","Gnashing Maw","Devour Brood"],["Brood Command","Birth Cry","Burrow","Brood Command","Devour Brood","Brood Guard"]]
var brood_queue: Array = []
var command_active := false
func boss_name() -> String:return "Nu’gh"
func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true, profile: Dictionary = {}) -> void:
 encounter_id = "nugh";brood_queue.clear();command_active = false
 super.start(builds,seed_value,soul,balanced,profile)
func prepare_encounter() -> void:
 boss.hp = v("nugh.hp");boss.max_hp = boss.hp
 spawn_worms(v("nugh.initial_worms"))
 record_event("guide","Nu’gh retreats while Brood Command moves and attacks with each worm. Soul Link damages him only BEFORE half HP. At half HP it breaks permanently: hunt Nu’gh directly while controlling his brood.",3)
func boss_dice() -> Array:return DICE.duplicate(true)
func pressure() -> int:return mini(v("nugh.pressure_cap")+(v("nugh.pressure_bonus") if phase_two else 0),living_minions().size())
func summon_cell_free(cell: Vector2i) -> bool:
 if cell.x < 0 or cell.y < 0 or cell.x >= 9 or cell.y >= 9:return false
 for id in range(unit_count()):
  if not unit_data(id).get("dead",false) and cell in cells(id):return false
 return true
func spawn_worms(count: int, origin: Vector2i = Vector2i(-99,-99)) -> int:
 var spawned := 0
 for index in range(count):
  if living_minions().size() >= v("nugh.worm_cap"):break
  var candidates: Array = []
  for x in range(9):
   for y in range(9):
    var cell := Vector2i(x,y)
    if not summon_cell_free(cell):continue
    var d := distance(0,3,cell) if origin.x == -99 else absi(cell.x-origin.x)+absi(cell.y-origin.y)
    if d <= 2:candidates.append(cell)
  if candidates.is_empty():break
  candidates.sort_custom(func(a,b):return a.y > b.y)
  var pool: Array = candidates.filter(func(c):return c.y == candidates[0].y)
  var pos: Vector2i = pool[rng.randi_range(0,pool.size()-1)]
  var hp := v("nugh.worm_hp")
  minions.append({"name":"Screaming Worm %d" % (minions.size()+1),"hp":hp,"max_hp":hp,"block":0,"dead":false,"pos":pos})
  record_event("summon","Nu’gh summons %s at %s (%d HP). Never on occupied cells." % [unit_name(unit_count()-1),cell_name(pos),hp],3,unit_count()-1)
  spawned += 1
 if spawned < count:record_event("info","Brood cap or occupied cells prevented %d summon(s)." % (count-spawned),3)
 return spawned
func safety(at: Vector2i) -> Vector2i:
 var nearest_distance := 100;var total := 0
 for id in range(3):
  if heroes[id].dead or heroes[id].hp <= 0:continue
  var d := distance(3,id,at);nearest_distance = mini(nearest_distance,d);total += d
 return Vector2i(nearest_distance,total)
func retreat(steps: int) -> bool:
 var origin: Vector2i = boss.pos
 var best: Vector2i = safety(origin);var paths: Array = []
 var queue: Array = [[origin,[]]];var visited: Array = [origin]
 while not queue.is_empty():
  var item: Array = queue.pop_front();var at: Vector2i = item[0];var path: Array = item[1]
  var score := safety(at)
  if score.x > best.x or (score.x == best.x and score.y > best.y):best = score;paths = [path]
  elif score == best and not path.is_empty():paths.append(path)
  if path.size() >= steps:continue
  for dir in DIRS:
   var next: Vector2i = at+dir
   if next not in visited and legal(3,next):visited.append(next);queue.append([next,path+[next]])
 if best == safety(origin) or paths.is_empty():return false
 var chosen: Array = paths[rng.randi_range(0,paths.size()-1)]
 if chosen.is_empty():return false
 boss.pos = chosen.back()
 record_event("move","Nu’gh retreats %s → %s; nearest hero distance %d → %d." % [cell_name(origin),cell_name(boss.pos),safety(origin).x,best.x],3,3)
 return true
func fallback() -> void:
 var origin: Vector2i = boss.pos
 if retreat(v("nugh.fallback_move")):
  last_boss_result = "%s → FALLBACK: RETREAT %s → %s." % [action_label,cell_name(origin),cell_name(boss.pos)]
 else:
  boss.block += v("nugh.guard_block")
  last_boss_result = "%s → FALLBACK: cornered; +%d Block." % [action_label,v("nugh.guard_block")]
 record_event("fallback",last_boss_result,3,3)
func boss_range(action: String) -> int:
 if action == "Worm Bite":return 1
 if action == "Gnashing Maw":return v("nugh.maw_range")+(v("nugh.maw_range_bonus") if phase_two else 0)
 return super.boss_range(action)
func boss_visible_index() -> int:return boss_index-1 if command_active else boss_index
func boss_display_action() -> String:return "Brood Command" if command_active else super.boss_display_action()
func boss_step_label() -> String:
 if command_active:return "Activate next worm (%d left) →" % brood_queue.size() if not brood_queue.is_empty() else "Finish Brood Command →"
 return super.boss_step_label()
func move_worm(id: int, steps: int) -> void:
 var origin: Vector2i = unit_data(id).pos
 var best := 100;var paths: Array = []
 var queue: Array = [[origin,[]]];var visited: Array = [origin]
 while not queue.is_empty():
  var item: Array = queue.pop_front();var at: Vector2i = item[0];var path: Array = item[1]
  var d := 100
  for hero in range(3):
   if heroes[hero].hp > 0 and not heroes[hero].dead:d = mini(d,distance(id,hero,at))
  if d < best:best = d;paths = [path]
  elif d == best:paths.append(path)
  if path.size() >= steps or d == 1:continue
  for dir in DIRS:
   var next: Vector2i = at+dir
   if next not in visited and legal(id,next):visited.append(next);queue.append([next,path+[next]])
 var shortest := 100
 for path in paths:shortest = mini(shortest,path.size())
 paths = paths.filter(func(path):return path.size() == shortest)
 if paths.is_empty():return
 var chosen: Array = paths[rng.randi_range(0,paths.size()-1)]
 if chosen.is_empty():return
 unit_data(id).pos = chosen.back()
 record_event("move","Brood Command: %s moves %s → %s." % [unit_name(id),cell_name(origin),cell_name(unit_data(id).pos)],id,id)
func worm_damage() -> int:return v("nugh.worm_damage")+(v("nugh.worm_damage_bonus") if phase_two else 0)
func activate_worm() -> void:
 while not brood_queue.is_empty() and unit_data(brood_queue[0]).dead:brood_queue.pop_front()
 if brood_queue.is_empty():command_active = false;last_boss_result = "Brood Command complete: every surviving worm activated once.";return
 var id: int = brood_queue.pop_front()
 action_owner = id;action_label = "Worm Bite";action_before = state_snapshot()
 move_worm(id,v("nugh.command_move")+(v("nugh.command_move_bonus") if phase_two else 0))
 var options := attack_targets(id,1)
 if options.is_empty():
  last_boss_result = "%s: moved / held; no adjacent hero to bite." % unit_name(id)
  record_event("minion_action",last_boss_result,id,id)
 else:
  var target := nearest_attacked(id,options);last_targets = [target]
  last_boss_result = "%s → %s: Bite %d. Reactions apply." % [unit_name(id),unit_name(target),worm_damage()]
  record_event("minion_action",last_boss_result,id,target)
  pending = {"kind":"attack","action":"Worm Bite","source":id,"range":1,"victims":[target],"reacted":[],"amount":worm_damage()}
  continue_attack()
 report_changes()
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if command_active:activate_worm();return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index]
 begin_action(3,action,-1,boss_index);boss_index += 1;last_action = action;last_targets.clear()
 last_boss_result = action+" resolved."
 match action:
  "Bound":last_boss_result = "Bound: Lethargic Bind suppresses this result.";note(last_boss_result)
  "Birth Cry":
   var spawned := spawn_worms(v("nugh.summon")+(v("nugh.summon_bonus") if phase_two else 0))
   last_boss_result = "Birth Cry: %d worms summoned (%d living)." % [spawned,living_minions().size()]
  "Brood Command":
   brood_queue = living_minions().duplicate()
   if brood_queue.is_empty():
    var spawned := spawn_worms(v("nugh.command_empty")+(v("nugh.summon_bonus") if phase_two else 0))
    last_boss_result = "Brood Command: no worms → summon %d. New worms wait for the next Command." % spawned
    record_event("minion_action",last_boss_result,3)
   else:
    command_active = true;record_event("minion_action","BROOD COMMAND: activate each of %d worms once. Move then bite; resolve Reactions between worms." % brood_queue.size(),3)
    activate_worm()
  "Burrow":
   var old: Vector2i = boss.pos
   if retreat(v("nugh.burrow_move")+(v("nugh.retreat_bonus") if phase_two else 0)):last_boss_result = "Burrow: RETREAT %s → %s." % [cell_name(old),cell_name(boss.pos)]
   else:boss.block += v("nugh.guard_block");last_boss_result = "Burrow: cornered; +%d Block." % v("nugh.guard_block")
   if phase_two:
    var spawned := spawn_worms(v("nugh.burrow_worms"),old);last_boss_result += " Leaves %d worm(s)." % spawned
   record_event("boss_result",last_boss_result,3)
  "Brood Guard":
   var value := v("nugh.guard_block")+mini(v("nugh.guard_worm_cap"),living_minions().size());boss.block += value
   last_boss_result = "Brood Guard: +%d Block." % value
   if phase_two and not living_minions().is_empty():
    var worm := unit_data(living_minions()[0]);worm.block = maxi(worm.block,v("nugh.guard_worm_block"));last_boss_result += " Shields %s (up to %d Block)." % [unit_name(living_minions()[0]),v("nugh.guard_worm_block")]
   record_event("block_gain",last_boss_result,3,3,value)
  "Devour Brood":
   var worms := living_minions()
   if worms.is_empty():
    var spawned := spawn_worms(v("nugh.command_empty"));last_boss_result = "Devour: no worms → summon %d." % spawned
   else:
    worms.sort_custom(func(a,b):return distance(3,a)<distance(3,b))
    var id: int = worms[0];unit_data(id).hp = 0;unit_data(id).dead = true
    record_event("minion_death","Nu’gh devours "+unit_name(id)+" (no Soul Link).",3,id)
    var restored := heal_boss(v("nugh.devour_heal")+(v("nugh.devour_heal_bonus") if phase_two else 0),"Devour Brood")
    last_boss_result = "Devour: consumes one worm; heals %d HP." % restored
    if phase_two:boss.block += v("nugh.devour_block");last_boss_result += " +%d Block." % v("nugh.devour_block")
  "Gnashing Maw":
   var options := targets(boss_range(action))
   if options.is_empty():fallback()
   else:
    var target := nearest(options);last_targets = [target]
    var amount := v("nugh.maw_damage")+pressure();last_boss_result = "Gnashing Maw → %s: %d damage before defenses." % [unit_name(target),amount]
    pending = {"kind":"attack","action":action,"victims":[target],"reacted":[],"amount":amount};continue_attack()
  _:fallback()
 report_changes()
func heal_boss(amount: int, source: String) -> int:
 var restored := mini(amount,boss.max_hp-boss.hp);boss.hp += restored
 record_event("heal","%s: Nu’gh heals %d HP → %d/%d." % [source,restored,boss.hp,boss.max_hp],3,3,restored)
 return restored
func check_phase() -> void:
 if phase_two or boss.hp <= 0 or boss.hp*100 > boss.max_hp*v("boss.phase.percent"):return
 phase_two = true
 record_event("phase","NU’GH — SEVERED BROOD. SOUL LINK BREAKS permanently: worm kills no longer hurt Nu’gh. Commands move worms farther; all abilities upgrade. Hunt the retreating master directly.",3)
func check_end() -> void:
 super.check_end()
 if outcome != "":brood_queue.clear();command_active = false
 if outcome == "victory":
  for worm in minions:worm.hp = 0;worm.dead = true
func default_boss_help(action: String) -> String:
 match action:
  "Birth Cry":return "Summon %d worms on empty cells within 2; cap %d living, %d HP each. Never on heroes, the boss or other worms." % [v("nugh.summon")+(v("nugh.summon_bonus") if phase_two else 0),v("nugh.worm_cap"),v("nugh.worm_hp")]
  "Brood Command":return "Each living worm moves up to %d toward the nearest standing hero, then bites an adjacent hero for %d. One activation per worm; Reactions apply between bites. No worms: summon %d instead; new worms wait for the next Command." % [v("nugh.command_move")+(v("nugh.command_move_bonus") if phase_two else 0),worm_damage(),v("nugh.command_empty")+(v("nugh.summon_bonus") if phase_two else 0)]
  "Gnashing Maw":return "Closest standing hero within %d: %d base + %d brood pressure damage. No target: RETREAT %d or gain %d Block if cornered." % [boss_range(action),v("nugh.maw_damage"),pressure(),v("nugh.fallback_move"),v("nugh.guard_block")]
  "Burrow":return "RETREAT up to %d cells to maximize distance from the nearest hero. No safer route: +%d Block." % [v("nugh.burrow_move")+(v("nugh.retreat_bonus") if phase_two else 0),v("nugh.guard_block")]+(" Also leave %d worm(s) near the old location." % v("nugh.burrow_worms") if phase_two else "")
  "Brood Guard":return "Gain %d Block + one per living worm, bonus capped at %d." % [v("nugh.guard_block"),v("nugh.guard_worm_cap")]+(" Also shield one worm with %d non-stacking Block." % v("nugh.guard_worm_block") if phase_two else "")
  "Devour Brood":return "Consume the nearest worm (no Soul Link); heal %d HP.%s No worms: summon %d." % [v("nugh.devour_heal")+(v("nugh.devour_heal_bonus") if phase_two else 0)," Gain %d Block." % v("nugh.devour_block") if phase_two else "",v("nugh.command_empty")]
  "Bound":return "Suppressed by Lethargic Bind."
 return "Resolve all pending worms, then the next boss die."
func phase_upgrades() -> Array:
 var command_upgrade := "Worm movement +%d; empty-brood summon +%d." % [v("nugh.command_move_bonus"),v("nugh.summon_bonus")]
 if v("nugh.worm_damage_bonus") > 0:command_upgrade += " Bite damage +%d." % v("nugh.worm_damage_bonus")
 var devour_upgrade := "Gain %d Block." % v("nugh.devour_block")
 if v("nugh.devour_heal_bonus") > 0:devour_upgrade += " Healing +%d." % v("nugh.devour_heal_bonus")
 return [["Birth Cry","Summon +%d worm(s); Soul Link switches OFF permanently." % v("nugh.summon_bonus")],["Brood Command",command_upgrade],["Gnashing Maw","Reach +%d; brood pressure cap +%d." % [v("nugh.maw_range_bonus"),v("nugh.pressure_bonus")]],["Burrow","Retreat +%d and leave %d worm(s)." % [v("nugh.retreat_bonus"),v("nugh.burrow_worms")]],["Brood Guard","Shield one worm with %d non-stacking Block." % v("nugh.guard_worm_block")],["Devour Brood",devour_upgrade]]
func turn_explanation() -> String:
 return "NU’GH: Brood Command makes worms move and attack. He retreats. "+("SOUL LINK OFF permanently: attack Nu’gh directly; clear worms to survive. " if phase_two else "Soul Link ON until half HP: hero worm kills deal %d to Nu’gh. " % v("nugh.link_damage"))+super.turn_explanation()
func status_description(id: int) -> String:
 var text := super.status_description(id)
 if id == 3:
  text = text.replace("Phase II: 3×3 Cinder Brand, Rooted Ashen Chain and Furnace Roar unlocked.","Severed Brood: Soul Link OFF; all Nu’gh abilities upgraded.")
  text += "\nLiving worms: %d/%d. Maw pressure: +%d.\nSoul Link: %s" % [living_minions().size(),v("nugh.worm_cap"),pressure(),"OFF permanently after half HP." if phase_two else "ON: hero kills deal %d to Nu’gh until half HP." % v("nugh.link_damage")]
 return text
func damage_minion(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 var alive: bool = not unit_data(id).dead
 super.damage_minion(id,amount,unavoidable,reason)
 if alive and unit_data(id).dead and not phase_two and action_owner in [0,1,2] and outcome == "":
  record_event("soul_link","Soul Link (phase I only): worm kill → %d unavoidable damage to Nu’gh." % v("nugh.link_damage"),action_owner,3,v("nugh.link_damage"))
  damage(3,v("nugh.link_damage"),true,"Brood Soul Link")
