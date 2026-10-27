extends RefCounted
const Battle = preload("res://prototype/battle.gd")
const Catalog = preload("res://prototype/catalog.gd")

static func score(build: Array) -> int:
 var result := 0
 var weights := {1:6,2:3,3:5,4:4,5:4,6:2,7:12,8:2}
 for die in build:
  for face in die:result += int(weights.get(face,0))
 return result

static func trial(build: Array, gifts: Array, profile: Dictionary, die: int, side: int, data: Variant) -> Dictionary:
 if not data is Dictionary or data.get("kind","") != "ash_face":return {"error":"Drag an ability card or an installed face."}
 if die not in range(3) or side not in range(6):return {"error":"Choose a square on one of the three dice."}
 var face: int = int(data.get("face",-1))
 if face not in range(59):return {"error":"Unknown face."}
 var next: Array = build.duplicate(true);var owned: Array = gifts.duplicate();var note := ""
 var source_die: int = int(data.get("from_die",-1));var source_side: int = int(data.get("from_side",-1))
 if source_die < 0:
  if face not in Catalog.extended_ids():return {"error":"Choose a bonus face from the full pool."}
  if face in owned:
   for d in range(3):
    for s in range(6):
     if next[d][s] == face and source_die < 0:source_die = d;source_side = s
  elif owned.size() >= 2:
   var replaced: int = next[die][side]
   var copies := 0
   for installed in next:copies += installed.count(replaced)
   if replaced not in owned or copies != 1:return {"error":"Two designs selected. Drop onto one of those bonus faces to replace it, or remove a choice."}
   owned.erase(replaced);owned.append(face)
  else:owned.append(face)
 if source_die >= 0:
  if source_die not in range(3) or source_side not in range(6) or next[source_die][source_side] != face:return {"error":"That source face has changed. Drag it again."}
  next[source_die][source_side] = next[die][side]
 next[die][side] = face
 var error := Battle.validate(next,owned,profile)
 # Dropping a new design on a required Blank keeps the requested square and frees a starter on the same die.
 if error.begins_with("Every six-sided die") and source_die < 0 and build[die][side] == 0:
  var best: Array = [];var best_score := -1
  for slot in range(6):
   var removed: int = next[die][slot]
   if slot == side or removed <= 0 or removed > 8:continue
   var candidate: Array = next.duplicate(true);candidate[die][slot] = 0
   if Battle.validate(candidate,owned,profile) == "" and score(candidate) > best_score:
    best = candidate;best_score = score(candidate);note = "Replaced %s on Die %s to keep %d Blanks." % [Battle.FACES[removed],["I","II","III"][die],Battle.Balance.value(profile,"body.blanks")]
  if not best.is_empty():next = best;error = ""
 if error == "" and not owned.all(func(id):return next.any(func(installed):return id in installed)):error = "Keep both selected bonus designs equipped. Replace a starter square instead."
 if error != "":return {"error":error+" Try replacing a face of the same type."}
 return {"error":"","build":next,"gifts":owned,"note":note,"score":score(next)}

static func best_drop(build: Array, gifts: Array, profile: Dictionary, die: int, data: Variant) -> Dictionary:
 var best := {"error":"No legal space on that die. Try another die or replace a face of the same type."};var best_score := -1
 for side in range(6):
  var result := trial(build,gifts,profile,die,side,data)
  if result.error == "" and result.score > best_score:best = result;best_score = result.score;best["side"] = side
 return best

static func quick_equip(build: Array, gifts: Array, profile: Dictionary, face: int) -> Dictionary:
 var best := {"error":"No legal space under these body / copy limits. Try a different design or edit the balance profile."};var best_score := -1
 for die in range(3):
  var result := best_drop(build,gifts,profile,die,{"kind":"ash_face","face":face})
  if result.error == "" and result.score > best_score:best = result;best_score = result.score
 return best
