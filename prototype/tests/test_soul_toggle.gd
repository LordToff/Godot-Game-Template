extends SceneTree
var checks := 0
var errors := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:errors += 1;printerr("TOGGLE FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.draft_modal = false;app.rebuild()
 var toggle = app.ui.get_node("TestSoulToggle")
 check(not toggle.button_pressed,"default is off")
 toggle.toggled.emit(true)
 check(app.reward_soul,"forge toggle enables Soul")
 app.begin();app.dice_tray.finish()
 check(app.game.reward,"battle starts with selected Soul")
 app.start_lab();check(app.game.reward and app.ui.get_node("TestSoulToggle").button_pressed,"Lab inherits enabled Soul")
 var h: Dictionary = app.game.heroes[0];h.results[0] = 0;h.used[0] = false
 check(app.game.hero_action(0,-1,Vector2i(4,5)),"test Soul converts Blank")
 app.ui.get_node("TestSoulToggle").toggled.emit(false)
 app.ui.get_node("TestSoulToggle").toggled.emit(true)
 h.results[1] = 0;h.used[1] = false
 check(not app.game.hero_action(1,-1,Vector2i(4,6)) and h.soul_move_used,"off/on cannot bypass once-per-turn limit")
 app.ui.get_node("TestSoulToggle").toggled.emit(false);app.reset_lab()
 check(not app.game.reward,"Lab reset preserves disabled choice")
 app.begin();app.dice_tray.finish();check(not app.game.reward,"next battle honors disabled choice")
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("TEST SOUL TOGGLE: %d checks, %d failures" % [checks,errors]);quit(1 if errors else 0)
