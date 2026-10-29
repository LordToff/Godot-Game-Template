extends SceneTree
# Reconstruct exact initial trial loadouts; this does not run or invent battle outcomes.
# Save this output as docs/Trial-reference-v0.16.json before regenerating the report.
const B = preload("res://prototype/battle.gd")
const C = preload("res://prototype/catalog.gd")
func _initialize():
 var teams := {"starting":[[],[],[]],"numeric":[[34,37],[35,39],[36,40]],"support":[[19,43],[42,44],[47,58]],"channel":[[25,37],[31,39],[49,35]],"growth":[[41,33],[12,19],[41,43]]}
 var result := {"teams":{},"faces":[],"random_draws":[]}
 for kit in teams:
  var builds: Array = []
  for pair in teams[kit]:builds.append(B.default_build() if pair.is_empty() else B.bonus_build(pair))
  result.teams[kit] = {"pairs":teams[kit],"builds":builds}
 var ids: Array = C.extended_ids()
 for seed_value in range(1,201):
  var picker := RandomNumberGenerator.new();picker.seed = seed_value*173
  for hero in range(3):
   var first: int = picker.randi_range(0,ids.size()-1)
   var second: int = picker.randi_range(0,ids.size()-2)
   if second >= first:second += 1
   var pair: Array = [ids[first],ids[second]]
   result.random_draws.append({"seed":seed_value,"hero":["Vesper","Rook","Wren"][hero],"pair":pair,"build":B.bonus_build(pair)})
 for id in range(59):
  result.faces.append({"id":id,"name":C.name_for(id),"type":C.category(id),"timing":C.timing(id),"description":C.text(id) if id >= 9 else ""})
 var f := FileAccess.open("/tmp/ash-trial-reference.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));quit()
