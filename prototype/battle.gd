class_name AshBattle
extends RefCounted

const Balance = preload("res://prototype/balance.gd")
var balance: Dictionary = {}
const Catalog = preload("res://prototype/catalog.gd")
static var FACES: Array = make_face_names()

static func make_face_names() -> Array:
 var names: Array = []
 for id in range(59): names.append(Catalog.name_for(id))
 return names
const CAPS = [18, 4, 2, 1, 2, 1, 1, 1, 1]
const BOSS_DICE = [["Advance","Advance","Smoking Strike","Smoking Strike","Brace","Drive Back"], ["Advance","Skirmish","Smoking Strike","Sweep","Brace","Distort"], ["Advance","Skirmish","Smoking Strike","Sweep","Drive Back","Fracture"]]
const TUNED_BOSS_DICE = [["Advance","Ashen Chain","Smoking Strike","Smoking Strike","Brace","Drive Back"], ["Skirmish","Cinder Brand","Smoking Strike","Sweep","Grave Tithe","Distort"], ["Advance","Skirmish","Cinder Brand","Sweep","Drive Back","Fracture"]]
const DIRS = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
var rng := RandomNumberGenerator.new()
var heroes: Array = []
var boss: Dictionary
var order: Array = []
var cursor := 0
var active := -1
var round_no := 0
var boss_index := 0
var boss_rolls: Array = []
var pending: Dictionary = {}
var recovery: Array = []
var replaced: Array = []
var log_lines: Array[String] = []
var outcome := ""
var reward := false
var recovery_active := false
var forced_die := -1
var stun_queue: Array = []
var tuned := true
var roll_serial := 0
var roll_context := "Shared roll"
var last_action := ""
var last_targets: Array = []
var event_log: Array = []
var event_id := 0
var action_owner := -1
var action_label := ""
var action_before: Dictionary = {}
var atomic_damage := false
var initial_builds: Array = []
var brand_cells: Array = []
var fire_tiles: Array = []
var boss_sides: Array = []
var roll_presentations: Array = []
var initiative_base: Array = []
var minions: Array = []
var encounter_id := "hollow"
var last_boss_result := ""
var phase_two := false
var roar_queued := false

static func default_build(profile: Dictionary = {}) -> Array:
 var result: Array = [[1,2,4,1,0,0], [1,3,5,2,0,0], [1,7,6,4,0,0]]
 var counts := {}
 var categories := {"Movement":0,"Defense":0,"Skill":0}
 for die in result:
  for side in range(6):
   var f: int = die[side]
   if f == 0:continue
   var category: String = Catalog.category(f)
   if int(counts.get(f,0)) >= Balance.value(profile,"owned."+str(f)) or (categories.has(category) and categories[category] >= Balance.value(profile,"body."+category)):
    die[side] = 0;continue
   counts[f] = int(counts.get(f,0))+1
   if categories.has(category):categories[category] += 1
  for side in range(5,-1,-1):
   if die.count(0) >= Balance.value(profile,"body.blanks"):break
   die[side] = 0
 return result

static func validate(build: Array, gift: Variant = -1, profile: Dictionary = {}) -> String:
 if build.size() != 3:return "A loadout must contain exactly three dice."
 var owned: Array = []
 if gift is Array:owned = gift
 elif gift is int and gift >= 0:owned = [gift]
 elif not (gift is int and gift == -1):return "Owned designs must be valid face numbers."
 var canonical_owned: Array = []
 for id in owned:
  if not valid_face_number(id):return "Owned designs must be whole face numbers from 0 to 58."
  canonical_owned.append(int(id))
 owned = canonical_owned
 var counts := []
 counts.resize(59);counts.fill(0)
 for die in build:
  if not die is Array or die.size() != 6:return "Every die must have exactly six faces."
  var blanks := 0
  for f in die:
   if not valid_face_number(f):return "Each die face must be a whole number from 0 to 58."
   counts[int(f)] += 1
   if int(f) == 0:blanks += 1
  if blanks < Balance.value(profile,"body.blanks"):return "Every six-sided die needs at least %d Blanks." % Balance.value(profile,"body.blanks")
 for i in range(1,9):
  if counts[i] > Balance.value(profile,"owned."+str(i)) + (Balance.value(profile,"owned.bonus") if i in owned else 0): return "Not enough owned copies of " + FACES[i] + "."
 for i in range(9,59):
  if counts[i] > (Balance.value(profile,"owned.bonus") if i in owned else 0): return "Only owned bonus faces may be equipped."
 var totals := {"Movement":0,"Defense":0,"Skill":0}
 for id in range(1,59):
  var cat: String = Catalog.category(id)
  if totals.has(cat): totals[cat] += counts[id]
 if totals.Movement > Balance.value(profile,"body.Movement") or totals.Defense > Balance.value(profile,"body.Defense") or totals.Skill > Balance.value(profile,"body.Skill"):
  return "Body caps: Movement %d, Defense %d, Skill %d." % [Balance.value(profile,"body.Movement"),Balance.value(profile,"body.Defense"),Balance.value(profile,"body.Skill")]
 return ""

func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true, profile: Dictionary = {}) -> void:
 balance = profile.duplicate(true)
 phase_two = false; roar_queued = false;minions.clear();last_boss_result = ""
 rng.randomize()
 if seed_value: rng.seed = seed_value
 initial_builds = builds.duplicate(true); brand_cells.clear();fire_tiles.clear(); roll_presentations.clear()
 reward = soul
 tuned = balanced
 roll_serial = 0
 last_action = ""
 last_targets.clear()
 heroes.clear(); order.clear(); log_lines.clear(); event_log.clear(); event_id = 0; action_owner = -1; action_label = ""; action_before = {}; recovery.clear(); replaced.clear()
 pending = {}; outcome = ""; atomic_damage = false; forced_die = -1; stun_queue.clear(); cursor = 0; round_no = 0; recovery_active = false
 for i in range(3):
  heroes.append({"name":["VESPER","ROOK","WREN"][i], "hp":v("hero.hp"),"max_hp":v("hero.hp"),"block":0,"pos":Vector2i(2+i*2,7),"dead":false,"broken":false,"protected":false,"weak":false,"stun":false,"setaside":-1,"build":builds[i].duplicate(true),"rolls":[],"results":[],"used":[],"reaction":[],"initiative":rng.randi_range(v("initiative.min"),v("initiative.max")),"rerolls":mini(v("hero.rerolls"),v("hero.reroll_cap")),"opening":true,"soul_move_used":false,"soul_moves_used":0,"channel":{},"taken":0,"dr":0,"ward":false,"num_boost":0,"numeric_focus":false,"numeric_zero":false,"bulwark_weak":false,"stored_num":-1,"gambler":false,"gold":0,"backstab":0,"debt_buff":0,"debt_next":0,"debt_penalty":0,"echo_due":false,"defy":false,"black_oath":false,"smoke":{},"mods":{},"blessings":0,"mutations":0,"engrave_growth":0,"rooted":0})
  order.append(i)
 boss = {"hp":v("boss.hp"),"max_hp":v("boss.hp"),"block":0,"mark":false,"bargain":{},"weak":false,"binds":[],"pos":Vector2i(3,3),"initiative":rng.randi_range(v("initiative.min"),v("initiative.max"))}
 order.append(3)
 order.sort_custom(func(a,b):
  var av: int = boss.initiative if a == 3 else heroes[a].initiative
  var bv: int = boss.initiative if b == 3 else heroes[b].initiative
  return false if a == b else (av > bv if av != bv else (a == 3 or (b != 3 and a < b))))
 initiative_base = order.duplicate()
 prepare_encounter()
 note("The dice remember. Initiative is fixed for this encounter.")
 new_round()

func prepare_encounter() -> void:pass

func unit_name(id: int) -> String:
 if id == 3: return boss_name()
 if id >= 4 and id < unit_count():return unit_data(id).name
 if id in [0,1,2] and heroes.size() == 3: return heroes[id].name.capitalize()
 return "Battle"

func record_event(kind: String, text: String, source: int = -1, target: int = -1, value: int = 0) -> void:
 event_id += 1
 event_log.append({"id":event_id,"round":round_no,"kind":kind,"text":text,"source":source,"target":target,"value":value,"action":action_label})
 log_lines.append("R%02d  %s" % [round_no,text])
 if event_log.size() > 2000: event_log.pop_front()
 if log_lines.size() > 2000: log_lines.pop_front()

func note(text: String) -> void:
 record_event("info",text,action_owner)

func begin_action(owner: int, label: String, target: int = -1, die: int = -1) -> void:
 action_owner = owner; action_label = label
 action_before = state_snapshot()
 var text := unit_name(owner) + " declares " + label
 if target >= 0: text += " on " + unit_name(target)
 if die >= 0: text += " (Die " + ["I","II","III"][die] + ")"
 record_event("action",text+".",owner,target)

func state_snapshot() -> Dictionary:
 var result := {}
 if heroes.size() != 3: return result
 for id in range(4):
  var h: Dictionary = boss if id == 3 else heroes[id]
  result[id] = {"block":h.block,"pos":h.pos,"statuses":status_map(id)}
 return result

func status_map(id: int) -> Dictionary:
 var h: Dictionary = boss if id == 3 else heroes[id]
 var result := {"Weakness":h.weak}
 if id < 3:
  result["Weakness"] = h.weak or h.bulwark_weak
  result["Damage Reduction"] = h.dr > 0
  result["Wither Ward"] = h.ward
  result["Numeric Power"] = h.num_boost > 0
  result["Numeric Focus"] = h.numeric_focus
  result["Backstab"] = h.backstab >= round_no and h.backstab > 0
  result["Debt Boost"] = h.debt_buff > 0
  result["Debt Penalty"] = h.debt_penalty > 0
  result["Channel"] = not h.channel.is_empty()
  result["Stunned"] = h.stun
  result["Rooted"] = h.get("rooted",0) > 0
  result["Broken"] = h.broken
  result["Gambler Armed"] = h.gambler
  result["Stored Numeric"] = h.stored_num >= 0
  result["Debt Owed"] = h.debt_next > 0
  result["Black Oath"] = h.black_oath
  result["Echo Backlash"] = h.echo_due
  result["Defy Death"] = h.defy
 else:
  result["Marked"] = h.mark
  result["Blood Bargain"] = not h.bargain.is_empty()
 return result

func report_changes() -> void:
 if action_before.is_empty(): return
 var previous: Dictionary = action_before; action_before = {}
 for id in range(4):
  var h: Dictionary = boss if id == 3 else heroes[id]
  var old: Dictionary = previous[id]
  var gained: int = h.block-old.block
  if gained > 0:
   record_event("block_gain","%s: %s gains %d Block → %d total." % [action_label,unit_name(id),gained,h.block],action_owner,id,gained)
  if h.pos != old.pos:
   record_event("move","%s: %s moves %s → %s." % [action_label,unit_name(id),cell_name(old.pos),cell_name(h.pos)],action_owner,id)
  var now: Dictionary = status_map(id)
  for status in now:
   if now[status] and not old.statuses.get(status,false):
    var harmful: bool = status in ["Weakness","Marked","Debt Penalty","Stunned","Broken","Rooted"]
    var description: String = status
    if status == "Weakness":description += " %d (Attacks deal %d less damage)" % [hero_weakness(h) if id < 3 else v("face51.weakness"),hero_weakness(h) if id < 3 else v("face51.weakness")]
    if status == "Damage Reduction":description += " %d (after Block)" % h.dr
    if status == "Backstab":description = "Weak Point READY (next rear Attack repeats)"
    if status == "Numeric Power": description += " +"+str(h.num_boost)+" for the next Numeric damage this turn"
    if status == "Debt Boost":description += " +%d on the next Attack/Defense this turn" % h.debt_buff
    if status == "Debt Penalty":description += " −%d on the next Attack/Defense" % h.debt_penalty
    if status == "Channel" and id < 3: description += " ("+FACES[h.channel.face]+")"
    if status == "Rooted" and id < 3:description += " %d (no voluntary movement until next boss turn)" % h.rooted
    record_event("debuff" if harmful else "buff","%s: %s gains %s." % [action_label,unit_name(id),description],action_owner,id)
   elif not now[status] and old.statuses.get(status,false):
    record_event("expire","%s loses %s." % [unit_name(id),status],action_owner,id)

