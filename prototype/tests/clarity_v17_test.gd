extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("V17 FAIL: ",what)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v17-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.balance_values = {};app.balanced = true;app.lab_face = 6;app.start_lab()
 var g = app.game;var h: Dictionary = g.heroes[0]
 h.build[1] = [1,1,1,1,1,1];h.opening = false
 app.ui.get_node("BattleDie0").pressed.emit()
 check(app.ui.get_node("ActionInstruction").text.contains("FOCUS"),"Focus selection gives an explicit instruction")
 check(app.ui.get_node("BattleDie1").text.contains("FOCUS TARGET"),"legal Focus targets are identified")
 app.ui.get_node("BattleDie1").pressed.emit()
 check(g.forced_die == 1 and h.used[0] and not h.used[1],"Focus spends source and forces new result even after ordinary window closed")
 check(h.rerolls == 1,"Focus does not use a banked charge")
 check(app.selected == 1 and app.combat_inspected == 1,"Focus selects and inspects the NEW result rather than the old face")
 check(app.ui.get_node("BattleDie0").text.contains("SPENT"),"Focus source is visibly spent")
 check(app.ui.get_node("BattleDie0").get_theme_color("font_color") == Color("7d8791"),"spent card is grey rather than retaining its ability color")
 check(app.ui.get_node("BattleDie1").text.contains("RESOLVE NEXT"),"forced die has persistent resolve-next state")
 check(app.ui.get_node("ActionReroll").disabled and app.ui.get_node("ActionReroll").text.contains("PAUSED"),"banked reroll is visibly paused during forced result")
 check(g.event_log.any(func(e):return e.kind == "focus" and e.old_face == 34 and e.new_face == 1),"Focus records exact old and new faces")
 await capture("focus-result")
 app.ui.get_node("BattleDie2").pressed.emit()
 check(app.selected == 1 and not h.used[2],"inspecting another die cannot interrupt the forced result")
 check(g.hero_action(1,3),"new Focus result resolves normally")
 app.selected = -1;app.rebuild()
 check(app.ui.get_node("ActionReroll").disabled and app.ui.get_node("ActionReroll").text.contains("CLOSED") and app.ui.get_node("ActionReroll").text.contains("1 saved"),"closed window clearly distinguishes saved charge from usable reroll")
 check(g.reroll_reason(-1).contains("Opening window closed"),"closed-window reason takes precedence over missing selection")
 await capture("spent-and-closed")
 for f in [9,11,15,56]:
  g = Lab.create(6);g.heroes[0].results[1] = f
  var before: int = g.event_id
  check(not g.hero_action(0,1) and not g.heroes[0].used[0] and g.event_id == before,"Focus rejects a locked / non-rerollable face without spending or false declarations: %d" % f)
  g.heroes[0].results[0] = f
  check(not g.action_reroll(0) and g.reroll_reason(0).contains(g.FACES[f]),"banked reroll names the restricted face: %d" % f)
 app.game = Lab.create(9);app.selected = 0;app.combat_inspected = 9;app.rebuild()
 check(app.ui.get_node("ActionReroll").text.contains("CANNOT REROLL"),"non-rerollable face has a visible explanation")
 check(app.ui.get_node("ActionReroll").tooltip_text.contains("non-rerollable"),"restriction is explained rather than hidden by generic error")
 g = Lab.create(6);g.heroes[0].build[1] = [5,5,5,5,5,5];app.game = g;app.selected = 0;app.rebuild();app.select_combat_die(1)
 check(g.forced_die == -1 and 1 in g.heroes[0].reaction and app.combat_inspected == 5,"Focus rolling a Reaction stores and inspects it correctly")
 app.game = Lab.create(10);app.selected = 0;app.rebuild();app.game.hero_action(0);app.selected = -1;app.rebuild()
 check(app.weak_point_ready(0) and app.ui.get_node("ActiveStatuses").text.contains("Weak Point READY"),"Weak Point activation is persistently named")
 check(app.game.event_log.any(func(e):return e.kind == "buff" and e.text.contains("Weak Point READY")),"activation log uses the actual ability name")
 app.ui.get_node("ActiveStatuses").pressed.emit()
 check(app.ui.get_node("ActiveEffectDetails").text.contains("expires after round"),"effect inspection explains use and expiry")
 await capture("weak-point")
 app.show_active_effects = false;app.game = Lab.create(1);app.seen_event = 0;app.inspect_action = "";app.selected = -1;app.rebuild()
 check(app.ui.get_node("BossPhaseSummary").text.contains("15 HP"),"phase threshold follows actual max HP")
 app.ui.get_node("BossPhaseSummary").pressed.emit()
 check(app.ui.get_node("BossActionDetails").text.contains("3×3") and app.ui.get_node("BossActionDetails").text.contains("Rooted 1") and app.ui.get_node("BossActionDetails").text.contains("Furnace Roar"),"phase page names all three upgrades")
 app.inspect_action = "";app.test_boss_phase_two()
 check(app.game.phase_two and app.inspect_action == "__phase__","crossing half HP opens the explanation automatically")
 await capture("phase-explanation")
 app.inspect_action = "";app.game = Lab.create(1);app.snapshots.clear();app.effects.clear();app.seen_event = app.game.event_id;app.rebuild();app.Lab.attack(app.game,1);app.rebuild()
 check(app.effects.any(func(f):return f.kind == "boss_attack") and app.effects.any(func(f):return f.kind == "impact"),"boss hit has distinct heavy attack and impact effects")
 check(app.impact_time > 0 and app.impact_strength > 0,"boss damage triggers a short arena-only impact")
 check(app.impact_sound.data.size() > 0 and app.shield_sound.data.size() > 0,"distinct impact and shield sounds are generated")
 await create_timer(0.16).timeout;await capture("boss-impact")
 app.combat_effects = false;app.effects.clear();app.impact_time = 0;app.game = Lab.create(1);app.seen_event = app.game.event_id;app.Lab.attack(app.game,1);app.rebuild()
 check(not app.effects.any(func(f):return f.kind == "impact") and app.impact_time == 0,"impact opt-out suppresses recoil and shake")
 app.combat_effects = true;app.game = Lab.create(31);app.inspect_action = "";app.show_active_effects = false;app.selected = -1;app.rebuild()
 for f in range(59):
  app.game.heroes[0].results[0] = f;app.game.heroes[0].used[0] = false;app.combat_inspected = f;app.detailed_ability = false;app.rebuild()
  check(not app.short_face_help(f).is_empty() and not app.ui.get_node("CombatAbilityDetails").text.contains("ACTIVE HERO"),"short description exists without unrelated status dump: %d" % f)
  check(app.ui.get_node("BattleDie0").size.x == 328,"long face names do not expand cards into the log: %d" % f)
 app.game.balance = {"face1.damage":5,"face31.break_block":4,"face57.move":5}
 check(app.short_face_help(1).contains("5 damage") and app.short_face_help(31).contains("4 cumulative Block") and app.short_face_help(57).contains("5 spaces"),"short descriptions show active custom values")
 app.game.heroes[0].results[0] = 31;app.combat_inspected = 31;app.rebuild();await capture("short-description")
 var board := Rect2(app.ORIGIN,Vector2.ONE*app.CELL*9)
 check(app.ui.get_node("CombatAbilityWindow").get_rect().position.x > board.end.x,"ability window stays entirely beside the arena")
 check(app.ui.get_children().filter(func(c):return c is BaseButton).all(func(c):return Rect2(0,0,1440,900).encloses(c.get_rect()) and not board.intersects(c.get_rect())),"combat controls fit viewport and leave board clear")
 check(app.ui.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR and app.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,"UI text and pixel sprites have separate sampling")
 print("V0.17 CLARITY: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
