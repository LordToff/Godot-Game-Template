extends SceneTree
var checks := 0
var errors := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:errors += 1;printerr("SOUL UI FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 app.draft_modal = false;app.reward_soul = true;app.begin();app.rolling_time = 0
 var g = app.game;g.active = 0;g.cursor = g.order.find(0);g.pending = {}
 g.heroes[0].pos = Vector2i(0,7);g.heroes[0].results = [0,0,0];g.heroes[0].used = [false,false,false]
 app.selected = 0;app.rebuild()
 var event := InputEventMouseButton.new();event.button_index = MOUSE_BUTTON_LEFT;event.pressed = true
 event.position = app.ORIGIN+Vector2(0,5)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
 check(g.heroes[0].pos == Vector2i(0,5) and g.heroes[0].soul_move_used,"first Blank converts through board input")
 app.selected = 1;app.rebuild()
 event.position = app.ORIGIN+Vector2(0,4)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
 check(g.heroes[0].pos == Vector2i(0,5) and not g.heroes[0].used[1],"second board conversion blocked")
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Resolve selected face"),"remaining Blank can be spent without movement")
 check(app.face_help(0).contains("ONE") and app.face_help(0).contains("per hero turn"),"face help states the cap")
 app.show_turn = true;app.rebuild()
 check(app.ui.get_node("TurnGuide").text.contains("0/1"),"turn guide shows exhausted Soul allowance")
 app.show_turn = false;g.cursor = g.order.find(0);g.activate();app.rebuild();app.show_turn = true;app.rebuild()
 check(app.ui.get_node("TurnGuide").text.contains("1/1"),"new turn shows refreshed Soul allowance")
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("REWARD SOUL UI: %d checks, %d failures" % [checks,errors])
 quit(1 if errors else 0)
