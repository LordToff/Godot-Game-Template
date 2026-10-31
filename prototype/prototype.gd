extends Control

const Balance = preload("res://prototype/balance.gd")
const AbilityCopy = preload("res://prototype/ability_copy.gd")
const BalanceEditor = preload("res://prototype/balance_editor.gd")
var balance_values: Dictionary = {}
var balance_editor: Control
var draft_error := ""
const Catalog = preload("res://prototype/catalog.gd")
const Cantor = preload("res://prototype/cantor.gd")
const CANTOR_SPRITE = preload("res://prototype/assets/pixel_cantor.png")
const CANTOR_PHASE = preload("res://prototype/assets/pixel_cantor_phase2.png")
const Nugh = preload("res://prototype/nugh.gd")
const NUGH_SPRITE = preload("res://prototype/assets/pixel_nugh.png")
const NUGH_PHASE = preload("res://prototype/assets/pixel_nugh_phase2.png")
const WORM_SPRITE = preload("res://prototype/assets/pixel_screaming_worm.png")
const DIE_Y = 205
const DIE_STEP = 98
var encounter := "hollow"
const Model = preload("res://prototype/battle.gd")
const FaceLoadout = preload("res://prototype/face_loadout.gd")
const Preset = preload("res://prototype/preset.gd")
const TITLE = preload("res://prototype/assets/body.ttf")
const BACKDROP = preload("res://prototype/assets/pixel_arena.png")
const PORTRAITS = preload("res://prototype/assets/pixel_portraits.png")
const SPRITES = preload("res://prototype/assets/pixel_units.png")
const BOSS_PHASE_TWO = preload("res://prototype/assets/pixel_boss_phase2.png")
const BODY = preload("res://prototype/assets/body.ttf")
const GOLD = Color("d5b87a")
const INK = Color("10151e")
const MUTED = Color("91a0af")
const COLORS = [Color("69c7bd"),Color("c5a5e8"),Color("edbd79")]
const FACE_COLORS = [Color("697483"),Color("df897f"),Color("6fc2b7"),Color("6fc2b7"),Color("8db7df"),Color("8db7df"),Color("c5a5e8"),Color("c5a5e8"),Color("c5a5e8")]
const SYMBOLS = ["—","/","↑","↟","◇","▣","◎","+","»"]
const ORIGIN = Vector2(40,144)
const CELL = 76.0
var game = Model.new()
var queued_hit_sound := -1
var footstep_audio: AudioStreamPlayer
var dice_tray: Control
var roll_seen := 0
var hover_key := ""
var channel_glows: Dictionary = {}
var friendly_confirm := -1
var show_training := false
var training_step := 0
var training := false
var lab_support := 34
var show_lab_setup := false
var compact_log := true
const LESSON_FACES = [2,1,4,7,5,31,0,57]
const LESSONS = ["Move: select Die I (Step), then a highlighted empty cell.","Attack: select Die I (Strike), then click the boss. Allies need a second click to confirm friendly fire.","Block: select Die I (Guard), then Resolve. Watch Block and the blue shield.","Heal: select Die I (First Aid), then an injured adjacent hero.","Reaction: press Boss hits, then choose Block + stay. This held die reacts before damage.","Channel: select Die I (Stonewake), then Resolve. Watch the persistent blue ring; Next turn opens maintain / release.","Reward Soul: select Die I (Blank), then move up to two cells. Only one Blank per hero turn may convert.","Escape danger: select Die I (Ashstep), then move outside the marked square before the next boss turn."]
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
var show_menu := false
var show_lab_tools := false
var reward_soul := false
var audio: AudioStreamPlayer
var music: AudioStreamPlayer
var muted := false
var t := 0.0
var balanced := true
var rolling_time := 0.0
var seen_roll := 0
var inspect_action := ""
var combat_inspected := -1
var inspect_actor := -1
var detailed_ability := false
var show_active_effects := false
var roll_feedback: Dictionary = {}
var combat_effects := true
var impact_time := 0.0
var impact_strength := 0.0
var combat_audio: AudioStreamPlayer
var impact_sound: AudioStreamWAV
var shield_sound: AudioStreamWAV
var scream_sound: AudioStreamWAV
var bell_sound: AudioStreamWAV
const NET = [Vector2i(1,0),Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(1,2),Vector2i(1,3)]
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
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 mouse_filter = Control.MOUSE_FILTER_PASS
 ui = Control.new(); ui.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR; ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(ui)
 var sound_controller = get_node_or_null("/root/ProjectUISoundController")
 if sound_controller and is_instance_valid(sound_controller.button_pressed_player): audio = sound_controller.button_pressed_player
 else:
  audio = AudioStreamPlayer.new(); audio.bus = &"SFX"
  if sound_controller: sound_controller.add_child(audio)
  else: add_child(audio)
 music = AudioStreamPlayer.new(); music.bus = &"Music"; music.volume_db = -22; add_child(music)
 make_audio()
 setup_combat_audio()
 load_balance_profile()
 make_offers()
 dice_tray = Tray.new();add_child(dice_tray)
 dice_tray.finished.connect(func(): rolling_time = 0;play_hit_sound(queued_hit_sound);queued_hit_sound = -1;rebuild())
 rebuild()
 if get_tree().root.has_meta("ash_restart"):
  var saved: Dictionary = get_tree().root.get_meta("ash_restart")
  get_tree().root.remove_meta("ash_restart")
  builds = saved.builds; reward_soul = saved.soul; muted = saved.muted
  encounter = saved.get("encounter","hollow");balance_values = saved.get("balance",balance_values).duplicate(true)
  balanced = saved.get("balanced",true);combat_effects = saved.get("combat_effects",true)
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
 impact_time = maxf(0.0,impact_time-delta)
 var effect_delta := 0.0 if rolling_time > 0 else delta
 hit_time = maxf(0,hit_time-effect_delta)
 for f in floaters: f.life -= effect_delta
 for fx in effects: fx.life -= effect_delta
 effects = effects.filter(func(fx):return fx.life > 0)
 floaters = floaters.filter(func(f):return f.life > 0)
 if page == "battle":
  for id in range(game.unit_count()):
   var target_pos: Vector2 = Vector2(game.unit_data(id).pos)
   if visual_positions.has(id):
    if not movement_tracks.has(id) and visual_positions[id].is_equal_approx(target_pos):continue
    if not movement_tracks.has(id) or movement_tracks[id].to != target_pos:
     movement_tracks[id] = movement_track(id,visual_positions[id],target_pos)
    var track: Dictionary = movement_tracks[id]
    var duration: float = track.duration
    var previous: float = track.elapsed/duration
    track.elapsed = minf(duration,track.elapsed+delta)
    var progress: float = track.elapsed/duration
    if previous < 1 and progress >= 1 and id < 3:
     if is_instance_valid(footstep_audio) and not muted:footstep_audio.play()
     effects.append({"kind":"landing","source":id,"target":id,"life":0.32,"length":0.32})
    var leg := minf(float(track.path.size()-1)-0.0001,progress*(track.path.size()-1))
    var segment := maxi(0,int(leg))
    var part := clampf(leg-segment,0,1)
    visual_positions[id] = track.path[segment].lerp(track.path[segment+1],smoothstep(0.0,1.0,part))
    if progress >= 1:visual_positions[id] = track.to
 rolling_time = 1.0 if dice_tray and dice_tray.busy else 0.0
 if page == "battle":
  var current_hover := inspection_at_mouse()
  if current_hover != hover_key:
   hover_key = current_hover
   rebuild()
 if page == "battle":
  for id in range(3):
   var goal := 1.0 if not game.heroes[id].channel.is_empty() and game.heroes[id].hp > 0 and not game.heroes[id].dead else 0.0
   channel_glows[id] = move_toward(float(channel_glows.get(id,0.0)),goal,delta*3)

 queue_redraw()

func movement_track(id: int, origin: Vector2, destination: Vector2) -> Dictionary:
 var start := Vector2i(origin.round());var goal := Vector2i(destination)
 var queue: Array = [[start,[]]];var visited := {start:true};var route: Array = []
 while not queue.is_empty():
  var node: Array = queue.pop_front()
  if node[0] == goal:route = node[1];break
  for direction in Model.DIRS:
   var next: Vector2i = node[0]+direction
   if not visited.has(next) and game.legal(id,next):visited[next] = true;queue.append([next,node[1]+[Vector2(next)]])
 var points: Array = [origin]
 points.append_array(route)
 if points.size() == 1:points.append(destination)
 return {"from":origin,"to":destination,"elapsed":0.0,"path":points,"duration":maxf(0.28,(points.size()-1)*0.24)}
func style(bg: Color, border: Color, radius: int = 0) -> StyleBoxFlat:
 var s := StyleBoxFlat.new(); s.bg_color = bg; s.border_color = border
 s.set_border_width_all(1); s.set_corner_radius_all(radius)
 s.content_margin_left = 12; s.content_margin_right = 12
 return s

func label_at(text: String, p: Vector2, size_px: int = 16, col: Color = Color("e2e5e9"), w: float = 600, serif: bool = false, wrap: bool = false) -> Label:
 var l := Label.new()
 if wrap: l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 l.text = text; l.position = p; l.size.x = w
 l.clip_text = not wrap
 if not wrap:l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
 l.add_theme_font_size_override("font_size",size_px); l.add_theme_color_override("font_color",col)
 if serif: l.add_theme_font_override("font",TITLE)
 ui.add_child(l); return l

func button(text: String, p: Vector2, sz: Vector2, fn: Callable, accent: Color = GOLD, disabled: bool = false) -> Button:
 var b := Button.new(); b.clip_text = true; b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS; b.text = text; b.position = p; b.size = sz; b.disabled = disabled or (page == "battle" and rolling_time > 0)
 b.add_theme_stylebox_override("normal",style(Color("1a222e"),Color(accent,0.35)))
 b.add_theme_stylebox_override("hover",style(Color("2b3543"),accent))
 b.add_theme_stylebox_override("pressed",style(Color("354050"),accent))
 b.add_theme_stylebox_override("disabled",style(Color("151b25"),Color("29303a")))
 b.add_theme_color_override("font_color",accent); b.add_theme_color_override("font_disabled_color",Color("83909d"))
 b.pressed.connect(func():
  fn.call())
 ui.add_child(b); return b

func panel(rect: Rect2, color: Color = Color("161d28"), border: Color = Color("303a48")) -> void:
 draw_style_box(style(color,border),rect)

func rebuild() -> void:
 sync_presentation()
 for c in ui.get_children(): ui.remove_child(c); c.queue_free()
 if page == "setup":
  setup_ui()
  if show_options:options_ui()
  if show_dice:dice_ui()
  return
 if page == "battle":
  label_at("ASH & OATH",Vector2(36,18),21,GOLD,205,true)

  button("View dice",Vector2(24,112),Vector2(120,26),func(): show_dice = true;dice_hero = game.active;rebuild(),Color("9fc7e6"))
  button("Turn help",Vector2(156,112),Vector2(120,26),func():show_turn = true;rebuild(),MUTED)
  button("Menu",Vector2(288,112),Vector2(120,26),func():show_menu = true;rebuild(),GOLD)
 else:
  label_at("ASH & OATH",Vector2(42,26),27,GOLD,500,true)
  label_at("A DICE-BUILDING BOSS BATTLER · v0.21.1",Vector2(44,65),11,MUTED)
  button("View dice",Vector2(350,30),Vector2(235,40),func(): show_dice = true;dice_hero = build_hero;rebuild(),Color("9fc7e6"))
  button("Tutorial / Ability Lab",Vector2(605,30),Vector2(245,40),start_lab,Color("82c8b9"))
  button("What changed",Vector2(866,30),Vector2(225,40),func():show_changes = true;rebuild())
  button("?  Rules",Vector2(1114,30),Vector2(112,40),func():show_help = true;rebuild())
  button("Options",Vector2(1236,30),Vector2(110,40),open_settings,Color("9fc7e6"))
 if page == "forge": forge_ui()
 else: battle_ui()
 if draft_modal and page == "forge": draft_ui()
 if page == "battle":
  apply_hover_inspection()
  if inspect_action != "" or combat_inspected >= 0 or show_active_effects:combat_details_ui()
 if show_history: history_ui()
 if show_help: help_ui()
 if show_changes: changes_ui()
 if show_turn: turn_ui()
 if show_dice: dice_ui()
 if show_lab_setup: lab_setup_ui()
 if show_menu: menu_ui()
 if show_lab_tools and lab and game.pending.is_empty() and game.outcome == "": lab_tools_ui()
 if show_options: options_ui()
 queue_redraw()

func forge_ui() -> void:
 label_at("Shape what remains.",Vector2(68,110),38,Color("ece6d9"),1000,true)
 label_at(hint,Vector2(70,165),16,MUTED)
 for i in range(3):
  button(("◆ " if i == build_hero else "") + ["01  VESPER","02  ROOK","03  WREN"][i],Vector2(70+i*216,215),Vector2(202,48),func(): build_hero = i; rebuild(),COLORS[i])
 label_at("THE DICE FORGE",Vector2(72,295),13,GOLD)
 label_at("Unfolded dice · click a square to edit that side.",Vector2(72,324),14,MUTED)
 for d in range(3):
  label_at("DIE " + ["I","II","III"][d],Vector2(85+d*240,342),15,GOLD,220)
  for side in range(6):
   var f: int = builds[build_hero][d][side]
   var o := OptionButton.new(); o.clip_text = true; o.position = Vector2(85+d*240,370)+Vector2(NET[side])*72; o.size = Vector2(70,70)
   o.add_theme_font_size_override("font_size",12)
   o.add_theme_icon_override("arrow",ImageTexture.new());o.alignment = HORIZONTAL_ALIGNMENT_CENTER
   o.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; o.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
   o.name = "ForgeDie%dSide%d" % [d,side]
   for id in range(9): o.add_item(Catalog.display_name(id),id)
   for id in gifts[build_hero]: o.add_item(Catalog.display_name(id),id)
   o.select(o.get_item_index(f));o.text = Model.FACES[f]; o.add_theme_stylebox_override("normal",style(Color("202938"),Color(color_for_face(f),0.55)))
   o.get_theme_stylebox("normal").content_margin_left = 4;o.get_theme_stylebox("normal").content_margin_right = 4
   o.add_theme_color_override("font_color",color_for_face(f))
   o.item_selected.connect(func(index): builds[build_hero][d][side] = o.get_item_id(index); rebuild())
   o.get_popup().min_size = Vector2i(440,0)
   o.tooltip_text = "SIDE %d · " % (side+1)+Catalog.display_name(f) + "\n" + face_help(f); ui.add_child(o)
   o.set_drag_forwarding(func(_at):return face_drag_data(o,f,d,side),func(_at,data):return face_drop_allowed(d,side,data),func(_at,data):place_dragged_face(d,side,data))
 var error := Model.validate(builds[build_hero],gifts[build_hero],balance_values)
 label_at("✓ Legal build · %d/%d ability faces" % [18-builds[build_hero].reduce(func(a,d): return a+d.count(0),0),18-3*balance_number("body.blanks")] if error == "" else error,Vector2(75,706),14,COLORS[build_hero] if error == "" else Color("ef8e87"),730)
 button("Guided practice",Vector2(350,811),Vector2(200,40),start_training,Color("82c8b9"))
 button("Save build preset",Vector2(75,811),Vector2(245,40),save_preset,MUTED)
 button("Load preset",Vector2(560,811),Vector2(220,40),load_preset,MUTED)
 soul_toggle(Vector2(350,756),false)
 button("Restore balanced build",Vector2(75,756),Vector2(245,46),restore_hero_build,MUTED)
 label_at("YOUR INHERITANCE",Vector2(886,300),13,GOLD)
 label_at("Memory   /   Empty\nSoul          /   %d HP · %d+ Blanks per die\nBody         /   Broken Body" % [balance_number("hero.hp"),balance_number("body.blanks")],Vector2(886,335),16,Color("d2d8df"))
 label_at("OWNED FACE POOL",Vector2(886,445),12,GOLD)
 label_at("%d Strike · %d Step · %d Stride\n%d Guard · %d Reaction\n%d Focus · %d First Aid · %d Shove" % [balance_number("owned.1"),balance_number("owned.2"),balance_number("owned.3"),balance_number("owned.4"),balance_number("owned.5"),balance_number("owned.6"),balance_number("owned.7"),balance_number("owned.8")],Vector2(886,474),15,MUTED)
 label_at("Two bonus designs per hero. At most %d equipped faces.\nBody caps: %d Movement, %d Defense, %d Skill.\nBlank → Move %d is " % [18-3*balance_number("body.blanks"),balance_number("body.Movement"),balance_number("body.Defense"),balance_number("body.Skill"),balance_number("soul.move")] + ("ON." if reward_soul else "OFF."),Vector2(886,559),13,MUTED)
 button("Balance: " + ("Tuned tutorial" if balanced else "Original rulebook"),Vector2(884,645),Vector2(400,35),func(): balanced = not balanced; rebuild(),GOLD)
 label_at("Boss HP %d · Strike %d · Brace %d\n%d starting Action Rerolls (cap %d).\nLocal play · three heroes · open 9×9 arena." % [balance_number("boss.hp"),balance_number("face1.damage"),balance_number("boss.brace.block"),mini(balance_number("hero.rerolls"),balance_number("hero.reroll_cap")),balance_number("hero.reroll_cap")],Vector2(886,692),13,MUTED)

 button("Bonus faces: %d / 2 · browse full pool" % gifts[build_hero].size(),Vector2(884,601),Vector2(400,35),func(): draft_modal = true; rebuild(),Color("be9bdf"))
 var legal_builds := true
 for i in range(3):
  if Model.validate(builds[i],gifts[i],balance_values) != "" or gifts[i].size() != 2: legal_builds = false
 button("Review rules & choose boss →",Vector2(884,773),Vector2(400,55),open_setup,GOLD,not legal_builds)

