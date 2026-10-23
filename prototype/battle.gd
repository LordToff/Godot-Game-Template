class_name AshBattle
extends RefCounted

const Catalog = preload("res://prototype/catalog.gd")
static var FACES: Array = make_face_names()

static func make_face_names() -> Array:
 var names: Array = []
 for id in range(57): names.append(Catalog.name_for(id))
 return names
const CAPS = [18, 4, 2, 1, 2, 1, 1, 1, 1]
const BOSS_DICE = [["Advance","Advance","Strike","Strike","Brace","Drive Back"], ["Advance","Skirmish","Strike","Sweep","Brace","Distort"], ["Advance","Skirmish","Strike","Sweep","Drive Back","Fracture"]]
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

static func default_build() -> Array:
 return [[1,2,4,0,0,0], [1,3,5,0,0,0], [1,7,6,0,0,0]]

static func validate(build: Array, gift: int = -1) -> String:
 var counts := []
 counts.resize(57)
 counts.fill(0)
 for die in build:
  if die.count(0) < 3: return "Every die needs at least 3 Blanks."
  for f in die: counts[f] += 1
 for i in range(1,9):
  if counts[i] > CAPS[i] + (1 if i == gift else 0): return "Not enough owned copies of " + FACES[i] + "."
 for i in range(9,57):
  if counts[i] > (1 if i == gift else 0): return "Only your chosen starter gift may be equipped."
 var totals := {"Movement":0,"Defense":0,"Skill":0}
 for id in range(1,57):
  var cat: String = Catalog.category(id)
  if totals.has(cat): totals[cat] += counts[id]
 if totals.Movement > 3 or totals.Defense > 3 or totals.Skill > 3:
  return "Broken Body allows at most 3 of each: Movement, Defense, Skill."
 return ""

func start(builds: Array, seed_value: int = 0, soul: bool = false, balanced: bool = true) -> void:
 rng.randomize()
 if seed_value: rng.seed = seed_value
 reward = soul
 tuned = balanced
 roll_serial = 0
 last_action = ""
 last_targets.clear()
 heroes.clear(); order.clear(); log_lines.clear(); recovery.clear(); replaced.clear()
 pending = {}; outcome = ""; forced_die = -1; stun_queue.clear(); cursor = 0; round_no = 0; recovery_active = false
 for i in range(3):
  heroes.append({"name":["VESPER","ROOK","WREN"][i], "hp":6,"block":0,"pos":Vector2i(2+i*2,7),"dead":false,"broken":false,"protected":false,"weak":false,"stun":false,"setaside":-1,"build":builds[i].duplicate(true),"rolls":[],"results":[],"used":[],"reaction":[],"initiative":rng.randi_range(1,6),"rerolls":1,"opening":true,"channel":{},"taken":0,"dr":0,"ward":false,"num_boost":0,"numeric_focus":false,"numeric_zero":false,"bulwark_weak":false,"stored_num":-1,"gambler":false,"gold":0,"backstab":0,"debt_buff":0,"debt_next":0,"debt_penalty":0,"echo_due":false,"defy":false,"black_oath":false,"smoke":{},"mods":{},"blessings":0})
  order.append(i)
 boss = {"hp":12 if tuned else 18,"max_hp":12 if tuned else 18,"block":0,"mark":false,"bargain":{},"weak":false,"binds":[],"pos":Vector2i(3,3),"initiative":rng.randi_range(1,6)}
 order.append(3)
 order.sort_custom(func(a,b):
  var av: int = boss.initiative if a == 3 else heroes[a].initiative
  var bv: int = boss.initiative if b == 3 else heroes[b].initiative
  return av > bv if av != bv else (a == 3 or (b != 3 and a < b)))
 note("The dice remember. Initiative is fixed for this encounter.")
 new_round()

func note(s: String) -> void:
 log_lines.append(s)
 if log_lines.size() > 70: log_lines.pop_front()

func new_round() -> void:
 round_no += 1; cursor = 0; replaced.clear()
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
 boss_rolls.clear()
 for index in range(3):
  var action: String = BOSS_DICE[index][rng.randi_range(0,5)]
  for bind in boss.binds:
   if bind.die == index and bind.action == action:
    action = "Bound"; damage(bind.owner,1); break
  boss_rolls.append(action)
 note("Round %d · All available dice rolled together." % round_no)
 activate()

