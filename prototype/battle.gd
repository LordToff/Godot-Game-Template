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
const BOSS_DICE = [["Advance","Advance","Strike","Strike","Brace","Drive Back"], ["Advance","Skirmish","Strike","Sweep","Brace","Distort"], ["Advance","Skirmish","Strike","Sweep","Drive Back","Fracture"]]
const TUNED_BOSS_DICE = [["Advance","Ashen Chain","Strike","Strike","Brace","Drive Back"], ["Skirmish","Cinder Brand","Strike","Sweep","Grave Tithe","Distort"], ["Advance","Skirmish","Cinder Brand","Sweep","Drive Back","Fracture"]]
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
var boss_sides: Array = []
var roll_presentations: Array = []
var initiative_base: Array = []

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
 var owned: Array = gift if gift is Array else ([gift] if gift is int and gift >= 0 else [])
 var counts := []
 counts.resize(59)
 counts.fill(0)
 for die in build:
  if die.size() != 6 or die.count(0) < Balance.value(profile,"body.blanks"): return "Every six-sided die needs at least %d Blanks." % Balance.value(profile,"body.blanks")
  for f in die: counts[f] += 1
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
 rng.randomize()
 if seed_value: rng.seed = seed_value
 initial_builds = builds.duplicate(true); brand_cells.clear(); roll_presentations.clear()
 reward = soul
 tuned = balanced
 roll_serial = 0
 last_action = ""
 last_targets.clear()
 heroes.clear(); order.clear(); log_lines.clear(); event_log.clear(); event_id = 0; action_owner = -1; action_label = ""; action_before = {}; recovery.clear(); replaced.clear()
 pending = {}; outcome = ""; atomic_damage = false; forced_die = -1; stun_queue.clear(); cursor = 0; round_no = 0; recovery_active = false
 for i in range(3):
  heroes.append({"name":["VESPER","ROOK","WREN"][i], "hp":v("hero.hp"),"max_hp":v("hero.hp"),"block":0,"pos":Vector2i(2+i*2,7),"dead":false,"broken":false,"protected":false,"weak":false,"stun":false,"setaside":-1,"build":builds[i].duplicate(true),"rolls":[],"results":[],"used":[],"reaction":[],"initiative":rng.randi_range(v("initiative.min"),v("initiative.max")),"rerolls":mini(v("hero.rerolls"),v("hero.reroll_cap")),"opening":true,"soul_move_used":false,"soul_moves_used":0,"channel":{},"taken":0,"dr":0,"ward":false,"num_boost":0,"numeric_focus":false,"numeric_zero":false,"bulwark_weak":false,"stored_num":-1,"gambler":false,"gold":0,"backstab":0,"debt_buff":0,"debt_next":0,"debt_penalty":0,"echo_due":false,"defy":false,"black_oath":false,"smoke":{},"mods":{},"blessings":0,"mutations":0})
  order.append(i)
 boss = {"hp":v("boss.hp"),"max_hp":v("boss.hp"),"block":0,"mark":false,"bargain":{},"weak":false,"binds":[],"pos":Vector2i(3,3),"initiative":rng.randi_range(v("initiative.min"),v("initiative.max"))}
 order.append(3)
 order.sort_custom(func(a,b):
  var av: int = boss.initiative if a == 3 else heroes[a].initiative
  var bv: int = boss.initiative if b == 3 else heroes[b].initiative
  return av > bv if av != bv else (a == 3 or (b != 3 and a < b)))
 initiative_base = order.duplicate()
 note("The dice remember. Initiative is fixed for this encounter.")
 new_round()

