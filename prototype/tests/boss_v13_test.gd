extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("V13 FAIL: ",what)
func _initialize():call_deferred("run")
func fresh():
 var g = Lab.create(1)
 g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 return g
func action(g, name: String):
 g.active = 3;g.pending = {};g.boss_index = 0;g.boss_rolls = [name,"Bound","Bound"];g.boss_step()
func run():
 var g = fresh();action(g,"Cinder Brand")
 check(g.brand_cells.size() == 5 and Vector2i(3,3) not in g.brand_cells,"phase I Brand is a five-cell cross, not a square")
 check(g.boss_help("Cinder Brand").contains("Mark a cross"),"phase I description matches cross")
 var armed: Array = g.brand_cells.duplicate();g.active = 0;g.damage(3,15)
 check(g.phase_two and g.brand_cells == armed,"cross already armed does not expand midway through its countdown")
 g.brand_cells.clear();action(g,"Cinder Brand")
 check(g.brand_cells.size() == 9 and Vector2i(3,3) in g.brand_cells,"new phase-II Brand includes square corners")
 check(g.boss_help("Cinder Brand").contains("3×3 square"),"phase II description reports upgraded geometry")
 g = fresh();g.heroes[0].pos = Vector2i(0,0);action(g,"Cinder Brand")
 check(g.brand_cells.is_empty(),"no legal fire target falls back without inventing hazard cells")
 g = fresh();action(g,"Ashen Chain")
 check(g.heroes[0].rooted == 0,"phase I Chain does not Root")
 g = fresh();g.phase_two = true;action(g,"Ashen Chain")
 check(g.heroes[0].rooted == 1,"phase II Chain applies Rooted 1")
 check(g.status_map(0).Rooted and g.status_description(0).contains("until next boss turn"),"Rooted is visible with expiry explained")
 g.active = 0;g.cursor = 0;g.activate();g.pending = {}
 check(g.heroes[0].rooted == 1,"own turn does not expire Rooted")
 check(g.reachable(0,3,false).is_empty() and g.leap_cells(0).is_empty(),"Rooted blocks walking and leaping")
 for id in [0,2,3,53,54,57]:
  g.reward = true;g.heroes[0].results[0] = id;g.heroes[0].used[0] = false
  check(not g.hero_action(0,-1,Vector2i(4,5)) and not g.heroes[0].used[0],"Rooted prevents voluntary movement for face %d without spending it" % id)
 g.heroes[0].results[0] = 4;check(g.hero_action(0) and g.heroes[0].block == 1,"Rooted permits non-movement defenses")
 g.heroes[0].results[0] = 58;g.heroes[0].used[0] = false;g.heroes[1].pos = Vector2i(3,4)
 check(not g.hero_action(0,1),"Rooted caster cannot Exchange")
 g.heroes[0].rooted = 0;g.heroes[1].rooted = 1
 check(not g.hero_action(0,1),"Exchange cannot voluntarily move a Rooted ally")
 g.heroes[0].rooted = 1;var before: Vector2i = g.heroes[0].pos
 action(g,"Drive Back")
 check(g.heroes[0].pos != before and g.heroes[0].rooted == 1,"forced Drive Back still moves a Rooted hero")
 g.order = [3,0,1,2];g.cursor = 0;g.pending = {};g.activate()
 check(g.heroes.all(func(h):return h.rooted == 0),"Rooted expires at next boss turn start")
 g = fresh();g.heroes[0].hp = 3;g.heroes[1].hp = 6;g.heroes[2].hp = 2
 before = g.boss.pos;var dist: int = g.distance(3,1);action(g,"Advance")
 check(g.last_targets == [1] and g.distance(3,1) < dist and g.boss.pos != before,"Advance chases highest HP even with a lower-HP hero adjacent")
 check(g.boss.block == 0,"moving into adjacency does not also earn the already-adjacent bonus")
 g = fresh();g.heroes[0].hp = 6;g.heroes[1].hp = 6;before = g.boss.pos;action(g,"Advance")
 check(g.boss.pos == before and g.boss.block == 1,"adjacency to ANY tied highest-HP hero grants Block instead of moving")
 var choices := {}
 for seed_value in range(1,16):
  g = fresh();g.heroes[0].hp = 1;g.heroes[1].hp = 6;g.heroes[2].hp = 6;g.rng.seed = seed_value;action(g,"Advance");choices[g.last_targets[0]] = true
 check(choices.has(1) and choices.has(2),"highest-HP pursuit ties use RNG across both heroes")
 g = fresh();g.heroes[1].hp = 6;g.heroes[1].pos = Vector2i(4,5);action(g,"Distort")
 check(g.heroes[1].weak and not g.heroes[0].weak,"Distort prioritizes reachable highest HP over closest")
 g = fresh();g.heroes[1].hp = 6;g.heroes[2].hp = 4;g.heroes[2].pos = Vector2i(4,5);action(g,"Distort")
 check(g.heroes[0].weak and not g.heroes[2].weak,"unreachable globally highest HP falls back to closest, not second-highest HP")
 for entry in [[Vector2i(4,4),Vector2i.DOWN],[Vector2i(4,1),Vector2i.UP],[Vector2i(3,2),Vector2i.LEFT],[Vector2i(6,3),Vector2i.RIGHT]]:
  g = fresh();g.heroes[0].hp = 6;g.heroes[0].pos = entry[0];action(g,"Drive Back")
  check(g.heroes[0].pos == entry[0]+entry[1] and g.pending.get("kind","") != "push","Drive Back automatically follows incoming hit direction %s" % entry[1])
 g = fresh();g.boss.pos = Vector2i(4,6);g.heroes[0].pos = Vector2i(4,8);g.heroes[0].hp = 6;action(g,"Drive Back")
 check(g.heroes[0].pos == Vector2i(4,8) and g.heroes[0].hp == 4 and g.pending.get("kind","") == "stun","fixed-direction collision applies damage and die choice, without a push-direction choice")
 g = fresh();action(g,"Smoking Strike")
 check(g.heroes[0].hp == 2 and g.fire_tiles == [Vector2i(4,4)],"HP damage ignites one fire cell under struck hero")
 action(g,"Smoking Strike")
 check(g.heroes[0].hp == 0 and g.fire_tiles.is_empty(),"next damaging Smoking Strike consumes that fire for its configured extra normal damage")
 g = fresh();g.heroes[0].block = 1;action(g,"Smoking Strike")
 check(g.heroes[0].hp == 3 and g.fire_tiles.size() == 1,"positive Smoking Strike ignites fire even when fully blocked")
 g.fire_tiles = [Vector2i(4,4)];g.heroes[0].block = 1;action(g,"Smoking Strike")
 check(g.heroes[0].hp == 1 and g.fire_tiles.is_empty(),"blocked hit still detonates existing fire after the hit")
 g = fresh();g.heroes[0].dr = 1;action(g,"Smoking Strike")
 check(g.heroes[0].hp == 3 and g.fire_tiles.size() == 1,"positive hit still ignites when Damage Reduction prevents HP loss")
 g = fresh();action(g,"Smoking Strike");g.heroes[0].pos = Vector2i(4,5)
 check(g.fire_tiles == [Vector2i(4,4)],"fire stays on original cell after hero moves")
 g.heroes[1].pos = Vector2i(4,4);g.heroes[1].hp = 6;action(g,"Smoking Strike")
 check(g.heroes[1].hp == 6-g.v("boss.Strike.damage")-g.v("boss.smoking.fire_damage") and g.fire_tiles.is_empty(),"another hero standing on old fire can trigger its detonation")
 g = fresh();g.balance["boss.smoking.fire_damage"] = 2;g.heroes[0].hp = 6;g.fire_tiles = [Vector2i(4,4)];action(g,"Smoking Strike")
 check(g.heroes[0].hp == 3,"Smoking Strike detonation damage is tunable")
 g = fresh();check(g.boss_dice()[0].has("Smoking Strike") and not g.boss_dice()[0].has("Strike"),"live dice display Smoking Strike instead of the legacy name")
 check(not g.boss_dice()[0].has("Furnace Roar"),"phase-II ability is absent from phase-I boss die")
 g.phase_two = true;check(g.boss_dice()[0][4] == "Furnace Roar","phase-II ability only enters boss die after threshold")
 g = fresh();g.fire_tiles = [Vector2i(4,4)];g.boss.hp = 30;g.new_round()
 check(g.fire_tiles == [Vector2i(4,4)],"shared rolls do not erase persistent fire")
 g = fresh();g.balance["boss.Strike.damage"] = 2;g.heroes[0].hp = 6;g.heroes[0].dr = 1;g.fire_tiles = [Vector2i(4,4)];action(g,"Smoking Strike")
 check(g.heroes[0].hp == 4 and g.fire_tiles.is_empty(),"normal Damage Reduction reduces each separate hit and fire detonation")
 g = Lab.create(5);g.heroes[0].rooted = 1;before = g.heroes[0].pos
 g.pending = {"kind":"attack","action":"Smoking Strike","victims":[0],"reacted":[],"amount":1};g.continue_attack();g.react(true,Vector2i.DOWN)
 check(g.heroes[0].pos == before and g.heroes[0].hp == 3,"rooted reaction can Block but cannot bypass the movement restriction")
 print("BOSS V0.13: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
