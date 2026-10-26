extends SceneTree
const Battle = preload("res://prototype/battle.gd")
const Lab = preload("res://prototype/lab.gd")
const Balance = preload("res://prototype/balance.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String):
 checks += 1
 if not ok:failures += 1;printerr("BALANCE FAIL: ",message)
func fresh(face: int, values: Dictionary = {}):return Lab.create(face,-1,values)
func _initialize():call_deferred("run")
func run():
 check(Balance.validate({}) == "","defaults are valid")
 check(Balance.validate({"not_a_setting":2}) != "","unknown imported settings rejected")
 check(Balance.validate({"soul.move":2.5}) != "","fractional settings rejected")
 check(Balance.validate({"hero.hp":0}) != "","unsafe HP limit rejected")
 check(Balance.validate({"initiative.min":7,"initiative.max":6}) != "","inverted initiative rejected")
 check(Balance.INDEX.size() == Balance.DEFINITIONS.size(),"every numeric key is unique")
 var g = Battle.new();g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],311,false,true,{"hero.hp":12,"hero.rerolls":3,"hero.reroll_cap":5,"boss.hp":50,"initiative.min":3,"initiative.max":3})
 check(g.heroes.all(func(h):return h.hp == 12 and h.max_hp == 12 and h.rerolls == 3),"starting HP and resources use the profile")
 check(g.boss.hp == 50 and g.boss.max_hp == 50,"boss HP uses the profile")
 check(g.heroes.all(func(h):return h.initiative == 3) and g.boss.initiative == 3,"initiative bounds are effective")
 var body := {"body.blanks":3,"body.Skill":0,"owned.1":0}
 var build := Battle.default_build(body)
 check(Battle.validate(build,-1,body) == "" and build.all(func(d):return d.count(0) >= 3 and 1 not in d),"body and inventory passives produce legal starter builds")
 g = fresh(0,{"soul.move":4,"soul.uses":2});g.reward = true
 g.heroes[0].results = [0,0,0]
 check(g.hero_action(0,-1,Vector2i(4,7)),"custom Soul permits a move beyond default range")
 check(g.soul_remaining(0) == 1,"first conversion leaves a second use")
 check(g.hero_action(1,-1,Vector2i(7,7)),"second conversion uses the configured allowance")
 check(not g.hero_action(2,-1,Vector2i(7,8)) and g.soul_remaining(0) == 0,"third conversion is blocked")
 g.cursor = 0;g.active = 0;g.activate()
 check(g.soul_remaining(0) == 2,"the configured allowance refreshes on a real turn start")
 g = fresh(1,{"face1.damage":5,"face1.range":3});g.boss.pos = Vector2i(4,0)
 check(g.hero_action(0,3) and g.boss.hp == 25,"Basic Strike damage and range are independently tunable")
 g = fresh(2,{"face2.move":4});check(g.hero_action(0,-1,Vector2i(4,8)),"Step movement uses its configured distance")
 g = fresh(7,{"face7.heal":3,"face7.range":4});g.heroes[1].pos = Vector2i(0,4)
 check(g.hero_action(0,1) and g.heroes[1].hp == 6,"First Aid healing and range are effective")
 for id in range(34,42):
  var values := {"numeric.tuned_bonus":0,"face35.cap":99,"face39.rear":0,"face41.bonus1":0,"face41.bonus2":0,"face41.copies":2}
  values["face%d.numeric_multiplier" % id] = 0;values["face%d.numeric_bonus" % id] = 4
  g = fresh(id,values);g.heroes[0].stored_num = 0
  check(g.hero_action(0,3) and g.boss.hp == 26,"Numeric multiplier / bonus applied to Attack %d" % id)
  if id == 41:check(g.heroes[0].build[0].count(41) == 3,"Engrave copies use their own tuning")
 for id in [15,19,55]:
  var values := {};values["face%d.numeric_multiplier" % id] = 0;values["face%d.numeric_bonus" % id] = 3
  g = fresh(id,values);g.heroes[0].stored_num = 0;g.heroes[1].hp = 1
  check(g.hero_action(0,1) and g.heroes[1].hp == 4,"Numeric healing scaling applied to face %d" % id)
 for id in [42,50,51,52]:
  var values := {"face50.block":0};values["face%d.numeric_multiplier" % id] = 0;values["face%d.numeric_bonus" % id] = 4
  g = fresh(id,values);g.heroes[0].stored_num = 0
  check(g.hero_action(0) and g.heroes[0].block == 4,"Numeric Block scaling applied to face %d" % id)
 g = fresh(31,{"face31.initial":5,"face31.gain":3,"face31.cap":7});g.hero_action(0)
 check(g.heroes[0].block == 5,"Stonewake initial Block tunable")
 g.pending = {"kind":"channel","hero":0};g.channel_choice(true)
 check(g.heroes[0].block == 7,"Stonewake maintenance gain and cap effective")
 g = fresh(25,{"face25.blank_block":3,"face25.boost":2,"face25.cap":5});g.hero_action(0)
 g.heroes[0].results[1] = 0;g.on_roll(g.heroes[0],1);g.heroes[0].results[2] = 4;g.on_roll(g.heroes[0],2)
 check(g.heroes[0].block == 3 and g.heroes[0].channel.boost == 2,"Contained Power passive values effective")
 g = fresh(44,{"face44.self":2,"face44.ally":3,"boss.Strike.damage":2});Lab.attack(g,44);g.react(true)
 check(g.heroes[0].block == 2 and g.heroes[1].block == 1,"Shield Wall independently tunes both Block gains before damage")
 g = fresh(1,{"boss.brand.damage":3,"boss.brand.radius":2});g.phase_two = true;g.active = 3;g.boss_rolls = ["Cinder Brand","Brace","Strike"];g.boss_step()
 check(g.brand_cells.size() == 25 and g.heroes[0].hp == 3,"Brand radius changes without immediate damage")
 check(g.event_log.any(func(e):return e.kind == "fire_arm" and e.tiles.size() == 25),"arming fire snapshots marked cells")
 g.detonate_brand()
 check(g.heroes.all(func(h):return h.hp == 0) and g.brand_cells.is_empty(),"Brand configured damage hits marked heroes together")
 check(g.event_log.any(func(e):return e.kind == "fire" and e.tiles.size() == 25),"detonation fire survives clearing hazard cells")
 g = fresh(1,{"boss.chain.range":8,"boss.chain.move":2,"boss.chain.strip":3});g.heroes[0].pos = Vector2i(4,7);g.heroes[0].block = 5;g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8);g.active = 3;g.boss_rolls = ["Ashen Chain","Brace","Strike"];g.boss_step()
 check(g.heroes[0].pos == Vector2i(4,5) and g.heroes[0].block == 2,"boss Chain range, pull and stripping are effective")
 g = fresh(1,{"boss.tithe.range":5,"boss.tithe.strip":2,"boss.tithe.cap":5})
 for h in g.heroes:h.block = 3
 g.active = 3;g.boss_rolls = ["Grave Tithe","Brace","Strike"];g.boss_step()
 check(g.boss.block == 5 and g.heroes.all(func(h):return h.block == 1),"Tithe range, theft and cap effective")
 g = fresh(1,{"boss.fracture.count":2});g.active = 3;g.boss_rolls = ["Fracture","Brace","Strike"];g.boss_step()
 var target: int = g.pending.hero;g.fracture(0,0)
 check(not g.pending.is_empty() and g.pending.remaining == 1,"Fracture can request more than one real choice")
 g.fracture(0,1);check(g.pending.is_empty() and g.heroes[target].build[0][0] == 0 and g.heroes[target].build[0][1] == 0,"Fracture ends at configured count")
 g = fresh(1,{"numeric.positive_faces":6,"numeric.positive":2})
 var rolls: Array = []
 for i in range(50):rolls.append(g.numeric(g.heroes[0]))
 check(rolls.all(func(n):return n == 2),"ordinary Numeric die distribution and values tunable")
 g = fresh(52,{"face52.burn":4,"face52.damage":2});g.heroes[0].block = 4;g.pending = {"kind":"ember","hero":0,"die":0};g.ember(4)
 check(g.heroes[0].block == 0 and g.boss.hp == 22,"Ember burn limit and damage per point effective")
 check(g.event_log.any(func(e):return e.kind == "fire"),"Ember Burst produces a fire event")
 g = fresh(27,{"face27.damage":0,"face27.charges":1,"face27.backlash":2})
 g.hero_action(0);g.hero_action(1,3)
 check(g.boss.bargain.is_empty() and g.heroes[0].hp == 1,"zero-bonus Bargain still consumes charges and pays its configured cost")
 g = fresh(1,{"lab.boss_hp":42,"lab.hero_hp":5,"lab.hero_block":3,"lab.boss_block":2})
 check(g.boss.hp == 42 and g.boss.block == 2 and g.heroes.all(func(h):return h.hp == 5 and h.block == 3),"Lab fixture values are independently configurable")
 print("CUSTOM BALANCE: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