func unit_name(id: int) -> String:
 if id == 3: return "The Hollow"
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
  result["Broken"] = h.broken
  result["Gambler Armed"] = h.gambler
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
    var harmful: bool = status in ["Weakness","Marked","Debt Penalty","Stunned","Broken"]
    var description: String = status
    if status == "Weakness": description += " 1 (Attacks deal 1 less damage)"
    if status == "Damage Reduction": description += " 1 (after Block)"
    if status == "Numeric Power": description += " +"+str(h.num_boost)+" for the next Numeric damage this turn"
    if status == "Debt Boost": description += " +2 on the next Attack/Defense this turn"
    if status == "Debt Penalty": description += " −2 on the next Attack/Defense"
    if status == "Channel" and id < 3: description += " ("+FACES[h.channel.face]+")"
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
 for id in range(3):
  var h: Dictionary = heroes[id]
  if h.hp <= 0 or h.dead: continue
  var dice: Array = []
  for d in range(3):
   if d != h.setaside and (h.channel.is_empty() or h.channel.die != d): dice.append(d)
  present_action_roll(id,dice,"Shared roll")
 roll_presentations.append({"actor":"The Hollow","kind":"Shared roll","faces":boss_dice().duplicate(true),"sides":boss_sides.duplicate(),"results":boss_rolls.duplicate(),"dice":[0,1,2]})
 record_event("round","Round %d begins. All available Action Dice roll together." % round_no)
 for id in range(3):
  if heroes[id].hp <= 0 or heroes[id].dead: continue
  var values: Array[String] = []
  for d in range(3): values.append(["I","II","III"][d]+": "+FACES[face(id,d)]+(" [held]" if heroes[id].used[d] else ""))
  record_event("roll",unit_name(id)+" rolls "+" · ".join(values)+".",id)
 record_event("roll","The Hollow rolls I: %s · II: %s · III: %s." % boss_rolls,3)
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
  detonate_brand()
  if outcome != "": return
  if boss.block > 0: record_event("expire","The Hollow loses %d unspent Block at turn start." % boss.block,3,3)
  boss.block = 0
  for id in range(3):
   if heroes[id].weak: record_event("expire","Distort ends on "+unit_name(id)+" at the boss turn start.",3,id)
   heroes[id].weak = false
  note("The Hollow takes its turn. Resolve I → II → III.")
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
  h.opening = true; h.soul_move_used = false; h.soul_moves_used = 0
  if not h.channel.is_empty(): pending = {"kind":"channel","hero":active}

func finish_turn() -> void:
 if outcome != "" or not pending.is_empty(): return
 forced_die = -1
 for h in heroes: h.protected = false
 record_event("turn",unit_name(active)+" ends its full turn.",active)
 if active < 3:
  if heroes[active].stun: record_event("expire",unit_name(active)+" loses Stunned at turn end.",active,active)
  heroes[active].stun = false
  heroes[active].debt_buff = 0; heroes[active].num_boost = 0; heroes[active].numeric_focus = false
  if heroes[active].black_oath and heroes[active].block > 0:
   heroes[active].black_oath = false; damage(active,v("face50.penalty"),true)
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
  heroes[active].opening = true; heroes[active].soul_move_used = false; heroes[active].soul_moves_used = 0
  roll_context = "Recovery · fresh Action Dice"
  roll_serial += 1
  heroes[active].setaside = -1
  roll_hero(heroes[active])
  present_action_roll(active,[0,1,2],"Recovery roll")
  note(heroes[active].name + " · Immediate recovery turn. Broken: next zero HP is death.")
 else: activate()

func cells(id: int, at: Vector2i = Vector2i(-99,-99)) -> Array:
 var p: Vector2i = at if at.x != -99 else (boss.pos if id == 3 else heroes[id].pos)
 return [p,p+Vector2i.RIGHT,p+Vector2i.DOWN,p+Vector2i.ONE] if id == 3 else [p]

func distance(a: int, b: int, at: Vector2i = Vector2i(-99,-99)) -> int:
 var best := 100
 for p in cells(a,at):
  for q in cells(b): best = mini(best,absi(p.x-q.x)+absi(p.y-q.y))
 return best

func legal(id: int, p: Vector2i) -> bool:
 for c in cells(id,p):
  if c.x < 0 or c.y < 0 or c.x >= 9 or c.y >= 9: return false
  for u in range(4):
   if u == id or (u < 3 and heroes[u].dead): continue
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

func boss_move(steps: int) -> bool:
 var target := nearest(targets())
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
 if moved: record_event("move","%s: The Hollow moves %s → %s." % [action_label,cell_name(origin),cell_name(boss.pos)],3,3)
 return moved

func fallback() -> void:
 if not targets(1).is_empty():
  boss.block += v("boss.fallback.idle")
  note("No closer step: The Hollow holds position; gains %d Block." % v("boss.fallback.idle"))
 elif boss_move(v("boss.fallback.move")):note("Fallback · The Hollow closes the gap.")
 else:
  boss.block += v("boss.fallback.block");note("Fallback · Block +%d." % v("boss.fallback.block"))

