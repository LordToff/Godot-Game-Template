extends RefCounted
const Battle = preload("res://prototype/battle.gd")
const Catalog = preload("res://prototype/catalog.gd")

static func create(id: int, forced_numeric: int = -1, profile: Dictionary = {}, balanced: bool = true):
 var g = Battle.new()
 g.start([Battle.default_build(),Battle.default_build(),Battle.default_build()],417,false,balanced,profile)
 g.pending = {}; g.outcome = ""; g.order = [0,1,2,3]; g.initiative_base = g.order.duplicate(); g.cursor = 0; g.active = 0; g.forced_die = -1
 g.boss.pos = Vector2i(4,2); g.boss.hp = g.v("lab.boss_hp"); g.boss.max_hp = g.boss.hp; g.boss.block = g.v("lab.boss_block"); g.boss_rolls = ["Strike","Grave Tithe","Sweep"]
 g.boss_sides = [2,4,3]
 for i in range(3):
  var h: Dictionary = g.heroes[i]
  h.pos = [Vector2i(4,4),Vector2i(3,4),Vector2i(5,4)][i]
  h.hp = mini(g.v("lab.hero_hp"),h.max_hp); h.block = g.v("lab.hero_block"); h.reaction = []; h.channel = {}; h.used = [false,false,false]; h.rolls = [0,0,0]; h.results = [1,34,4]
  h.build = [[1,34,4,0,0,0],[34,4,5,0,0,0],[4,7,2,0,0,0]]
  h.stored_num = forced_numeric
 g.heroes[0].build[0][0] = id; g.heroes[0].results[0] = id
 g.initial_builds = g.heroes.map(func(h):return h.build.duplicate(true))
 if id == 22: g.heroes[0].used = [false,true,true]
 if id == 23: g.heroes[0].used[2] = true
 if id == 26: g.heroes[0].results[1] = 0; g.heroes[0].rolls[1] = 3
 if id == 32: g.heroes[0].results[1] = 4; g.heroes[0].rolls[1] = 1
 if id == 46: g.heroes[0].hp = mini(g.v("lab.defy_hp"),g.heroes[0].max_hp)
 if id == 48: g.heroes[0].taken = g.v("lab.echo_taken"); g.heroes[0].echo_due = true
 if Catalog.is_reaction(id): g.heroes[0].reaction = [0]; g.heroes[0].used[0] = true
 g.on_roll(g.heroes[0],0)
 g.event_log.clear(); g.log_lines.clear(); g.event_id = 0
 g.record_event("turn","ABILITY LAB: " + Battle.FACES[id] + ". Vesper is active. This is an isolated test; normal builds are preserved.",0)
 g.record_event("info",guide(id),0)
 g.record_event("info",Catalog.text(id) if id >= 9 else "Select Die I, then use its highlighted board target or Resolve button. Invalid targets do not spend the die.",0)
 g.record_event("info","Tuned rules: a positive Numeric Attack gets +1 damage; Short Shot is still capped at 1. Numeric 0/1 selector supplies the next roll only. Reset to repeat.",0)
 return g

static func guide(id: int) -> String:
 if Catalog.is_reaction(id): return "Stored reaction: press Boss hits. Respond in the window; compare HP / Block and the log. Reset to repeat."
 if id in [0,56]: return "This face is intentionally inert. Blank is not a failure; Red Tile is also locked against rerolls."
 if id in [2,3,53,54,57]: return "Select Die I, then a highlighted empty cell." + (" Bone may also Resolve to stay and gain Block." if id == 54 else "")
 if id in [1,34,35,36,37,38,39,40,41]: return "Select Die I, then click the boss. Try force 0 / 1 and reset. Cleave has no second enemy in this encounter."
 if id == 58: return "Select Die I and click a standing ally within 3. Positions swap; both gain 1 Block. Dead / Downed allies are ineligible."
 if id in [7,12,15,19,55]: return "Select Die I, then an injured ally. First Aid / Recovery may target self. Blessing then asks for a Blank slot."
 if id == 8: return "Select Die I, click the adjacent ally, then pick a legal push direction beneath the action panel."
 if id == 6: return "Select Focus (Die I), then click Die II to reroll it. The new face must resolve next."
 if id in [11,16,23,26,30,32]: return "Select Die I and Resolve. Follow the face-choice window, then resolve the forced face. Other dice supply valid sources."
 if id in [25,31,49]: return "Resolve Die I, then Next turn to test maintain / release. Boss hits tests damage breaking a Channel."
 if id == 13: return "When-rolled ability: the log explains the full reroll bank. Spend a reroll; reset starts a fresh test."
 if id == 24: return "Resolve Die I: it contains Strike / Numeric Strike and attacks random adjacent units twice, including allies."
 if id == 18: return "Resolve Die I and bind a boss face. Next turn advances a round to test whether that face is suppressed."
 if id in [9,10,14,17,20,21,27,29]: return "Resolve Die I, then use Numeric Strike (Die II) on the boss. Next turn tests duration and Debt repayment."
 if id == 22: return "Other non-Blank dice are already spent. Resolve Die I; boss loses 1 unavoidable HP."
 return "Select Die I and Resolve. Compare Block / statuses with the log. Boss hits tests defenses; Next turn tests expiry."

static func attack(g, id: int) -> void:
 if not g.pending.is_empty() or g.outcome != "": return
 var victim := 0
 if id in [44,45]:
  g.heroes[2].pos = Vector2i(6,5); g.heroes[1].pos = Vector2i(5,4); victim = 1
 if id == 28: g.heroes[2].pos = Vector2i(6,5); g.heroes[1].pos = Vector2i(5,4)
 g.begin_action(3,"Lab Strike")
 g.last_action = "Lab Strike"; g.last_targets = [victim]
 g.pending = {"kind":"attack","action":"Strike","victims":[victim],"reacted":[],"amount":g.v("boss.Strike.damage")}
 g.continue_attack(); g.report_changes()

static func next_turn(g, forced_numeric: int = -1) -> void:
 if not g.pending.is_empty() or g.outcome != "": return
 # Complete a real round, without automatic boss actions, then use normal activation timing.
 g.record_event("turn","Lab advances to Vesper's next turn; boss actions are manual via Boss hits.",0)
 g.finish_turn()
 if g.outcome != "": return
 g.cursor = 0
 g.new_round()
 if g.pending.is_empty() and g.active != 0:
  g.active = 0; g.cursor = 0; g.activate()
 g.heroes[0].stored_num = forced_numeric

static func roll_test_face(g, id: int, forced_numeric: int = -1) -> void:
 if not g.pending.is_empty() or g.outcome != "": return
 var h: Dictionary = g.heroes[0]
 if not h.channel.is_empty() and h.channel.die == 0:
  g.record_event("info","Lab: end the Channel before rolling its held die again.",0); return
 var side: int = h.build[0].find(id)
 if side < 0 or h.hp <= 0 or h.dead:
  g.record_event("info","Lab: that face was mutated away or Vesper is Downed. Reset test to restore the fixture.",0); return
 g.active = 0; g.cursor = g.order.find(0); g.forced_die = -1
 h.rolls[0] = side; h.results[0] = id; h.used[0] = Catalog.is_reaction(id); h.opening = true
 h.stored_num = forced_numeric
 h.reaction.erase(0)
 if Catalog.is_reaction(id): h.reaction.append(0)
 g.record_event("roll","LAB OVERRIDE: roll " + Battle.FACES[id] + " again while keeping current statuses. Normal turn / roll timing is bypassed for testing.",0)
 g.on_roll(h,0);g.roll_serial += 1;g.present_action_roll(0,[0],"Lab · chosen face roll")
