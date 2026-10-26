extends SceneTree
var errors := 0
var checks := 0
func check(ok: bool, text: String):
 checks += 1
 if not ok:errors += 1;printerr("POLISH UI FAIL: ",text)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v8-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 app.start_lab();app.game.present_action_roll(0,[0,1,2],"Recorded hero faces");app.rebuild()
 check(not app.dice_tray.busy and app.rolling_time == 0,"recorded rolls never open an animated tray")
 check(app.dice_tray.get_child_count() == 0,"no hidden 3D viewport or dice meshes")
 check(app.roll_seen == app.game.roll_presentations.size(),"instant results consume presentation records")
 app.lab_face = 49;app.reset_lab();app.game.hero_action(0);app.rebuild();app._process(0.4)
 check(app.channel_glows[0] > 0,"Channel produces persistent aura")
 check(app.ui.get_children().any(func(c):return c is Button and c.text.contains("CHANNEL HELD")),"Channel die is labelled held")
 await capture("channel")
 app.game.damage(0,1);app.rebuild();app._process(0.4)
 check(app.channel_glows[0] == 0,"breaking Channel fades aura")
 app.lab_face = 1;app.reset_lab();app.selected = 0;app.rebuild()
 var event := InputEventMouseButton.new();event.button_index = MOUSE_BUTTON_LEFT;event.pressed = true
 event.position = app.ORIGIN+Vector2(app.game.heroes[1].pos)*app.CELL+Vector2.ONE*app.CELL/2
 var hp: int = app.game.heroes[1].hp
 app._gui_input(event);check(app.game.heroes[1].hp == hp and app.hint.contains("FRIENDLY FIRE"),"friendly attack requires explicit second click")
 app._gui_input(event);check(app.game.heroes[1].hp < hp,"confirmed friendly attack resolves")
 app.lab_support = 27;app.reset_lab();check(app.game.face(0,1) == 27,"Lab combines selected primary and support face")
 app.lab_support = 34;app.start_training()
 for lesson in range(8):
  var g = app.game
  match lesson:
   0:g.hero_action(0,-1,Vector2i(4,5))
   1:g.hero_action(0,3)
   2:g.hero_action(0)
   3:g.hero_action(0,1)
   4:app.Lab.attack(g,5);g.react(true)
   5:g.hero_action(0)
   6:g.hero_action(0,-1,Vector2i(4,5))
   7:g.hero_action(0,-1,Vector2i(3,5))
  check(app.lesson_done(),"lesson completion %d" % lesson)
  app.next_lesson()
 check(not app.training and not app.lab and app.page == "battle","guided practice leads into a legal encounter")
 app.dice_tray.finish()
 var old: String = FileAccess.get_file_as_string("user://ash_build_preset.json") if FileAccess.file_exists("user://ash_build_preset.json") else ""
 app.page = "forge";app.save_preset();var recorded: Array = app.builds.duplicate(true)
 app.builds[0] = app.Model.default_build();app.load_preset()
 check(app.builds == recorded and app.gifts[0].size() == 2,"preset round trip restores all heroes")
 if old != "":
  var file = FileAccess.open("user://ash_build_preset.json",FileAccess.WRITE);file.store_string(old);file.close()
 else:DirAccess.remove_absolute(ProjectSettings.globalize_path("user://ash_build_preset.json"))
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("POLISH UI: %d checks, %d failures" % [checks,errors]);quit(1 if errors else 0)
