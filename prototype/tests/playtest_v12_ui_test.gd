extends SceneTree
const Lab = preload("res://prototype/lab.gd")
var checks := 0
var failures := 0
func check(ok: bool, what: String):
 checks += 1
 if not ok:failures += 1;printerr("V12 UI FAIL: ",what)
func _initialize():call_deferred("run")
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v12-"+name+".png")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene;app.draft_modal = false;app.balance_values = {};app.balanced = true;app.rebuild()
 var first = app.ui.get_node("ForgeDie0Side0")
 var last = app.ui.get_node("ForgeDie0Side5")
 check(first.position.x == last.position.x and last.position.y-first.position.y == 216,"forge die has four-square stem")
 check(app.ui.get_node("ForgeDie0Side1").position.x < first.position.x and app.ui.get_node("ForgeDie0Side3").position.x > first.position.x,"forge die has left/right wings")
 await capture("forge-nets")
 app.lab_face = 31;app.start_lab();app.game = Lab.create(31);app.selected = -1;app.rebuild()
 var die = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("DIE I ·"))[0]
 die.pressed.emit()
 var window = app.ui.get_node("CombatAbilityWindow")
 check(window.position.x >= app.ORIGIN.x+app.CELL*9,"ability window lies entirely beside battlefield")
 check(app.ui.get_node("CombatAbilityDetails").text.contains("2 cumulative Block"),"clicking an ability opens its updated rules")
 app.game.hero_action(0);app.game.heroes[0].weak = true;app.game.heroes[0].dr = 2;app.rebuild()
 check(app.ui.get_node("ActiveStatuses").text.contains("Weakness") and app.ui.get_node("ActiveStatuses").tooltip_text.contains("Stonewake"),"active turn exposes buffs and debuffs")
 var move := InputEventMouseMotion.new();move.position = app.ORIGIN+Vector2(app.game.heroes[0].pos)*app.CELL+Vector2.ONE*app.CELL/2;app._gui_input(move)
 check(app.tooltip_text.contains("Weakness") and app.tooltip_text.contains("Stonewake"),"hovering knight explains active statuses")
 await capture("combat-inspector")
 app.inspect_action = "Furnace Roar";app.combat_inspected = -1;app.rebuild()
 check(app.ui.get_node("BossActionDetails").text.contains("push survivors"),"boss inspection uses same side window")
 await capture("boss-inspector")
 app.inspect_action = "";app.show_dice = true;app.dice_hero = 0;app.rebuild()
 check(app.ui.get_node("ViewDie0Side0").position.x == app.ui.get_node("ViewDie0Side5").position.x,"live dice use the same unfolded template")
 check(app.ui.get_node("ViewDie0Side1").position.x < app.ui.get_node("ViewDie0Side0").position.x,"live dice keep side numbering stable")
 app.ui.get_node("ViewDie1Side3").pressed.emit()
 check(app.ui.get_node("DiceNetDetails").text.contains("DIE II · SIDE 4"),"net side click opens correct die and face details")
 await capture("live-dice-nets")
 check(app.ui.get_children().filter(func(c):return c is Button and c.name.begins_with("ViewDie")).all(func(c):return c.size == Vector2(102,102)),"all six net squares retain exact dimensions without overlap")
 app.show_dice = false;app.game = Lab.create(0);app.selected = 0;app.rebuild()
 var reroll = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Reroll selected"))[0]
 check(not reroll.disabled,"ready Blank can use Action Reroll")
 app.game.heroes[0].opening = false;app.rebuild()
 reroll = app.ui.get_children().filter(func(c):return c is Button and c.text.begins_with("Reroll selected"))[0]
 check(reroll.disabled and reroll.tooltip_text.contains("Opening window closed"),"closed reroll window explains why")
 print("V0.12 UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
