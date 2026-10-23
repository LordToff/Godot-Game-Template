class_name AshBattle
extends RefCounted

const FACES = ["Blank", "Strike", "Step", "Stride", "Guard", "Reaction", "Focus", "First Aid", "Shove"]
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

static func default_build() -> Array:
 return [[1,2,4,0,0,0], [1,3,5,0,0,0], [1,7,6,0,0,0]]

static func validate(build: Array) -> String:
 var counts := []
 counts.resize(9)
 counts.fill(0)
 for die in build:
  if die.count(0) < 3: return "Every die needs at least 3 Blanks."
  for f in die: counts[f] += 1
 for i in range(1,9):
  if counts[i] > CAPS[i]: return "Not enough owned copies of " + FACES[i] + "."
 if counts[2]+counts[3] > 3 or counts[4]+counts[5] > 3 or counts[6]+counts[7]+counts[8] > 3:
  return "Broken Body allows at most 3 of each: Movement, Defense, Skill."
 return ""

func start(builds: Array, seed_value: int = 0, soul: bool = false) -> void:
 rng.randomize()
 if seed_value: rng.seed = seed_value
 reward = soul
 heroes.clear(); order.clear(); log_lines.clear(); recovery.clear(); replaced.clear()
 pending = {}; outcome = ""; forced_die = -1; stun_queue.clear(); cursor = 0; round_no = 0; recovery_active = false
 for i in range(3):
  heroes.append({"name":["VESPER","ROOK","WREN"][i], "hp":6,"block":0,"pos":Vector2i(2+i*2,7),"dead":false,"broken":false,"protected":false,"weak":false,"stun":false,"setaside":-1,"build":builds[i].duplicate(true),"rolls":[],"results":[],"used":[],"reaction":[],"initiative":rng.randi_range(1,6)})
  order.append(i)
 boss = {"hp":18,"block":0,"pos":Vector2i(3,3),"initiative":rng.randi_range(1,6)}
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
 for h in heroes:
  h.reaction.clear()
  if h.hp > 0 and not h.dead: roll_hero(h)
 boss_rolls.clear()
 for die in BOSS_DICE: boss_rolls.append(die[rng.randi_range(0,5)])
 note("Round %d · All available dice rolled together." % round_no)
 activate()

func roll_hero(h: Dictionary) -> void:
 h.rolls = []; h.results = []; h.used = []; h.reaction = []
 for d in range(3):
  var side := rng.randi_range(0,5)
  h.rolls.append(side); h.results.append(h.build[d][side]); h.used.append(d == h.setaside)
  if d != h.setaside and h.build[d][side] == 5:
   h.reaction.append(d); h.used[d] = true


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
  h.block = 0
  note(h.name + " · Choose your dice order.")

func finish_turn() -> void:
 if outcome != "" or not pending.is_empty(): return
 forced_die = -1
 for h in heroes: h.protected = false
 if active < 3: heroes[active].stun = false
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
 if id < 3 and h.hp == 0:
  if amount > 0 and not h.protected: h.dead = true; note(h.name + " is slain.")
 elif amount > 0:
  h.hp = maxi(0,h.hp-amount)
  note(("The Hollow" if id == 3 else h.name) + " loses %d HP." % amount)
  if id < 3 and h.hp == 0:
   if h.broken: h.dead = true; note(h.name + " is slain — Broken.")
   else:
    h.protected = true; h.block = 0; h.weak = false; h.stun = false
    h.reaction.clear(); h.used = [true,true,true]
    note(h.name + " is Downed. Protected until this full turn ends.")
 check_end()

func heal(id: int) -> void:
 var h: Dictionary = heroes[id]
 if h.dead: return
 if h.hp == 0:
  h.broken = true; h.protected = false; recovery.append(id)
 h.hp = mini(6,h.hp+1)
 note(h.name + " recovers 1 HP.")

