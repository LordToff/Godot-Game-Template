extends SceneTree
const Battle = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:failures += 1;printerr("FAIL: ",text)
func fresh():
 var g = Battle.new();g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],71)
 g.active = 0;g.pending = {};g.heroes[0].pos = Vector2i(2,3)
 g.heroes[0].results = [1,4,47];g.heroes[0].rolls = [0,0,0];g.heroes[0].used = [false,false,false]
 return g
func _initialize():call_deferred("run")
func run():
 var tested := 0
 for a in Battle.Catalog.extended_ids():
  for b in Battle.Catalog.extended_ids():
   if b <= a: continue
   var build: Array = Battle.bonus_build([a,b])
   check(not build.is_empty() and Battle.validate(build,[a,b]) == "","legal pair %d/%d" % [a,b])
   if not build.is_empty():
    check(build.any(func(die):return 7 in die),"auto build preserves First Aid")
   tested += 1
 check(Battle.bonus_build([1,9]).is_empty(),"starter excluded from extended bonus pair")
 check(Battle.bonus_build([9,9]).is_empty(),"duplicate bonus disallowed")
 var g = fresh();g.balance["face1.damage"] = 2;g.boss.block = 1;g.hero_action(0,3)
 var hits: Array = g.event_log.filter(func(e):return e.kind == "damage")
 check(hits.size() == 1 and hits[0].source == 0 and hits[0].target == 3 and hits[0].value == 1,"damage event attributes actor, target and actual HP loss")
 check(hits[0].text.contains("1 blocked") and hits[0].text.contains("HP 11/12"),"readable damage summary includes mitigation and remaining HP")
 check(g.event_log.any(func(e):return e.kind == "attack" and e.action == "Strike"),"Attack has a distinct animation event")
 g.hero_action(1)
 check(g.event_log.any(func(e):return e.kind == "block_gain" and e.value == 1),"Block gain has a distinct event")
 g.hero_action(2)
 check(g.event_log.any(func(e):return e.kind == "buff"),"buff gained has a distinct event")
 check(g.event_log.any(func(e):return e.kind == "debuff"),"Bulwark drawback emits a debuff event")
 g = fresh();g.active = 3;g.boss_rolls = ["Distort","Brace","Advance"];g.boss_index = 0;g.boss_step()
 check(g.event_log.any(func(e):return e.kind == "debuff" and e.target == 0 and e.text.contains("Distort")),"boss debuff names source and target")
 g = fresh();g.heroes[0].results[0] = 35;g.heroes[0].debt_buff = 2
 g.hero_action(0,3)
 check(g.boss.max_hp-g.boss.hp <= 2,"Short Shot respects final damage cap even under buffs")
 g = fresh();g.heroes[0].block = 1;g.damage(0,-3)
 check(g.heroes[0].block == 1 and g.heroes[0].hp == 6,"negative damage cannot create Block or healing")
 g = fresh();g.order = [0,1,2,3];g.cursor = 0;g.heroes[0].results[0] = 29
 g.hero_action(0);g.finish_turn()
 check(g.heroes[0].debt_buff == 0,"unused positive Debt expires at turn end")
 g.cursor = 0;g.activate();g.finish_turn();g.cursor = 0;g.activate()
 check(g.heroes[0].debt_penalty == 2,"unpaid Debt penalty carries to the next eligible face")
 print("PRESENTATION/PAIR TESTS: %d checks (%d full-pool pairs), %d failures" % [checks,tested,failures])
 quit(1 if failures else 0)
