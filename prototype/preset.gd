extends RefCounted
const Battle = preload("res://prototype/battle.gd")
const Catalog = preload("res://prototype/catalog.gd")

static func decode(text: String, profile: Dictionary = {}) -> Dictionary:
 var parser := JSON.new()
 if parser.parse(text) != OK:return {"error":"Preset contains invalid JSON; the current loadout was not changed."}
 var saved = parser.data
 if not saved is Dictionary:return {"error":"Preset must be a valid JSON object."}
 if not saved.get("builds") is Array or saved.builds.size() != 3 or not saved.get("gifts") is Array or saved.gifts.size() != 3:return {"error":"Preset needs three heroes, each with three dice and two bonus designs."}
 for key in ["balanced","test_soul"]:
  if saved.has(key) and not saved[key] is bool:return {"error":"Preset option '%s' must be true or false." % key}
 var builds: Array = [];var gifts: Array = []
 for hero in range(3):
  if not saved.builds[hero] is Array or not saved.gifts[hero] is Array or saved.gifts[hero].size() != 2:return {"error":"Each hero needs three dice and two bonus designs."}
  var owned: Array = []
  for id in saved.gifts[hero]:
   if not Battle.valid_face_number(id) or int(id) not in Catalog.extended_ids():return {"error":"Bonus designs must be whole numbers from the bonus pool."}
   owned.append(int(id))
  if owned[0] == owned[1]:return {"error":"Each hero must choose two distinct bonus designs."}
  var error := Battle.validate(saved.builds[hero],owned,profile)
  if error != "":return {"error":"Hero %d: %s" % [hero+1,error]}
  var build: Array = []
  for die in saved.builds[hero]:
   var sides: Array = []
   for face in die:sides.append(int(face))
   build.append(sides)
  builds.append(build);gifts.append(owned)
 return {"error":"","builds":builds,"gifts":gifts,"balanced":saved.get("balanced",true),"test_soul":saved.get("test_soul",false)}