func roll_hero(h: Dictionary) -> void:
 var previous: Array = h.rolls.duplicate()
 h.rolls = []; h.results = []; h.used = []; h.reaction = []; h.taken = 0; h.mods = {}; h.smoke = {}
 h.num_boost = 0; h.numeric_focus = false
 if not h.channel.is_empty() and h.channel.face == 25:
  h.channel.boost = 0
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
 if active == 3:
  boss.block = 0
  for h in heroes: h.weak = false
  note("The Hollow takes its turn. Resolve I → II → III.")
 else:
  var h: Dictionary = heroes[active]
  if h.dead or h.hp == 0 or active in replaced:
   cursor += 1; activate(); return
  if h.echo_due:
   h.echo_due = false; damage(active,1,true)
   if h.hp <= 0 or outcome != "":
    if outcome == "": cursor += 1; activate()
    return
  h.dr = 0; h.bulwark_weak = false; h.ward = false; h.num_boost = 0; h.numeric_focus = false
  h.debt_penalty = h.debt_next; h.debt_next = 0
  boss.binds = boss.binds.filter(func(bind):return bind.owner != active)
  if h.channel.is_empty() or h.channel.face != 31: h.block = 0
  h.opening = true
  if not h.channel.is_empty(): pending = {"kind":"channel","hero":active}
  note(h.name + " · Choose your dice order.")

func finish_turn() -> void:
 if outcome != "" or not pending.is_empty(): return
 forced_die = -1
 for h in heroes: h.protected = false
 if active < 3:
  heroes[active].stun = false
  if heroes[active].black_oath and heroes[active].block > 0:
   heroes[active].black_oath = false; damage(active,1,true)
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
  heroes[active].opening = true
  roll_context = "Recovery · fresh Action Dice"
  roll_serial += 1
  heroes[active].setaside = -1
  roll_hero(heroes[active])
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
 return moved

func fallback() -> void:
 if tuned and not targets(1).is_empty():
  note("No closer step: The Hollow holds position; no free Block.")
  return
 if boss_move(1): note("Fallback · The Hollow moves one step closer.")
 else: boss.block += 1; note("Fallback · Cannot close the gap; +1 Block.")

func check_end() -> void:
 if heroes.all(func(h): return h.dead or h.hp <= 0): outcome = "defeat"
 elif boss.hp <= 0: outcome = "victory"
 if outcome != "": pending = {}; note("The Hollow falls. A new Soul awakens." if outcome == "victory" else "All three lights are extinguished.")

func damage(id: int, amount: int, unavoidable: bool = false) -> void:
 if outcome != "": return
 var h: Dictionary = boss if id == 3 else heroes[id]
 if id < 3 and h.dead: return
 var absorbed := 0 if unavoidable else mini(h.block,amount)
 h.block -= absorbed; amount -= absorbed
 if id < 3 and not unavoidable: amount = maxi(0,amount-h.dr)
 if absorbed > 0: note(("The Hollow" if id == 3 else h.name) + " blocks %d damage · %d Block remains." % [absorbed,h.block])
 if id < 3 and h.hp == 0:
  if amount > 0 and not h.protected: h.dead = true; note(h.name + " is slain.")
 elif amount > 0:
  if id < 3 and h.defy and h.hp-amount <= 0:
   h.defy = false; amount = maxi(0,h.hp-1); h.stun = true
   for d in range(3):
    if not h.used[d]: h.used[d] = true; break
  var old_hp: int = h.hp
  h.hp = maxi(0,h.hp-amount)
  if id < 3: h.taken += old_hp-h.hp
  note(("The Hollow" if id == 3 else h.name) + " loses %d HP." % (old_hp-h.hp))
  if id < 3 and h.ward and distance(id,3) == 1: boss.weak = true
  if id < 3 and h.hp == 0:
   if h.broken: h.dead = true; note(h.name + " is slain — Broken.")
   else:
    h.protected = true; h.block = 0; h.weak = false; h.bulwark_weak = false; h.stun = false
    h.reaction.clear(); h.channel = {}; h.dr = 0; h.rerolls = 0; h.used = [true,true,true]
    note(h.name + " is Downed. Protected until this full turn ends.")
 check_end()
 if id < 3 and amount > 0 and not h.channel.is_empty() and h.channel.face in [25,49]:
  var ch: Dictionary = h.channel.duplicate(); h.channel = {}
  h.build[ch.die][ch.side] = 56 if ch.face == 25 else 0
  if ch.face == 25 and outcome == "": damage(id,2)

