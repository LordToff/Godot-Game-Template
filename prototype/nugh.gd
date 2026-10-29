extends "res://prototype/battle.gd"
const DICE = [["Birth Cry","Birth Cry","Burrow","Gnashing Maw","Brood Guard","Devour Brood"],["Birth Cry","Screaming Chorus","Screaming Chorus","Gnashing Maw","Burrow","Brood Guard"],["Screaming Chorus","Gnashing Maw","Birth Cry","Brood Guard","Burrow","Devour Brood"]]
func boss_name() -> String:return "Nu’gh"
func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true, profile: Dictionary = {}) -> void:
 encounter_id = "nugh"
 super.start(builds,seed_value,soul,balanced,profile)
 boss.hp = v("nugh.hp");boss.max_hp = boss.hp
 spawn_worms(v("nugh.initial_worms"))
 record_event("guide","Nu’gh starts with his brood. Screaming worms add damage to his attacks and feed his defenses. Kill them to lower pressure and hurt Nu’gh through Soul Link; kill Nu’gh to win.",3)
func boss_dice() -> Array:return DICE.duplicate(true)
func pressure() -> int:return mini(v("nugh.pressure_cap")+(v("nugh.pressure_bonus") if phase_two else 0),living_minions().size())
func spawn_worms(count: int, origin: Vector2i = Vector2i(-99,-99)) -> int:
 var spawned := 0
 for index in range(count):
  if living_minions().size() >= v("nugh.worm_cap"):break
  var candidates: Array = []
  for x in range(9):
   for y in range(9):
    var cell := Vector2i(x,y)
    if not legal(0,cell):continue
    var d := distance(0,3,cell) if origin.x == -99 else absi(cell.x-origin.x)+absi(cell.y-origin.y)
    if d <= 2:candidates.append(cell)
  if candidates.is_empty():break
  # Prefer the brood's front; ties are deterministic under the encounter seed.
  candidates.sort_custom(func(a,b):return a.y > b.y)
  var pool: Array = candidates.filter(func(c):return c.y == candidates[0].y)
  var pos: Vector2i = pool[rng.randi_range(0,pool.size()-1)]
  var hp := v("nugh.worm_hp")
  minions.append({"name":"Screaming Worm %d" % (minions.size()+1),"hp":hp,"max_hp":hp,"block":0,"dead":false,"pos":pos})
  record_event("summon","Nu’gh summons %s at %s (%d HP). Worm pressure is now +%d attack damage." % [unit_name(unit_count()-1),cell_name(pos),hp,pressure()],3,unit_count()-1)
  spawned += 1
 if spawned < count:record_event("info","Brood limit or occupied cells prevented %d summon(s); existing worms stay." % (count-spawned),3)
 return spawned
func boss_range(action: String) -> int:
 if action == "Screaming Chorus":return v("nugh.chorus_range")
 if action == "Gnashing Maw":return v("nugh.maw_range")+(v("nugh.maw_range_bonus") if phase_two else 0)
 return super.boss_range(action)
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index]
 begin_action(3,action,-1,boss_index);boss_index += 1;last_action = action;last_targets.clear()
 match action:
  "Bound":note("Lethargic Bind suppresses this result.")
  "Birth Cry":spawn_worms(v("nugh.summon")+(v("nugh.summon_bonus") if phase_two else 0))
  "Burrow":
   var old: Vector2i = boss.pos
   if not boss_move(v("nugh.burrow_move")):boss.block += v("nugh.guard_block")
   if phase_two:spawn_worms(v("nugh.burrow_worms"),old)
  "Brood Guard":
   var count := living_minions().size()
   var value := v("nugh.guard_block")+mini(v("nugh.guard_worm_cap"),count)
   boss.block += value
   record_event("block_gain","Brood Guard: Nu’gh gains %d Block (%d worms)." % [value,count],3,3,value)
   if phase_two and count > 0:
    var worm := unit_data(living_minions()[0]);worm.block = maxi(worm.block,v("nugh.guard_worm_block"))
    record_event("block_gain","Upgraded Brood Guard shields one worm; this protection does not stack.",3,living_minions()[0],v("nugh.guard_worm_block"))
  "Devour Brood":
   var worms := living_minions()
   if worms.is_empty():spawn_worms(v("nugh.summon"))
   else:
    worms.sort_custom(func(a,b):return distance(3,a)<distance(3,b))
    var id: int = worms[0];unit_data(id).hp = 0;unit_data(id).dead = true
    record_event("minion_death","Nu’gh devours "+unit_name(id)+". Worm pressure drops to +%d." % pressure(),3,id)
    heal_boss(v("nugh.devour_heal")+(v("nugh.devour_heal_bonus") if phase_two else 0),"Devour Brood")
    if phase_two:boss.block += v("nugh.devour_block")
  "Screaming Chorus","Gnashing Maw":
   var ts := targets(boss_range(action))
   if ts.is_empty():
    if not boss_move(v("nugh.burrow_move")):boss.block += v("nugh.guard_block")
   else:
    var target := nearest(ts);last_targets = [target]
    var base := v("nugh.chorus_damage") if action == "Screaming Chorus" else v("nugh.maw_damage")
    var bonus := pressure()
    record_event("guide","%s: base %d + %d worm pressure. Killing worms reduces future attacks." % [action,base,bonus],3,target)
    if action == "Screaming Chorus" and bonus > 0:
     var spent: int = living_minions()[0];unit_data(spent).hp = 0;unit_data(spent).dead = true
     record_event("minion_death","Screaming Chorus spends "+unit_name(spent)+" for this attack. The declared damage keeps its bonus; future worm pressure is +%d." % pressure(),3,spent)
    pending = {"kind":"attack","action":action,"victims":[target],"reacted":[],"amount":base+bonus}
    continue_attack()
 report_changes()
