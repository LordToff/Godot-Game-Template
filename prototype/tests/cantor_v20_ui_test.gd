extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V20 UI FAIL: ",why)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v20-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.balance_values = {};app.balanced = true
 for hero in range(3):app.gifts[hero] = [19,37];app.builds[hero] = app.Model.bonus_build(app.gifts[hero])
 app.build_hero = 2;app.confirm_gifts()
 check(app.page == "setup" and app.ui.has_node("EncounterCantor"),"third boss is optional on real pre-fight review")
 check(app.ui.has_node("EncounterHollow") and app.ui.has_node("EncounterNugh"),"existing bosses remain selectable")
 app.ui.get_node("EncounterCantor").pressed.emit()
 check(app.encounter == "cantor" and app.game.heroes.is_empty(),"selecting third boss does not start combat")
 await capture("three-boss-review")
 var saved: Array = app.builds.duplicate(true)
 app.ui.get_node("SetupSoul1").pressed.emit();app.ui.get_node("StartEncounter").pressed.emit()
 check(app.game.encounter_id == "cantor" and app.game.boss.hp == 14 and app.builds == saved,"entry uses Cantor and preserves exact build / rules")
 var g = app.game;g.active = 0;g.cursor = g.order.find(0);g.pending = {};app.inspect_actor = 0
 for h in g.heroes:h.reaction.clear();h.used = [false,false,false]
 g.heroes[0].pos = Vector2i(2,3);g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8);g.heroes[0].results = [1,4,7]
 app.visual_positions.clear();app.snapshots.clear();app.rebuild()
 check(app.ui.get_node("ResonanceStatus").text.contains("0/6"),"shared Resonance meter is visible")
 app.ui.get_node("BattleDie0").pressed.emit()
 var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = app.ORIGIN+Vector2(g.boss.pos)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(click)
 check(g.resonance == 1 and app.ui.get_node("ResonanceStatus").text.contains("1/6"),"real Attack click updates shared meter")
 app.ui.get_node("BattleDie1").pressed.emit()
 var resolve = app.ui.get_children().filter(func(c):return c is Button and c.text == "Resolve selected face")
 check(resolve.size() == 1,"Defense can resolve through ordinary button")
 if not resolve.is_empty():resolve[0].pressed.emit()
 check(g.resonance == 0,"ordinary Defense button calms meter")
 app.combat_inspected = -1;app.selected = -1;app.inspect_action = "";app.rebuild();await capture("cantor-battle")
 g.active = 3;g.boss_index = 0;g.boss_rolls = ["Crescendo","Toll of Reckoning","Hushed Chime"];g.boss_step();app.rebuild()
 check(app.ui.get_node("ResonanceStatus").text.contains("OPEN +1"),"open core shows its exact bonus")
 await capture("open-core")
 g.pending = {};g.boss_index = 1;g.resonance = 6;g.heroes[0].block = 0;g.heroes[0].results[0] = 5;g.heroes[0].reaction = [0];g.heroes[0].used[0] = true
 g.boss_step();app.rebuild()
 check(g.pending.get("kind","") == "reaction","Toll opens real Reaction window")
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Gain 2 Block"),"basic Reaction offers only Block")
 check(not app.ui.get_children().any(func(c):return c is Button and (c.text.begins_with("Block + ") or c.text.begins_with("Step "))),"no movement buttons for basic Reaction")
 var before: Vector2i = g.heroes[0].pos
 app.ui.get_children().filter(func(c):return c is Button and c.text == "Gain 2 Block")[0].pressed.emit()
 check(g.heroes[0].pos == before and g.heroes[0].hp == 4,"actual Reaction button blocks two and never moves")
 await capture("reaction-block-only")
 app.inspect_action = "";g.pending = {};g.damage(3,7);app.rebuild()
 check(g.phase_two and app.inspect_action == "__phase__","Cantor uses actual half-HP phase transition")
 check(app.ui.get_node("BossActionDetails").text.contains("Toll of Reckoning") and not app.ui.get_node("BossActionDetails").text.contains("Cinder Brand"),"own six-ability upgrade guide")
 await capture("grand-peal")
 app.inspect_action = "";app.show_dice = true;app.dice_hero = 3;app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text.contains("VEYL")),"View dice uses new boss name")
 check(app.ui.get_node("ViewDie0Side0").text.contains("Gathering Note"),"View dice uses Cantor faces")
 app.show_dice = false;app.inspect_action = "";app.rebuild()
 var arena := Rect2(app.ORIGIN,Vector2.ONE*app.CELL*9)
 check(app.ui.get_children().filter(func(c):return c is BaseButton).all(func(c):return not arena.intersects(c.get_rect()) and Rect2(0,0,1440,900).encloses(c.get_rect())),"third-boss controls fit without covering battlefield")
 print("V0.20 CANTOR UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
