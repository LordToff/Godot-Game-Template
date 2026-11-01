extends SceneTree
const Lab = preload("res://prototype/lab.gd")
const Bug = preload("res://prototype/bugh.gd")
const B = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V222 SWEEP FAIL: ",why)
func redirected(alternative: bool = false):
 var g = Lab.create(28)
 g.heroes[1].pos = Vector2i(3,2) if alternative else Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 var worm: int = g.spawn_friendly(0,Vector2i(4,5));g.unit_data(worm).pos = Vector2i(3,3)
 g.pending = {"kind":"attack","source":3,"action":"Smoking Strike","victims":[0],"reacted":[],"amount":1}
 g.continue_attack();check(g.pending.get("kind","") == "reaction","Override opens normal Reaction window")
 g.react(true)
 return g
func _initialize():call_deferred("run")
func run():
 var g = redirected()
 check(not g.unit_data(g.owned_worm(0)).get("dead",false) if g.owned_worm(0)>=4 else false,"Override never redirects a hero-only ability onto a friendly worm")
 check(g.heroes[0].hp == 2,"without another legal hero, the original hero takes the hit")
 g = redirected(true)
 check(g.heroes[0].hp == 3 and g.heroes[1].hp == 2,"another legal hero can still receive an overridden attack")
 check(g.owned_worm(0) >= 4,"legal hero redirect leaves the friendly worm intact")
 g = Lab.create(59);var worm: int = g.spawn_friendly(0,Vector2i(4,5))
 g.unit_data(worm).rooted = 1;g.unit_data(worm).weak = 2;g.unit_data(worm).poison = 1
 var details: String = g.summon_description(worm)
 check(details.contains("Rooted") and details.contains("next boss turn"),"friendly worm hover explains blocked movement and its expiry")
 check(details.contains("Weakness 2") and details.contains("Poison 1"),"friendly worm hover includes actual Weakness and Poison values")
 g = Bug.new();g.start([B.default_build(),B.default_build(),B.default_build()],4)
 g.boss.poison = 1;g.boss.weak = true;g.boss.weak_amount = 3
 check(g.status_description(3).contains("Poison 1"),"Bu’gh boss hover includes friendly-worm Poison")
 check(g.status_description(3).contains("Weakness 3"),"Bu’gh boss hover includes actual custom Weakness")
 g = Lab.create(1);g.boss.weak = true;g.boss.weak_amount = 3
 check(g.status_description(3).contains("−3"),"base boss status uses actual Weakness rather than Wither Ward's default")
 g.begin_action(0,"status test");g.boss.weak = false;g.action_before = g.state_snapshot();g.boss.weak = true;g.report_changes()
 check(g.event_log.any(func(e):return e.kind == "debuff" and e.text.contains("Weakness 3")),"debuff log reports the same effective Weakness as combat")
 g = Lab.create(1);g.begin_action(3,"Worm Bite");g.heroes[0].poison = 1;g.report_changes()
 check(g.event_log.any(func(e):return e.kind == "debuff" and e.text.contains("Poison")),"Poison gain is logged as harmful rather than a buff")
 g = Lab.create(1);g.heroes[0].weak = true;g.order = [3,0,1,2];g.cursor = 0;g.activate()
 check(g.event_log.any(func(e):return e.kind == "expire" and e.text.contains("Weakness ends")),"expiry names the status rather than falsely naming Distort")
 print("V0.22.2 BUG SWEEP: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
