extends SceneTree
const Battle = preload("res://prototype/battle.gd")
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var errors := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok: errors += 1;printerr("UPDATE FAIL: ",what)
func boss_action(g, action: String):
 g.active = 3;g.pending = {};g.boss_rolls = [action,"Brace","Strike"];g.boss_index = 0;g.boss_step()
func _initialize():call_deferred("run")
func run():
 var build: Array = Battle.default_build()
 check(build.all(func(d):return d.count(0) == 2) and Battle.validate(build) == "","fuller default is legal with exactly two Blanks per die")
 build[0] = [1,2,4,1,8,0]
 check(Battle.validate(build) != "","one Blank remains illegal")
 check(Battle.Catalog.extended_ids().size() == 47 and 57 in Battle.Catalog.draft_ids() and 58 in Battle.Catalog.draft_ids(),"both new movements are offered")
 var g = Lab.create(57)
 check(not g.hero_action(0,-1,Vector2i(8,8)) and g.heroes[0].block == 0 and not g.heroes[0].used[0],"invalid Ashstep cannot farm Block")
 check(g.hero_action(0,-1,Vector2i(3,5)) and g.heroes[0].pos == Vector2i(3,5) and g.heroes[0].block == 1,"Ashstep turns and grants exactly one Block")
 g = Lab.create(57);g.heroes[0].pos = Vector2i(0,0);g.heroes[1].pos = Vector2i(1,0);g.heroes[2].pos = Vector2i(0,1)
 check(not g.hero_action(0,-1,Vector2i(1,1)),"Ashstep cannot cross occupied paths")
 g = Lab.create(58)
 var a: Vector2i = g.heroes[0].pos;var b: Vector2i = g.heroes[1].pos
 check(g.hero_action(0,1) and g.heroes[0].pos == b and g.heroes[1].pos == a,"Exchange swaps complete hero positions")
 check(g.heroes[0].block == 1 and g.heroes[1].block == 1,"Exchange shields both heroes")
 check(g.event_log.any(func(e):return e.kind == "move" and e.target == 1),"Exchange reports ally movement")
 g = Lab.create(58);g.heroes[1].hp = 0
 check(not g.hero_action(0,1) and not g.heroes[0].used[0],"Exchange rejects Downed ally without spending")
 check(not g.hero_action(0,3),"Exchange rejects boss")
 g = Lab.create(58);g.heroes[1].pos = Vector2i(1,1)
 check(not g.hero_action(0,1),"Exchange range enforced")
 g = Lab.create(1);g.heroes[0].pos = Vector2i(2,3);g.heroes[0].block = 2;g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 boss_action(g,"Ashen Chain")
 check(g.heroes[0].pos == Vector2i(3,3) and g.heroes[0].block == 1 and g.heroes[0].hp == 3,"Chain pulls legally, strips one Block and deals no HP damage")
 g = Lab.create(1);g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(3,3);g.heroes[2].pos = Vector2i(7,7)
 # Closest target (ally) is adjacent: it holds position rather than overlapping the boss.
 boss_action(g,"Ashen Chain")
 check(g.heroes[1].pos == Vector2i(3,3) and g.legal(0,g.heroes[0].pos),"Chain never forces an illegal overlap")
 g = Lab.create(1);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8);boss_action(g,"Cinder Brand")
 var hp: int = g.heroes[0].hp
 check(g.brand_cells.size() == 5 and g.heroes[0].pos in g.brand_cells and hp == 3,"phase-I Brand telegraphs a cross without immediate damage")
 var marked: Array = g.brand_cells.duplicate()
 boss_action(g,"Cinder Brand")
 check(g.brand_cells == marked,"Brand cannot stack or replace an existing warning")
 g.heroes[0].pos = Vector2i(1,7);g.heroes[1].pos = Vector2i(4,4);g.heroes[1].block = 1;g.heroes[2].pos = Vector2i(4,5)
 g.active = 3;g.cursor = 3;g.activate()
 check(g.heroes[0].hp == hp and g.heroes[1].hp == maxi(0,3-maxi(0,g.v("boss.brand.damage")-1)) and g.heroes[1].block == 0 and g.heroes[2].hp == maxi(0,3-g.v("boss.brand.damage")),"Brand rewards escape, respects Block and hits each marked hero once")
 check(g.brand_cells.is_empty(),"Brand clears after one detonation")
 g = Lab.create(1);g.heroes[0].block = 2;g.heroes[1].block = 1;g.heroes[2].block = 1
 boss_action(g,"Grave Tithe")
 check(g.boss.block == 2 and g.heroes[0].block == 1 and g.heroes[1].block == 0 and g.heroes[2].block == 0,"Tithe steals one per nearby hero with boss gain capped at two")
 check(g.heroes.all(func(h):return h.hp == 3),"Tithe does not secretly damage HP")
 g = Lab.create(1);g.tuned = false
 check(g.boss_dice() == Battle.BOSS_DICE,"Original encounter retains original boss faces")
 g.tuned = true
 check(g.boss_dice() == Battle.TUNED_BOSS_DICE,"Tuned encounter uses varied boss faces")
 check(g.boss_sides.size() == 3 and g.initial_builds.size() == 3,"dice inventory records baseline builds and boss rolled sides")
 check(g.turn_explanation().contains("Reroll first") and g.turn_explanation().contains("Next round"),"hero turn explanation covers reroll window and shared roll")
 g.active = 3
 check(g.turn_explanation().contains("detonate first") and g.turn_explanation().contains("I, II, III"),"boss explanation covers hazards and action order")
 for action in ["Ashen Chain","Cinder Brand","Grave Tithe"]:check(g.boss_help(action).length() > 50,"new boss face has full explanation")
 print("V0.5 RULES: %d checks, %d failures" % [checks,errors])
 quit(1 if errors else 0)