func check_end() -> void:
 if atomic_damage: return
 if heroes.all(func(h): return h.dead or h.hp <= 0): outcome = "defeat"
 elif boss.hp <= 0: outcome = "victory"
 if outcome != "": pending = {}; note("The Hollow falls. A new Soul awakens." if outcome == "victory" else "All three lights are extinguished.")

func damage(id: int, amount: int, unavoidable: bool = false, reason: String = "") -> void:
 if outcome != "": return
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
  if id < 3 and h.ward and distance(id,3) <= v("face51.range"):
   boss.weak = true
   record_event("debuff","Wither Ward: %s inflicts Weakness %d on The Hollow until the boss turn ends." % [unit_name(id),v("face51.weakness")],id,3)
   if action_before.has(3): action_before[3].statuses["Weakness"] = true
  if id < 3 and h.hp == 0:
   if h.broken: h.dead = true; note(h.name + " is slain — Broken.")
   else:
    h.protected = true; h.block = 0; h.weak = false; h.bulwark_weak = false; h.stun = false
    h.reaction.clear(); h.channel = {}; h.dr = 0; h.rerolls = 0; h.used = [true,true,true]
    h.ward = false; h.num_boost = 0; h.numeric_focus = false; h.stored_num = -1
    h.backstab = 0; h.debt_buff = 0; h.debt_next = 0; h.debt_penalty = 0
    h.defy = false; h.black_oath = false; h.echo_due = false; h.mods = {}; h.smoke = {}
    note(h.name + " is Downed. Protected until this full turn ends.")
 var lost: int = initial_hp-h.hp
 var label: String = reason if reason != "" else (action_label if action_label != "" else "Damage")
 var result := "%s — %s → %s: %d incoming; %d blocked" % [label,unit_name(action_owner),unit_name(id),incoming,absorbed]
 if reduction > 0: result += "; %d reduced" % reduction
 result += "; %d HP lost. HP %d/%d, Block %d." % [lost,h.hp,h.get("max_hp",v("hero.hp")) if id < 3 else boss.max_hp,h.block]
 if unavoidable: result += " Unavoidable: bypasses Block and ordinary reduction."
 if id < 3 and initial_hp == 0 and h.protected: result += " Downed protection prevents death this turn."
 record_event("damage" if lost > 0 else ("block" if absorbed+reduction > 0 else "info"),result,action_owner,id,lost)
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
 if active == 3 or outcome != "" or not pending.is_empty(): return false
 var h: Dictionary = heroes[active]
 if h.used[d] or (forced_die >= 0 and forced_die != d): return false
 var f := face(active,d)
 begin_action(active,FACES[f],target if f != 6 else -1,d)
 if f >= 9: return catalog_action(d,target,destination)
 match f:
  0:
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
   if target < 0 or target == d or h.used[target]: return false
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
   return true
  7:
   if target < 0 or target == 3 or heroes[target].dead or (target != active and distance(active,target) > face_range(f)): return false
   heal(target,v("face7.heal"))
  8:
   if target < 0 or target == active or distance(active,target) > face_range(f): return false
   var dirs := away_dirs(active,target)
   if destination not in dirs: return false
   var tp: Vector2i = boss.pos if target == 3 else heroes[target].pos
   for step in range(v("face8.move")):
    if not legal(target,tp+destination):break
    tp += destination
    if target == 3:boss.pos = tp
    else:heroes[target].pos = tp
   note("Shove · No collision penalty.")
  _: return false
 spend(d,true)
 return true

func reachable(id: int, steps: int, straight: bool) -> Array:
 var result: Array = []; var origin: Vector2i = heroes[id].pos
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
 var tp: Vector2i = boss.pos if target == 3 else heroes[target].pos
 for dir in DIRS:
  var best := 100
  for a in cells(source):
   for b in cells(target,tp+dir): best = mini(best,absi(a.x-b.x)+absi(a.y-b.y))
  if best > old: valid.append(dir)
 return valid

