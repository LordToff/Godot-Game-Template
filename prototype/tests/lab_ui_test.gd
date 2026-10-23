extends SceneTree
var errors := 0
var checks := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok: errors += 1; printerr("LAB UI FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 var launch = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Try abilities"))
 check(launch.size() == 1,"tutorial accessible before face drafting")
 launch[0].pressed.emit()
 check(app.lab and app.page == "battle" and not app.draft_modal,"tutorial enters playable arena")
 var loadouts: Array = app.builds.duplicate(true)
 var chronicle = app.ui.get_node("SideChronicle")
 check(chronicle.position.x >= 1000 and chronicle.size.y >= 500,"large persistent log on right")
 check(chronicle.text.contains("ABILITY LAB") and chronicle.text.contains("isolated test"),"full log includes instructions and context")
 check(app.ui.get_children().any(func(c):return c is Label and "VESPER’S TURN" in c.text and c.get_theme_font_size("font_size") >= 20),"large active turn label")
 var picker = app.ui.get_node("LabAbilities")
 check(picker.item_count == 59,"all hero, generated and penalty faces selectable")
 picker.item_selected.emit(33)
 check(app.lab_face == 33 and app.game.face(0,0) == 33,"ability selector resets fixture")
 app.game.hero_action(0);app.rebuild()
 check(app.game.pending.get("kind","") == "slot","mutation opens an exact slot picker")
 var slots = app.ui.get_children().filter(func(c):return c is Button and "· Blank" in c.text and not c.disabled)
 check(slots.size() > 0,"eligible mutation slots enabled")
 slots[-1].pressed.emit()
 check(app.game.heroes[0].build[2][5] == 54 and app.game.pending.is_empty(),"slot button installs Bone at clicked location")
 app.lab_face = 26; app.reset_lab();app.game.hero_action(0);app.game.catalog_pick(0,1);app.rebuild()
 var conversion = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("2 · Reaction"))
 check(conversion.size() == 1 and not conversion[0].disabled,"conversion allows explicit reaction choice")
 conversion[0].pressed.emit()
 check(1 in app.game.heroes[0].reaction,"chosen reaction stored by UI path")
 app.lab_face = 5;app.reset_lab()
 var hits = app.ui.get_children().filter(func(c):return c is Button and c.text == "Boss hits")
 hits[0].pressed.emit()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Block + stay"),"lab boss hit opens real reaction controls")
 app.game.react(true);app.rebuild()
 app.show_changes = true;app.rebuild()
 check(app.ui.get_node("ChangeLog").text.contains("Why") or app.ui.get_node("ChangeLog").text.contains("Previously"),"in-game changelog explains reasons")
 app.show_changes = false;app.lab_face = 2;app.reset_lab()
 app.game.heroes[0].pos += Vector2i.DOWN;app._process(0.1)
 var pos: Vector2 = app.visual_positions[0]
 check(pos.y > 4 and pos.y < 5,"movement interpolates through intermediate position")
 app._process(0.4)
 check(app.visual_positions[0] == Vector2(4,5),"movement settles exactly at destination")
 check(app.builds == loadouts,"lab preserves normal loadouts")
 app.game.damage(3,100);app.rebuild()
 var reset = app.ui.get_children().filter(func(c):return c is Button and c.text == "Reset this test")
 check(reset.size() == 1 and not app.ui.get_children().any(func(c):return c is Button and c.text == "Rematch with reward Soul"),"Lab outcome offers reset without granting normal rewards")
 reset[0].pressed.emit()
 check(app.lab and app.game.outcome == "" and not app.reward_soul,"outcome reset restores isolated Lab")
 app.show_changes = false;app.rebuild()
 for i in range(8):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v4-lab.png")
 print("LAB UI: %d checks, %d failures" % [checks,errors])
 current_scene.queue_free()
 for i in range(3):await process_frame
 quit(1 if errors else 0)
