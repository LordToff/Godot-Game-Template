extends SceneTree
const E = preload("res://prototype/expedition.gd")
const M = preload("res://prototype/event_battle.gd")
const B = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String):
 checks += 1
 if not ok:failures += 1;printerr("EVENT FAIL: ",message)
func choice(id: int):
 var e = E.new();e.selected = id;e.stage = "choice";return e
func fresh(hard: bool = false):
 var g = M.new();g.hard = hard;g.start([B.default_build(),B.default_build(),B.default_build()],25)
 g.pending = {};return g
func _initialize():call_deferred("run")
func run():
 for seed_value in range(100):
  var e = E.new();e.rng.seed = seed_value
  var rolled: int = e.roll()
  check(rolled >= 1 and rolled <= 6,"d6 range")
  check(e.roll() == rolled and e.serial == 1,"roll locked until next sortie")
 for id in range(1,7):
  for option in range(2):
   var e = choice(id);e.gold = 2;e.salves = 1;e.rng.seed = 25
   check(e.choose(option),"legal choice accepted")
   if e.stage == "combat":
    check(e.gold == 2 and e.fragments == 0,"no premature encounter reward")
    check(e.finish_combat(true),"victory settles once")
   var wallet := e.inventory();var text: String = e.summary
   check(not e.choose(option) and not e.finish_combat(true),"duplicate claim denied")
   check(wallet == e.inventory() and text == e.summary,"duplicate cannot alter summary or rewards")
 var e = choice(1);e.choose(0);check(e.salves == 1,"supplies salve quantity")
 e = choice(1);e.choose(1);check(e.seals == 1,"supplies seal quantity")
 e = choice(2);check(not e.choose(1) and e.stage == "choice","unaffordable shrine leaves choice open")
 e = choice(3);check(not e.choose(1),"help requires salve")
 e = choice(3);e.salves = 1;e.choose(1);check(e.salves == 0 and e.gold == 3 and e.seals == 1,"help exact costs and grant")
 for id in [4,5]:
  e = choice(id);e.choose(1);e.finish_combat(false)
  check(e.gold == 0 and e.fragments == 0 and e.salves == 0,"defeat gives no reward")
  e = choice(id);e.choose(1);e.finish_combat(true)
  check(e.gold == (3 if id == 4 else 5) and e.salves == (1 if id == 4 else 0) and e.seals == (0 if id == 4 else 1) and e.fragments == (0 if id == 4 else 1),"exact victory rewards")
 # Both risk branches and exact deductions across many deterministic seeds.
 var shrine_hits := 0;var shrine_miss := 0;var relic_hits := 0;var relic_miss := 0
 for seed_value in range(40):
  e = choice(2);e.gold = 2;e.rng.seed = seed_value;e.choose(1)
  check(e.gold == 0 and e.fragments in [0,1],"shrine pays exactly two and grants at most one")
  if e.fragments:shrine_hits += 1
  else:shrine_miss += 1
  e = choice(6);e.salves = 1;e.rng.seed = seed_value;e.choose(1)
  if e.fragments:relic_hits += 1;check(e.gold == 3 and e.salves == 1,"reliquary success exact")
  else:relic_miss += 1;check(e.gold == 0 and e.salves == 0,"reliquary failure exact")
 check(shrine_hits > 0 and shrine_miss > 0 and relic_hits > 0 and relic_miss > 0,"risk outcomes exercised")
 e = E.new();e.fragments = 3;check(e.unlock_soul() and e.fragments == 0 and e.soul,"soul costs three")
 check(not e.unlock_soul(),"soul cannot be claimed twice")
 e.gold = 7;e.salves = 2;e.seals = 3;e.save()
 var loaded = E.new();loaded.load_save();check(loaded.inventory() == e.inventory(),"reward ledger survives reload")
 e = choice(4);e.choose(1);loaded = E.new();loaded.load_save()
 check(loaded.stage == "resolved" and loaded.gold == 0 and not loaded.finish_combat(true),"interrupted encounter never grants victory")
 var g = fresh();e = E.new();e.salves = 2;e.seals = 2;g.active = 0;g.heroes[0].hp = 3
 check(e.use_supply(g,"salve") and g.heroes[0].hp == 5 and e.salves == 1,"salve heals exactly two")
 check(not e.use_supply(g,"salve"),"salve once per own turn")
 g.heroes[0].rerolls = 0;check(e.use_supply(g,"seal") and g.heroes[0].rerolls == 1,"seal restores one reroll")
 check(not e.use_supply(g,"seal"),"seal respects reroll cap")
 g.pending = {"kind":"choice"};check(not e.use_supply(g,"salve"),"pending choice forbids supply")
 g.pending = {};g.heroes[0].hp = 0;check(not e.use_supply(g,"salve"),"salve cannot revive")
 for hard in [false,true]:
  g = fresh(hard)
  check(g.encounter_id == "event" and g.cells(3).size() == 1 and g.living_minions().size() == 1,"two ordinary one-cell monsters")
  check(g.summon_description(4).contains("not a summon"),"ordinary monster tooltip does not recurse or call it a summon")
  check(g.boss.hp == (4 if hard else 3) and g.unit_data(4).hp == g.boss.hp,"monster HP")
  g.damage(3,99,true);check(g.outcome == "" and not g.phase_two,"first kill is not victory or phase transition")
  g.damage(4,99,true);check(g.outcome == "victory","both defeated wins")
 g = fresh();g.heroes[0].pos = Vector2i(3,5);g.heroes[0].reaction = [];g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 g.active = 3;g.boss_rolls = ["Bite","Guard","Scuttle"];g.boss_index = 0;g.boss_step()
 check(g.heroes[0].hp == 5 and g.heroes[0].get("poison",0) == 0,"ordinary bite does one with no poison")
 g.boss_step();check(g.boss.block == 1 and g.unit_data(4).block == 1,"both monsters guard")
 g.boss_step();check(g.boss_index == 3 and g.pending.is_empty(),"three public results resolve")
 g = fresh();g.heroes[0].pos = Vector2i(3,5);g.heroes[0].results = [5,0,0];g.heroes[0].reaction = [0];g.active = 3;g.boss_rolls = ["Bite","Guard","Guard"];g.boss_index = 0;g.boss_step()
 check(g.pending.get("kind","") == "reaction","monster bite offers held reaction")
 g.react(true);check(g.heroes[0].hp == 6 and g.pending.is_empty(),"reaction prevents bite and continues second monster")
 print("Events v0.25: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