func heal(id: int, value: int = 1) -> void:
 var h: Dictionary = heroes[id]
 if h.dead or value <= 0: return
 if h.hp == 0:
  h.broken = true; h.protected = false; recovery.append(id)
 var restored: int = mini(6-h.hp,value)
 h.hp += restored
 note(h.name + " recovers %d HP." % restored)

func face(id: int, d: int) -> int:
 return heroes[id].results[d]

func spend(d: int, store_smoke: bool = false) -> void:
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
 if f >= 9: return catalog_action(d,target,destination)
 match f:
  0:
   if reward and destination.x != -99:
    if not reachable(active,2,false).has(destination): return false
    h.pos = destination
  1:
   if target < 0 or target == active or distance(active,target) != 1: return false
   strike(d,target,2 if tuned else 1)
  2,3:
   if not reachable(active,1 if f == 2 else 3,f == 3).has(destination): return false
   h.pos = destination
  4: h.block += modified_value(d,1)
  6:
   if target < 0 or target == d or h.used[target]: return false
   spend(d)
   roll_context = "Focus · Action Die reroll"
   roll_serial += 1
   h.rolls[target] = rng.randi_range(0,5)
   h.results[target] = h.build[target][h.rolls[target]]
   on_roll(h,target)
   note(h.name + " focuses Die " + str(target+1) + " → " + FACES[face(active,target)])
   if Catalog.is_reaction(face(active,target)): h.used[target] = true; h.reaction.append(target)
   else: forced_die = target
   return true
  7:
   if target < 0 or target == 3 or heroes[target].dead or (target != active and distance(active,target) != 1): return false
   heal(target)
  8:
   if target < 0 or target == active or distance(active,target) != 1: return false
   var dirs := away_dirs(active,target)
   if destination not in dirs: return false
   var tp: Vector2i = boss.pos if target == 3 else heroes[target].pos
   if legal(target,tp+destination):
    if target == 3: boss.pos += destination
    else: heroes[target].pos += destination
   note("Shove · No collision penalty.")
  _: return false
 spend(d,true)
 note(h.name + " resolves " + FACES[f] + ".")
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
 var action: String = boss_rolls[boss_index]; boss_index += 1
 last_action = action
 last_targets.clear()
 note("The Hollow · " + action)
 match action:
  "Bound": note("Lethargic Bind suppresses this action.")
  "Advance":
   if not boss_move(2): fallback()
  "Brace":
   var value := 1 if tuned else 2
   boss.block += value
   note("Brace · +%d Block. Total: %d. Expires at the next boss turn." % [value,boss.block])
  "Distort":
   var t := nearest(targets(2))
   if t < 0: fallback()
   else: last_targets = [t]; heroes[t].weak = true; note(heroes[t].name + " gains Weakness 1 until the next boss turn.")
  "Fracture":
   var ts := targets(1).filter(func(i): return heroes[i].build.any(func(d): return d.any(func(f): return f not in [0,56])))
   var t := nearest(ts)
   if t < 0: fallback()
   else: last_targets = [t]; pending = {"kind":"fracture","hero":t}
  _:
   if action == "Skirmish": boss_move(1)
   var ts := targets(1,action == "Sweep")
   if ts.is_empty():
    if action != "Skirmish": fallback()
   else:
    var victims: Array = ts if action == "Sweep" else [nearest(ts,action == "Strike")]
    last_targets = victims.duplicate()
    note(action + " targets " + ", ".join(victims.map(func(t): return heroes[t].name)))
    pending = {"kind":"attack","action":action,"victims":victims,"reacted":[],"amount":2 if action == "Strike" else 1}
    continue_attack()

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
    if f == 44: trigger = actor != victim and distance(actor,victim) <= 2 and sight(actor,victim,2)
    if f == 45: trigger = actor != victim and distance(actor,3) == 1 and pending.action != "Sweep"
    if f == 46: trigger = actor == victim and pending.amount-int(boss.weak)-heroes[actor].block-heroes[actor].dr >= heroes[actor].hp
    if f == 48: trigger = true
    if trigger:
     pending.kind = "reaction"; pending.hero = actor; pending.die = die; pending.victim = victim
     return
 var victims: Array = pending.victims.duplicate()
 if action != "Sweep" and (heroes[victims[0]].hp <= 0 or distance(3,victims[0]) != 1):
  var ts := targets(1)
  if ts.is_empty():
   pending = {}
   if action != "Skirmish": fallback()
   return
  var t := nearest(ts,action == "Strike")
  pending.victims = [t]; continue_attack(); return
 var amount: int = pending.amount
 pending = {}
 for t in victims:
  # Sweep locks its area after all reactions, and hits each adjacent unit once.
  if action == "Sweep" and distance(3,t) != 1: continue
  damage(t,maxi(0,amount-int(boss.weak)))
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
  match f:
   28:
    var options := targets(1).filter(func(id):return id != t)
    if not options.is_empty(): pending.victims = [nearest(options)]
   44: h.block += 1; heroes[victim].block += 1
   45: pending.victims = [t]
   46: h.defy = true; mutate(t,die,h.rolls[die],0)
   48:
    h.echo_due = false; mutate(t,die,h.rolls[die],0); damage(3,mini(3,h.taken))
    if outcome != "": return
   _:
    if not h.smoke.has(die) or h.smoke[die] == 4: h.block += 1
    if dir != Vector2i.ZERO and legal(t,h.pos+dir): h.pos += dir
    h.smoke.erase(die)
  note(h.name + " uses Reaction · " + FACES[f])
 pending.reacted.append(str(t)+":"+str(die)); pending.kind = "attack"; continue_attack()

