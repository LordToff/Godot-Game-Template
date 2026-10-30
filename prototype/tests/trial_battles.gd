extends SceneTree
# Deterministic heuristic playtester. Reads visible rolls/board only; never alters live state or RNG.
const Battle = preload("res://prototype/battle.gd")
const Nugh = preload("res://prototype/nugh.gd")
const Catalog = preload("res://prototype/catalog.gd")
var activations := {}
var choice_misses := {}
var errors := 0
func _initialize():call_deferred("run")
func run():
 var count := maxi(1,int(OS.get_environment("ASH_TRIAL_COUNT")))
 var report := {"seeds":count,"policy":"visible-board heuristic v3", "boss":OS.get_environment("ASH_BOSS"),"ignore_worms":OS.get_environment("ASH_IGNORE_WORMS") == "1", "ignore_hazards":OS.get_environment("ASH_IGNORE_HAZARDS") == "1", "scenarios":[]}
 for kit in ["starting","mixed","numeric","support","channel","growth"]:
  for move in [0,1,2]:
   var stat := {"kit":kit,"blank_move":move,"wins":0,"losses":0,"stalls":0,"rounds":0,"phase_two":0,"loss_boss_hp":0,"downings":0,"damage":{},"ability_uses":{}}
   activations = {};choice_misses = {}
   for seed_value in range(1,count+1):
    var g = Nugh.new() if OS.get_environment("ASH_BOSS") == "nugh" else Battle.new();var builds: Array = []
    var picker := RandomNumberGenerator.new();picker.seed = seed_value*173
    var ids: Array = Catalog.extended_ids()
    for hero in range(3):
     if kit == "starting":builds.append(Battle.default_build());continue
     var pair: Array
     match kit:
      "numeric":pair = [[34,37],[35,39],[36,40]][hero]
      "support":pair = [[19,43],[42,44],[47,58]][hero]
      "channel":pair = [[25,37],[31,39],[49,35]][hero]
      "growth":pair = [[41,33],[12,19],[41,43]][hero]
      _:
       var first: int = picker.randi_range(0,ids.size()-1)
       var second: int = picker.randi_range(0,ids.size()-2)
       if second >= first:second += 1
       pair = [ids[first],ids[second]]
     builds.append(Battle.bonus_build(pair))
    g.start(builds,seed_value,move > 0,true,{"soul.move":move})
    var steps := 0
    while g.outcome == "" and steps < 1600 and g.round_no <= 50:
     steps += 1
     if not g.pending.is_empty():resolve_choice(g)
     elif g.active == 3:g.boss_step()
     elif not hero_step(g):
      if g.forced_die >= 0:g.decline(g.forced_die)
      else:g.finish_turn()
     for h in g.heroes:
      if h.hp < 0 or h.hp > h.max_hp or h.block < 0 or (h.dead and h.hp > 0):
       printerr("STATE FAIL ",kit," seed ",seed_value," ",h);errors += 1;quit(1);return
    stat.rounds += g.round_no
    if g.phase_two:stat.phase_two += 1
    match g.outcome:
     "victory":stat.wins += 1
     "defeat":stat.losses += 1;stat.loss_boss_hp += g.boss.hp
     _:
      stat.stalls += 1
      var file := FileAccess.open("/tmp/trial-stall-%s-%d-%d.log" % [kit,move,seed_value],FileAccess.WRITE)
      file.store_string(str(g.pending)+"\n"+"\n".join(g.log_lines))
    for e in g.event_log:
     if e.text.contains("is Downed"):stat.downings += 1
     if e.kind == "damage" and e.target in [0,1,2]:stat.damage[e.action] = int(stat.damage.get(e.action,0))+e.value
   stat.ability_uses = activations.duplicate();stat["declined_choices"] = choice_misses.duplicate()
   stat["mean_rounds"] = snappedf(float(stat.rounds)/count,0.01)
   stat["mean_boss_hp_in_losses"] = snappedf(float(stat.loss_boss_hp)/maxi(1,stat.losses),0.01)
   report.scenarios.append(stat)
   print("TRIAL ",kit," blank=",move," W/L/S=",stat.wins,"/",stat.losses,"/",stat.stalls," mean_rounds=",stat.mean_rounds," bossHP/loss=",stat.mean_boss_hp_in_losses," phaseII=",stat.phase_two," choices_declined=",choice_misses)
 var path := OS.get_environment("ASH_TRIAL_REPORT")
 if path == "":path = "/tmp/ash-trial-report.json"
 var out := FileAccess.open(path,FileAccess.WRITE);out.store_string(JSON.stringify(report,"  "))
 print("TRIAL COMPLETE: ",count*18," encounters; report=",path)
 quit(1 if errors or report.scenarios.any(func(s):return s.stalls > 0) else 0)

