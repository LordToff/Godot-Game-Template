extends SceneTree
const Battle = preload("res://prototype/battle.gd")
const Catalog = preload("res://prototype/catalog.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:failures += 1;printerr("FAIL: ",text)
func fresh(id: int = 1):
 var g = Battle.new();g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],37)
 g.active = 0;g.pending = {}; g.forced_die = -1
 g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(2,4);g.heroes[2].pos = Vector2i(1,3)
 for h in g.heroes:
  h.hp = 4;h.rolls = [0,0,0];h.results = [1,4,7];h.used = [false,false,false];h.reaction = []
 g.heroes[0].build[0][0] = id;g.heroes[0].results[0] = id
 return g
func _initialize():call_deferred("run")
func run():
 check(Catalog.draft_ids().size() == 55,"entire playable hero-action catalog in draft")
 for id in Catalog.draft_ids():
  var build: Array = [[1,2,4,0,0,0],[1,3,5,0,0,0],[1,7,id,0,0,0]]
  check(Battle.validate(build,id) == "","gift can be legally installed: "+Catalog.name_for(id))
  if id >= 9:check(Battle.validate(build) != "","unowned extended face rejected")
 var g = fresh()
 check(g.heroes.all(func(h):return h.rerolls == 1),"each hero begins with one Action Reroll")
 check(g.action_reroll(0) and g.heroes[0].rerolls == 0,"one charge is spent")
 check(not g.action_reroll(1),"no second free reroll")
 g = fresh();g.hero_action(1)
 check(not g.action_reroll(0),"ordinary resolution closes reroll opening")
 g = fresh();g.damage(0,100)
 check(g.heroes[0].rerolls == 0,"Downed clears the reroll bank")
 g = fresh();g.active = 3;g.boss_rolls = ["Advance","Brace","Strike"];g.boss_index = 0
 g.boss_step();check(g.boss.block == 1,"Advance adjacent to a tied highest-HP hero gains one Block")
 g.boss.block = 0;g.boss_step();check(g.boss.block == 1,"tuned Brace independently gives one Block")
 g = fresh(1);g.hero_action(0,3);check(g.boss.hp == g.boss.max_hp-1,"Strike deals one")
 for id in range(9,57):
  g = fresh(id)
  if Catalog.is_reaction(id):
   g.heroes[0].reaction = [0];g.heroes[0].used[0] = true
   var target := 1 if id in [44,45] else 0
   if id == 46:g.heroes[0].hp = 1
   if id == 48:g.heroes[0].taken = 2
   g.pending = {"kind":"attack","action":"Strike","victims":[target],"reacted":[],"amount":2}
   g.continue_attack()
   check(not g.pending.is_empty() and g.pending.kind == "reaction","reaction is triggerable: "+Catalog.name_for(id))
   if not g.pending.is_empty():g.react(true)
  else:
   var target := 3 if Catalog.is_attack(id) else (1 if id in [12,15,19] else (0 if id == 55 else -1))
   if id == 22:g.heroes[0].used = [false,true,true]
   if id == 23:g.heroes[0].used[2] = true
   if id == 26:g.heroes[0].results[1] = 0
   if id == 32:g.heroes[0].results[1] = 4
   var dest := Vector2i(1,3) if id == 53 else Vector2i(-99,-99)
   if id == 53:dest = Vector2i(1,2)
   check(g.hero_action(0,target,dest),"face can resolve: "+Catalog.name_for(id))
   if not g.pending.is_empty():
    match g.pending.kind:
     "bind":g.choose_bind(0,"Strike")
     "ember":g.ember(1)
     "slot":check(g.choose_slot(0,4),"choose exact generated face slot")
     "catalog_choice":
      match id:
       11:check(g.catalog_pick(1,0),"Conjure picks an immediate face")
       16:check(g.catalog_pick(0,1,0),"Borrow Shape rotates a die")
       23:
        check(g.catalog_pick(0,1),"Second Chance skips a die")
        check(not g.catalog_pick(0,1),"skipped die cannot count as already resolved")
        check(g.catalog_pick(0,2),"Second Chance repeats another spent face")
       26:
        check(g.catalog_pick(0,1),"conversion chooses a Blank die")
        check(g.catalog_pick(0,1,0),"conversion chooses an installed face")
       30:check(g.catalog_pick(0,1),"Ill Omen modifies Defense")
       32:check(g.catalog_pick(0,1),"Oath of Smoke selects Guard")
   if id in [25,31,49]:
    g.pending = {"kind":"channel","hero":0};g.channel_choice(true)
    check(not g.heroes[0].channel.is_empty(),"channel maintained: "+Catalog.name_for(id))
    g.pending = {"kind":"channel","hero":0};g.channel_choice(false)
    check(g.heroes[0].channel.is_empty(),"channel can end: "+Catalog.name_for(id))
 g = fresh(54)
 var before: int = g.heroes[0].block
 check(not g.hero_action(0,-1,Vector2i(8,8)) and g.heroes[0].block == before,"invalid Bone movement cannot farm Block")
 g = fresh(47);g.hero_action(0)
 check(g.heroes[0].dr == 1 and g.heroes[0].bulwark_weak,"Bulwark grants its paired protection and drawback")
 print("CATALOG TESTS: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