static func cell_name(p: Vector2i) -> String:
 return char(65+p.y)+str(p.x+1)

func new_round() -> void:
 action_owner = -1; action_label = "Round preparation"; action_before = {}
 round_no += 1; cursor = 0; replaced.clear()
 if not initiative_base.is_empty(): order = initiative_base.duplicate()
 boss.mark = false
 stun_queue.clear()
 for i in range(3):
  heroes[i].reaction.clear()
  heroes[i].setaside = -1
  if heroes[i].stun and heroes[i].hp > 0 and not heroes[i].dead: stun_queue.append(i)
 if not stun_queue.is_empty():
  pending = {"kind":"preroll_stun","hero":stun_queue.pop_front()}
  return
 shared_roll()

func shared_roll() -> void:
 roll_context = "Heroes and boss · shared roll"
 roll_serial += 1
 for h in heroes:
  h.reaction.clear()
  if h.hp > 0 and not h.dead: roll_hero(h)
 boss_rolls.clear(); boss_sides.clear()
 for index in range(3):
  var side := rng.randi_range(0,5)
  boss_sides.append(side)
  var action: String = boss_dice()[index][side]
  for bind in boss.binds:
   if bind.die == index and bind.action == action:
    action = "Bound"; damage(bind.owner,v("face18.backlash")); break
  boss_rolls.append(action)
 if roar_queued:
  boss_rolls[0] = "Furnace Roar";boss_sides[0] = 4;roar_queued = false
 for id in range(3):
  var h: Dictionary = heroes[id]
  if h.hp <= 0 or h.dead: continue
  var dice: Array = []
  for d in range(3):
   if d != h.setaside and (h.channel.is_empty() or h.channel.die != d): dice.append(d)
  present_action_roll(id,dice,"Shared roll")
 roll_presentations.append({"actor":boss_name(),"kind":"Shared roll","faces":boss_dice().duplicate(true),"sides":boss_sides.duplicate(),"results":boss_rolls.duplicate(),"dice":[0,1,2]})
 record_event("round","Round %d begins. All available Action Dice roll together." % round_no)
 for id in range(3):
  if heroes[id].hp <= 0 or heroes[id].dead: continue
  var values: Array[String] = []
  for d in range(3): values.append(["I","II","III"][d]+": "+FACES[face(id,d)]+(" [held]" if heroes[id].used[d] else ""))
  record_event("roll",unit_name(id)+" rolls "+" · ".join(values)+".",id)
 record_event("roll","%s rolls I: %s · II: %s · III: %s." % ([boss_name()]+boss_rolls),3)
 activate()

func roll_hero(h: Dictionary) -> void:
 var previous: Array = h.rolls.duplicate()
 h.rolls = []; h.results = []; h.used = []; h.reaction = []; h.taken = 0; h.mods = {}; h.smoke = {}
 h.num_boost = 0; h.numeric_focus = false
 if not h.channel.is_empty() and h.channel.face == 25:
  h.channel.boost = 0; h.channel.confirmed = false; h.channel.pending_blank = 0; h.channel.pending_boost = 0
 for d in range(3):
  var kept: bool = not h.channel.is_empty() and h.channel.die == d
  var side: int = previous[d] if kept and previous.size() == 3 else rng.randi_range(0,5)
  h.rolls.append(side); h.results.append(h.build[d][side]); h.used.append(d == h.setaside or kept)
  if d != h.setaside and not kept and Catalog.is_reaction(h.build[d][side]):
   h.reaction.append(d); h.used[d] = true
  if not kept and d != h.setaside: on_roll(h,d)


func activate() -> void:
 if outcome != "": return
 if cursor >= order.size(): new_round(); return
 active = order[cursor]; boss_index = 0; forced_die = -1
 action_owner = active; action_label = "Turn start"; action_before = {}
 record_event("turn",unit_name(active)+" begins its turn.",active)
 record_event("guide",turn_explanation(),active)
 if active == 3:
  for id in range(3):
   if heroes[id].rooted > 0:record_event("expire","Rooted ends on "+unit_name(id)+" at the boss turn start.",3,id)
   heroes[id].rooted = 0
  detonate_brand()
  if outcome != "": return
  if boss.block > 0: record_event("expire","%s loses %d unspent Block at turn start." % [boss_name(),boss.block],3,3)
  boss.block = 0
  for id in range(3):
   if heroes[id].weak: record_event("expire","Distort ends on "+unit_name(id)+" at the boss turn start.",3,id)
   heroes[id].weak = false
  note(boss_name()+" takes its turn. Resolve I → II → III.")
 else:
  var h: Dictionary = heroes[active]
  if h.dead or h.hp == 0 or active in replaced:
   cursor += 1; activate(); return
  if h.echo_due:
   h.echo_due = false; damage(active,v("face48.penalty"),true)
   if h.hp <= 0 or outcome != "":
    if outcome == "": cursor += 1; activate()
    return
  if h.dr > 0: record_event("expire",unit_name(active)+" loses Damage Reduction at turn start.",active,active)
  if h.ward: record_event("expire",unit_name(active)+" loses Wither Ward at turn start.",active,active)
  h.dr = 0; h.bulwark_weak = false; h.ward = false; h.num_boost = 0; h.numeric_focus = false
  h.debt_penalty = maxi(h.debt_penalty,h.debt_next); h.debt_next = 0
  boss.binds = boss.binds.filter(func(bind):return bind.owner != active)
  if h.channel.is_empty() or h.channel.face != 31:
   if h.block > 0: record_event("expire","%s loses %d unspent Block at turn start." % [unit_name(active),h.block],active,active)
   h.block = 0
  h.opening = true; reset_soul_allowance(active); h.engrave_growth = 0
  if not h.channel.is_empty():
   h.channel.block_lost = 0
   pending = {"kind":"channel","hero":active}

func finish_turn() -> void:
 if outcome != "" or not pending.is_empty(): return
 forced_die = -1
 for h in heroes: h.protected = false
 record_event("turn",unit_name(active)+" ends its full turn.",active)
 if active < 3:
  if encounter_id == "hollow" and heroes[active].hp > 0 and not heroes[active].dead and heroes[active].pos in fire_tiles and v("boss.fire.end_turn") > 0:
   action_owner = 3;action_label = "Smouldering Fire"
   fire_event(3,[heroes[active].pos],"End-turn fire")
   record_event("hazard","%s ends their turn on FIRE: %d normal damage. Move off the burning cell to avoid this." % [unit_name(active),v("boss.fire.end_turn")],3,active)
   last_boss_result = "FIRE: %s ends turn on a burning cell; %d normal damage." % [unit_name(active),v("boss.fire.end_turn")]
   damage(active,v("boss.fire.end_turn"),false,"Smouldering Fire")
   if outcome != "":return
  if heroes[active].stun: record_event("expire",unit_name(active)+" loses Stunned at turn end.",active,active)
  heroes[active].stun = false
  heroes[active].debt_buff = 0; heroes[active].num_boost = 0; heroes[active].numeric_focus = false
  if heroes[active].black_oath:
   heroes[active].black_oath = false
   if heroes[active].block > 0:
    action_owner = active;action_label = "Black Oath cost"
    damage(active,v("face50.penalty"),true,"Black Oath cost")
    if outcome != "": return
 if active == 3: boss.weak = false
 if recovery_active:
  recovery_active = false
 else: cursor += 1
 if not recovery.is_empty():
  active = recovery.pop_front()
  if heroes[active].dead:
   recovery_active = true
   finish_turn(); return
  replaced.append(active); recovery_active = true
  heroes[active].block = 0
  heroes[active].opening = true; reset_soul_allowance(active)
  roll_context = "Recovery · fresh Action Dice"
  roll_serial += 1
  heroes[active].setaside = -1
  roll_hero(heroes[active])
  present_action_roll(active,[0,1,2],"Recovery roll")
  note(heroes[active].name + " · Immediate recovery turn. Broken: next zero HP is death.")
 else: activate()

func cells(id: int, at: Vector2i = Vector2i(-99,-99)) -> Array:
 var p: Vector2i = at if at.x != -99 else unit_data(id).pos
 return [p,p+Vector2i.RIGHT,p+Vector2i.DOWN,p+Vector2i.ONE] if id == 3 else [p]

func distance(a: int, b: int, at: Vector2i = Vector2i(-99,-99)) -> int:
 var best := 100
 for p in cells(a,at):
  for q in cells(b): best = mini(best,absi(p.x-q.x)+absi(p.y-q.y))
 return best

func legal(id: int, p: Vector2i) -> bool:
 for c in cells(id,p):
  if c.x < 0 or c.y < 0 or c.x >= 9 or c.y >= 9: return false
  for u in range(unit_count()):
   if u == id or unit_data(u).get("dead",false): continue
   if c in cells(u): return false
 return true

func targets(dist: int = 99, include_downed: bool = false) -> Array:
 var ts: Array = []
 for i in range(3):
  if not heroes[i].dead and (include_downed or heroes[i].hp > 0) and distance(3,i) <= dist: ts.append(i)
 return ts

func nearest(ts: Array, low_block: bool = false) -> int:
 if ts.is_empty(): return -1
 var candidates: Array = []; var best := 100
 for t in ts:
  var d := distance(3,t)
  if d < best: candidates = [t]; best = d
  elif d == best: candidates.append(t)
 if low_block:
  var lowest := 100
  for t in candidates: lowest = mini(lowest,heroes[t].block)
  candidates = candidates.filter(func(t): return heroes[t].block == lowest)
 return candidates[rng.randi_range(0,candidates.size()-1)]

func boss_move(steps: int, chosen_target: int = -1) -> bool:
 var target := chosen_target if chosen_target >= 0 else nearest(targets())
 if target < 0: return false
 var moved := false
 var origin: Vector2i = boss.pos
 # Breadth-first search gives shortest legal paths for the full 2x2 footprint.
 for step in range(steps):
  var queue: Array = [[boss.pos, []]]; var visited: Array = [boss.pos]; var chosen: Array = []
  var goal := 100
  while not queue.is_empty():
   var item: Array = queue.pop_front(); var p: Vector2i = item[0]; var path: Array = item[1]
   var d := distance(3,target,p)
   if d == 1: chosen = path; break
   if d < goal and not path.is_empty(): chosen = path; goal = d
   for dir in DIRS:
    var np: Vector2i = p+dir
    if np not in visited and legal(3,np):
     visited.append(np); queue.append([np,path+[np]])
  if chosen.is_empty(): break
  boss.pos = chosen[0]; moved = true
 if moved: record_event("move","%s: %s moves %s → %s." % [action_label,boss_name(),cell_name(origin),cell_name(boss.pos)],3,3)
 return moved

func fallback() -> void:
 var origin: Vector2i = boss.pos
 if not targets(1).is_empty():
  boss.block += v("boss.fallback.idle")
  last_boss_result = "%s → FALLBACK: holds position; +%d Block." % [action_label,v("boss.fallback.idle")]
 elif boss_move(v("boss.fallback.move")):
  last_boss_result = "%s → FALLBACK: moves %s → %s." % [action_label,cell_name(origin),cell_name(boss.pos)]
 else:
  boss.block += v("boss.fallback.block")
  last_boss_result = "%s → FALLBACK: no route; +%d Block." % [action_label,v("boss.fallback.block")]
 record_event("fallback",last_boss_result,3,3)

