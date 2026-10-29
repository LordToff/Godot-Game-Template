extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("BUG UI FAIL: ",what)
func _initialize():call_deferred("run")
func find_button(app, prefix: String):
 for child in app.ui.get_children():
  if child is Button and child.text.begins_with(prefix):return child
 return null
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.balance_values = {};app.balanced = true;app.draft_modal = false
 var preset_path := "user://ash_build_preset.json"
 var existed := FileAccess.file_exists(preset_path)
 var backup: PackedByteArray = FileAccess.get_file_as_bytes(preset_path) if existed else PackedByteArray()
 for hero in range(3):app.gifts[hero] = [19,37];app.builds[hero] = app.Model.bonus_build(app.gifts[hero])
 app.build_hero = 0;app.rebuild();find_button(app,"Restore balanced build").pressed.emit()
 check(app.builds[0].any(func(d):return 19 in d) and app.builds[0].any(func(d):return 37 in d),"restore keeps both selected bonus designs installed")
 app.save_preset();var before: Array = app.builds.duplicate(true)
 app.builds[0] = app.Model.default_build();app.load_preset()
 check(app.builds == before and app.hint.contains("Loaded"),"valid JSON preset round-trips through actual save/load controls")
 var good = JSON.parse_string(FileAccess.get_file_as_string(preset_path))
 for invalid in ["not json",JSON.stringify({"builds":[],"gifts":[]})]:
  var file := FileAccess.open(preset_path,FileAccess.WRITE);file.store_string(invalid);file.close();app.load_preset()
  check(app.builds == before and app.hint.to_lower().contains("preset"),"bad preset preserves current team and gives clear feedback")
 var fractional: Dictionary = good.duplicate(true);fractional.builds[0][0][0] = 1.5
 var file := FileAccess.open(preset_path,FileAccess.WRITE);file.store_string(JSON.stringify(fractional));file.close();app.load_preset()
 check(app.builds == before and app.hint.contains("whole"),"fractional face rejected without truncation")
 if existed:file = FileAccess.open(preset_path,FileAccess.WRITE);file.store_buffer(backup);file.close()
 else:DirAccess.remove_absolute(ProjectSettings.globalize_path(preset_path))
 app.start_lab();var h: Dictionary = app.game.heroes[0];h.broken = true;h.hp = 1;app.game.damage(0,1,true);app.rebuild()
 check(app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("DIE ")).all(func(c):return c.disabled),"dead hero dice are disabled")
 check(app.ui.get_children().any(func(c):return c is Label and c.text.contains("hero cannot act")),"incapacitated turn explains how to continue")
 check(not find_button(app,"End hero turn").disabled,"dead actor can still end their turn")
 app.lab_face = 31;app.reset_lab();app.game.hero_action(0);app.game.pending = {"kind":"preroll_stun","hero":0};app.rebuild()
 check(find_button(app,"Die 1").disabled and not find_button(app,"Die 2").disabled,"Stunned cannot offer a channel-held die before shared roll")
 app.game.pending = {};app.open_balance_editor();var editor = app.balance_editor
 editor.open_json();editor.json_text.text = "{bad json"
 for node in editor.json_layer.get_children():
  if node is Button and node.text == "Use this JSON":node.pressed.emit();break
 check(editor.json_error.text.contains("Invalid JSON") and editor.draft.is_empty(),"invalid profile JSON reports location without applying")
 print("V0.15 BUG UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
