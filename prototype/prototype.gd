extends Control

const Catalog = preload("res://prototype/catalog.gd")
const Model = preload("res://prototype/battle.gd")
const TITLE = preload("res://prototype/assets/title.ttf")
const BACKDROP = preload("res://prototype/assets/crypt_arena.png")
const PORTRAITS = preload("res://prototype/assets/character_portraits.png")
const BODY = preload("res://prototype/assets/body.ttf")
const GOLD = Color("d5b87a")
const INK = Color("10151e")
const MUTED = Color("91a0af")
const COLORS = [Color("69c7bd"),Color("c5a5e8"),Color("edbd79")]
const FACE_COLORS = [Color("697483"),Color("df897f"),Color("6fc2b7"),Color("6fc2b7"),Color("8db7df"),Color("8db7df"),Color("c5a5e8"),Color("c5a5e8"),Color("c5a5e8")]
const SYMBOLS = ["—","/","↑","↟","◇","↪","◎","+","»"]
const ORIGIN = Vector2(75,239)
const CELL = 55.0
var game = Model.new()
var dice_tray: Control
var roll_seen := 0
var channel_glows: Dictionary = {}
var friendly_confirm := -1
var show_training := false
var training_step := 0
var training := false
var lab_support := 34
var show_lab_setup := false
var compact_log := true
const LESSON_FACES = [2,1,4,7,5,31,0,57]
const LESSONS = ["Move: select Die I (Step), then a highlighted empty cell.","Attack: select Die I (Strike), then click the boss. Allies need a second click to confirm friendly fire.","Block: select Die I (Guard), then Resolve. Watch Block and the blue shield.","Heal: select Die I (First Aid), then an injured adjacent hero.","Reaction: press Boss hits, then choose Block + stay. This held die reacts before damage.","Channel: select Die I (Stonewake), then Resolve. Watch the persistent blue ring; Next turn opens maintain / release.","Reward Soul: select Die I (Blank), then move up to two cells. Only one Blank per hero turn may convert.","Escape danger: select Die I (Ashstep), then move outside the red cross before the next boss turn."]
const Tray = preload("res://prototype/dice_tray.gd")
var builds: Array = [Model.default_build(),Model.default_build(),Model.default_build()]
var page := "forge"
var build_hero := 0
var selected := -1
var shove_target := -1
var hover := Vector2i(-1,-1)
var ui: Control
var hint := "Choose a hero and customize their three dice. A balanced build is already equipped."
var show_help := false
var show_options := false
var reward_soul := false
var audio: AudioStreamPlayer
var music: AudioStreamPlayer
var muted := false
var t := 0.0
var balanced := true
var rolling_time := 0.0
var seen_roll := 0
var inspect_action := ""
var show_history := false
var visual_positions: Dictionary = {}
var snapshots: Dictionary = {}
var floaters: Array = []
var hit_time := 0.0
var offers: Array = []
var gifts: Array = [[],[],[]]
var draft_search := ""
var draft_category := "All"
var draft_timing := "All timings"
var inspected_gift := 9
var draft_scroll := 0
var seen_event := 0
var effects: Array = []
var log_filter := "All"
var draft_modal := true
var show_changes := false
var changes_page := 0
var show_dice := false
var dice_hero := 0
var dice_inspected := Vector2i(0,0)
var show_turn := false
var lab := false
var lab_face := 1
var lab_numeric := -1
var movement_tracks: Dictionary = {}
const Lab = preload("res://prototype/lab.gd")
const Changes = preload("res://prototype/changes.gd")


func _ready() -> void:
 var theme_res := Theme.new()
 theme_res.default_font = BODY
 theme_res.default_font_size = 15
 theme = theme_res
 mouse_filter = Control.MOUSE_FILTER_PASS
 ui = Control.new(); ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(ui)
 var sound_controller = get_node_or_null("/root/ProjectUISoundController")
 if sound_controller and is_instance_valid(sound_controller.button_pressed_player): audio = sound_controller.button_pressed_player
 else:
  audio = AudioStreamPlayer.new(); audio.bus = &"SFX"
  if sound_controller: sound_controller.add_child(audio)
  else: add_child(audio)
 music = AudioStreamPlayer.new(); music.bus = &"Music"; music.volume_db = -22; add_child(music)
 make_audio()
 make_offers()
 dice_tray = Tray.new();add_child(dice_tray)
 dice_tray.finished.connect(func(): rolling_time = 0; rebuild())
 rebuild()
 if get_tree().root.has_meta("ash_restart"):
  var saved: Dictionary = get_tree().root.get_meta("ash_restart")
  get_tree().root.remove_meta("ash_restart")
  builds = saved.builds; reward_soul = saved.soul; muted = saved.muted
  balanced = saved.get("balanced",true)
  gifts = saved.get("gifts",gifts); offers = saved.get("offers",offers); draft_modal = false
  music.stream_paused = muted
  audio.volume_db = -80 if muted else 0
  begin()
 elif "--battle" in OS.get_cmdline_user_args(): begin()

func make_audio() -> void:
 var wav := AudioStreamWAV.new(); wav.mix_rate = 22050; wav.format = AudioStreamWAV.FORMAT_16_BITS
 var data := PackedByteArray(); data.resize(22050*2*4)
 for i in range(22050*4):
  var x := float(i)/22050.0
  var sample := int((sin(x*TAU*55)+0.3*sin(x*TAU*82.5)+0.12*sin(x*TAU*110))*1300)
  data.encode_s16(i*2,sample)
 wav.data = data; wav.loop_mode = AudioStreamWAV.LOOP_FORWARD; wav.loop_end = 22050*4
 music.stream = wav
 var music_controller = get_node_or_null("/root/ProjectMusicController")
 if music_controller:
  music_controller.fade_in_duration = 1.0
  music_controller.play_stream_player(music)
 else: music.play()
 var click := AudioStreamWAV.new(); click.mix_rate = 22050; click.format = AudioStreamWAV.FORMAT_16_BITS
 var cd := PackedByteArray(); cd.resize(2205*2)
 for i in range(2205): cd.encode_s16(i*2,int(sin(float(i)*0.08)*2200*pow(1.0-float(i)/2205.0,3)))
 click.data = cd; audio.stream = click
 # Maaack's existing UI Sound Controller connects dynamically created buttons.
 var sound_controller = get_node_or_null("/root/ProjectUISoundController")
 if sound_controller:
  sound_controller.button_pressed = click
  sound_controller.button_pressed_player = audio

func _process(delta: float) -> void:
 t += delta
 var effect_delta := 0.0 if rolling_time > 0 else delta
 hit_time = maxf(0,hit_time-effect_delta)
 for f in floaters: f.life -= effect_delta
 for fx in effects: fx.life -= effect_delta
 effects = effects.filter(func(fx):return fx.life > 0)
 floaters = floaters.filter(func(f):return f.life > 0)
 if page == "battle":
  for id in range(4):
   var target_pos: Vector2 = Vector2(game.boss.pos if id == 3 else game.heroes[id].pos)
   if visual_positions.has(id):
    if not movement_tracks.has(id) or movement_tracks[id].to != target_pos:
     movement_tracks[id] = {"from":visual_positions[id],"to":target_pos,"elapsed":0.0}
    var track: Dictionary = movement_tracks[id]
    track.elapsed = minf(0.34,track.elapsed+delta)
    var progress: float = track.elapsed/0.34
    visual_positions[id] = track.from.lerp(track.to,progress*progress*(3.0-2.0*progress))
 if dice_tray and dice_tray.busy:
  if rolling_time <= 0: dice_tray.finish()
 else:
  rolling_time = 0
 if page == "battle":
  for id in range(3):
   var goal := 1.0 if not game.heroes[id].channel.is_empty() and game.heroes[id].hp > 0 and not game.heroes[id].dead else 0.0
   channel_glows[id] = move_toward(float(channel_glows.get(id,0.0)),goal,delta*3)

 queue_redraw()

func style(bg: Color, border: Color, radius: int = 7) -> StyleBoxFlat:
 var s := StyleBoxFlat.new(); s.bg_color = bg; s.border_color = border
 s.set_border_width_all(1); s.set_corner_radius_all(radius)
 s.content_margin_left = 12; s.content_margin_right = 12
 return s

func label_at(text: String, p: Vector2, size_px: int = 16, col: Color = Color("e2e5e9"), w: float = 600, serif: bool = false, wrap: bool = false) -> Label:
 var l := Label.new()
 if wrap: l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 l.text = text; l.position = p; l.size.x = w
 l.add_theme_font_size_override("font_size",size_px); l.add_theme_color_override("font_color",col)
 if serif: l.add_theme_font_override("font",TITLE)
 ui.add_child(l); return l

func button(text: String, p: Vector2, sz: Vector2, fn: Callable, accent: Color = GOLD, disabled: bool = false) -> Button:
 var b := Button.new(); b.text = text; b.position = p; b.size = sz; b.disabled = disabled or (page == "battle" and rolling_time > 0)
 b.add_theme_stylebox_override("normal",style(Color("1a222e"),Color(accent,0.35)))
 b.add_theme_stylebox_override("hover",style(Color("2b3543"),accent))
 b.add_theme_stylebox_override("pressed",style(Color("354050"),accent))
 b.add_theme_stylebox_override("disabled",style(Color("151b25"),Color("29303a")))
 b.add_theme_color_override("font_color",accent); b.add_theme_color_override("font_disabled_color",Color("53606c"))
 b.pressed.connect(func():
  fn.call())
 ui.add_child(b); return b

func panel(rect: Rect2, color: Color = Color("161d28"), border: Color = Color("303a48")) -> void:
 draw_style_box(style(color,border),rect)

func rebuild() -> void:
 sync_presentation()
 for c in ui.get_children(): ui.remove_child(c); c.queue_free()
 label_at("ASH & OATH",Vector2(42,26),27,GOLD,500,true)
 label_at("A DICE-BUILDING BOSS BATTLER · v0.9",Vector2(44,65),11,MUTED)
 button("View dice",Vector2(350,30),Vector2(235,40),func(): show_dice = true; dice_hero = game.active if page == "battle" else build_hero; rebuild(),Color("9fc7e6"))
 button("Tutorial / Ability Lab",Vector2(605,30),Vector2(245,40),start_lab,Color("82c8b9"))
 button("What changed",Vector2(866,30),Vector2(225,40),func(): show_changes = true; rebuild())
 button("?  Rules",Vector2(1114,30),Vector2(112,40),func(): show_help = not show_help; rebuild())
 button("Options",Vector2(1236,30),Vector2(110,40),open_settings,Color("9fc7e6"))
 if page == "forge": forge_ui()
 else: battle_ui()
 if draft_modal and page == "forge": draft_ui()
 if inspect_action != "":
  overlay()
  label_at("BOSS ACTION REFERENCE",Vector2(399,265),12,GOLD)
  label_at(inspect_action,Vector2(399,305),30,Color("ece6d9"),600,true)
  label_at(game.boss_help(inspect_action),Vector2(399,375),18,MUTED,520,false,true)
  button("Understood",Vector2(399,555),Vector2(520,48),func(): inspect_action = ""; rebuild())
 if show_history: history_ui()
 if show_help: help_ui()
 if show_changes: changes_ui()
 if show_turn: turn_ui()
 if show_dice: dice_ui()
 if show_lab_setup: lab_setup_ui()
 if show_options: options_ui()
 queue_redraw()

