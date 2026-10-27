extends SceneTree
const B = preload("res://prototype/battle.gd")
const L = preload("res://prototype/face_loadout.gd")
var checks := 0
var errors := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:errors += 1;printerr("LOADOUT FAIL: ",what)
func _initialize():call_deferred("run")
func run():
 var base: Array = B.default_build()
 for face in B.Catalog.extended_ids():
  var result := L.quick_equip(base,[],{},face)
  check(result.error == "" and face in result.gifts and result.build.any(func(d):return face in d),"one-click equips %s legally" % B.FACES[face])
  var valid := 0
  for die in range(3):
   for side in range(6):
    var drop := L.trial(base,[],{},die,side,{"kind":"ash_face","face":face})
    if drop.error == "":
     valid += 1
     check(drop.build[die][side] == face and B.validate(drop.build,drop.gifts) == "","drop honors square and all build limits")
  check(valid > 0,"each bonus design has valid drop targets")
 var result := L.trial(base,[],{},0,4,{"kind":"ash_face","face":34})
 check(result.error == "" and result.build[0][4] == 34 and result.build[0].count(0) == 2 and result.note != "","new face on minimum Blank frees a starter on same die")
 var original: Array = result.build.duplicate(true)
 var move := L.trial(result.build,result.gifts,{},1,0,{"kind":"ash_face","face":34,"from_die":0,"from_side":4})
 check(move.error == "" and move.build[1][0] == 34 and move.build[0][4] == 1,"dragging installed face swaps rather than duplicates")
 check(result.build == original and base == B.default_build(),"preview and validation never mutate applied loadouts")
 result = L.quick_equip(base,[],{},25);var second := L.quick_equip(result.build,result.gifts,{},31)
 check(second.error == "" and second.gifts.size() == 2 and second.build.any(func(d):return 25 in d) and second.build.any(func(d):return 31 in d) and B.validate(second.build,second.gifts) == "","two Skill choices respect body caps")
 var old_slot := Vector2i(-1,-1)
 for d in range(3):
  for side in range(6):
   if second.build[d][side] == 25:old_slot = Vector2i(d,side)
 var replace := L.trial(second.build,second.gifts,{},old_slot.x,old_slot.y,{"kind":"ash_face","face":27})
 check(replace.error == "" and 25 not in replace.gifts and 27 in replace.gifts,"third catalog design replaces targeted selected design atomically")
 var bad := L.trial(second.build,second.gifts,{},0,5,{"kind":"ash_face","face":49})
 check(bad.error != "" and second.gifts == [25,31],"third design on unrelated square is rejected without losing selections")
 check(L.trial(base,[],{},0,0,{"kind":"ash_face","face":56}).error != "","penalty face cannot be selected from bonus pool")
 check(L.trial(base,[],{},0,0,{"kind":"ash_face","face":34,"from_die":1,"from_side":0}).error != "","stale source payload cannot overwrite a face")
 print("V0.14 LOADOUT: %d checks, %d failures" % [checks,errors]);quit(1 if errors else 0)
