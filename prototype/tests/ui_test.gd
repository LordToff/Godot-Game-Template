extends SceneTree
var errors := 0
var checks := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok: errors += 1; printerr("UI FAIL: ",what)
func _initialize(): call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4): await process_frame
 var app = current_scene
 check(app.page == "forge","starts in forge")
 check(app.draft_modal and app.offers.size() == 3,"bonus picker opens for all heroes")
 check(app.offers.all(func(pool):return pool.size() == 47 and pool.all(func(id):return id in app.Catalog.extended_ids())),"full extended pool excludes starter and generated faces")
 app.choose_gift(1)
 check(app.gifts[0].is_empty(),"starter faces cannot be selected")
 for i in range(3):
  app.build_hero = i;app.choose_gift(19);app.choose_gift(37);app.confirm_gifts()
 check(not app.draft_modal and app.gifts.all(func(ids):return ids.size() == 2),"each hero confirms two distinct extended faces")
 check(app.builds.all(func(build):return app.Model.validate(build,[19,37]) == ""),"two-face bonuses automatically produce legal loadouts")
 check(app.page == "setup","completed choices open pre-fight rule review")
 app.page = "forge";app.build_hero = 0;app.rebuild()
 var options: Array = app.ui.get_children().filter(func(c):return c is OptionButton)
 check(options.size() == 18,"forge has all 18 editable sides")
 options[0].item_selected.emit(8)
 check(app.builds[0][0][0] == 8,"builder responds to input")
 app.builds[0] = app.Model.default_build()
 app.begin()
 check(app.page == "battle" and app.game.round_no == 1,"begin rolls encounter")
 check(app.rolling_time == 0 and not app.dice_tray.busy,"shared roll resolves instantly")
 app.game.pending = {}; app.game.active = 0
 app.game.heroes[0].results = [2,4,1]; app.game.heroes[0].used = [false,false,false]
 app.rolling_time = 0; app.rebuild(); app.select_combat_die(0)
 var target: Vector2i = app.game.heroes[0].pos + Vector2i.UP
 var event := InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.pressed = true
 event.position = app.ORIGIN+Vector2(target)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(event)
 check(app.game.heroes[0].pos == target and app.game.heroes[0].used[0],"board click resolves movement")
 app.game.heroes[0].opening = true;app.game.heroes[0].rerolls = 1
 app.game.heroes[0].used[0] = false;app.selected = 0;app.rebuild()
 var reroll_buttons: Array = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Reroll selected"))
 check(reroll_buttons.size() == 1 and not reroll_buttons[0].disabled,"starting reroll control available in opening")
 reroll_buttons[0].pressed.emit()
 check(app.game.heroes[0].rerolls == 0 and app.rolling_time == 0,"reroll spends charge without delaying input")
 app.rolling_time = 0;app.rebuild()
 app.game.heroes[0].used[1] = false;app.game.heroes[0].results[1] = 4
 app.game.hero_action(1);app.rebuild()
 check(app.effects.any(func(fx):return fx.kind == "block"),"Block action creates shield animation")
 app.game.heroes[0].used[2] = false;app.game.heroes[0].results[2] = 47
 app.game.hero_action(2);app.rebuild()
 check(app.effects.any(func(fx):return fx.kind == "buff"),"buff action creates green animation")
 check(app.effects.any(func(fx):return fx.kind == "debuff"),"debuff creates purple animation")
 app.game.pending = {"kind":"reaction","hero":0,"action":"Strike","victims":[0],"reacted":[],"amount":2}
 app.game.heroes[0].results[1] = 5;app.game.heroes[0].reaction = [1]; app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Block + stay"),"Reaction choices displayed")
 app.game.pending = {"kind":"fracture","hero":1}; app.rebuild()
 check(app.ui.get_children().filter(func(c):return c is Button).size() >= 18,"Fracture face picker displayed")
 app.game.pending = {}; app.show_help = true; app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Return to the game"),"rules overlay can close")
 app.show_help = false; app.rebuild(); app.open_settings()
 check(app.show_options,"game options opens before audio/display settings")
 app.open_audio_settings()
 for i in range(5): await process_frame
 check(get_nodes_in_group("ash_settings").any(func(c):return c.packed_scene != null and c.visible),"template settings window instantiated")
 for settings in get_nodes_in_group("ash_settings"): settings.close()
 for i in range(5): await process_frame
 # Reload through Maaack's Scene Loader; verifies the plugin integration and data handoff.
 app.game.damage(3,app.game.boss.hp)
 app.rebuild()
 check(app.ui.get_children().any(func(c):return c is Button and c.text == "Rematch with reward Soul"),"victory offers Soul reward")
 app.retry(true)
 for i in range(90): await process_frame
 check(current_scene != app and current_scene.page == "battle","Scene Loader restarts playable encounter")
 check(current_scene.reward_soul and current_scene.game.reward,"reward Soul survives Scene Loader restart")
 check(current_scene.gifts == app.gifts if is_instance_valid(app) else current_scene.gifts.all(func(ids):return ids.size() == 2),"starter gifts survive Scene Loader restart")
 current_scene.queue_free()
 for i in range(3): await process_frame
 print("UI INTEGRATION: %d checks, %d failures" % [checks,errors])
 quit(1 if errors else 0)
