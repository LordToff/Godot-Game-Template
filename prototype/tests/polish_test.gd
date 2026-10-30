extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var errors := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:errors += 1;printerr("POLISH FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 var g = Lab.create(35,1);g.boss.mark = true;g.hero_action(0,3)
 check(g.boss.hp == 28 and not g.boss.mark,"Short Shot cap includes mark and consumes mark")
 g = Lab.create(37,1);g.heroes[1].hp = 1;g.heroes[1].block = 1;g.hero_action(0,1)
 check(g.heroes[1].hp == 0 and g.heroes[1].block == 0,"Pierce cannot restore Block to a Downed hero")
 g = Lab.create(40,2);g.boss.block = 1;g.order = [0,3,1,2];g.initiative_base = g.order.duplicate();g.cursor = 0;g.hero_action(0,3)
 check(g.order == [0,1,3,2],"Rhythm delays upcoming activation")
 g.new_round();check(g.order == [0,3,1,2],"next round restores initiative")
 for keep in [true,false]:
  g = Lab.create(25,1);g.hero_action(0);var h: Dictionary = g.heroes[0]
  h.block = 0;h.channel.confirmed = false;h.channel.pending_blank = 0;h.results[1] = 0;g.on_roll(h,1)
  check(h.block == 0,"unconfirmed Channel holds future-roll Block")
  g.pending = {"kind":"channel","hero":0};g.channel_choice(keep)
  check(h.block == (1 if keep else 0),"only maintain grants held benefits")
 g = Lab.create(34,1);g.heroes[0].backstab = g.round_no;g.hero_action(0,3)
 check(g.event_log.filter(func(e):return e.kind == "roll" and e.text.contains("Numeric")).size() == 2,"repeated Numeric attacks roll separately")
 check(g.roll_presentations.filter(func(e):return e.kind.begins_with("Numeric")).size() == 2,"both Numeric rolls have presentation data")
 g = Lab.create(1);g.heroes[0].rerolls = 1;g.action_reroll(0)
 check(g.roll_presentations.back().dice == [0] and g.roll_presentations.back().faces.size() == 1,"reroll animates only affected die")
 g = Lab.create(49);g.hero_action(0);g.pending = {"kind":"channel","hero":0};g.channel_choice(false)
 check(g.roll_presentations.back().kind == "Released Channel die","released Channel has its own roll presentation")
 print("POLISH RULES: %d checks, %d failures" % [checks,errors]);quit(1 if errors else 0)