func boss_visible_index() -> int:return boss_index
func boss_display_action() -> String:
 return boss_rolls[boss_index] if boss_index < boss_rolls.size() else "Turn complete"
func boss_step_label() -> String:
 return "Resolve "+(["I","II","III"][boss_index] if boss_index < 3 else "end of turn")+"   →"
func attack_targets(source: int, reach: int) -> Array:
 var result: Array = []
 for id in range(3):
  if not heroes[id].dead and heroes[id].hp > 0 and distance(source,id) <= reach:result.append(id)
 return result
func nearest_attacked(source: int, options: Array) -> int:
 if source == 3:return nearest(options)
 if options.is_empty():return -1
 var best := 100;var choices: Array = []
 for id in options:
  var d := distance(source,id)
  if d < best:best = d;choices = [id]
  elif d == best:choices.append(id)
 return choices[rng.randi_range(0,choices.size()-1)]

func check_end() -> void:
 if atomic_damage: return
 if heroes.all(func(h): return h.dead or h.hp <= 0): outcome = "defeat"
 elif boss.hp <= 0: outcome = "victory"
 if outcome != "": pending = {}; note(boss_name()+" falls. A new Soul awakens." if outcome == "victory" else "All three lights are extinguished.")

func damage(id: int, amount: int, unavoidable: bool = false, reason: String = "", attacker: int = -1) -> void:
 if outcome != "": return
 if id >= 4:
  damage_minion(id,amount,unavoidable,reason);return
 var h: Dictionary = boss if id == 3 else heroes[id]
 if id < 3 and h.dead: return
 amount = maxi(0,amount)
 var broken_channel: Dictionary = h.channel.duplicate() if id < 3 else {}
 var initial_hp: int = h.hp
 var incoming: int = maxi(0,amount)
 var reduction := 0
 var absorbed := 0 if unavoidable else mini(h.block,amount)
 h.block -= absorbed; amount -= absorbed
 if id < 3 and not unavoidable:
  reduction = mini(amount,h.dr); amount = maxi(0,amount-h.dr)
 if id < 3 and h.hp == 0:
  if amount > 0 and not h.protected: h.dead = true; note(h.name + " is slain.")
 elif amount > 0:
  if id < 3 and h.defy and h.hp-amount <= 0:
   h.defy = false; amount = maxi(0,h.hp-mini(h.hp,v("face46.hp"))); h.stun = true
   for d in range(3):
    if not h.used[d]: h.used[d] = true; break
  var old_hp: int = h.hp
  h.hp = maxi(0,h.hp-amount)
  if id < 3: h.taken += old_hp-h.hp
  if id < 3 and h.ward and attacker == 3 and old_hp > h.hp and distance(id,3) == 1:
   boss.weak = true
   record_event("debuff","Wither Ward: %s inflicts Weakness %d on %s until the boss turn ends." % [unit_name(id),v("face51.weakness"),boss_name()],id,3)
   if action_before.has(3): action_before[3].statuses["Weakness"] = true
  if id < 3 and h.hp == 0:
   if h.broken:h.dead = true;note(h.name+" is slain — Broken.")
   else:h.protected = true;note(h.name+" is Downed. Protected until this full turn ends.")
   h.block = 0;h.weak = false;h.bulwark_weak = false;h.stun = false
   h.reaction.clear();h.channel = {};h.dr = 0;h.rerolls = 0;h.used = [true,true,true]
   h.ward = false;h.num_boost = 0;h.numeric_focus = false;h.stored_num = -1;h.rooted = 0
   h.backstab = 0;h.debt_buff = 0;h.debt_next = 0;h.debt_penalty = 0
   h.defy = false;h.black_oath = false;h.echo_due = false;h.mods = {};h.smoke = {}

 var lost: int = initial_hp-h.hp
 var label: String = reason if reason != "" else (action_label if action_label != "" else "Damage")
 var result := "%s — %s → %s: %d incoming; %d blocked" % [label,unit_name(action_owner),unit_name(id),incoming,absorbed]
 if reduction > 0: result += "; %d reduced" % reduction
 result += "; %d HP lost. HP %d/%d, Block %d." % [lost,h.hp,h.get("max_hp",v("hero.hp")) if id < 3 else boss.max_hp,h.block]
 if unavoidable: result += " Unavoidable: bypasses Block and ordinary reduction."
 if id < 3 and initial_hp == 0 and h.protected: result += " Downed protection prevents death this turn."
 record_event("damage" if lost > 0 else ("block" if absorbed+reduction > 0 else "info"),result,action_owner,id,lost)
 if id < 3:stonewake_loss(id,absorbed,lost)
 if id == 3:check_phase()
 check_end()
 if id < 3 and lost > 0 and not broken_channel.is_empty() and broken_channel.face in [25,49]:
  var ch: Dictionary = broken_channel; h.channel = {}
  mutate(id,ch.die,ch.side,56 if ch.face == 25 else 0)
  if ch.face == 25 and outcome == "": damage(id,v("face25.backlash"),false,"Contained Power backlash")

func heal(id: int, value: int = 1) -> void:
 var h: Dictionary = heroes[id]
 if h.dead or value <= 0: return
 if h.hp == 0:
  h.broken = true; h.protected = false; recovery.append(id)
 var restored: int = maxi(0,mini(h.get("max_hp",v("hero.hp"))-h.hp,value))
 h.hp += restored
 record_event("heal","%s — %s heals %s for %d HP. HP %d/%d." % [action_label,unit_name(action_owner),unit_name(id),restored,h.hp,h.get("max_hp",v("hero.hp"))],action_owner,id,restored)

func face(id: int, d: int) -> int:
 return heroes[id].results[d]

func spend(d: int, store_smoke: bool = false) -> void:
 report_changes()
 heroes[active].opening = false
 heroes[active].used[d] = true
 if store_smoke and heroes[active].smoke.has(d):
  heroes[active].reaction.append(d)
 if forced_die == d: forced_die = -1

func hero_action(d: int, target: int = -1, destination: Vector2i = Vector2i(-99,-99)) -> bool:
 if active not in [0,1,2] or d not in range(3) or target < -1 or target >= unit_count():return false
 if active == 3 or outcome != "" or not pending.is_empty(): return false
 var h: Dictionary = heroes[active]
 if target >= 4 and unit_data(target).dead:return false
 if h.dead or h.hp <= 0:return false
 if h.used[d] or (forced_die >= 0 and forced_die != d): return false
 var f := face(active,d)
 if f == 6 and focus_reason(d,target) != "":return false
 begin_action(active,FACES[f],target if f != 6 else -1,d)
 if f >= 9: return catalog_action(d,target,destination)
 match f:
  0:
   if destination.x != -99 and not reward:return false
   if reward and destination.x != -99:
    if soul_remaining(active) <= 0 or not reachable(active,v("soul.move"),false).has(destination): return false
    h.pos = destination; h.soul_moves_used = int(h.get("soul_moves_used",0))+1; h.soul_move_used = h.soul_moves_used >= v("soul.uses")
    record_event("soul","%s uses the first reward Soul: spends one rolled Blank as Move %d. Soul conversion %d/%d used this hero turn; installed face remains Blank." % [unit_name(active),v("soul.move"),h.soul_moves_used,v("soul.uses")],active,active)
  1:
   if target < 0 or target == active or distance(active,target) > face_range(f): return false
   strike(d,target,v("face1.damage"))
  2,3:
   if not reachable(active,move_steps(f),f == 3).has(destination): return false
   h.pos = destination
  4: h.block += modified_value(d,v("face4.block"))
  6:
   var old_face: int = face(active,target)
   var old_side: int = h.rolls[target]
   spend(d)
   roll_context = "Focus · Action Die reroll"
   roll_serial += 1
   h.rolls[target] = rng.randi_range(0,5)
   h.results[target] = h.build[target][h.rolls[target]]
   on_roll(h,target)
   present_action_roll(active,[target],"Focus reroll")
   note(h.name + " focuses Die " + str(target+1) + " → " + FACES[face(active,target)])
   if Catalog.is_reaction(face(active,target)): h.used[target] = true; h.reaction.append(target)
   else: forced_die = target
   record_event("focus","%s uses Focus: Die %s, %s → %s.%s" % [unit_name(active),["I","II","III"][target],FACES[old_face],FACES[face(active,target)]," Held as a Reaction." if h.used[target] else " Resolve this die next, or decline it."],active,active)
   event_log[-1]["die"] = target;event_log[-1]["old_face"] = old_face;event_log[-1]["new_face"] = face(active,target);event_log[-1]["old_side"] = old_side;event_log[-1]["new_side"] = h.rolls[target]
   return true
  7:
   if target < 0 or target >= 3 or heroes[target].dead or (target != active and distance(active,target) > face_range(f)): return false
   heal(target,v("face7.heal"))
  8:
   if target < 0 or target == active or distance(active,target) > face_range(f): return false
   var dirs := away_dirs(active,target)
   if destination not in dirs: return false
   var tp: Vector2i = unit_data(target).pos
   for step in range(v("face8.move")):
    if not legal(target,tp+destination):break
    tp += destination
    unit_data(target).pos = tp
   note("Shove · No collision penalty.")
  _: return false
 spend(d,true)
 return true

func reachable(id: int, steps: int, straight: bool) -> Array:
 var result: Array = []; var origin: Vector2i = heroes[id].pos
 if heroes[id].get("rooted",0) > 0:return result
 if straight:
  for dir in DIRS:
   for n in range(1,steps+1):
    var p: Vector2i = origin+dir*n
    if not legal(id,p): break
    result.append(p)
 else:
  var queue: Array = [[origin,0]]; var seen: Array = [origin]
  while not queue.is_empty():
   var item: Array = queue.pop_front()
   if item[1] >= steps: continue
   for dir in DIRS:
    var p: Vector2i = item[0]+dir
    if p not in seen and legal(id,p):
     seen.append(p); result.append(p); queue.append([p,item[1]+1])
 return result

func away_dirs(source: int, target: int) -> Array:
 var valid: Array = []
 var old := distance(source,target)
 var tp: Vector2i = unit_data(target).pos
 for dir in DIRS:
  var best := 100
  for a in cells(source):
   for b in cells(target,tp+dir): best = mini(best,absi(a.x-b.x)+absi(a.y-b.y))
  if best > old: valid.append(dir)
 return valid

