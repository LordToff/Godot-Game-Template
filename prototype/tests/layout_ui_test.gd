extends SceneTree
var checks := 0
var failures := 0
func _initialize():call_deferred("run")
func check(ok: bool, message: String):
 checks += 1
 if not ok:failures += 1;printerr("LAYOUT FAIL: ",message)
func button(app, text: String):
 for child in app.ui.get_children():
  if child is Button and child.text == text:return child
 return null
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.start_lab()
 var board := Rect2(app.ORIGIN,Vector2.ONE*app.CELL*9)
 check(board.size == Vector2(684,684),"arena is almost twice the old screen area")
 check(app.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,"pixel art uses crisp sampling")
 check(app.BACKDROP.get_size() == Vector2(179,179) and app.PORTRAITS.get_size() == Vector2(32,32),"source art is drawn at pixel resolution")
 for actor in [0,3]:
  app.game.active = actor;app.rebuild()
  var controls = app.ui.get_children().filter(func(c):return c is BaseButton)
  check(controls.all(func(c):return not board.intersects(c.get_rect())),"battle controls leave all 81 cells unobstructed for actor %d" % actor)
  check(controls.all(func(c):return Rect2(0,0,1440,900).encloses(c.get_rect())),"controls fit inside the viewport for actor %d" % actor)
 button(app,"View dice").pressed.emit()
 check(app.dice_hero == 3,"View dice follows the boss during its turn")
 app.show_dice = false;app.rebuild()
 check(not app.ui.has_node("LabAbilities"),"testing picker is tucked away during play")
 app.game.active = 0;app.rebuild();button(app,"Lab tools").pressed.emit()
 check(app.ui.has_node("LabAbilities") and app.ui.get_node("LabAbilities").item_count == 59,"Lab tools retain every test face")
 button(app,"Back to battle").pressed.emit();button(app,"Menu").pressed.emit()
 check(app.show_menu and button(app,"Game options") != null and button(app,"What changed") != null,"secondary commands are available in Menu")
 var position: Vector2i = app.game.heroes[0].pos
 app.selected = 0
 var event := InputEventMouseButton.new();event.button_index = MOUSE_BUTTON_LEFT;event.pressed = true;event.position = app.ORIGIN+Vector2(position+Vector2i.DOWN)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event);check(app.game.heroes[0].pos == position,"Menu blocks accidental board actions")
 button(app,"Return to battle").pressed.emit()
 check(not app.show_menu and app.ui.get_node("SideChronicle").size.y >= 500,"return keeps the full side log")
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v10-battle.png")
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("LAYOUT UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