func fracture(d: int, side: int) -> void:
 var t: int = pending.hero
 if heroes[t].build[d][side] in [0,56]: return
 note(heroes[t].name + " loses " + FACES[heroes[t].build[d][side]] + " for this encounter.")
 mutate(t,d,side,0)
 if d in heroes[t].reaction and heroes[t].rolls[d] == side: heroes[t].reaction.erase(d)
 pending = {}

func push(dir: Vector2i) -> void:
 var t: int = pending.hero
 if dir not in away_dirs(3,t): return
 pending = {}
 if legal(t,heroes[t].pos+dir): heroes[t].pos += dir
 else:
  damage(t,1,true)
  if outcome != "" or heroes[t].dead or heroes[t].hp == 0: return
  if heroes[t].stun: damage(t,1,true)
  else:
   if heroes[t].used.has(false):
    heroes[t].stun = true
    pending = {"kind":"stun","hero":t}
 note("Drive Back · Forced movement; collision causes 1 unavoidable damage and Stunned.")

func stun_die(d: int) -> void:
 var t: int = pending.hero
 if pending.kind == "preroll_stun":
  if not heroes[t].channel.is_empty() and heroes[t].channel.die == d: return
  heroes[t].setaside = d
  pending = {}
  if not stun_queue.is_empty(): pending = {"kind":"preroll_stun","hero":stun_queue.pop_front()}
  else: shared_roll()
  return
 if heroes[t].used[d]: return
 heroes[t].used[d] = true
 pending = {}

func action_reroll(d: int) -> bool:
 if active >= 3 or outcome != "" or not pending.is_empty(): return false
 var h: Dictionary = heroes[active]
 if not h.opening or h.rerolls <= 0 or h.used[d] or face(active,d) in [9,11,15,56]: return false
 h.rerolls -= 1
 h.rolls[d] = rng.randi_range(0,5)
 h.results[d] = h.build[d][h.rolls[d]]
 if Catalog.is_reaction(face(active,d)): h.reaction.append(d); h.used[d] = true
 on_roll(h,d)
 roll_context = "Action Reroll · keep the new result"
 roll_serial += 1
 note(h.name + " spends a starting reroll · Die %d → %s" % [d+1,FACES[face(active,d)]])
 return true