func boss_step() -> void:
 if active != 3 or outcome != "" or not pending.is_empty(): return
 if boss_index >= 3: finish_turn(); return
 var action: String = boss_rolls[boss_index]
 begin_action(3,action,-1,boss_index)
 boss_index += 1
 last_action = action
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
    var lost: int = mini(v("boss.chain.strip"),h.block); h.block -= lost
    record_event("debuff","Ashen Chain pulls %s %s → %s and removes %d Block. No HP damage; occupied cells stop the pull." % [unit_name(target),cell_name(origin),cell_name(best),lost],3,target)
  "Cinder Brand":
   var target := nearest(targets(v("boss.brand.range")))
   if target < 0: fallback()
   elif not brand_cells.is_empty(): note("Cinder Brand is already armed; the marked cells remain unchanged.")
   else:
    var at: Vector2i = heroes[target].pos
    var offsets: Array = [Vector2i.ZERO]
    for direction in DIRS:
     for step in range(1,v("boss.brand.radius")+1):offsets.append(direction*step)
    for offset in offsets:
     var cell: Vector2i = at+offset
     if cell.x in range(9) and cell.y in range(9): brand_cells.append(cell)
    var names: Array[String] = []
    for cell in brand_cells: names.append(cell_name(cell))
    fire_event(3,brand_cells,"Cinder Brand armed",true)
    record_event("hazard","Cinder Brand marks " + ", ".join(names) + ". At the START of the next boss turn, each hero still on a marked cell takes %d normal damage. Move off the red cross to evade; no immediate damage." % v("boss.brand.damage"),3,target)
  "Grave Tithe":
   var stolen := 0
   for target in targets(v("boss.tithe.range")):
    var lost: int = mini(v("boss.tithe.strip"),heroes[target].block); heroes[target].block -= lost; stolen += lost
    if lost: record_event("debuff","Grave Tithe removes %d Block from %s." % [lost,unit_name(target)],3,target)
   boss.block += mini(v("boss.tithe.cap"),stolen)
   note("Grave Tithe steals %d Block; The Hollow gains %d (cap %d). No HP damage." % [stolen,mini(v("boss.tithe.cap"),stolen),v("boss.tithe.cap")])
  "Bound": note("Lethargic Bind suppresses this action.")
  "Advance":
   if not boss_move(v("boss.advance.move")): fallback()
  "Brace":
   var value := v("boss.brace.block")
   boss.block += value
   note("Brace · +%d Block. Total: %d. Expires at the next boss turn." % [value,boss.block])
  "Distort":
   var t := nearest(targets(v("boss.distort.range")))
   if t < 0: fallback()
   else:
    last_targets = [t]; heroes[t].weak = true
    record_event("debuff","Distort: %s gains Weakness %d until the next boss turn." % [unit_name(t),v("boss.distort.weakness")],3,t)
    if action_before.has(t): action_before[t].statuses["Weakness"] = true
  "Fracture":
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
    var victims: Array = ts if action == "Sweep" else [nearest(ts,action == "Strike")]
    last_targets = victims.duplicate()
    note(action + " targets " + ", ".join(victims.map(func(t): return heroes[t].name)))
    pending = {"kind":"attack","action":action,"victims":victims,"reacted":[],"amount":v("boss."+action+".damage")}
    continue_attack()
 report_changes()

func continue_attack() -> void:
 if pending.is_empty() or outcome != "": return
 var action: String = pending.action
 for victim in pending.victims:
  for actor in range(3):
   if heroes[actor].hp <= 0 or heroes[actor].dead: continue
   for die in heroes[actor].reaction:
    var key := str(actor) + ":" + str(die)
    if key in pending.reacted: continue
    var f: int = face(actor,die)
    var trigger: bool = actor == victim and (f in [5,28] or heroes[actor].smoke.has(die))
    if f == 44: trigger = actor != victim and distance(actor,victim) <= v("face44.range") and sight(actor,victim,v("face44.range"))
    if f == 45: trigger = actor != victim and distance(actor,3) <= mini(v("face45.range"),boss_range(pending.action)) and pending.action != "Sweep"
    if f == 46: trigger = actor == victim and pending.amount-(v("face51.weakness") if boss.weak else 0)-heroes[actor].block-heroes[actor].dr >= heroes[actor].hp
    if f == 48: trigger = true
    if trigger:
     pending.kind = "reaction"; pending.hero = actor; pending.die = die; pending.victim = victim
     return
 var victims: Array = pending.victims.duplicate()
 if action != "Sweep" and (heroes[victims[0]].hp <= 0 or distance(3,victims[0]) > boss_range(action)):
  var ts := targets(boss_range(action))
  if ts.is_empty():
   note(action + " has no legal adjacent target after Reactions; " + ("completed movement is kept, attack ends." if action == "Skirmish" else "attack is replaced by fallback."))
   pending = {}
   if action != "Skirmish": fallback()
   return
  var t := nearest(ts,action == "Strike")
  record_event("retarget","The Hollow retargets %s to %s after a Reaction." % [action,unit_name(t)],3,t)
  pending.victims = [t]; continue_attack(); return
 var amount: int = pending.amount
 pending = {}
 for t in victims:
  # Sweep locks its area after all reactions, and hits each adjacent unit once.
  if action == "Sweep" and distance(3,t) > boss_range(action): continue
  record_event("attack","The Hollow attacks %s with %s for %d damage." % [unit_name(t),action,maxi(0,amount-(v("face51.weakness") if boss.weak else 0))],3,t,amount)
  damage(t,maxi(0,amount-(v("face51.weakness") if boss.weak else 0)))
  if outcome != "": return
  if action == "Drive Back": pending = {"kind":"push","hero":t}; return

