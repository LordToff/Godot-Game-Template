extends SceneTree
const P = preload("res://prototype/preset.gd")
const B = preload("res://prototype/battle.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("PRESET FAIL: ",what)
func _initialize():call_deferred("run")
func run():
 var build: Array = B.bonus_build([19,37])
 var good := {"builds":[build,build,build],"gifts":[[19,37],[19,37],[19,37]],"balanced":true,"test_soul":false}
 var result := P.decode(JSON.stringify(good))
 check(result.error == "" and result.builds == good.builds,"valid saved preset round-trips through real JSON")
 if result.error != "":printerr(result.error);quit(1);return
 check(result.builds[0][0][0] is int and result.gifts[0][0] is int,"JSON numeric faces are normalized to integers after validation")
 for flags in [{"balanced":[]},{"test_soul":"yes"}]:
  var bad: Dictionary = good.duplicate(true);bad.merge(flags,true)
  check(P.decode(JSON.stringify(bad)).error != "","malformed option is rejected")
 for face in [1.5,-1,59,"1",[],{}]:
  var bad: Dictionary = good.duplicate(true);bad.builds[0][0][0] = face
  check(P.decode(JSON.stringify(bad)).error != "","invalid face rejected without rounding or crash: "+str(face))
 for gifts in [[19.2,37],["19",37],[[],37],[19,19],[1,37],[56,37]]:
  var bad: Dictionary = good.duplicate(true);bad.gifts[0] = gifts
  check(P.decode(JSON.stringify(bad)).error != "","invalid bonus designs rejected")
 for data in ["not json","[]","null",JSON.stringify({"builds":[],"gifts":[]})]:check(P.decode(data).error != "","bad preset structure gives a message")
 var historical: Dictionary = good.duplicate(true);historical.builds[0] = B.default_build();historical.erase("balanced");historical.erase("test_soul")
 check(P.decode(JSON.stringify(historical)).error == "","legacy legal presets may own optional bonus designs without installing them")
 for malformed in [[],[[0,0,0,0,0,0]],[[0,0,0,0,0,0],[],[]],[[0,0,0,0,0,0],{},[]]]:check(B.validate(malformed) != "","malformed model loadout rejected safely")
 for face in [-1,59,1.5,[],{},"1"]:
  var invalid: Array = B.default_build();invalid[0][0] = face
  check(B.validate(invalid) != "","model rejects invalid face values without indexing")
 print("V0.15 PRESETS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