func forge_ui() -> void:
 label_at("Shape what remains.",Vector2(68,110),38,Color("ece6d9"),1000,true)
 label_at(hint,Vector2(70,165),16,MUTED)
 for i in range(3):
  button(("◆ " if i == build_hero else "") + ["01  VESPER","02  ROOK","03  WREN"][i],Vector2(70+i*216,215),Vector2(202,48),func(): build_hero = i; rebuild(),COLORS[i])
 label_at("THE DICE FORGE",Vector2(72,295),13,GOLD)
 label_at("Click a side to choose a face from this hero’s owned pool.",Vector2(72,324),14,MUTED)
 for d in range(3):
  label_at("DIE " + ["I","II","III"][d],Vector2(82,380+d*111),15,GOLD)
  for side in range(6):
   var f: int = builds[build_hero][d][side]
   var o := OptionButton.new(); o.clip_text = true; o.position = Vector2(160+side*102,369+d*111); o.size = Vector2(96,66)
   o.add_theme_font_size_override("font_size",12)
   for id in range(9): o.add_item(Catalog.display_name(id),id)
   for id in gifts[build_hero]: o.add_item(Catalog.display_name(id),id)
   o.select(o.get_item_index(f)); o.add_theme_stylebox_override("normal",style(Color("202938"),Color(color_for_face(f),0.55)))
   o.add_theme_color_override("font_color",color_for_face(f))
   o.item_selected.connect(func(index): builds[build_hero][d][side] = o.get_item_id(index); rebuild())
   o.get_popup().min_size = Vector2i(440,0)
   o.tooltip_text = Catalog.display_name(f) + "\n" + face_help(f); ui.add_child(o)
 var error := Model.validate(builds[build_hero],gifts[build_hero])
 label_at("✓ Legal build · " + str(18-builds[build_hero].reduce(func(a,d): return a+d.count(0),0)) + "/12 ability faces" if error == "" else error,Vector2(75,706),14,COLORS[build_hero] if error == "" else Color("ef8e87"),730)
 button("Guided practice",Vector2(350,811),Vector2(200,40),start_training,Color("82c8b9"))
 button("Save build preset",Vector2(75,811),Vector2(245,40),save_preset,MUTED)
 button("Load preset",Vector2(560,811),Vector2(220,40),load_preset,MUTED)
 soul_toggle(Vector2(350,756),false)
 button("Restore balanced build",Vector2(75,756),Vector2(245,46),func(): builds[build_hero] = Model.default_build(); rebuild(),MUTED)
 label_at("YOUR INHERITANCE",Vector2(886,300),13,GOLD)
 label_at("Memory   /   Empty\nSoul          /   6 HP · 2+ Blanks per die\nBody         /   Broken Body",Vector2(886,335),16,Color("d2d8df"))
 label_at("OWNED FACE POOL",Vector2(886,445),12,GOLD)
 label_at("4 Strike   ·   2 Step   ·   1 Stride\n2 Guard   ·   1 Reaction\n1 Focus   ·   1 First Aid   ·   1 Shove",Vector2(886,474),15,MUTED)
 label_at("Each hero owns 13 starter tiles + 2 gifts. Equip up to 12.\nAt most 3 Movement, 3 Defense and 3 Skill.\nBlank → Move 2 is " + ("ON." if reward_soul else "OFF."),Vector2(886,559),13,MUTED)
 button("Balance: " + ("Tuned tutorial" if balanced else "Original rulebook"),Vector2(884,645),Vector2(400,35),func(): balanced = not balanced; rebuild(),GOLD)
 label_at("16 boss HP · Strike 2 · Brace 1 · no idle Block\n1 starting Action Reroll per hero, once per fight.\nLocal play · three heroes · open 9×9 arena." if balanced else "Original: 18 boss HP · Strike 1 · Brace 2\n1 starting Action Reroll per hero, once per fight.\nLocal play · three heroes · open 9×9 arena.",Vector2(886,692),13,MUTED)
 button("Bonus faces: %d / 2 · browse full pool" % gifts[build_hero].size(),Vector2(884,601),Vector2(400,35),func(): draft_modal = true; rebuild(),Color("be9bdf"))
 var legal_builds := true
 for i in range(3):
  if Model.validate(builds[i],gifts[i]) != "" or gifts[i].size() != 2: legal_builds = false
 button("Enter the hollow   →",Vector2(884,773),Vector2(400,55),begin,GOLD,not legal_builds)

func retry(with_soul: bool = false) -> void:
 get_tree().root.set_meta("ash_restart", {"builds":builds.duplicate(true),"soul":with_soul or reward_soul,"muted":muted,"balanced":balanced,"gifts":gifts,"offers":offers})
 SceneLoader.load_scene("res://prototype/prototype.tscn")

func begin() -> void:
 training = false
 lab = false
 draft_modal = false
 game.start(builds,0,reward_soul,balanced); page = "battle"; seen_roll = 0; roll_seen = 0; seen_event = 0; effects.clear(); snapshots.clear(); visual_positions.clear(); selected = -1; shove_target = -1
 hint = "Select a rolled die, then a highlighted cell or unit. Boss dice are public."
 rebuild()