func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty(): return
 if boss_index >= 3: finish_turn(); return
 if roar_queued:
  boss_rolls[boss_index] = "Furnace Roar";roar_queued = false
 var action: String = boss_rolls[boss_index]
 if action == "Strike":action = "Smoking Strike";boss_rolls[boss_index] = action
 begin_action(3,action,-1,boss_index)
 boss_index += 1
 last_action = action
 last_boss_result = action+" resolved; see battle log for targets and values."
 last_targets.clear()
 match action:
  "Ashen Chain":
   var target := nearest(targets(v("boss.chain.range")))
   if target < 0: fallback()
   else:
    last_targets = [target]
    var h: Dictionary = heroes[target]
    var origin: Vector2i = h.pos
    var best: Vector2i = origin
    for step in range(v("boss.chain.move")):
     var dist := distance(target,3,best);var next: Vector2i = best
     for dir in DIRS:
      if legal(target,best+dir) and distance(target,3,best+dir) < dist:
       next = best+dir;dist = distance(target,3,next)
     if next == best:break
     best = next
    h.pos = best
    if phase_two and v("boss.chain.root") > 0:
     h.rooted = v("boss.chain.root")
     record_event("debuff","Upgraded Ashen Chain: %s gains Rooted %d until the next boss turn. Voluntary movement is prevented; forced movement still works." % [unit_name(target),h.rooted],3,target)
     if action_before.has(target):action_before[target].statuses["Rooted"] = true
    var lost: int = remove_block(target,v("boss.chain.strip"))
    record_event("debuff","Ashen Chain pulls %s %s → %s and removes %d Block. No HP damage; occupied cells stop the pull." % [unit_name(target),cell_name(origin),cell_name(best),lost],3,target)
  "Cinder Brand":
   var target := nearest(targets(v("boss.brand.range")))
   if target < 0: fallback()
   elif not brand_cells.is_empty(): note("Cinder Brand is already armed; the marked cells remain unchanged.")
   else:
    var at: Vector2i = heroes[target].pos
    var offsets: Array = brand_offsets()
    for offset in offsets:
     var cell: Vector2i = at+offset
     if cell.x in range(9) and cell.y in range(9): brand_cells.append(cell)
    var names: Array[String] = []
    for cell in brand_cells: names.append(cell_name(cell))
    fire_event(3,brand_cells,"Cinder Brand armed",true)
    record_event("hazard","Cinder Brand marks " + ", ".join(names) + ". At the START of the next boss turn, each hero still on a marked cell takes %d normal damage. Move off the marked area to evade; no immediate damage." % v("boss.brand.damage"),3,target)
  "Grave Tithe":
   var stolen := 0
   for target in targets(v("boss.tithe.range")):
    var lost: int = remove_block(target,v("boss.tithe.strip")); stolen += lost
    if lost: record_event("debuff","Grave Tithe removes %d Block from %s." % [lost,unit_name(target)],3,target)
   boss.block += mini(v("boss.tithe.cap"),stolen)
   note("Grave Tithe steals %d Block; The Hollow gains %d (cap %d). No HP damage." % [stolen,mini(v("boss.tithe.cap"),stolen),v("boss.tithe.cap")])
  "Bound": note("Lethargic Bind suppresses this action.")
  "Furnace Roar":
   var victims := targets(boss_range(action))
   last_targets = victims.duplicate()
   if victims.is_empty():fallback()
   else:
    pending = {"kind":"attack","action":action,"victims":victims,"reacted":[],"amount":v("boss.Furnace Roar.damage")}
    continue_attack()
  "Advance":
   var highest := highest_hp_targets()
   var adjacent := highest.filter(func(t):return distance(3,t) == 1)
   if not adjacent.is_empty():
    var target: int = adjacent[rng.randi_range(0,adjacent.size()-1)]
    boss.block += v("boss.advance.block");last_targets = [target]
    note("Advance: already adjacent to highest-HP hero %s (%d HP); gain %d Block." % [unit_name(target),heroes[target].hp,v("boss.advance.block")])
   elif not highest.is_empty():
    var target: int = highest[rng.randi_range(0,highest.size()-1)];last_targets = [target]
    note("Advance pursues %s (%d HP), the highest-HP hero; ties are random." % [unit_name(target),heroes[target].hp])
    if not boss_move(v("boss.advance.move"),target):
     boss.block += v("boss.fallback.block");note("Advance has no legal route to its chosen hero; gains %d Block." % v("boss.fallback.block"))
  "Brace":
   var value := v("boss.brace.block")
   boss.block += value
   note("Brace · +%d Block. Total: %d. Expires at the next boss turn." % [value,boss.block])
  "Distort":
   var t := distort_target()
   if t < 0: fallback()
   else:
    last_targets = [t]; heroes[t].weak = true
    record_event("debuff","Distort: %s gains Weakness %d until the next boss turn." % [unit_name(t),v("boss.distort.weakness")],3,t)
    if action_before.has(t): action_before[t].statuses["Weakness"] = true
  "Fracture":
   if v("boss.fracture.count") == 0:
    note("Fracture destroys no faces: its configured count is 0.");report_changes();return
   var ts := targets(v("boss.fracture.range")).filter(func(i): return heroes[i].build.any(func(d): return d.any(func(f): return f not in [0,56])))
   var t := nearest(ts)
   if t < 0: fallback()
   else: last_targets = [t]; pending = {"kind":"fracture","hero":t,"remaining":v("boss.fracture.count")}
  _:
   if action == "Skirmish": boss_move(v("boss.skirmish.move"))
   var ts := targets(boss_range(action),action == "Sweep")
   if ts.is_empty():
    if action != "Skirmish": fallback()
   else:
    var victims: Array = ts if action == "Sweep" else [nearest(ts,action in ["Strike","Smoking Strike"])]
    last_targets = victims.duplicate()
    note(action + " targets " + ", ".join(victims.map(func(t): return heroes[t].name)))
    pending = {"kind":"attack","action":action,"victims":victims,"reacted":[],"amount":v("boss."+("Strike" if action == "Smoking Strike" else action)+".damage")}
    continue_attack()
 report_changes()

func continue_attack() -> void:
 if pending.is_empty() or outcome != "": return
 var action: String = pending.action
 var source: int = pending.get("source",3)
 var reach: int = pending.get("range",boss_range(action))
 for victim in pending.victims:
  for actor in range(3):
   if heroes[actor].hp <= 0 or heroes[actor].dead: continue
   for die in heroes[actor].reaction:
    var key := str(actor) + ":" + str(die)
    if key in pending.reacted: continue
    var f: int = face(actor,die)
    var trigger: bool = actor == victim and (f in [5,28] or heroes[actor].smoke.has(die))
    if f == 44: trigger = actor != victim and distance(actor,victim) <= v("face44.range") and sight(actor,victim,v("face44.range"))
    if f == 45: trigger = actor != victim and distance(actor,source) <= mini(v("face45.range"),reach) and pending.action not in ["Sweep","Furnace Roar"]
    if f == 46: trigger = actor == victim and pending.amount-(v("face51.weakness") if boss.weak and source == 3 else 0)-heroes[actor].block-heroes[actor].dr >= heroes[actor].hp
    if f == 48: trigger = true
    if trigger:
     pending.kind = "reaction"; pending.hero = actor; pending.die = die; pending.victim = victim
     return
 var victims: Array = pending.victims.duplicate()
 if action not in ["Sweep","Furnace Roar"] and (heroes[victims[0]].hp <= 0 or distance(source,victims[0]) > reach):
  var ts := attack_targets(source,reach)
  if ts.is_empty():
   note(action + " has no legal adjacent target after Reactions; " + ("worm holds; bite ends." if source >= 4 else ("completed movement is kept, attack ends." if action == "Skirmish" else "attack is replaced by fallback.")))
   pending = {}
   if source == 3 and action != "Skirmish": fallback()
   return
  var t := nearest(ts,action in ["Strike","Smoking Strike"]) if source == 3 else nearest_attacked(source,ts)
  record_event("retarget","%s retargets %s to %s after a Reaction." % [unit_name(source),action,unit_name(t)],source,t)
  pending.victims = [t]; continue_attack(); return
 var amount: int = pending.amount
 pending = {}
 for t in victims:
  # Sweep locks its area after all reactions, and hits each adjacent unit once.
  if action in ["Sweep","Furnace Roar"] and distance(3,t) > boss_range(action): continue
  record_event("attack","%s attacks %s with %s for %d damage." % [unit_name(source),unit_name(t),action,maxi(0,amount-(v("face51.weakness") if boss.weak and source == 3 else 0))],source,t,amount)
  var hp_before: int = heroes[t].hp
  damage(t,maxi(0,amount-(v("face51.weakness") if boss.weak and source == 3 else 0)),false,"",source)
  last_boss_result = "%s · %s → %s: %d HP lost (%d incoming)." % [action,unit_name(source),unit_name(t),hp_before-heroes[t].hp,amount]
  if outcome != "": return
  if action in ["Strike","Smoking Strike"] and maxi(0,amount-(v("face51.weakness") if boss.weak else 0)) > 0:smoking_fire(t)
  if outcome != "":return
  if action == "Furnace Roar" and heroes[t].hp > 0:
   for step in range(v("boss.roar.push")):
    var dirs := away_dirs(3,t)
    var moved := false
    for dir in dirs:
     if legal(t,heroes[t].pos+dir):heroes[t].pos += dir;moved = true;break
    if not moved:break
  if action == "Drive Back":
   pending = {"kind":"push","hero":t,"direction":impact_direction(t)};push(pending.direction);return

func react(use: bool, dir: Vector2i = Vector2i.ZERO) -> void:
 if pending.get("kind","") != "reaction" or outcome != "":return
 var t: int = pending.hero
 var source: int = pending.get("source",3)
 var reach: int = pending.get("range",boss_range(pending.action))
 var die: int = pending.get("die",-1)
 if die not in range(3):
  if heroes[t].reaction.is_empty():return
  die = heroes[t].reaction[0]
 var victim: int = pending.get("victim",t)
 var h: Dictionary = heroes[t]
 var f: int = face(t,die)
 if use:
  h.reaction.erase(die)
  begin_action(t,"Reaction: "+FACES[f],victim,die)
  match f:
   28:
    var options := attack_targets(source,mini(v("face28.range"),reach)).filter(func(id):return id != t)
    if not options.is_empty(): pending.victims = [nearest_attacked(source,options)]
   44: h.block += v("face44.self"); heroes[victim].block += v("face44.ally")
   45: pending.victims = [t]
   46: h.defy = true; mutate(t,die,h.rolls[die],0)
   48:
    h.echo_due = false; mutate(t,die,h.rolls[die],0); damage(3,mini(v("face48.cap"),h.taken))
    if outcome != "": return
   _:
    if not h.smoke.has(die) or h.smoke[die] == 4: h.block += v("face32.block") if h.smoke.has(die) else v("face5.block")
    if dir != Vector2i.ZERO and h.get("rooted",0) <= 0:
     for step in range(v("face32.move") if h.smoke.has(die) else v("face5.move")):
      if not legal(t,h.pos+dir):break
      h.pos += dir
    h.smoke.erase(die)
  report_changes()
  action_owner = source; action_label = pending.action; action_before = {}
 pending.reacted.append(str(t)+":"+str(die)); pending.kind = "attack"; continue_attack()

func fracture(d: int, side: int) -> void:
 if pending.get("kind","") != "fracture" or d not in range(3) or side not in range(6):return
 var t: int = pending.hero
 if heroes[t].build[d][side] in [0,56]: return
 note(heroes[t].name + " loses " + FACES[heroes[t].build[d][side]] + " for this encounter.")
 mutate(t,d,side,0)
 if d in heroes[t].reaction and heroes[t].rolls[d] == side: heroes[t].reaction.erase(d)
 if int(pending.get("remaining",1)) > 1 and heroes[t].build.any(func(die):return die.any(func(f):return f not in [0,56])):pending.remaining -= 1
 else:pending = {}

func push(dir: Vector2i) -> void:
 if pending.get("kind","") != "push":return
 var t: int = pending.hero
 if pending.has("direction"):dir = pending.direction
 if dir not in away_dirs(3,t):return
 pending = {}
 var origin: Vector2i = heroes[t].pos
 for step in range(v("boss.push.move")):
  if legal(t,heroes[t].pos+dir):heroes[t].pos += dir
  else:
   record_event("collision","Drive Back: %s hits an obstruction; suffers %d unavoidable damage and Stunned." % [unit_name(t),v("boss.push.collision")],3,t)
   damage(t,v("boss.push.collision"),true,"Drive Back collision")
   if outcome != "" or heroes[t].dead or heroes[t].hp == 0:return
   if heroes[t].stun:damage(t,v("status.stun_repeat"),true)
   else:
    heroes[t].stun = true
    if heroes[t].used.has(false):pending = {"kind":"stun","hero":t}
    else:record_event("stun","%s gains Stunned. No unused die remains now; if still Stunned at the next shared roll, choose a die to set aside." % unit_name(t),3,t)
   break
 if origin != heroes[t].pos:record_event("move","Drive Back pushes %s %s → %s." % [unit_name(t),cell_name(origin),cell_name(heroes[t].pos)],3,t)

