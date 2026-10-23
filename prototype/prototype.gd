extends Control

const Model = preload("res://prototype/battle.gd")
const TITLE = preload("res://prototype/assets/title.ttf")
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
var builds: Array = [Model.default_build(),Model.default_build(),Model.default_build()]
var page := "forge"
var build_hero := 0
var selected := -1
var shove_target := -1
var hover := Vector2i(-1,-1)
var ui: Control
var hint := "Choose a hero and customize their three dice. A balanced build is already equipped."
var show_help := false
var reward_soul := false
var audio: AudioStreamPlayer
var music: AudioStreamPlayer
var muted := false
var t := 0.0

func _ready() -> void:
 var theme_res := Theme.new()
 theme_res.default_font = BODY
 theme_res.default_font_size = 15
 theme = theme_res
 mouse_filter = Control.MOUSE_FILTER_PASS
 ui = Control.new(); ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(ui)
 audio = AudioStreamPlayer.new(); audio.bus = &"SFX"; add_child(audio)
 music = AudioStreamPlayer.new(); music.bus = &"Music"; music.volume_db = -22; add_child(music)
 make_audio()
 rebuild()
 if get_tree().root.has_meta("ash_restart"):
  var saved: Dictionary = get_tree().root.get_meta("ash_restart")
  get_tree().root.remove_meta("ash_restart")
  builds = saved.builds; reward_soul = saved.soul; muted = saved.muted
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
 var b := Button.new(); b.text = text; b.position = p; b.size = sz; b.disabled = disabled
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
 for c in ui.get_children(): ui.remove_child(c); c.queue_free()
 label_at("ASH & OATH",Vector2(42,26),27,GOLD,500,true)
 label_at("A DICE-BUILDING BOSS BATTLER",Vector2(44,65),11,MUTED)
 button("?  Rules",Vector2(1114,30),Vector2(112,40),func(): show_help = not show_help; rebuild())
 button("Sound " + ("off" if muted else "on"),Vector2(1236,30),Vector2(110,40),func(): muted = not muted; music.stream_paused = muted; audio.volume_db = -80 if muted else 0; rebuild())
 if page == "forge": forge_ui()
 else: battle_ui()
 if show_help: help_ui()
 queue_redraw()

func forge_ui() -> void:
 label_at("Shape what remains.",Vector2(68,110),38,Color("ece6d9"),1000,true)
 label_at("Three heroes. Three broken bodies. One soul worth fighting for.",Vector2(70,165),16,MUTED)
 for i in range(3):
  button(("◆ " if i == build_hero else "") + ["01  VESPER","02  ROOK","03  WREN"][i],Vector2(70+i*216,215),Vector2(202,48),func(): build_hero = i; rebuild(),COLORS[i])
 label_at("THE DICE FORGE",Vector2(72,295),13,GOLD)
 label_at("Click a side to choose a face from this hero’s owned pool.",Vector2(72,324),14,MUTED)
 for d in range(3):
  label_at("DIE " + ["I","II","III"][d],Vector2(82,380+d*111),15,GOLD)
  for side in range(6):
   var f: int = builds[build_hero][d][side]
   var o := OptionButton.new(); o.position = Vector2(160+side*102,369+d*111); o.size = Vector2(96,66)
   o.add_theme_font_size_override("font_size",12)
   for name in Model.FACES: o.add_item(name)
   o.select(f); o.add_theme_stylebox_override("normal",style(Color("202938"),Color(FACE_COLORS[f],0.55)))
   o.add_theme_color_override("font_color",FACE_COLORS[f])
   o.item_selected.connect(func(index): builds[build_hero][d][side] = index; rebuild())
   o.tooltip_text = face_help(f); ui.add_child(o)
 var error := Model.validate(builds[build_hero])
 label_at("✓ Legal build · " + str(18-builds[build_hero].reduce(func(a,d): return a+d.count(0),0)) + "/9 ability faces" if error == "" else error,Vector2(75,706),14,COLORS[build_hero] if error == "" else Color("ef8e87"),730)
 button("Restore balanced build",Vector2(75,756),Vector2(245,46),func(): builds[build_hero] = Model.default_build(); rebuild(),MUTED)
 label_at("YOUR INHERITANCE",Vector2(886,300),13,GOLD)
 label_at("Memory   /   Empty\nSoul          /   6 HP · 3+ Blanks per die\nBody         /   Broken Body",Vector2(886,335),16,Color("d2d8df"))
 label_at("OWNED FACE POOL",Vector2(886,445),12,GOLD)
 label_at("4 Strike   ·   2 Step   ·   1 Stride\n2 Guard   ·   1 Reaction\n1 Focus   ·   1 First Aid   ·   1 Shove",Vector2(886,474),15,MUTED)
 label_at("Each hero owns 13 ability tiles. Equip up to 9.\nAt most 3 Movement, 3 Defense and 3 Skill.\nBlank faces do nothing with the starting Soul.",Vector2(886,559),13,MUTED)
 label_at("TEST ENCOUNTER  /  THE HOLLOW",Vector2(886,662),12,GOLD)
 label_at("18 HP · 2×2 footprint · open 9×9 arena\nLocal play: you control all three heroes.\nDeployment is a provisional test layout.",Vector2(886,692),14,MUTED)
 var legal_builds: bool = builds.all(func(b): return Model.validate(b) == "")
 button("Enter the hollow   →",Vector2(884,773),Vector2(400,55),begin,GOLD,not legal_builds)

