extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("CHOICE LAYOUT FAIL: ",what)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.start_lab()
 for face in [5,11,12,16,18,23,25,26,30,31,32,33,49,52,58]:
  app.show_lab_tools = false;app.inspect_action = "";app.show_active_effects = false;app.combat_inspected = -1;app.selected = -1
  app.game = Lab.create(face)
  if face == 5:Lab.attack(app.game,face)
  elif face in [25,31,49]:app.game.hero_action(0);app.game.pending = {"kind":"channel","hero":0}
  elif face == 58:
   app.game.active = 3;app.game.boss_rolls = ["Fracture","Bound","Bound"];app.game.boss_step()
  else:app.game.hero_action(0,1 if face == 12 else -1)
  if face == 26:app.game.catalog_pick(0,1)
  if app.game.pending.get("kind","") == "catalog_choice":
   app.game.heroes[1].results = [12,25,58];app.game.heroes[2].results = [15,24,41]
  app.seen_event = app.game.event_id;app.rebuild()
  for i in range(3):await process_frame
  var shade := -1
  for index in range(app.ui.get_child_count()):
   var c = app.ui.get_child(index)
   if c is ColorRect and c.size == Vector2(1440,900):shade = index
  check(shade >= 0,"actual pending choice opens modal for %d" % face)
  var buttons: Array = []
  for index in range(shade+1,app.ui.get_child_count()):
   var c = app.ui.get_child(index)
   if c is BaseButton:buttons.append(c)
  check(not buttons.is_empty(),"choice has usable controls for %d" % face)
  for button in buttons:
   check(Rect2(350,222,680,445).encloses(button.get_rect()),"choice stays inside its window: %d / %s" % [face,button.text])
   check(button.get_theme_font_size("font_size") >= 12,"choice text never shrinks below 12: %d" % face)
  for a in range(buttons.size()):
   for b in range(a+1,buttons.size()):check(not buttons[a].get_rect().intersects(buttons[b].get_rect()),"choice buttons do not overlap: %d" % face)
  if face == 16:
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("/workspace/artifacts/v17-choice-grid.png")
 print("V0.17 CHOICE LAYOUT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