func battle_ui() -> void:
 portrait_at(3,Vector2(74,102),Vector2(40,40))
 label_at("ABILITY LAB" if lab else "THE HOLLOW",Vector2(128,109),28,Color("ece6d9"),500,true)
 label_at("▶ ROUND %02d   /   %s" % [game.round_no,"ENCOUNTER ENDED" if game.outcome != "" else ("THE HOLLOW’S TURN" if game.active == 3 else game.heroes[game.active].name + "’S TURN")],Vector2(90,150),22,Color("fff0c8"))
 label_at("%d / %d HP    ·    %d BLOCK" % [game.boss.hp,game.boss.max_hp,game.boss.block],Vector2(408,119),13,Color("d78b83"))
 var x := 74.0
 for id in game.order:
  var name_text: String = "HOLLOW" if id == 3 else game.heroes[id].name
  var init: int = game.boss.initiative if id == 3 else game.heroes[id].initiative
  label_at(("◆ " if id == game.active else "○ ") + name_text + "  " + str(init),Vector2(x,193),12,GOLD if id == game.active else MUTED,150)
  x += 141
 for i in range(3):
  var h: Dictionary = game.heroes[i]
  var cy := 790
  var hx := 76+i*183
  portrait_at(i,Vector2(hx+4,cy),Vector2(40,40))
  label_at(h.name,Vector2(hx+50,cy),15,COLORS[i],124,true)
  label_at("%d/6 HP · %d Block" % [h.hp,h.block],Vector2(hx+50,cy+24),11,MUTED,124)
  var statuses: String = "DEAD" if h.dead else ("DOWNED" if h.hp == 0 else ("BROKEN  " if h.broken else ""))
  if h.weak or h.bulwark_weak: statuses += " WEAK"
  if not h.reaction.is_empty(): statuses += " REACTION ×"+str(h.reaction.size())
  if h.stun: statuses += " STUN"
  if h.dr > 0: statuses += " DR " + str(h.dr)
  if h.ward: statuses += " WARD"
  if not h.channel.is_empty(): statuses += " CHANNEL"
  if h.num_boost > 0: statuses += " NUM +"+str(h.num_boost)
  label_at(statuses,Vector2(hx,cy+53),10,GOLD,175,false,true).max_lines_visible = 2
  if not h.rolls.is_empty():
   var public_dice: Array[String] = []
   for d in range(3): public_dice.append(Model.FACES[game.face(i,d)].left(3) + ("·" if h.used[d] else ""))
   label_at(" / ".join(public_dice),Vector2(hx,cy+68),10,MUTED,175)
 label_at("BOSS INTENT  /  CLICK AN ACTION TO EXPLAIN",Vector2(630,199),11,GOLD)
 for d in range(3):
  var action: String = game.boss_rolls[d]
  if game.active == 3:
   var col := GOLD if d == game.boss_index else MUTED
   label_at(["I","II","III"][d] + "   " + action + ("   ✓" if d < game.boss_index else ""),Vector2(632,235+d*109),17,col)
   label_at(game.boss_help(action),Vector2(632,266+d*109),13,MUTED,375,false,true)
  else:
   button(["I","II","III"][d] + "    " + action + "    · Details",Vector2(630,231+d*41),Vector2(380,34),func(): inspect_action = action; rebuild(),MUTED).tooltip_text = game.boss_help(action)
 soul_toggle(Vector2(630,778) if game.active == 3 else Vector2(630,352),true)
 if game.active < 3: label_at("YOUR DICE · CHOOSE ONE",Vector2(630,391),12,GOLD)
 if game.active < 3:
  var h: Dictionary = game.heroes[game.active]
  for d in range(3):
   var f: int = game.face(game.active,d)
   var state: String = "CHANNEL HELD" if not h.channel.is_empty() and h.channel.die == d else ("REACTION HELD" if d in h.reaction else ("SPENT" if h.used[d] else ("RESOLVE NEXT" if game.forced_die == d else "READY")))
   var face_name: String = "Blank → Move 2 (Movement)" if f == 0 and game.reward and not h.soul_move_used else Catalog.display_name(f)
   var text: String = "DIE " + ["I","II","III"][d] + "  ·  " + ("SELECTED" if selected == d and not h.used[d] else state) + "\n" + face_name
   var die_button := button(text,Vector2(630,416+d*61),Vector2(380,51),func():
    friendly_confirm = -1
    if selected >= 0 and game.face(game.active,selected) == 6 and selected != d:
     if game.hero_action(selected,d): selected = d if not game.heroes[game.active].used[d] else -1
    elif game.forced_die < 0 or game.forced_die == d: selected = d; shove_target = -1
    hint = face_help(game.face(game.active,d)); rebuild(),color_for_face(f),h.used[d] or (game.forced_die >= 0 and game.forced_die != d) or not game.pending.is_empty() or game.outcome != "")
   die_button.tooltip_text = face_help(f)
   die_button.add_theme_font_size_override("font_size",15)
   if selected == d and not h.used[d]:
    var selected_style := style(Color("304151"),color_for_face(f)); selected_style.set_border_width_all(2)
    die_button.add_theme_stylebox_override("normal",selected_style)
  if selected >= 0 and not h.used[selected]:
   var f: int = game.face(game.active,selected)
   if f in [4,9,10,11,13,14,16,17,18,20,21,22,23,24,25,26,27,29,30,31,32,33,42,43,47,49,50,51,52,54,56] or (f == 0 and (not game.reward or h.soul_move_used)):
    button("Resolve selected face",Vector2(630,609),Vector2(225,41),func(): game.hero_action(selected); selected = -1; rebuild())
   button("Decline",Vector2(865,609),Vector2(145,41),func(): game.decline(selected); selected = -1; rebuild(),MUTED)
  button(("Reroll selected die" if selected >= 0 else "Select a die to reroll") + "   ·   " + str(h.rerolls) + " left",Vector2(630,737),Vector2(380,43),func():
   if game.action_reroll(selected): selected = -1; hint = "Reroll spent. Fresh result kept."
   rebuild(),Color("82c8b9"),selected < 0 or h.rerolls == 0 or not h.opening or (selected >= 0 and game.face(game.active,selected) in [9,11,15,56]) or not game.pending.is_empty() or game.outcome != "")
  if not lab: label_at("Opening window only · no automatic refill",Vector2(637,784),10,MUTED)
  label_at("%d dice unused · reactions stay held" % h.used.count(false),Vector2(637,655),12,MUTED,380)
  button("End hero turn   →",Vector2(630,674),Vector2(380,50),func(): game.finish_turn(); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 else:
  var last: String = "No action resolved yet." if game.last_action == "" else "LAST: " + game.last_action + (" → " + ", ".join(game.last_targets.map(func(id):return game.heroes[id].name)) if not game.last_targets.is_empty() else "")
  label_at(last,Vector2(632,574),14,Color("e1af9b"),375,false,true)
  label_at("Watch the board and chronicle for HP, Block,\nmovement and status changes.",Vector2(632,615),12,MUTED)
  button("Resolve " + (["I","II","III"][mini(game.boss_index,2)] if game.boss_index < 3 else "end of turn") + "   →",Vector2(630,674),Vector2(380,54),func(): game.boss_step(); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 label_at("BATTLE LOG",Vector2(1070,199),17,GOLD,170,true)
 button("Summary" if compact_log else "All events",Vector2(1245,202),Vector2(115,24),func(): compact_log = not compact_log; rebuild(),MUTED).add_theme_font_size_override("font_size",10)
 button("Full history / filters",Vector2(1070,232),Vector2(290,34),func(): show_history = true; rebuild(),MUTED)
 var latest := RichTextLabel.new(); latest.name = "SideChronicle"; latest.bbcode_enabled = true; latest.position = Vector2(1070,281); latest.size = Vector2(290,552); latest.add_theme_font_size_override("normal_font_size",16); latest.scroll_following = true
 var formatted: Array[String] = []
 for entry in game.event_log:
  if compact_log and entry.kind in ["guide","action","roll","info"]: continue
  formatted.append(format_event(entry,true))
 latest.text = "\n\n".join(formatted); ui.add_child(latest)
 label_at("Scroll up to review · newest at bottom",Vector2(1070,847),11,MUTED,300)
 var displayed_hint: String = "Boss turn: resolve I → II → III. Reactions pause before damage." if game.active == 3 else (game.unit_name(game.active)+": optional opening reroll → resolve available dice → End hero turn." if selected < 0 else hint)
 if training: displayed_hint = "Lesson %d/%d · " % [training_step+1,LESSONS.size()] + LESSONS[training_step]
 var hint_label := label_at("Choose a push direction:" if shove_target >= 0 else displayed_hint,Vector2(630,126),15,Color("dce6ee"),380,false,true)
 hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; hint_label.size = Vector2(380,54)
 hint_label.max_lines_visible = 3; hint_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS; hint_label.tooltip_text = displayed_hint
 label_at("NEXT STEP",Vector2(630,105),11,GOLD,380)
 if shove_target >= 0 and selected >= 0:
  for i in range(4):
   var dir: Vector2i = Model.DIRS[i]
   button(["North","East","South","West"][i],Vector2(630+i*96,864),Vector2(90,30),func():
    if game.hero_action(selected,shove_target,dir): selected = -1; shove_target = -1
    rebuild(),GOLD,dir not in game.away_dirs(game.active,shove_target))
 label_at(("SOUL %d/1 left · " % int(not game.heroes[game.active].soul_move_used) if game.reward and game.active < 3 else "")+"REROLL FIRST → resolve available dice → END TURN\nAll heroes roll together at the NEXT ROUND. Reactions wait for attacks.",Vector2(76,742),11,MUTED,525)
 button("Turn help",Vector2(902,387),Vector2(108,25),func(): show_turn = true; rebuild(),GOLD)
 button("Rebuild / restart",Vector2(830,811),Vector2(180,39),func(): page = "forge"; selected = -1; rebuild(),MUTED)
 button("Game options",Vector2(630,811),Vector2(185,39),open_settings,MUTED)
 if lab: lab_ui()
 if not game.pending.is_empty(): pending_ui()
 if game.outcome != "": outcome_ui()

func open_settings() -> void:
 show_options = true
 rebuild()

func open_audio_settings() -> void:
 var options = load("res://scenes/windows/main_menu_options_window.tscn").instantiate()
 options.add_to_group("ash_settings")
 options.closed.connect(options.queue_free)
 add_child(options)
 options.show()

func face_help(f: int) -> String:
 if f >= 9: return Catalog.text(f) + (" Tuned balance: positive Numeric Attack damage gains +1; Short Shot remains capped at 1." if balanced and f in range(34,42) else "")
 return ["Blank: no starting effect. First reward Soul: spend at most ONE rolled Blank per hero turn as Move 2. This does not permanently change the installed face.","Strike: %d damage to one adjacent unit. Weakness subtracts 1. Allies are legal targets." % (2 if balanced else 1),"Step: move up to 1 orthogonal space.","Stride: move up to 3 spaces in one straight orthogonal direction; no turning.","Guard: gain 1 Block. Block expires at your next turn start.","Tactical Defense: stored when rolled. On being targeted, gain 1 Block and optionally step 1 before the attack.","Focus: select another unresolved die to reroll it. Keep and resolve its new face.","First Aid: heal yourself or an adjacent hero for 1. Revives Downed heroes with Broken.","Shove: choose an adjacent unit, then a directly-away direction. Moves the full boss footprint. No collision penalty."][f]

func pending_ui() -> void:
 overlay()
 var p: Dictionary = game.pending
 label_at("A MOMENT TO RESPOND",Vector2(399,260),12,GOLD)
 if p.kind in ["channel","bind","ember","catalog_choice","slot"]:
  catalog_pending_ui(p)
 elif p.kind == "reaction":
  label_at(game.heroes[p.hero].name + " is targeted.",Vector2(399,300),26,Color("ece6d9"),620,true)
  var reaction_face: int = game.face(p.hero,p.get("die",game.heroes[p.hero].reaction[0]))
  label_at("Spend Tactical Defense: gain 1 Block, then optionally move 1.\nThe boss rechecks its target before the attack resolves.",Vector2(399,352),15,MUTED)
  if reaction_face != 5:
   for c in ui.get_children():
    if c is Label and c.position == Vector2(399,352): c.text = face_help(reaction_face); c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; c.size.x = 520
  button("Block + stay" if reaction_face == 5 else "Use " + Model.FACES[reaction_face],Vector2(399,421),Vector2(250,48),func(): game.react(true); rebuild())
  button("Hold reaction",Vector2(669,421),Vector2(250,48),func(): game.react(false); rebuild(),MUTED)
  for i in range(4):
   var dir: Vector2i = Model.DIRS[i]
   button("Block + " + ["North","East","South","West"][i],Vector2(399+(i%2)*270,490+(i/2)*60),Vector2(250,48),func(): game.react(true,dir); rebuild(),GOLD,reaction_face != 5 and not game.heroes[p.hero].smoke.has(p.get("die",-1)) or not game.legal(p.hero,game.heroes[p.hero].pos+dir))
 elif p.kind == "fracture":
  label_at("Fracture · " + game.heroes[p.hero].name,Vector2(399,301),26,Color("ece6d9"),620,true)
  label_at("Choose an installed ability to replace with Blank for this fight.\nYour recorded build returns after the encounter.",Vector2(399,348),15,MUTED)
  for d in range(3):
   for side in range(6):
    var f: int = game.heroes[p.hero].build[d][side]
    button(Model.FACES[f],Vector2(377+side*98,416+d*66),Vector2(92,54),func(): game.fracture(d,side); rebuild(),color_for_face(f),f in [0,56]).add_theme_font_size_override("font_size",11)
 elif p.kind == "push":
  label_at("Drive Back · choose direction",Vector2(399,301),24,Color("ece6d9"),700,true)
  label_at("Choose a directly-away direction. A blocked destination causes\n1 unavoidable damage and Stunned. A board edge is a wall.",Vector2(399,356),15,MUTED)
  for i in range(4):
   var dir: Vector2i = Model.DIRS[i]
   button(["North","East","South","West"][i],Vector2(399+(i%2)*270,433+(i/2)*65),Vector2(250,48),func(): game.push(dir); rebuild(),GOLD,dir not in game.away_dirs(3,p.hero))
 elif p.kind in ["stun","preroll_stun"]:
  label_at("Stunned · " + game.heroes[p.hero].name,Vector2(399,301),26,Color("ece6d9"),620,true)
  label_at("Choose one die to set aside before the shared roll." if p.kind == "preroll_stun" else "Choose one unresolved Action Die to set aside.",Vector2(399,356),16,MUTED)
  for d in range(3):
   button("Die %d" % [d+1] if p.kind == "preroll_stun" else "Die %d · %s" % [d+1,Model.FACES[game.face(p.hero,d)]],Vector2(399,416+d*56),Vector2(520,45),func(): game.stun_die(d); rebuild(),GOLD,p.kind != "preroll_stun" and game.heroes[p.hero].used[d])

func overlay() -> void:
 var shade := ColorRect.new(); shade.color = Color(0.02,0.03,0.05,0.93); shade.size = Vector2(1440,900); ui.add_child(shade)
 var box := Panel.new(); box.position = Vector2(350,222); box.size = Vector2(680,445); box.add_theme_stylebox_override("panel",style(Color("19212d"),GOLD)); ui.add_child(box)

func outcome_ui() -> void:
 overlay()
 if lab:
  label_at("ABILITY LAB · TEST COMPLETE",Vector2(399,280),24,GOLD,620,true)
  label_at("The test reached an encounter outcome. Reset restores the fixture.\nYour normal builds and rewards are preserved.",Vector2(399,350),16,MUTED,570,false,true)
  button("Reset this test",Vector2(399,430),Vector2(520,48),reset_lab)
  button("Review battle chronicle",Vector2(399,495),Vector2(520,44),func(): show_history = true; rebuild(),MUTED)
  button("Return to the forge",Vector2(399,560),Vector2(520,44),func(): lab = false; page = "forge"; rebuild(),MUTED)
  return
 var won: bool = game.outcome == "victory"
 label_at("ENCOUNTER COMPLETE",Vector2(399,264),12,GOLD)
 label_at("A soul, reclaimed." if won else "The oath is not over.",Vector2(399,309),32,Color("ece6d9"),700,true)
 label_at("The Hollow is defeated. Each hero unlocks the boss Soul.\n6 maximum HP · 2+ Blanks per die.\nOnce per hero turn: spend ONE Blank as Move 2.\nSurviving heroes recover between encounters." if won else "All three heroes are Downed or dead.\nA clean test restart restores HP, dice and conditions.\nRebuild your dice or try the encounter again.",Vector2(399,378),16,MUTED)
 if won:
  button("Rematch with reward Soul",Vector2(399,493),Vector2(520,49),func(): retry(true))
 else:
  button("Try again",Vector2(399,493),Vector2(520,49),retry)
 button("Return to the forge",Vector2(399,556),Vector2(520,45),func(): lab = false; page = "forge"; rebuild(),MUTED)
 button("Review battle chronicle",Vector2(399,612),Vector2(520,35),func(): show_history = true; rebuild(),MUTED)

func help_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("0e141f"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("The shape of an oath",Vector2(160,85),38,GOLD,1000,true)
 label_at("A playable tutorial based on Master Rules v10 and Action Faces.",Vector2(162,143),16,MUTED)
 label_at("01   BUILD",Vector2(162,215),17,GOLD)
 label_at("Each hero chooses TWO distinct bonus faces from the full 47-face extended pool.\nStarter faces are excluded. Equip up to 12 abilities from your starter pool plus both gifts. Each die needs 2+ Blanks.\nBroken Body: max 3 Movement, 3 Defense, 3 Skill. Gift cards label prototype variants.",Vector2(162,250),16,Color("d8dfe5"))
 label_at("02   ROLL & RESOLVE",Vector2(162,345),17,GOLD)
 label_at("Initiative is rolled once. All available dice roll together at each round boundary.\nEach hero starts with 1 Action Reroll: select a die and reroll BEFORE resolving any face.\nFocus is a separate exception. Dice animate without changing their final results.\nBoss I → II → III: effects are shown on each card. Click compact intent rows to inspect.",Vector2(162,380),16,Color("d8dfe5"))
 label_at("03   SURVIVE",Vector2(162,500),17,GOLD)
 label_at("Reactions store immediately and expire before the next round’s roll. Block is spent\non damage and expires at your next turn. First zero HP: Downed, protected through\nthe acting turn. First Aid revives with Broken and queues a full recovery turn.\nAt zero again, a Broken hero dies. All heroes Downed/dead means immediate defeat.",Vector2(162,535),16,Color("d8dfe5"))
 label_at("PROTOTYPE SCOPE",Vector2(162,660),13,GOLD)
 label_at("Tuned default: boss 16 HP, Basic Strike 2, Brace 1; an idle Advance grants no Block.\nSelect Original rulebook in the forge for 18 HP / Strike 1 / Brace 2.\nBonus faces use the printed playtest variants. The boss faces north for rear attacks.\nNo campaign Events or online multiplayer. Click Chronicle to review every result.",Vector2(162,696),14,MUTED)
 button("Return to the game",Vector2(1003,799),Vector2(255,51),func(): show_help = false; rebuild())

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion:
  hover = Vector2i((event.position-ORIGIN)/CELL)
  tooltip_text = ""
  if page == "battle":
   for id in range(3):
    var h: Dictionary = game.heroes[id]
    if hover == h.pos:
     tooltip_text = h.name+" · HP %d/6 · Block %d" % [h.hp,h.block]
     if not h.channel.is_empty():tooltip_text += "\nChannel: "+Model.FACES[h.channel.face]+"\n"+Catalog.text(h.channel.face)
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  if page != "battle" or show_options or show_lab_setup or show_dice or show_turn or show_changes or show_help or show_history or inspect_action != "" or rolling_time > 0 or not game.pending.is_empty() or game.outcome != "" or game.active == 3 or selected < 0: return
  var c := Vector2i((event.position-ORIGIN)/CELL)
  if not Rect2(ORIGIN,Vector2.ONE*CELL*9).has_point(event.position): return
  var f: int = game.face(game.active,selected)
  var target := -1
  for u in range(4):
   if u < 3 and game.heroes[u].dead: continue
   if c in game.cells(u): target = u
  if Catalog.is_attack(f) and target in [0,1,2] and target != game.active and friendly_confirm != target:
   friendly_confirm = target; hint = "FRIENDLY FIRE: click this ally again to confirm the attack."; rebuild(); return
  friendly_confirm = -1
  var done := false
  if f in [0,2,3,53,54,57]: done = game.hero_action(selected,-1,c)
  elif f == 8:
   if shove_target == -1 and target >= 0 and target != game.active and game.distance(game.active,target) == 1:
    shove_target = target; hint = "Choose a push direction from the arrows beside the board."; rebuild(); return
   elif shove_target >= 0:
    var tp: Vector2i = game.boss.pos if shove_target == 3 else game.heroes[shove_target].pos
    var delta := c-tp
    var dir := Vector2i(signi(delta.x),0) if absi(delta.x) >= absi(delta.y) else Vector2i(0,signi(delta.y))
    done = game.hero_action(selected,shove_target,dir)
  elif f in [1,7,12,15,19,34,35,36,37,38,39,40,41,55,58]: done = game.hero_action(selected,target)
  if done: selected = -1; shove_target = -1; hint = "Choose another die, or end this hero’s turn."
  else:
   hint = explain_invalid(f,target,c)
   game.record_event("invalid",game.unit_name(game.active)+" cannot resolve "+Model.FACES[f]+" there; no effect and the die remains available.",game.active)
  rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  selected = -1; shove_target = -1; show_options = false; show_help = false; inspect_action = ""; show_history = false; show_changes = false; show_dice = false; show_turn = false; show_lab_setup = false; rebuild()

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,Vector2(1440,900)),Color("10151e"))
 if page == "battle": draw_texture_rect(BACKDROP,Rect2(0,0,1440,900),false,Color(0.16,0.20,0.24,0.35))
 for i in range(28):
  var p := Vector2(fmod(i*131.73,1400.0),fmod(i*79.37+t*3,900.0))
  draw_circle(p,1.2,Color(0.8,0.6,0.35,0.16+sin(t+i)*0.08))
 draw_line(Vector2(42,92),Vector2(1346,92),Color("303846"))
 if page == "forge":
  panel(Rect2(68,351,736,336)); panel(Rect2(850,278,472,563))
  for d in range(3):
   draw_line(Vector2(150,452+d*111),Vector2(781,452+d*111),Color("2b3542"))
 else:
  panel(Rect2(610,95,420,90),Color("182632"),Color("354653"))
  panel(Rect2(610,190,420,157),Color("18212c"),Color("354653"))
  if game.active == 3: panel(Rect2(610,190,420,605),Color("18212c"),Color("354653"))
  if game.active < 3: panel(Rect2(610,350,420,445),Color("1b2935"),Color("354653"))
  panel(Rect2(1050,190,330,690),Color("14212c"),Color("354653"))
  var turn_color: Color = Color("ed9986") if game.active == 3 else COLORS[maxi(0,game.active)]
  panel(Rect2(74,145,496,39),Color("29333e"),turn_color)
  for i in range(3): panel(Rect2(68+i*183,780,178,107),Color("202d37") if i == game.active else Color("161d28"),COLORS[i] if i == game.active else Color("303a48"))
  draw_board()
  draw_effects()

func draw_board() -> void:
 draw_texture_rect(BACKDROP,Rect2(35,199,575,575),false)
 var highlights: Array = []
 if selected >= 0 and game.active < 3 and game.pending.is_empty():
  var f: int = game.face(game.active,selected)
  if f in [2,3,54] or (f == 0 and game.reward and not game.heroes[game.active].soul_move_used): highlights = game.reachable(game.active,3 if f == 3 else (2 if f == 0 else 1),f == 3)
  if f == 53: highlights = game.leap_cells(game.active)
  if f == 57: highlights = game.reachable(game.active,2,false)
  if Catalog.is_attack(f) or f in [7,12,15,19,55,58]:
   var reach := 3 if f in [15,19,58] else (2 if f == 35 else (99 if f == 12 else 1))
   for target in range(4):
    if target < 3 and game.heroes[target].dead:continue
    if target == game.active and f not in [7,12,55]:continue
    if not Catalog.is_attack(f) and target == 3:continue
    if f == 58 and game.heroes[target].hp <= 0:continue
    if game.distance(game.active,target) > reach:continue
    if f in [15,19,35,58] and not game.sight(game.active,target,reach):continue
    highlights.append_array(game.cells(target))
 for y in range(9):
  for x in range(9):
   var c := Vector2i(x,y); var p := ORIGIN+Vector2(c)*CELL
   var col := Color("222b34") if (x+y)%2 == 0 else Color("1d2630")
   if c in game.cells(3): col = Color("382d37")
   if c in highlights: col = Color("365550")
   if c in game.brand_cells: col = Color("663e31")
   var opacity := 0.48 if c in highlights or c in game.brand_cells else (0.22 if c in game.cells(3) else 0.06)
   draw_rect(Rect2(p,Vector2.ONE*CELL),Color(col,opacity))
   draw_rect(Rect2(p,Vector2.ONE*CELL),Color(0.75,0.79,0.80,0.24),false,1)
   if c in highlights: draw_circle(p+Vector2.ONE*CELL/2,3,Color("82c5b0"))
   if c in game.brand_cells:
    draw_rect(Rect2(p+Vector2.ONE*4,Vector2.ONE*(CELL-8)),Color("f0a17b"),false,2)
    draw_line(p+Vector2(19,19),p+Vector2(36,36),Color("f0a17b"),2)
    draw_line(p+Vector2(36,19),p+Vector2(19,36),Color("f0a17b"),2)
   if c == hover: draw_rect(Rect2(p+Vector2.ONE*2,Vector2.ONE*(CELL-4)),Color(GOLD,0.5),false,1)
 for i in range(9):
  draw_string(BODY,ORIGIN+Vector2(i*CELL+23,-10),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
  draw_string(BODY,ORIGIN+Vector2(-20,i*CELL+32),char(65+i),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
 # Portrait tokens use the same art as the party panels and drafting tabs.
 var bp: Vector2 = ORIGIN+Vector2(visual_positions.get(3,Vector2(game.boss.pos)))*CELL+Vector2.ONE*CELL+attack_nudge(3)
 draw_circle(bp+Vector2(0,26),43,Color(0.02,0.02,0.04,0.65))
 draw_portrait(3,Rect2(bp-Vector2.ONE*45,Vector2.ONE*90))
 draw_rect(Rect2(bp-Vector2.ONE*45,Vector2.ONE*90),Color("b18c79"),false,2)
 for i in range(3):
  var h: Dictionary = game.heroes[i]
  if h.dead: continue
  var p := ORIGIN+Vector2(visual_positions.get(i,Vector2(h.pos)))*CELL+Vector2.ONE*CELL/2
  p += attack_nudge(i)
  var glow: float = channel_glows.get(i,0.0)
  if glow > 0:
   var channel: Dictionary = h.channel
   var ch_face: int = channel.get("face",0)
   var col := Color("86bded") if ch_face == 31 else (Color("8be0ad") if ch_face == 49 else Color("d7a2ed"))
   for ring in range(2):draw_arc(p,29+ring*5,sin(t)*0.05+t*(0.35 if ring == 0 else -0.25),TAU+t*(0.35 if ring == 0 else -0.25),64,Color(col,glow*0.8),2,true)
   for rune in range(6):
    var at := p+Vector2.from_angle(rune*TAU/6+t*0.45)*33
    draw_line(at+Vector2(-3,-3),at+Vector2(3,3),Color(col,glow),2,true)
   draw_string(BODY,p+Vector2(-45,44),Model.FACES[ch_face] if ch_face > 0 else "Channel ended",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color(col,glow))
  if game.active == i:
   draw_arc(p,26,0,TAU,64,Color(COLORS[i],0.8+sin(t*2)*0.15),3)
   draw_colored_polygon(PackedVector2Array([p+Vector2(-7,-42),p+Vector2(7,-42),p+Vector2(0,-32)]),COLORS[i])
   draw_string(BODY,p+Vector2(-24,-49),"TURN",HORIZONTAL_ALIGNMENT_LEFT,-1,12,COLORS[i])
  draw_circle(p,19,Color("111923")); draw_arc(p,19,0,TAU,48,COLORS[i],2)
  if h.hp == 0:
   draw_line(p+Vector2(-8,-8),p+Vector2(8,8),COLORS[i],3); draw_line(p+Vector2(8,-8),p+Vector2(-8,8),COLORS[i],3)
  else:
   draw_portrait(i,Rect2(p-Vector2.ONE*18,Vector2.ONE*36))
   draw_rect(Rect2(p-Vector2.ONE*18,Vector2.ONE*36),COLORS[i],false,1.5)
  for hp in range(6): draw_rect(Rect2(p+Vector2(-18+hp*6,24),Vector2(4,3)),COLORS[i] if hp < h.hp else Color("3d434b"))

func sync_presentation() -> void:
 if page != "battle": return
 for event in game.event_log:
  if event.id <= seen_event: continue
  seen_event = event.id
  if event.kind in ["attack","block","block_gain","buff","debuff","heal"]:
   var kind: String = event.kind
   if kind == "block_gain": kind = "block"
   if event.target >= 0:
    effects.append({"kind":kind,"source":event.source,"target":event.target,"life":1.05,"length":1.05})
 if roll_seen > game.roll_presentations.size(): roll_seen = 0
 # Model rolls remain recorded in the event log; results appear instantly.
 roll_seen = game.roll_presentations.size()
 rolling_time = 0
 seen_roll = game.roll_serial
 for id in range(4):
  var h: Dictionary = game.boss if id == 3 else game.heroes[id]
  if not visual_positions.has(id): visual_positions[id] = Vector2(h.pos)
  if snapshots.has(id):
   var old: Dictionary = snapshots[id]
   var diff: int = h.hp-old.hp
   var bd: int = h.block-old.block
   var at: Vector2 = ORIGIN+Vector2(h.pos)*CELL+Vector2.ONE*CELL*(1.0 if id == 3 else 0.5)
   if diff != 0:
    floaters.append({"at":at,"text":("+" if diff > 0 else "")+str(diff)+" HP","color":Color("85d2ab") if diff > 0 else Color("f19581"),"life":1.6})
    if diff < 0: hit_time = 0.7
   elif bd < 0: floaters.append({"at":at,"text":str(bd)+" BLOCK","color":Color("95c8ee"),"life":1.6})
   if bd > 0: floaters.append({"at":at,"text":"+"+str(bd)+" BLOCK","color":Color("95c8ee"),"life":1.6})
  if id < 3 and snapshots.has(id) and snapshots[id].get("channel",0) > 0 and h.channel.is_empty():
   effects.append({"kind":"debuff","source":id,"target":id,"life":1.05,"length":1.05})
  snapshots[id] = {"hp":h.hp,"block":h.block,"channel":h.channel.get("face",0) if id < 3 else 0}

func history_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color(0.02,0.03,0.05,0.96); shade.size = Vector2(1440,900); ui.add_child(shade)
 var box := Panel.new(); box.position = Vector2(175,101); box.size = Vector2(1090,700); box.add_theme_stylebox_override("panel",style(Color("18212c"),GOLD)); ui.add_child(box)
 label_at("BATTLE CHRONICLE",Vector2(212,126),26,GOLD,800,true)
 label_at("In order: actor → ability → target → mitigation → actual result",Vector2(214,172),13,MUTED,900)
 var filter := OptionButton.new(); filter.position = Vector2(1003,131); filter.size = Vector2(218,38)
 for name in ["All","Combat","Turns"]: filter.add_item(name)
 filter.select(["All","Combat","Turns"].find(log_filter)); filter.item_selected.connect(func(index): log_filter = ["All","Combat","Turns"][index]; rebuild()); ui.add_child(filter)
 var lines := RichTextLabel.new(); lines.bbcode_enabled = true; lines.position = Vector2(214,215); lines.size = Vector2(1004,484); lines.add_theme_font_size_override("normal_font_size",15); lines.scroll_following = true
 var text_lines: Array[String] = []
 for entry in game.event_log:
  if log_filter == "Combat" and entry.kind not in ["action","attack","damage","block","block_gain","heal","buff","debuff","expire","mutation","retarget","collision","stun","decline"]: continue
  if log_filter == "Turns" and entry.kind not in ["turn","round","roll"]: continue
  text_lines.append(format_event(entry,true))
 lines.text = "\n\n".join(text_lines); ui.add_child(lines)
 button("Copy log",Vector2(215,734),Vector2(208,40),func(): DisplayServer.clipboard_set("\n".join(game.log_lines)),MUTED)
 button("Back to battle",Vector2(943,730),Vector2(279,45),func(): show_history = false; show_changes = false; show_dice = false; show_turn = false; show_lab_setup = false; rebuild())

func format_event(entry: Dictionary, expanded: bool) -> String:
 var colors := {"attack":"efb29b","damage":"eea394","block":"9fc7e6","block_gain":"9fc7e6","buff":"91d1b4","debuff":"c9a4e3","heal":"91d1b4","turn":"e4c88f","round":"e4c88f","expire":"9aaaba"}
 var color: String = colors.get(entry.kind,"becad3")
 var tag: String = "R%02d · #%03d · %s" % [entry.round,entry.id,entry.kind.replace("_"," ").to_upper()]
 return "[color=#%s][b]%s[/b][/color]%s%s" % [color,tag,"\n" if expanded else "  ",entry.text.replace("[","[lb]")]

func effect_center(id: int) -> Vector2:
 if id < 0: return Vector2(322,150)
 var pos: Vector2 = visual_positions.get(id,Vector2(game.boss.pos if id == 3 else game.heroes[id].pos))
 return ORIGIN+pos*CELL+Vector2.ONE*CELL*(1.0 if id == 3 else 0.5)

func draw_effects() -> void:
 for fx in effects:
  var p: Vector2 = effect_center(fx.target)
  var progress: float = 1.0-fx.life/fx.length
  var alpha: float = smoothstep(0.0,0.15,progress)*(1.0-smoothstep(0.5,1.0,progress))
  progress = smoothstep(0.0,1.0,progress)
  match fx.kind:
   "attack":
    var start: Vector2 = effect_center(fx.source)
    var end: Vector2 = start.lerp(p,minf(1,progress*3))
    draw_line(start,end,Color(0.95,0.72,0.5,alpha),2.5,true)
    draw_line(p+Vector2(-20,-20)*(0.5+progress),p+Vector2(20,20)*(0.5+progress),Color(1,0.77,0.58,alpha),4,true)
    draw_line(p+Vector2(-14,18)*(0.5+progress),p+Vector2(14,-18)*(0.5+progress),Color(1,0.9,0.75,alpha*0.7),2,true)
   "block":
    var shield := PackedVector2Array([p+Vector2(-19,-20),p+Vector2(19,-20),p+Vector2(18,3),p+Vector2(0,24),p+Vector2(-18,3)])
    draw_colored_polygon(shield,Color(0.35,0.65,0.9,alpha*0.25)); draw_polyline(shield+PackedVector2Array([shield[0]]),Color(0.6,0.85,1,alpha),2,true)
    draw_arc(p,27+progress*12,0,TAU,48,Color(0.6,0.85,1,alpha*0.65),1.5)
   "buff","heal":
    draw_arc(p,24+progress*8,0,TAU,48,Color(0.5,0.9,0.7,alpha),2)
    for n in range(5):
     var q := p+Vector2(-18+n*9,10-progress*43+sin(n)*4)
     draw_line(q+Vector2(-3,0),q+Vector2(3,0),Color(0.65,1,0.8,alpha),1.8)
     draw_line(q+Vector2(0,-3),q+Vector2(0,3),Color(0.65,1,0.8,alpha),1.8)
   "debuff":
    draw_arc(p,27,progress*4,progress*4+TAU*0.8,40,Color(0.8,0.45,0.9,alpha),2.5)
    for n in range(4):
     var q := p+Vector2.from_angle(n*TAU/4+progress*2)*(20+progress*12)
     draw_line(q,q+Vector2(0,11),Color(0.9,0.5,0.9,alpha),2)
 for f in floaters:
  draw_string(BODY,f.at+Vector2(-30,-20-(1.6-f.life)*35),f.text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color(f.color,minf(1,f.life)))
 if hit_time > 0:
  for id in game.last_targets:
   var p := ORIGIN+Vector2(game.heroes[id].pos)*CELL+Vector2.ONE*CELL/2
   draw_arc(p,23+(0.7-hit_time)*30,0,TAU,32,Color(0.95,0.5,0.35,hit_time),2)

func color_for_face(f: int) -> Color:
 if f < 9: return FACE_COLORS[f]
 match Catalog.category(f):
  "Attack": return FACE_COLORS[1]
  "Movement": return FACE_COLORS[2]
  "Defense": return FACE_COLORS[4]
  "Penalty": return Color("d87870")
 return FACE_COLORS[6]

func make_offers() -> void:
 offers = [Catalog.extended_ids(),Catalog.extended_ids(),Catalog.extended_ids()]

func choose_gift(id: int) -> void:
 if id not in Catalog.extended_ids(): return
 if id in gifts[build_hero]: gifts[build_hero].erase(id)
 elif gifts[build_hero].size() < 2: gifts[build_hero].append(id)
 inspected_gift = id
 rebuild()

func confirm_gifts() -> void:
 var legal: Array = Model.bonus_build(gifts[build_hero])
 if legal.is_empty(): return
 builds[build_hero] = legal
 var next := -1
 for i in range(3):
  if gifts[i].size() != 2: next = i; break
 if next >= 0: build_hero = next; draft_search = ""; draft_scroll = 0
 else: draft_modal = false
 rebuild()

func draft_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("101922"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("BUILD YOUR INHERITANCE · v0.9",Vector2(60,30),30,GOLD,900,true)
 label_at("Pick two bonus faces per hero. Click a card to inspect; use Add / Remove on the right.",Vector2(62,76),16,MUTED,1250)
 button("Back to forge",Vector2(1150,30),Vector2(230,42),func(): draft_modal = false; rebuild(),MUTED)
 for hero in range(3):
  button(["VESPER","ROOK","WREN"][hero]+"  ·  %d/2" % gifts[hero].size(),Vector2(60+hero*292,113),Vector2(280,44),func(): build_hero = hero; draft_scroll = 0; rebuild(),COLORS[hero] if build_hero == hero else MUTED)
 for hero in range(3):portrait_at(hero,Vector2(70+hero*292,120),Vector2(30,30))
 var search := LineEdit.new(); search.name = "GiftSearch"; search.placeholder_text = "Search ability names…"; search.text = draft_search; search.position = Vector2(60,178); search.size = Vector2(360,42); ui.add_child(search)
 search.text_changed.connect(func(value):
  draft_search = value; draft_scroll = 0; rebuild()
  var field = ui.get_node("GiftSearch");field.grab_focus();field.caret_column = value.length())
 var filter := OptionButton.new(); filter.name = "GiftCategory"; filter.position = Vector2(434,178); filter.size = Vector2(225,42)
 for cat in ["All","Attack","Defense","Movement","Skill"]: filter.add_item(cat)
 filter.select(["All","Attack","Defense","Movement","Skill"].find(draft_category))
 filter.item_selected.connect(func(index): draft_category = ["All","Attack","Defense","Movement","Skill"][index];draft_scroll = 0;rebuild());ui.add_child(filter)
 var timing_filter := OptionButton.new();timing_filter.name = "GiftTiming";timing_filter.position = Vector2(673,178);timing_filter.size = Vector2(251,42)
 for value in ["All timings","Action","Reaction","Channel"]:timing_filter.add_item(value)
 timing_filter.select(["All timings","Action","Reaction","Channel"].find(draft_timing))
 timing_filter.item_selected.connect(func(index):draft_timing = ["All timings","Action","Reaction","Channel"][index];draft_scroll = 0;rebuild());ui.add_child(timing_filter)
 var scroll := ScrollContainer.new();scroll.name = "GiftCards";scroll.position = Vector2(60,240);scroll.size = Vector2(864,522);ui.add_child(scroll)
 var saved_scroll := draft_scroll
 scroll.get_v_scroll_bar().value_changed.connect(func(value):draft_scroll = int(value))
 scroll.set_deferred("scroll_vertical",saved_scroll)
 var cards := GridContainer.new();cards.columns = 2;cards.add_theme_constant_override("h_separation",12);cards.add_theme_constant_override("v_separation",12);scroll.add_child(cards)
 var count := 0
 for id in Catalog.extended_ids():
  if draft_category != "All" and Catalog.category(id) != draft_category:continue
  if draft_timing != "All timings" and Catalog.timing(id) != draft_timing:continue
  if draft_search != "" and not Model.FACES[id].to_lower().contains(draft_search.to_lower()):continue
  count += 1
  var chosen: bool = id in gifts[build_hero]
  var card := Button.new();card.name = "Face"+str(id);card.text = Model.FACES[id]+"\n("+Catalog.classification(id)+")\n"+("SELECTED" if chosen else "Inspect ability")
  card.custom_minimum_size = Vector2(414,105);card.alignment = HORIZONTAL_ALIGNMENT_LEFT;card.add_theme_font_size_override("font_size",16)
  card.add_theme_color_override("font_color",color_for_face(id));card.add_theme_stylebox_override("normal",style(Color("2b3c47") if inspected_gift == id else Color("1a2732"),GOLD if chosen else (color_for_face(id) if inspected_gift == id else Color("354653"))))
  card.add_theme_stylebox_override("hover",style(Color("304351"),color_for_face(id)));card.tooltip_text = face_help(id)
  card.pressed.connect(func():inspected_gift = id;rebuild());cards.add_child(card)
 if count == 0:label_at("No matching abilities. Try different filters.",Vector2(85,285),19,MUTED,800)
 label_at("%d abilities · starter faces excluded" % count,Vector2(65,775),13,MUTED,850)
 var detail_box := Panel.new();detail_box.position = Vector2(950,113);detail_box.size = Vector2(430,649);detail_box.add_theme_stylebox_override("panel",style(Color("1a2732"),Color("43515d")));ui.add_child(detail_box)
 label_at(Model.FACES[inspected_gift],Vector2(976,145),26,color_for_face(inspected_gift),378,true,true)
 label_at("("+Catalog.classification(inspected_gift)+")",Vector2(976,216),17,GOLD,378)
 var detail := RichTextLabel.new();detail.name = "GiftDetail";detail.position = Vector2(976,259);detail.size = Vector2(378,225);detail.add_theme_font_size_override("normal_font_size",18);detail.text = face_help(inspected_gift);ui.add_child(detail)
 label_at(Catalog.readiness(inspected_gift),Vector2(976,502),12,MUTED,378)
 var selected_names: Array[String] = []
 for id in gifts[build_hero]:selected_names.append(Model.FACES[id])
 label_at("YOUR TWO FACES\n"+(" · ".join(selected_names) if not selected_names.is_empty() else "None selected yet"),Vector2(976,548),15,GOLD,378,false,true)
 var chosen: bool = inspected_gift in gifts[build_hero]
 button("Remove this face" if chosen else ("Add this face" if gifts[build_hero].size() < 2 else "Two selected · remove one first"),Vector2(976,675),Vector2(378,52),func():choose_gift(inspected_gift),color_for_face(inspected_gift),not chosen and gifts[build_hero].size() >= 2)
 button("Confirm hero’s two faces →",Vector2(950,797),Vector2(430,52),confirm_gifts,GOLD,gifts[build_hero].size() != 2)
 button("Guided practice",Vector2(60,810),Vector2(260,42),start_training,Color("82c8b9"))
 button("Game options",Vector2(335,810),Vector2(260,42),open_settings,MUTED)

func catalog_pending_ui(p: Dictionary) -> void:
 if p.kind == "slot":
  label_at("Choose a Blank slot · " + Model.FACES[p.face],Vector2(390,290),22,GOLD,620,true)
  label_at("Choose exactly where the new face is installed. Grey slots are unavailable.",Vector2(390,340),13,MUTED,590,false,true)
  for d in range(3):
   for side in range(6):
    var f: int = game.heroes[p.target].build[d][side]
    button(str(d+1)+" · "+Model.FACES[f],Vector2(377+side*101,390+d*58),Vector2(95,48),func(): game.choose_slot(d,side); selected = -1; rebuild(),color_for_face(f),f != 0).add_theme_font_size_override("font_size",10)
 elif p.kind == "channel":
  var ch: Dictionary = game.heroes[p.hero].channel
  label_at("CHANNEL · " + Model.FACES[ch.face],Vector2(390,299),23,GOLD,600,true)
  label_at(face_help(ch.face),Vector2(390,352),15,MUTED,550,false,true)
  button("Maintain Channel",Vector2(399,524),Vector2(250,49),func(): game.channel_choice(true); rebuild())
  button("End and roll this die",Vector2(669,524),Vector2(280,49),func(): game.channel_choice(false); rebuild())
 elif p.kind == "ember":
  label_at("Ember Burst · Block to burn?",Vector2(390,299),23,GOLD,600,true)
  label_at("Each point burned damages ALL adjacent units, including allies.",Vector2(390,358),14,MUTED,550,false,true)
  for n in range(3): button(str(n)+" Block",Vector2(399+n*181,450),Vector2(167,49),func(): game.ember(n); rebuild(),GOLD,n > game.heroes[p.hero].block)
 elif p.kind == "bind":
  label_at("Lethargic Bind · choose a boss face",Vector2(390,299),23,GOLD,620,true)
  for d in range(3):
   for side in range(6):
    var action: String = game.boss_dice()[d][side]
    button(str(d+1)+" · "+action,Vector2(377+side*101,379+d*70),Vector2(95,58),func(): game.choose_bind(d,action); rebuild(),GOLD).add_theme_font_size_override("font_size",10)
 else:
  label_at(Model.FACES[p.face] + " · Choose a die",Vector2(390,298),22,GOLD,620,true)
  label_at("Skip an unresolved die first; then choose a spent immediate face." if p.face == 23 else ("Choose the installed ability on the Blank die you selected." if p.face == 26 and p.stage == 1 else "Choose an eligible source; unavailable choices are grey."),Vector2(390,343),13,MUTED,570,false,true)
  if p.face == 16 or (p.face == 26 and p.stage == 1):
   for d in range(3):
    for side in range(6):
     var f: int = game.heroes[p.hero].build[d][side]
     button(str(d+1)+" · "+Model.FACES[f],Vector2(377+side*101,390+d*58),Vector2(95,48),func():
      if game.catalog_pick(p.hero,d,side): selected = game.forced_die
      rebuild(),color_for_face(f),not choice_eligible(p,p.hero,d,side)).add_theme_font_size_override("font_size",10)
  else:
   for hero in range(3):
    for d in range(3):
     var h: Dictionary = game.heroes[hero]
     if h.results.is_empty(): continue
     var f: int = game.face(hero,d)
     button(h.name+" "+str(d+1)+" · "+Model.FACES[f],Vector2(387+d*202,390+hero*58),Vector2(195,48),func():
      if game.catalog_pick(hero,d): selected = game.forced_die
      rebuild(),color_for_face(f),not choice_eligible(p,hero,d)).add_theme_font_size_override("font_size",10)
  button("Spend with no effect",Vector2(399,593),Vector2(520,42),func(): game.pending = {}; game.decline(p.die); selected = -1; rebuild(),MUTED)

func attack_nudge(id: int) -> Vector2:
 for fx in effects:
  if fx.kind == "attack" and fx.source == id:
   var from := effect_center(id)
   var to := effect_center(fx.target)
   return from.direction_to(to)*8*sin((1.0-fx.life/fx.length)*PI)
 return Vector2.ZERO


func start_lab() -> void:
 training = false
 lab = true; draft_modal = false; show_help = false; show_changes = false; inspect_action = ""; show_history = false; show_dice = false; show_turn = false
 reset_lab()

func reset_lab() -> void:
 game = Lab.create(lab_face,lab_numeric)
 game.reward = reward_soul
 if lab_support != 34:
  game.heroes[0].build[1][0] = lab_support; game.heroes[0].results[1] = lab_support;game.heroes[0].used[1] = Catalog.is_reaction(lab_support)
  game.heroes[0].reaction.erase(1)
  if Catalog.is_reaction(lab_support): game.heroes[0].reaction.append(1)
  game.on_roll(game.heroes[0],1)
 page = "battle"; selected = -1; shove_target = -1; effects.clear(); floaters.clear(); snapshots.clear(); visual_positions.clear(); movement_tracks.clear(); seen_event = game.event_id; seen_roll = game.roll_serial; roll_seen = game.roll_presentations.size(); rolling_time = 0
 hint = Lab.guide(lab_face)
 rebuild()

func lab_ui() -> void:
 # A persistent strip replaces party cards only in the isolated testing arena.
 var cover := ColorRect.new(); cover.position = Vector2(67,774); cover.size = Vector2(540,126); cover.color = Color("16232d"); ui.add_child(cover)
 button("Roll chosen face again",Vector2(630,864),Vector2(235,30),func(): Lab.roll_test_face(game,lab_face,lab_numeric); selected = -1; rebuild(),Color("82c8b9"),not game.pending.is_empty() or game.outcome != "")
 button("Combine faces",Vector2(870,864),Vector2(150,30),func(): show_lab_setup = true; rebuild(),MUTED)
 if training: button("Next lesson →" if training_step < LESSON_FACES.size()-1 else "Play preset →",Vector2(870,864),Vector2(150,30),next_lesson,GOLD,not lesson_done())
 label_at("LAB · Vesper %d/6 HP · %d Block · %s" % [game.heroes[0].hp,game.heroes[0].block,Model.FACES[lab_face]],Vector2(77,780),12,Color("82c8b9"),520)
 var picker := OptionButton.new(); picker.name = "LabAbilities"; picker.position = Vector2(77,806); picker.size = Vector2(315,35)
 for id in range(59): picker.add_item(Catalog.display_name(id),id)
 picker.select(lab_face); picker.item_selected.connect(func(index): training = false; lab_face = index; reset_lab()); ui.add_child(picker)
 var num := OptionButton.new(); num.position = Vector2(403,806); num.size = Vector2(186,35)
 for title in ["Numeric: random","Numeric: force 0","Numeric: force 1"]: num.add_item(title)
 num.select(lab_numeric+1); num.item_selected.connect(func(index): lab_numeric = index-1; reset_lab()); ui.add_child(num)
 button("Reset test",Vector2(77,850),Vector2(125,35),reset_lab)
 button("Boss hits",Vector2(210,850),Vector2(110,35),func(): Lab.attack(game,lab_face); selected = -1; rebuild(),Color("ed9986"),not game.pending.is_empty() or game.outcome != "")
 button("Next turn",Vector2(328,850),Vector2(115,35),func(): Lab.next_turn(game,lab_numeric); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 button("Copy test log",Vector2(451,850),Vector2(138,35),func(): DisplayServer.clipboard_set("Ash & Oath v0.4 · Ability: "+Model.FACES[lab_face]+"\n"+"\n".join(game.log_lines)),MUTED)

func changes_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("101923"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("PATCH NOTES · v0.9",Vector2(125,75),32,GOLD,1200,true)
 label_at("Choose a topic · short pages · what changed and why",Vector2(128,125),15,MUTED,1100)
 var nav_step := minf(75,610.0/Changes.SECTIONS.size())
 for i in range(Changes.SECTIONS.size()):
  button(Changes.SECTIONS[i].title,Vector2(125,190+i*nav_step),Vector2(255,minf(58,nav_step-8)),func(): changes_page = i; rebuild(),GOLD if i == changes_page else MUTED)
 var section: Dictionary = Changes.SECTIONS[changes_page]
 label_at(section.title,Vector2(420,190),28,GOLD,880,true)
 var text := RichTextLabel.new(); text.name = "ChangeLog"; text.bbcode_enabled = true; text.position = Vector2(420,250); text.size = Vector2(880,455); text.add_theme_font_size_override("normal_font_size",20); text.text = section.body; ui.add_child(text)
 button("← Previous",Vector2(420,735),Vector2(200,46),func(): changes_page -= 1; rebuild(),MUTED,changes_page == 0)
 label_at("Page %d / %d" % [changes_page+1,Changes.SECTIONS.size()],Vector2(675,747),16,GOLD,200)
 button("Next →",Vector2(865,735),Vector2(200,46),func(): changes_page += 1; rebuild(),GOLD,changes_page == Changes.SECTIONS.size()-1)
 button("Back to game",Vector2(1080,800),Vector2(225,48),func(): show_changes = false; rebuild())


func choice_eligible(p: Dictionary, hero: int, d: int, side: int = -1) -> bool:
 var h: Dictionary = game.heroes[hero]
 var f: int = game.face(hero,d)
 if p.face == 11: return h.hp > 0 and not h.dead and Catalog.can_copy(f)
 if hero != p.hero: return false
 if p.face == 16: return d != p.die and not h.used[d] and side >= 0 and h.build[d][side] != 56
 if p.face == 26:
  if p.stage == 0: return d != p.die and not h.used[d] and f == 0 and h.build[d].any(func(id):return id > 0 and id not in [11,16,23,24,26,56])
  return d == p.convert_die and side >= 0 and h.build[d][side] > 0 and h.build[d][side] not in [11,16,23,24,26,56]
 if p.face == 23:
  if p.stage == 0: return d != p.die and not h.used[d] and f != 0
  return h.used[d] and d not in [p.die,p.get("skipped",-1)] and Catalog.can_copy(f)
 if p.face == 30: return d != p.die and not h.used[d] and (Catalog.is_attack(f) or f in [4,42,43,50,51,52])
 if p.face == 32: return d != p.die and not h.used[d] and f in [2,3,4]
 return false


func turn_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("101923"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("HOW THIS TURN WORKS",Vector2(125,80),32,GOLD,1200,true)
 var actor: String = game.unit_name(game.active)
 label_at("ROUND %d · %s" % [game.round_no,actor],Vector2(130,145),22,GOLD,1100)
 var text := RichTextLabel.new(); text.name = "TurnGuide"; text.bbcode_enabled = true; text.position = Vector2(130,210); text.size = Vector2(1175,480); text.add_theme_font_size_override("normal_font_size",21)
 text.text = "[b]"+actor+" is acting now.[/b]\n\n"+game.turn_explanation()+"\n\n[b]What to do next[/b]\n"
 if not game.pending.is_empty(): text.text += "Finish the open choice / reaction window first. It pauses the attack or turn; no other action can resolve until that decision is complete."
 elif game.active == 3:
  text.text += ("Resolve boss die %s: %s.\n%s" % [["I","II","III"][game.boss_index],game.boss_rolls[game.boss_index],game.boss_help(game.boss_rolls[game.boss_index])]) if game.boss_index < 3 else "All three boss dice are finished. Click Resolve end of turn to move to the next hero."
 else:
  var h: Dictionary = game.heroes[game.active]
  text.text += "Choose a bright, unspent die. Its description appears above the action panel. Movement needs an empty highlighted cell; attacks and healing need a legal unit; setup effects use Resolve. Grey dice are spent, held as reactions or channelled. You may End turn without using every die."
  if game.reward: text.text += "\n\nReward Soul: " + ("0/1" if h.soul_move_used else "1/1") + " Blank-to-Move-2 conversions remain this hero turn.\n"
  text.text += "\n\nReroll window: " + ("OPEN" if h.opening else "CLOSED after your first ordinary resolution") + " · saved charges: " + str(h.rerolls) + ". A starting charge does not refill each round."
 text.text += "\n\n[b]Between turns[/b]\nInitiative stays fixed for this encounter. New round = everyone rolls available dice together. Your next turn start clears old Block and temporary defenses; Channels can pause for maintain / release. HP damage, mitigation and expiry are recorded in the chronicle."
 ui.add_child(text)
 button("Understood · back to turn",Vector2(945,790),Vector2(360,48),func(): show_turn = false; rebuild())

func dice_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("101923"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("VIEW DICE · LIVE FACE INVENTORY",Vector2(125,60),30,GOLD,1200,true)
 label_at("Choose a unit. Click any side for its effect. Gold = changed this fight; blue = current rolled side.",Vector2(130,110),15,MUTED,1200)
 for hero in range(4):
  button(["VESPER","ROOK","WREN","THE HOLLOW"][hero],Vector2(130+hero*300,150),Vector2(280,42),func(): dice_hero = hero; dice_inspected = Vector2i.ZERO; rebuild(),GOLD if dice_hero == hero else MUTED,hero == 3 and page != "battle")
 var in_fight := page == "battle"
 var is_boss := dice_hero == 3
 for d in range(3):
  label_at("DIE " + ["I","II","III"][d],Vector2(130,207+d*143),13,GOLD,1100)
  for side in range(6):
   var original: String
   var current: String
   var rolled := false
   var id := 0
   if is_boss:
    current = game.boss_dice()[d][side]; original = current
    rolled = game.boss_sides.size() == 3 and game.boss_sides[d] == side
   else:
    var build: Array = game.heroes[dice_hero].build if in_fight else builds[dice_hero]
    id = build[d][side]; current = Model.FACES[id]
    original = Model.FACES[game.initial_builds[dice_hero][d][side]] if in_fight else current
    rolled = in_fight and game.heroes[dice_hero].rolls[d] == side
   var changed := current != original
   var title: String = "SIDE %d%s\n%s" % [side+1," · ROLLED" if rolled else "",current]
   if not is_boss: title += "\n(" + Catalog.classification(id) + ")"
   if changed: title += "\n★ was " + original
   var b := button(title,Vector2(130+side*199,232+d*143),Vector2(187,105),func(): dice_inspected = Vector2i(d,side); rebuild(),GOLD if changed else (Color("9fc7e6") if rolled else MUTED))
   b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; b.add_theme_font_size_override("font_size",13)
   b.tooltip_text = game.boss_help(current) if is_boss else face_help(id)
 var d: int = dice_inspected.x; var side: int = dice_inspected.y
 var info: String
 if is_boss:
  var action: String = game.boss_dice()[d][side]
  info = "DIE %s · SIDE %d · %s\n%s\nCurrent rolled result: %s" % [["I","II","III"][d],side+1,action,game.boss_help(action),game.boss_rolls[d]]
 else:
  var h: Dictionary = game.heroes[dice_hero] if in_fight else {}
  var build: Array = h.build if in_fight else builds[dice_hero]
  var id: int = build[d][side]
  info = "DIE %s · SIDE %d · %s\n%s" % [["I","II","III"][d],side+1,Catalog.display_name(id),face_help(id)]
  if in_fight:
   info += "\nRecorded roll: %s · %s. Installed sides may change while an earlier recorded result stays valid." % [Model.FACES[game.face(dice_hero,d)],"reaction held" if d in h.reaction else ("channel held" if not h.channel.is_empty() and h.channel.die == d else ("spent" if h.used[d] else "ready"))]
 label_at(info,Vector2(130,675),17,Color("d9e3eb"),1175,false,true)
 button("Back to game",Vector2(1060,815),Vector2(255,45),func(): show_dice = false; rebuild())


func explain_invalid(f: int, target: int, cell: Vector2i) -> String:
 var actor: int = game.active
 if f == 0 and game.reward and game.heroes[actor].soul_move_used: return "Soul movement already used: one Blank conversion per hero turn."
 if f in [2,3,53,54,57,0]: return "No legal path to that cell. Occupied cells block normal movement; Stride must stay straight."
 if target < 0:return "Choose a unit, not an empty cell, for this face."
 if target == actor and f not in [7,55]:return "This ability cannot target its user."
 var reach := 3 if f in [15,19,58] else (2 if f == 35 else 1)
 if game.distance(actor,target) > reach:return "Out of range: target is %d away; this face reaches %d." % [game.distance(actor,target),reach]
 if f in [15,19,35,58] and not game.sight(actor,target,reach):return "Line of sight is blocked by a unit or corner."
 if f == 58 and target < 3 and game.heroes[target].hp <= 0:return "Exchange requires a standing ally; this hero is Downed."
 return "That target is unavailable for this face. Check its description and any forced next die."


func save_preset() -> void:
 if gifts.any(func(pool):return pool.size() != 2):hint = "Choose two bonus faces per hero before saving a preset."; rebuild(); return
 for hero in range(3):
  if Model.validate(builds[hero],gifts[hero]) != "": hint = "Fix illegal builds before saving."; rebuild(); return
 var file := FileAccess.open("user://ash_build_preset.json",FileAccess.WRITE)
 if not file: hint = "Could not save preset."; rebuild(); return
 file.store_string(JSON.stringify({"builds":builds,"gifts":gifts,"balanced":balanced,"test_soul":reward_soul}));file.close()
 hint = "Saved all three heroes’ builds on this device."; rebuild()

func load_preset() -> void:
 if not FileAccess.file_exists("user://ash_build_preset.json"):hint = "No saved preset on this device yet."; rebuild(); return
 var saved = JSON.parse_string(FileAccess.get_file_as_string("user://ash_build_preset.json"))
 if not saved is Dictionary or not saved.get("builds") is Array or not saved.get("gifts") is Array or saved.builds.size() != 3 or saved.gifts.size() != 3:hint = "Preset is not valid."; rebuild(); return
 for hero in range(3):
  if not saved.builds[hero] is Array or saved.builds[hero].size() != 3 or not saved.gifts[hero] is Array:return
  for die in saved.builds[hero]:
   if not die is Array or die.size() != 6 or not die.all(func(f):return f is float or f is int):return
   for f in die:
    if int(f) < 0 or int(f) >= Model.FACES.size():return
  for die in saved.builds[hero]:
   for side in range(6):die[side] = int(die[side])
  for i in range(saved.gifts[hero].size()):saved.gifts[hero][i] = int(saved.gifts[hero][i])
  if saved.gifts[hero].size() != 2 or saved.gifts[hero][0] == saved.gifts[hero][1] or not saved.gifts[hero].all(func(id):return id in Catalog.extended_ids()) or Model.validate(saved.builds[hero],saved.gifts[hero]) != "":hint = "Preset contains an illegal build."; rebuild(); return
 builds = saved.builds;gifts = saved.gifts;balanced = saved.get("balanced",true);reward_soul = saved.get("test_soul",false);draft_modal = false
 hint = "Loaded all three heroes’ saved builds."; rebuild()

func start_training() -> void:
 training_step = 0;start_lab();training = true;prepare_lesson()

func prepare_lesson() -> void:
 lab_face = LESSON_FACES[training_step];lab_support = 34;reset_lab()
 if training_step == 6:game.reward = true
 if training_step == 7:
  game.boss_rolls = ["Cinder Brand","Brace","Strike"];game.active = 3;game.boss_index = 0;game.boss_step();game.active = 0;game.cursor = 0
 seen_event = game.event_id;rebuild()

func lesson_done() -> bool:
 if training_step == 4:return game.heroes[0].reaction.is_empty() and game.heroes[0].used[0]
 if training_step == 5:return not game.heroes[0].channel.is_empty()
 if training_step == 6:return game.heroes[0].soul_move_used
 if training_step == 7:return game.heroes[0].used[0] and game.heroes[0].pos not in game.brand_cells
 return game.heroes[0].used[0]

func next_lesson() -> void:
 if not lesson_done():return
 if training_step < LESSON_FACES.size()-1:training_step += 1;prepare_lesson()
 else:
  for hero in range(3):
   if gifts[hero].size() != 2:gifts[hero] = [19,37];builds[hero] = Model.bonus_build(gifts[hero])
  begin()

func lab_setup_ui() -> void:
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = Vector2(1440,900);ui.add_child(shade)
 label_at("LAB · COMBINE TWO ABILITIES",Vector2(160,180),30,GOLD,1100,true)
 label_at("Die I is your selected test face. Choose the result for Die II, then reset the fixture.\nThese overrides are for testing combinations; normal builds are preserved.",Vector2(165,250),18,MUTED,1100,false,true)
 var picker := OptionButton.new();picker.position = Vector2(165,355);picker.size = Vector2(800,48)
 for id in range(Model.FACES.size()):picker.add_item(Catalog.display_name(id),id)
 picker.select(lab_support);picker.item_selected.connect(func(index):lab_support = index);ui.add_child(picker)
 button("Apply and reset test",Vector2(165,460),Vector2(400,50),func(): show_lab_setup = false;reset_lab())
 button("Back",Vector2(585,460),Vector2(380,50),func():show_lab_setup = false;rebuild(),MUTED)


func soul_toggle(at: Vector2, in_lab: bool) -> void:
 var toggle := CheckButton.new();toggle.name = "TestSoulToggle"
 toggle.text = "Soul: Blank → Move 2  ·  " + ("ON" if (game.reward if in_lab else reward_soul) else "OFF") + " · 1/turn"
 toggle.position = at;toggle.size = Vector2(380 if in_lab else 430,30 if in_lab else 44)
 toggle.add_theme_font_size_override("font_size",15)
 toggle.button_pressed = game.reward if in_lab else reward_soul
 toggle.tooltip_text = "Each hero may spend ONE rolled Blank as Move 2 per own turn. Normal and recovery turns refresh it. Toggling does not refill a spent allowance."
 toggle.toggled.connect(func(enabled):
  set_soul_enabled(enabled,in_lab))
 ui.add_child(toggle)


func set_soul_enabled(enabled: bool, live: bool = true) -> void:
 reward_soul = enabled
 if live and page == "battle":
  game.reward = enabled
  game.record_event("info","Blank → Move 2 " + ("enabled: each hero may spend one Blank per turn." if enabled else "disabled: Blanks have no movement effect."))
 hint = "Blank → Move 2 is " + ("ON. Select a rolled Blank, then a highlighted cell. Once per hero turn." if enabled else "OFF. Rolled Blanks cannot be spent for movement.")
 rebuild()

func options_ui() -> void:
 overlay()
 label_at("GAME OPTIONS",Vector2(399,258),28,GOLD,600,true)
 var enabled: bool = game.reward if page == "battle" else reward_soul
 button("Blank → Move 2: " + ("ON  ·  click to turn OFF" if enabled else "OFF  ·  click to turn ON"),Vector2(399,319),Vector2(575,48),func(): set_soul_enabled(not enabled),Color("82c8b9"))
 label_at("ON: each hero can spend one rolled Blank to move up to 2 spaces per own turn.\nOFF: Blanks cannot be used for movement.\nSwitching off and on does not restore a spent use.",Vector2(399,383),17,Color("dce6ee"),575,false,true)
 button("Sound: " + ("OFF" if muted else "ON"),Vector2(399,503),Vector2(275,43),func(): muted = not muted; music.stream_paused = muted; audio.volume_db = -80 if muted else 0; rebuild(),MUTED)
 button("Audio / display settings",Vector2(689,503),Vector2(285,43),open_audio_settings,MUTED)
 button("Back to game",Vector2(399,575),Vector2(575,46),func(): show_options = false; rebuild())


func portrait_region(id: int) -> Rect2:
 var half := Vector2(PORTRAITS.get_size())/2.0
 return Rect2(Vector2(id%2,id/2)*half+Vector2(0.18,0.0)*half,half*0.74)

func draw_portrait(id: int, rect: Rect2) -> void:
 draw_texture_rect_region(PORTRAITS,rect,portrait_region(id))

func portrait_at(id: int, at: Vector2, dimensions: Vector2) -> void:
 var atlas := AtlasTexture.new();atlas.atlas = PORTRAITS;atlas.region = portrait_region(id)
 var picture := TextureRect.new();picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;picture.texture = atlas;picture.position = at;picture.size = dimensions;picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED;picture.mouse_filter = Control.MOUSE_FILTER_IGNORE;ui.add_child(picture)
