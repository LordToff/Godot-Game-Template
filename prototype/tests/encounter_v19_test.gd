extends SceneTree
const B = preload("res://prototype/battle.gd")
const Nu = preload("res://prototype/nugh.gd")
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V19 FAIL: ",why)
func fresh(seed_value: int = 51):
 var g = Nu.new();g.start([B.default_build(),B.default_build(),B.default_build()],seed_value);return g
func action(g, name: String):
 g.active = 3;g.pending = {};g.boss_index = 0;g.boss_rolls = [name,"Bound","Bound"];g.boss_step()
func _initialize():call_deferred("run")
func run():
 var g = fresh()
 check(g.boss.hp == 10 and g.boss_name() == "Nu’gh","new health and separate encounter")
 check(g.living_minions().size() == 2 and g.boss_dice()[1].count("Brood Command") == 2,"starting brood and command-heavy dice")
 for seed_value in range(1,31):
  g = fresh(seed_value)
  for h in range(3):g.heroes[h].pos = Vector2i(2+h,5);g.heroes[h].hp = 0 if h == 1 else 6
  g.minions.clear();g.spawn_worms(12)
  var occupied: Array = []
  for id in range(g.unit_count()):
   for cell in g.cells(id):
    check(cell not in occupied,"no summon overlap, including Vesper / Downed heroes, seed %d" % seed_value)
    occupied.append(cell)
 g = fresh();g.minions.clear();g.heroes[0].pos = Vector2i(3,6);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 var before: int = g.distance(3,0);var origin: Vector2i = g.boss.pos
 action(g,"Burrow")
 check(g.distance(3,0) > before and g.boss.pos != origin,"Burrow retreats instead of approaching")
 for hero in range(3):check(not g.cells(3).has(g.heroes[hero].pos),"retreat full footprint does not overlap hero")
 g = fresh();g.minions.clear();action(g,"Brood Command")
 check(g.living_minions().size() == 2 and not g.command_active and g.pending.is_empty(),"empty Command summons two and does not attack immediately")
 g = fresh();g.minions.clear();g.spawn_worms(1)
 var worm: int = g.living_minions()[0];g.unit_data(worm).pos = Vector2i(2,5)
 g.heroes[0].pos = Vector2i(2,7);g.heroes[0].results = [5,1,4];g.heroes[0].reaction = [0];g.heroes[0].used = [true,false,false]
 g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8);g.boss.weak = true
 g.balance["nugh.worm_hit_faces"] = 6
 action(g,"Brood Command")
 check(g.unit_data(worm).pos == Vector2i(2,6),"command moves worm along legal path to adjacency")
 check(g.pending.get("source",-1) == worm and g.pending.get("kind","") == "reaction","worm bite opens a real reaction with its own source")
 var hp: int = g.heroes[0].hp;g.react(true)
 check(g.heroes[0].hp == hp and g.heroes[0].block == 1,"Reaction blocks worm damage; boss Weakness does not reduce unrelated worm")
 g.boss_step();check(not g.command_active,"command ends after each living worm activated once")
 check(g.event_log.filter(func(e):return e.kind == "attack" and e.source == worm).size() == 1,"one attack per worm per Command")
 g = fresh();g.minions.clear();g.spawn_worms(1);worm = g.living_minions()[0];g.unit_data(worm).pos = Vector2i(2,6)
 g.heroes[0].pos = Vector2i(2,7);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 for h in g.heroes:h.reaction.clear()
 g.balance["nugh.worm_hit_faces"] = 6
 action(g,"Brood Command")
 check(g.heroes[0].hp == 5,"worm actually damages hero without a reaction")
 g = fresh();g.boss.hp = 6;g.action_owner = 0;g.damage(g.living_minions()[0],1)
 check(g.boss.hp == 5 and g.phase_two,"phase-I Soul Link can trigger half-HP transition")
 g.action_owner = 0;g.damage(g.living_minions()[0],1)
 check(g.boss.hp == 5,"Soul Link stops immediately at half HP")
 g.heal_boss(5,"test");g.spawn_worms(1);g.action_owner = 0;g.damage(g.living_minions()[0],1)
 check(g.boss.hp == 10 and g.phase_two,"healing never re-enables Soul Link")
 g = fresh();g.damage(3,6);g.minions.clear();action(g,"Brood Command")
 check(g.living_minions().size() == 3,"phase-II empty Command summons three")
 check(g.phase_upgrades().size() == 6 and g.boss_range("Gnashing Maw") == 2,"all six revised abilities upgrade")
 g = fresh();g.boss.hp = 8;action(g,"Devour Brood")
 check(g.boss.hp == 9 and g.living_minions().size() == 1,"Devour heals without triggering Soul Link")
 g = fresh();g.minions.clear();g.heroes[0].pos = Vector2i(0,8);g.heroes[1].pos = Vector2i(4,8);g.heroes[2].pos = Vector2i(8,8)
 action(g,"Gnashing Maw")
 check(g.last_boss_result.contains("FALLBACK") and g.event_log.any(func(e):return e.kind == "fallback"),"Nu fallback has a persistent result and typed log event")
 g = fresh();g.active = 0;g.pending = {};g.heroes[0].results = [38,4,7];g.heroes[0].used = [false,false,false];g.heroes[0].stored_num = 1;g.heroes[0].pos = Vector2i(2,3)
 worm = g.living_minions()[0];g.unit_data(worm).pos = Vector2i(3,5)
 check(g.hero_action(0,3) and g.unit_data(worm).dead,"Cleave still hits secondary worm")
 g = fresh();g.damage(3,99);check(g.outcome == "victory" and g.living_minions().is_empty() and not g.command_active,"boss death clears brood / commands")
 g = Lab.create(1)
 for key in ["boss.brand.damage"]:check(g.v(key) == 2,"stronger Hollow default "+key)
 g.active = 0;g.pending = {};g.cursor = g.order.find(0);g.fire_tiles = [g.heroes[0].pos];hp = g.heroes[0].hp;g.finish_turn()
 check(g.heroes[0].hp == hp-1 and g.fire_tiles.size() == 1,"ending on fire deals damage without consuming tile")
 g = Lab.create(1);g.active = 0;g.pending = {};g.cursor = g.order.find(0);g.fire_tiles = [g.heroes[0].pos];g.heroes[0].block = 1;hp = g.heroes[0].hp;g.finish_turn()
 check(g.heroes[0].hp == hp,"ordinary fire can be blocked")
 g = Lab.create(1);g.damage(3,15)
 check(g.phase_two and g.v("boss.brand.damage") == 3 and g.v("boss.fire.end_turn") == 1,"phase II increases fire and Brand danger")
 g.active = 0;g.pending = {};g.cursor = g.order.find(0);g.heroes[0].hp = 6;g.fire_tiles = [g.heroes[0].pos];g.finish_turn()
 check(g.heroes[0].hp == 5,"phase-II end-turn fire remains one unless customized")
 g = Lab.create(1);g.active = 0;g.pending = {};g.cursor = g.order.find(0);g.fire_tiles = [Vector2i(0,0)];hp = g.heroes[0].hp;g.finish_turn()
 check(g.heroes[0].hp == hp,"moving off fire avoids its cost")
 print("V0.19 ENCOUNTERS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