func face(id: int, d: int) -> int:
 return heroes[id].results[d]

func spend(d: int) -> void:
 heroes[active].used[d] = true
 if forced_die == d: forced_die = -1

func hero_action(d: int, target: int = -1, destination: Vector2i = Vector2i(-99,-99)) -> bool:
 if active == 3 or outcome != "" or not pending.is_empty(): return false
 var h: Dictionary = heroes[active]
 if h.used[d] or (forced_die >= 0 and forced_die != d): return false
 var f := face(active,d)
 match f:
  0:
   if reward and destination.x != -99:
    if not reachable(active,2,false).has(destination): return false
    h.pos = destination
  1:
   if target < 0 or target == active or distance(active,target) != 1: return false
   damage(target,maxi(0,1-int(h.weak)))
  2,3:
   if not reachable(active,1 if f == 2 else 3,f == 3).has(destination): return false
   h.pos = destination
  4: h.block += 1
  6:
   if target < 0 or target == d or h.used[target]: return false
   spend(d)
   h.rolls[target] = rng.randi_range(0,5)
   h.results[target] = h.build[target][h.rolls[target]]
   note(h.name + " focuses Die " + str(target+1) + " → " + FACES[face(active,target)])
   if face(active,target) == 5: h.used[target] = true; h.reaction.append(target)
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
 spend(d)
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
 note("The Hollow · " + action)
 match action:
  "Advance":
   if not boss_move(2): fallback()
  "Brace": boss.block += 2
  "Distort":
   var t := nearest(targets(2))
   if t < 0: fallback()
   else: heroes[t].weak = true; note(heroes[t].name + " gains Weakness 1 until the next boss turn.")
  "Fracture":
   var ts := targets(1).filter(func(i): return heroes[i].build.any(func(d): return d.any(func(f): return f != 0)))
   var t := nearest(ts)
   if t < 0: fallback()
   else: pending = {"kind":"fracture","hero":t}
  _:
   if action == "Skirmish": boss_move(1)
   var ts := targets(1,action == "Sweep")
   if ts.is_empty():
    if action != "Skirmish": fallback()
   else:
    var victims: Array = ts if action == "Sweep" else [nearest(ts,action == "Strike")]
    pending = {"kind":"attack","action":action,"victims":victims,"reacted":[],"amount":2 if action == "Strike" else 1}
    continue_attack()

func continue_attack() -> void:
 if pending.is_empty() or outcome != "": return
 var action: String = pending.action
 for t in pending.victims:
  if t not in pending.reacted and not heroes[t].reaction.is_empty() and heroes[t].hp > 0:
   pending.kind = "reaction"; pending.hero = t; return
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
  damage(t,amount)
  if outcome != "": return
  if action == "Drive Back": pending = {"kind":"push","hero":t}; return

func react(use: bool, dir: Vector2i = Vector2i.ZERO) -> void:
 var t: int = pending.hero
 if use:
  heroes[t].reaction.pop_front(); heroes[t].block += 1
  if dir != Vector2i.ZERO and legal(t,heroes[t].pos+dir): heroes[t].pos += dir
  note(heroes[t].name + " reacts · +1 Block" + (" and steps away." if dir != Vector2i.ZERO else "."))
  if not heroes[t].reaction.is_empty(): return
 pending.reacted.append(t); pending.kind = "attack"; continue_attack()

func fracture(d: int, side: int) -> void:
 var t: int = pending.hero
 if heroes[t].build[d][side] == 0: return
 note(heroes[t].name + " loses " + FACES[heroes[t].build[d][side]] + " for this encounter.")
 heroes[t].build[d][side] = 0
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
  heroes[t].setaside = d
  pending = {}
  if not stun_queue.is_empty(): pending = {"kind":"preroll_stun","hero":stun_queue.pop_front()}
  else: shared_roll()
  return
 if heroes[t].used[d]: return
 heroes[t].used[d] = true
 pending = {}
