extends SceneTree
const B = preload("res://prototype/battle.gd")
const N = preload("res://prototype/nugh.gd")
const Bug = preload("res://prototype/bugh.gd")
const C = preload("res://prototype/catalog.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V22 FAIL: ",why)
func fresh(script = B, seed_value: int = 1):
 var g = script.new();g.start([B.default_build(),B.default_build(),B.default_build()],seed_value)
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.forced_die = -1
 for h in g.heroes:h.reaction.clear();h.used = [false,false,false];h.results = [59,59,1];h.rolls = [0,0,0]
 return g
func boss_action(g, action: String):
 g.active = 3;g.pending = {};g.boss_index = 0;g.boss_rolls = [action,"Bound","Bound"];g.boss_step()
func _initialize():call_deferred("run")
func run():
 check(C.extended_ids().size() == 48 and B.FACES.size() == 60,"catalog counts")
 check(C.category(59) == "Skill" and B.validate(B.bonus_build([59,34]),[59,34]) == "","selectable legal Skill")
 check(B.validate(B.bonus_build([59,34]),[34]) != "","ownership enforced")
 var g = fresh()
 check(not g.hero_action(0,-1,g.heroes[0].pos) and not g.heroes[0].used[0],"occupied summon rejected without spending")
 check(not g.hero_action(0,-1,Vector2i(0,0)),"distant summon rejected")
 var cell: Vector2i = g.summon_cells(0)[0]
 check(g.hero_action(0,-1,cell),"adjacent summon succeeds")
 var worm: int = g.owned_worm(0)
 check(worm >= 4 and g.unit_data(worm).hp == 1 and g.friendly(worm),"friendly 1 HP worm")
 check(g.action_name(0,59) == "Command Nu’gh" and g.action_name(1,59) == "Summon Nu’gh","owner-specific face label")
 var actions: int = g.event_log.filter(func(e):return e.kind == "minion_action").size()
 check(g.hero_action(1),"second copy Commands immediately")
 check(g.event_log.any(func(e):return e.kind == "action" and e.text.contains("Command Nu’gh")),"Command declarations use their live name")
 check(g.living_minions("friendly").size() == 1 and g.event_log.filter(func(e):return e.kind == "minion_action").size() == actions+1,"shared cap and command activation")
 actions += 1;g.finish_turn()
 check(g.event_log.filter(func(e):return e.kind == "minion_action").size() == actions+1,"extra owner-end activation after Command")
 g.active = 0;g.pending = {};g.heroes[0].used = [false,false,false]
 g.damage(worm,1,true,"enemy test")
 check(g.unit_data(worm).dead and g.owned_worm(0) == -1 and g.action_name(0,59) == "Summon Nu’gh","death restores Summon")
 check(g.hero_action(0,-1,g.summon_cells(0)[0]) and g.owned_worm(0) != worm,"resummon uses new stable ID")
 check(g.spawn_friendly(1,g.summon_cells(1)[0]) >= 4,"each hero may own a worm")
 g = fresh();worm = g.spawn_friendly(0,Vector2i(2,6));g.unit_data(worm).pos = Vector2i(2,3)
 g.balance["face59.hit_faces"] = 6;g.boss.block = 1;var hp: int = g.boss.hp
 g.activate_friendly(worm)
 check(g.boss.hp == hp and g.boss.get("poison",0) == 0,"blocked bite does not poison")
 g.activate_friendly(worm)
 check(g.boss.hp == hp-1 and g.boss.poison == 1,"friendly bite damages and poisons boss")
 g.apply_poison(worm,3,1);g.boss.block = 9;hp = g.boss.hp;g.tick_poison(3)
 check(g.boss.hp == hp-1 and g.boss.poison == 0 and g.boss.block == 9,"refresh no stack; poison bypasses Block then clears")
 g = fresh(N);worm = g.spawn_friendly(0,g.summon_cells(0)[0]);var pressure: int = g.pressure()
 check(g.living_minions().size() == 2 and g.living_minions("all").size() == 3,"faction-separated brood count")
 hp = g.boss.hp;g.action_owner = 0;g.damage(worm,99)
 check(g.boss.hp == hp and g.pressure() == pressure,"friendly death never Soul Links or changes pressure")
 worm = g.spawn_friendly(0,g.summon_cells(0)[0]);boss_action(g,"Devour Brood")
 check(not g.unit_data(worm).dead and g.living_minions().size() == 1,"Nu’gh devours only enemy brood")
 var enemy: int = g.living_minions()[0];g.unit_data(enemy).pos = Vector2i(2,4);g.unit_data(worm).pos = Vector2i(2,5)
 check(worm in g.attack_targets(enemy,1) and enemy in g.attack_targets(worm,1),"opposing summons can target one another")
 g.balance["face59.hit_faces"] = 6;g.unit_data(enemy).hp = 2;g.unit_data(enemy).max_hp = 2
 g.activate_friendly(worm)
 check(g.unit_data(enemy).hp == 1 and g.unit_data(enemy).poison == 1,"enemy summon can be poisoned")
 g.tick_poison(enemy);check(g.unit_data(enemy).dead,"poison kills enemy summon")
 # Enemy attack and reaction retarget path must support a friendly worm victim.
 g = fresh();worm = g.spawn_friendly(0,g.summon_cells(0)[0]);g.unit_data(worm).pos = Vector2i(2,3)
 g.pending = {"kind":"attack","action":"Smoking Strike","source":3,"victims":[worm],"reacted":[],"amount":1};g.continue_attack()
 check(g.unit_data(worm).dead,"boss kills friendly worm")
 # Bu’gh’s replaced cocoon rules are covered by warden_v24_test.gd.
 g = fresh();g.apply_poison(3,0,1);g.damage(0,99,true);check(g.heroes[0].get("poison",0) == 0,"Downing still clears Poison")
 # Cleave does not splash friendly Nu’gh; broad Ember explicitly can.
 g = fresh();g.minions.clear();g.heroes[0].pos = Vector2i(2,3);worm = g.spawn_friendly(0,Vector2i(2,4));g.unit_data(worm).pos = Vector2i(3,5)
 g.heroes[0].results = [38,4,1];g.heroes[0].stored_num = 1;g.hero_action(0,3)
 check(not g.unit_data(worm).dead,"Cleave secondary excludes friendly worm")
 g.damage(worm,1,false,"Ember Burst");check(g.unit_data(worm).dead,"all-unit damage can kill friendly worm")
 # Seeded movement/occupancy and bite distributions, without forcing successful sides.
 var hits := 0
 for seed_value in range(1,121):
  g = fresh(B,seed_value);g.minions.clear();g.heroes[0].pos = Vector2i(2,3)
  worm = g.spawn_friendly(0,Vector2i(1,3));g.unit_data(worm).pos = Vector2i(2,2);hp = g.boss.hp;g.activate_friendly(worm)
  check(g.distance(worm,3) == 1,"legal orthogonal approach")
  check(g.unit_data(worm).pos not in g.cells(3),"no boss overlap")
  if g.boss.hp < hp:hits += 1
 check(hits > 20 and hits < 65,"Numeric approximately two successful sides; hits="+str(hits))
 print("V0.22 SUMMONS: ",checks," checks, ",failures," failures; seeded friendly hits ",hits,"/120")
 quit(1 if failures else 0)