func boss_help(action: String) -> String:
 match action:
  "Advance": return "Move up to 2 toward the closest standing hero. Already adjacent? Hold position." if tuned else "Move up to 2 toward the closest standing hero; if impossible, use fallback."
  "Skirmish": return "Move 1 toward the closest hero, then attack an adjacent hero for 1. Reactions happen before damage."
  "Strike": return "Attack the closest adjacent standing hero for 2 damage. Ties: lowest Block, then random."
  "Sweep": return "Attack EVERY adjacent hero for 1 each, including Downed heroes. Each hero is hit once."
  "Drive Back": return "Attack an adjacent hero for 1, then push 1 directly away. Collision: 1 unavoidable damage + Stunned."
  "Brace": return "Gain %d Block. Damage consumes Block; any left expires at the boss’s next turn." % (1 if tuned else 2)
  "Distort": return "Closest standing hero within 2 gains Weakness 1 until the next boss turn: Attacks deal 1 less damage."
  "Fracture": return "Closest adjacent hero chooses one installed ability to become Blank for this fight. Earlier rolled results stay."
 return "Resolve one boss die at a time, then end its turn."

func on_roll(h: Dictionary, d: int) -> void:
 var f: int = h.results[d]
 if f == 13: h.rerolls = mini(1,h.rerolls+1)
 if f == 48: h.echo_due = true
 if not h.channel.is_empty() and h.channel.face == 25 and h.channel.die != d:
  if f == 0: h.block += 1
  else: h.channel.boost = mini(2,h.channel.get("boost",0)+1)

func numeric(h: Dictionary, damage_value: bool = false) -> int:
 var value := 0
 var absolute_zero := false
 if h.stored_num >= 0: value = h.stored_num; h.stored_num = -1
 else:
  var side := rng.randi_range(0,5)
  if h.gambler and side == 4: absolute_zero = true
  elif h.gambler and side == 5:
   var base := rng.randi_range(0,4)
   value = 2*(1 if base < 4 or h.numeric_focus else 0)
  else: value = 1 if side < 4 or h.numeric_focus else 0
 h.numeric_focus = false
 if not absolute_zero:
  if not h.channel.is_empty() and h.channel.face == 25: value += h.channel.get("boost",0)
  if damage_value: value += h.num_boost; h.num_boost = 0
 h.numeric_zero = absolute_zero
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
 var value := maxi(0,modified_value(d,base)-int(h.weak or h.bulwark_weak))
 if numeric_attack and h.numeric_zero: value = 0
 var repeats := 1
 if h.backstab >= round_no and target == 3 and rear(active): repeats += 1; h.backstab = 0
 if h.mods.has(d):
  pierce += h.mods[d].get("pierce",0); repeats += h.mods[d].get("repeat",0)
 var lost := 0
 for n in range(repeats):
  if outcome != "": break
  var unit: Dictionary = boss if target == 3 else heroes[target]
  var before: int = unit.hp
  var marked: bool = target == 3 and boss.mark and unit.block == 0 and value > 0
  var power := 1 if target == 3 and not boss.bargain.is_empty() else 0
  var bypass := mini(unit.block,pierce)
  unit.block -= bypass
  damage(target,value+power)
  unit.block += bypass
  lost += maxi(0,before-unit.hp)
  if outcome != "": break
  if marked and before > unit.hp: boss.mark = false; damage(3,1)
  if power > 0 and outcome == "":
   boss.bargain.charges -= 1
   if boss.bargain.charges == 0:
    var owner: int = boss.bargain.owner; boss.bargain = {}; damage(owner,1,true)
 return lost

func rear(id: int) -> bool:
 return heroes[id].pos.y >= boss.pos.y+2 and distance(id,3) == 1

func sight(a: int, b: int, limit: int) -> bool:
 for start_cell in cells(a):
  for end_cell in cells(b):
   if absi(start_cell.x-end_cell.x)+absi(start_cell.y-end_cell.y) > limit: continue
   # A strict orthogonal ray or clear horizontal-then-vertical route; units block sight.
   for first_x in [true,false]:
    var p: Vector2i = start_cell
    var clear := true
    while p != end_cell:
     var dir := Vector2i.ZERO
     if (first_x and p.x != end_cell.x) or p.y == end_cell.y: dir.x = signi(end_cell.x-p.x)
     else: dir.y = signi(end_cell.y-p.y)
     p += dir
     for u in range(4):
      if u in [a,b] or (u < 3 and heroes[u].dead): continue
      if p in cells(u): clear = false
    if clear: return true
 return false