func face_value(g, id: int, f: int) -> float:
 var h: Dictionary = g.heroes[id]
 if Catalog.is_attack(f):return 8.0 if g.distance(id,3) <= g.face_range(f) else 1.0
 if f in [7,15,19,55]:
  for ally in range(3):
   if not g.heroes[ally].dead and g.heroes[ally].hp < g.heroes[ally].max_hp and (ally == id or g.distance(id,ally) <= g.face_range(f)):return 9.0
  return 0.1
 if f in [2,3,53,57,58]:return 7.0 if g.distance(id,3) > 1 or h.pos in g.brand_cells else 0.4
 if f == 0:return 0.0
 if f == 56:return -1.0
 if f in [4,42,43,44,45,46,47,50,51,52]:return 3.0
 return 2.0

func movement_value(g, id: int, p: Vector2i) -> float:
 var value: float = -g.distance(id,3,p)*1.1
 # Escape a delayed explosion, avoid edge collisions and persistent fire when equivalent.
 if OS.get_environment("ASH_IGNORE_HAZARDS") != "1" and p in g.brand_cells:value -= 3.0*g.v("boss.brand.damage")
 if OS.get_environment("ASH_IGNORE_HAZARDS") != "1" and p in g.fire_tiles:value -= 3.0*g.v("boss.fire.end_turn")
 if p.x in [0,8] or p.y in [0,8]:value -= 0.15
 return value

func use_action(g, d: int, target: int = -1, dest: Vector2i = Vector2i(-99,-99)) -> bool:
 var f: int = g.face(g.active,d)
 var result: bool = g.hero_action(d,target,dest)
 if result:activations[str(f)] = int(activations.get(str(f),0))+1
 return result

func hero_step(g) -> bool:
 var id: int = g.active;var h: Dictionary = g.heroes[id]
 if h.dead or h.hp <= 0:return false
 if h.opening and h.rerolls > 0:
  for d in range(3):
   if h.used[d] or g.face(id,d) != 0:continue
   if g.reward and g.soul_remaining(id) > 0:
    var moves: Array = g.reachable(id,g.v("soul.move"),false)
    if moves.any(func(p):return movement_value(g,id,p) > movement_value(g,id,h.pos)+0.1):continue
   if g.action_reroll(d):return true
 # Setup boosts before their attacks. Healing and escape take precedence over damage.
 var dice: Array = [0,1,2]
 dice.sort_custom(func(a,b):return priority(g,id,a) > priority(g,id,b))
 for d in dice:
  if h.used[d] or (g.forced_die >= 0 and g.forced_die != d):continue
  var f: int = g.face(id,d)
  if Catalog.is_attack(f):
   if g.encounter_id == "nugh" and g.phase_two and g.distance(id,3) <= g.face_range(f) and (f != 35 or g.sight(id,3,g.face_range(f))) and use_action(g,d,3):return true
   if OS.get_environment("ASH_IGNORE_WORMS") != "1":
    var enemies: Array = g.living_minions()
    enemies.sort_custom(func(a,b):return g.distance(id,a) < g.distance(id,b))
    for enemy in enemies:
     if g.distance(id,enemy) <= g.face_range(f) and (f != 35 or g.sight(id,enemy,g.face_range(f))) and use_action(g,d,enemy):return true
   if g.distance(id,3) <= g.face_range(f) and (f != 35 or g.sight(id,3,g.face_range(f))) and use_action(g,d,3):return true
   continue
  match f:
   0,2,3,53,54,57:
    if f == 0 and (not g.reward or g.soul_remaining(id) <= 0):continue
    var options: Array = g.leap_cells(id) if f == 53 else g.reachable(id,g.move_steps(f),f == 3)
    var best: Vector2i = h.pos;var score: float = movement_value(g,id,best)
    for pos in options:
     var candidate: float = movement_value(g,id,pos)
     if candidate > score+0.01:best = pos;score = candidate
    if best != h.pos and use_action(g,d,-1,best):return true
    if f == 54 and use_action(g,d):return true
   6:
    var worst := -1;var score := 100.0
    for other in range(3):
     if other == d or h.used[other]:continue
     var value: float = face_value(g,id,g.face(id,other))
     if value < score:score = value;worst = other
    if worst >= 0 and score < 2 and use_action(g,d,worst):return true
   7,15,19,55:
    var allies: Array = [0,1,2];allies.sort_custom(func(a,b):return g.heroes[a].hp < g.heroes[b].hp)
    for ally in allies:
     if not g.heroes[ally].dead and g.heroes[ally].hp < g.heroes[ally].max_hp and use_action(g,d,ally):return true
   12:
    for ally in [id,(id+1)%3,(id+2)%3]:
     if use_action(g,d,ally):return true
   58:
    for ally in range(3):
     if ally != id and movement_value(g,id,g.heroes[ally].pos) > movement_value(g,id,h.pos)+0.2 and use_action(g,d,ally):return true
   8:pass # No Shove in default body; keep forced uses optional.
   _:
    if f not in [5,28,44,45,46,48,56] and use_action(g,d):return true
 return false

