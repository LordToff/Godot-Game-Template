extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, why: String):
 checks += 1
 if not ok:failures += 1;printerr("V23 PRESENTATION FAIL: ",why)
func capture(name: String):
 for i in range(3):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/artifacts/v23-"+name+".png")
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://prototype/prototype.tscn")
 for i in range(5):await process_frame
 var app = current_scene;var score = app.score
 check(score.current == "forge" and score.players.size() == 2,"preparation cue and crossfade players")
 for cue in score.CUES:
  check(score.CUES[cue].get_length() > 30,"complete musical phrase: "+cue)
 check(score.players[score.slot].stream.loop,"music loops")
 var cards = app.ui.get_node("GiftCards").get_child(0)
 check(cards.get_child_count() == 48,"all bonus cards remain available")
 var card = cards.get_node("Face59")
 check(card.get_node("CardTitle").text.contains("Summon") and card.get_child_count() >= 2,"card has distinct title and supporting labels")
 check(card.get_theme_stylebox("normal").content_margin_top == card.get_theme_stylebox("hover").content_margin_top,"hover does not shift card text")
 check(app.ui.get_node("GiftSearch").get_theme_stylebox("focus").border_color == Color("e6c58c"),"keyboard focus is visible")
 await capture("face-picker")
 app.ui.get_node("SoundtrackSettings").pressed.emit()
 check(app.show_soundtrack and app.ui.has_node("MusicVolume") and app.ui.has_node("EffectsVolume"),"dedicated music/effects controls")
 var old_music: float = score.music_level;var old_effects: float = score.effects_level;var old_mute: bool = score.muted
 app.ui.get_node("MusicVolume").value = 35
 check(is_equal_approx(score.music_level,.35) and is_equal_approx(score.effects_level,old_effects),"music slider does not alter effects")
 app.ui.get_node("EffectsVolume").value = 60
 check(is_equal_approx(score.effects_level,.6),"effect slider works")
 score.set_muted(true)
 check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) and AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")),"mute covers both buses")
 score.set_muted(old_mute);score.set_level("Music",old_music);score.set_level("SFX",old_effects)
 await capture("soundtrack-controls")
 app.show_soundtrack = false
 for hero in range(3):app.gifts[hero] = [59,34];app.builds[hero] = app.Model.bonus_build(app.gifts[hero])
 app.build_hero = 2;app.confirm_gifts();await capture("encounters")
 app.encounter = "bugh";app.begin()
 for i in range(3):await process_frame
 check(score.current == "battle","battle music follows encounter state")
 await capture("battle")
 app.game.damage(3,6,true)
 for i in range(3):await process_frame
 check(score.current == "phase","phase II changes the score")
 var rng_state: int = app.game.rng.state
 score.set_cue("forge");score.set_cue("battle");score.set_cue("phase")
 check(app.game.rng.state == rng_state,"soundtrack transitions never consume gameplay RNG")
 await capture("phase-two")
 app.show_changes = true;app.rebuild()
 check(app.ui.get_node("PatchTopics").get_child(0).get_child_count() == app.Changes.SECTIONS.size(),"all patch topics live in a readable scroll list")
 await capture("patch-notes")
 print("V0.23 PRESENTATION: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