func retry(with_soul: bool = false) -> void:
 get_tree().root.set_meta("ash_restart", {"builds":builds.duplicate(true),"soul":with_soul or reward_soul,"muted":muted})
 SceneLoader.load_scene("res://prototype/prototype.tscn")

func begin() -> void:
 game.start(builds,0,reward_soul); page = "battle"; selected = -1; shove_target = -1
 hint = "Select a rolled die, then a highlighted cell or unit. Boss dice are public."
 rebuild()

func battle_ui() -> void:
 label_at("THE HOLLOW",Vector2(74,109),28,Color("ece6d9"),500,true)
 label_at("ROUND %02d   /   %s" % [game.round_no,"ENCOUNTER ENDED" if game.outcome != "" else ("THE HOLLOW’S TURN" if game.active == 3 else game.heroes[game.active].name + "’S TURN")],Vector2(76,151),12,GOLD)
 label_at("%d / 18 HP    ·    %d BLOCK" % [game.boss.hp,game.boss.block],Vector2(408,119),13,Color("d78b83"))
 var x := 74.0
 for id in game.order:
  var name_text: String = "HOLLOW" if id == 3 else game.heroes[id].name
  var init: int = game.boss.initiative if id == 3 else game.heroes[id].initiative
  label_at(("◆ " if id == game.active else "○ ") + name_text + "  " + str(init),Vector2(x,193),12,GOLD if id == game.active else MUTED,150)
  x += 141
 for i in range(3):
  var h: Dictionary = game.heroes[i]
  var cy := 245+i*103
  label_at("0%d  %s" % [i+1,h.name],Vector2(631,cy),16,COLORS[i],170,true)
  label_at("%d / 6 HP    %d BLOCK" % [h.hp,h.block],Vector2(632,cy+30),12,MUTED,170)
  var statuses: String = "DEAD" if h.dead else ("DOWNED" if h.hp == 0 else ("BROKEN  " if h.broken else ""))
  if h.weak: statuses += " WEAK"
  if not h.reaction.is_empty(): statuses += " REACTION ×"+str(h.reaction.size())
  label_at(statuses,Vector2(632,cy+53),10,GOLD,175)
  if not h.rolls.is_empty():
   var public_dice: Array[String] = []
   for d in range(3): public_dice.append(Model.FACES[game.face(i,d)].left(3) + ("·" if h.used[d] else ""))
   label_at(" / ".join(public_dice),Vector2(632,cy+75),10,MUTED,175)
 label_at("BOSS INTENT  /  RESOLVE IN ORDER",Vector2(868,199),12,GOLD)
 for d in range(3):
  var color := Color("d28a81") if game.active == 3 and d == game.boss_index else MUTED
  label_at(["I","II","III"][d] + "    " + game.boss_rolls[d],Vector2(882,237+d*38),17,color)
 label_at("ACTION DICE",Vector2(868,380),12,GOLD)
 if game.active < 3:
  var h: Dictionary = game.heroes[game.active]
  for d in range(3):
   var f: int = game.face(game.active,d)
   var text: String = ["I","II","III"][d] + "   " + Model.FACES[f] + ("  · spent" if h.used[d] else "")
   button(text,Vector2(868,416+d*61),Vector2(420,51),func():
    if selected >= 0 and game.face(game.active,selected) == 6 and selected != d:
     if game.hero_action(selected,d): selected = d if not game.heroes[game.active].used[d] else -1
    elif game.forced_die < 0 or game.forced_die == d: selected = d; shove_target = -1
    hint = face_help(game.face(game.active,d)); rebuild(),FACE_COLORS[f],h.used[d] or not game.pending.is_empty() or game.outcome != "").tooltip_text = face_help(f)
  if selected >= 0 and not h.used[selected]:
   var f: int = game.face(game.active,selected)
   if f == 4 or (f == 0 and not game.reward):
    button("Resolve selected face",Vector2(868,609),Vector2(262,41),func(): game.hero_action(selected); selected = -1; rebuild())
   button("Decline",Vector2(1140,609),Vector2(148,41),func(): game.spend(selected); selected = -1; rebuild(),MUTED)
  button("End hero turn   →",Vector2(868,674),Vector2(420,50),func(): game.finish_turn(); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 else:
  label_at("Read the intent. Resolve one face at a time.\nReactions interrupt before damage.\nMovement follows a shortest legal path.",Vector2(870,424),14,MUTED)
  button("Resolve " + (["I","II","III"][mini(game.boss_index,2)] if game.boss_index < 3 else "end of turn") + "   →",Vector2(868,571),Vector2(420,54),func(): game.boss_step(); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 label_at("CHRONICLE",Vector2(76,773),11,GOLD)
 var recent: Array = game.log_lines.slice(maxi(0,game.log_lines.size()-3))
 label_at("\n".join(recent),Vector2(76,800),13,MUTED,740)
 var hint_label := label_at("Choose a push direction:" if shove_target >= 0 else hint,Vector2(632,578),13,MUTED,180,false,true)
 hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; hint_label.size = Vector2(180,150)
 if shove_target >= 0 and selected >= 0:
  for i in range(4):
   var dir: Vector2i = Model.DIRS[i]
   button(["North","East","South","West"][i],Vector2(632+(i%2)*86,625+(i/2)*43),Vector2(80,36),func():
    if game.hero_action(selected,shove_target,dir): selected = -1; shove_target = -1
    rebuild(),GOLD,dir not in game.away_dirs(game.active,shove_target))
 label_at("Orthogonal movement · Edge adjacency\nClick a hero or the boss to target them.",Vector2(76,743),11,MUTED)
 button("Rebuild / restart",Vector2(1075,811),Vector2(213,39),func(): page = "forge"; selected = -1; rebuild(),MUTED)
 button("Settings",Vector2(868,811),Vector2(190,39),open_settings,MUTED)
 if not game.pending.is_empty(): pending_ui()
 if game.outcome != "": outcome_ui()

func open_settings() -> void:
 var options = load("res://scenes/windows/main_menu_options_window.tscn").instantiate()
 options.add_to_group("ash_settings")
 options.closed.connect(options.queue_free)
 add_child(options)
 options.show()

func face_help(f: int) -> String:
 return ["Blank: no effect. The reward Soul unlocks Move 2.","Strike: 1 damage to one adjacent unit. Weakness reduces this to zero. Allies are legal targets.","Step: move up to 1 orthogonal space.","Stride: move up to 3 spaces in one straight orthogonal direction; no turning.","Guard: gain 1 Block. Block expires at your next turn start.","Tactical Defense: stored when rolled. On being targeted, gain 1 Block and optionally step 1 before the attack.","Focus: select another unresolved die to reroll it. Keep and resolve its new face.","First Aid: heal yourself or an adjacent hero for 1. Revives Downed heroes with Broken.","Shove: choose an adjacent unit, then a directly-away direction. Moves the full boss footprint. No collision penalty."][f]

func pending_ui() -> void:
 overlay()
 var p: Dictionary = game.pending
 label_at("A MOMENT TO RESPOND",Vector2(399,260),12,GOLD)
 if p.kind == "reaction":
  label_at(game.heroes[p.hero].name + " is targeted.",Vector2(399,300),26,Color("ece6d9"),620,true)
  label_at("Spend Tactical Defense: gain 1 Block, then optionally move 1.\nThe boss rechecks its target before the attack resolves.",Vector2(399,352),15,MUTED)
  button("Block + stay",Vector2(399,421),Vector2(250,48),func(): game.react(true); rebuild())
  button("Hold reaction",Vector2(669,421),Vector2(250,48),func(): game.react(false); rebuild(),MUTED)
  for i in range(4):
   var dir: Vector2i = Model.DIRS[i]
   button("Block + " + ["North","East","South","West"][i],Vector2(399+(i%2)*270,490+(i/2)*60),Vector2(250,48),func(): game.react(true,dir); rebuild(),GOLD,not game.legal(p.hero,game.heroes[p.hero].pos+dir))
 elif p.kind == "fracture":
  label_at("Fracture · " + game.heroes[p.hero].name,Vector2(399,301),26,Color("ece6d9"),620,true)
  label_at("Choose an installed ability to replace with Blank for this fight.\nYour recorded build returns after the encounter.",Vector2(399,348),15,MUTED)
  for d in range(3):
   for side in range(6):
    var f: int = game.heroes[p.hero].build[d][side]
    button(Model.FACES[f],Vector2(377+side*98,416+d*66),Vector2(92,54),func(): game.fracture(d,side); rebuild(),FACE_COLORS[f],f == 0).add_theme_font_size_override("font_size",11)
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
 var won: bool = game.outcome == "victory"
 label_at("ENCOUNTER COMPLETE",Vector2(399,264),12,GOLD)
 label_at("A soul, reclaimed." if won else "The oath is not over.",Vector2(399,309),32,Color("ece6d9"),700,true)
 label_at("The Hollow is defeated. Each hero unlocks the boss Soul.\n6 maximum HP · 3+ Blanks per die · resolve a Blank as Move 2.\nSurviving heroes recover between encounters." if won else "All three heroes are Downed or dead.\nA clean test restart restores HP, dice and conditions.\nRebuild your dice or try the encounter again.",Vector2(399,378),16,MUTED)
 if won:
  button("Rematch with reward Soul",Vector2(399,493),Vector2(520,49),func(): retry(true))
 else:
  button("Try again",Vector2(399,493),Vector2(520,49),retry)
 button("Return to the forge",Vector2(399,556),Vector2(520,45),func(): page = "forge"; rebuild(),MUTED)

func help_ui() -> void:
 var shade := ColorRect.new(); shade.color = Color("0e141f"); shade.size = Vector2(1440,900); ui.add_child(shade)
 label_at("The shape of an oath",Vector2(160,85),38,GOLD,1000,true)
 label_at("A playable tutorial based on Master Rules v10 and Action Faces.",Vector2(162,143),16,MUTED)
 label_at("01   BUILD",Vector2(162,215),17,GOLD)
 label_at("Each hero has 3 customizable d6. Equip up to 9 abilities from their own 13-tile pool.\nEvery die needs at least 3 Blanks. Broken Body: max 3 Movement, 3 Defense, 3 Skill.\nThe balanced default includes Strike, Step, Stride, Guard, Reaction, Focus and First Aid.",Vector2(162,250),16,Color("d8dfe5"))
 label_at("02   ROLL & RESOLVE",Vector2(162,345),17,GOLD)
 label_at("Initiative is rolled once. All available dice roll together at each round boundary.\nUse your hero’s faces in any order. Click a die, then a highlighted cell or unit.\nFocus rerolls another unresolved die. You may decline a face or end your turn early.\nThe boss resolves I → II → III. Click Resolve to advance each action; results stay public.",Vector2(162,380),16,Color("d8dfe5"))
 label_at("03   SURVIVE",Vector2(162,500),17,GOLD)
 label_at("Reactions store immediately and expire before the next round’s roll. Block is spent\non damage and expires at your next turn. First zero HP: Downed, protected through\nthe acting turn. First Aid revives with Broken and queues a full recovery turn.\nAt zero again, a Broken hero dies. All heroes Downed/dead means immediate defeat.",Vector2(162,535),16,Color("d8dfe5"))
 label_at("PROTOTYPE SCOPE",Vector2(162,660),13,GOLD)
 label_at("Local hotseat controls all 3 heroes. Deployment and deterministic shortest-path choices\nare test defaults. No unfinished catalog abilities, campaign Events or Channel faces.\nBoss target ties are random; equal hero initiative uses Vesper → Rook → Wren.\nNumeric dice are not rolled: all starting effects have printed fixed values.",Vector2(162,696),14,MUTED)
 button("Return to the game",Vector2(1003,799),Vector2(255,51),func(): show_help = false; rebuild())

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion:
  hover = Vector2i((event.position-ORIGIN)/CELL)
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  if page != "battle" or show_help or not game.pending.is_empty() or game.outcome != "" or game.active == 3 or selected < 0: return
  var c := Vector2i((event.position-ORIGIN)/CELL)
  if not Rect2(ORIGIN,Vector2.ONE*CELL*9).has_point(event.position): return
  var f: int = game.face(game.active,selected)
  var target := -1
  for u in range(4):
   if u < 3 and game.heroes[u].dead: continue
   if c in game.cells(u): target = u
  var done := false
  if f in [0,2,3]: done = game.hero_action(selected,-1,c)
  elif f == 8:
   if shove_target == -1 and target >= 0 and target != game.active and game.distance(game.active,target) == 1:
    shove_target = target; hint = "Choose a push direction from the arrows beside the board."; rebuild(); return
   elif shove_target >= 0:
    var tp: Vector2i = game.boss.pos if shove_target == 3 else game.heroes[shove_target].pos
    var delta := c-tp
    var dir := Vector2i(signi(delta.x),0) if absi(delta.x) >= absi(delta.y) else Vector2i(0,signi(delta.y))
    done = game.hero_action(selected,shove_target,dir)
  elif f in [1,7]: done = game.hero_action(selected,target)
  if done: selected = -1; shove_target = -1; hint = "Choose another die, or end this hero’s turn."
  else: hint = "That target or destination is not legal for this face."
  rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  selected = -1; shove_target = -1; show_help = false; rebuild()

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,Vector2(1440,900)),Color("10151e"))
 for i in range(28):
  var p := Vector2(fmod(i*131.73,1400.0),fmod(i*79.37+t*3,900.0))
  draw_circle(p,1.2,Color(0.8,0.6,0.35,0.16+sin(t+i)*0.08))
 draw_line(Vector2(42,92),Vector2(1346,92),Color("303846"))
 if page == "forge":
  panel(Rect2(68,351,736,336)); panel(Rect2(850,278,472,563))
  for d in range(3):
   draw_line(Vector2(150,452+d*111),Vector2(781,452+d*111),Color("2b3542"))
 else:
  panel(Rect2(846,180,477,568)); panel(Rect2(612,230,211,322)); panel(Rect2(67,768,757,112))
  draw_board()

