extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("INTERACTION FAIL: ",what)
func _initialize():call_deferred("run")
func button(app, prefix: String):
 for child in app.ui.get_children():
  if child is Button and child.text.begins_with(prefix):return child
 return null
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v14-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.balance_values = {};app.balanced = true;app.gifts = [[],[],[]];app.builds = [app.Model.default_build(),app.Model.default_build(),app.Model.default_build()];app.rebuild()
 var cards = app.ui.get_node("GiftCards").get_child(0);cards.get_node("Face25").pressed.emit()
 check(app.gifts[0] == [25] and app.builds[0].any(func(d):return 25 in d),"single click selects AND equips first design")
 cards = app.ui.get_node("GiftCards").get_child(0);cards.get_node("Face31").pressed.emit()
 check(app.gifts[0].size() == 2 and app.Model.validate(app.builds[0],app.gifts[0]) == "","second click leaves both designs equipped legally")
 app.gifts[0] = [];app.builds[0] = app.Model.default_build();app.rebuild()
 var data := {"kind":"ash_face","hero":0,"face":34,"from_die":-1,"from_side":-1}
 check(app.face_drop_allowed(0,3,data),"catalog card accepted on exact square")
 app.place_dragged_face(0,3,data);await process_frame
 check(app.builds[0][0][3] == 34 and app.gifts[0] == [34],"real drop handler equips at requested location")
 data = {"kind":"ash_face","hero":0,"face":57,"from_die":-1,"from_side":-1}
 check(app.face_drop_allowed(1,-1,data),"whole die accepts auto-fit drag")
 app.place_dragged_face(1,-1,data);await process_frame
 check(app.gifts[0].size() == 2 and app.builds[0].any(func(d):return 57 in d),"whole-die drop places second design")
 data = {"kind":"ash_face","hero":0,"face":34,"from_die":0,"from_side":3}
 check(app.face_drop_allowed(2,0,data),"installed square can move to another die")
 app.place_dragged_face(2,0,data);await process_frame
 check(app.builds[0][2][0] == 34 and app.builds[0][0][3] == 1,"installed drag swaps source and destination")
 var placed: Array = app.builds[0].duplicate(true)
 await capture("drag-picker")
 app.confirm_gifts()
 check(app.build_hero == 1 and app.builds[0] == placed,"Next hero preserves exact dragged placements")
 check(not app.face_drop_allowed(0,0,data),"another hero cannot accept stale previous-hero drag")
 # A normal encounter, using real turn / shared-roll timing and board input. Boss actions are suppressed for repeatability.
 var blank_build := [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
 app.builds = [blank_build.duplicate(true),blank_build.duplicate(true),blank_build.duplicate(true)];app.gifts = [[],[],[]];app.reward_soul = true;app.begin()
 var g = app.game;g.order = [0,1,2,3];g.initiative_base = g.order.duplicate();g.cursor = 0;g.pending = {};g.activate();app.rebuild()
 var moved := [0,0,0]
 while g.round_no <= 4:
  if g.active == 3:
   g.boss_rolls = ["Bound","Bound","Bound"];app.rebuild();button(app,"Resolve ").pressed.emit();continue
  var id: int = g.active;var h: Dictionary = g.heroes[id]
  if g.round_no == 2:h.soul_move_used = true # legacy marker must not override the fresh numeric allowance
  app.rebuild();button(app,"DIE I ·").pressed.emit()
  check(app.hint.contains("Click a highlighted"),"normal fight turn %d / hero %d offers Blank movement" % [g.round_no,id])
  var to: Vector2i = h.pos+Vector2i.UP if h.pos.y == 7 else h.pos+Vector2i.DOWN
  var event := InputEventMouseButton.new();event.button_index = MOUSE_BUTTON_LEFT;event.pressed = true;event.position = app.ORIGIN+Vector2(to)*app.CELL+Vector2.ONE*app.CELL/2
  app._gui_input(event)
  check(h.pos == to and g.soul_remaining(id) == 0,"normal combat board input spends refreshed conversion")
  moved[id] += 1
  button(app,"DIE II ·").pressed.emit()
  check(app.hint.contains("refreshes"),"second Blank explains when its allowance resets")
  event.position = app.ORIGIN+Vector2(to+Vector2i.LEFT)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(event)
  check(h.pos == to and not h.used[1],"extra attempt cannot move or consume another Blank")
  button(app,"End hero turn").pressed.emit()
 check(moved == [4,4,4],"each hero converts on four full rounds of the same normal combat")
 check(g.event_log.filter(func(e):return e.kind == "soul_refresh").size() >= 12,"each own turn records a refresh")
 app.game = app.Lab.create(1);app.game.reward = true;app.game.heroes[0].rooted = 1;app.game.heroes[0].weak = true;app.game.heroes[1].rooted = 1;app.game.heroes[2].weak = true;app.selected = -1;app.snapshots.clear();app.visual_positions.clear();app.rebuild()
 await capture("debuff-sprites")
 check(app.ui.get_node("ActiveStatuses").text.contains("Rooted") and app.ui.get_node("ActiveStatuses").text.contains("Weakness"),"combined visible status labels match sprite effects")
 app.game.heroes[0].results[0] = 0;app.game.heroes[0].used[0] = false;button(app,"DIE I ·").pressed.emit()
 check(app.hint.contains("ROOTED") and app.game.soul_remaining(0) == 1,"Rooted explains blocked movement without consuming refreshed allowance")
 print("V0.14 INTERACTION: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