func mutate(hero: int, d: int, side: int, id: int) -> void:
 var h: Dictionary = heroes[hero]
 if h.build[d][side] == 56: return
 h.build[d][side] = id
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
   else: h.gold += 1; mutate(active,d,side,0); note("Gambler's Coin becomes Blank · +1 Gold.")
  10: h.backstab = round_no+1
  11,16,23,26,30,32:
   pending = {"kind":"catalog_choice","hero":active,"die":d,"face":f,"stage":0}
   return true
  12:
   if target < 0 or target == 3 or heroes[target].dead: return false
   if add_to_blank(target,55):
    h.blessings += 1
    if h.blessings >= 2: mutate(active,d,side,0)
  13: pass # The when-rolled charge was already granted.
  14: h.num_boost += 1
  15,19:
   if target < 0 or target >= 3 or target == active or heroes[target].dead or distance(active,target) > 3 or not sight(active,target,3): return false
   var value := numeric(h)
   if f == 19 and not h.numeric_zero: value = maxi(1,value)
   heal(target,value)
   if f == 15: mutate(active,d,side,0); add_to_blank(target,15)
  17:
   if h.stored_num < 0: h.stored_num = 1 if rng.randi_range(0,5) < 4 else 0
  18:
   pending = {"kind":"bind","hero":active,"die":d}
   return true
  20: h.numeric_focus = true
  21: boss.mark = true
  22:
   for other in range(3):
    if other != d and not h.used[other] and face(active,other) != 0: return false
   damage(3,1,true)
  24:
   var attacks: Array = h.build[d].filter(func(id):return Catalog.is_attack(id))
   if not attacks.is_empty():
    var copied: int = attacks[rng.randi_range(0,attacks.size()-1)]
    h.results[d] = copied
    for n in range(2):
     var victims: Array = []
     for id in range(4):
      if id != active and not (id < 3 and heroes[id].dead) and distance(active,id) <= (2 if copied == 35 else 1): victims.append(id)
     if not victims.is_empty():
      h.used[d] = false; hero_action(d,victims[rng.randi_range(0,victims.size()-1)])
     if outcome != "": break
    h.results[d] = 24
  25,31,49:
   if f == 31: h.block += 2
   h.channel = {"die":d,"side":side,"face":f,"boost":0}
   note(h.name + " begins Channel · " + FACES[f])
  27: boss.bargain = {"owner":active,"charges":2}
  28,44,45,46,48: return false # Stored automatically by the roll.
  29: h.debt_buff = 2; h.debt_next = 2
  33:
   if not add_to_blank(active,54): note("No Blank available for Bone Mutation.")
  34,35,36,37,38,39,40,41:
   var range_value := 2 if f == 35 else 1
   if target < 0 or target == active or (target < 3 and heroes[target].dead) or distance(active,target) > range_value: return false
   if f == 35 and not sight(active,target,range_value): return false
   var value := numeric(h,true)
   if f == 35: value = mini(1,value)
   if f == 39 and target == 3 and rear(active): value += 1
   if f == 41:
    var count: int = h.build[d].count(41)
    value += 2 if count >= 6 else (1 if count >= 3 else 0)
   var had_block: bool = (boss.block if target == 3 else heroes[target].block) > 0
   var lost := strike(d,target,value,1 if f == 37 else 0,true)
   if outcome != "": spend(d); return true
   if f == 36 and lost >= 2: h.block += lost
   if f == 40 and target == 3 and had_block and boss.block == 0 and lost > 0:
    var at: int = order.find(3)
    if at > cursor and at < order.size()-1:
     var next: int = order[at+1]; order[at+1] = 3; order[at] = next
     note("Break Rhythm delays the next boss activation one slot.")
   if f == 41:
    var slot: int = h.build[d].find(0)
    if slot < 0:
     for i in range(6):
      if h.build[d][i] not in [41,56]: slot = i; break
    if slot >= 0: mutate(active,d,slot,41)
  42: h.block += numeric_block(d)
  43: h.block += modified_value(d,3 if h.block == 0 else 1)
  47: h.dr = 1; h.bulwark_weak = true
  50: h.block += numeric_block(d,1); h.black_oath = true
  51: h.block += numeric_block(d); h.ward = true
  52:
   h.block += numeric_block(d); spend(d)
   pending = {"kind":"ember","hero":active,"die":d}
   return true
  53:
   if destination not in leap_cells(active): return false
   h.pos = destination
   if distance(active,3) == 1: h.num_boost += 1
  54:
   if destination.x != -99:
    if destination not in reachable(active,1,false): return false
    h.pos = destination
   h.block += 1
  55:
   if target < 0 or target >= 3 or heroes[target].dead or (target != active and distance(active,target) != 1): return false
   heal(target,numeric(h))
  56: pass
  _: return false
 spend(d,true)
 note(h.name + " resolves " + FACES[f] + ".")
 return true

