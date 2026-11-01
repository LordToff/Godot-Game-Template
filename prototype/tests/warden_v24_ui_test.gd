extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("WARDEN UI FAIL: ",why)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(4):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v24-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 for hero in range(3):app.gifts[hero] = [42,37];app.builds[hero] = app.Model.bonus_build(app.gifts[hero])
 app.build_hero = 2;app.confirm_gifts()
 check(app.ui.get_node("EncounterBugh").text.contains("Iron Warden"),"selector presents replacement concept")
 app.ui.get_node("EncounterBugh").pressed.emit();app.ui.get_node("StartEncounter").pressed.emit();var g = app.game
 g.pending = {};g.active = 0;g.cursor = g.order.find(0);g.heroes[0].pos = Vector2i(2,3);g.heroes[0].reaction = [];g.heroes[0].used = [false,false,false];g.heroes[0].results = [2,4,1];g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 g.arm_sweep();app.selected = -1;app.rolling_time = 0;app.visual_positions.clear();app.rebuild()
 check(app.ui.get_node("WardenStatus").text.contains("BULWARK"),"closed-guard state is visible")
 check(app.ui.get_node("ActionInstruction").text.contains("SWEEP"),"standing in warning explains escape / defend")
 var motion := InputEventMouseMotion.new();motion.position = app.ORIGIN+Vector2(2,3)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(motion)
 check(app.tooltip_text.contains("CRUSHING SWEEP"),"tile hover explains the fixed danger")
 await capture("warden-warning")
 app.select_combat_die(0)
 var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = app.ORIGIN+Vector2(1,3)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(click)
 check(g.heroes[0].pos == Vector2i(1,3),"real movement click escapes marked zone")
 g.order = [3,0,1,2];g.cursor = 0;g.activate();app.rebuild()
 var resolve = app.ui.get_children().filter(func(c):return c is Button and c.text == "Resolve marked sweep →")
 check(resolve.size() == 1,"impact is an explicit step before the three dice")
 if resolve.size():resolve[0].pressed.emit()
 check(g.guard_broken and app.ui.get_node("WardenStatus").text.contains("COUNTERATTACK"),"evade changes actual boss and UI state")
 await capture("warden-open")
 g.active = 0;g.pending = {};g.damage(3,6,true);g.sweep_tiles.clear();g.arm_sweep();app.rebuild()
 check(g.phase_two and g.sweep_damage == 2,"phase II shows stronger future warning")
 await capture("warden-phase-two")
 print("V0.24 WARDEN UI: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
