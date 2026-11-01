extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V222 SWEEP UI FAIL: ",why)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.lab_face = 5;app.start_lab();var g = app.game
 g.boss.weak = true;g.boss.weak_amount = 3
 g.pending = {"kind":"attack","source":3,"action":"Smoking Strike","victims":[0],"reacted":[],"amount":4}
 g.continue_attack();app.rebuild()
 check(app.ui.get_children().any(func(n):return n is Label and n.text.contains("1 incoming damage")),"real Reaction preview uses the actual custom Weakness")
 var block = app.ui.get_children().filter(func(n):return n is Button and n.text == "Gain 2 Block")
 check(block.size() == 1,"normal block Reaction remains available")
 if block.size():block[0].pressed.emit()
 check(g.heroes[0].hp == 3 and g.heroes[0].block == 1,"Reaction outcome matches the displayed one incoming damage")
 app.lab_face = 59;app.reset_lab();g = app.game
 var worm: int = g.spawn_friendly(0,Vector2i(4,5));g.unit_data(worm).rooted = 1;g.unit_data(worm).weak = 2;g.unit_data(worm).poison = 1
 app.rebuild()
 var hover := InputEventMouseMotion.new();hover.position = app.ORIGIN+Vector2(4,5)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(hover)
 check(app.tooltip_text.contains("Rooted 1") and app.tooltip_text.contains("next boss turn"),"actual worm hover explains movement lock")
 check(app.tooltip_text.contains("Weakness 2") and app.tooltip_text.contains("Poison 1"),"actual hover includes all summon debuffs")
 for i in range(4):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v222-summon-statuses.png")
 var bug = app.Bugh.new();bug.start([app.Model.default_build(),app.Model.default_build(),app.Model.default_build()],4)
 bug.arm_sweep();bug.action_owner = 0;bug.damage(3,1)
 bug.heroes[0].pos = Vector2i(2,3);bug.heroes[0].block = 1;bug.heroes[0].reaction.clear();bug.active = 3;bug.boss_index = 0;bug.boss_rolls = ["Shield Bash","Bound","Bound"];bug.boss_step()
 bug.damage(3,6,true)
 app.game = bug;app.effects.clear();app.floaters.clear();app.visual_positions.clear();app.snapshots.clear();app.show_history = true;app.log_filter = "Combat";app.rebuild()
 for tag in ["GUARD BREAK","ARMOR","WARNING","PHASE"]:
  check(app.ui.get_node("BattleHistory").text.contains(tag),"Combat history retains "+tag)
 app.log_filter = "Turns";app.rebuild()
 check(not app.ui.get_node("BattleHistory").text.contains("GUARD BREAK"),"Turns filter still excludes combat details")
 print("V0.22.2 BUG SWEEP UI: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
