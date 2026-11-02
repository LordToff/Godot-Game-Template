extends "res://prototype/battle.gd"
## Two ordinary one-cell monsters. Slot 3 shares existing enemy-turn controls.
var hard := false
const DICE = [["Scuttle","Scuttle","Bite","Bite","Guard","Bite"],["Scuttle","Bite","Guard","Bite","Scuttle","Bite"],["Bite","Guard","Scuttle","Bite","Guard","Scuttle"]]
func prepare_encounter() -> void:
 encounter_id = "event"
 boss.hp = 4 if hard else 3;boss.max_hp = boss.hp;boss.pos = Vector2i(3,4)
 minions.append({"name":boss_name()+" II","hp":boss.hp,"max_hp":boss.hp,"pos":Vector2i(5,4),"block":0,"dead":false,"faction":"enemy","weak":0,"rooted":0,"poison":0})
func boss_name() -> String:return "Cinder Mite" if hard else "Ash Scavenger"
func cells(id: int, at: Vector2i = Vector2i(-99,-99)) -> Array:
 return [at if at.x != -99 else unit_data(id).pos]
func boss_dice() -> Array:return DICE
func check_phase() -> void:pass
func phase_upgrades() -> Array:return []
func phase_description() -> String:return "Ordinary monsters: no phase transition, no boss Soul. Defeat both for the listed event reward."
func check_end() -> void:
 if atomic_damage:return
 if boss.hp <= 0:boss.dead = true
 if heroes.all(func(h):return h.dead or h.hp <= 0):outcome = "defeat"
 elif boss.hp <= 0 and living_minions().is_empty():outcome = "victory"
 if outcome != "":pending = {};note("Both monsters defeated. Claim the event completion reward." if outcome == "victory" else "Party defeated. No event reward.")
func damage_minion(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 super.damage_minion(id,amount,unavoidable,reason);check_end()
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index];boss_index += 1
 # Each monster gets the same public rolled result, one at a time; reactions remain available.
 queued_actions = []
 for id in [3]+living_minions():
  if unit_data(id).hp > 0:queued_actions.append({"id":id,"action":action})
 continue_monsters()
var queued_actions: Array = []
func continue_monsters():
 while not queued_actions.is_empty() and pending.is_empty() and outcome == "":
  var entry: Dictionary = queued_actions.pop_front();var id: int = entry.id;var action: String = entry.action
  if unit_data(id).hp <= 0:continue
  begin_action(id,action)
  if action == "Bound":note("Bound result: no action.");continue
  if action == "Guard":unit_data(id).block += 1;note(unit_name(id)+" gains 1 Block.");continue
  var target := nearest_attacked(id,attack_targets(id,99))
  if target < 0:continue
  if action == "Scuttle":
   if unit_data(id).get("rooted",0) <= 0:move_friendly_summon(id,2)
   note(unit_name(id)+" scuttles up to 2 cells.")
  elif action == "Bite" and distance(id,target) <= 1:
   pending = {"kind":"attack","action":"Scavenger Bite","victims":[target],"reacted":[],"amount":maxi(0,1-int(unit_data(id).get("weak",0))) if id >= 4 else 1,"source":id,"range":1,"area":false}
   continue_attack()
  else:note(unit_name(id)+" has no target in Bite reach 1; holds.")
 report_changes()
func react(use: bool, dir: Vector2i = Vector2i.ZERO) -> void:
 super.react(use,dir)
 if pending.is_empty():continue_monsters()
func activate() -> void:
 super.activate()
 if active == 3:
  for id in living_minions():
   tick_poison(id);unit_data(id).block = 0;unit_data(id).weak = 0;unit_data(id).rooted = 0
func default_boss_help(action: String) -> String:
 return "Each living monster: "+{"Scuttle":"move up to 2 orthogonal cells toward a hero. No attack.","Bite":"deal 1 normal damage to the closest adjacent hero or friendly summon; otherwise hold. Reactions apply. No Poison.","Guard":"gain 1 Block until the next enemy turn.","Bound":"no action."}.get(action,"no action.")

func summon_description(id: int) -> String:
 if friendly(id):return super.summon_description(id)
 return "Ordinary monster, not a summon. Shares the public enemy dice. 1-cell footprint; Bite 1, Scuttle 2, Guard 1. No Poison on bite, no phase. " + super.summon_description(id).replace("Enemy summon.","")
