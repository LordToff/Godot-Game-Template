extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String):
 checks += 1
 if not ok:failures += 1;printerr("CLARITY FAIL: ",message)
func _initialize():call_deferred("run")
func find_button(app, text: String):
 for child in app.ui.get_children():
  if child is Button and child.text == text:return child
 return null
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(4):await process_frame
 var app = current_scene
 check(app.Catalog.display_name(25) == "Contained Power (Skill - Channel)","Channel label uses implemented timing")
 check(app.Catalog.display_name(44) == "Shield Wall (Defense - Reaction)","Reaction label includes its category")
 check(app.Catalog.display_name(57) == "Ashstep (Movement)","ordinary movement is labelled without false timing")
 check(app.Catalog.display_name(32) == "Oath of Smoke (Skill)","an ability that grants a reaction is not falsely labelled as a reaction")
 var cards = app.ui.get_node("GiftCards").get_child(0)
 check(cards.get_child_count() == 47,"all 47 bonus abilities remain available")
 cards.get_node("Face25").pressed.emit()
 check(app.inspected_gift == 25 and app.gifts[0].is_empty(),"inspection keeps selections unchanged")
 find_button(app,"Add this face").pressed.emit()
 check(25 in app.gifts[0],"explicit Add selects inspected ability")
 app.ui.get_node("GiftTiming").item_selected.emit(3)
 cards = app.ui.get_node("GiftCards").get_child(0)
 check(cards.get_child_count() == 3,"Channel filter exposes exactly the three implemented Channels")
 check(cards.get_children().all(func(c):return " - Channel)" in c.text),"filtered cards consistently label timing")
 cards.get_node("Face31").pressed.emit()
 find_button(app,"Add this face").pressed.emit()
 check(app.gifts[0].size() == 2,"two-face limit maintained")
 cards = app.ui.get_node("GiftCards").get_child(0);cards.get_node("Face49").pressed.emit()
 check(find_button(app,"Two selected · remove one first").disabled,"third face requires removing an existing choice")
 app.confirm_gifts()
 check(app.build_hero == 1 and app.Model.validate(app.builds[0],app.gifts[0]) == "","confirmation advances hero with a legal build")
 app.ui.get_node("GiftSearch").text_changed.emit("stone")
 check(app.ui.get_node("GiftCards").get_child(0).get_child_count() == 1,"search and timing filters combine")
 app.begin()
 check(app.rolling_time == 0 and not app.dice_tray.busy and not app.dice_tray.visible,"encounter has no rolling overlay or delay")
 check(app.game.heroes.all(func(h):return h.rolls.size() == 3),"all real action results still exist")
 app.start_lab();app.lab_face = 25;app.reset_lab()
 check(app.ui.get_children().any(func(c):return c is Button and "Contained Power" in c.text and "(Skill - Channel)" in c.text),"battle dice show name, category and timing")
 check(app.ui.get_children().filter(func(c):return c is TextureRect).all(func(c):return c.size.x <= 40 and c.size.y <= 40),"portrait widgets fit their panels")
 check(app.PORTRAITS.get_width() == 32 and app.BACKDROP.get_height() == 179 and app.SPRITES.get_width() == 64,"painted game art loads")
 current_scene.queue_free()
 for i in range(3):await process_frame
 print("CLARITY UI: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
