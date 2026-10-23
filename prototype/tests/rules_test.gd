extends SceneTree
const Battle = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1; printerr("FAIL: ",message)
func fresh():
 var g = Battle.new()
 g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],71,false,false)
 g.pending = {}; g.active = 0
 return g
func set_faces(g, id: int, faces: Array) -> void:
 g.heroes[id].results = faces.duplicate(); g.heroes[id].rolls = [0,0,0]; g.heroes[id].used = [false,false,false]; g.heroes[id].reaction = []
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 expect(Battle.validate(Battle.default_build()) == "","balanced build legal")
 var b = Battle.default_build(); b[0] = [1,1,1,1,2,0]
 expect(Battle.validate(b) != "","Blank minimum enforced")
 b = Battle.default_build(); b[0] = [1,1,1,0,0,0]; b[1] = [1,1,1,0,0,0]
 expect(Battle.validate(b) != "","finite face ownership enforced")
 var g = fresh()
 expect(g.boss.hp == 18 and g.heroes.all(func(h): return h.hp == 6),"correct starting HP")
 expect(g.cells(3).size() == 4,"boss has 2x2 footprint")
 expect(not g.legal(0,g.boss.pos),"cannot enter occupied boss footprint")
 expect(not g.legal(3,Vector2i(8,8)),"entire boss footprint must fit")
 g.heroes[0].pos = Vector2i(2,3)
 expect(g.distance(0,3) == 1,"boss edge contact is adjacent")
 g.heroes[0].pos = Vector2i(2,2)
 expect(g.distance(0,3) == 2,"diagonal corners are not adjacent")
 set_faces(g,0,[3,1,4]); g.heroes[0].pos = Vector2i(1,7)
 var paths: Array = g.reachable(0,3,true)
 expect(Vector2i(1,4) in paths and Vector2i(2,6) not in paths,"Stride goes straight and cannot turn")
 expect(not g.hero_action(0,-1,Vector2i(2,6)),"illegal movement is not spent")
 expect(not g.heroes[0].used[0],"invalid action preserves result")
 expect(g.hero_action(0,-1,Vector2i(1,5)),"Stride may stop early")
 g = fresh(); g.heroes[0].pos = Vector2i(2,3); set_faces(g,0,[1,4,7])
 g.boss.block = 1; g.hero_action(0,3)
 expect(g.boss.hp == 18 and g.boss.block == 0,"Block absorbs damage and is consumed")
 g.heroes[0].weak = true; g.heroes[0].used[0] = false; g.hero_action(0,3)
 expect(g.boss.hp == 18,"Weakness affects Strike")
 g.hero_action(1)
 expect(g.heroes[0].block == 1,"Weakness does not reduce Guard")
 g.damage(0,100)
 expect(g.heroes[0].hp == 0 and not g.heroes[0].dead,"first hit discards overkill and Downs")
 g.damage(0,1,true)
 expect(not g.heroes[0].dead,"Downed protection lasts through full acting turn")
 g.heroes[0].protected = false; g.damage(0,1)
 expect(g.heroes[0].dead,"later damage kills unprotected Downed hero")
 g = fresh(); g.damage(1,6); g.heal(1)
 expect(g.heroes[1].hp == 1 and g.heroes[1].broken and g.recovery == [1],"healing revives and queues recovery")
 g.finish_turn()
 expect(g.active == 1 and g.recovery_active,"recovery follows entire acting turn")
 expect(g.heroes[1].rolls.size() == 3,"recovery freshly rolls Action Dice")
 g.damage(1,1)
 expect(g.heroes[1].dead,"Broken overrides initial Downed protection")
 g = fresh(); g.heroes[0].pos = Vector2i(2,3); set_faces(g,0,[8,1,0])
 var hp: int = g.boss.hp
 expect(g.hero_action(0,3,Vector2i.RIGHT),"Shove affects whole boss")
 expect(g.boss.pos == Vector2i(4,3) and g.boss.hp == hp,"boss rigid footprint shifts without damage")
 g = fresh(); set_faces(g,0,[1,4,7]); g.pending = {"kind":"fracture","hero":0}
 g.heroes[0].build[0][0] = 1; g.fracture(0,0)
 expect(g.heroes[0].build[0][0] == 0,"Fracture blanks selected installed face")
 expect(g.face(0,0) == 1,"Fracture preserves already recorded unused result")
 g = fresh(); g.active = 3; g.heroes[0].pos = Vector2i(2,3); g.heroes[1].pos = Vector2i(7,7); g.heroes[2].pos = Vector2i(0,8)
 g.heroes[0].results[1] = 5; g.heroes[0].reaction = [1]; g.pending = {"kind":"attack","action":"Strike","victims":[0],"reacted":[],"amount":2}
 g.continue_attack()
 expect(g.pending.kind == "reaction","attack opens stored Reaction window")
 g.react(true,Vector2i.LEFT)
 expect(g.heroes[0].hp == 6 and g.heroes[0].block == 1,"Reaction movement avoids attack; fallback replaces it")
 expect(g.pending.is_empty(),"reaction resolution completes without stale prompt")
 g = fresh(); g.active = 3; g.boss_rolls = ["Brace","Brace","Brace"]; g.boss_index = 0
 for i in range(3):g.boss_step()
 expect(g.boss.block == 6 and g.boss_index == 3,"boss resolves exactly three dice in order")
 g = fresh(); var initial_order: Array = g.order.duplicate(); g.new_round()
 expect(g.order == initial_order,"initiative stays fixed between rounds")
 g = fresh(); g.boss.hp = 1; g.damage(3,1)
 expect(g.outcome == "victory","boss zero ends battle immediately")
 var hp_before: int = g.heroes[0].hp; g.damage(0,6)
 expect(g.heroes[0].hp == hp_before,"no later effect resolves after victory")
 g = fresh()
 for i in range(3):g.damage(i,6)
 expect(g.outcome == "defeat","all Downed is immediate party loss")
 g = fresh(); g.reward = true; set_faces(g,0,[0,0,0]); var dest: Vector2i = g.heroes[0].pos+Vector2i.UP*2
 expect(g.hero_action(0,-1,dest) and g.heroes[0].pos == dest,"reward Soul spends Blank as Move 2")
 g = fresh(); g.heroes[0].stun = true; g.new_round()
 expect(g.pending.kind == "preroll_stun", "Stunned choice occurs before shared roll")
 g.stun_die(1)
 expect(g.pending.is_empty() and g.heroes[0].used[1] and 1 not in g.heroes[0].reaction,"set-aside die cannot store a Reaction")
 g = fresh(); set_faces(g,0,[6,0,4]); g.heroes[0].build[1] = [1,1,1,1,1,1]
 expect(g.hero_action(0,1) and g.forced_die == 1,"Focus queues its fresh result for immediate resolution")
 expect(not g.hero_action(2),"another face cannot interrupt Focus fresh resolution")
 g.spend(1)
 expect(g.forced_die == -1,"declining fresh result releases Focus constraint")
 print("RULE TESTS: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