func draw_board() -> void:
 var highlights: Array = []
 if selected >= 0 and game.active < 3 and game.pending.is_empty():
  var f: int = game.face(game.active,selected)
  if f in [2,3] or (f == 0 and game.reward): highlights = game.reachable(game.active,3 if f == 3 else (2 if f == 0 else 1),f == 3)
 for y in range(9):
  for x in range(9):
   var c := Vector2i(x,y); var p := ORIGIN+Vector2(c)*CELL
   var col := Color("222b34") if (x+y)%2 == 0 else Color("1d2630")
   if c in game.cells(3): col = Color("382d37")
   if c in highlights: col = Color("365550")
   draw_rect(Rect2(p+Vector2.ONE*2,Vector2.ONE*(CELL-4)),col)
   if c in highlights: draw_circle(p+Vector2.ONE*CELL/2,3,Color("82c5b0"))
   if c == hover: draw_rect(Rect2(p+Vector2.ONE*2,Vector2.ONE*(CELL-4)),Color(GOLD,0.5),false,1)
 for i in range(9):
  draw_string(BODY,ORIGIN+Vector2(i*CELL+23,-10),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
  draw_string(BODY,ORIGIN+Vector2(-20,i*CELL+32),char(65+i),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
 # Ritual circle under the boss, and a hand-drawn twisted silhouette.
 var bp: Vector2 = ORIGIN+Vector2(game.boss.pos)*CELL+Vector2.ONE*CELL
 draw_arc(bp,48,0,TAU,64,Color("8e5e62"),1.5)
 draw_arc(bp,43,0,TAU,64,Color("62454e"),1)
 var sway := sin(t*1.7)*2
 draw_colored_polygon(PackedVector2Array([bp+Vector2(-22,34),bp+Vector2(-16,-9),bp+Vector2(-5,-26),bp+Vector2(13,-21),bp+Vector2(24,32),bp+Vector2(4,24)]),Color("382c3c"))
 draw_polyline(PackedVector2Array([bp+Vector2(-35,-35),bp+Vector2(-23,-5),bp+Vector2(-10,-12),bp+Vector2(1,22),bp+Vector2(24,36)]),Color("ab7c84"),5,true)
 draw_polyline(PackedVector2Array([bp+Vector2(36,-29),bp+Vector2(22,-4),bp+Vector2(10,-13),bp+Vector2(1,22),bp+Vector2(-17,38)]),Color("ab7c84"),5,true)
 draw_circle(bp+Vector2(sway,-24),10,Color("d3baac"))
 draw_line(bp+Vector2(-8+sway,-24),bp+Vector2(8+sway,-24),Color("332334"),3)
 draw_circle(bp+Vector2(-3+sway,-24),1.5,Color("f5ae8f")); draw_circle(bp+Vector2(4+sway,-24),1.5,Color("f5ae8f"))
 for i in range(3):
  var h: Dictionary = game.heroes[i]
  if h.dead: continue
  var p := ORIGIN+Vector2(h.pos)*CELL+Vector2.ONE*CELL/2
  if game.active == i:
   draw_arc(p,24,0,TAU,48,Color(COLORS[i],0.6+sin(t*3)*0.2),2)
  draw_circle(p,19,Color("111923")); draw_arc(p,19,0,TAU,48,COLORS[i],2)
  if h.hp == 0:
   draw_line(p+Vector2(-8,-8),p+Vector2(8,8),COLORS[i],3); draw_line(p+Vector2(8,-8),p+Vector2(-8,8),COLORS[i],3)
  else:
   draw_colored_polygon(PackedVector2Array([p+Vector2(-10,11),p+Vector2(0,-7),p+Vector2(10,11)]),COLORS[i].darkened(0.2))
   draw_circle(p+Vector2(0,-7),5,COLORS[i])
  for hp in range(6): draw_rect(Rect2(p+Vector2(-18+hp*6,24),Vector2(4,3)),COLORS[i] if hp < h.hp else Color("3d434b"))
