extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V19 UI FAIL: ",why)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 var picture := root.get_texture().get_image();picture.save_png("/workspace/artifacts/v19-"+name+".png");return picture
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.balance_values = {};app.balanced = true
 for hero in range(3):app.gifts[hero] = [19,37];app.builds[hero] = app.Model.bonus_build(app.gifts[hero])
 var saved: Array = app.builds.duplicate(true);app.build_hero = 2;app.confirm_gifts()
 check(app.page == "setup" and app.game.heroes.is_empty(),"last face confirmation opens review before any combat starts")
 check(app.ui.has_node("EncounterNugh") and app.ui.has_node("StartEncounter"),"review presents boss choice and explicit entry")
 check(not app.ui.get_node("StartEncounter").disabled,"legal team can enter")
 await capture("review-rules")
 app.ui.get_node("EncounterNugh").pressed.emit();app.ui.get_node("SetupSoul1").pressed.emit()
 check(app.encounter == "nugh" and app.reward_soul and app.balance_values["soul.move"] == 1,"review changes boss and rules")
 check(app.builds == saved,"review preserves exact chosen faces / placements")
 app.ui.get_node("StartEncounter").pressed.emit()
 check(app.page == "battle" and app.game.encounter_id == "nugh" and app.game.v("soul.move") == 1,"explicit start uses chosen boss and rules")
 var g = app.game
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};app.inspect_actor = 0;app.rebuild()
 check(g.living_minions().size() == 2,"real encounter displays the starting brood")
 check(app.ui.get_node("SideChronicle").position.y == 250 and app.ui.get_node("SideChronicle").size.y >= 570,"log gets more room")
 check(app.ui.get_node("BattleDie0").position.y == app.DIE_Y and app.ui.get_node("BattleDie0").size.y >= 88,"action cards move upward and grow")
 var board := Rect2(app.ORIGIN,Vector2.ONE*app.CELL*9)
 check(app.ui.get_children().filter(func(c):return c is BaseButton).all(func(c):return not board.intersects(c.get_rect()) and Rect2(0,0,1440,900).encloses(c.get_rect())),"all controls fit and leave the arena unobstructed")
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};app.inspect_actor = 0
 for i in range(3):g.heroes[i].used = [false,false,false];g.heroes[i].results = [1,34,4]
 g.heroes[1].pos = Vector2i(0,8);g.heroes[2].pos = Vector2i(8,8)
 var worm: int = g.living_minions()[0];g.heroes[0].pos = g.unit_data(worm).pos+Vector2i.DOWN
 app.visual_positions.clear();app.snapshots.clear();app.rebuild();app.ui.get_node("BattleDie0").pressed.emit()
 var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = app.ORIGIN+Vector2(g.unit_data(worm).pos)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(click)
 check(g.unit_data(worm).dead and g.heroes[0].used[0],"actual board click attacks a worm and spends the hero die")
 app.set_process(false);g.heroes[0].stun = false;g.heroes[1].stun = false;app.rebuild();var before = await capture("nugh-battle")
 g.heroes[0].stun = true;g.heroes[1].stun = true;app.rebuild();var after = await capture("stunned-stars")
 var p0: Vector2 = app.ORIGIN+Vector2(g.heroes[0].pos)*app.CELL+Vector2.ONE*app.CELL/2
 var p1: Vector2 = app.ORIGIN+Vector2(g.heroes[1].pos)*app.CELL+Vector2.ONE*app.CELL/2
 for p in [p0,p1]:
  check(before.get_region(Rect2i(Vector2i(p)-Vector2i(32,42),Vector2i(64,40))).get_data() != after.get_region(Rect2i(Vector2i(p)-Vector2i(32,42),Vector2i(64,40))).get_data(),"Stunned changes sprite area on active AND inactive heroes")
 g.heroes[0].stun = false;g.heroes[1].stun = false;app.rebuild();var cleared = await capture("stun-expired")
 check(before.get_region(Rect2i(Vector2i(p0)-Vector2i(32,42),Vector2i(64,40))).get_data() == cleared.get_region(Rect2i(Vector2i(p0)-Vector2i(32,42),Vector2i(64,40))).get_data(),"Stunned effect disappears when status clears")
 app.set_process(true);g.damage(3,8);app.rebuild()
 check(app.inspect_action == "__phase__" and app.ui.get_node("BossActionDetails").text.contains("Birth Cry") and not app.ui.get_node("BossActionDetails").text.contains("Cinder Brand"),"Nu phase guide shows his own six upgrades")
 await capture("nugh-phase-two")
 app.inspect_action = "";app.combat_inspected = 38;app.rebuild()
 check(app.ui.get_node("CombatAbilityDetails").text.contains("other enemy"),"Cleave explains its now-active secondary target")
 check(app.ui.get_node("CombatAbilityWindow").position.x > board.end.x,"description remains beside arena")
 app.show_dice = true;app.dice_hero = 3;app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "NU’GH"),"View dice uses correct boss identity")
 app.show_dice = false;app.inspect_action = "";app.combat_inspected = -1;app.detailed_ability = false;app.show_active_effects = false
 g.pending = {};g.phase_two = false;g.boss.hp = g.boss.max_hp;g.active = 3;g.boss_index = 0;g.boss_rolls = ["Brood Command","Gnashing Maw","Bound"]
 g.minions.clear();g.spawn_worms(2)
 g.unit_data(4).pos = Vector2i(3,6);g.unit_data(5).pos = Vector2i(5,6)
 g.heroes[0].pos = Vector2i(3,7);g.heroes[1].pos = Vector2i(5,7);g.heroes[2].pos = Vector2i(8,8)
 for h in g.heroes:h.hp = 6;h.reaction.clear();h.used = [false,false,false]
 g.heroes[0].results = [5,1,4];g.heroes[0].reaction = [0];g.heroes[0].used[0] = true
 app.visual_positions.clear();app.snapshots.clear();app.rebuild()
 var resolve: Button = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Resolve I"))[0]
 resolve.pressed.emit()
 check(g.pending.get("source",-1) == 4,"real boss Resolve button begins a worm reaction")
 check(app.ui.get_children().any(func(c):return c is Label and c.text.contains("Screaming Worm 1") and c.text.contains("incoming")),"reaction window names actual worm attacker")
 await capture("worm-reaction")
 g.react(true);app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text.begins_with("Activate next worm")),"command offers explicit next-worm button")
 check(app.ui.get_node("CurrentBossDetails").text.contains("Each living worm"),"boss panel stays on Command while brood resolves")
 var hp: int = g.heroes[1].hp
 app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Activate next worm"))[0].pressed.emit()
 check(g.heroes[1].hp == hp-1,"second command click makes second worm attack")
 await capture("brood-command")
 g.boss_step();app.rebuild();g.boss_step();app.rebuild()
 check(g.last_boss_result.contains("FALLBACK") and app.ui.has_node("BossResolution"),"fallback result is persistently visible")
 g.active = 0;app.rebuild()
 check(app.ui.get_node("BossResolution").text.contains("FALLBACK"),"fallback remains readable during next hero turn")
 await capture("fallback-result")
 app.encounter = "hollow";app.begin();g = app.game;g.active = 0;g.pending = {};g.fire_tiles = [g.heroes[0].pos];app.rebuild()
 check(app.ui.get_node("ActionInstruction").text.contains("FIRE:"),"standing in fire shows explicit end-turn damage warning")
 await capture("hollow-fire-warning")
 print("V0.19 ENCOUNTER UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
