extends SceneTree
var errors := 0
func check(ok: bool, what: String):
 if not ok: errors += 1; printerr("UI FAIL: ",what)
func _initialize(): call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4): await process_frame
 var app = current_scene
 check(app.page == "forge","starts in forge")
 var options: Array = app.ui.get_children().filter(func(c):return c is OptionButton)
 check(options.size() == 18,"forge has all 18 editable sides")
 options[0].item_selected.emit(8)
 check(app.builds[0][0][0] == 8,"builder responds to input")
 app.builds[0] = app.Model.default_build()
 app.begin()
 check(app.page == "battle" and app.game.round_no == 1,"begin rolls encounter")
 app.game.pending = {}; app.game.active = 0
 app.game.heroes[0].results = [2,4,1]; app.game.heroes[0].used = [false,false,false]
 app.selected = 0; app.rebuild()
 var target: Vector2i = app.game.heroes[0].pos + Vector2i.UP
 var event := InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
 event.position = app.ORIGIN+Vector2(target)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
 check(app.game.heroes[0].pos == target and app.game.heroes[0].used[0],"board click resolves movement")
 app.game.pending = {"kind":"reaction","hero":0,"action":"Strike","victims":[0],"reacted":[],"amount":2}
 app.game.heroes[0].reaction = [1]; app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Block + stay"),"Reaction choices displayed")
 app.game.pending = {"kind":"fracture","hero":1}; app.rebuild()
 check(app.ui.get_children().filter(func(c):return c is Button).size() >= 18,"Fracture face picker displayed")
 app.game.pending = {}; app.show_help = true; app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Return to the game"),"rules overlay can close")
 app.show_help = false; app.rebuild(); app.open_settings()
 for i in range(5): await process_frame
 check(get_nodes_in_group("ash_settings").any(func(c):return c.packed_scene != null and c.visible),"template settings window instantiated")
 for settings in get_nodes_in_group("ash_settings"): settings.close()
 for i in range(5): await process_frame
 # Reload through Maaack's Scene Loader; verifies the plugin integration and data handoff.
 app.game.damage(3,app.game.boss.hp)
 app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Rematch with reward Soul"),"victory offers Soul reward")
 app.retry(true)
 for i in range(90): await process_frame
 check(current_scene != app and current_scene.page == "battle","Scene Loader restarts playable encounter")
 check(current_scene.reward_soul and current_scene.game.reward,"reward Soul survives Scene Loader restart")
 current_scene.queue_free()
 for i in range(3): await process_frame
 print("UI INTEGRATION: 12 checks, %d failures" % errors)
 quit(1 if errors else 0)
