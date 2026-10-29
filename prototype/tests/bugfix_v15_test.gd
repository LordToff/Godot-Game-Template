extends SceneTree
const Lab = preload("res://prototype/lab.gd")
const B = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("BUG SCAN FAIL: ",what)
func _initialize():call_deferred("run")
func run():
 var g = Lab.create(1);g.boss.pos = Vector2i(4,6);g.heroes[0].pos = Vector2i(4,8);g.heroes[0].hp = 6;g.heroes[0].used = [true,true,true];g.pending = {"kind":"push","hero":0,"direction":Vector2i.DOWN};g.push(Vector2i.DOWN)
 check(g.heroes[0].stun and g.pending.is_empty(),"collision applies Stunned even with no unused die")
 g.new_round();check(g.pending.get("kind","") == "preroll_stun" and g.pending.hero == 0,"carried Stunned sets aside a die before next shared roll")
 g = Lab.create(4);g.heroes[0].hp = 1;g.heroes[0].broken = true;g.damage(0,1,true)
 check(g.heroes[0].dead and not g.hero_action(0) and g.heroes[0].block == 0,"killed Broken hero cannot keep resolving dice")
 check(not g.action_reroll(1),"dead hero cannot spend saved rerolls")
 g = Lab.create(1);g.heroes[0].results[2] = 4
 check(not g.hero_action(-1) and not g.heroes[0].used[2],"negative stale die index cannot resolve another die")
 g = Lab.create(1,-1,{"face51.range":0});g.heroes[0].backstab = g.round_no;g.hero_action(0,3)
 check(g.boss.hp == 28,"rear repeat is independent of Wither Ward range")
 g = Lab.create(27,-1,{"face27.charges":0});g.hero_action(0);g.heroes[0].results[1] = 1;g.hero_action(1,3)
 check(g.boss.bargain.is_empty() and g.boss.hp == 29,"zero Blood Bargain charges cannot create unlimited damage bonus")
 g = Lab.create(1);g.heroes[0].hp = 1;g.heroes[0].defy = true;g.heroes[0].ward = true;g.damage(0,1)
 check(g.heroes[0].hp == 1 and not g.boss.weak,"Wither Ward requires actual HP loss after Defy Death")
 check(B.validate([]) != "" and B.validate([[0,0,0,0,0,0]]) != "","loadout validation requires exactly three dice")
 g = Lab.create(47,-1,{"face47.reduction":3,"face47.weakness":2});g.hero_action(0)
 check(g.event_log.any(func(e):return e.kind == "debuff" and "Weakness 2" in e.text),"Weakness logs report actual configured penalty")
 check(g.event_log.any(func(e):return e.kind == "buff" and "Reduction 3" in e.text),"reduction logs report actual configured value")
 g = Lab.create(1);g.heroes[0].dead = true;g.heroes[0].hp = 0
 check(not g.action_reroll(0),"dead hero cannot reroll even if opening flag and bank are stale")
 g = Lab.create(6)
 check(not g.hero_action(0,3) and not g.heroes[0].used[0],"Focus rejects a nonexistent fourth die without spending itself")
 g = Lab.create(1);g.pending = {"kind":"reaction","action":"Smoking Strike","victims":[0],"hero":0,"victim":0,"die":0,"reacted":[],"amount":1};g.react(false)
 check(g.pending.is_empty(),"explicit reaction die does not index an empty held list")
 g = Lab.create(1);var before: Dictionary = g.state_snapshot()
 g.react(true);g.fracture(0,0);g.push(Vector2i.UP);g.stun_die(0);g.channel_choice(true);g.choose_bind(0,"Smoking Strike");g.ember(1)
 check(g.state_snapshot() == before and g.pending.is_empty(),"obsolete modal callbacks safely do nothing")
 check(not g.catalog_pick(0,0),"obsolete catalog choice is rejected")
 g.heroes[0].used[0] = true;g.decline(0);check(g.heroes[0].used[0],"declining an already-spent die is harmless")
 g = Lab.create(34,-1,{"numeric.positive_faces":0})
 check(g.numeric_faces(false) == ["0","0","0","0","0","0"],"zero positive Numeric sides creates an all-Blank die, without leftover high-value sides")
 print("V0.15 BUG SCAN: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