func leap_cells(id: int) -> Array:
 var result: Array = []
 for x in range(-2,3):
  for y in range(-2,3):
   if absi(x)+absi(y) in [1,2]:
    var p: Vector2i = heroes[id].pos+Vector2i(x,y)
    if legal(id,p): result.append(p)
 return result

func channel_choice(keep: bool) -> void:
 var h: Dictionary = heroes[pending.hero]
 var ch: Dictionary = h.channel.duplicate()
 pending = {}
 if keep:
  if ch.face == 31: h.block = mini(8,h.block+1)
  if ch.face == 49: heal(active,1)
  note(h.name + " maintains " + FACES[ch.face])
 else:
  h.channel = {}; h.rolls[ch.die] = rng.randi_range(0,5)
  h.results[ch.die] = h.build[ch.die][h.rolls[ch.die]]; h.used[ch.die] = false
  if Catalog.is_reaction(h.results[ch.die]): h.reaction.append(ch.die); h.used[ch.die] = true
  on_roll(h,ch.die); roll_serial += 1
  note(h.name + " ends Channel and rolls the released die.")

func choose_bind(d: int, action: String) -> void:
 var source: int = pending.die
 boss.binds.append({"owner":active,"die":d,"action":action})
 pending = {}; spend(source)
 note("Bound boss die %d: %s until the binder's next turn." % [d+1,action])

func ember(value: int) -> void:
 var owner: int = pending.hero
 value = mini(value,mini(2,heroes[owner].block))
 heroes[owner].block -= value; pending = {}
 for id in range(4):
  if id != owner and not (id < 3 and heroes[id].dead) and distance(owner,id) == 1: damage(id,value)
  if outcome != "": return

func catalog_pick(hero: int, d: int, side: int = -1) -> bool:
 var p: Dictionary = pending.duplicate()
 var source: int = p.die
 var h: Dictionary = heroes[active]
 var f: int = p.face
 if f == 11:
  if heroes[hero].dead or heroes[hero].hp <= 0: return false
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
  on_roll(h,d); return true
 if f == 23:
  if p.stage == 0:
   if d == source or h.used[d] or face(active,d) == 0: return false
   h.used[d] = true; pending.stage = 1; pending.skipped = d; return true
  if not h.used[d] or d in [source,p.get("skipped",-1)] or not Catalog.can_copy(face(active,d)): return false
  var copy: int = face(active,d); pending = {}; h.results[source] = copy; forced_die = source; return true
 if f == 26:
  if d == source or h.used[d] or face(active,d) != 0: return false
  var options: Array = h.build[d].filter(func(id):return id > 0 and id not in [11,16,23,24,26,56])
  if options.is_empty(): return false
  mutate(active,source,h.rolls[source],56); spend(source)
  h.results[d] = options[0]; pending = {}; forced_die = d; return true
 if f == 30:
  if d == source or h.used[d] or (not Catalog.is_attack(face(active,d)) and face(active,d) not in [4,42,43,50,51,52]): return false
  var n := rng.randi_range(1,6)
  h.mods[d] = {"value":-1 if n == 1 else (1 if n in [2,3,4] else (2 if n == 5 and Catalog.category(face(active,d)) == "Defense" else 0)),"pierce":2 if n == 5 else 0,"repeat":1 if n == 6 else 0}
  note("Ill Omen rolls %d for Die %d." % [n,d+1]); pending = {}; spend(source); return true
 if f == 32:
  if d == source or h.used[d] or face(active,d) not in [2,3,4]: return false
  h.smoke[d] = face(active,d); pending = {}; spend(source); forced_die = d; return true
 return false

func numeric_block(d: int, extra: int = 0) -> int:
 var h: Dictionary = heroes[active]
 var value := numeric(h)
 if h.numeric_zero: return 0
 return modified_value(d,value+extra)
