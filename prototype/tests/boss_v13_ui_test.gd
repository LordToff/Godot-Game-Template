extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("BOSS UI FAIL: ",what)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v13-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.balance_values = {};app.balanced = true;app.lab_face = 1;app.start_lab()
 app.game.boss.block = 3;app.rebuild();await capture("boss-phase-I")
 app.show_lab_tools = true;app.rebuild()
 var phase = app.ui.get_children().filter(func(c):return c is Button and c.text == "Test boss phase II")
 check(phase.size() == 1 and not phase[0].disabled,"Lab exposes real half-HP phase test")
 phase[0].pressed.emit()
 check(app.game.phase_two and app.game.boss.hp == 15,"phase test deals actual threshold damage")
 check(app.effects.any(func(f):return f.kind == "phase" and f.life > 0),"phase event creates a timed transition animation")
 check(app.BOSS_PHASE_TWO.get_size() == Vector2(32,32),"phase II uses a separate pixel sprite")
 check(app.ui.get_children().any(func(c):return c is Label and c.text.contains("THE HOLLOW · PHASE II")),"phase II remains identified after animation")
 check(app.ui.get_children().any(func(c):return c is Button and c.text.contains("Furnace Roar")),"unlocked Roar is visible before resolution")
 await capture("boss-phase-transition")
 app.inspect_action = "Ashen Chain";app.rebuild()
 check(app.ui.get_node("BossActionDetails").text.contains("Rooted 1 until the next boss turn"),"phase II boss inspector explains Rooted duration")
 var board := Rect2(app.ORIGIN,Vector2.ONE*app.CELL*9)
 check(app.ui.get_node("CombatAbilityWindow").position.x >= board.end.x,"phase inspector stays beside arena")
 app.inspect_action = "";app.game.heroes[0].rooted = 1;app.game.heroes[0].results[0] = 2;app.selected = 0;app.rebuild()
 check(app.ui.get_node("ActiveStatuses").text.contains("Rooted"),"Rooted appears in active-turn summary")
 var motion := InputEventMouseMotion.new();motion.position = app.ORIGIN+Vector2(app.game.heroes[0].pos)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(motion)
 check(app.tooltip_text.contains("Rooted 1"),"hero hover includes Rooted with duration")
 var before: Vector2i = app.game.heroes[0].pos
 var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = app.ORIGIN+Vector2(before+Vector2i.DOWN)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(click)
 check(app.game.heroes[0].pos == before and app.hint.contains("Rooted prevents"),"clicking movement while Rooted explains the failed action")
 app.game.fire_tiles = [before];app.rebuild();await capture("root-and-fire")
 app.game = Lab.create(5);app.game.heroes[0].rooted = 1;app.game.pending = {"kind":"reaction","action":"Smoking Strike","victims":[0],"hero":0,"victim":0,"die":0,"reacted":[],"amount":1};app.rebuild()
 var directions = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Block + ") and c.text != "Block + stay")
 check(directions.size() == 4 and directions.all(func(c):return c.disabled),"Rooted disables reaction movement choices")
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Block + stay" and not c.disabled),"Rooted still permits blocking in place")
 app.game.pending = {};app.effects.clear();app.game = Lab.create(1);app.game.boss.hp = 15;app.game.phase_two = true;app.selected = -1;app.rebuild();await capture("boss-phase-II")
 print("BOSS V0.13 UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