func react(use: bool, dir: Vector2i = Vector2i.ZERO) -> void:
 var t: int = pending.hero
 var die: int = pending.get("die",heroes[t].reaction[0])
 var victim: int = pending.get("victim",t)
 var h: Dictionary = heroes[t]
 var f: int = face(t,die)
 if use:
  h.reaction.erase(die)
  begin_action(t,"Reaction: "+FACES[f],victim,die)
  match f:
   28:
    var options := targets(mini(v("face28.range"),boss_range(pending.action))).filter(func(id):return id != t)
    if not options.is_empty(): pending.victims = [nearest(options)]
   44: h.block += v("face44.self"); heroes[victim].block += v("face44.ally")
   45: pending.victims = [t]
   46: h.defy = true; mutate(t,die,h.rolls[die],0)
   48:
    h.echo_due = false; mutate(t,die,h.rolls[die],0); damage(3,mini(v("face48.cap"),h.taken))
    if outcome != "": return
   _:
    if not h.smoke.has(die) or h.smoke[die] == 4: h.block += v("face32.block") if h.smoke.has(die) else v("face5.block")
    if dir != Vector2i.ZERO:
     for step in range(v("face32.move") if h.smoke.has(die) else v("face5.move")):
      if not legal(t,h.pos+dir):break
      h.pos += dir
    h.smoke.erase(die)
  report_changes()
  action_owner = 3; action_label = pending.action; action_before = {}
 pending.reacted.append(str(t)+":"+str(die)); pending.kind = "attack"; continue_attack()

func fracture(d: int, side: int) -> void:
 var t: int = pending.hero
 if heroes[t].build[d][side] in [0,56]: return
 note(heroes[t].name + " loses " + FACES[heroes[t].build[d][side]] + " for this encounter.")
 mutate(t,d,side,0)
 if d in heroes[t].reaction and heroes[t].rolls[d] == side: heroes[t].reaction.erase(d)
 if int(pending.get("remaining",1)) > 1 and heroes[t].build.any(func(die):return die.any(func(f):return f not in [0,56])):pending.remaining -= 1
 else:pending = {}

func push(dir: Vector2i) -> void:
 var t: int = pending.hero
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
   elif heroes[t].used.has(false):heroes[t].stun = true;pending = {"kind":"stun","hero":t}
   break
 if origin != heroes[t].pos:record_event("move","Drive Back pushes %s %s → %s." % [unit_name(t),cell_name(origin),cell_name(heroes[t].pos)],3,t)

func stun_die(d: int) -> void:
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
 if active >= 3 or outcome != "" or not pending.is_empty(): return false
 var h: Dictionary = heroes[active]
 if not h.opening or h.rerolls < v("hero.reroll_cost") or h.used[d] or face(active,d) in [9,11,15,56]: return false
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
 return true

func boss_help(action: String) -> String:
 var base := default_boss_help(action)
 if balance.is_empty():return base
 var group := "Boss · "+action
 var values := Balance.summary(balance,group,tuned)
 return "ACTIVE VALUES\n"+values+"\n\nRules reference (default numbers; active values above take precedence):\n"+base

