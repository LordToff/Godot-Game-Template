extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:failures += 1;printerr("TRIAL FIX FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 var g = Lab.create(50,1)
 g.hero_action(0);g.remove_block(0,g.heroes[0].block);g.finish_turn()
 check(not g.heroes[0].black_oath,"Black Oath expires at the end of its casting turn even with zero Block")
 g.active = 0;g.cursor = 0;g.heroes[0].results[1] = 4;g.heroes[0].used[1] = false
 var hp: int = g.heroes[0].hp;g.hero_action(1);g.finish_turn()
 check(g.heroes[0].hp == hp,"an expired Black Oath cannot tax a later Guard")
 g = Lab.create(50,1);g.hero_action(0);hp = g.heroes[0].hp;g.finish_turn()
 check(g.heroes[0].hp == hp-1 and not g.heroes[0].black_oath,"Black Oath still charges once when Block remains")
 # Ward reacts to HP damage caused by the boss, not to a hero's own costs.
 g = Lab.create(51,1);g.hero_action(0);g.remove_block(0,g.heroes[0].block)
 g.heroes[0].black_oath = true;g.heroes[0].block = 1;g.finish_turn()
 check(not g.boss.weak,"Black Oath self-cost does not inflict Wither Ward on the boss")
 g = Lab.create(51,1);g.hero_action(0);g.heroes[0].block = 0;Lab.attack(g,51)
 check(g.boss.weak,"a real adjacent boss hit still triggers Wither Ward")
 g = Lab.create(51,1);g.hero_action(0);g.heroes[0].block = 0;g.action_owner = 3
 g.brand_cells = [g.heroes[0].pos];g.detonate_brand()
 check(not g.boss.weak,"Cinder Brand hazard is not an attacker and cannot trigger Ward")
 g = Lab.create(1,1);g.heroes[1].ward = true;g.heroes[1].block = 0;g.hero_action(0,1)
 check(not g.boss.weak,"friendly fire cannot weaken an uninvolved boss through Ward")
 g = Lab.create(51,1);g.hero_action(0);g.heroes[0].block = 4;Lab.attack(g,51)
 check(not g.boss.weak,"fully blocked boss damage does not trigger Ward")
 g = Lab.create(1);g.action_owner = 3;g.heroes[0].hp = 1;g.heroes[0].ward = true;g.heroes[0].defy = true
 g.damage(0,1,false,"boss hit",3)
 check(g.heroes[0].hp == 1 and not g.boss.weak,"zero HP loss after Defy Death does not trigger Ward even with explicit boss attribution")
 # Setting Fracture to zero must not destroy a face.
 g = Lab.create(1,-1,{"boss.fracture.count":0});g.active = 3;g.boss_rolls = ["Fracture","Bound","Bound"]
 var build: Array = g.heroes[0].build.duplicate(true);g.boss_step()
 check(g.pending.is_empty() and g.heroes[0].build == build,"zero Fracture count skips the destructive choice")
 # Engrave should still grow on the killing hit; finishing the fight should not suppress its effect.
 g = Lab.create(41,1);g.boss.hp = 1;g.hero_action(0,3)
 check(g.outcome == "victory" and g.heroes[0].build[0].count(41) == 2,"Engrave grows on a killing hit, consistently with its printed trigger")
 g = Lab.create(36,2);g.boss.hp = 2;g.hero_action(0,3)
 check(g.outcome == "victory" and g.heroes[0].block == 2,"Hooked Slash gains its Block even on the killing hit")
 print("TRIAL REGRESSIONS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
