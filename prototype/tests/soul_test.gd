extends SceneTree
const Battle = preload("res://prototype/battle.gd")
var checks := 0
var errors := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:errors += 1;printerr("SOUL FAIL: ",text)
func fresh(reward: bool = true):
 var g = Battle.new();g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],391,reward)
 g.order = [0,1,2,3];g.cursor = 0;g.active = 0;g.pending = {};g.boss.pos = Vector2i(5,1)
 for i in range(3):
  var h: Dictionary = g.heroes[i]
  h.pos = Vector2i(i*3,7);h.results = [0,0,2];h.rolls = [4,4,1];h.used = [false,false,false];h.reaction = []
 return g
func _initialize():call_deferred("run")
func run():
 var g = fresh()
 check(g.hero_action(0,-1,Vector2i(0,5)),"first reward Blank moves up to two")
 check(g.heroes[0].soul_move_used and g.heroes[0].used[0],"successful conversion consumes allowance and result")
 check(not g.hero_action(1,-1,Vector2i(0,4)) and not g.heroes[0].used[1] and g.heroes[0].pos == Vector2i(0,5),"second conversion rejected without spending die or moving")
 check(g.hero_action(2,-1,Vector2i(0,4)),"ordinary movement still works after Soul conversion")
 check(g.heroes[0].build[0][4] == 0,"conversion does not install a Movement face")
 check(g.event_log.any(func(e):return e.kind == "soul" and e.text.contains("1/1")),"log explains spent Soul allowance")
 g.finish_turn()
 check(g.active == 1 and not g.heroes[1].soul_move_used,"each hero has independent allowance")
 check(g.hero_action(0,-1,Vector2i(3,5)),"second hero can use own Soul")
 g.cursor = 0;g.activate();g.heroes[0].results[1] = 0;g.heroes[0].used[1] = false
 check(not g.heroes[0].soul_move_used and g.hero_action(1,-1,Vector2i(0,3)),"next own activation resets allowance")
 g = fresh();check(not g.hero_action(0,-1,Vector2i(8,0)) and not g.heroes[0].soul_move_used,"invalid destination does not consume allowance")
 g.decline(0)
 check(not g.heroes[0].soul_move_used and g.hero_action(1,-1,Vector2i(0,5)),"declining a Blank does not consume conversion")
 g = fresh();g.hero_action(0,-1,Vector2i(0,5));g.roll_hero(g.heroes[0])
 check(g.heroes[0].soul_move_used,"rolling dice does not refill allowance")
 g = fresh(false)
 check(g.hero_action(0,-1,Vector2i(0,5)) and g.heroes[0].pos == Vector2i(0,7) and not g.heroes[0].soul_move_used,"starting Soul still grants no movement")
 g = fresh();g.heroes[1].soul_move_used = true;g.damage(1,6);g.heal(1,1);g.finish_turn()
 check(g.active == 1 and g.recovery_active and not g.heroes[1].soul_move_used,"full recovery turn resets its own allowance")
 print("REWARD SOUL: %d checks, %d failures" % [checks,errors])
 quit(1 if errors else 0)
