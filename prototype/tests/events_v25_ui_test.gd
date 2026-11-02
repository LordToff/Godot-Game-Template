extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String):
 checks += 1
 if not ok:failures += 1;printerr("EVENT UI FAIL: ",message)
func _initialize():call_deferred("run")
func run():
 var scene = load("res://prototype/prototype.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.draft_modal = false;scene.open_setup()
 check(scene.ui.get_node_or_null("EncounterBugh") != null,"fourth boss preserved")
 var launch: Button
 for child in scene.ui.get_children():
  if child is Button and child.text == "Expedition events":launch = child
 check(launch != null,"event entry on boss review")
 launch.pressed.emit()
 for id in range(1,7):check(scene.ui.get_node_or_null("EventSlot%d" % id) != null,"visible numbered slot")
 scene.expedition.next_sortie();scene.rebuild();scene.ui.get_node("RollEvent").pressed.emit()
 check(scene.expedition.stage == "choice" and scene.ui.get_node_or_null("RollEvent") == null,"single roll opens choice and locks reroll")
 for id in range(1,7):
  scene.expedition.stage = "choice";scene.expedition.selected = id;scene.expedition.gold = 0;scene.expedition.salves = 0;scene.rebuild()
  check(scene.ui.get_node_or_null("EventChoice0") != null and scene.ui.get_node_or_null("EventChoice1") != null,"two visible choices")
  if id in [2,3]:check(scene.ui.get_node("EventChoice1").disabled,"unaffordable option visibly disabled")
 scene.expedition.selected = 4;scene.expedition.stage = "choice";scene.event_choice(1)
 check(scene.event_fight and scene.game.encounter_id == "event" and scene.page == "battle","fight choice launches ordinary encounter")
 scene.game.damage(3,99,true);scene.game.damage(4,99,true);scene.rebuild()
 check(scene.expedition.gold == 3 and scene.expedition.salves == 1,"outcome actually grants exact rewards")
 scene.rebuild();check(scene.expedition.gold == 3,"UI redraw cannot duplicate rewards")
 scene.event_fight = false;scene.page = "setup";scene.encounter = "bugh";scene.begin()
 check(scene.game.encounter_id == "bugh","event does not replace selected boss")
 scene.game.active = 0;scene.game.pending = {};scene.game.heroes[0].hp = 3
 check(scene.can_use_supply("salve"),"earned salve usable in boss encounter")
 scene.expedition.use_supply(scene.game,"salve")
 check(scene.game.heroes[0].hp == 5 and not scene.can_use_supply("salve"),"supply heals and cannot repeat that turn")
 scene.lab = true;check(not scene.can_use_supply("seal"),"lab cannot consume expedition supplies")
 print("Event UI: %d checks, %d failures" % [checks,failures]);scene.queue_free();await process_frame;quit(1 if failures else 0)