func stun_die(d: int) -> void:
 if pending.get("kind","") not in ["stun","preroll_stun"] or d not in range(3):return
 var t: int = pending.hero
 if pending.kind == "preroll_stun":
  if not heroes[t].channel.is_empty() and heroes[t].channel.die == d: return
  heroes[t].setaside = d
  record_event("stun","Stunned: %s sets aside Die %s before the shared roll." % [unit_name(t),["I","II","III"][d]],t,t)
  pending = {}
  if not stun_queue.is_empty(): pending = {"kind":"preroll_stun","hero":stun_queue.pop_front()}
  else: shared_roll()
  return
 if heroes[t].used[d]: return
 heroes[t].used[d] = true
 record_event("stun","Stunned: %s loses its unused Die %s (%s) this activation." % [unit_name(t),["I","II","III"][d],FACES[face(t,d)]],t,t)
 pending = {}

func action_reroll(d: int) -> bool:
 if reroll_reason(d) != "":return false
 var h: Dictionary = heroes[active]
 var old_face := face(active,d)
 var old_side: int = h.rolls[d]
 h.rerolls -= v("hero.reroll_cost")
 action_owner = active; action_label = "Action Reroll"; action_before = {}
 h.rolls[d] = rng.randi_range(0,5)
 h.results[d] = h.build[d][h.rolls[d]]
 if Catalog.is_reaction(face(active,d)): h.reaction.append(d); h.used[d] = true
 on_roll(h,d)
 roll_context = "Action Reroll · keep the new result"
 roll_serial += 1
 present_action_roll(active,[d],"Action reroll")
 record_event("roll",h.name.capitalize() + " spends %d Action Reroll: Die %s → %s. Charges left: %d." % [v("hero.reroll_cost"),["I","II","III"][d],FACES[face(active,d)],h.rerolls],active,active)
 record_event("roll","Die %s: side %d %s → side %d %s.%s" % [["I","II","III"][d],old_side+1,FACES[old_face],h.rolls[d]+1,FACES[face(active,d)]," Same ability rolled again; a reroll can land on another Blank or the same side." if old_face == face(active,d) else ""],active,active)
 return true

func boss_help(action: String) -> String:
 var base := default_boss_help(action)
 if balance.is_empty():return base
 var group := "Boss · "+action
 var values := Balance.summary(balance,group,tuned)
 return "ACTIVE VALUES\n"+values+"\n\nRules reference (default numbers; active values above take precedence):\n"+base

func default_boss_help(action: String) -> String:
 match action:
  "Ashen Chain": return "Pull the closest standing hero within %d up to %d legal cells closer; strip %d Block. %s" % [v("boss.chain.range"),v("boss.chain.move"),v("boss.chain.strip"),("PHASE II: also inflict Rooted %d until the next boss turn (no voluntary movement; forced movement allowed)." % v("boss.chain.root")) if phase_two else "Phase I: no Rooted. At half HP this upgrades to Rooted until the next boss turn."]
  "Furnace Roar": return "Unlocked at %d%% boss HP. Attack every standing hero within %d for %d damage, then push survivors up to %d cells away. Reactions apply; occupied cells stop the push without collision damage. Replaces Brace on Die I for the rest of the fight. The first Roar replaces the next unresolved boss die." % [v("boss.phase.percent"),v("boss.Furnace Roar.range"),v("boss.Furnace Roar.damage"),v("boss.roar.push")]
  "Cinder Brand": return "Mark %s beneath the closest hero within %d. At NEXT boss turn start, each hero on any marked cell takes %d normal damage. Move away to evade. No stacking. Phase I uses a cross; Phase II uses a square. Already armed cells do not expand mid-countdown." % [("a %d×%d square" % [v("boss.brand.radius")*2+1,v("boss.brand.radius")*2+1]) if phase_two else "a cross",v("boss.brand.range"),v("boss.brand.damage")]
  "Grave Tithe": return "Remove %d Block from each standing hero within %d. Gain the stolen Block, capped at %d. No HP damage." % [v("boss.tithe.strip"),v("boss.tithe.range"),v("boss.tithe.cap")]
  "Advance": return "Pursue the standing hero with the highest current HP, up to %d cells; highest-HP ties are random. If already adjacent to ANY tied highest-HP hero, stay and gain %d Block. Cannot path to the chosen hero: gain %d Block." % [v("boss.advance.move"),v("boss.advance.block"),v("boss.fallback.block")]
  "Skirmish": return "Move %d toward the closest hero, then attack within %d for %d. Reactions happen before damage." % [v("boss.skirmish.move"),boss_range(action),v("boss.Skirmish.damage")]
  "Strike", "Smoking Strike": return "Attack the closest standing hero within %d for %d damage (distance ties: lowest Block, then random). Any positive hit, even fully blocked: put a fire tile under that hero. If a Smoking Strike fire tile is already there, consume it to deal %d extra normal damage on that cell instead. Ending a hero turn on fire deals %d normal damage. Moving through it does not detonate it." % [v("boss.Strike.range"),v("boss.Strike.damage"),v("boss.smoking.fire_damage"),v("boss.fire.end_turn")]
  "Sweep": return "Attack EVERY hero within %d for %d each, including Downed heroes. Each hero is hit once." % [boss_range(action),v("boss.Sweep.damage")]
  "Drive Back": return "Attack within %d for %d, then automatically push %d cells along the direction from the boss to the hero. No player direction choice. Collision: %d unavoidable damage + Stunned; two equally aligned directions are resolved randomly." % [v("boss.Drive Back.range"),v("boss.Drive Back.damage"),v("boss.push.move"),v("boss.push.collision")]
  "Brace": return "Gain %d Block. Damage consumes Block; any left expires at the boss’s next turn." % v("boss.brace.block")
  "Distort": return "Target a highest-current-HP standing hero within %d. If no globally highest-HP hero is in reach, target the closest standing hero in reach. HP / distance ties are random. Inflict Weakness %d until the next boss turn. With no reachable hero, use fallback." % [v("boss.distort.range"),v("boss.distort.weakness")]
  "Fracture": return "Closest hero within %d chooses %d installed ability face(s) to become Blank for this fight. Earlier rolled results stay." % [v("boss.fracture.range"),v("boss.fracture.count")]
 return "Resolve one boss die at a time, then end its turn."
func on_roll(h: Dictionary, d: int) -> void:
 var f: int = h.results[d]
 if f == 13:
  var before: int = h.rerolls
  h.rerolls = mini(v("hero.reroll_cap"),h.rerolls+v("face13.rerolls"))
  record_event("buff" if h.rerolls > before else "info","%s rolls Clairvoyance: gains %d Action Rerolls; bank %d/%d." % [h.name.capitalize(),h.rerolls-before,h.rerolls,v("hero.reroll_cap")],heroes.find(h),heroes.find(h))
 if f == 48: h.echo_due = true
 if not h.channel.is_empty() and h.channel.face == 25 and h.channel.die != d:
  if h.channel.get("confirmed",true):
   if f == 0: h.block += v("face25.blank_block")
   else: h.channel.boost = mini(v("face25.cap"),h.channel.get("boost",0)+v("face25.boost"))
  elif f == 0: h.channel.pending_blank = h.channel.get("pending_blank",0)+v("face25.blank_block")
  else: h.channel.pending_boost = mini(v("face25.cap"),h.channel.get("pending_boost",0)+v("face25.boost"))

func numeric(h: Dictionary, damage_value: bool = false) -> int:
 var value := 0
 var absolute_zero := false
 var numeric_side := 0
 if h.stored_num >= 0: value = h.stored_num; numeric_side = 0 if value > 0 else 4; h.stored_num = -1
 else:
  var side := rng.randi_range(0,5)
  numeric_side = side
  if h.gambler and side == 4: absolute_zero = true
  elif h.gambler and side == 5:
   var base := rng.randi_range(0,5)
   value = v("face9.multiplier")*(ordinary_numeric(base,h.numeric_focus))
  else: value = ordinary_numeric(side,h.numeric_focus)
 var rolled_value := value
 h.numeric_focus = false
 if not absolute_zero:
  if not h.channel.is_empty() and h.channel.face == 25: value += h.channel.get("boost",0)
  if damage_value: value += h.num_boost; h.num_boost = 0
 h.numeric_zero = absolute_zero
 roll_presentations.append({"actor":h.name.capitalize(),"kind":("Numeric · base %d → value %d" % [rolled_value,value]) + (" · Attack modifiers follow" if damage_value else ""),"faces":[numeric_faces(h.gambler)],"sides":[numeric_side],"results":[str(value)],"dice":[0]})
 note(h.name + " rolls Numeric → " + str(value))
 roll_context = "Numeric Die · result " + str(value)
 roll_serial += 1
 return value

func modified_value(d: int, value: int) -> int:
 var h: Dictionary = heroes[active]
 if h.debt_buff > 0: value += h.debt_buff; h.debt_buff = 0
 if h.debt_penalty > 0: value -= h.debt_penalty; h.debt_penalty = 0
 if h.mods.has(d):
  value += h.mods[d].get("value",0)
  if Catalog.category(face(active,d)) == "Defense": value *= 1+h.mods[d].get("repeat",0)
 return maxi(0,value)

func strike(d: int, target: int, base: int, pierce: int = 0, numeric_attack: bool = false) -> int:
 var h: Dictionary = heroes[active]
 var value := maxi(0,modified_value(d,base)-hero_weakness(h))
 if numeric_attack and h.numeric_zero: value = 0
 var repeats := 1
 if h.backstab >= round_no and target == 3 and rear(active): repeats += v("face10.repeat"); h.backstab = 0
 if h.mods.has(d):
  pierce += h.mods[d].get("pierce",0); repeats += h.mods[d].get("repeat",0)
 var lost := 0
 for n in range(repeats):
  if outcome != "" or h.hp <= 0 or h.dead: break
  if unit_data(target).get("dead",false): break
  if distance(active,target) > face_range(face(active,d)): break
  if face(active,d) == 35 and not sight(active,target,face_range(35)): break
  if n > 0:
   var next_base: int = numeric_attack_base(d,target) if numeric_attack else base
   value = maxi(0,modified_value(d,next_base)-hero_weakness(h))
   if numeric_attack and h.numeric_zero: value = 0
  var unit: Dictionary = unit_data(target)
  var before: int = unit.hp
  var hit_had_block: bool = unit.block > 0
  var marked: bool = target == 3 and boss.mark and unit.block == 0 and value > 0
  var bargained: bool = target == 3 and not boss.bargain.is_empty() and boss.bargain.get("charges",0) > 0 and not (numeric_attack and h.numeric_zero)
  var power := v("face27.damage") if bargained else 0
  var shot_mark := v("face21.damage") if marked and face(active,d) == 35 else 0
  var bypass := mini(unit.block,pierce)
  unit.block -= bypass
  record_event("attack","%s attacks %s with %s for %d damage%s." % [unit_name(active),unit_name(target),action_label,mini(v("face35.cap"),value+power+shot_mark) if face(active,d) == 35 else value+power," (Pierce %d)" % pierce if pierce > 0 else ""],active,target,value+power)
  damage(target,mini(v("face35.cap"),value+power+shot_mark) if face(active,d) == 35 else value+power)
  if target == 3 or (unit.hp > 0 and not unit.dead): unit.block += bypass
  var hit_loss: int = maxi(0,before-unit.hp)
  lost += hit_loss
  # Personal on-hit rewards also resolve on a killing hit; no further damage follows victory.
  if face(active,d) == 36 and hit_loss >= v("face36.threshold"): h.block += hit_loss*v("face36.multiplier")
  if face(active,d) == 41 and hit_loss > 0: engrave_copy(d)
  if outcome != "": break
  if face(active,d) == 38 and target >= 3:cleave_splash(target)
  if face(active,d) == 40 and target == 3 and hit_had_block and unit.block == 0 and hit_loss > 0: delay_boss_once()
  if marked and before > unit.hp:
   boss.mark = false
   if face(active,d) != 35: damage(3,v("face21.damage"))
  if bargained and outcome == "":
   boss.bargain.charges -= 1
   if boss.bargain.charges == 0:
    var owner: int = boss.bargain.owner; boss.bargain = {}; damage(owner,v("face27.backlash"),true,"Blood Bargain backlash")
 return lost

