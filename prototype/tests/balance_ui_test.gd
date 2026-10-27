extends SceneTree
var checks := 0
var failures := 0
func _initialize():call_deferred("run")
func check(ok: bool, message: String):
 checks += 1
 if not ok:failures += 1;printerr("BALANCE UI FAIL: ",message)
func find_button(node: Node, title: String):
 for child in node.get_children():
  if child is Button and child.text == title:return child
 return null
func find_spin(node: Node, key: String):
 for child in node.get_children():
  if child is SpinBox and child.get_meta("balance_key","") == key:return child
  var found = find_spin(child,key)
  if found:return found
 return null
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v11-"+name+".png")
func run():
 var file_path := "user://ash_balance_profile.json"
 var existed := FileAccess.file_exists(file_path)
 var backup := FileAccess.get_file_as_string(file_path) if existed else ""
 if existed:DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.reward_soul = true;app.lab_face = 0;app.start_lab();app.open_settings()
 var workshop = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Balance workshop"))[0]
 workshop.pressed.emit()
 var editor = app.balance_editor
 check(is_instance_valid(editor) and not app.show_options,"workshop opens from Game Options")
 find_spin(editor,"soul.move").value = 4
 find_spin(editor,"soul.uses").value = 2
 check(editor.draft.get("soul.move",0) == 4 and editor.draft.get("soul.uses",0) == 2,"both Blank movement values edit independently")
 editor.selected_group = "General & passives";editor.fill_rows();find_spin(editor,"hero.hp").value = 10
 editor.query = "damage";editor.fill_groups()
 check(editor.shown_groups.any(func(g):return g.begins_with("Boss · ")),"search finds fields inside boss sections")
 editor.query = "";editor.selected_group = "Soul · Blank movement";editor.fill_groups();editor.fill_rows()
 await capture("balance-editor")
 find_button(editor,"Apply & restart fight / test").pressed.emit()
 check(app.balance_editor == null and app.game.v("soul.move") == 4 and app.game.v("soul.uses") == 2,"Apply restarts Lab with chosen values")
 check(app.game.heroes[0].max_hp == 10 and app.game.balance.get("hero.hp",0) == 10,"new starting-stat limits reach the model")
 check(app.ui.get_children().any(func(c):return c is Button and "Blank → Move 4" in c.text),"combat dice reflect configured Blank movement")
 check(app.game.hero_action(0,-1,Vector2i(4,7)),"larger highlighted movement is actually legal")
 app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Label and "Blank moves 1/2" in c.text),"remaining conversions show the configured cap")
 app.balance_values = {};app.load_balance_profile()
 check(app.balance_values.get("soul.move",0) == 4,"saved profile reloads")
 app.open_balance_editor();editor = app.balance_editor;editor.open_json()
 editor.json_text.text = '{"values":{"hero.hp":-1}}';find_button(editor.json_layer,"Use this JSON").pressed.emit()
 check(editor.json_error.text != "" and editor.draft.get("hero.hp",0) == 10,"invalid JSON values cannot replace the draft")
 editor.json_text.text = '{"values":{}}';find_button(editor.json_layer,"Use this JSON").pressed.emit()
 check(editor.draft.is_empty() and app.balance_values.get("soul.move",0) == 4,"JSON import stays staged until Apply")
 find_button(editor,"Cancel").pressed.emit()
 check(app.balance_values.get("hero.hp",0) == 10,"Cancel preserves applied rules")
 app.open_balance_editor();editor = app.balance_editor
 find_button(editor,"Reset all values").pressed.emit();find_button(editor,"Apply & restart fight / test").pressed.emit()
 check(app.balance_values.is_empty() and app.game.heroes[0].max_hp == 6 and app.game.v("soul.move") == 2,"Reset defaults is complete and restarts the fixture")
 app.open_balance_editor();editor = app.balance_editor;editor.tuned = false
 app.apply_balance_profile({},editor);app.balanced = true;app.load_balance_profile()
 check(not app.balanced,"the base rules preset persists with the balance profile")
 app.balanced = true;app.apply_balance_profile({})
 app.lab_face = 1;app.reset_lab();app.game.active = 3;app.game.boss_rolls = ["Cinder Brand","Brace","Strike"];app.game.boss_step();app.rebuild();app._process(0.1)
 check(not app.game.brand_cells.is_empty() and app.effects.any(func(fx):return fx.kind == "fire_arm"),"boss arming fire reaches the visual layer")
 await capture("boss-fire-armed")
 app.game.detonate_brand();app.rebuild();app._process(0.2)
 check(app.effects.any(func(fx):return fx.kind == "fire" and not fx.tiles.is_empty()),"detonation flare retains its tile snapshot")
 await capture("boss-fire-detonation")
 if existed:
  var file := FileAccess.open(file_path,FileAccess.WRITE);file.store_string(backup);file.close()
 else:DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("BALANCE WORKSHOP UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
