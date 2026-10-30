extends SceneTree
const B = preload("res://prototype/battle.gd")
const Nu = preload("res://prototype/nugh.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V21 FAIL: ",why)
func fresh(seed_value: int = 1):
 var g = Nu.new();g.start([B.default_build(),B.default_build(),B.default_build()],seed_value)
 g.pending = {};g.minions.clear();g.spawn_worms(1);g.unit_data(4).pos = Vector2i(2,6)
 for h in g.heroes:h.reaction.clear()
 g.heroes[0].pos = Vector2i(2,7);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 g.active = 3;g.order = [3,0,1,2];g.cursor = 0;g.boss_index = 3;g.boss_rolls = ["Bound","Bound","Bound"]
 return g
func _initialize():call_deferred("run")
func run():
 var hits := 0
 for seed_value in range(1,301):
  var g = fresh(seed_value);var before: int = g.roll_presentations.size()
  g.finish_turn()
  check(g.active == 3 and g.autonomous and g.command_active,"brood pauses initiative before next hero")
  check(g.roll_presentations.size() == before+1,"one actual Numeric presentation per adjacent bite")
  var p: Dictionary = g.roll_presentations.back()
  check(p.faces[0] == ["1","1","0","0","0","0"],"worm die has exact requested six sides")
  var hit: bool = int(p.sides[0]) < 2
  check(g.heroes[0].hp == (5 if hit else 6),"actual damage matches recorded side")
  check(g.heroes[0].get("poison",0) == (1 if hit else 0),"misses never poison")
  if hit:hits += 1
  g.boss_step()
  check(g.active == 0 and not g.command_active,"brood finishes once and initiative advances")
  check(g.heroes[0].hp == (4 if hit else 6) and g.heroes[0].get("poison",0) == 0,"next own turn consumes Poison exactly once")
  check(g.event_log.filter(func(e):return e.kind == "roll" and e.source == 4).size() == 1,"no duplicate end-turn activation")
 check(hits > 65 and hits < 135,"300 seeded bites have plausible one-third hit frequency")
 var g = fresh();g.balance["nugh.worm_hit_faces"] = 6;g.heroes[0].block = 1
 g.finish_turn();check(g.heroes[0].hp == 6 and g.heroes[0].get("poison",0) == 0,"fully blocked hit cannot poison")
 g = fresh();g.balance["nugh.worm_hit_faces"] = 6;g.heroes[0].results[0] = 5;g.heroes[0].used[0] = true;g.heroes[0].reaction = [0]
 g.finish_turn();check(g.pending.get("kind","") == "reaction" and g.pending.source == 4,"autonomous bite gives real source-aware Reaction")
 g.react(true);check(g.heroes[0].hp == 6 and g.heroes[0].block == 1 and g.heroes[0].get("poison",0) == 0,"Reaction can prevent Poison")
 check(g.event_log.any(func(e):return e.kind == "attack" and e.source == 4) and g.event_log.any(func(e):return e.kind == "block" and e.source == 4),"reaction does not misattribute worm damage to hero")
 g.boss_step();check(g.active == 0,"reaction resumes brood then next hero")
 g = fresh();g.balance["nugh.worm_hit_faces"] = 6;g.boss_index = 0;g.boss_rolls = ["Brood Command","Bound","Bound"]
 g.boss_step();g.boss_step();g.boss_step();g.boss_step();g.boss_step()
 check(g.heroes[0].hp == 4 and g.heroes[0].poison == 1,"command plus autonomous bite, poison refreshes without stacking")
 g.boss_step();check(g.heroes[0].hp == 3 and g.heroes[0].poison == 0,"single poison tick after two bites")
 g = fresh();g.minions.clear();g.finish_turn();check(g.active == 0,"empty autonomous brood does not summon or stall")
 g = fresh();g.heroes[0].poison = 1;g.heroes[0].block = 10;g.tick_poison(0)
 check(g.heroes[0].hp == 5 and g.heroes[0].block == 10 and g.heroes[0].poison == 0,"Poison bypasses Block and clears")
 g.tick_poison(0);check(g.heroes[0].hp == 5,"no second tick")
 g.heroes[0].poison = 1;g.damage(0,99,true)
 check(g.heroes[0].get("poison",0) == 0,"Downed clears Poison")
 g = fresh();g.active = 0;g.cursor = 0;g.order = [0,1,2,3];g.heroes[0].hp = 1;g.heroes[0].poison = 1
 g.activate()
 check(g.active == 1 and g.heroes[0].hp == 0 and not g.heroes[0].protected,"lethal turn-start Poison ends skipped turn and Downed protection normally")
 g = fresh();g.damage(3,99);g.finish_turn()
 check(g.outcome == "victory" and not g.command_active,"no brood activation after boss death")
 print("V0.21 BROOD: %d checks, %d failures; seeded successful bites %d/300" % [checks,failures,hits]);quit(1 if failures else 0)
