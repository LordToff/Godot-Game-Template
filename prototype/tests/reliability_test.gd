extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var errors := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:errors += 1;printerr("RELIABILITY FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 for id in [25,49]:
  var g = Lab.create(id,1);g.hero_action(0);g.damage(0,20)
  check(g.heroes[0].hp == 0 and g.heroes[0].channel.is_empty(),"lethal hit clears Channel")
  check(g.heroes[0].build[0][0] == (56 if id == 25 else 0),"lethal Channel break changes installed face")
  check(g.event_log.any(func(e):return e.kind == "mutation"),"Channel break is visible in log")
 var g = Lab.create(49);g.hero_action(0);g.heroes[0].block = 3;g.damage(0,2)
 check(not g.heroes[0].channel.is_empty(),"fully prevented hit does not break Channel")
 g = Lab.create(31);g.hero_action(0);g.heroes[0].results[1] = 49;g.heroes[0].used[1] = false
 check(not g.hero_action(1) and g.heroes[0].channel.face == 31 and not g.heroes[0].used[1],"second Channel cannot silently overwrite first")
 g = Lab.create(1);var h: Dictionary = g.heroes[0]
 h.ward = true;h.num_boost = 2;h.stored_num = 1;h.backstab = 2;h.debt_buff = 2;h.debt_next = 2;h.black_oath = true;h.mods = {1:{"value":2}};h.smoke = {2:4}
 g.damage(0,20);g.heal(0,1)
 check(not h.ward and h.num_boost == 0 and h.stored_num == -1 and h.backstab == 0,"revival cannot retain old buffs")
 check(h.debt_buff == 0 and h.debt_next == 0 and not h.black_oath and h.mods.is_empty() and h.smoke.is_empty(),"Downed clears temporary costs and modifiers")
 print("RELIABILITY: %d checks, %d failures" % [checks,errors]);quit(1 if errors else 0)
