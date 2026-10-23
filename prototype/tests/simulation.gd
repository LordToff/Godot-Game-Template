extends SceneTree
const Battle = preload("res://prototype/battle.gd")
func _initialize(): call_deferred("run")
func run():
 var wins := 0; var losses := 0; var stalled := 0; var max_round := 0
 for seed_value in range(1,101):
  var g = Battle.new()
  g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],seed_value)
  var actions := 0
  while g.outcome == "" and actions < 3000 and g.round_no < 70:
   actions += 1
   if not g.pending.is_empty():
    var p: Dictionary = g.pending
    match p.kind:
     "reaction": g.react(true)
     "fracture":
      var done := false
      for d in range(3):
       for s in range(6):
        if not done and g.heroes[p.hero].build[d][s] != 0:
         g.fracture(d,s); done = true
     "push":
      var dirs: Array = g.away_dirs(3,p.hero)
      if dirs.is_empty(): printerr("No push direction"); quit(1); return
      var choice: Vector2i = dirs[0]
      for dir in dirs:
       if g.legal(p.hero,g.heroes[p.hero].pos+dir): choice = dir; break
      g.push(choice)
     "stun","preroll_stun":
      var choice := 0
      for d in range(3):
       if p.kind == "preroll_stun" or not g.heroes[p.hero].used[d]: choice = d; break
      g.stun_die(choice)
    continue
   if g.active == 3: g.boss_step(); continue
   var id: int = g.active; var h: Dictionary = g.heroes[id]
   var rerolled := false
   if h.opening and h.rerolls > 0:
    for d in range(3):
     if not h.used[d] and g.face(id,d) == 0:
      rerolled = g.action_reroll(d); break
   if rerolled: continue
   var did := false
   for d in range(3):
    if did or h.used[d] or (g.forced_die >= 0 and g.forced_die != d): continue
    var f: int = g.face(id,d)
    match f:
     1:
      if g.distance(id,3) == 1: did = g.hero_action(d,3)
     4: did = g.hero_action(d)
     7:
      var ts: Array = []
      for i in range(3):
       if not g.heroes[i].dead and g.heroes[i].hp < 6 and (i == id or g.distance(id,i) == 1):ts.append(i)
      ts.sort_custom(func(a,b):return g.heroes[a].hp < g.heroes[b].hp)
      if not ts.is_empty():did = g.hero_action(d,ts[0])
     2,3,0:
      if f == 0 and not g.reward: continue
      var options: Array = g.reachable(id,1 if f == 2 else (3 if f == 3 else 2),f == 3)
      var best: Vector2i = h.pos; var dist: int = g.distance(id,3)
      for p in options:
       var dd: int = g.distance(id,3,p)
       if dd < dist: dist = dd; best = p
      if best != h.pos: did = g.hero_action(d,-1,best)
     6:
      for other in range(3):
       if other != d and not h.used[other] and g.face(id,other) == 0:
        did = g.hero_action(d,other); break
   if not did:
    if g.forced_die >= 0: g.spend(g.forced_die)
    else: g.finish_turn()
  max_round = maxi(max_round,g.round_no)
  if g.outcome == "victory":wins += 1
  elif g.outcome == "defeat":losses += 1
  else:stalled += 1
 print("SIMULATION: 100 seeded encounters; wins=%d losses=%d stalls=%d max_round=%d" % [wins,losses,stalled,max_round])
 quit(1 if stalled else 0)
