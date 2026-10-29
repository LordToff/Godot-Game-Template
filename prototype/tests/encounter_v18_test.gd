extends SceneTree
const B = preload("res://prototype/battle.gd")
const Nu = preload("res://prototype/nugh.gd")
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V18 FAIL: ",why)
func fresh():
 var g = Nu.new();g.start([B.default_build(),B.default_build(),B.default_build()],51);return g
func action(g, name: String):
 g.active = 3;g.pending = {};g.boss_index = 0;g.boss_rolls = [name,"Bound","Bound"];g.boss_step()
func _initialize():call_deferred("run")
func run():
 var g = fresh()
 check(g.boss_name() == "Nu’gh" and g.encounter_id == "nugh","separate encounter identity")
 check(g.living_minions().size() == 2 and g.pressure() == 1,"starting brood and capped pressure")
 for id in g.living_minions():
  check(not g.legal(0,g.unit_data(id).pos),"living worm blocks a cell")
  check(g.unit_data(id).hp == 1,"worms are killable by one unmodified Strike")
 var id: int = g.living_minions()[0];var cell: Vector2i = g.unit_data(id).pos
 g.damage(id,1)
 check(g.unit_data(id).dead and g.legal(0,cell),"killed worm frees its cell")
 g.damage(g.living_minions()[0],1)
 check(g.pressure() == 0 and g.outcome == "","clearing worms reduces pressure without ending boss fight")
 action(g,"Birth Cry");check(g.living_minions().size() == 1,"Birth Cry summons one")
 for i in range(10):action(g,"Birth Cry")
 check(g.living_minions().size() == g.v("nugh.worm_cap"),"brood cap is enforced")
 g = fresh();var before: int = g.boss.hp;g.damage(3,6)
 check(g.phase_two and g.boss.hp == before-6 and not g.boss_rolls.has("Furnace Roar"),"Nu phase uses own upgrades, never Hollow Roar")
 check(g.pressure() == 2 and g.boss_range("Gnashing Maw") == 2,"phase increases pressure cap and Maw reach")
 var n: int = g.living_minions().size();action(g,"Birth Cry")
 check(g.living_minions().size() == mini(g.v("nugh.worm_cap"),n+2),"upgraded Birth Cry summons two")
 g.boss.hp = 5;action(g,"Brood Guard")
 check(g.boss.hp == 5 and g.unit_data(g.living_minions()[0]).block == 1,"upgraded Guard shields a living worm without healing the boss")
 action(g,"Devour Brood")
 check(g.boss.hp == 7 and g.living_minions().size() == 3,"upgraded Devour consumes a worm and heals two")
 g = fresh();g.active = 0;g.pending = {};g.heroes[0].results = [1,38,7];g.heroes[0].rolls = [0,0,0];g.heroes[0].used = [false,false,false]
 var worm: int = g.living_minions()[0];g.unit_data(worm).pos = Vector2i(1,6);g.heroes[0].pos = Vector2i(1,7)
 check(g.hero_action(0,worm) and g.unit_data(worm).dead,"ordinary hero attack targets and kills a worm")
 check(not g.hero_action(2,g.living_minions()[0]),"healing cannot target an enemy worm")
 g = fresh();g.active = 0;g.pending = {};g.heroes[0].results = [38,4,7];g.heroes[0].used = [false,false,false];g.heroes[0].stored_num = 1;g.heroes[0].pos = Vector2i(2,3)
 var w: int = g.living_minions()[0];g.unit_data(w).pos = Vector2i(3,5)
 check(g.hero_action(0,3) and g.unit_data(w).dead,"Cleave secondary hit reaches a distinct enemy adjacent to the boss")
 g = fresh();g.active = 0;g.pending = {};g.heroes[0].results = [35,4,7];g.heroes[0].used = [false,false,false];g.heroes[0].pos = Vector2i(3,6)
 g.unit_data(4).pos = Vector2i(3,5)
 check(not g.sight(0,3,3),"worm blocks line of sight")
 g.damage(4,1);check(g.sight(0,3,3),"dead worm no longer blocks sight")
 g = fresh();g.damage(3,99)
 check(g.outcome == "victory" and g.living_minions().is_empty(),"boss death wins and silences the brood")
 g = fresh();g.damage(3,6);g.boss.hp = 4
 for worm_id in g.living_minions():g.damage(worm_id,99)
 var cleared_hp: int = g.boss.hp
 action(g,"Brood Guard");check(g.boss.hp == cleared_hp,"no worms denies upgraded Guard healing")
 g = fresh();g.damage(3,6);g.boss.hp = 4;g.heal_boss(6,"test")
 check(g.phase_two,"healing above half never reverses phase")
 g = Lab.create(1);g.damage(3,15)
 var upgrades: Array = g.phase_upgrades();check(upgrades.size() == 12,"every Hollow action has an upgrade entry")
 var phase_keys: Array = ["boss.advance.move","boss.advance.block","boss.smoking.fire_damage","boss.brace.block","boss.skirmish.move","boss.Sweep.range","boss.push.move","boss.distort.weakness","boss.fracture.range","boss.tithe.strip","boss.tithe.cap","boss.Furnace Roar.range"]
 for key in phase_keys:check(g.v(key) > B.Balance.value({},key),"Hollow phase mechanically upgrades "+key)
 g = fresh();check(g.phase_upgrades().size() == 6,"every Nu ability has a phase entry")
 g.phase_two = true;var at: int = g.living_minions().size();action(g,"Burrow")
 check(g.living_minions().size() > at,"upgraded Burrow leaves a worm")
 g = fresh();g.action_owner = 0
 var linked_hp: int = g.boss.hp
 g.damage(g.living_minions()[0],1)
 check(g.boss.hp == linked_hp-1,"hero worm kill triggers unavoidable Soul Link")
 g = fresh();g.boss.hp = 8
 action(g,"Devour Brood")
 check(g.boss.hp == 9,"Nu consuming a worm heals without triggering Soul Link")
 g = fresh();g.heroes[0].pos = Vector2i(3,6);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 var brood: int = g.living_minions().size();var hp_before: int = g.boss.hp
 action(g,"Screaming Chorus")
 check(g.living_minions().size() == brood-1 and g.boss.hp == hp_before,"empowered Chorus spends its worm without Soul Link")
 print("V0.18 ENCOUNTERS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
