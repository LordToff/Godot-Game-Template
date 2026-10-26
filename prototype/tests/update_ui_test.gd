extends SceneTree
var checks := 0
var errors := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:errors += 1;printerr("UPDATE UI FAIL: ",what)
func find_button(app, title: String):
 var found: Array = app.ui.get_children().filter(func(c):return c is Button and c.text == title)
 return found[0] if not found.is_empty() else null
func capture(name: String):
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v5-"+name+".png")
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 app.start_lab()
 check(find_button(app,"View dice") != null,"dice viewer available from battle")
 app.game.mutate(0,2,5,54)
 find_button(app,"View dice").pressed.emit()
 check(app.show_dice,"dice viewer opens")
 var changed: Array = app.ui.get_children().filter(func(c):return c is Button and "Bone" in c.text and "was Blank" in c.text)
 check(changed.size() == 1,"mutated Bone shows original Blank")
 check(app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("SIDE ")).size() == 18,"all 18 installed faces assigned to three dice")
 changed[0].pressed.emit()
 check(app.dice_inspected == Vector2i(2,5),"face inspection identifies die and side")
 check(app.ui.get_children().any(func(c):return c is RichTextLabel and "Bone" in c.text and "Recorded roll:" in c.text),"details distinguish installed effect and earlier result")
 await capture("dice")
 find_button(app,"THE HOLLOW").pressed.emit()
 check(app.dice_hero == 3 and app.ui.get_children().any(func(c):return c is Button and "Cinder Brand" in c.text),"boss inventory shows new boss faces")
 find_button(app,"Back to game").pressed.emit()
 find_button(app,"Menu").pressed.emit()
 find_button(app,"What changed").pressed.emit()
 check(app.show_changes and app.changes_page == 0,"patch notes start on overview")
 check(find_button(app,"← Previous").disabled,"first page disables Previous")
 find_button(app,"Dice & turn flow").pressed.emit()
 check(app.ui.get_node("ChangeLog").text.contains("Two Blanks"),"topic navigation opens rules")
 find_button(app,"Boss changes").pressed.emit()
 check(app.ui.get_node("ChangeLog").text.contains("Cinder Brand"),"topic buttons jump directly to boss notes")
 await capture("changes")
 find_button(app,"Fixes & previous").pressed.emit()
 check(find_button(app,"Next →").disabled,"last page disables Next")
 find_button(app,"Back to game").pressed.emit()
 find_button(app,"Turn help").pressed.emit()
 check(app.show_turn and app.ui.get_node("TurnGuide").text.contains("Reroll window"),"turn guide shows current window and charges")
 await capture("turn-guide")
 var escape := InputEventKey.new();escape.keycode = KEY_ESCAPE;escape.pressed = true
 app._unhandled_key_input(escape)
 check(not app.show_turn,"Escape closes turn guide")
 app.lab_face = 57;app.reset_lab();app.selected = 0;app.rebuild()
 var event := InputEventMouseButton.new();event.button_index = MOUSE_BUTTON_LEFT;event.pressed = true
 event.position = app.ORIGIN+Vector2(3,5)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
 check(app.game.heroes[0].pos == Vector2i(3,5) and app.game.heroes[0].block == 1,"Ashstep resolves through board input")
 app.lab_face = 58;app.reset_lab();app.selected = 0;app.rebuild()
 event.position = app.ORIGIN+Vector2(app.game.heroes[1].pos)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
 check(app.game.heroes[0].pos == Vector2i(3,4) and app.game.heroes[1].pos == Vector2i(4,4),"Exchange targets an ally through board input")
 app.game.active = 3;app.game.pending = {};app.game.boss_rolls = ["Cinder Brand","Ashen Chain","Grave Tithe"];app.game.boss_index = 0;app.game.boss_step();app.rebuild()
 check(not app.game.brand_cells.is_empty(),"boss Brand creates board hazard")
 var brand = app.ui.get_children().filter(func(c):return c is Button and "Cinder Brand" in c.text)[0]
 brand.pressed.emit()
 check(app.ui.get_children().any(func(c):return c is RichTextLabel and c.text.contains("Mark a cross")),"boss intent details explain delayed danger")
 app.inspect_action = "";app.rebuild()
 await capture("boss-brand")
 app.show_dice = true;app.dice_hero = 0;app.rebuild()
 var saved: Vector2i = app.game.heroes[0].pos
 app._gui_input(event)
 check(app.game.heroes[0].pos == saved,"reference overlay blocks battle clicks")
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("V0.5 UI: %d checks, %d failures" % [checks,errors])
 quit(1 if errors else 0)
