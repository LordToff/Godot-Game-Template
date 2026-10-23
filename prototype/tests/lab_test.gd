extends SceneTree
const Lab = preload("res://prototype/lab.gd")
const Battle = preload("res://prototype/battle.gd")
const Catalog = preload("res://prototype/catalog.gd")
var checks := 0
var errors := 0
func check(ok: bool, message: String):
 checks += 1
 if not ok: errors += 1; printerr("LAB FAIL: ",message)
func _initialize(): call_deferred("run")
func run():
 for id in range(57):
  var g = Lab.create(id,1)
  check(g.active == 0 and g.face(0,0) == id and g.outcome == "","prepared fixture: "+Battle.FACES[id])
  check(not Lab.guide(id).is_empty(),"guidance: "+Battle.FACES[id])
  if Catalog.is_reaction(id):
   Lab.attack(g,id)
   check(g.pending.get("kind","") == "reaction","actual boss trigger: "+Battle.FACES[id])
   if g.pending.get("kind","") == "reaction": g.react(true)
  else:
   var target := 3 if Catalog.is_attack(id) else (1 if id in [7,8,12,15,19] else (0 if id == 55 else -1))
   var dest := Vector2i(4,5) if id in [2,3,53,54] else (Vector2i.LEFT if id == 8 else Vector2i(-99,-99))
   if id == 6: target = 1
   check(g.hero_action(0,target,dest),"resolve fixture face: "+Battle.FACES[id])
   if not g.pending.is_empty():
    match g.pending.kind:
     "slot":
      check(not g.choose_slot(0,0),"occupied slots rejected without spending")
      check(g.choose_slot(2,5),"specific Blank chosen")
      check(g.heroes[1 if id == 12 else 0].build[2][5] == (55 if id == 12 else 54),"requested slot receives face")
     "bind":g.choose_bind(0,"Strike")
     "ember":g.ember(1)
     "catalog_choice":
      match id:
       11:g.catalog_pick(1,0); g.hero_action(0,3)
       16:g.catalog_pick(0,1,1); g.hero_action(1)
       23:g.catalog_pick(0,1);g.catalog_pick(0,2);g.hero_action(0)
       26:
        check(g.catalog_pick(0,1),"conversion stage one")
        check(not g.catalog_pick(0,1,3),"conversion cannot select another Blank")
        check(g.catalog_pick(0,1,2),"conversion can choose a reaction")
        check(g.heroes[0].used[1] and 1 in g.heroes[0].reaction and g.heroes[0].build[0][0] == 56,"converted reaction stored; Red cost paid")
       30:g.catalog_pick(0,1);g.hero_action(1,3)
       32:g.catalog_pick(0,1);g.hero_action(1)
  check(g.outcome == "","test does not prematurely end: "+Battle.FACES[id])
  check(g.pending.is_empty(),"face completes all choices: "+Battle.FACES[id])
  if id in [25,31,49]:
   Lab.next_turn(g,1)
   check(g.pending.get("kind","") == "channel","next-turn Channel choice exists")
   g.channel_choice(true)
   Lab.attack(g,id)
   check(g.heroes[0].hp >= 0,"channel handles follow-up damage")
 # Balance and restrictions must hold for both zero and positive results.
 for tuned in [true,false]:
  var g = Lab.create(34,1);g.tuned = tuned;g.hero_action(0,3)
  check(g.boss.hp == (28 if tuned else 29),"Numeric attack balance mode")
  g = Lab.create(34,0);g.tuned = tuned;g.hero_action(0,3)
  check(g.boss.hp == 30,"Numeric zero stays zero")
  g = Lab.create(35,1);g.tuned = tuned;g.hero_action(0,3)
  check(g.boss.hp == 29,"Short Shot cap survives tuning")
 var g = Lab.create(15,1)
 for d in range(3):g.heroes[1].build[d] = [1,1,1,1,1,1]
 check(not g.hero_action(0,1) and not g.heroes[0].used[0] and g.heroes[0].build[0][0] == 15,"Passing Grace refuses a full recipient without destroying source")
 g = Lab.create(35,1);g.heroes[0].pos = Vector2i(1,1);g.heroes[1].pos = Vector2i(2,1);g.heroes[2].pos = Vector2i(2,2);g.boss.pos = Vector2i(7,7)
 check(not g.sight(0,2,2),"straight sight cannot bend around corner blocker")
 g.heroes[1].pos = Vector2i(6,6)
 check(g.sight(0,2,2),"unblocked diagonal ray works")
 g = Lab.create(9,1);g.hero_action(0);Lab.roll_test_face(g,9,1);g.hero_action(0)
 check(g.heroes[0].gold == 1 and g.heroes[0].build[0][0] == 0,"repeat roll tests Gambler second use and mutation")
 g = Lab.create(12,1);g.hero_action(0,1);g.choose_slot(2,5);Lab.roll_test_face(g,12,1);g.hero_action(0,2);g.choose_slot(2,5)
 check(g.heroes[0].blessings == 2 and g.heroes[0].build[0][0] == 0,"Blessing completes both placements and source expiry")
 g = Lab.create(13,1);g.heroes[0].rerolls = 0;Lab.roll_test_face(g,13,1)
 check(g.heroes[0].rerolls == 1,"lab can demonstrate Clairvoyance replenishment")
 g = Lab.create(31,1);g.hero_action(0);Lab.roll_test_face(g,31,1)
 check(g.heroes[0].used[0] and not g.heroes[0].channel.is_empty(),"lab cannot reroll through held Channel")
 print("ABILITY LAB: %d checks, %d failures" % [checks,errors])
 quit(1 if errors else 0)