func default_boss_help(action: String) -> String:
 match action:
  "Ashen Chain": return "Pull the closest standing hero within 3 one legal cell closer; strip 1 Block. Units stop the pull. No HP damage."
  "Cinder Brand": return "Mark a red cross beneath the closest hero within 3. At NEXT boss turn start, each hero on any marked cell takes 1 normal damage. Move away to evade. A second Brand cannot stack."
  "Grave Tithe": return "Remove 1 Block from each standing hero within 2. Gain the stolen Block, capped at 2. No HP damage."
  "Advance": return "Move up to 2 toward the closest standing hero. Already adjacent? Hold position." if tuned else "Move up to 2 toward the closest standing hero; if impossible, use fallback."
  "Skirmish": return "Move 1 toward the closest hero, then attack an adjacent hero for 1. Reactions happen before damage."
  "Strike": return "Attack the closest adjacent standing hero for 2 damage. Ties: lowest Block, then random."
  "Sweep": return "Attack EVERY adjacent hero for 1 each, including Downed heroes. Each hero is hit once."
  "Drive Back": return "Attack an adjacent hero for 1, then push 1 directly away. Collision: 1 unavoidable damage + Stunned."
  "Brace": return "Gain %d Block. Damage consumes Block; any left expires at the boss’s next turn." % v("boss.brace.block")
  "Distort": return "Closest standing hero within 2 gains Weakness 1 until the next boss turn: Attacks deal 1 less damage."
  "Fracture": return "Closest adjacent hero chooses one installed ability to become Blank for this fight. Earlier rolled results stay."
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
   var base := rng.randi_range(0,4)
   value = v("face9.multiplier")*(v("numeric.positive") if base < v("numeric.positive_faces") else (v("face20.blank_value") if h.numeric_focus else v("numeric.blank")))
  else: value = v("numeric.positive") if side < v("numeric.positive_faces") else (v("face20.blank_value") if h.numeric_focus else v("numeric.blank"))
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
  if target < 3 and heroes[target].dead: break
  if distance(active,target) > face_range(face(active,d)): break
  if face(active,d) == 35 and not sight(active,target,face_range(35)): break
  if n > 0:
   var next_base: int = numeric_attack_base(d,target) if numeric_attack else base
   value = maxi(0,modified_value(d,next_base)-hero_weakness(h))
   if numeric_attack and h.numeric_zero: value = 0
  var unit: Dictionary = boss if target == 3 else heroes[target]
  var before: int = unit.hp
  var hit_had_block: bool = unit.block > 0
  var marked: bool = target == 3 and boss.mark and unit.block == 0 and value > 0
  var bargained: bool = target == 3 and not boss.bargain.is_empty() and not (numeric_attack and h.numeric_zero)
  var power := v("face27.damage") if bargained else 0
  var bypass := mini(unit.block,pierce)
  unit.block -= bypass
  record_event("attack","%s attacks %s with %s for %d damage%s." % [unit_name(active),unit_name(target),action_label,mini(v("face35.cap"),value+power) if face(active,d) == 35 else value+power," (Pierce %d)" % pierce if pierce > 0 else ""],active,target,value+power)
  damage(target,mini(v("face35.cap"),value+power) if face(active,d) == 35 else value+power)
  if target == 3 or (unit.hp > 0 and not unit.dead): unit.block += bypass
  var hit_loss: int = maxi(0,before-unit.hp)
  lost += hit_loss
  if outcome != "": break
  if face(active,d) == 40 and target == 3 and hit_had_block and unit.block == 0 and hit_loss > 0: delay_boss_once()
  if face(active,d) == 36 and hit_loss >= v("face36.threshold"): h.block += hit_loss*v("face36.multiplier")
  if face(active,d) == 41: engrave_copy(d)
  if outcome != "": break
  if marked and before > unit.hp:
   boss.mark = false
   if face(active,d) != 35: damage(3,v("face21.damage"))
  if bargained and outcome == "":
   boss.bargain.charges -= 1
   if boss.bargain.charges == 0:
    var owner: int = boss.bargain.owner; boss.bargain = {}; damage(owner,v("face27.backlash"),true,"Blood Bargain backlash")
 return lost

