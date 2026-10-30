extends SceneTree
const B = preload("res://prototype/battle.gd")
const C = preload("res://prototype/cantor.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V20 FAIL: ",why)
func fresh():
 var g = C.new();g.start([B.default_build(),B.default_build(),B.default_build()],17)
 g.active = 0;g.cursor = g.order.find(0);g.pending = {}
 for h in g.heroes:h.reaction.clear();h.used = [false,false,false]
 g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 g.heroes[0].results = [1,4,7]
 return g
func action(g, name: String):
 g.active = 3;g.pending = {};g.boss_index = 0;g.boss_rolls = [name,"Bound","Bound"];g.boss_step()
func _initialize():call_deferred("run")
func run():
 var g = fresh()
 check(g.boss.hp == 14 and g.encounter_id == "cantor" and g.boss_name().contains("Veyl"),"independent third encounter identity / HP")
 check(g.minions.is_empty() and g.fire_tiles.is_empty() and g.brand_cells.is_empty(),"no summons or terrain hazards")
 check(g.hero_action(0,3) and g.resonance == 1 and g.boss.hp == 13,"resolved Attack charges Resonance")
 check(g.hero_action(1) and g.resonance == 0,"resolved Defense calms Resonance")
 g.resonance = 3
 check(g.hero_action(2,0) and g.resonance == 2,"resolved Skill calms even without missing HP")
 g = fresh();g.resonance = 4;g.heroes[0].results = [2,0,1]
 check(g.hero_action(0,-1,Vector2i(2,4)) and g.resonance == 4,"Movement does not change meter")
 check(g.hero_action(1) and g.resonance == 4,"Blank does not change meter")
 g.decline(2);check(g.resonance == 4,"declined Attack does not charge meter")
 g = fresh();g.resonance = 4;g.heroes[0].results[0] = 4;g.decline(0)
 check(g.resonance == 4,"declined Defense cannot farm calm")
 g = fresh();g.resonance = 6;g.hero_action(0,3)
 check(g.resonance == 6,"meter caps at six")
 g = fresh();g.core_open = true;g.hero_action(0,3)
 check(g.boss.hp == 12 and g.resonance == 1,"open core adds one damage before Block")
 g = fresh();g.core_open = true;g.heroes[0].results[0] = 34;g.heroes[0].stored_num = 1;g.hero_action(0,3)
 check(g.boss.hp == 12,"Numeric Attack gets core bonus once, not twice")
 g = fresh();g.core_open = true;g.heroes[0].pos = Vector2i(3,5);g.heroes[0].backstab = g.round_no;g.hero_action(0,3)
 check(g.boss.hp == 10 and g.resonance == 1,"repeated fixed Attack gets bonus per hit, charges meter once per face")
 g = fresh();g.core_open = true;g.boss.block = 2;g.hero_action(0,3)
 check(g.boss.hp == 14 and g.boss.block == 0,"core bonus still respects Block")
 g = fresh();action(g,"Crescendo")
 check(g.core_open and g.resonance == 2,"Crescendo opens the core and charges meter")
 action(g,"Seal the Bell")
 check(g.core_open and g.boss.block == 2,"Seal does not close an already-open core")
 g.order = [3,0,1,2];g.cursor = 0;g.activate()
 check(not g.core_open and g.boss.block == 0,"core and old Block expire at next boss turn start")
 g = fresh();action(g,"Gathering Note");check(g.resonance == 2,"Gathering Note telegraphs future damage")
 g = fresh();g.resonance = 6
 g.heroes[1].pos = Vector2i(3,5);g.heroes[2].pos = Vector2i(5,3)
 g.heroes[0].results[0] = 5;g.heroes[0].reaction = [0];g.heroes[0].used[0] = true
 g.heroes[1].results[0] = 45;g.heroes[1].reaction = [0];g.heroes[1].used[0] = true
 action(g,"Toll of Reckoning")
 check(g.pending.get("kind","") == "reaction" and g.pending.amount == 4 and g.resonance == 0,"Toll snapshots damage and spends meter before Reaction")
 g.react(true,Vector2i.LEFT)
 check(g.pending.is_empty() and g.heroes[0].hp == 4 and g.heroes[1].hp == 2 and g.heroes[2].hp == 2,"area hits each once; Block 2 protects; Taunt cannot redirect whole Toll")
 check(g.heroes[0].pos == Vector2i(2,3),"basic Reaction does not move even when supplied a legal direction")
 check(g.resonance == 0,"held Reactions do not rewrite declared damage or calm the meter")
 g = fresh();g.resonance = 6;action(g,"Hushed Chime")
 check(g.heroes[0].hp == 3 and g.resonance == 4,"Chime uses meter before spending two")
 g = fresh();g.resonance = 6
 g.heroes[0].pos = Vector2i(0,8);g.heroes[1].pos = Vector2i(4,8)
 action(g,"Toll of Reckoning")
 check(g.resonance == 6 and g.last_boss_result.contains("FALLBACK"),"Toll fallback preserves meter and has readable result")
 g = fresh();g.damage(3,7)
 check(g.phase_two and not g.boss_rolls.has("Furnace Roar"),"own phase transition, no Hollow Roar")
 check(g.boss_range("Toll of Reckoning") == 4 and g.boss_range("Hushed Chime") == 4 and g.core_bonus() == 2,"phase range and vulnerability upgrades")
 action(g,"Seal the Bell");check(g.boss.block == 3,"phase-II Seal stronger")
 action(g,"Gathering Note");check(g.resonance == 3,"phase-II Note gathers three")
 check(g.phase_upgrades().size() == 6,"every unique action has an upgrade")
 g = fresh();g.balance["face5.move"] = 16
 g.heroes[0].results[0] = 5;g.heroes[0].reaction = [0];g.heroes[0].used[0] = true
 action(g,"Hushed Chime");g.react(true,Vector2i.LEFT)
 check(g.heroes[0].pos == Vector2i(2,3) and g.heroes[0].hp == 6 and g.heroes[0].block == 1,"legacy movement overrides cannot re-enable basic Reaction steps")
 g = fresh();g.heroes[0].results[0] = 2;g.heroes[0].reaction = [0];g.heroes[0].smoke[0] = 2;g.heroes[0].used[0] = true
 action(g,"Hushed Chime");g.react(true,Vector2i.LEFT)
 check(g.heroes[0].pos == Vector2i(1,3),"Oath of Smoke’s explicitly stored movement still works")
 g = fresh();g.heroes[0].results[0] = 4;g.heroes[0].reaction = [0];g.heroes[0].smoke[0] = 4;g.heroes[0].used[0] = true
 action(g,"Hushed Chime");g.react(true,Vector2i.LEFT)
 check(g.heroes[0].pos == Vector2i(2,3),"stored Smoke Guard does not grant an unlisted step")
 g = fresh();g.heroes[0].pos = Vector2i(0,3);g.heroes[0].results[0] = 2;g.heroes[0].reaction = [0];g.heroes[0].smoke[0] = 2;g.heroes[0].used[0] = true
 action(g,"Toll of Reckoning");g.react(true,Vector2i.UP)
 check(g.heroes[0].hp == 6 and g.heroes[0].pos == Vector2i(0,2),"leaving Toll area via a real movement Reaction avoids that hit")
 g = fresh();g.heroes[0].results[0] = 1;g.heroes[0].used[0] = false
 check(not g.hero_action(0,1) and g.resonance == 0,"invalid Attack does not charge meter")
 print("V0.20 CANTOR: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
