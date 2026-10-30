extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V21 UI FAIL: ",why)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 check(app.ui.has_node("GiftCards") and app.ui.has_node("GiftDetail"),"full-pool face picker and readable preview")
 app.preview_gift(34)
 check(app.ui.get_node("GiftPreviewTitle").text.contains(app.Model.FACES[34]),"hover preview updates ability title")
 app.choose_gift(34);app.choose_gift(37)
 check(app.gifts[0] == [34,37] and app.Model.validate(app.builds[0],app.gifts[0]) == "","quick clicks equip legal bonus faces")
 app.choose_gift(34)
 check(app.gifts[0] == [37],"chosen face removes in one click")
 app.start_lab();var g = app.game
 app.show_lab_tools = false;g.pending = {};g.active = 0;g.heroes[0].results = [34,4,7];app.rebuild()
 check(app.inspection_at(Vector2(800,230)) == "hero:0","hover hero die opens ability details")
 check(app.inspection_at(Vector2(400,400)) == "","leaving die restores battlefield/log")
 check(app.inspection_at(Vector2(800,80)) == "boss:0","boss intents support hover")
 check(app.inspection_at(Vector2(800,120)) == "phase","phase guide supports hover")
 check(app.inspection_at(Vector2(800,800)) == "effects","active statuses support hover")
 app.select_combat_die(0)
 check(not app.ui.has_node("CombatAbilityWindow"),"click selection does not leave sticky inspector")
 var original_rng: int = g.rng.state
 g.numeric(g.heroes[0],true);app.rebuild()
 check(app.dice_tray.busy and app.rolling_time > 0,"Numeric rolls start visible dice feedback")
 var after_rng: int = g.rng.state
 app.dice_tray._process(0.5)
 check(g.rng.state == after_rng and original_rng != after_rng,"animation never consumes game randomness")
 app.dice_tray._process(2.0)
 check(not app.dice_tray.busy and app.rolling_time == 0,"roll ends and controls unlock")
 var route: Dictionary = app.movement_track(0,Vector2(1,7),Vector2(3,7))
 check(route.path.size() >= 3 and route.duration >= 0.48,"movement uses tile-by-tile footfall timing")
 for index in range(1,route.path.size()):check(route.path[index].distance_to(route.path[index-1]) == 1,"each movement segment is one orthogonal cell")
 g.heroes[0].poison = 1
 check(g.status_description(0).contains("Poison 1") and g.status_map(0).Poison,"poison is included in hover/effects status")
 print("V0.21 FEEDBACK UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