func rear(id: int) -> bool:
 return heroes[id].pos.y >= boss.pos.y+2 and distance(id,3) <= v("face51.range")

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
    for u in range(4):
     if u in [a,b] or (u < 3 and heroes[u].dead): continue
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
   if target < 0 or target == 3 or heroes[target].dead: return false
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
   if h.stored_num < 0: h.stored_num = v("numeric.positive") if rng.randi_range(0,5) < v("numeric.positive_faces") else v("numeric.blank")
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
     for id in range(4):
      if id != active and not (id < 3 and heroes[id].dead) and distance(active,id) <= face_range(copied): victims.append(id)
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
  27: boss.bargain = {"owner":active,"charges":v("face27.charges")}
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
 for x in range(-v("face53.move"),v("face53.move")+1):
  for y in range(-v("face53.move"),v("face53.move")+1):
   if absi(x)+absi(y) > 0 and absi(x)+absi(y) <= v("face53.move"):
    var p: Vector2i = heroes[id].pos+Vector2i(x,y)
    if legal(id,p): result.append(p)
 return result

func channel_choice(keep: bool) -> void:
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
 var source: int = pending.die
 boss.binds.append({"owner":active,"die":d,"action":action})
 pending = {}; spend(source)
 note("Bound boss die %d: %s until the binder's next turn." % [d+1,action])

func ember(value: int) -> void:
 var owner: int = pending.hero
 value = maxi(0,mini(value,mini(v("face52.burn"),heroes[owner].block)))
 heroes[owner].block -= value; pending = {}
 record_event("action","Ember Burst: %s burns %d Block; deals %d damage to each other unit in its radius, including allies. Block %d remains." % [unit_name(owner),value,value*v("face52.damage"),heroes[owner].block],owner)
 var burning: Array = []
 for x in range(9):
  for y in range(9):
   if absi(x-heroes[owner].pos.x)+absi(y-heroes[owner].pos.y) <= v("face52.range"):burning.append(Vector2i(x,y))
 if value > 0:fire_event(owner,burning,"Ember Burst")
 atomic_damage = true
 for id in range(4):
  if id != owner and not (id < 3 and heroes[id].dead) and distance(owner,id) <= v("face52.range"): damage(id,value*v("face52.damage"))
 atomic_damage = false
 check_end()

func catalog_pick(hero: int, d: int, side: int = -1) -> bool:
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
 return TUNED_BOSS_DICE if tuned else BOSS_DICE

func detonate_brand() -> void:
 if brand_cells.is_empty(): return
 var marked: Array = brand_cells.duplicate(); brand_cells.clear()
 action_owner = 3; action_label = "Cinder Brand detonation"
 record_event("hazard","Cinder Brand detonates now, before boss dice resolve. Each hero on the red cross takes %d normal damage; moving away avoids it." % v("boss.brand.damage"),3)
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
 for copy in range(v("face41.copies")):
  var slot: int = h.build[d].find(0)
  if slot < 0:
   for side in range(6):
    if h.build[d][side] not in [41,56]: slot = side; break
  if slot >= 0: mutate(active,d,slot,41)


func delay_boss_once() -> void:
 for step in range(v("face40.delay")):
  var at: int = order.find(3)
  if at <= cursor or at >= order.size()-1:break
  var next: int = order[at+1];order[at+1] = 3;order[at] = next
 note("Break Rhythm delays the upcoming boss activation up to %d slots; original initiative returns next round." % v("face40.delay"))


func v(key: String) -> int:
 return Balance.value(balance,key,tuned)
func hero_weakness(h: Dictionary) -> int:
 return maxi(v("boss.distort.weakness") if h.weak else 0,v("face47.weakness") if h.bulwark_weak else 0)
func soul_remaining(id: int) -> int:
 var h: Dictionary = heroes[id]
 var used: int = int(h.get("soul_moves_used",0))
 if h.soul_move_used:used = maxi(used,v("soul.uses"))
 return maxi(0,v("soul.uses")-used)
func move_steps(f: int) -> int:
 return v("soul.move") if f == 0 else v("face%d.move" % f)
func face_range(f: int) -> int:
 var key := "face%d.range" % f
 return v(key) if Balance.INDEX.has(key) else 1
func boss_range(action: String) -> int:
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
  result.append(str(v("numeric.positive") if side < v("numeric.positive_faces") else v("numeric.blank")))
 if gambler:result[4] = "×0";result[5] = "×"+str(v("face9.multiplier"))
 return result