func rear(id: int) -> bool:
 return heroes[id].pos.y >= boss.pos.y+2 and distance(id,3) == 1

func sight(a: int, b: int, limit: int) -> bool:
 for start_cell in cells(a):
  for end_cell in cells(b):
   if absi(start_cell.x-end_cell.x)+absi(start_cell.y-end_cell.y) > limit: continue
   var clear := true
   # Supercover segment: include both cells touched at a diagonal corner.
   var dx: int = end_cell.x-start_cell.x
   var dy: int = end_cell.y-start_cell.y
   var nx := absi(dx); var ny := absi(dy)
   var ix := 0; var iy := 0
   var p: Vector2i = start_cell
   var touched: Array = []
   while ix < nx or iy < ny:
    var decision := (1+2*ix)*ny-(1+2*iy)*nx
    if decision == 0:
     touched.append(p+Vector2i(signi(dx),0)); touched.append(p+Vector2i(0,signi(dy)))
     p += Vector2i(signi(dx),signi(dy)); ix += 1; iy += 1
    elif decision < 0: p.x += signi(dx); ix += 1
    else: p.y += signi(dy); iy += 1
    touched.append(p)
   for cell in touched:
    for u in range(unit_count()):
     if u in [a,b] or unit_data(u).get("dead",false): continue
     if cell in cells(u): clear = false
   if clear: return true
 return false

func mutate(hero: int, d: int, side: int, id: int) -> void:
 var h: Dictionary = heroes[hero]
 if h.build[d][side] == 56: return
 var old: int = h.build[d][side]
 h.build[d][side] = id
 record_event("mutation","%s: %s, Die %s side %d changes %s → %s for this encounter." % [action_label,unit_name(hero),["I","II","III"][d],side+1,FACES[old],FACES[id]],action_owner,hero)
 if d in h.reaction and h.rolls[d] == side: h.reaction.erase(d)
 if not h.channel.is_empty() and h.channel.die == d and h.channel.side == side: h.channel = {}

func add_to_blank(hero: int, id: int) -> bool:
 for d in range(3):
  var side: int = heroes[hero].build[d].find(0)
  if side >= 0: mutate(hero,d,side,id); return true
 return false

func catalog_action(d: int, target: int, destination: Vector2i) -> bool:
 var h: Dictionary = heroes[active]
 var f := face(active,d)
 var side: int = h.rolls[d]
 match f:
  9:
   if not h.gambler: h.gambler = true; note(h.name + " arms Gambler's Coin (x0 / x2).")
   else: h.gold += v("face9.gold"); mutate(active,d,side,0); note("Gambler's Coin becomes Blank · +%d Gold." % v("face9.gold"))
  10: h.backstab = round_no+v("face10.duration")
  11,16,23,26,30,32:
   pending = {"kind":"catalog_choice","hero":active,"die":d,"face":f,"stage":0}
   return true
  12:
   if target < 0 or target >= 3 or heroes[target].dead: return false
   if not heroes[target].build.any(func(die):return 0 in die): return false
   pending = {"kind":"slot","hero":active,"die":d,"face":f,"target":target,"install":55}
   return true
  13: pass # The when-rolled charge was already granted.
  14: h.num_boost += v("face14.boost")
  15,19:
   if target < 0 or target >= 3 or target == active or heroes[target].dead or distance(active,target) > face_range(f) or not sight(active,target,face_range(f)): return false
   if f == 15 and not heroes[target].build.any(func(die):return 0 in die): return false
   var value := numeric_for(f,h)
   if f == 19 and not h.numeric_zero: value = maxi(v("face19.minimum"),value)
   heal(target,value)
   if f == 15: mutate(active,d,side,0); add_to_blank(target,15)
  17:
   if h.stored_num < 0: h.stored_num = ordinary_numeric(rng.randi_range(0,5))
  18:
   pending = {"kind":"bind","hero":active,"die":d}
   return true
  20: h.numeric_focus = true
  21: boss.mark = true
  22:
   for other in range(3):
    if other != d and not h.used[other] and face(active,other) != 0: return false
   damage(3,v("face22.damage"),true)
  24:
   var attacks: Array = h.build[d].filter(func(id):return Catalog.is_attack(id))
   if not attacks.is_empty():
    var copied: int = attacks[rng.randi_range(0,attacks.size()-1)]
    h.results[d] = copied
    for n in range(v("face24.repeat")):
     var victims: Array = []
     for id in range(unit_count()):
      if id != active and not unit_data(id).get("dead",false) and distance(active,id) <= face_range(copied): victims.append(id)
     if not victims.is_empty():
      h.used[d] = false; hero_action(d,victims[rng.randi_range(0,victims.size()-1)])
     if outcome != "": break
    h.results[d] = 24
  25,31,49:
   if not h.channel.is_empty():
    note("Only one Channel per hero is supported. Maintain or release the existing Channel at your next turn; this die remains available to decline.")
    return false
   if f == 31: h.block += v("face31.initial")
   h.channel = {"die":d,"side":side,"face":f,"boost":0,"confirmed":true,"pending_blank":0,"pending_boost":0}
   note(h.name + " begins Channel · " + FACES[f])
  27:
   boss.bargain = {"owner":active,"charges":v("face27.charges")} if v("face27.charges") > 0 else {}
   if boss.bargain.is_empty():note("Blood Bargain has 0 configured charges; no damage bonus or backlash is armed.")
  28,44,45,46,48: return false # Stored automatically by the roll.
  29: h.debt_buff = v("face29.boost"); h.debt_next = v("face29.penalty")
  33:
   if not h.build.any(func(die):return 0 in die): return false
   pending = {"kind":"slot","hero":active,"die":d,"face":f,"target":active,"install":54}
   return true
  34,35,36,37,38,39,40,41:
   var range_value := face_range(f)
   if target < 0 or target == active or (target < 3 and heroes[target].dead) or distance(active,target) > range_value: return false
   if f == 35 and not sight(active,target,range_value): return false
   var value := numeric_attack_base(d,target)
   var lost := strike(d,target,value,v("face37.pierce") if f == 37 else 0,true)
   if outcome != "": spend(d); return true
  42: h.block += numeric_block(d)
  43: h.block += modified_value(d,v("face43.empty") if h.block == 0 else v("face43.normal"))
  47: h.dr = v("face47.reduction"); h.bulwark_weak = true
  50: h.block += numeric_block(d,v("face50.block")); h.black_oath = true
  51: h.block += numeric_block(d); h.ward = true
  52:
   h.block += numeric_block(d); spend(d)
   pending = {"kind":"ember","hero":active,"die":d}
   return true
  53:
   if destination not in leap_cells(active): return false
   h.pos = destination
   if distance(active,3) <= v("face53.range"): h.num_boost += v("face53.boost")
  54:
   if destination.x != -99:
    if destination not in reachable(active,v("face54.move"),false): return false
    h.pos = destination
   h.block += v("face54.block")
  55:
   if target < 0 or target >= 3 or heroes[target].dead or (target != active and distance(active,target) > face_range(f)): return false
   heal(target,numeric_for(f,h))
  57:
   if destination not in reachable(active,v("face57.move"),false): return false
   h.pos = destination; h.block += v("face57.block")
  58:
   if h.get("rooted",0) > 0 or (target in [0,1,2] and heroes[target].get("rooted",0) > 0):return false
   if target < 0 or target >= 3 or target == active or heroes[target].dead or heroes[target].hp <= 0 or distance(active,target) > face_range(f) or not sight(active,target,face_range(f)): return false
   var old: Vector2i = h.pos
   h.pos = heroes[target].pos; heroes[target].pos = old
   h.block += v("face58.block"); heroes[target].block += v("face58.block")
  56: pass
  _: return false
 spend(d,true)
 return true

func leap_cells(id: int) -> Array:
 var result: Array = []
 if heroes[id].get("rooted",0) > 0:return result
 for x in range(-v("face53.move"),v("face53.move")+1):
  for y in range(-v("face53.move"),v("face53.move")+1):
   if absi(x)+absi(y) > 0 and absi(x)+absi(y) <= v("face53.move"):
    var p: Vector2i = heroes[id].pos+Vector2i(x,y)
    if legal(id,p): result.append(p)
 return result

func channel_choice(keep: bool) -> void:
 if pending.get("kind","") != "channel" or active not in [0,1,2] or heroes[active].channel.is_empty():return
 begin_action(active,"Maintain Channel" if keep else "End Channel")
 var h: Dictionary = heroes[pending.hero]
 var ch: Dictionary = h.channel.duplicate()
 pending = {}
 if keep:
  if ch.face == 25:
   h.block += ch.get("pending_blank",0); h.channel.boost = mini(v("face25.cap"),ch.get("boost",0)+ch.get("pending_boost",0))
   h.channel.pending_blank = 0; h.channel.pending_boost = 0; h.channel.confirmed = true
   note("Maintained Contained Power: +%d held Block; Numeric +%d this turn." % [ch.get("pending_blank",0),h.channel.boost])
  if ch.face == 31: h.block = mini(v("face31.cap"),h.block+v("face31.gain"))
  if ch.face == 49: heal(active,v("face49.heal"))
  note(h.name + " maintains " + FACES[ch.face])
 else:
  h.channel = {}; h.rolls[ch.die] = rng.randi_range(0,5)
  h.results[ch.die] = h.build[ch.die][h.rolls[ch.die]]; h.used[ch.die] = false
  if Catalog.is_reaction(h.results[ch.die]): h.reaction.append(ch.die); h.used[ch.die] = true
  on_roll(h,ch.die); roll_serial += 1
  present_action_roll(active,[ch.die],"Released Channel die")
  note(h.name + " ends Channel and rolls the released die.")
 report_changes()

func choose_bind(d: int, action: String) -> void:
 if action == "Strike":action = "Smoking Strike"
 if pending.get("kind","") != "bind" or d not in range(3) or action not in boss_dice()[d]:return
 var source: int = pending.die
 boss.binds.append({"owner":active,"die":d,"action":action})
 pending = {}; spend(source)
 note("Bound boss die %d: %s until the binder's next turn." % [d+1,action])

func ember(value: int) -> void:
 if pending.get("kind","") != "ember":return
 var owner: int = pending.hero
 value = maxi(0,mini(value,mini(v("face52.burn"),heroes[owner].block)))
 remove_block(owner,value); pending = {}
 record_event("action","Ember Burst: %s burns %d Block; deals %d damage to each other unit in its radius, including allies. Block %d remains." % [unit_name(owner),value,value*v("face52.damage"),heroes[owner].block],owner)
 var burning: Array = []
 for x in range(9):
  for y in range(9):
   if absi(x-heroes[owner].pos.x)+absi(y-heroes[owner].pos.y) <= v("face52.range"):burning.append(Vector2i(x,y))
 if value > 0:fire_event(owner,burning,"Ember Burst")
 atomic_damage = true
 for id in range(unit_count()):
  if id != owner and not unit_data(id).get("dead",false) and distance(owner,id) <= v("face52.range"): damage(id,value*v("face52.damage"))
 atomic_damage = false
 check_end()

