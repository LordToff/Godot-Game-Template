extends "res://prototype/battle.gd"
const DICE = [["Gathering Note","Gathering Note","Tuning Fork","Seal the Bell","Hushed Chime","Crescendo"],["Hushed Chime","Tuning Fork","Toll of Reckoning","Seal the Bell","Gathering Note","Hushed Chime"],["Toll of Reckoning","Hushed Chime","Tuning Fork","Toll of Reckoning","Seal the Bell","Crescendo"]]
var resonance := 0
var core_open := false
var suppress_resonance := false
func boss_name() -> String:return "Veyl, the Brass Cantor"
func unit_name(id: int) -> String:return "Veyl" if id == 3 else super.unit_name(id)
func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true, profile: Dictionary = {}) -> void:
 encounter_id = "cantor";resonance = 0;core_open = false;suppress_resonance = false
 super.start(builds,seed_value,soul,balanced,profile)
func prepare_encounter() -> void:
 boss.hp = v("cantor.hp");boss.max_hp = boss.hp
 record_event("guide","VEYL — BRASS CANTOR: your resolved Attack faces raise Resonance; Skill / Defense faces calm it. Movement and Blanks do neither. Toll spends the meter on an area attack. Crescendo opens the core: burst now, but build the next Toll. No summons or terrain hazards.",3)
func boss_dice() -> Array:return DICE.duplicate(true)
func change_resonance(delta: int, reason: String, owner: int = 3) -> void:
 var before := resonance;resonance = clampi(resonance+delta,0,v("cantor.resonance_cap"))
 record_event("resonance","%s: Resonance %d → %d/%d (%+d)." % [reason,before,resonance,v("cantor.resonance_cap"),resonance-before],owner,3,resonance-before)
func spend(d: int, store_smoke: bool = false) -> void:
 var id := active
 var was_used: bool = heroes[id].used[d]
 var category: String = Catalog.category(face(id,d))
 var name: String = FACES[face(id,d)]
 super.spend(d,store_smoke)
 if was_used or suppress_resonance or outcome != "":return
 if category == "Attack":change_resonance(v("cantor.attack_charge"),unit_name(id)+" resolves "+name,id)
 elif category in ["Defense","Skill"]:change_resonance(-v("cantor.calm"),unit_name(id)+" resolves "+name,id)
func decline(d: int) -> void:
 suppress_resonance = true;super.decline(d);suppress_resonance = false
func activate() -> void:
 if cursor < order.size() and order[cursor] == 3 and core_open:
  core_open = false;record_event("expire","Veyl’s exposed core closes at boss turn start.",3)
 super.activate()
func core_bonus() -> int:return v("cantor.core_bonus")+(v("cantor.core_bonus_phase") if phase_two else 0)
func attack_bonus(target: int) -> int:
 var bonus := core_bonus() if core_open and target == 3 else 0
 if bonus > 0:record_event("core","OPEN CORE: %s gains +%d damage on this Attack hit." % [unit_name(active),bonus],active,3,bonus)
 return bonus
func boss_range(action: String) -> int:
 if action == "Toll of Reckoning":return v("cantor.toll_range")+(v("cantor.toll_range_phase") if phase_two else 0)
 if action == "Hushed Chime":return v("cantor.chime_range")+(v("cantor.chime_range_phase") if phase_two else 0)
 if action == "Tuning Fork":return v("cantor.fork_range")
 return super.boss_range(action)
func toll_damage() -> int:return v("cantor.toll_base")+int(resonance/maxi(1,v("cantor.toll_divisor")))
func chime_damage() -> int:return v("cantor.chime_base")+int(resonance/maxi(1,v("cantor.chime_divisor")))
func fallback() -> void:
 var origin: Vector2i = boss.pos
 if boss_move(v("cantor.fallback_move")):last_boss_result = "%s → FALLBACK: Veyl advances %s → %s." % [action_label,cell_name(origin),cell_name(boss.pos)]
 else:boss.block += v("cantor.fallback_block");last_boss_result = "%s → FALLBACK: holds; +%d Block." % [action_label,v("cantor.fallback_block")]
 record_event("fallback",last_boss_result,3,3)
