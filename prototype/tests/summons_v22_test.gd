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
 # Bu’gh defaults, cocoon break rewards, stable hatching and strict Feast faction.
 g = fresh(Bug)
 check(g.boss.hp == 12 and g.kind_ids("cocoon").size() == 1 and g.v("bugh.cap") == 3,"provisional defaults applied")
 var cocoon: int = g.kind_ids("cocoon")[0];g.boss.block = 5;g.action_owner = 1;hp = g.boss.hp;g.damage(cocoon,1)
 check(g.heroes[1].block == 1 and g.boss.block == 3 and g.boss.weak and g.boss.hp == hp,"hero cocoon break: Block, strip, Weakness; no Soul Link")
 g.active = 3;g.brood_finished = true;g.pending = {};g.finish_turn();check(not g.boss.weak,"cocoon Weakness expires at boss turn end")
 g = fresh(Bug);cocoon = g.kind_ids("cocoon")[0]
 g.active = 3;g.boss_index = 3;g.finish_turn()
 check(g.unit_data(cocoon).age == 1 and g.unit_data(cocoon).kind == "cocoon","first brood phase ages once")
 for age in [2,3]:
  g.active = 3;g.pending = {};g.brood_finished = false;g.finish_turn()
  while g.brood_active and g.outcome == "":
   if g.pending.is_empty():g.boss_step()
   else:g.react(false)
 check(g.unit_data(cocoon).kind == "mite" and g.unit_data(cocoon).hp == 1,"hatch at third brood phase, same stable ID")
 g = fresh(Bug);g.lay_cocoons(9);check(g.living_minions().size() == 3,"enemy brood cap")
 worm = g.spawn_friendly(0,g.summon_cells(0)[0]);check(g.living_minions().size() == 3 and worm >= 4,"friendly worm outside enemy cap")
 boss_action(g,"Hatching Scream");check(g.kind_ids("mite").size() == 1,"phase-I scream hatches oldest only")
 g.boss.hp = 10;boss_action(g,"Royal Feast")
 check(g.boss.hp == 11 and not g.unit_data(worm).dead and g.kind_ids("mite").is_empty(),"Feast heals one and spares friendly worm")
 boss_action(g,"Royal Feast");check(g.boss.hp == 11 and not g.unit_data(worm).dead,"no enemy mite means no Feast")
 g.damage(3,5,true);check(g.phase_two,"half HP phase triggers")
 boss_action(g,"Hatching Scream")
 check(g.kind_ids("cocoon").is_empty() and g.kind_ids("mite").size() == 2,"phase-II scream hatches all")
 for id in g.kind_ids("mite"):check(g.unit_data(id).block == 1,"phase-II newborn Block")
 g.lay_cocoons(1);cocoon = g.kind_ids("cocoon")[0];check(g.unit_data(cocoon).hp == 2,"new phase-II cocoon HP 2")
 check(g.boss_range("Carapace Crash") == 2 and g.phase_upgrades().size() == 6,"phase-II reach and all upgrades")
 g = fresh(Bug);g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 boss_action(g,"Silken Mandate");check(g.heroes[0].weak and g.heroes[0].rooted == 0,"phase-I mandate")
 g.phase_two = true;boss_action(g,"Silken Mandate");check(g.heroes[0].rooted == 1,"phase-II mandate Roots")
 g.on_enemy_bite(4,0,"Mite Bite");check(g.heroes[0].weak and g.heroes[0].rooted == 1,"mite HP-hit effect")
 g.apply_poison(4,0,1);g.damage(0,99,true);check(g.heroes[0].get("poison",0) == 0,"Downing clears Poison")
 # Resolve a real successful / blocked mite bite through the Reaction pipeline.
 g = fresh(Bug);cocoon = g.kind_ids("cocoon")[0];g.hatch(cocoon)
 g.unit_data(cocoon).pos = Vector2i(2,6);g.heroes[0].pos = Vector2i(2,7)
 g.balance["bugh.mite_hit_faces"] = 6;g.heroes[0].results = [5,59,1];g.heroes[0].reaction = [0];g.heroes[0].used[0] = true
 g.phase_two = true;g.active = 3;g.brood_queue = [cocoon];g.brood_active = true
 g.activate_mite()
 check(g.pending.get("kind","") == "reaction" and g.pending.source == cocoon,"mite opens true Reaction window")
 hp = g.heroes[0].hp;g.react(true)
 check(g.heroes[0].hp == hp and not g.heroes[0].weak and g.heroes[0].rooted == 0,"blocked mite bite applies neither Weakness nor Rooted")
 g.heroes[0].block = 0;g.brood_queue = [cocoon];g.activate_mite()
 check(g.heroes[0].hp == hp-1 and g.heroes[0].weak and g.heroes[0].rooted == 1,"HP-damaging phase-II mite bite applies both statuses")
 g.order = [3,0,1,2];g.cursor = 0;g.activate()
 check(not g.heroes[0].weak and g.heroes[0].rooted == 0,"mite statuses expire at next boss turn start")
 # Phase-II Crash is a genuine area attack and includes a friendly worm once.
 g = fresh(Bug);g.minions.clear();g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(5,3);g.heroes[2].pos = Vector2i(8,8)
 worm = g.spawn_friendly(0,Vector2i(2,4));g.balance["bugh.crash_move_phase"] = 0;g.balance["bugh.crash_move"] = 0;g.phase_two = true
 var h0: int = g.heroes[0].hp;var h1: int = g.heroes[1].hp
 boss_action(g,"Carapace Crash")
 check(g.heroes[0].hp == h0-1 and g.heroes[1].hp == h1-1 and g.unit_data(worm).dead,"area Crash hits opponents once, including friendly worm")
 check(g.boss.hp == 12,"Crash never damages its own boss")
 # Phase-I Crash remains single target damage 2.
 g = fresh(Bug);g.minions.clear();g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(8,8);g.heroes[2].pos = Vector2i(0,8);g.balance["bugh.crash_move"] = 0;hp = g.heroes[0].hp
 boss_action(g,"Carapace Crash");check(g.heroes[0].hp == hp-2,"phase-I Crash single damage 2")
 g = fresh(Bug);g.minions.clear();boss_action(g,"Shed the Shell")
 check(g.boss.block == 1 and g.kind_ids("cocoon").size() == 1,"phase-I Shell Block and cocoon")
 g.phase_two = true;g.boss.block = 0;boss_action(g,"Shed the Shell")
 check(g.boss.block == 2 and g.unit_data(g.kind_ids("cocoon")[-1]).hp == 2,"phase-II Shell Block and tougher new cocoon")
 # Cocoon poison at its next brood activation resolves before hatch; no hero reaction reward.
 g = fresh(Bug);cocoon = g.kind_ids("cocoon")[0];worm = g.spawn_friendly(0,g.summon_cells(0)[0]);g.apply_poison(worm,cocoon,1)
 g.unit_data(cocoon).age = 2;g.active = 3;g.boss_index = 3;g.finish_turn()
 check(g.unit_data(cocoon).dead and g.unit_data(cocoon).kind == "cocoon","Poison kills cocoon before scheduled hatch")
 # Cleave does not splash friendly Nu’gh; broad Ember explicitly can.
 g = fresh();g.minions.clear();g.heroes[0].pos = Vector2i(2,3);worm = g.spawn_friendly(0,Vector2i(2,4));g.unit_data(worm).pos = Vector2i(3,5)
 g.heroes[0].results = [38,4,1];g.heroes[0].stored_num = 1;g.hero_action(0,3)
 check(not g.unit_data(worm).dead,"Cleave secondary excludes friendly worm")
 g.damage(worm,1,false,"Ember Burst");check(g.unit_data(worm).dead,"all-unit damage can kill friendly worm")
 # Seeded movement/occupancy and bite distributions, without forcing successful sides.
 var hits := 0
 for seed_value in range(1,121):
  g = fresh(Bug,seed_value);g.minions.clear();g.heroes[0].pos = Vector2i(2,3)
  worm = g.spawn_friendly(0,Vector2i(1,3));g.unit_data(worm).pos = Vector2i(2,2);hp = g.boss.hp;g.activate_friendly(worm)
  check(g.distance(worm,3) == 1,"legal orthogonal approach")
  check(g.unit_data(worm).pos not in g.cells(3),"no boss overlap")
  if g.boss.hp < hp:hits += 1
 check(hits > 20 and hits < 65,"Numeric approximately two successful sides; hits="+str(hits))
 print("V0.22 SUMMONS: ",checks," checks, ",failures," failures; seeded friendly hits ",hits,"/120")
 quit(1 if failures else 0)