func catalog_pick(hero: int, d: int, side: int = -1) -> bool:
 if pending.get("kind","") not in ["catalog_choice","slot"] or hero not in range(3) or d not in range(3) or side < -1 or side > 5:return false
 var p: Dictionary = pending.duplicate()
 var source: int = p.die
 var h: Dictionary = heroes[active]
 var f: int = p.face
 if f == 11:
  if heroes[hero].dead or heroes[hero].hp <= 0 or distance(active,hero) > v("face11.range"): return false
  var copy: int = face(hero,d)
  if not Catalog.can_copy(copy): return false
  h.results[source] = copy; pending = {}; forced_die = source
  note("Conjure copies " + FACES[copy] + ". Resolve it now."); return true
 if hero != active: return false
 if f == 16:
  if d == source or h.used[d] or side < 0 or h.build[d][side] == 56: return false
  spend(source); h.rolls[d] = side; h.results[d] = h.build[d][side]; pending = {}; roll_serial += 1
  if Catalog.is_reaction(h.results[d]): h.reaction.append(d); h.used[d] = true
  else: forced_die = d
  on_roll(h,d); present_action_roll(active,[d],"Borrow Shape · chosen face"); return true
 if f == 23:
  if p.stage == 0:
   if d == source or h.used[d] or face(active,d) == 0: return false
   h.used[d] = true; pending.stage = 1; pending.skipped = d; return true
  if not h.used[d] or d in [source,p.get("skipped",-1)] or not Catalog.can_copy(face(active,d)): return false
  var copy: int = face(active,d); pending = {}; h.results[source] = copy; forced_die = source; return true
 if f == 26:
  if p.stage == 0:
   if d == source or h.used[d] or face(active,d) != 0: return false
   if not h.build[d].any(func(id):return id > 0 and id not in [11,16,23,24,26,56]): return false
   pending.stage = 1; pending.convert_die = d; return true
  if d != p.convert_die or side < 0: return false
  var chosen: int = h.build[d][side]
  if chosen <= 0 or chosen in [11,16,23,24,26,56]: return false
  mutate(active,source,h.rolls[source],56); spend(source)
  h.results[d] = chosen; pending = {}; forced_die = d
  if Catalog.is_reaction(chosen): h.reaction.append(d); h.used[d] = true; forced_die = -1
  on_roll(h,d)
  note("Corruption Conversion selects " + FACES[chosen] + " on Die " + str(d+1) + ".")
  return true
 if f == 30:
  if d == source or h.used[d] or (not Catalog.is_attack(face(active,d)) and face(active,d) not in [4,42,43,50,51,52]): return false
  var n := rng.randi_range(1,6)
  h.mods[d] = {"value":-v("face30.bad") if n == 1 else (v("face30.good") if n in [2,3,4] else (v("face30.defense") if n == 5 and Catalog.category(face(active,d)) == "Defense" else 0)),"pierce":v("face30.pierce") if n == 5 else 0,"repeat":v("face30.repeat") if n == 6 else 0}
  note("Ill Omen rolls %d for Die %d." % [n,d+1]); pending = {}; spend(source); return true
 if f == 32:
  if d == source or h.used[d] or face(active,d) not in [2,3,4]: return false
  h.smoke[d] = face(active,d); pending = {}; spend(source); forced_die = d; return true
 return false

func numeric_block(d: int, extra: int = 0) -> int:
 var h: Dictionary = heroes[active]
 var value := numeric_for(face(active,d),h)
 if h.numeric_zero: return 0
 return modified_value(d,value+extra)

static func bonus_build(selected_faces: Array, profile: Dictionary = {}) -> Array:
 var base := default_build(profile)
 if selected_faces.size() != 2 or selected_faces[0] == selected_faces[1]: return []
 for f in selected_faces:
  if f not in Catalog.extended_ids(): return []
 var best: Array = []
 var best_score := -1
 for a in range(9):
  for b in range(a+1,9):
   var trial: Array = base.duplicate(true)
   trial[a/3][a%3] = selected_faces[0]
   trial[b/3][b%3] = selected_faces[1]
   if validate(trial,selected_faces,profile) != "": continue
   var score := 0
   for die in trial:
    for f in die:
     if f == 1: score += 6
     elif f == 7: score += 12
     elif f == 3: score += 5
     elif f == 2: score += 3
     elif f in [4,5]: score += 4
   if score > best_score: best = trial; best_score = score
 return best

func decline(d: int) -> void:
 if active not in [0,1,2] or d not in range(3) or outcome != "" or not pending.is_empty():return
 if heroes[active].dead or heroes[active].hp <= 0 or heroes[active].used[d]:return
 if forced_die >= 0 and forced_die != d:return
 action_before = {}; action_owner = active; action_label = FACES[face(active,d)]
 record_event("decline","%s declines %s (Die %s); no effect, result spent." % [unit_name(active),action_label,["I","II","III"][d]],active)
 spend(d)


func choose_slot(d: int, side: int) -> bool:
 if pending.get("kind","") != "slot" or d not in range(3) or side not in range(6): return false
 var p: Dictionary = pending.duplicate()
 if heroes[p.target].build[d][side] != 0: return false
 mutate(p.target,d,side,p.install)
 if p.face == 12:
  heroes[p.hero].blessings += 1
  if heroes[p.hero].blessings >= v("face12.placements"): mutate(p.hero,p.die,heroes[p.hero].rolls[p.die],0)
 if p.face == 33 and v("face33.placements") > 0:
  heroes[p.hero].mutations = int(heroes[p.hero].get("mutations",0))+1
  if heroes[p.hero].mutations >= v("face33.placements"):mutate(p.hero,p.die,heroes[p.hero].rolls[p.die],0)
 pending = {}; spend(p.die,true)
 return true


func boss_dice() -> Array:
 var dice: Array = (TUNED_BOSS_DICE if tuned else BOSS_DICE).duplicate(true)
 if phase_two:dice[0][4] = "Furnace Roar"
 return dice

func detonate_brand() -> void:
 if brand_cells.is_empty(): return
 var marked: Array = brand_cells.duplicate(); brand_cells.clear()
 action_owner = 3; action_label = "Cinder Brand detonation"
 record_event("hazard","Cinder Brand detonates now, before boss dice resolve. Each hero on the marked square takes %d normal damage; moving away avoids it." % v("boss.brand.damage"),3)
 fire_event(3,marked,"Cinder Brand detonation")
 atomic_damage = true
 for id in range(3):
  if not heroes[id].dead and heroes[id].pos in marked: damage(id,v("boss.brand.damage"),false,"Cinder Brand")
 atomic_damage = false; check_end()

func turn_explanation() -> String:
 if outcome != "": return "Encounter ended. Open the chronicle to review the result."
 if active == 3:
  return "BOSS TURN: marked Cinder cells detonate first; old boss Block expires. Click Resolve I, II, III in order. Reactions pause before damage; choose whether to spend them. After III, click Resolve end of turn."
 var h: Dictionary = heroes[active]
 var available := 0
 for used in h.used:
  if not used: available += 1
 return "%s TURN: old Block expires (Stonewake can preserve it); temporary defenses end. Reroll first if you want to use your saved charge (%d left). Resolve up to %d available dice in any order, choosing board targets or Resolve. Stored reactions wait for attacks. End hero turn when finished; unused immediate results are lost at the next shared roll. Next round rolls all heroes together, not at each hero turn." % [unit_name(active),h.rerolls,available]


func present_action_roll(id: int, dice: Array, kind: String) -> void:
 if dice.is_empty(): return
 var h: Dictionary = heroes[id]
 var faces: Array = []; var sides: Array = []; var results: Array = []
 for d in dice:
  faces.append(h.build[d].map(func(f):return FACES[f])); sides.append(h.rolls[d]); results.append(FACES[face(id,d)])
 roll_presentations.append({"actor":unit_name(id),"kind":kind,"faces":faces,"sides":sides,"results":results,"dice":dice.duplicate()})

func numeric_attack_base(d: int, target: int) -> int:
 var h: Dictionary = heroes[active]; var f := face(active,d)
 var value := numeric_for(f,h,true)
 if value > 0:value += v("numeric.tuned_bonus")
 if f == 35: value = mini(v("face35.cap"),value)
 if f == 39 and target == 3 and rear(active): value += v("face39.rear")
 if f == 41:
  var count: int = h.build[d].count(41)
  value += v("face41.bonus2") if count >= v("face41.threshold2") else (v("face41.bonus1") if count >= v("face41.threshold1") else 0)
 return value

func engrave_copy(d: int) -> void:
 var h: Dictionary = heroes[active]
 if h.engrave_growth >= v("face41.growth"):return
 var grown := 0
 for copy in range(v("face41.copies")):
  if h.build[d].count(41) >= v("face41.cap"):break
  var slot: int = h.build[d].find(0)
  if slot < 0:break
  mutate(active,d,slot,41);grown += 1
 if grown > 0:h.engrave_growth += 1


func delay_boss_once() -> void:
 for step in range(v("face40.delay")):
  var at: int = order.find(3)
  if at <= cursor or at >= order.size()-1:break
  var next: int = order[at+1];order[at+1] = 3;order[at] = next
 note("Break Rhythm delays the upcoming boss activation up to %d slots; original initiative returns next round." % v("face40.delay"))


func v(key: String) -> int:
 var value := Balance.value(balance,key,tuned)
 if phase_two and encounter_id == "hollow" and Balance.INDEX.has("phase."+key):value += Balance.value(balance,"phase."+key,tuned)
 return value
func hero_weakness(h: Dictionary) -> int:
 return maxi(v("boss.distort.weakness") if h.weak else 0,v("face47.weakness") if h.bulwark_weak else 0)
func soul_remaining(id: int) -> int:
 var h: Dictionary = heroes[id]
 var used: int = int(h.get("soul_moves_used",0))
 return maxi(0,v("soul.uses")-used)
func move_steps(f: int) -> int:
 return v("soul.move") if f == 0 else v("face%d.move" % f)
func face_range(f: int) -> int:
 var key := "face%d.range" % f
 return v(key) if Balance.INDEX.has(key) else 1
func boss_range(action: String) -> int:
 if action == "Smoking Strike":action = "Strike"
 var key := "boss."+action+".range"
 return v(key) if Balance.INDEX.has(key) else 1
func numeric_for(f: int, h: Dictionary, attack: bool = false) -> int:
 var value := numeric(h,attack)
 if h.numeric_zero:return 0
 var prefix := "face%d." % f
 return maxi(0,value*v(prefix+"numeric_multiplier")+v(prefix+"numeric_bonus")) if Balance.INDEX.has(prefix+"numeric_multiplier") else value

func fire_event(source: int, tiles: Array, label: String, armed: bool = false) -> void:
 record_event("fire_arm" if armed else "fire",label+" · flames flare across the marked cells.",source)
 event_log[-1]["tiles"] = tiles.duplicate()
func numeric_faces(gambler: bool) -> Array:
 var result: Array = []
 for side in range(6):
  result.append(str(ordinary_numeric(side)))
 if gambler:result[4] = "×0";result[5] = "×"+str(v("face9.multiplier"))
 return result

func ordinary_numeric(side: int, focus: bool = false) -> int:
 if side < mini(v("numeric.high_faces"),v("numeric.positive_faces")):return v("numeric.high")
 if side < v("numeric.positive_faces"):return v("numeric.positive")
 return v("face20.blank_value") if focus else v("numeric.blank")

func stonewake_loss(id: int, block_loss: int, hp_loss: int = 0) -> void:
 var h: Dictionary = heroes[id]
 if h.channel.is_empty() or h.channel.face != 31:return
 h.channel.block_lost = int(h.channel.get("block_lost",0))+block_loss
 if hp_loss > 0 or (block_loss > 0 and h.channel.block_lost >= v("face31.break_block")):
  var lost: int = h.channel.block_lost;h.channel = {}
  record_event("expire","%s stops channeling Stonewake: %d HP and %d cumulative Block lost since their last turn. Held die stays spent until the next shared roll." % [unit_name(id),hp_loss,lost],id,id)

func remove_block(id: int, amount: int) -> int:
 var h: Dictionary = boss if id == 3 else heroes[id]
 var removed := mini(h.block,maxi(0,amount));h.block -= removed
 if id < 3:stonewake_loss(id,removed)
 return removed

