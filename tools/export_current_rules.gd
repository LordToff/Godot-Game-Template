extends SceneTree
const B = preload("res://prototype/battle.gd")
const N = preload("res://prototype/nugh.gd")
const C = preload("res://prototype/catalog.gd")
const Copy = preload("res://prototype/ability_copy.gd")
func _initialize():
 var g = B.new();g.start([B.default_build(),B.default_build(),B.default_build()],1)
 var n = N.new();n.start([B.default_build(),B.default_build(),B.default_build()],1)
 var copy = Copy.new()
 var result := {"faces":[],"hollow":[],"nugh":[],"defaults":{},"build":B.default_build(),"dice":g.boss_dice(),"nugh_dice":n.boss_dice(),"original":{}}
 for def in B.Balance.DEFINITIONS:
  result.defaults[def.key] = B.Balance.value({},def.key,true)
  if B.Balance.value({},def.key,false) != result.defaults[def.key]:result.original[def.key] = B.Balance.value({},def.key,false)
 for id in range(59):result.faces.append({"id":id,"name":C.name_for(id),"type":C.classification(id),"description":copy.face(id)})
 for entry in g.phase_upgrades():result.hollow.append({"name":entry[0],"description":g.default_boss_help(entry[0]),"upgrade":entry[1]})
 for entry in n.phase_upgrades():result.nugh.append({"name":entry[0],"description":n.default_boss_help(entry[0]),"upgrade":entry[1]})
 result["original_dice"] = B.BOSS_DICE
 var f = FileAccess.open("/tmp/current-rules-data.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));quit()
