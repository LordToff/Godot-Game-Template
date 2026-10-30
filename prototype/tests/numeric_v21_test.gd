extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V21 NUMERIC FAIL: ",why)
func _initialize():
 var g = Lab.create(17);var h: Dictionary = g.heroes[0];g.roll_presentations.clear()
 check(g.hero_action(0),"Numeric Echo resolves")
 check(g.roll_presentations.size() == 1 and g.roll_presentations[0].kind == "Numeric · Numeric Echo","Numeric Echo has its own Numeric cube presentation")
 var p: Dictionary = g.roll_presentations[0]
 check(h.stored_num == g.ordinary_numeric(p.sides[0]) and p.results[0] == str(h.stored_num),"stored value matches the recorded ordinary side")
 var value: int = h.stored_num;var state: int = g.rng.state
 h.used[0] = false;g.hero_action(0)
 check(g.rng.state == state and g.roll_presentations.size() == 1,"holding an existing stored value does not roll again")
 check(g.numeric(h) == value and g.rng.state == state,"consuming stored value does not consume randomness")
 check(g.roll_presentations.back().kind.contains("Stored") and g.roll_presentations.back().faces[0].all(func(face):return face == str(value)),"stored feedback cannot show a contradictory ordinary face")
 var doubled := 0
 for seed_value in range(1,81):
  g = Lab.create(34);h = g.heroes[0];h.gambler = true;h.numeric_focus = true;g.rng.seed = seed_value;g.roll_presentations.clear()
  var mirror := RandomNumberGenerator.new();mirror.state = g.rng.state
  var side := mirror.randi_range(0,5)
  if side != 5:continue
  doubled += 1
  var base := mirror.randi_range(0,5);var expected: int = g.ordinary_numeric(base,true)
  check(g.numeric(h) == expected*g.v("face9.multiplier"),"Gambler result preserves Numeric Focus rules")
  check(g.rng.state == mirror.state,"Gambler feedback does not change random consumption")
  check(g.roll_presentations.size() == 2 and g.roll_presentations[1].sides == [base] and g.roll_presentations[1].results == [str(expected)],"both Gambler dice show their actual values")
 check(doubled > 0,"seed sample exercises multiplier faces")
 print("V0.21 NUMERIC: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
