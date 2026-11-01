extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("WORM PATH UI FAIL: ",why)
func _initialize():call_deferred("run")
func click_tile(app, cell: Vector2i):
 var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true
 click.position = app.ORIGIN+Vector2(cell)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(click)
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.lab_face = 59;app.start_lab()
 app.select_combat_die(0);click_tile(app,Vector2i(4,5))
 var g = app.game;var id: int = g.owned_worm(0)
 check(id >= 4 and g.unit_data(id).pos == Vector2i(4,5),"real click creates the blocked-behind-owner fixture")
 for i in range(3):await process_frame
 var end = app.ui.get_children().filter(func(n):return n is Button and n.text.begins_with("End hero turn"))
 check(end.size() == 1,"normal owner-end button exists")
 end[0].pressed.emit()
 check(g.active == 1 and g.unit_data(id).pos == Vector2i(6,5),"real owner-end button activates and detours the worm")
 for i in range(50):await process_frame
 check(app.visual_positions[id].is_equal_approx(Vector2(6,5)),"worm sprite finishes moving to the model's new tile")
 check(g.event_log.any(func(e):return e.kind == "move" and e.source == id and e.text.contains("detours")),"movement appears in the chronicle")
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v221-worm-after-owner-turn.png")
 print("V0.22.1 WORM PATH UI: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