func retry(with_soul: bool = false) -> void:
 get_tree().root.set_meta("ash_restart", {"builds":builds.duplicate(true),"soul":with_soul or reward_soul,"muted":muted,"balanced":balanced,"combat_effects":combat_effects,"encounter":encounter,"balance":balance_values.duplicate(true),"gifts":gifts,"offers":offers})
 SceneLoader.load_scene("res://prototype/prototype.tscn")

func open_setup() -> void:
 draft_modal = false;page = "setup";show_menu = false;selected = -1;rebuild()

func begin() -> void:
 for hero in range(3):
  var error := Model.validate(builds[hero],gifts[hero],balance_values)
  if error != "":hint = error;page = "forge";rebuild();return
 training = false
 lab = false
 draft_modal = false
 roll_feedback = {};show_active_effects = false;detailed_ability = false
 game = Cantor.new() if encounter == "cantor" else (Nugh.new() if encounter == "nugh" else Model.new())
 game.start(builds,0,reward_soul,balanced,balance_values); page = "battle"; seen_roll = 0; roll_seen = 0; seen_event = 0; effects.clear(); snapshots.clear(); visual_positions.clear(); selected = -1; shove_target = -1
 hint = "Select a rolled die, then a highlighted cell or unit. Boss dice are public."
 rebuild()

func battle_ui() -> void:
 if inspect_actor != game.active:
  inspect_actor = game.active;combat_inspected = -1;inspect_action = "";show_active_effects = false;roll_feedback = {};selected = -1
 var actor: String = "ENCOUNTER ENDED" if game.outcome != "" else (game.boss_name().split(",")[0].to_upper()+"’S TURN" if game.active == 3 else game.heroes[game.active].name.to_upper()+"’S TURN")
 label_at(actor,Vector2(250,19),22,Color("f1e8cf"),360).clip_text = true
 var order_text: Array[String] = []
 for id in game.order: order_text.append(game.unit_name(id))
 label_at("ROUND %02d" % game.round_no,Vector2(622,22),14,GOLD,130).tooltip_text = "Initiative: "+" → ".join(order_text)
 var boss_title := "VEYL · BRASS CANTOR" if game.encounter_id == "cantor" else game.boss_name().to_upper()
 label_at(boss_title+(" · PHASE II" if game.phase_two else ""),Vector2(768,20),16,Color("e6c4b6"),320).clip_text = true
 label_at("%d/%d HP  ·  %d Block" % [game.boss.hp,game.boss.max_hp,game.boss.block],Vector2(1120,22),16,Color("e6c4b6"),285)
 for d in range(3):
  var action: String = game.boss_rolls[d]
  var done: bool = game.active == 3 and d < game.boss_visible_index()
  var upgraded: bool = game.phase_two and action != "Bound"
  var intent := button(["I","II","III"][d]+" · "+action+(" +" if upgraded else "")+(" ✓" if done else ""),Vector2(760+d*220,66),Vector2(208,36),func():inspect_action = action;combat_inspected = -1;show_active_effects = false;detailed_ability = false;rebuild(),GOLD if game.active == 3 and game.boss_visible_index() == d else MUTED)
  intent.add_theme_font_size_override("font_size",14);intent.tooltip_text = ""
 var threshold := int(floor(game.boss.max_hp*game.v("boss.phase.percent")/100.0))
 var phase_button := button(("PHASE II ACTIVE" if game.phase_two else "UPGRADES AT %d HP" % threshold)+" · view changes",Vector2(760,110),Vector2(328,28),func():inspect_action = "__phase__";combat_inspected = -1;show_active_effects = false;detailed_ability = false;rebuild(),Color("e8a56a") if game.phase_two else GOLD)
 label_at("%d abilities upgrade at half HP" % game.phase_upgrades().size(),Vector2(1128,115),14,Color("e8b885"),280)
 phase_button.name = "BossPhaseSummary";phase_button.add_theme_font_size_override("font_size",14);phase_button.tooltip_text = ""
 soul_toggle(Vector2(760,159),true,328)
 for i in range(3):
  var h: Dictionary = game.heroes[i];var hx := 24+i*244
  portrait_at(i,Vector2(hx+8,68),Vector2(32,32))
  var status: String = "DEAD" if h.dead else ("DOWNED" if h.hp == 0 else ("BROKEN" if h.broken else ""))
  if h.weak or h.bulwark_weak:status += " WEAK"
  if h.stun:status += " STUN"
  if h.get("rooted",0) > 0:status += " ROOT"
  if h.get("poison",0) > 0:status += " POISON"
  if h.ward:status += " WARD"
  if not h.channel.is_empty():status += " CHANNEL"
  if not h.reaction.is_empty():status += " REACTION"
  if weak_point_ready(i):status = "WEAK POINT"
  if h.dr > 0:status += " DR "+str(h.dr)
  if h.num_boost > 0:status += " NUM +"+str(h.num_boost)
  var name_label := label_at(h.name+ (" · "+status.strip_edges() if status != "" else ""),Vector2(hx+48,63),14,COLORS[i],178)
  name_label.clip_text = true;name_label.mouse_filter = Control.MOUSE_FILTER_PASS
  var dice_info: Array[String] = []
  for d in range(3):dice_info.append("Die %d: %s%s" % [d+1,Catalog.display_name(game.face(i,d))," · spent / held" if h.used[d] else ""])
  name_label.tooltip_text = h.name+"\n"+game.status_description(i)+"\n\n"+"\n".join(dice_info)
  label_at("%d/%d HP · %d Block" % [h.hp,h.max_hp,h.block],Vector2(hx+48,86),12,MUTED,178)
 if game.active < 3:
  var h: Dictionary = game.heroes[game.active]
  for d in range(3):
   var f: int = game.face(game.active,d)
   var state: String = "CHANNEL HELD" if not h.channel.is_empty() and h.channel.die == d else ("REACTION HELD" if d in h.reaction else ("SPENT" if h.used[d] else ("RESOLVE NEXT" if game.forced_die == d else "READY")))
   var available_soul: bool = f == 0 and game.reward and game.soul_remaining(game.active) > 0
   var name_text: String = "Blank → Move %d" % game.v("soul.move") if available_soul else Model.FACES[f]
   var kind: String = "(Movement)" if available_soul else ("("+Catalog.classification(f)+")" if f != 0 else "")
   if selected >= 0 and game.face(game.active,selected) == 6 and d != selected and game.focus_reason(selected,d) == "":state = "FOCUS TARGET"
   if game.reroll_face_reason(f) != "":kind += " · NO REROLL"
   var text: String = "DIE "+["I","II","III"][d]+" · "+("RESOLVE NEXT" if game.forced_die == d else ("SELECTED" if selected == d and not h.used[d] else state))+"\n"+name_text+"\n"+kind
   var die_button := button(text,Vector2(760,DIE_Y+d*DIE_STEP),Vector2(328,88),func():select_combat_die(d),color_for_face(f),not game.pending.is_empty() or game.outcome != "" or h.dead or h.hp <= 0)
   die_button.name = "BattleDie%d" % d
   die_button.add_theme_font_size_override("font_size",15);die_button.tooltip_text = ""
   var cannot_focus: bool = selected >= 0 and game.face(game.active,selected) == 6 and d != selected and game.focus_reason(selected,d) != ""
   var waiting: bool = game.forced_die >= 0 and game.forced_die != d
   if h.used[d] or waiting or cannot_focus:
    die_button.add_theme_color_override("font_color",Color("7d8791"))
    die_button.add_theme_stylebox_override("normal",style(Color("141a22"),Color("303944")))
    die_button.add_theme_stylebox_override("hover",style(Color("202832"),Color("56606d")))
   if state == "FOCUS TARGET":die_button.add_theme_stylebox_override("normal",style(Color("243b3c"),Color("82c8b9")))
   if selected == d and not h.used[d]:
    var chosen := style(Color("2b3d48"),GOLD if game.forced_die == d else color_for_face(f));chosen.set_border_width_all(2);die_button.add_theme_stylebox_override("normal",chosen)
   if game.forced_die == d:die_button.tooltip_text = ""

  var instruction: String = "Choose a die, then its target. You can end your turn with dice left." if selected < 0 else hint
  if selected >= 0 and game.face(game.active,selected) == 6:instruction = "FOCUS: click another READY die to reroll it. Its new result must resolve next."
  if game.forced_die >= 0:instruction = (roll_feedback.text if not roll_feedback.is_empty() and roll_feedback.get("die",-1) == game.forced_die else "New result: "+Model.FACES[game.face(game.active,game.forced_die)])+"\nResolve this die next, or Decline."
  elif not roll_feedback.is_empty() and roll_feedback.get("actor",-1) == game.active:instruction = roll_feedback.text
  if h.dead or h.hp <= 0:instruction = "This hero cannot act. End their turn to continue with the party."
  if h.hp > 0 and h.pos in game.fire_tiles and game.v("boss.fire.end_turn") > 0:
   instruction = "FIRE: end turn here → %d damage. Move off this cell or prepare enough Block." % game.v("boss.fire.end_turn")
  if training:
   instruction = "Lesson %d/8: " % (training_step+1)+LESSONS[training_step]
   if training_step == 6:instruction = "Soul lesson: select a Blank and move up to %d cells. You have %d conversions this hero turn." % [game.v("soul.move"),game.v("soul.uses")]
  var instruction_label := label_at(instruction,Vector2(760,502),15,Color("dce6ee"),328,false,true)
  instruction_label.name = "ActionInstruction";instruction_label.mouse_filter = Control.MOUSE_FILTER_PASS
  instruction_label.max_lines_visible = 2;instruction_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS;instruction_label.tooltip_text = instruction
  if selected >= 0 and not h.used[selected]:
   var f: int = game.face(game.active,selected)
   if f in [4,9,10,11,13,14,16,17,18,20,21,22,23,24,25,26,27,29,30,31,32,33,42,43,47,49,50,51,52,54,56] or (f == 0 and (not game.reward or game.soul_remaining(game.active) <= 0)):
    button("Resolve selected face",Vector2(760,556),Vector2(211,44),func():
     if game.hero_action(selected):selected = -1;roll_feedback = {}
     rebuild())
   button("Decline",Vector2(981,556),Vector2(107,44),func():game.decline(selected);selected = -1;roll_feedback = {};rebuild(),MUTED)
  combat_reroll_ui()

  button("End hero turn   →",Vector2(760,682),Vector2(328,54),func():game.finish_turn();selected = -1;rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
  label_at(("Blank moves %d/%d · " % [game.soul_remaining(game.active),game.v("soul.uses")] if game.reward else "")+"%d dice available" % h.used.count(false),Vector2(760,750),13,MUTED,328)
  var tags: Array[String] = []
  for tag in game.status_map(game.active):
   if game.status_map(game.active)[tag]:tags.append("Weak Point READY" if tag == "Backstab" else tag)
  if weak_point_ready(game.active):tags.erase("Weak Point READY");tags.push_front("Weak Point READY")
  var status_label := button("Effects: "+(" · ".join(tags) if not tags.is_empty() else "none"),Vector2(760,780),Vector2(328,48),func():show_active_effects = true;combat_inspected = -1;inspect_action = "";rebuild(),GOLD if weak_point_ready(game.active) else Color("b9cbd9"))
  status_label.name = "ActiveStatuses";status_label.add_theme_font_size_override("font_size",14);status_label.tooltip_text = ""

 else:
  label_at("BOSS TURN",Vector2(760,207),16,GOLD,328)
  var current: String = game.boss_display_action()
  label_at(current,Vector2(760,235),25,Color("f1d2bc"),328,true,true)
  var description := RichTextLabel.new();description.name = "CurrentBossDetails";description.position = Vector2(760,310);description.size = Vector2(328,280);description.add_theme_font_size_override("normal_font_size",18);description.text = boss_ability_summary(current) if current != "Turn complete" else "Advance to the next hero.";ui.add_child(description)
  label_at("Last: "+(game.last_action if game.last_action != "" else "No action yet"),Vector2(760,625),14,MUTED,328,false,true)
  button(game.boss_step_label(),Vector2(760,682),Vector2(328,54),func():game.boss_step();selected = -1;rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 label_at("BATTLE LOG",Vector2(1128,164),17,GOLD,280)
 button("Summary" if compact_log else "All events",Vector2(1296,159),Vector2(104,29),func():compact_log = not compact_log;rebuild(),MUTED).add_theme_font_size_override("font_size",11)
 button("Full history / filters",Vector2(1128,205),Vector2(272,34),func():show_history = true;rebuild(),MUTED)
 var latest := RichTextLabel.new();latest.name = "SideChronicle";latest.bbcode_enabled = true;latest.position = Vector2(1128,250);latest.size = Vector2(272,570);latest.add_theme_font_size_override("normal_font_size",15);latest.scroll_following = true
 var formatted: Array[String] = []
 for entry in game.event_log:
  if compact_log and entry.kind in ["guide","info"]:continue
  formatted.append(format_event(entry,true))
 latest.text = "\n\n".join(formatted);ui.add_child(latest)
 if shove_target >= 0 and selected >= 0:
  for i in range(4):
   var dir: Vector2i = Model.DIRS[i]
   button(["North","East","South","West"][i],Vector2(760+(i%2)*170,780+(i/2)*43),Vector2(158,38),func():
    if game.hero_action(selected,shove_target,dir):selected = -1;shove_target = -1
    rebuild(),GOLD,dir not in game.away_dirs(game.active,shove_target))
 elif lab:lab_ui()
 if not game.pending.is_empty():pending_ui()
 if game.encounter_id == "nugh":
  label_at("BROOD %d/%d · SOUL LINK %s" % [game.living_minions().size(),game.v("nugh.worm_cap"),"OFF" if game.phase_two else "ON"],Vector2(428,117),13,Color("d7b3eb"),310)
 var goal := "v0.21.1 · THE HOLLOW · Read the intent, evade fire and prepare for half HP."
 if game.encounter_id == "nugh":goal = "v0.21.1 · SOUL LINK OFF · Hunt Nu’gh; clear worms for control." if game.phase_two else "v0.21.1 · SOUL LINK ON until half HP · Kill worms, then hunt the master."
 if game.encounter_id == "cantor":
  goal = "v0.21.1 · ATTACKS charge Resonance · SKILL / DEFENSE calm it · Burst during OPEN CORE."
  var meter := button("RESONANCE %d/%d · CORE %s · ?" % [game.resonance,game.v("cantor.resonance_cap"),"OPEN +%d" % game.core_bonus() if game.core_open else "closed"],Vector2(424,112),Vector2(314,24),func():show_turn = true;rebuild(),Color("8cdae4"))
  meter.add_theme_font_size_override("font_size",12);meter.name = "ResonanceStatus"
  meter.tooltip_text = "Resonance = Veyl’s shared power. More power means harder bell hits. Click for rules and examples."
 label_at(goal,Vector2(28,857),14,MUTED,706,false,true)
 if game.last_boss_result != "":
  var outcome_label := label_at("LAST ENEMY RESULT · "+game.last_boss_result,Vector2(752,849),14,Color("e6c394"),664,false,true)
  outcome_label.name = "BossResolution"
  outcome_label.tooltip_text = game.last_boss_result

 if game.outcome != "":outcome_ui()

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
 if f == 0:
  var count := balance_number("soul.uses");var distance := balance_number("soul.move")
  var text := "Blank: with Soul ON, spend %s rolled Blank%s per hero turn as Move %d. Your allowance refreshes at every own turn, including recovery turns. The die stays Blank and can roll again next round." % ["ONE" if count == 1 else str(count),"" if count == 1 else "s",distance]
  if page == "battle":
   text += "\n\n"+("Soul is OFF: Blanks do not grant movement." if not game.reward else ("%d/%d Blank moves remain this turn." % [game.soul_remaining(game.active),game.v("soul.uses")] if game.active < 3 else "Wait for a hero turn."))
   if game.active < 3 and game.heroes[game.active].get("rooted",0) > 0:text += "\nRooted currently prevents voluntary movement until the boss’s next turn."
  return text
 var base := default_face_help(f)
 var profile := active_balance()
 if profile.is_empty():return base
 var values := Balance.summary(profile,Balance.face_group(f),game.tuned if page == "battle" else balanced)
 if Balance.INDEX.has("face%d.numeric_multiplier" % f) or f in [17,20]:values += "\n\nShared Numeric die:\n"+Balance.summary(profile,"Numeric die",game.tuned if page == "battle" else balanced)
 if f == 0:values = Balance.summary(profile,"Soul · Blank movement",balanced)
 return "CUSTOM BALANCE · ACTIVE VALUES\n"+values+"\n\nRules reference (default numbers; active values above take precedence):\n"+base

func default_face_help(f: int) -> String:
 if f >= 9: return Catalog.text(f) + (" Numeric die: 2, 2, 1, 1, 1, 0 by default." if f in range(34,43) or f in [15,17,19,50,51,55] else "")
 return ["Blank: no starting effect. First reward Soul: spend at most ONE rolled Blank per hero turn as Move 2. This does not permanently change the installed face.","Strike: %d damage to one adjacent unit. Weakness subtracts 1. Allies are legal targets." % balance_number("face1.damage"),"Step: move up to 1 orthogonal space.","Stride: move up to 3 spaces in one straight orthogonal direction; no turning.","Guard: gain 1 Block. Block expires at your next turn start.","Reaction: stored when rolled. On being targeted, gain 2 Block before the hit. No movement.","Focus: select another unresolved die to reroll it. Keep and resolve its new face.","First Aid: heal yourself or an adjacent hero for 1. Revives Downed heroes with Broken.","Shove: choose an adjacent unit, then a directly-away direction. Moves the full boss footprint. No collision penalty."][f]

func pending_ui() -> void:
 overlay()
 var p: Dictionary = game.pending
 label_at("A MOMENT TO RESPOND",Vector2(399,260),12,GOLD)
 if p.kind in ["channel","bind","ember","catalog_choice","slot"]:
  catalog_pending_ui(p)
 elif p.kind == "reaction":
  label_at(game.heroes[p.hero].name + " can react.",Vector2(399,300),26,Color("ece6d9"),620,true)
  var reaction_die: int = p.get("die",-1)
  if reaction_die not in range(3):
   if game.heroes[p.hero].reaction.is_empty():return
   reaction_die = game.heroes[p.hero].reaction[0]
  var reaction_face: int = game.face(p.hero,reaction_die)
  label_at(game.unit_name(p.get("source",3))+" · "+p.action+" · %d incoming damage" % maxi(0,p.amount-(game.v("face51.weakness") if game.boss.weak and p.get("source",3) == 3 else 0)),Vector2(399,333),14,Color("edba8b"),570)
  label_at("Spend Reaction: gain %d Block before the hit.\nThis face does not move you." % game.v("face5.block"),Vector2(399,352),15,MUTED)
  if reaction_face != 5:
   for c in ui.get_children():
    if c is Label and c.position == Vector2(399,352): c.text = short_face_help(reaction_face); c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; c.size = Vector2(550,120);c.clip_text = true;c.max_lines_visible = 6
  button("Gain %d Block" % game.v("face5.block") if reaction_face == 5 else "Use " + Model.FACES[reaction_face],Vector2(399,481),Vector2(250,48),func(): game.react(true); rebuild())
  button("Hold reaction",Vector2(669,481),Vector2(250,48),func(): game.react(false); rebuild(),MUTED)
  if game.heroes[p.hero].smoke.get(p.get("die",-1),-1) in [2,3]:
   for i in range(4):
    var dir: Vector2i = Model.DIRS[i]
    button("Step " + ["North","East","South","West"][i],Vector2(399+(i%2)*270,550+(i/2)*60),Vector2(250,48),func(): game.react(true,dir); rebuild(),GOLD,game.heroes[p.hero].get("rooted",0) > 0 or not game.legal(p.hero,game.heroes[p.hero].pos+dir))
 elif p.kind == "fracture":
  label_at("Fracture · " + game.heroes[p.hero].name,Vector2(399,301),26,Color("ece6d9"),620,true)
  label_at("Choose an installed ability to replace with Blank for this fight.\nYour recorded build returns after the encounter.",Vector2(399,348),15,MUTED)
  for d in range(3):
   for side in range(6):
    var f: int = game.heroes[p.hero].build[d][side]
    choice_button(Model.FACES[f],Vector2(377+side*98,416+d*66),Vector2(92,54),func(): game.fracture(d,side); rebuild(),color_for_face(f),f in [0,56])
 elif p.kind == "push":
  label_at("Drive Back resolves automatically along the hit direction.",Vector2(399,301),20,GOLD,620,true)
 elif p.kind in ["stun","preroll_stun"]:
  label_at("Stunned · " + game.heroes[p.hero].name,Vector2(399,301),26,Color("ece6d9"),620,true)
  label_at("Choose one die to set aside before the shared roll." if p.kind == "preroll_stun" else "Choose one unresolved Action Die to set aside.",Vector2(399,356),16,MUTED)
  for d in range(3):
   button("Die %d" % [d+1] if p.kind == "preroll_stun" else "Die %d · %s" % [d+1,Model.FACES[game.face(p.hero,d)]],Vector2(399,416+d*56),Vector2(520,45),func(): game.stun_die(d); rebuild(),GOLD,(p.kind != "preroll_stun" and game.heroes[p.hero].used[d]) or (p.kind == "preroll_stun" and not game.heroes[p.hero].channel.is_empty() and game.heroes[p.hero].channel.die == d))

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
 label_at(game.boss_name()+" is defeated. The boss Soul is unlocked.\nEach hero: %d HP · %d+ Blanks per die.\n%d Blank conversions per turn, each Move %d.\nSurviving heroes recover between encounters." % [game.v("hero.hp"),game.v("body.blanks"),game.v("soul.uses"),game.v("soul.move")] if won else "All three heroes are Downed or dead.\nA clean test restart restores HP, dice and conditions.\nRebuild your dice or try the encounter again.",Vector2(399,378),16,MUTED)
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
 label_at("Initiative is rolled once. All available dice roll together at each round boundary.\nEach hero starts with 1 Action Reroll: select a die and reroll BEFORE resolving any face.\nFocus is a separate exception. Rolls resolve instantly. A reroll can repeat the same result.\nBoss I → II → III: effects are shown on each card. Click compact intent rows to inspect.",Vector2(162,380),16,Color("d8dfe5"))
 label_at("03   SURVIVE",Vector2(162,500),17,GOLD)
 label_at("Reactions store immediately and expire before the next round’s roll. Block is spent\non damage and expires at your next turn. First zero HP: Downed, protected through\nthe acting turn. First Aid revives with Broken and queues a full recovery turn.\nAt zero again, a Broken hero dies. All heroes Downed/dead means immediate defeat.",Vector2(162,535),16,Color("d8dfe5"))
 label_at("PROTOTYPE SCOPE",Vector2(162,660),13,GOLD)
 label_at("Tuned: Hollow 12 HP; Nu’gh 10 HP; Veyl 14 HP. Choose boss and rules after picking faces.\nThe Hollow: fire burns at hero turn end; Brand and phase-II Sweep punish staying close.\nNu’gh: retreats and commands worms. Soul Link stops at half HP. Reactions work against bites.\nVeyl: Attacks charge Resonance; Skills / Defenses calm it. The current rulebook explains all three.",Vector2(162,696),14,MUTED)
 button("Open current rulebook",Vector2(162,799),Vector2(310,51),func():OS.shell_open("https://lordtoff.github.io/Godot-Game-Template/current-rules.html"),Color("9fc7e6"))
 button("Return to the game",Vector2(1003,799),Vector2(255,51),func(): show_help = false; rebuild())

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion:
  hover = Vector2i((event.position-ORIGIN)/CELL)
  tooltip_text = ""
  if page == "battle":
   for id in range(4):
    if id == 3:
     if hover in game.cells(3):tooltip_text = game.boss_name()+" · HP %d/%d · Block %d\n" % [game.boss.hp,game.boss.max_hp,game.boss.block]+game.status_description(3)
     continue
    var h: Dictionary = game.heroes[id]
    if hover == h.pos:
     tooltip_text = h.name+" · HP %d/%d · Block %d\n" % [h.hp,h.max_hp,h.block]+game.status_description(id)
     if not h.channel.is_empty():tooltip_text += "\nChannel: "+Model.FACES[h.channel.face]+"\n"+Catalog.text(h.channel.face)
  if page == "battle":
   for id in game.living_minions():
    if hover == game.unit_data(id).pos:tooltip_text = game.unit_name(id)+" · HP %d/%d · Block %d\nWorms move and roll a bite after Nu’gh, plus extra Commands. Die: 1,1,0,0,0,0; HP damage applies Poison 1. Kill for control; Soul Link damages Nu’gh only BEFORE half HP." % [game.unit_data(id).hp,game.unit_data(id).max_hp,game.unit_data(id).block]
  if page == "battle" and hover in game.fire_tiles:tooltip_text += "\nFIRE TILE: end your turn here → %d normal damage. A later positive Smoking Strike also detonates it for %d." % [game.v("boss.fire.end_turn"),game.v("boss.smoking.fire_damage")]
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  if page != "battle" or is_instance_valid(balance_editor) or show_menu or show_lab_tools or show_options or show_lab_setup or show_dice or show_turn or show_changes or show_help or show_history or rolling_time > 0 or not game.pending.is_empty() or game.outcome != "" or game.active == 3 or selected < 0: return
  var c := Vector2i((event.position-ORIGIN)/CELL)
  if not Rect2(ORIGIN,Vector2.ONE*CELL*9).has_point(event.position): return
  var f: int = game.face(game.active,selected)
  var target := -1
  for u in range(game.unit_count()):
   if game.unit_data(u).get("dead",false): continue
   if c in game.cells(u): target = u
  if Catalog.is_attack(f) and target in [0,1,2] and target != game.active and friendly_confirm != target:
   friendly_confirm = target; hint = "FRIENDLY FIRE: click this ally again to confirm the attack."; rebuild(); return
  friendly_confirm = -1
  var done := false
  if f in [0,2,3,53,54,57]: done = game.hero_action(selected,-1,c)
  elif f == 8:
   if shove_target == -1 and target >= 0 and target != game.active and game.distance(game.active,target) <= game.face_range(8):
    shove_target = target; hint = "Choose a push direction from the arrows beside the board."; rebuild(); return
   elif shove_target >= 0:
    var tp: Vector2i = game.unit_data(shove_target).pos
    var delta := c-tp
    var dir := Vector2i(signi(delta.x),0) if absi(delta.x) >= absi(delta.y) else Vector2i(0,signi(delta.y))
    done = game.hero_action(selected,shove_target,dir)
  elif f in [1,7,12,15,19,34,35,36,37,38,39,40,41,55,58]: done = game.hero_action(selected,target)
  if done: selected = -1; shove_target = -1; roll_feedback = {}; hint = "Choose another die, or end this hero’s turn."
  else:
   hint = explain_invalid(f,target,c)
   game.record_event("invalid",game.unit_name(game.active)+" cannot resolve "+Model.FACES[f]+" there; no effect and the die remains available.",game.active)
  rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  if is_instance_valid(balance_editor):balance_editor.queue_free();balance_editor = null
  selected = -1; shove_target = -1; show_active_effects = false; show_options = false; show_menu = false; show_lab_tools = false; show_help = false; inspect_action = "";combat_inspected = -1; show_history = false; show_changes = false; show_dice = false; show_turn = false; show_lab_setup = false; rebuild()

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,Vector2(1440,900)),Color("10151e"))
 draw_line(Vector2(24,76),Vector2(1408,76),Color("303846"))
 if page == "setup":return
 if page == "forge":
  panel(Rect2(68,351,736,336)); panel(Rect2(850,278,472,563))
 else:
  var turn_color: Color = Color("ed9986") if game.active == 3 else COLORS[maxi(0,game.active)]
  panel(Rect2(24,12,716,42),Color("202d37"),turn_color)
  panel(Rect2(752,12,664,126),Color("18222d"),Color("354653"))
  draw_rect(Rect2(760,51,648,6),Color("303846"))
  draw_rect(Rect2(760,51,int(648.0*maxi(0,game.boss.hp)/game.boss.max_hp),6),Color("b76a65"))
  panel(Rect2(752,151,344,687),Color("18222d"),Color("354653"))
  panel(Rect2(1112,151,304,687),Color("14212a"),Color("354653"))
  for i in range(3):panel(Rect2(24+i*244,60,232,48),Color("243641") if i == game.active else Color("17212d"),COLORS[i] if i == game.active else Color("354653"))
  var shake := Vector2.ZERO
  if combat_effects and impact_time > 0:shake = Vector2(sin(t*83),cos(t*71))*impact_strength*(impact_time/0.22)
  draw_set_transform(shake)
  draw_board()
  draw_effects()
  draw_set_transform(Vector2.ZERO)