func check_phase() -> void:
 if phase_two or boss.hp <= 0 or boss.hp*100 > boss.max_hp*v("boss.phase.percent"):return
 phase_two = true
 var next_die := boss_index if active == 3 else 0
 if next_die < boss_rolls.size():
  boss_rolls[next_die] = "Furnace Roar"
  if next_die == 0 and boss_sides.size() == 3:boss_sides[0] = 4
 else:roar_queued = true
 record_event("phase","HALF-HEALTH PHASE: every Hollow ability upgrades. New Brands become squares; Chain Roots; Roar unlocks. Open the phase guide for every upgrade.",3)

func reroll_face_reason(f: int) -> String:
 if f == 56:return "Red Tile is locked: it cannot be rerolled."
 if f in [9,11,15]:return FACES[f]+" is non-rerollable by its rules."
 return ""

func reroll_window_reason() -> String:
 if active not in [0,1,2] or outcome != "":return "No active hero turn."
 if not pending.is_empty():return "Finish the pending choice first."
 var h: Dictionary = heroes[active]
 if h.dead or h.hp <= 0:return "This hero is incapacitated. End the turn or revive them before taking actions."
 if forced_die >= 0:return "Resolve the forced result before using an Action Reroll."
 if not h.opening:return "Opening window closed: an action has already resolved. Saved charges are usable next own turn; Focus is a separate ability."
 if h.rerolls < v("hero.reroll_cost"):return "Not enough Action Rerolls. The starting charge does not refill each round."
 return ""

func reroll_reason(d: int) -> String:
 var window := reroll_window_reason()
 if window != "":return window
 if d not in range(3):return "Select a die first."
 var h: Dictionary = heroes[active]
 if h.used[d]:return "This die is already spent or held as a reaction / Channel."
 return reroll_face_reason(face(active,d))

func focus_reason(source: int, target: int) -> String:
 if active not in [0,1,2] or source not in range(3) or target not in range(3):return "Choose another die."
 var h: Dictionary = heroes[active]
 if target == source:return "Focus cannot reroll itself. Choose another READY die."
 if h.used[target]:return "That die is spent or held. Choose another READY die."
 return reroll_face_reason(face(active,target))

func status_description(id: int) -> String:
 var h: Dictionary = boss if id == 3 else heroes[id]
 var lines: Array[String] = []
 if id < 3:
  if h.dead:lines.append("Dead: cannot act or be revived.")
  elif h.hp == 0:lines.append("Downed: heal to revive with Broken.")
  if h.broken:lines.append("Broken: the next Downing is lethal.")
  if hero_weakness(h) > 0:lines.append("Weakness −%d Attack damage." % hero_weakness(h))
  if h.dr > 0:lines.append("Damage Reduction %d after Block; ends at own turn." % h.dr)
  if h.ward:lines.append("Wither Ward: HP damage near boss inflicts Weakness.")
  if h.stun:lines.append("Stunned: set aside one die at next shared roll.")
  if h.get("rooted",0) > 0:lines.append("Rooted %d: no voluntary movement until next boss turn; forced movement still works." % h.rooted)
  if not h.channel.is_empty():
   lines.append("Channel: "+FACES[h.channel.face]+(" · Block loss %d/%d; any HP loss breaks it." % [h.channel.get("block_lost",0),v("face31.break_block")] if h.channel.face == 31 else ""))
  if not h.reaction.is_empty():lines.append("Held reactions: "+", ".join(h.reaction.map(func(d):return FACES[face(id,d)])))
  if h.num_boost > 0:lines.append("Numeric damage +%d on next roll this turn." % h.num_boost)
  if h.numeric_focus:lines.append("Numeric Focus: next Blank counts as %d." % v("face20.blank_value"))
  if h.stored_num >= 0:lines.append("Stored Numeric: %d." % h.stored_num)
  if h.gambler:lines.append("Gambler: Numeric die has ×0 and ×%d." % v("face9.multiplier"))
  if h.backstab >= round_no and h.backstab > 0:lines.append("Weak Point READY: next rear Attack repeats; expires after round %d." % h.backstab)
  if h.debt_buff > 0:lines.append("Debt: next Attack/Defense +%d." % h.debt_buff)
  if h.debt_penalty > 0:lines.append("Debt: next Attack/Defense −%d." % h.debt_penalty)
  if h.debt_next > 0:lines.append("Debt owed next turn: −%d." % h.debt_next)
  if h.defy:lines.append("Defy Death armed.")
  if h.black_oath:lines.append("Black Oath: leftover Block costs HP at turn end.")
  if h.echo_due:lines.append("Echo of Pain: unused retaliation costs HP next turn.")
 else:
  if phase_two:lines.append("Phase II: 3×3 Cinder Brand, Rooted Ashen Chain and Furnace Roar unlocked.")
  if h.weak:lines.append("Weakness −%d damage." % v("face51.weakness"))
  if h.mark:lines.append("Mark Prey: next damaging unblocked hit gains damage.")
  if not h.bargain.is_empty():lines.append("Blood Bargain: %d charges." % h.bargain.charges)
 if lines.is_empty():return "No active buffs or debuffs."
 return "\n".join(lines)

func highest_hp_targets() -> Array:
 var standing := targets();var best := -1;var result: Array = []
 for id in standing:
  if heroes[id].hp > best:best = heroes[id].hp;result = [id]
  elif heroes[id].hp == best:result.append(id)
 return result

func distort_target() -> int:
 var highest := highest_hp_targets().filter(func(id):return distance(3,id) <= v("boss.distort.range"))
 if not highest.is_empty():return highest[rng.randi_range(0,highest.size()-1)]
 return nearest(targets(v("boss.distort.range")))

func brand_offsets() -> Array:
 var result: Array = [Vector2i.ZERO]
 var radius := v("boss.brand.radius")
 if phase_two:
  result.clear()
  for x in range(-radius,radius+1):
   for y in range(-radius,radius+1):result.append(Vector2i(x,y))
 else:
  for dir in DIRS:
   for step in range(1,radius+1):result.append(dir*step)
 return result

func impact_direction(target: int) -> Vector2i:
 # A 2x2 boss strikes outward from its centre; adjacent heroes have one dominant axis.
 var delta := Vector2(heroes[target].pos)-(Vector2(boss.pos)+Vector2(0.5,0.5))
 var candidates: Array = []
 if absf(delta.x) >= absf(delta.y):candidates.append(Vector2i(signi(int(delta.x*2)),0))
 if absf(delta.y) >= absf(delta.x):candidates.append(Vector2i(0,signi(int(delta.y*2))))
 return candidates[rng.randi_range(0,candidates.size()-1)]

func smoking_fire(target: int) -> void:
 var cell: Vector2i = heroes[target].pos
 if cell in fire_tiles:
  fire_tiles.erase(cell)
  record_event("hazard","Smoking Strike detonates and consumes the fire at %s: %d extra normal damage to each hero on that cell." % [cell_name(cell),v("boss.smoking.fire_damage")],3,target)
  fire_event(3,[cell],"Smoking Strike fire detonation")
  for id in range(3):
   if not heroes[id].dead and heroes[id].pos == cell:damage(id,v("boss.smoking.fire_damage"),false,"Smoking Strike fire detonation")
 else:
  fire_tiles.append(cell)
  record_event("hazard","Smoking Strike ignites %s under %s. Ending a hero turn here burns them; a later positive Smoking Strike detonates and removes it." % [cell_name(cell),unit_name(target)],3,target)
  fire_event(3,[cell],"Smoking Strike fire ignited",true)

func reset_soul_allowance(id: int) -> void:
 heroes[id].soul_moves_used = 0
 heroes[id].soul_move_used = false
 if reward:record_event("soul_refresh","%s refreshes Blank movement: %d/%d uses available for this own turn." % [unit_name(id),v("soul.uses"),v("soul.uses")],id,id)

static func valid_face_number(value: Variant) -> bool:
 return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= 0 and value < 59

func boss_name() -> String:return "The Hollow"
func unit_count() -> int:return 4+minions.size()
func unit_data(id: int) -> Dictionary:
 return boss if id == 3 else (heroes[id] if id < 3 else minions[id-4])
func living_minions() -> Array:
 var ids: Array = []
 for i in range(minions.size()):
  if not minions[i].dead and minions[i].hp > 0:ids.append(i+4)
 return ids
func damage_minion(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 var worm := unit_data(id)
 if worm.dead:return
 var absorbed := 0 if unavoidable else mini(worm.block,maxi(0,amount))
 worm.block -= absorbed
 var old: int = worm.hp;worm.hp = maxi(0,worm.hp-maxi(0,amount-absorbed))
 record_event("damage" if worm.hp < old else "block","%s — %s → %s: %d blocked; %d HP lost. HP %d/%d, Block %d." % [action_label,unit_name(action_owner),unit_name(id),absorbed,old-worm.hp,worm.hp,worm.max_hp,worm.block],action_owner,id,old-worm.hp)
 if worm.hp == 0:
  worm.dead = true
  record_event("minion_death",unit_name(id)+" falls silent. It no longer strengthens Nu’gh or blocks this cell.",action_owner,id)
func cleave_splash(target: int) -> void:
 for other in range(3,unit_count()):
  if other != target and not unit_data(other).get("dead",false) and unit_data(other).hp > 0 and distance(target,other) <= 1:
   damage(other,v("face38.splash"),false,"Cleave secondary hit");return
func phase_upgrades() -> Array:
 var smoking_upgrade := "Fire detonation damage +%d." % Balance.value(balance,"phase.boss.smoking.fire_damage")
 if Balance.value(balance,"phase.boss.fire.end_turn") > 0:smoking_upgrade += " End-turn fire damage +%d." % Balance.value(balance,"phase.boss.fire.end_turn")
 return [
 ["Advance","Movement +%d; adjacent Block +%d." % [Balance.value(balance,"phase.boss.advance.move"),Balance.value(balance,"phase.boss.advance.block")]],
 ["Ashen Chain","Also applies Rooted %d until next boss turn." % Balance.value(balance,"boss.chain.root")],
 ["Smoking Strike",smoking_upgrade],
 ["Skirmish","Movement +%d." % Balance.value(balance,"phase.boss.skirmish.move")],
 ["Sweep","Reach +%d; damage +%d (each hero once)." % [Balance.value(balance,"phase.boss.Sweep.range"),Balance.value(balance,"phase.boss.Sweep.damage")]],
 ["Brace","Block +%d; Die I instead becomes Furnace Roar." % Balance.value(balance,"phase.boss.brace.block")],
 ["Drive Back","Push distance +%d." % Balance.value(balance,"phase.boss.push.move")],
 ["Distort","Weakness +%d." % Balance.value(balance,"phase.boss.distort.weakness")],
 ["Fracture","Reach +%d; destruction count stays the same." % Balance.value(balance,"phase.boss.fracture.range")],
 ["Cinder Brand","New warnings become %d×%d squares; detonation damage +%d. Already armed cells keep their marked area." % [Balance.value(balance,"boss.brand.radius")*2+1,Balance.value(balance,"boss.brand.radius")*2+1,Balance.value(balance,"phase.boss.brand.damage")]],
 ["Grave Tithe","Steal +%d Block per hero; gain cap +%d." % [Balance.value(balance,"phase.boss.tithe.strip"),Balance.value(balance,"phase.boss.tithe.cap")]],
 ["Furnace Roar","Unlocks; reach +%d over its base test value." % Balance.value(balance,"phase.boss.Furnace Roar.range")]]
func phase_description() -> String:
 var text := "[b]PHASE II ACTIVE[/b]" if phase_two else "[b]At %d/%d HP[/b]" % [int(floor(boss.max_hp*v("boss.phase.percent")/100.0)),boss.max_hp]
 for item in phase_upgrades():text += "\n\n[b]"+item[0]+"[/b]\n"+item[1]
 return text
