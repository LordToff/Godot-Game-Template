extends SceneTree
const Lab = preload("res://prototype/lab.gd")
const B = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("WORM PATH FAIL: ",why)
func fixture():
 var g = Lab.create(59)
 g.balance["face59.hit_faces"] = 6
 check(g.hero_action(0,-1,Vector2i(4,5)),"summon behind the three-hero line")
 return g
func _initialize():call_deferred("run")
func run():
 var g = fixture();var id: int = g.owned_worm(0);var origin: Vector2i = g.unit_data(id).pos
 var before: int = g.distance(id,3)
 g.finish_turn()
 check(g.active == 1,"owner ends turn and initiative advances normally")
 check(g.unit_data(id).pos == Vector2i(6,5),"owner-end activation takes two legal detour steps")
 check(g.distance(id,3) > before,"detour can initially increase distance instead of freezing")
 check(g.unit_data(id).pos != origin and g.legal(id,g.unit_data(id).pos),"worm moves without landing on occupied tiles")
 origin = g.unit_data(id).pos;g.finish_turn()
 check(g.unit_data(id).pos == origin,"another hero ending turn does not activate this worm")
 g.active = 0;g.cursor = 0;var hp: int = g.boss.hp;g.finish_turn()
 check(g.unit_data(id).pos == Vector2i(6,3) and g.distance(id,3) == 1,"next owner-end activation completes route within two steps")
 check(g.boss.hp == hp-1 and g.boss.poison == 1,"worm bites and poisons after reaching the enemy")
 g = fixture();id = g.owned_worm(0);g.heroes[0].used[0] = false
 check(g.hero_action(0),"Command spends another result on the living worm")
 check(g.unit_data(id).pos == Vector2i(6,5),"Command also follows the complete detour")
 g.finish_turn();check(g.unit_data(id).pos == Vector2i(6,3),"normal owner-end movement still follows Command")
 g = fixture();id = g.owned_worm(0);g.unit_data(id).rooted = 1;g.finish_turn()
 check(g.unit_data(id).pos == Vector2i(4,5),"Rooted still prevents movement")
 g = fixture();id = g.owned_worm(0)
 g.heroes[1].pos = Vector2i(3,5);g.heroes[2].pos = Vector2i(5,5)
 var ally: int = g.spawn_friendly(1,Vector2i(3,6));g.unit_data(ally).pos = Vector2i(4,6)
 g.finish_turn();check(g.unit_data(id).pos == Vector2i(4,5),"truly surrounded worm cannot pass through allies")
 check(g.event_log.any(func(e):return e.source == id and e.text.contains("no legal route")),"blocked movement is explained in the log")
 g = fixture();id = g.owned_worm(0)
 g.minions.append({"name":"Enemy worm","faction":"enemy","kind":"worm","hp":2,"max_hp":2,"block":0,"dead":false,"pos":Vector2i(5,5)})
 var enemy: int = g.unit_count()-1;g.finish_turn()
 check(g.unit_data(id).pos == Vector2i(4,5) and g.unit_data(enemy).hp == 1,"already adjacent enemy is bitten without wandering")
 # Every starting hero, every available adjacent summon cell: if movement is
 # possible, each activation is bounded and reaches an enemy across the board.
 for hero in range(3):
  g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],17)
  var positions: Array = g.summon_cells(hero)
  for pos in positions:
   var f = B.new();f.start([B.default_build(),B.default_build(),B.default_build()],17)
   id = f.spawn_friendly(hero,pos)
   for turn in range(12):
    origin = f.unit_data(id).pos;f.move_summon(id,2)
    var after: Vector2i = f.unit_data(id).pos
    check(absi(after.x-origin.x)+absi(after.y-origin.y) <= 2,"movement allowance is at most two orthogonal steps")
    check(f.legal(id,after),"all starting placements keep occupancy legal")
    if f.distance(id,3) == 1:break
   check(f.distance(id,3) == 1,"every unblocked starting placement reaches the boss")
 print("V0.22.1 WORM PATH: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
