extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V22 UI FAIL: ",why)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v22-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(5):await process_frame
 var app = current_scene
 app.preview_gift(59)
 check(app.ui.get_node("GiftPreviewTitle").text.contains("Summon Nu’gh"),"full pool previews new Skill")
 app.choose_gift(59);app.choose_gift(34)
 check(app.gifts[0] == [59,34] and app.Model.validate(app.builds[0],app.gifts[0]) == "","two distinct legal gifts")
 for hero in range(3):app.gifts[hero] = [59,34];app.builds[hero] = app.Model.bonus_build(app.gifts[hero])
 app.build_hero = 2;app.confirm_gifts()
 check(app.page == "setup","review before battle")
 var selectors := ["EncounterHollow","EncounterNugh","EncounterCantor","EncounterBugh"]
 var keys := ["hollow","nugh","cantor","bugh"]
 for i in range(4):
  check(app.ui.has_node(selectors[i]),"selector exists: "+keys[i])
  var card = app.ui.get_node(selectors[i])
  check(card.position.y >= 190 and card.position.y+card.size.y < 730,"selector fits: "+keys[i])
  card.pressed.emit();check(app.encounter == keys[i],"selector chooses: "+keys[i])
  app.ui.get_node("StartEncounter").pressed.emit()
  check(app.page == "battle" and app.game.encounter_id == keys[i],"selector starts correct model: "+keys[i])
  app.page = "setup";app.rebuild()
 app.ui.get_node("EncounterBugh").pressed.emit();await capture("four-selectors")
 app.ui.get_node("StartEncounter").pressed.emit();var g = app.game
 g.active = 0;g.cursor = g.order.find(0);g.pending = {};g.heroes[0].used = [false,false,false];g.heroes[0].results = [59,59,1]
 app.selected = -1;app.rolling_time = 0;app.visual_positions.clear();app.snapshots.clear();app.rebuild()
 app.select_combat_die(0)
 var cell: Vector2i = g.summon_cells(0)[0]
 var click := InputEventMouseButton.new();click.button_index = MOUSE_BUTTON_LEFT;click.pressed = true;click.position = app.ORIGIN+Vector2(cell)*app.CELL+Vector2.ONE*app.CELL/2
 app._gui_input(click)
 var worm: int = g.owned_worm(0)
 check(worm >= 4 and g.heroes[0].used[0],"real tile click summons and spends")
 check(g.unit_data(worm).owner == 0 and g.friendly(worm),"friendly marker belongs to Vesper")
 app.dice_tray._process(3);app.rolling_time = 0;app.rebuild()
 check(app.ui.get_node("BattleDie1").text.contains("Command Nu’gh"),"live duplicate label changes to Command")
 app.select_combat_die(1);app.rebuild()
 var resolve = app.ui.get_children().filter(func(n):return n is Button and n.text == "Resolve selected face")
 check(resolve.size() == 1,"Command has immediate Resolve control")
 if resolve.size() == 1:resolve[0].pressed.emit()
 check(g.heroes[0].used[1] and g.owned_worm(0) == worm,"Resolve Commands same worm")
 app.dice_tray._process(3);app.rolling_time = 0;app.rebuild()
 var motion := InputEventMouseMotion.new();motion.position = app.ORIGIN+Vector2(g.unit_data(worm).pos)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(motion)
 check(app.tooltip_text.contains("Friendly") and app.tooltip_text.contains("Vesper"),"hover explains owner and friendly timing")
 await capture("friendly-bugh")
 g.damage(worm,99);g.heroes[0].used[0] = false;app.rebuild()
 check(app.ui.get_node("BattleDie0").text.contains("Summon Nu’gh"),"worm death restores Summon UI")
 g.damage(3,6,true);app.rebuild()
 check(g.phase_two and g.phase_upgrades().size() == 6,"UI phase guide uses all six upgrades")
 await capture("bugh-phase-two")
 app.open_balance_editor()
 check(is_instance_valid(app.balance_editor),"workshop opens")
 print("V0.22 SUMMONS UI: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