func priority(g, id: int, d: int) -> float:
 var f: int = g.face(id,d)
 if f in [7,15,19,55]:return 50.0
 if OS.get_environment("ASH_IGNORE_HAZARDS") != "1" and f in [0,2,3,53,57] and (g.heroes[id].pos in g.brand_cells or g.heroes[id].pos in g.fire_tiles):return 45.0
 if f in [10,14,20,21,27,29,30,32]:return 40.0
 if Catalog.is_attack(f):return 30.0
 if f in [0,2,3,53,57,58]:return 20.0
 if f == 22:return -10.0
 return 10.0

func resolve_choice(g) -> void:
 var p: Dictionary = g.pending.duplicate(true)
 match p.kind:
  "reaction":
   var f: int = g.face(p.hero,p.die)
   if f == 48 and g.heroes[p.hero].taken == 0:g.react(false);return
   if f == 45 and g.heroes[p.hero].hp < g.heroes[p.victim].hp:g.react(false);return
   var dir := Vector2i.ZERO
   if f in [5,2,3] and g.heroes[p.hero].get("rooted",0) <= 0:
    var score: float = movement_value(g,p.hero,g.heroes[p.hero].pos)
    for delta in Battle.DIRS:
     var pos: Vector2i = g.heroes[p.hero].pos+delta
     if g.legal(p.hero,pos) and movement_value(g,p.hero,pos) > score+0.1:dir = delta;score = movement_value(g,p.hero,pos)
   g.react(true,dir)
  "fracture":
   var best := Vector2i(-1,-1);var score := 1000.0
   for d in range(3):
    for s in range(6):
     var f: int = g.heroes[p.hero].build[d][s]
     if f in [0,56]:continue
     var value: float = face_value(g,p.hero,f)
     if value < score:score = value;best = Vector2i(d,s)
   if best.x >= 0:g.fracture(best.x,best.y)
  "stun","preroll_stun":
   var dice: Array = [0,1,2];dice.sort_custom(func(a,b):return face_value(g,p.hero,g.face(p.hero,a)) < face_value(g,p.hero,g.face(p.hero,b)))
   for d in dice:
    if p.kind == "stun" and g.heroes[p.hero].used[d]:continue
    if p.kind == "preroll_stun" and not g.heroes[p.hero].channel.is_empty() and g.heroes[p.hero].channel.die == d:continue
    g.stun_die(d);return
  "push":g.push(p.get("direction",g.impact_direction(p.hero)))
  "channel":g.channel_choice(true)
  "bind":
   if g.encounter_id == "nugh":g.choose_bind(1,"Brood Command")
   else:g.choose_bind(0,"Smoking Strike")
  "ember":
   var value := 0
   if g.distance(p.hero,3) <= g.v("face52.range"):
    value = mini(g.v("face52.burn"),g.heroes[p.hero].block)
    if g.heroes.any(func(h):return h != g.heroes[p.hero] and not h.dead and h.hp > 0 and g.distance(p.hero,g.heroes.find(h)) <= g.v("face52.range") and h.hp <= value):value = 0
   g.ember(value)
  "slot":
   for d in range(3):
    for s in range(6):
     if g.choose_slot(d,s):return
  "catalog_choice":
   var candidates: Array = []
   for hero in range(3):
    for d in range(3):
     if p.face in [16,26] and (p.face == 16 or p.stage == 1):
      for s in range(6):candidates.append({"hero":hero,"d":d,"s":s,"value":face_value(g,hero,g.heroes[hero].build[d][s])})
     else:
      var value: float = face_value(g,hero,g.face(hero,d))
      if p.face == 23 and p.stage == 0:value = -value
      candidates.append({"hero":hero,"d":d,"s":-1,"value":value})
   candidates.sort_custom(func(a,b):return a.value > b.value)
   for c in candidates:
    if g.catalog_pick(c.hero,c.d,c.s):return
   # Same explicit UI option: spend this face with no effect when no legal copy exists.
   choice_misses[str(p.face)] = int(choice_misses.get(str(p.face),0))+1
   g.pending = {};g.decline(p.die)
  _:printerr("UNSUPPORTED CHOICE ",p);errors += 1