func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty():return
 if boss_index >= 3:finish_turn();return
 var action: String = boss_rolls[boss_index]
 begin_action(3,action,-1,boss_index);boss_index += 1;last_action = action;last_targets.clear();last_boss_result = action+" resolved."
 match action:
  "Bound":last_boss_result = "Bound: this die is suppressed.";note(last_boss_result)
  "Gathering Note":
   change_resonance(v("cantor.gather")+(v("cantor.gather_phase") if phase_two else 0),action)
   last_boss_result = "Gathering Note: Resonance now %d/%d." % [resonance,v("cantor.resonance_cap")]
  "Crescendo":
   change_resonance(v("cantor.crescendo")+(v("cantor.crescendo_phase") if phase_two else 0),action)
   core_open = true;last_boss_result = "Crescendo: CORE OPEN until next boss turn. Hero Attacks gain +%d per hit; Resonance %d." % [core_bonus(),resonance]
   record_event("core",last_boss_result,3)
  "Seal the Bell":
   var value := v("cantor.seal_block")+(v("cantor.seal_phase") if phase_two else 0);boss.block += value
   last_boss_result = "Seal the Bell: +%d Block. An already open core stays exposed." % value
   record_event("block_gain",last_boss_result,3,3,value)
  "Toll of Reckoning":
   var options := targets(boss_range(action))
   if options.is_empty():fallback()
   else:
    var amount := toll_damage();last_targets = options.duplicate();change_resonance(-resonance,"Toll spends all Resonance")
    last_boss_result = "TOLL: %d damage to each of %d heroes in reach %d. Meter emptied; Reactions apply." % [amount,options.size(),boss_range(action)]
    record_event("guide",last_boss_result,3)
    pending = {"kind":"attack","action":action,"area":true,"victims":options,"reacted":[],"amount":amount};continue_attack()
  "Hushed Chime":
   var options := targets(boss_range(action))
   if options.is_empty():fallback()
   else:
    var target := nearest(options);var amount := chime_damage();last_targets = [target]
    change_resonance(-v("cantor.chime_spend"),"Hushed Chime spends Resonance")
    pending = {"kind":"attack","action":action,"victims":[target],"reacted":[],"amount":amount};continue_attack()
  "Tuning Fork":
   boss_move(v("cantor.fork_move")+(v("cantor.fork_move_phase") if phase_two else 0))
   var options := targets(boss_range(action))
   if options.is_empty():fallback()
   else:
    var target := nearest(options);last_targets = [target]
    pending = {"kind":"attack","action":action,"victims":[target],"reacted":[],"amount":v("cantor.fork_damage")+(v("cantor.fork_damage_phase") if phase_two else 0)};continue_attack()
  _:fallback()
 report_changes()
func check_phase() -> void:
 if phase_two or boss.hp <= 0 or boss.hp*100 > boss.max_hp*v("boss.phase.percent"):return
 phase_two = true
 record_event("phase","VEYL — GRAND PEAL. Every ability upgrades. Toll and Chime reach farther; Fork moves farther; seals grow stronger. Crescendo gathers more Resonance but opens a +%d damage core." % core_bonus(),3)
func default_boss_help(action: String) -> String:
 match action:
  "Gathering Note":return "Gain %d Resonance, up to %d. No immediate damage. Your own-turn Skills and Defenses calm it before the next boss turn." % [v("cantor.gather")+(v("cantor.gather_phase") if phase_two else 0),v("cantor.resonance_cap")]
  "Crescendo":return "Gain %d Resonance and OPEN THE CORE until next boss turn. Hero Attacks against Veyl gain +%d per hit before Block. Burst now or calm the next Toll." % [v("cantor.crescendo")+(v("cantor.crescendo_phase") if phase_two else 0),core_bonus()]
  "Seal the Bell":return "Gain %d Block. Old Block expires next boss turn; this does not close an open core." % [v("cantor.seal_block")+(v("cantor.seal_phase") if phase_two else 0)]
  "Toll of Reckoning":return "Attack EVERY standing hero within %d for %d NOW: %d base + 1 per %d Resonance. Spend the entire meter when declared. Reactions apply; the declared hit is fixed. No targets: fallback, keep meter." % [boss_range(action),toll_damage(),v("cantor.toll_base"),v("cantor.toll_divisor")]
  "Hushed Chime":return "Closest standing hero within %d: %d damage NOW (%d base + 1 per %d Resonance). Spend up to %d Resonance when declared. No target: fallback, keep meter." % [boss_range(action),chime_damage(),v("cantor.chime_base"),v("cantor.chime_divisor"),v("cantor.chime_spend")]
  "Tuning Fork":return "Advance up to %d, then attack within %d for %d. Reactions apply. No reachable target: fallback advance / Block." % [v("cantor.fork_move")+(v("cantor.fork_move_phase") if phase_two else 0),boss_range(action),v("cantor.fork_damage")+(v("cantor.fork_damage_phase") if phase_two else 0)]
  "Bound":return "Lethargic Bind suppresses this result."
 return "Resolve I → II → III, then end the boss turn."
func phase_upgrades() -> Array:
 return [["Gathering Note","Resonance gain +%d." % v("cantor.gather_phase")],["Crescendo","Resonance gain +%d; exposed-core Attack bonus +%d." % [v("cantor.crescendo_phase"),v("cantor.core_bonus_phase")]],["Seal the Bell","Block +%d." % v("cantor.seal_phase")],["Toll of Reckoning","Reach +%d." % v("cantor.toll_range_phase")],["Hushed Chime","Reach +%d." % v("cantor.chime_range_phase")],["Tuning Fork","Movement +%d." % v("cantor.fork_move_phase")]]
func turn_explanation() -> String:
 return "BRASS CANTOR: Attack faces +%d Resonance; own-turn Skill / Defense faces −%d. Movement, Blanks, declines and held Reactions do not change it. Toll spends the meter; open-core Attacks gain extra damage. " % [v("cantor.attack_charge"),v("cantor.calm")]+super.turn_explanation()
func status_description(id: int) -> String:
 var text := super.status_description(id)
 if id == 3:
  text = text.replace("Phase II: 3×3 Cinder Brand, Rooted Ashen Chain and Furnace Roar unlocked.","Grand Peal: all six Cantor abilities upgraded.")
  text += "\nResonance %d/%d. Toll damage now %d. Chime damage now %d.\nCore: %s" % [resonance,v("cantor.resonance_cap"),toll_damage(),chime_damage(),"OPEN: hero Attack hits +%d until next boss turn." % core_bonus() if core_open else "closed."]
 return text