func draw_board() -> void:
 draw_texture_rect(BACKDROP,Rect2(24,128,716,716),false)
 var highlights: Array = []
 if selected >= 0 and game.active < 3 and game.pending.is_empty():
  var f: int = game.face(game.active,selected)
  if f in [2,3,54] or (f == 0 and game.reward and not game.soul_remaining(game.active) <= 0): highlights = game.reachable(game.active,game.move_steps(f),f == 3)
  if f == 53: highlights = game.leap_cells(game.active)
  if f == 57: highlights = game.reachable(game.active,game.move_steps(f),false)
  if Catalog.is_attack(f) or f in [7,12,15,19,55,58]:
   var reach: int = 99 if f == 12 else game.face_range(f)
   for target in range(game.unit_count()):
    if game.unit_data(target).get("dead",false):continue
    if target == game.active and f not in [7,12,55]:continue
    if not Catalog.is_attack(f) and target >= 3:continue
    if f == 58 and (game.heroes[target].hp <= 0 or game.heroes[target].get("rooted",0) > 0 or game.heroes[game.active].get("rooted",0) > 0):continue
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
   if c in game.fire_tiles:col = Color("8c4b2c")
   var opacity := 0.48 if c in highlights or c in game.brand_cells or c in game.fire_tiles else (0.22 if c in game.cells(3) else 0.06)
   draw_rect(Rect2(p,Vector2.ONE*CELL),Color(col,opacity))
   draw_rect(Rect2(p,Vector2.ONE*CELL),Color(0.75,0.79,0.80,0.24),false,1)
   if c in highlights: draw_circle(p+Vector2.ONE*CELL/2,3,Color("82c5b0"))
   if c in game.brand_cells:
    draw_pixel_fire(p+Vector2.ONE*CELL/2,0.55, x+y*9)
    draw_rect(Rect2(p+Vector2.ONE*4,Vector2.ONE*(CELL-8)),Color("f0a17b"),false,2)
    draw_line(p+Vector2(19,19),p+Vector2(36,36),Color("f0a17b"),2)
    draw_line(p+Vector2(36,19),p+Vector2(19,36),Color("f0a17b"),2)
   if c in game.fire_tiles:
    draw_rect(Rect2(p+Vector2(3,3),Vector2.ONE*(CELL-6)),Color("e5a04d"),false,2)
    draw_pixel_fire(p+Vector2.ONE*CELL/2,0.85,x+y*9)
   if game.active < 3 and weak_point_ready(game.active) and c in [game.boss.pos+Vector2i(0,2),game.boss.pos+Vector2i(1,2)]:
    draw_rect(Rect2(p+Vector2(5,5),Vector2.ONE*(CELL-10)),Color(GOLD,0.85),false,2)
    draw_string(BODY,p+Vector2(17,69),"REAR",HORIZONTAL_ALIGNMENT_LEFT,-1,12,GOLD)
   if c == hover: draw_rect(Rect2(p+Vector2.ONE*2,Vector2.ONE*(CELL-4)),Color(GOLD,0.5),false,1)
 for i in range(9):
  draw_string(BODY,ORIGIN+Vector2(i*CELL+33,9*CELL+12),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
  draw_string(BODY,ORIGIN+Vector2(-20,i*CELL+32),char(65+i),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
 # Portrait tokens use the same art as the party panels and drafting tabs.
 var bp: Vector2 = ORIGIN+Vector2(visual_positions.get(3,Vector2(game.boss.pos)))*CELL+Vector2.ONE*CELL+attack_nudge(3)
 draw_circle(bp+Vector2(0,26),43,Color(0.02,0.02,0.04,0.65))
 draw_unit_sprite(3,Rect2(bp-Vector2.ONE*64,Vector2.ONE*128))
 draw_boss_vitals(bp)
 for i in range(3):
  var h: Dictionary = game.heroes[i]
  if h.dead: continue
  var p := ORIGIN+Vector2(visual_positions.get(i,Vector2(h.pos)))*CELL+Vector2.ONE*CELL/2
  p += attack_nudge(i)
  if movement_tracks.has(i):
   var track: Dictionary = movement_tracks[i]
   var duration: float = track.duration
   var stride := clampf(track.elapsed/duration,0,1)
   p.y -= absf(sin(stride*PI*(track.path.size()-1)))*6
   if stride > 0 and stride < 1:
    draw_line(effect_center(i)+Vector2(-12,24),effect_center(i)+Vector2(12,24),Color(0.04,0.04,0.05,0.6),6)
  var glow: float = channel_glows.get(i,0.0)
  if glow > 0:
   var channel: Dictionary = h.channel
   var ch_face: int = channel.get("face",0)
   var col := Color("86bded") if ch_face == 31 else (Color("8be0ad") if ch_face == 49 else Color("d7a2ed"))
   for ring in range(2):draw_arc(p,29+ring*5,sin(t)*0.05+t*(0.35 if ring == 0 else -0.25),TAU+t*(0.35 if ring == 0 else -0.25),64,Color(col,glow*0.8),2,true)
   for rune in range(6):
    var at := p+Vector2.from_angle(rune*TAU/6+t*0.45)*33
    draw_line(at+Vector2(-3,-3),at+Vector2(3,3),Color(col,glow),2,true)

  if game.active == i:
   draw_arc(p,26,0,TAU,64,Color(COLORS[i],0.8+sin(t*2)*0.15),3)
   draw_colored_polygon(PackedVector2Array([p+Vector2(-7,-42),p+Vector2(7,-42),p+Vector2(0,-32)]),COLORS[i])
   draw_string(BODY,p+Vector2(-24,-49),"TURN",HORIZONTAL_ALIGNMENT_LEFT,-1,12,COLORS[i])
  draw_circle(p+Vector2(0,21),21,Color(0.04,0.05,0.08,0.5))
  if h.hp == 0:
   draw_line(p+Vector2(-8,-8),p+Vector2(8,8),COLORS[i],3); draw_line(p+Vector2(8,-8),p+Vector2(-8,8),COLORS[i],3)
  else:
   draw_unit_sprite(i,Rect2(p-Vector2.ONE*32,Vector2.ONE*64))
  draw_hp_dots(p+Vector2(0,35),h.hp,h.max_hp,COLORS[i])
  draw_hero_debuffs(i,p)
  if weak_point_ready(i):draw_weak_point(p)
  if h.stun:draw_stunned(p)
 for id in game.living_minions():draw_worm(id)
 if game.encounter_id == "cantor":
  var cap: int = game.v("cantor.resonance_cap")
  for pip in range(cap):
   var width := 250.0/maxi(1,cap)
   draw_rect(Rect2(430+pip*width,136,width-3,4),GOLD if pip < game.resonance and game.resonance == cap else (Color("75cfdf") if pip < game.resonance else Color("354655")))

func sync_presentation() -> void:
 if page != "battle": return
 var hit_sound := -1
 for event in game.event_log:
  if event.id <= seen_event: continue
  seen_event = event.id
  if event.kind == "phase":
   inspect_actor = game.active
   effects.append({"kind":"phase","source":3,"target":3,"life":2.6,"length":2.6})
  if event.kind == "focus":
   roll_feedback = {"actor":event.source,"die":event.die,"text":"FOCUS · Die %s: %s → %s" % [["I","II","III"][event.die],Model.FACES[event.old_face],Model.FACES[event.new_face]]+(" · Reaction held" if game.heroes[event.source].used[event.die] else "")}
   effects.append({"kind":"focus","source":event.source,"target":event.target,"die":event.die,"life":1.5,"length":1.5})
  if event.kind in ["damage","block"] and event.source >= 3 and event.target in [0,1,2] and event.action != "Poison":
   if combat_effects:
    impact_time = 0.22;impact_strength = 3.5 if event.value > 0 else 1.5
    effects.append({"kind":"impact","source":event.source,"target":event.target,"life":0.5,"length":0.5,"damage":event.value})
   hit_sound = maxi(hit_sound,3 if game.encounter_id == "cantor" else (2 if event.action == "Screaming Chorus" else (1 if event.value > 0 else 0)))
  if event.kind == "buff" and "Weak Point READY" in event.text:
   floaters.append({"at":effect_center(event.target),"text":"WEAK POINT READY","color":GOLD,"life":1.6})
  if event.kind in ["resonance","core","poison"]:
   effects.append({"kind":event.kind,"source":event.source,"target":event.target if event.target >= 0 else 3,"life":1.1,"length":1.1})
   if event.kind in ["core","poison"]:floaters.append({"at":effect_center(event.target if event.target >= 0 else 3),"text":"POISON" if event.kind == "poison" else ("CORE OPEN" if game.core_open else "CORE SEALED"),"color":Color("a4dc75") if event.kind == "poison" else GOLD,"life":1.6})
  if event.kind in ["summon","minion_death"]:
   effects.append({"kind":"buff" if event.kind == "summon" else "debuff","source":event.source,"target":event.target,"life":1.05,"length":1.05})
  if event.kind in ["fire","fire_arm"]:
   effects.append({"kind":event.kind,"tiles":event.get("tiles",[]).duplicate(),"source":event.source,"target":-1,"life":1.2,"length":1.2})
  if event.kind in ["attack","block","block_gain","buff","debuff","heal"]:
   var kind: String = event.kind
   if kind == "block_gain": kind = "block"
   if kind == "attack" and event.source >= 3:kind = "boss_attack"
   if event.target >= 0:
    effects.append({"kind":kind,"source":event.source,"target":event.target,"life":1.05,"length":1.05,"action":event.action})
 if roll_seen > game.roll_presentations.size(): roll_seen = 0
 var numeric_batches: Array = []
 while roll_seen < game.roll_presentations.size():
  var presentation: Dictionary = game.roll_presentations[roll_seen]
  roll_seen += 1
  if str(presentation.kind).begins_with("Numeric"):numeric_batches.append(presentation)
 if not numeric_batches.is_empty() and is_instance_valid(dice_tray):
  dice_tray.play(numeric_batches);rolling_time = 1.0
 if dice_tray.busy:queued_hit_sound = maxi(queued_hit_sound,hit_sound)
 else:play_hit_sound(hit_sound)
 seen_roll = game.roll_serial
 for id in range(game.unit_count()):
  var h: Dictionary = game.unit_data(id)
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
  if log_filter == "Combat" and entry.kind not in ["action","attack","damage","block","block_gain","heal","buff","debuff","expire","mutation","retarget","collision","stun","decline","focus","summon","minion_death","soul_link","minion_action","fallback","boss_result","resonance","core","roll","poison","move"]: continue
  if log_filter == "Turns" and entry.kind not in ["turn","round","roll"]: continue
  text_lines.append(format_event(entry,true))
 lines.text = "\n\n".join(text_lines); ui.add_child(lines)
 button("Copy log",Vector2(215,734),Vector2(208,40),func(): DisplayServer.clipboard_set("\n".join(game.log_lines)),MUTED)
 button("Back to battle",Vector2(943,730),Vector2(279,45),func(): show_history = false; show_changes = false; show_dice = false; show_turn = false; show_lab_setup = false; rebuild())

func format_event(entry: Dictionary, expanded: bool) -> String:
 var colors := {"attack":"efb29b","damage":"eea394","block":"9fc7e6","block_gain":"9fc7e6","buff":"91d1b4","debuff":"c9a4e3","heal":"91d1b4","turn":"e4c88f","round":"e4c88f","focus":"e4c88f","summon":"b9d0a6","minion_death":"d9c493","soul_link":"d5a0e4","fallback":"edc785","minion_action":"d5b7eb","boss_result":"edc785","resonance":"8edbe5","core":"f0dfa3","expire":"9aaaba","poison":"b7e86d","roll":"c6d6ed","move":"c0b398"}
 var color: String = colors.get(entry.kind,"becad3")
 var tag: String = "R%02d · #%03d · %s" % [entry.round,entry.id,entry.kind.replace("_"," ").to_upper()]
 return "[color=#%s][b]%s[/b][/color]%s%s" % [color,tag,"\n" if expanded else "  ",entry.text.replace("[","[lb]")]

func effect_center(id: int) -> Vector2:
 if id < 0: return Vector2(322,150)
 var pos: Vector2 = visual_positions.get(id,Vector2(game.unit_data(id).pos))
 return ORIGIN+pos*CELL+Vector2.ONE*CELL*(1.0 if id == 3 else 0.5)

func draw_effects() -> void:
 for fx in effects:
  if not combat_effects and fx.kind in ["boss_attack","impact"]:continue
  if fx.kind == "focus":
   if game.active == fx.source:
    var rect := Rect2(756,DIE_Y-4+fx.die*DIE_STEP,336,96)
    draw_rect(rect,Color(GOLD,minf(1.0,fx.life)),false,3)
   continue
  if fx.kind in ["boss_attack","impact"]:
   draw_boss_impact(fx);continue
  if fx.kind == "phase":
   draw_phase_transition(fx);continue
  if fx.kind in ["fire","fire_arm"]:
   var flame_alpha: float = minf(1.0,fx.life*2.0)
   for tile in fx.tiles:draw_pixel_fire(ORIGIN+Vector2(tile)*CELL+Vector2.ONE*CELL/2,flame_alpha, tile.x+tile.y*9,fx.kind == "fire")
   continue
  var p: Vector2 = effect_center(fx.target)
  var progress: float = 1.0-fx.life/fx.length
  var alpha: float = smoothstep(0.0,0.15,progress)*(1.0-smoothstep(0.5,1.0,progress))
  progress = smoothstep(0.0,1.0,progress)
  match fx.kind:
   "poison":
    draw_arc(p+Vector2(0,18),18+progress*24,0,TAU,32,Color(0.58,0.9,0.25,alpha),3)
    for mote in range(7):
     var q := p+Vector2.from_angle(mote*TAU/7)*(12+progress*26)+Vector2(0,-progress*18)
     draw_rect(Rect2(q,Vector2(5,5)),Color(0.68,0.92,0.28,alpha))
   "resonance","core":
    var tint := Color("e8cb80") if fx.kind == "core" else Color("78d2e9")
    draw_arc(p,32+progress*55,0,TAU,48,Color(tint,alpha),3)
    for note in range(6):
     var q := p+Vector2.from_angle(note*TAU/6+progress)*(32+progress*30)
     draw_line(q,q+Vector2(0,-12),Color(tint,alpha),2)
     draw_circle(q+Vector2(-2,0),3,Color(tint,alpha))
   "landing":
    draw_arc(p+Vector2(0,22),10+progress*19,0,TAU,24,Color(0.7,0.6,0.44,alpha*0.65),2)
    for grit in range(5):draw_rect(Rect2(p+Vector2(-24+grit*12,22-sin(progress*PI)*9),Vector2(3,3)),Color(0.65,0.58,0.43,alpha))
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
 draft_error = "";inspected_gift = id
 if id not in Catalog.extended_ids():return
 if id in gifts[build_hero]:
  gifts[build_hero].erase(id)
  for die in builds[build_hero]:
   for side in range(6):
    if die[side] == id:die[side] = 0
 else:
  var result := FaceLoadout.quick_equip(builds[build_hero],gifts[build_hero],balance_values,id)
  if result.error != "":draft_error = result.error
  else:builds[build_hero] = result.build;gifts[build_hero] = result.gifts
 rebuild()

func confirm_gifts() -> void:
 if gifts[build_hero].size() != 2:return
 var error := Model.validate(builds[build_hero],gifts[build_hero],balance_values)
 if error != "" or not gifts[build_hero].all(func(id):return builds[build_hero].any(func(die):return id in die)):
  draft_error = error if error != "" else "Place both chosen designs on the dice first.";rebuild();return
 var next := -1
 for i in range(3):
  if gifts[i].size() != 2:next = i;break
 if next >= 0:build_hero = next;draft_search = "";draft_scroll = 0
 else:open_setup();return
 rebuild()

func draft_ui() -> void:
 var shade := ColorRect.new();shade.color = Color("101922");shade.size = Vector2(1440,900);ui.add_child(shade)
 label_at("CHOOSE TWO FACES · v0.21.1",Vector2(60,27),29,GOLD,1000,true)
 label_at("1 · Pick two abilities     2 · Arrange your dice (optional)     3 · Next hero",Vector2(62,74),15,MUTED,1300)
 button("Back to forge",Vector2(1150,26),Vector2(230,40),func():draft_modal = false;rebuild(),MUTED)
 for hero in range(3):
  button(["VESPER","ROOK","WREN"][hero]+" · %d/2" % gifts[hero].size(),Vector2(60+hero*440,113),Vector2(424,44),func():build_hero = hero;draft_scroll = 0;draft_error = "";rebuild(),COLORS[hero] if build_hero == hero else MUTED)
  portrait_at(hero,Vector2(72+hero*440,120),Vector2(30,30))
 var search := LineEdit.new();search.name = "GiftSearch";search.placeholder_text = "Search abilities…";search.text = draft_search;search.position = Vector2(60,178);search.size = Vector2(242,42);ui.add_child(search)
 search.text_changed.connect(func(value):
  draft_search = value;draft_scroll = 0;rebuild()
  var field = ui.get_node("GiftSearch");field.grab_focus();field.caret_column = value.length())
 var filter := OptionButton.new();filter.name = "GiftCategory";filter.position = Vector2(314,178);filter.size = Vector2(162,42)
 for cat in ["All","Attack","Defense","Movement","Skill"]:filter.add_item(cat)
 filter.select(["All","Attack","Defense","Movement","Skill"].find(draft_category))
 filter.item_selected.connect(func(index):draft_category = ["All","Attack","Defense","Movement","Skill"][index];draft_scroll = 0;rebuild());ui.add_child(filter)
 var timing_filter := OptionButton.new();timing_filter.name = "GiftTiming";timing_filter.position = Vector2(488,178);timing_filter.size = Vector2(176,42)
 for value in ["All timings","Action","Reaction","Channel"]:timing_filter.add_item(value)
 timing_filter.select(["All timings","Action","Reaction","Channel"].find(draft_timing))
 timing_filter.item_selected.connect(func(index):draft_timing = ["All timings","Action","Reaction","Channel"][index];draft_scroll = 0;rebuild());ui.add_child(timing_filter)
 var scroll := ScrollContainer.new();scroll.name = "GiftCards";scroll.position = Vector2(60,240);scroll.size = Vector2(604,514);ui.add_child(scroll)
 var saved_scroll := draft_scroll
 scroll.get_v_scroll_bar().value_changed.connect(func(value):draft_scroll = int(value));scroll.set_deferred("scroll_vertical",saved_scroll)
 var cards := GridContainer.new();cards.columns = 2;cards.add_theme_constant_override("h_separation",10);cards.add_theme_constant_override("v_separation",10);scroll.add_child(cards)
 var count := 0
 for id in Catalog.extended_ids():
  if draft_category != "All" and Catalog.category(id) != draft_category:continue
  if draft_timing != "All timings" and Catalog.timing(id) != draft_timing:continue
  if draft_search != "" and not Model.FACES[id].to_lower().contains(draft_search.to_lower()):continue
  count += 1
  var chosen: bool = id in gifts[build_hero]
  var card := Button.new();card.name = "Face"+str(id);card.text = Model.FACES[id]+"\n("+Catalog.classification(id)+")\n"+("✓ EQUIPPED · click to remove" if chosen else short_face_help(id).split("\n")[0].left(96))
  card.custom_minimum_size = Vector2(288,118);card.clip_text = true;card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;card.alignment = HORIZONTAL_ALIGNMENT_LEFT;card.add_theme_font_size_override("font_size",14)
  card.add_theme_color_override("font_color",color_for_face(id));card.add_theme_stylebox_override("normal",style(Color("2b3c47") if chosen else Color("1a2732"),GOLD if chosen else Color("354653")));card.add_theme_stylebox_override("hover",style(Color("304351"),color_for_face(id)));card.tooltip_text = ""
  card.pressed.connect(func():
   inspected_gift = id
   if id not in gifts[build_hero] and gifts[build_hero].size() < 2:choose_gift(id)
   elif id in gifts[build_hero]:choose_gift(id)
   else:draft_error = "Two faces chosen. Click an equipped card to remove it, then choose a replacement.";rebuild())
  card.mouse_entered.connect(func():preview_gift(id))
  card.set_drag_forwarding(func(_at):return face_drag_data(card,id),Callable(),Callable());cards.add_child(card)
 label_at("%d bonus designs · two per hero" % count,Vector2(62,766),13,MUTED,600)
 label_at("YOUR DICE · "+str(gifts[build_hero].size())+" / 2 CHOSEN",Vector2(700,178),16,COLORS[build_hero],680)
 label_at("Drop on the die to auto-fit, or on a square for exact placement.",Vector2(700,204),13,MUTED,680)
 for die in range(3):
  var base := Vector2(700+die*224,250)
  var pad := Panel.new();pad.name = "DraftDie"+str(die);pad.position = base-Vector2(4,28);pad.size = Vector2(220,314);pad.add_theme_stylebox_override("panel",style(Color("14212b"),Color("354653")));ui.add_child(pad)
  pad.set_drag_forwarding(Callable(),func(_at,data):return face_drop_allowed(die,-1,data),func(_at,data):place_dragged_face(die,-1,data))
  label_at("DIE "+["I","II","III"][die],base-Vector2(0,24),13,GOLD,200)
  for side in range(6):
   var face: int = builds[build_hero][die][side]
   var slot := button(Model.FACES[face],base+Vector2(NET[side])*72,Vector2(70,70),func():
    inspected_gift = face;rebuild(),color_for_face(face))
   slot.name = "DraftDie%dSide%d" % [die,side];slot.clip_text = true;slot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;slot.add_theme_font_size_override("font_size",12);slot.size = Vector2(70,70);slot.tooltip_text = face_help(face)
   for state_name in ["normal","hover","pressed"]:
    slot.get_theme_stylebox(state_name).content_margin_left = 4;slot.get_theme_stylebox(state_name).content_margin_right = 4
   slot.set_drag_forwarding(func(_at):return face_drag_data(slot,face,die,side),func(_at,data):return face_drop_allowed(die,side,data),func(_at,data):place_dragged_face(die,side,data))
 var drop_hint := label_at(draft_error if draft_error != "" else "Picked: "+(" + ".join(gifts[build_hero].map(func(id):return Model.FACES[id])) if not gifts[build_hero].is_empty() else "Click any two cards on the left."),Vector2(700,544),13,GOLD if draft_error != "" else MUTED,680,false,true);drop_hint.name = "DraftDropHint";drop_hint.max_lines_visible = 2
 label_at(Catalog.display_name(inspected_gift),Vector2(700,590),20,color_for_face(inspected_gift),680,true,true).name = "GiftPreviewTitle"
 var detail := RichTextLabel.new();detail.name = "GiftDetail";detail.position = Vector2(700,626);detail.size = Vector2(680,108);detail.add_theme_font_size_override("normal_font_size",16);detail.text = short_face_help(inspected_gift);ui.add_child(detail)
 var chosen: bool = inspected_gift in gifts[build_hero]
 button("Remove this face" if chosen else "Equip this face",Vector2(700,748),Vector2(310,38),func():choose_gift(inspected_gift),color_for_face(inspected_gift),not chosen and (gifts[build_hero].size() >= 2 or inspected_gift not in Catalog.extended_ids())).name = "GiftEquipButton"
 label_at("%d/2 selected · drag equipped squares to rearrange" % gifts[build_hero].size(),Vector2(1025,757),12,MUTED,350)
 var complete: bool = gifts.all(func(list):return list.size() == 2)
 button("Choose boss & rules →" if complete else "Next hero →",Vector2(950,810),Vector2(430,44),func():
  if complete:open_setup()
  else:confirm_gifts(),GOLD,gifts[build_hero].size() != 2)
 button("Guided practice",Vector2(60,810),Vector2(260,42),start_training,Color("82c8b9"))
 button("Game options",Vector2(335,810),Vector2(260,42),open_settings,MUTED)

func preview_gift(id: int) -> void:
 inspected_gift = id
 if not ui.has_node("GiftDetail"):return
 ui.get_node("GiftDetail").text = short_face_help(id)
 ui.get_node("GiftPreviewTitle").text = Catalog.display_name(id)
 ui.get_node("GiftPreviewTitle").add_theme_color_override("font_color",color_for_face(id))
 var chosen: bool = id in gifts[build_hero]
 var equip = ui.get_node("GiftEquipButton")
 equip.text = "Remove this face" if chosen else "Equip this face"
 equip.disabled = not chosen and gifts[build_hero].size() >= 2
func face_drag_data(source: Control, face: int, die: int = -1, side: int = -1) -> Dictionary:
 var preview := Panel.new();preview.size = Vector2(250,76);preview.add_theme_stylebox_override("panel",style(Color("293747"),color_for_face(face)))
 var caption := Label.new();caption.text = Catalog.display_name(face);caption.position = Vector2(10,8);caption.size = Vector2(230,60);caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;preview.add_child(caption);source.set_drag_preview(preview)
 return {"kind":"ash_face","face":face,"hero":build_hero,"from_die":die,"from_side":side}

func face_drop_result(die: int, side: int, data: Variant) -> Dictionary:
 if not data is Dictionary or data.get("hero",-1) != build_hero:return {"error":"Drag a face for the currently selected hero."}
 if side < 0:return FaceLoadout.best_drop(builds[build_hero],gifts[build_hero],balance_values,die,data)
 return FaceLoadout.trial(builds[build_hero],gifts[build_hero],balance_values,die,side,data)

func face_drop_allowed(die: int, side: int, data: Variant) -> bool:
 var result := face_drop_result(die,side,data)
 if ui.has_node("DraftDropHint"):
  ui.get_node("DraftDropHint").text = result.error if result.error != "" else (result.note if result.note != "" else "Release to place / swap this face on Die "+["I","II","III"][die]+".")
 return result.error == ""

func place_dragged_face(die: int, side: int, data: Variant) -> void:
 var result := face_drop_result(die,side,data)
 if result.error != "":draft_error = result.error;return
 builds[build_hero] = result.build;gifts[build_hero] = result.gifts;inspected_gift = int(data.face)
 draft_error = result.note if result.note != "" else "Placed "+Model.FACES[inspected_gift]+" on Die "+["I","II","III"][die]+"."
 rebuild.call_deferred()

func catalog_pending_ui(p: Dictionary) -> void:
 if p.kind == "slot":
  label_at("Choose a Blank slot · " + Model.FACES[p.face],Vector2(390,290),22,GOLD,620,true)
  label_at("Choose exactly where the new face is installed. Grey slots are unavailable.",Vector2(390,340),13,MUTED,590,false,true)
  for d in range(3):
   for side in range(6):
    var f: int = game.heroes[p.target].build[d][side]
    choice_button(str(d+1)+" · "+Model.FACES[f],Vector2(377+side*101,390+d*58),Vector2(95,48),func(): game.choose_slot(d,side); selected = -1; rebuild(),color_for_face(f),f != 0)
 elif p.kind == "channel":
  var ch: Dictionary = game.heroes[p.hero].channel
  label_at("CHANNEL · " + Model.FACES[ch.face],Vector2(390,299),23,GOLD,600,true)
  label_at(short_face_help(ch.face),Vector2(390,352),15,MUTED,550,false,true)
  button("Maintain Channel",Vector2(399,524),Vector2(250,49),func(): game.channel_choice(true); rebuild())
  button("End and roll this die",Vector2(669,524),Vector2(280,49),func(): game.channel_choice(false); rebuild())
 elif p.kind == "ember":
  label_at("Ember Burst · Block to burn?",Vector2(390,299),23,GOLD,600,true)
  label_at("Each point burned damages all units in the configured radius, including allies.",Vector2(390,358),14,MUTED,550,false,true)
  var amount := SpinBox.new();amount.position = Vector2(399,430);amount.size = Vector2(240,48);amount.min_value = 0;amount.max_value = mini(game.v("face52.burn"),game.heroes[p.hero].block);amount.step = 1;ui.add_child(amount)
  button("Burn this Block",Vector2(669,430),Vector2(250,48),func():game.ember(int(amount.value));rebuild())
  label_at("Up to %d Block · %d damage per point · radius %d" % [int(amount.max_value),game.v("face52.damage"),game.v("face52.range")],Vector2(399,507),15,GOLD,570)

 elif p.kind == "bind":
  label_at("Lethargic Bind · choose a boss face",Vector2(390,299),23,GOLD,620,true)
  for d in range(3):
   for side in range(6):
    var action: String = game.boss_dice()[d][side]
    choice_button(str(d+1)+" · "+action,Vector2(377+side*101,379+d*70),Vector2(95,58),func(): game.choose_bind(d,action); rebuild(),GOLD)
 else:
  label_at(Model.FACES[p.face] + " · Choose a die",Vector2(390,298),22,GOLD,620,true)
  label_at("Skip an unresolved die first; then choose a spent immediate face." if p.face == 23 else ("Choose the installed ability on the Blank die you selected." if p.face == 26 and p.stage == 1 else "Choose an eligible source; unavailable choices are grey."),Vector2(390,343),13,MUTED,570,false,true)
  if p.face == 16 or (p.face == 26 and p.stage == 1):
   for d in range(3):
    for side in range(6):
     var f: int = game.heroes[p.hero].build[d][side]
     choice_button(str(d+1)+" · "+Model.FACES[f],Vector2(377+side*101,390+d*58),Vector2(95,48),func():
      if game.catalog_pick(p.hero,d,side): selected = game.forced_die
      rebuild(),color_for_face(f),not choice_eligible(p,p.hero,d,side))
  else:
   for hero in range(3):
    for d in range(3):
     var h: Dictionary = game.heroes[hero]
     if h.results.is_empty(): continue
     var f: int = game.face(hero,d)
     choice_button(h.name+" · Die "+str(d+1)+"\n"+Model.FACES[f],Vector2(387+d*202,390+hero*58),Vector2(195,48),func():
      if game.catalog_pick(hero,d): selected = game.forced_die
      rebuild(),color_for_face(f),not choice_eligible(p,hero,d))
  button("Spend with no effect",Vector2(399,593),Vector2(520,42),func(): game.pending = {}; game.decline(p.die); selected = -1; rebuild(),MUTED)

func attack_nudge(id: int) -> Vector2:
 for index in range(effects.size()-1,-1,-1):
  var fx: Dictionary = effects[index]
  if fx.kind in ["attack","boss_attack"] and fx.source == id:
   if fx.kind == "boss_attack" and not combat_effects:return Vector2.ZERO
   var origin_point := effect_center(id);var target_point := effect_center(fx.target)
   var progress: float = 1.0-fx.life/fx.length
   return origin_point.direction_to(target_point)*(22.0 if id == 3 else 8.0)*sin(progress*PI)
  if fx.kind == "impact" and fx.target == id and combat_effects:
   return effect_center(3).direction_to(effect_center(id))*7.0*sin((1.0-fx.life/fx.length)*PI)
 return Vector2.ZERO


func start_lab() -> void:
 training = false
 lab = true; draft_modal = false; show_help = false; show_changes = false; inspect_action = ""; show_history = false; show_dice = false; show_turn = false
 reset_lab()

func reset_lab() -> void:
 combat_inspected = -1;inspect_action = "";show_active_effects = false;roll_feedback = {};detailed_ability = false
 game = Lab.create(lab_face,lab_numeric,balance_values,balanced)
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
 button("Lab tools",Vector2(760,847),Vector2(158 if training else 328,43),func():show_lab_tools = true;rebuild(),Color("82c8b9"))
 if training:button("Next lesson →" if training_step < LESSON_FACES.size()-1 else "Play preset →",Vector2(930,847),Vector2(158,43),next_lesson,GOLD,not lesson_done())

func lab_tools_ui() -> void:
 overlay()
 label_at("ABILITY LAB TOOLS",Vector2(399,253),26,GOLD,600,true)
 label_at("Vesper: %d/%d HP · %d Block" % [game.heroes[0].hp,game.heroes[0].max_hp,game.heroes[0].block],Vector2(399,293),15,MUTED,570)
 var picker := OptionButton.new();picker.name = "LabAbilities";picker.position = Vector2(399,333);picker.size = Vector2(575,39)
 for id in range(59):picker.add_item(Catalog.display_name(id),id)
 picker.select(lab_face);picker.item_selected.connect(func(index):training = false;lab_face = index;reset_lab());ui.add_child(picker)
 var num := OptionButton.new();num.position = Vector2(399,390);num.size = Vector2(275,39)
 for title in ["Numeric: random","Numeric: force 0","Numeric: force 1","Numeric: force 2"]:num.add_item(title)
 num.select(lab_numeric+1);num.item_selected.connect(func(index):lab_numeric = index-1;reset_lab());ui.add_child(num)
 button("Reset test",Vector2(689,390),Vector2(285,39),reset_lab)
 button("Boss hits",Vector2(399,446),Vector2(275,39),func():show_lab_tools = false;Lab.attack(game,lab_face);selected = -1;rebuild(),Color("ed9986"),not game.pending.is_empty() or game.outcome != "")
 button("Next turn",Vector2(689,446),Vector2(285,39),func():show_lab_tools = false;Lab.next_turn(game,lab_numeric);selected = -1;rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 button("Roll chosen face again",Vector2(399,502),Vector2(275,39),func():show_lab_tools = false;Lab.roll_test_face(game,lab_face,lab_numeric);selected = -1;rebuild(),Color("82c8b9"))
 button("Combine faces",Vector2(689,502),Vector2(285,39),func():show_lab_tools = false;show_lab_setup = true;rebuild(),MUTED)
 button("Copy test log",Vector2(399,570),Vector2(275,43),func():DisplayServer.clipboard_set("Ash & Oath v0.21.1 · "+Model.FACES[lab_face]+"\n"+"\n".join(game.log_lines)),MUTED)
 button("Back to battle",Vector2(689,570),Vector2(285,43),func():show_lab_tools = false;rebuild())
 button("Phase II active" if game.phase_two else "Test boss phase II",Vector2(399,632),Vector2(575,39),test_boss_phase_two,Color("e9a36a"),game.phase_two or not game.pending.is_empty() or game.outcome != "" or game.v("boss.phase.percent") == 0)

func changes_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("101923"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("PATCH NOTES · v0.21.1",Vector2(125,75),32,GOLD,1200,true)
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
 if p.face == 11: return h.hp > 0 and not h.dead and Catalog.can_copy(f) and game.distance(game.active,hero) <= game.v("face11.range")
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
 label_at("RESONANCE & TURN HELP" if game.encounter_id == "cantor" else "HOW THIS TURN WORKS",Vector2(125,80),32,GOLD,1200,true)
 var actor: String = game.unit_name(game.active)
 label_at("ROUND %d · %s" % [game.round_no,actor],Vector2(130,145),22,GOLD,1100)
 var text := RichTextLabel.new(); text.name = "TurnGuide"; text.bbcode_enabled = true; text.position = Vector2(130,210); text.size = Vector2(1175,480); text.add_theme_font_size_override("normal_font_size",21)
 text.text = (game.resonance_help()+"\n\n[b]THIS TURN[/b]\n" if game.encounter_id == "cantor" else "")+"[b]"+actor+" is acting now.[/b]\n\n"+game.turn_explanation()+"\n\n[b]What to do next[/b]\n"
 if not game.pending.is_empty(): text.text += "Finish the open choice / reaction window first. It pauses the attack or turn; no other action can resolve until that decision is complete."
 elif game.active == 3:
  text.text += ("Resolve boss die %s: %s.\n%s" % [["I","II","III"][game.boss_index],game.boss_rolls[game.boss_index],game.boss_help(game.boss_rolls[game.boss_index])]) if game.boss_index < 3 else "All three boss dice are finished. Click Resolve end of turn to move to the next hero."
 else:
  var h: Dictionary = game.heroes[game.active]
  text.text += "Choose a bright, unspent die. Hover it to read its description beside the arena. Movement needs an empty highlighted cell; attacks and healing need a legal unit; setup effects use Resolve. Grey dice are spent, held as reactions or channelled. You may End turn without using every die."
  if game.reward: text.text += "\n\nReward Soul: " + ("%d/%d" % [game.soul_remaining(game.active),game.v("soul.uses")]) + " Blank-to-Move-%d conversions remain this hero turn.\n" % game.v("soul.move")
  text.text += "\n\nReroll window: " + ("OPEN" if h.opening else "CLOSED after your first ordinary resolution") + " · saved charges: " + str(h.rerolls) + ". A starting charge does not refill each round."
 text.text += "\n\n[b]Initiative[/b]\n"+" → ".join(game.order.map(func(id):return game.unit_name(id)))
 text.text += "\n\n[b]Between turns[/b]\nInitiative stays fixed for this encounter. New round = everyone rolls available dice together. Your next turn start clears old Block and temporary defenses; Channels can pause for maintain / release. HP damage, mitigation and expiry are recorded in the chronicle."
 ui.add_child(text)
 button("Understood · back to turn",Vector2(945,790),Vector2(360,48),func(): show_turn = false; rebuild())

func dice_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("101923"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("VIEW DICE · LIVE FACE INVENTORY",Vector2(125,60),30,GOLD,1200,true)
 label_at("Choose a unit. Click any side for its effect. Gold = changed this fight; blue = current rolled side.",Vector2(130,110),15,MUTED,1200)
 for hero in range(4):
  button((["VESPER","ROOK","WREN",game.boss_name().to_upper() if page == "battle" else "BOSS"])[hero],Vector2(130+hero*300,150),Vector2(280,42),func(): dice_hero = hero; dice_inspected = Vector2i.ZERO; rebuild(),GOLD if dice_hero == hero else MUTED,hero == 3 and page != "battle")
 var in_fight := page == "battle"
 var is_boss := dice_hero == 3
 for d in range(3):
  label_at("DIE " + ["I","II","III"][d],Vector2(130+d*420,207),16,GOLD,300)
  for side in range(6):
   var original: String
   var current: String
   var rolled := false
   var id := 0
   if is_boss:
    current = game.boss_dice()[d][side]; original = (Cantor.DICE if game.encounter_id == "cantor" else (Nugh.DICE if game.encounter_id == "nugh" else (Model.TUNED_BOSS_DICE if game.tuned else Model.BOSS_DICE)))[d][side]
    rolled = game.boss_sides.size() == 3 and game.boss_sides[d] == side
   else:
    var build: Array = game.heroes[dice_hero].build if in_fight else builds[dice_hero]
    id = build[d][side]; current = Model.FACES[id]
    original = Model.FACES[game.initial_builds[dice_hero][d][side]] if in_fight else current
    rolled = in_fight and game.heroes[dice_hero].rolls[d] == side
   var changed := current != original
   var title: String = "SIDE %d%s\n%s" % [side+1," · ROLLED" if rolled else "",current]
   if changed: title += "\n★ was " + original
   var b := button(title,Vector2(130+d*420,240)+Vector2(NET[side])*104,Vector2(102,102),func(): dice_inspected = Vector2i(d,side); rebuild(),GOLD if changed else (Color("9fc7e6") if rolled else MUTED))
   b.clip_text = true;b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS; b.add_theme_font_size_override("font_size",12)
   b.size = Vector2(102,102)
   b.name = "ViewDie%dSide%d" % [d,side]
   if dice_inspected == Vector2i(d,side):
    var selected_style := style(Color("2d3a47"),Color("e9d5a7"));selected_style.set_border_width_all(2);b.add_theme_stylebox_override("normal",selected_style)
   b.tooltip_text = game.boss_help(current) if is_boss else face_help(id)
 var d: int = dice_inspected.x; var side: int = dice_inspected.y
 var info: String
 if is_boss:
  var action: String = game.boss_dice()[d][side]
  info = "DIE %s · SIDE %d · %s\n%s\nCurrent rolled result: %s" % [["I","II","III"][d],side+1,action,short_boss_help(action),game.boss_rolls[d]]
 else:
  var h: Dictionary = game.heroes[dice_hero] if in_fight else {}
  var build: Array = h.build if in_fight else builds[dice_hero]
  var id: int = build[d][side]
  info = "DIE %s · SIDE %d · %s\n%s" % [["I","II","III"][d],side+1,Catalog.display_name(id),short_face_help(id)]
  if in_fight:
   info += "\nRecorded roll: %s · %s. Installed sides may change while an earlier recorded result stays valid." % [Model.FACES[game.face(dice_hero,d)],"reaction held" if d in h.reaction else ("channel held" if not h.channel.is_empty() and h.channel.die == d else ("spent" if h.used[d] else "ready"))]
 var details := RichTextLabel.new();details.name = "DiceNetDetails";details.position = Vector2(130,675);details.size = Vector2(1175,117);details.add_theme_font_size_override("normal_font_size",17);details.text = info;ui.add_child(details)
 button("Back to game",Vector2(1060,815),Vector2(255,45),func(): show_dice = false; rebuild())


func explain_invalid(f: int, target: int, cell: Vector2i) -> String:
 var actor: int = game.active
 if game.heroes[actor].get("rooted",0) > 0 and Catalog.category(f) == "Movement":return "Rooted prevents voluntary movement until the boss’s next turn. Attacks, Block and forced movement still work."
 if game.heroes[actor].used[selected]:return "This die is spent. Select another ready die; all available dice roll again next round."
 if f == 0 and not game.reward:return "Soul is OFF. Enable Blank movement above your dice or in Game options."
 if f == 0 and game.v("soul.move") <= 0:return "Blank movement is set to 0 in the balance workshop."
 if f == 0 and game.reward and game.soul_remaining(actor) <= 0:return "Blank movement used for this turn. It refreshes at this hero’s next own turn."
 if f in [2,3,53,54,57,0]: return "No legal path to that cell. Occupied cells block normal movement; Stride must stay straight."
 if target < 0:return "Choose a unit, not an empty cell, for this face."
 if target == actor and f not in [7,55]:return "This ability cannot target its user."
 var reach: int = game.face_range(f)
 if game.distance(actor,target) > reach:return "Out of range: target is %d away; this face reaches %d." % [game.distance(actor,target),reach]
 if f in [15,19,35,58] and not game.sight(actor,target,reach):return "Line of sight is blocked by a unit or corner."
 if f == 58 and target < 3 and game.heroes[target].hp <= 0:return "Exchange requires a standing ally; this hero is Downed."
 return "That target is unavailable for this face. Check its description and any forced next die."


func save_preset() -> void:
 if gifts.any(func(pool):return pool.size() != 2):hint = "Choose two bonus faces per hero before saving a preset."; rebuild(); return
 for hero in range(3):
  if Model.validate(builds[hero],gifts[hero],balance_values) != "":hint = "Fix illegal builds before saving.";rebuild();return
 var file := FileAccess.open("user://ash_build_preset.json",FileAccess.WRITE)
 if not file: hint = "Could not save preset."; rebuild(); return
 file.store_string(JSON.stringify({"builds":builds,"gifts":gifts,"balanced":balanced,"test_soul":reward_soul}));file.close()
 hint = "Saved all three heroes’ builds on this device."; rebuild()

func load_preset() -> void:
 if not FileAccess.file_exists("user://ash_build_preset.json"):hint = "No saved preset on this device yet."; rebuild(); return
 var saved := Preset.decode(FileAccess.get_file_as_string("user://ash_build_preset.json"),balance_values)
 if saved.error != "":hint = saved.error;rebuild();return
 builds = saved.builds;gifts = saved.gifts;balanced = saved.balanced;reward_soul = saved.test_soul;draft_modal = false
 hint = "Loaded all three heroes’ saved builds.";rebuild()


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
 if training_step == 6:return int(game.heroes[0].get("soul_moves_used",0)) > 0
 if training_step == 7:return game.heroes[0].used[0] and game.heroes[0].pos not in game.brand_cells
 return game.heroes[0].used[0]

func next_lesson() -> void:
 if not lesson_done():return
 if training_step < LESSON_FACES.size()-1:training_step += 1;prepare_lesson()
 else:
  for hero in range(3):
   if gifts[hero].size() != 2:gifts[hero] = [19,37];builds[hero] = Model.bonus_build(gifts[hero],balance_values)
  training = false;lab = false;open_setup()

func lab_setup_ui() -> void:
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = Vector2(1440,900);ui.add_child(shade)
 label_at("LAB · COMBINE TWO ABILITIES",Vector2(160,180),30,GOLD,1100,true)
 label_at("Die I is your selected test face. Choose the result for Die II, then reset the fixture.\nThese overrides are for testing combinations; normal builds are preserved.",Vector2(165,250),18,MUTED,1100,false,true)
 var picker := OptionButton.new();picker.position = Vector2(165,355);picker.size = Vector2(800,48)
 for id in range(Model.FACES.size()):picker.add_item(Catalog.display_name(id),id)
 picker.select(lab_support);picker.item_selected.connect(func(index):lab_support = index);ui.add_child(picker)
 button("Apply and reset test",Vector2(165,460),Vector2(400,50),func(): show_lab_setup = false;reset_lab())
 button("Back",Vector2(585,460),Vector2(380,50),func():show_lab_setup = false;rebuild(),MUTED)


func soul_toggle(at: Vector2, in_lab: bool, width: float = 0) -> void:
 var toggle := CheckButton.new();toggle.name = "TestSoulToggle"
 toggle.text = "Soul: Blank → Move %d · " % balance_number("soul.move") + ("ON" if (game.reward if in_lab else reward_soul) else "OFF")
 toggle.position = at;toggle.size = Vector2(width if width > 0 else (380 if in_lab else 430),30 if in_lab else 44)
 toggle.add_theme_font_size_override("font_size",14)
 toggle.button_pressed = game.reward if in_lab else reward_soul
 toggle.tooltip_text = "Each hero may spend %d rolled Blanks as Move %d per own turn. Toggling does not refill uses." % [balance_number("soul.uses"),balance_number("soul.move")]
 toggle.toggled.connect(func(enabled):
  set_soul_enabled(enabled,in_lab))
 ui.add_child(toggle)


func set_soul_enabled(enabled: bool, live: bool = true) -> void:
 reward_soul = enabled
 if live and page == "battle":
  game.reward = enabled
  game.record_event("info","Blank → Move %d " % game.v("soul.move") + ("enabled: %d conversions per hero turn." % game.v("soul.uses") if enabled else "disabled: Blanks have no movement effect."))
 hint = "Blank → Move %d is " % balance_number("soul.move") + ("ON. Select a rolled Blank, then a highlighted cell. %d conversions per hero turn." % balance_number("soul.uses") if enabled else "OFF. Rolled Blanks cannot be spent for movement.")
 rebuild()

func options_ui() -> void:
 overlay()
 label_at("GAME OPTIONS",Vector2(399,258),28,GOLD,600,true)
 var enabled: bool = game.reward if page == "battle" else reward_soul
 button("Blank → Move %d: " % balance_number("soul.move") + ("ON  ·  click to turn OFF" if enabled else "OFF  ·  click to turn ON"),Vector2(399,319),Vector2(575,48),func(): set_soul_enabled(not enabled),Color("82c8b9"))
 label_at("ON: %d Blank conversions per hero turn, each Move %d.\nOFF disables conversion. Switching off/on does not refill uses." % [balance_number("soul.uses"),balance_number("soul.move")],Vector2(399,383),15,Color("dce6ee"),575,false,true)
 button("Balance workshop · edit ability & passive values",Vector2(399,444),Vector2(575,43),open_balance_editor,Color("82c8b9"))
 button("Sound: " + ("OFF" if muted else "ON"),Vector2(399,503),Vector2(275,43),func(): muted = not muted; music.stream_paused = muted; audio.volume_db = -80 if muted else 0; rebuild(),MUTED)
 button("Audio / display settings",Vector2(689,503),Vector2(285,43),open_audio_settings,MUTED)
 button("Combat impact effects: "+("ON" if combat_effects else "OFF"),Vector2(399,552),Vector2(575,40),func():combat_effects = not combat_effects;rebuild(),MUTED)
 button("Back to game",Vector2(399,607),Vector2(575,46),func(): show_options = false; rebuild())


func portrait_region(id: int) -> Rect2:
 var half := Vector2(PORTRAITS.get_size())/2.0
 return Rect2(Vector2(id%2,id/2)*half,half)

func draw_portrait(id: int, rect: Rect2) -> void:
 draw_texture_rect_region(PORTRAITS,rect,portrait_region(id))

func portrait_at(id: int, at: Vector2, dimensions: Vector2) -> void:
 var atlas := AtlasTexture.new();atlas.atlas = PORTRAITS;atlas.region = portrait_region(id)
 var picture := TextureRect.new();picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;picture.texture = atlas;picture.position = at;picture.size = dimensions;picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED;picture.mouse_filter = Control.MOUSE_FILTER_IGNORE;ui.add_child(picture)


func draw_unit_sprite(id: int, rect: Rect2) -> void:
 if id == 3 and page == "battle" and game.encounter_id == "cantor":
  draw_texture_rect(CANTOR_PHASE if game.phase_two else CANTOR_SPRITE,rect,false)
  var center := rect.get_center()
  if game.resonance > 0:draw_arc(center,48+sin(t*3)*3,0,TAU,48,Color(0.4,0.85,0.95,0.2+game.resonance*0.08),2)
  if game.core_open:
   draw_arc(center+Vector2(0,8),18+sin(t*5)*3,0,TAU,24,Color("fff0b5"),3)
   draw_rect(rect.grow(-8),Color(0.95,0.82,0.4,0.55),false,2)
  return
 if id == 3 and page == "battle" and game.encounter_id == "nugh":
  draw_texture_rect(NUGH_PHASE if game.phase_two else NUGH_SPRITE,rect,false);return
 if id == 3 and page == "battle" and game.phase_two:
  draw_texture_rect(BOSS_PHASE_TWO,rect,false);return
 var half := Vector2(SPRITES.get_size())/2.0
 draw_texture_rect_region(SPRITES,rect,Rect2(Vector2(id%2,id/2)*half,half))

func menu_ui() -> void:
 overlay()
 label_at("GAME MENU",Vector2(399,255),27,GOLD,600,true)
 button("Tutorial / Ability Lab",Vector2(399,325),Vector2(275,45),func():show_menu = false;start_lab(),Color("82c8b9"))
 button("Guided practice",Vector2(689,325),Vector2(285,45),func():show_menu = false;start_training(),Color("82c8b9"))
 button("What changed",Vector2(399,388),Vector2(275,45),func():show_menu = false;show_changes = true;rebuild())
 button("Rules",Vector2(689,388),Vector2(285,45),func():show_menu = false;show_help = true;rebuild(),MUTED)
 button("Game options",Vector2(399,451),Vector2(275,45),func():show_menu = false;open_settings(),MUTED)
 button("Rebuild / restart",Vector2(689,451),Vector2(285,45),func():show_menu = false;page = "forge";selected = -1;rebuild(),MUTED)
 button("Return to battle",Vector2(399,570),Vector2(575,46),func():show_menu = false;rebuild())


func active_balance() -> Dictionary:
 return game.balance if page == "battle" else balance_values
func balance_number(key: String) -> int:
 return Balance.value(active_balance(),key,game.tuned if page == "battle" else balanced)
func load_balance_profile() -> void:
 var path := "user://ash_balance_profile.json"
 if not FileAccess.file_exists(path):return
 var parser := JSON.new()
 if parser.parse(FileAccess.get_file_as_string(path)) != OK:hint = "Saved balance profile was invalid; defaults loaded.";return
 var decoded = parser.data
 var values = decoded.get("values",{}) if decoded is Dictionary else null
 if Balance.validate(values) == "":
  balance_values = values.duplicate(true)
  if decoded.get("base_rules","") in ["tuned","original"]:balanced = decoded.base_rules == "tuned"
 else:hint = "Saved balance profile was invalid; defaults loaded."
func open_balance_editor() -> void:
 if is_instance_valid(balance_editor):return
 show_options = false;show_menu = false;show_lab_tools = false;rebuild()
 var editor = BalanceEditor.new();balance_editor = editor;editor.configure(balance_values,balanced,page == "battle")
 editor.closed.connect(func():balance_editor = null;editor.queue_free();rebuild())
 editor.apply_requested.connect(func(values):apply_balance_profile(values,editor))
 add_child(editor)
func apply_balance_profile(values: Dictionary, editor: Control = null) -> void:
 var error := Balance.validate(values)
 if error != "":
  if is_instance_valid(editor):editor.set_error(error)
  return
 var file := FileAccess.open("user://ash_balance_profile.json",FileAccess.WRITE)
 if file == null:
  if is_instance_valid(editor):editor.set_error("Could not save this profile. Nothing was applied.")
  return
 var base: bool = editor.tuned if is_instance_valid(editor) else balanced
 file.store_string(JSON.stringify({"format":"ash-and-oath-balance-v1","base_rules":"tuned" if base else "original","values":values},"  "));file.close()
 balanced = base
 balance_values = values.duplicate(true);balance_editor = null
 if is_instance_valid(editor):editor.queue_free()
 selected = -1;draft_error = ""
 if page == "battle":
  if lab:reset_lab()
  else:
   var legal := true
   for i in range(3):
    if Model.validate(builds[i],gifts[i],balance_values) != "":legal = false
   if legal:begin()
   else:page = "forge";hint = "Profile saved. Adjust your dice to the new body / copy limits before entering.";rebuild()

 else:hint = "Balance profile saved. The next encounter uses these values.";rebuild()
func draw_pixel_fire(center: Vector2, alpha: float, seed_value: int, burst: bool = false) -> void:
 for flame in range(5 if burst else 3):
  var phase := fmod(t*7.0+seed_value*0.71+flame*1.3,3.0)
  var height := 16+int(phase)*8+(16 if burst else 0)
  var x := int(center.x)+(-20+flame*10 if burst else -12+flame*12)
  var bottom := int(center.y)+20
  draw_rect(Rect2(x-4,bottom-height,8,height),Color(0.92,0.29,0.12,alpha*0.85))
  draw_rect(Rect2(x-4,bottom-height+8,8,maxi(4,height-8)),Color(1.0,0.62,0.17,alpha))
  draw_rect(Rect2(x,bottom-12,4,12),Color(1.0,0.88,0.43,alpha))
  draw_rect(Rect2(x,bottom-height-8-int(phase)*4,4,4),Color(1.0,0.68,0.25,alpha*0.8))

func inspection_at_mouse() -> String:
 return inspection_at(get_local_mouse_position())
func inspection_at(at: Vector2) -> String:
 if page != "battle" or show_menu or show_lab_tools or show_options or show_lab_setup or show_dice or show_turn or show_changes or show_help or show_history or not game.pending.is_empty():return ""
 if Rect2(1112,151,304,687).has_point(at) and hover_key != "":return hover_key
 for die in range(3):
  if Rect2(760+die*220,66,208,36).has_point(at):return "boss:"+str(die)
 if Rect2(760,110,328,28).has_point(at):return "phase"
 if Rect2(760,780,328,48).has_point(at):return "effects"
 if game.active < 3:
  for die in range(3):
   if Rect2(760,DIE_Y+die*DIE_STEP,328,88).has_point(at):return "hero:"+str(die)
 return ""
func apply_hover_inspection() -> void:
 combat_inspected = -1;inspect_action = "";show_active_effects = false;detailed_ability = false
 var key := inspection_at_mouse()
 if key.begins_with("hero:"):combat_inspected = game.face(game.active,int(key.get_slice(":",1)))
 elif key.begins_with("boss:"):inspect_action = game.boss_rolls[int(key.get_slice(":",1))]
 elif key == "phase":inspect_action = "__phase__"
 elif key == "effects":show_active_effects = true
func combat_details_ui() -> void:
 var backing := Panel.new();backing.name = "CombatAbilityWindow";backing.position = Vector2(1112,151);backing.size = Vector2(304,687);backing.add_theme_stylebox_override("panel",style(Color("192936"),GOLD));ui.add_child(backing)
 var phase: bool = inspect_action == "__phase__"
 var heading := "ACTIVE EFFECTS" if show_active_effects else ("BOSS PHASES" if phase else ("BOSS ABILITY" if inspect_action != "" else "ABILITY · HOVER"))
 label_at(heading,Vector2(1130,168),13,GOLD,260)
 var title: String = game.unit_name(game.active) if show_active_effects else ("Half-health upgrades" if phase else (inspect_action if inspect_action != "" else Model.FACES[combat_inspected]))
 var title_label := label_at(title,Vector2(1130,203),21,Color("f0e3c9"),264,true,true);title_label.max_lines_visible = 2
 if not show_active_effects and inspect_action == "":label_at(Catalog.classification(combat_inspected),Vector2(1130,265),14,color_for_face(combat_inspected),264)
 var text := RichTextLabel.new();text.name = "ActiveEffectDetails" if show_active_effects else ("BossActionDetails" if inspect_action != "" else "CombatAbilityDetails");text.position = Vector2(1130,300);text.size = Vector2(264,406);text.add_theme_font_size_override("normal_font_size",18);text.bbcode_enabled = true
 if show_active_effects:text.text = game.status_description(game.active)
 elif phase:text.text = phase_help()
 elif inspect_action != "":text.text = game.boss_help(inspect_action) if detailed_ability else boss_ability_summary(inspect_action)
 else:
  text.text = face_help(combat_inspected) if detailed_ability else short_face_help(combat_inspected)
  if not detailed_ability and (combat_inspected in range(34,43) or combat_inspected in [15,17,19,50,51,52,55]):
   var numeric: Array = game.numeric_faces(game.heroes[game.active].gambler) if game.active < 3 and combat_inspected != 17 else game.numeric_faces(false)
   text.text += "\n\n[color=#91a0af]Value die: "+" · ".join(numeric)+"[/color]"
 ui.add_child(text)
 label_at("Move away to return to the combat log",Vector2(1130,778),12,MUTED,264)

func draw_hp_dots(center: Vector2, hp: int, maximum: int, color: Color) -> void:
 var shown := mini(maximum,12)
 for dot in range(shown):
  var offset := Vector2((dot-(shown-1)*0.5)*6,0)
  draw_circle(center+offset,2.3,color if dot < hp else Color("3d434b"))
 if maximum > 12:draw_string(BODY,center+Vector2(-20,14),"%d/%d" % [hp,maximum],HORIZONTAL_ALIGNMENT_LEFT,-1,10,color)

func draw_boss_vitals(center: Vector2) -> void:
 var rect := Rect2(center+Vector2(-76,64),Vector2(152,24))
 draw_rect(rect,Color(0.06,0.07,0.1,0.92))
 draw_rect(rect,Color("d38b55") if game.phase_two else Color("90766e"),false,1)
 var text := "%d/%d HP · %d Block" % [game.boss.hp,game.boss.max_hp,game.boss.block]
 draw_string(BODY,rect.position+Vector2(2,17),text,HORIZONTAL_ALIGNMENT_CENTER,148,13,Color("f1dfc2"))

func draw_phase_transition(fx: Dictionary) -> void:
 var progress: float = 1.0-fx.life/fx.length
 var alpha: float = smoothstep(0.0,0.1,progress)*(1.0-smoothstep(0.65,1.0,progress))
 var center := effect_center(3)
 for ring in range(3):
  var radius := 38.0+progress*100.0+ring*14.0
  draw_arc(center,radius,0,TAU,48,Color(0.4,0.85,1.0,alpha*(0.6-ring*0.12)) if game.encounter_id == "cantor" else (Color(0.75,0.55,1.0,alpha*(0.6-ring*0.12)) if game.encounter_id == "nugh" else Color(1.0,0.48+ring*0.1,0.2,alpha*(0.6-ring*0.12))),3)
 for spark in range(12):
  var at := center+Vector2.from_angle(spark*TAU/12)*(28+progress*110)
  draw_rect(Rect2(at,Vector2.ONE*4),Color(1.0,0.77,0.35,alpha))
 if game.encounter_id == "hollow":draw_pixel_fire(center,alpha,7,true)
 # The announcement sits below the boss-intent bar, beside the arena; it does not intercept clicks.
 draw_rect(Rect2(760,126,648,14),Color(0.3,0.12,0.09,alpha*0.9))
 draw_string(BODY,Vector2(760,137),"PHASE II · "+game.boss_name().to_upper(),HORIZONTAL_ALIGNMENT_CENTER,648,12,Color(1.0,0.8,0.45,alpha))

func test_boss_phase_two() -> void:
 show_lab_tools = false
 game.begin_action(-1,"Lab phase-II test",3)
 var threshold: int = maxi(1,int(floor(game.boss.max_hp*game.v("boss.phase.percent")/100.0)))
 game.damage(3,maxi(0,game.boss.hp-threshold),true,"Lab phase-II test")
 game.report_changes();selected = -1;rebuild()

func selected_die_help(die: int) -> String:
 var h: Dictionary = game.heroes[game.active]
 if h.used[die]:return "This die is spent / held. Choose a READY die. Available dice roll again at the start of the next round."
 var face: int = game.face(game.active,die)
 if face == 0:
  if h.get("rooted",0) > 0:return "ROOTED: no voluntary movement until the boss’s next turn. Your Blank allowance is not consumed."
  if not game.reward:return "Blank movement is OFF. Turn Soul ON above the dice to enable it."
  if game.soul_remaining(game.active) <= 0:return "Blank movement used this turn. It refreshes at this hero’s next own turn."
  return "Blank → Move %d. Click a highlighted empty cell. %d/%d uses remain this own turn." % [game.v("soul.move"),game.soul_remaining(game.active),game.v("soul.uses")]
 return short_face_help(face)

func draw_hero_debuffs(id: int, center: Vector2) -> void:
 var h: Dictionary = game.heroes[id]
 if h.hp <= 0 or h.dead:return
 if h.get("rooted",0) > 0:
  var pulse := 0.75+sin(t*2.6)*0.15
  draw_arc(center+Vector2(0,19),25,0,TAU,24,Color(0.7,0.47,0.22,pulse),2)
  for sign_value in [-1,1]:
   var root := PackedVector2Array([center+Vector2(sign_value*29,29),center+Vector2(sign_value*18,21),center+Vector2(sign_value*23,10),center+Vector2(sign_value*11,3),center+Vector2(sign_value*15,-8)])
   draw_polyline(root,Color(0.3,0.22,0.13,pulse),5)
   draw_polyline(root,Color(0.85,0.65,0.29,pulse),2)
   draw_line(center+Vector2(sign_value*18,21),center+Vector2(sign_value*7,15),Color("b9984f"),2)
  for link in range(4):draw_rect(Rect2(center+Vector2(-21+link*11,16),Vector2(9,6)),Color("dac89d"),false,1.5)
  var badge := center+Vector2(-27,-24)
  draw_rect(Rect2(badge-Vector2(8,8),Vector2(16,16)),Color("332c21"))
  draw_line(badge+Vector2(0,-5),badge+Vector2(0,5),Color("edcb76"),2)
  for branch in [-1,1]:
   draw_line(badge, badge+Vector2(branch*5,4),Color("edcb76"),2)
   draw_line(badge+Vector2(0,-1),badge+Vector2(branch*4,-4),Color("edcb76"),2)
 if h.get("poison",0) > 0:
  draw_arc(center+Vector2(0,19),23,0,TAU,24,Color(0.45,0.75,0.22,0.65),2)
  for mote in range(6):
   var rise := fmod(t*0.65+mote/6.0,1.0)
   var at := center+Vector2(sin(mote*2.2+t)*23,22-rise*55)
   draw_rect(Rect2(at,Vector2(4,4)),Color(0.65,0.9,0.3,sin(rise*PI)*0.9))
  draw_string(BODY,center+Vector2(-26,54),"POISON "+str(h.poison),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("b7e86d"))
 if game.hero_weakness(h) > 0:
  for mote in range(5):
   var progress: float = fmod(t*0.35+mote*0.2,1.0)
   var at := center+Vector2(sin(mote*1.8+t)*25,18-progress*48)
   draw_rect(Rect2(at,Vector2(4,4)),Color(0.74,0.4,0.9,sin(progress*PI)*0.7))
  var badge := center+Vector2(27,-24)
  draw_rect(Rect2(badge-Vector2(9,11),Vector2(18,22)),Color("2f203d"))
  draw_line(badge+Vector2(-4,7),badge+Vector2(-1,1),Color("d7a2ed"),3)
  draw_line(badge+Vector2(2,-2),badge+Vector2(5,-8),Color("d7a2ed"),3)
  draw_line(badge+Vector2(-7,3),badge+Vector2(0,7),Color("d7a2ed"),2)
  draw_line(badge+Vector2(-5,0),badge+Vector2(5,-1),Color("f28c9e"),2)

func restore_hero_build() -> void:
 var restored: Array = Model.bonus_build(gifts[build_hero],balance_values) if gifts[build_hero].size() == 2 else Model.default_build(balance_values)
 if restored.is_empty():hint = "The selected bonus designs cannot fit this balance profile. Choose different designs or adjust the limits."
 else:builds[build_hero] = restored;hint = "Restored a legal starter build with your selected bonus designs equipped."
 rebuild()

func short_face_help(f: int) -> String:
 var copy := AbilityCopy.new();copy.values = active_balance();copy.tuned = game.tuned if page == "battle" else balanced
 var text: String = copy.face(f)
 var key := "face%d.numeric_multiplier" % f
 if Balance.INDEX.has(key):
  var multiplier: int = balance_number(key);var bonus: int = balance_number("face%d.numeric_bonus" % f)
  if multiplier != 1 or bonus != 0:text += "\n\nCustom value: roll ×%d, then +%d." % [multiplier,bonus]
 return text

func select_combat_die(d: int) -> void:
 var h: Dictionary = game.heroes[game.active]
 friendly_confirm = -1;show_active_effects = false;detailed_ability = false;inspect_action = ""
 if selected >= 0 and game.face(game.active,selected) == 6 and selected != d and not h.used[selected]:
  var reason: String = game.focus_reason(selected,d)
  if reason != "":
   hint = reason;roll_feedback = {"actor":game.active,"text":reason};combat_inspected = game.face(game.active,d)
  elif game.hero_action(selected,d):
   selected = game.forced_die;combat_inspected = game.face(game.active,d)
  rebuild();return
 combat_inspected = game.face(game.active,d)
 if h.used[d]:
  selected = game.forced_die
  roll_feedback = {"actor":game.active,"text":"Die %s is spent / held. Inspect it here, or choose a READY die." % ["I","II","III"][d]}
 elif game.forced_die < 0 or game.forced_die == d:
  selected = d;shove_target = -1;roll_feedback = {};hint = selected_die_help(d)
 rebuild()

func combat_reroll_ui() -> void:
 var h: Dictionary = game.heroes[game.active]
 var window: String = game.reroll_window_reason()
 var reason: String = game.reroll_reason(selected)
 var caption := ""
 if game.forced_die >= 0:caption = "REROLL PAUSED · %d saved\nResolve the Focus result first" % h.rerolls
 elif not h.opening:caption = "REROLL CLOSED · %d saved\nAlready acted · usable next own turn" % h.rerolls
 elif h.rerolls < game.v("hero.reroll_cost"):caption = "NO REROLL CHARGES\nStarting charges do not refill each round"
 elif selected < 0:caption = "REROLL OPEN · %d charges\nSelect a ready die" % h.rerolls
 elif reason != "":caption = "CANNOT REROLL THIS DIE\n"+reason
 else:caption = "Reroll selected · %d charges\nOPEN · before your first action" % h.rerolls
 var b := button(caption,Vector2(760,612),Vector2(328,58),func():
  if game.action_reroll(selected):
   combat_inspected = game.face(game.active,selected);show_active_effects = false;inspect_action = "";detailed_ability = false
   hint = "Die %s rerolled → %s" % [["I","II","III"][selected],Model.FACES[combat_inspected]]
   roll_feedback = {"actor":game.active,"text":hint}
  rebuild(),Color("82c8b9"),reason != "")
 b.name = "ActionReroll";b.add_theme_font_size_override("font_size",14)
 b.tooltip_text = reason if reason != "" else "Roll all six sides again for %d charge(s). The same result can appear again." % game.v("hero.reroll_cost")
 if window != "":b.tooltip_text = window

func weak_point_ready(id: int) -> bool:
 if id not in range(3) or game.heroes.size() != 3:return false
 var h: Dictionary = game.heroes[id]
 return not h.dead and h.hp > 0 and h.backstab > 0 and h.backstab >= game.round_no

func draw_weak_point(p: Vector2) -> void:
 var at := p+Vector2(27,0)
 draw_rect(Rect2(at-Vector2(10,10),Vector2(20,20)),Color("3b3020"))
 draw_arc(at,6,0,TAU,16,GOLD,2)
 for dir in Model.DIRS:draw_line(at+Vector2(dir)*4,at+Vector2(dir)*10,GOLD,2)
 draw_arc(p,29,0,TAU,32,Color(GOLD,0.5+sin(t*2.0)*0.15),1)

func phase_help() -> String:return game.phase_description()

func short_boss_help(action: String) -> String:
 if game.encounter_id in ["nugh","cantor"]:return game.default_boss_help(action)
 match action:
  "Smoking Strike","Strike":return "Hit the closest hero within %d for %d.\n\nEven blocked: ignite their cell. Existing fire detonates for %d extra normal damage. End your turn on fire: %d damage." % [game.v("boss.Strike.range"),game.v("boss.Strike.damage"),game.v("boss.smoking.fire_damage"),game.v("boss.fire.end_turn")]
  "Cinder Brand":return "Mark a %s under a hero within %d.\n\nAt next boss turn start: %d damage to heroes still inside. Move away to evade." % ["%d×%d square" % [game.v("boss.brand.radius")*2+1,game.v("boss.brand.radius")*2+1] if game.phase_two else "cross",game.v("boss.brand.range"),game.v("boss.brand.damage")]
  "Ashen Chain":return "Pull the closest hero within %d up to %d spaces closer. Remove %d Block." % [game.v("boss.chain.range"),game.v("boss.chain.move"),game.v("boss.chain.strip")]+("\n\nRooted %d until the next boss turn. No voluntary movement." % game.v("boss.chain.root") if game.phase_two else "\n\nPhase I: no Rooted.")
  "Furnace Roar":return "Hit every standing hero within %d for %d damage, then push survivors %d space(s) away.\n\nBlocked movement stops the push; no collision damage." % [game.v("boss.Furnace Roar.range"),game.v("boss.Furnace Roar.damage"),game.v("boss.roar.push")]
  "Advance":return "Move %d toward the highest-HP standing hero. Ties are random.\n\nAlready adjacent to any tied highest-HP hero? Stay and gain %d Block." % [game.v("boss.advance.move"),game.v("boss.advance.block")]
  "Drive Back":return "Hit within %d for %d. Push %d spaces directly away.\n\nCollision: %d unavoidable damage + Stunned. Push direction is automatic." % [game.v("boss.Drive Back.range"),game.v("boss.Drive Back.damage"),game.v("boss.push.move"),game.v("boss.push.collision")]
  "Skirmish":return "Move %d toward the nearest hero, then hit an adjacent hero for %d." % [game.v("boss.skirmish.move"),game.v("boss.Skirmish.damage")]
  "Sweep":return "Hit every hero within %d for %d, including Downed heroes. Each hero is hit once." % [game.boss_range("Sweep"),game.v("boss.Sweep.damage")]
  "Distort":return "Apply Weakness %d until next boss turn. Target: highest HP within %d; otherwise closest in reach." % [game.v("boss.distort.weakness"),game.v("boss.distort.range")]
  "Grave Tithe":return "Steal %d Block from each standing hero within %d. Gain the stolen Block, capped at %d. No HP damage." % [game.v("boss.tithe.strip"),game.v("boss.tithe.range"),game.v("boss.tithe.cap")]
  "Fracture":return "Closest hero within %d chooses %d installed face(s) to become Blank for this fight. Already recorded results stay." % [game.v("boss.fracture.range"),game.v("boss.fracture.count")]
  "Brace":return "Gain %d Block. Remaining Block expires at the next boss turn." % game.v("boss.brace.block")
  "Bound":return "This boss result is suppressed by Lethargic Bind."
 return "All three dice resolved. End the boss turn."

func setup_combat_audio() -> void:
 footstep_audio = AudioStreamPlayer.new();footstep_audio.bus = &"SFX";footstep_audio.volume_db = -23;footstep_audio.stream = make_footstep_sound();add_child(footstep_audio)
 combat_audio = AudioStreamPlayer.new();combat_audio.bus = &"SFX";combat_audio.volume_db = -16;add_child(combat_audio)
 impact_sound = make_impact_sound(false);shield_sound = make_impact_sound(true);scream_sound = make_scream_sound();bell_sound = make_bell_sound()

func make_impact_sound(shield: bool) -> AudioStreamWAV:
 var wave := AudioStreamWAV.new();wave.mix_rate = 22050;wave.format = AudioStreamWAV.FORMAT_16_BITS
 var length := 0.22 if shield else 0.3
 var frames := int(22050*length);var bytes := PackedByteArray();bytes.resize(frames*2)
 for i in range(frames):
  var x: float = float(i)/22050.0;var envelope: float = pow(1.0-float(i)/frames,3)
  var noise: float = sin(i*12.9898)*sin(i*4.1414)
  var sound_sample: float = (sin(x*TAU*680)+0.35*sin(x*TAU*1170)) if shield else (sin(TAU*(100*x-90*x*x))+noise*0.55)
  bytes.encode_s16(i*2,int(clampf(sound_sample*envelope*14000,-32767,32767)))
 wave.data = bytes;return wave

func draw_boss_impact(fx: Dictionary) -> void:
 var p := effect_center(fx.target);var progress: float = 1.0-fx.life/fx.length
 var alpha: float = sin(progress*PI)
 if fx.kind == "impact":
  var color := Color("f3b477") if fx.damage > 0 else Color("8dc7eb")
  var radius := 13.0+progress*32.0
  draw_arc(p,radius,0,TAU,20,Color(color,alpha),3)
  for n in range(6):
   var dir := Vector2.from_angle(n*TAU/6+0.2)
   draw_line(p+dir*radius,p+dir*(radius+8),Color(color,alpha),3)
  return
 var origin_point := effect_center(fx.source);var delta := origin_point.direction_to(p);var side := delta.orthogonal()
 var at := origin_point.lerp(p,smoothstep(0.0,0.45,progress))
 draw_line(at-side*17,at+side*17,Color(1,0.8,0.52,alpha),7,true)
 draw_line(origin_point,at,Color(0.95,0.39,0.2,alpha*0.6),8,true)
 if fx.action in ["Toll of Reckoning","Hushed Chime"]:
  for ring in range(4):draw_arc(origin_point,20+progress*150+ring*13,0,TAU,48,Color(0.4,0.9,1.0,alpha*(0.7-ring*0.1)),3)
 elif fx.action == "Screaming Chorus":
  for ring in range(3):draw_arc(origin_point,30+progress*145+ring*15,0,TAU,48,Color(0.8,0.6,1,alpha*(0.7-ring*0.15)),3)
 elif fx.action in ["Sweep","Furnace Roar"]:
  draw_arc(origin_point,45+progress*125,0,TAU,48,Color(1,0.55,0.25,alpha*0.55),5)
 else:
  var reach := 25.0+progress*17.0
  draw_line(p-side*reach-delta*9,p+side*reach+delta*9,Color(1,0.78,0.42,alpha),6,true)
 for spark in range(5):
  var dir := Vector2.from_angle(spark*TAU/5+t*0.2)
  var spot := p+dir*(12+progress*35)
  draw_rect(Rect2(spot,Vector2(4,4)),Color(1,0.65,0.28,alpha))

func choice_button(text: String, p: Vector2, size_px: Vector2, fn: Callable, accent: Color = GOLD, disabled: bool = false) -> Button:
 var b := button(text,p,size_px,fn,accent,disabled)
 b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;b.add_theme_font_size_override("font_size",12);b.tooltip_text = text
 return b

func draw_stunned(center: Vector2) -> void:
 var crown := center+Vector2(0,-25)
 draw_arc(crown,21,0,TAU,24,Color("927aab"),1)
 for index in range(3):
  var angle := t*2.2+index*TAU/3
  var at := crown+Vector2(cos(angle)*22,sin(angle)*8)
  var star := PackedVector2Array()
  for point in range(8):star.append(at+Vector2.from_angle(point*PI/4)*(6.0 if point%2 == 0 else 2.0))
  draw_colored_polygon(star,Color("f2d585"))

func draw_worm(id: int) -> void:
 var worm: Dictionary = game.unit_data(id)
 var center := effect_center(id)
 var frame := int(t*4+id)%2
 draw_circle(center+Vector2(0,18),18,Color(0.02,0.02,0.04,0.5))
 draw_texture_rect_region(WORM_SPRITE,Rect2(center-Vector2(24,24),Vector2(48,48)),Rect2(frame*16,0,16,16))
 draw_hp_dots(center+Vector2(-8 if worm.block > 0 else 0,29),worm.hp,worm.max_hp,Color("bed4ab"))
 if worm.block > 0:
  draw_rect(Rect2(center+Vector2(4,20),Vector2(26,16)),Color("243e50"))
  draw_string(BODY,center+Vector2(6,32),"B%d" % worm.block,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("a7d1ee"))
 var pulse := fmod(t*0.8+id*0.23,1.0)
 draw_arc(center+Vector2(11,-12),8+pulse*12,-PI*.7,PI*.3,16,Color(0.78,0.75,0.92,(1-pulse)*0.55),1.5)

func setup_panel(rect: Rect2, border: Color = Color("354653")) -> void:
 var box := Panel.new();box.position = rect.position;box.size = rect.size;box.add_theme_stylebox_override("panel",style(Color("19232e"),border));ui.add_child(box)

func setup_ui() -> void:
 label_at("CHOOSE YOUR ENCOUNTER",Vector2(48,30),32,GOLD,1100,true)
 label_at("1 · Faces chosen     →     2 · Boss & rules     →     3 · Fight",Vector2(50,87),18,Color("a6c6c4"),1250)
 setup_panel(Rect2(48,145,410,625));setup_panel(Rect2(482,145,910,625))
 label_at("BOSS",Vector2(70,162),16,GOLD,360)
 for index in range(3):
  var key: String = ["hollow","nugh","cantor"][index]
  var title: String = ["The Hollow","Nu’gh · Worm Summoner","Veyl · Brass Cantor"][index]
  var top := 198+index*182
  var card := button(("SELECTED · " if encounter == key else "CHOOSE · ")+title,Vector2(68,top),Vector2(370,38),func():encounter = key;rebuild(),GOLD if encounter == key else MUTED)
  card.name = ["EncounterHollow","EncounterNugh","EncounterCantor"][index];card.add_theme_font_size_override("font_size",16)
  var art := TextureRect.new();art.texture = [SPRITES,NUGH_SPRITE,CANTOR_SPRITE][index];art.position = Vector2(75,top+48);art.size = Vector2(78,78);art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;art.mouse_filter = Control.MOUSE_FILTER_IGNORE
  if index == 0:
   var atlas := AtlasTexture.new();atlas.atlas = SPRITES;atlas.region = Rect2(32,32,32,32);art.texture = atlas
  ui.add_child(art)
  var lesson: String = ["Read attacks, escape fire warnings and adapt at half HP.","Pursue the human-worm; control his attacking brood. Soul Link breaks at half HP.","Resonance = shared boss power. Attacks +%d; Skills / Defenses −%d. Higher power means harder bell hits. Click the meter in combat for examples." % [balance_number("cantor.attack_charge"),balance_number("cantor.calm")]][index]
  label_at(lesson,Vector2(169,top+49),15,Color("d6e0e6"),260,false,true)
 label_at("Every boss ability upgrades at half HP.",Vector2(70,740),14,Color("c1a5d9"),370)
 label_at("RULES FOR THIS FIGHT",Vector2(510,164),18,GOLD,830)
 button("Tuned numbers"+(" ✓" if balanced else ""),Vector2(510,205),Vector2(400,43),func():balanced = true;rebuild(),GOLD if balanced else MUTED)
 button("Original numbers"+(" ✓" if not balanced else ""),Vector2(930,205),Vector2(430,43),func():balanced = false;rebuild(),GOLD if not balanced else MUTED)
 label_at("Original changes The Hollow’s baseline. Nu’gh and Veyl use their own boss values.",Vector2(512,259),15,MUTED,838,false,true)
 label_at("ROLLED BLANK MOVEMENT",Vector2(512,312),16,GOLD,840)
 for index in range(3):
  var chosen: bool = not reward_soul if index == 0 else reward_soul and balance_number("soul.move") == index
  var option := button(["OFF · Blank has no movement","ON · Blank → Move 1","ON · Blank → Move 2"][index]+(" ✓" if chosen else ""),Vector2(510+index*286,348),Vector2(278,46),func():
   reward_soul = index > 0
   if index > 0:balance_values["soul.move"] = index
   rebuild(),Color("83cec1") if chosen else MUTED)
  option.name = "SetupSoul%d" % index;option.add_theme_font_size_override("font_size",14)
 label_at("%d conversion(s) per hero’s own turn. Switching this setting never grants extra dice." % balance_number("soul.uses"),Vector2(512,407),15,MUTED,838)
 var boss_hp: int = balance_number("cantor.hp") if encounter == "cantor" else (balance_number("nugh.hp") if encounter == "nugh" else balance_number("boss.hp"))
 label_at("Heroes: %d HP · %d starting reroll(s) (bank cap %d)\nBoss: %d HP · every ability upgrades at %d%% HP\nDice: minimum %d Blanks per die\nPer hero across all 3 dice: Movement %d · Defense %d · Skill %d" % [balance_number("hero.hp"),balance_number("hero.rerolls"),balance_number("hero.reroll_cap"),boss_hp,balance_number("boss.phase.percent"),balance_number("body.blanks"),balance_number("body.Movement"),balance_number("body.Defense"),balance_number("body.Skill")],Vector2(512,458),18,Color("e2e8ed"),838,false,true)
 label_at("YOUR PARTY",Vector2(512,579),16,GOLD,600)
 for hero in range(3):
  var names: Array[String] = []
  for f in gifts[hero]:names.append(Model.FACES[f]+("" if builds[hero].any(func(die):return f in die) else " (not equipped)"))
  label_at(["Vesper","Rook","Wren"][hero]+" · "+" + ".join(names),Vector2(512,618+hero*33),16,COLORS[hero],830)
 var error := ""
 for hero in range(3):
  var invalid: String = Model.validate(builds[hero],gifts[hero],balance_values)
  if gifts[hero].size() != 2:error = "Choose two faces for each hero first."
  elif invalid != "":error = invalid
 label_at(error if error != "" else "Review the boss and rules, then enter. Your chosen faces and placements are preserved.",Vector2(50,782),15,Color("edac94") if error != "" else MUTED,1320)
 button("← Change faces / dice",Vector2(48,826),Vector2(290,48),func():page = "forge";draft_modal = true;rebuild(),MUTED)
 button("View chosen dice",Vector2(358,826),Vector2(245,48),func():show_dice = true;dice_hero = 0;rebuild(),Color("9fc7e6"))
 button("Advanced numeric rules",Vector2(755,826),Vector2(317,48),open_balance_editor,Color("9fc7e6"))
 var start := button("Enter fight →",Vector2(1092,826),Vector2(300,48),begin,GOLD,error != "");start.name = "StartEncounter"

func boss_ability_summary(action: String) -> String:
 var text := short_boss_help(action)
 if not game.phase_two:
  for upgrade in game.phase_upgrades():
   if upgrade[0] == action:text += "\n\nAt half HP: "+upgrade[1];break
 return text

func make_scream_sound() -> AudioStreamWAV:
 var wave := AudioStreamWAV.new();wave.mix_rate = 22050;wave.format = AudioStreamWAV.FORMAT_16_BITS
 var frames := 6600;var bytes := PackedByteArray();bytes.resize(frames*2)
 for i in range(frames):
  var x: float = float(i)/22050.0;var envelope: float = sin(float(i)/frames*PI)*pow(1.0-float(i)/frames,2)
  var pulse: float = sin(TAU*(720*x-480*x*x)+sin(x*TAU*37)*2.0)
  bytes.encode_s16(i*2,int(pulse*envelope*10500))
 wave.data = bytes;return wave

func make_bell_sound() -> AudioStreamWAV:
 var wave := AudioStreamWAV.new();wave.mix_rate = 22050;wave.format = AudioStreamWAV.FORMAT_16_BITS
 var frames := 11025;var bytes := PackedByteArray();bytes.resize(frames*2)
 for i in range(frames):
  var x := float(i)/22050.0
  var envelope := minf(1.0,x*200)*exp(-x*8)
  var value := sin(TAU*440*x)*0.5+sin(TAU*658*x)*0.3+sin(TAU*1254*x)*0.2
  bytes.encode_s16(i*2,int(value*envelope*12000))
 wave.data = bytes;return wave

func make_footstep_sound() -> AudioStreamWAV:
 var wave := AudioStreamWAV.new();wave.mix_rate = 22050;wave.format = AudioStreamWAV.FORMAT_16_BITS
 var bytes := PackedByteArray();bytes.resize(3308*2)
 for index in range(3308):
  var x := index/22050.0
  var envelope := exp(-x*35)*(1-exp(-x*500))
  bytes.encode_s16(index*2,int((sin(TAU*(95*x-100*x*x))+sin(x*TAU*310)*0.25)*envelope*15000))
 wave.data = bytes;return wave

func play_hit_sound(kind: int) -> void:
 if kind < 0 or not is_instance_valid(combat_audio) or muted:return
 combat_audio.stream = bell_sound if kind == 3 else (scream_sound if kind == 2 else (impact_sound if kind == 1 else shield_sound))
 combat_audio.play()