func heal_boss(amount: int, source: String) -> void:
 var restored := mini(amount,boss.max_hp-boss.hp);boss.hp += restored
 record_event("heal","%s: Nu’gh heals %d HP → %d/%d." % [source,restored,boss.hp,boss.max_hp],3,3,restored)
func check_phase() -> void:
 if phase_two or boss.hp <= 0 or boss.hp*100 > boss.max_hp*v("boss.phase.percent"):return
 phase_two = true
 record_event("phase","NU’GH — BROOD FRENZY. Every ability upgrades: more summons, stronger worm pressure, longer Maw reach, Burrow spawns, Guard shields a worm and Devour restores more HP. Kill worms to stop the bonuses.",3)
func check_end() -> void:
 super.check_end()
 if outcome == "victory":
  for worm in minions:worm.hp = 0;worm.dead = true
func default_boss_help(action: String) -> String:
 var add := "\n\nCurrent worm bonus: +%d. Kill worms to lower it." % pressure()
 match action:
  "Birth Cry":return "Summon %d screaming worm(s), up to %d living. Each has %d HP and occupies a cell." % [v("nugh.summon")+(v("nugh.summon_bonus") if phase_two else 0),v("nugh.worm_cap"),v("nugh.worm_hp")]+add
  "Screaming Chorus":return "Attack the closest standing hero within %d for %d base + %d worm pressure damage." % [boss_range(action),v("nugh.chorus_damage"),pressure()]+" Screaming Chorus spends one worm when empowered."+add
  "Gnashing Maw":return "Attack the closest standing hero within %d for %d base + %d worm pressure damage." % [boss_range(action),v("nugh.maw_damage"),pressure()]+add
  "Burrow":return "Move up to %d toward the closest hero. No route: gain %d Block." % [v("nugh.burrow_move"),v("nugh.guard_block")]+(" Leave %d worm(s) near the old location." % v("nugh.burrow_worms") if phase_two else "")
  "Brood Guard":return "Gain %d Block + one per living worm, worm bonus capped at %d." % [v("nugh.guard_block"),v("nugh.guard_worm_cap")]+(" Shield one living worm with %d Block (does not stack)." % v("nugh.guard_worm_block") if phase_two else "")
  "Devour Brood":return "Consume the nearest worm and heal %d HP.%s No worms: summon %d instead." % [v("nugh.devour_heal")+(v("nugh.devour_heal_bonus") if phase_two else 0)," Gain %d Block." % v("nugh.devour_block") if phase_two else "",v("nugh.summon")]
  "Bound":return "This result is suppressed by Lethargic Bind."
 return "End Nu’gh’s turn after all three dice."
func phase_upgrades() -> Array:
 return [["Birth Cry","Summon +%d worm(s)." % v("nugh.summon_bonus")],["Screaming Chorus","Maximum worm bonus damage +%d." % v("nugh.pressure_bonus")],["Gnashing Maw","Reach +%d; also uses the stronger worm pressure." % v("nugh.maw_range_bonus")],["Burrow","Also summon %d worm(s) near the old location." % v("nugh.burrow_worms")],["Brood Guard","Shield one worm with %d non-stacking Block." % v("nugh.guard_worm_block")],["Devour Brood","Healing +%d and gain %d Block." % [v("nugh.devour_heal_bonus"),v("nugh.devour_block")]]]
func turn_explanation() -> String:
 return "NU’GH: kill the summoner to win. Living worms add damage (up to +%d at this phase). Kill them to reduce damage, deny healing / defenses and deal %d Soul Link damage to Nu’gh. They block cells and sight but have no separate attack turn. " % [v("nugh.pressure_cap")+(v("nugh.pressure_bonus") if phase_two else 0),v("nugh.link_damage")]+super.turn_explanation()

func status_description(id: int) -> String:
 var text := super.status_description(id)
 if id == 3:
  text = text.replace("Phase II: 3×3 Cinder Brand, Rooted Ashen Chain and Furnace Roar unlocked.","Brood Frenzy: all six Nu’gh abilities are upgraded.")
  text += "\nLiving worms: %d/%d. Attack damage bonus: +%d.\nSoul Link: hero kills deal %d damage to Nu’gh." % [living_minions().size(),v("nugh.worm_cap"),pressure(),v("nugh.link_damage")]
 return text

func damage_minion(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 var alive: bool = not unit_data(id).dead
 super.damage_minion(id,amount,unavoidable,reason)
 if alive and unit_data(id).dead and action_owner in [0,1,2] and outcome == "":
  record_event("soul_link","Brood Soul Link: killing a worm deals %d unavoidable damage to Nu’gh." % v("nugh.link_damage"),action_owner,3,v("nugh.link_damage"))
  damage(3,v("nugh.link_damage"),true,"Brood Soul Link")
