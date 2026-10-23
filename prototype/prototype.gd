extends Control

const Catalog = preload("res://prototype/catalog.gd")
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
var gifts: Array = [-1,-1,-1]
var draft_modal := true


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
 make_offers()
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
 hit_time = maxf(0,hit_time-delta)
 for f in floaters: f.life -= delta
 floaters = floaters.filter(func(f):return f.life > 0)
 if page == "battle":
  for id in range(4):
   var target_pos: Vector2 = Vector2(game.boss.pos if id == 3 else game.heroes[id].pos)
   if visual_positions.has(id): visual_positions[id] = visual_positions[id].lerp(target_pos,1.0-exp(-delta*13))
 if rolling_time > 0:
  rolling_time = maxf(0,rolling_time-delta)
  if rolling_time == 0: rebuild()
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
 label_at("A DICE-BUILDING BOSS BATTLER",Vector2(44,65),11,MUTED)
 button("?  Rules",Vector2(1114,30),Vector2(112,40),func(): show_help = not show_help; rebuild())
 button("Sound " + ("off" if muted else "on"),Vector2(1236,30),Vector2(110,40),func(): muted = not muted; music.stream_paused = muted; audio.volume_db = -80 if muted else 0; rebuild())
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
   var o := OptionButton.new(); o.clip_text = true; o.position = Vector2(160+side*102,369+d*111); o.size = Vector2(96,66)
   o.add_theme_font_size_override("font_size",12)
   for id in range(9): o.add_item(Model.FACES[id],id)
   if gifts[build_hero] >= 9: o.add_item(Model.FACES[gifts[build_hero]],gifts[build_hero])
   o.select(o.get_item_index(f)); o.add_theme_stylebox_override("normal",style(Color("202938"),Color(color_for_face(f),0.55)))
   o.add_theme_color_override("font_color",color_for_face(f))
   o.item_selected.connect(func(index): builds[build_hero][d][side] = o.get_item_id(index); rebuild())
   o.tooltip_text = Model.FACES[f] + "\n" + face_help(f); ui.add_child(o)
 var error := Model.validate(builds[build_hero],gifts[build_hero])
 label_at("✓ Legal build · " + str(18-builds[build_hero].reduce(func(a,d): return a+d.count(0),0)) + "/9 ability faces" if error == "" else error,Vector2(75,706),14,COLORS[build_hero] if error == "" else Color("ef8e87"),730)
 button("Restore balanced build",Vector2(75,756),Vector2(245,46),func(): builds[build_hero] = Model.default_build(); rebuild(),MUTED)
 label_at("YOUR INHERITANCE",Vector2(886,300),13,GOLD)
 label_at("Memory   /   Empty\nSoul          /   6 HP · 3+ Blanks per die\nBody         /   Broken Body",Vector2(886,335),16,Color("d2d8df"))
 label_at("OWNED FACE POOL",Vector2(886,445),12,GOLD)
 label_at("4 Strike   ·   2 Step   ·   1 Stride\n2 Guard   ·   1 Reaction\n1 Focus   ·   1 First Aid   ·   1 Shove",Vector2(886,474),15,MUTED)
 label_at("Each hero owns 13 ability tiles. Equip up to 9.\nAt most 3 Movement, 3 Defense and 3 Skill.\nBlank faces do nothing with the starting Soul.",Vector2(886,559),13,MUTED)
 button("Balance: " + ("Tuned tutorial" if balanced else "Original rulebook"),Vector2(884,645),Vector2(400,35),func(): balanced = not balanced; rebuild(),GOLD)
 label_at("12 boss HP · Strike 2 · Brace 1 · no idle Block\n1 starting Action Reroll per hero, once per fight.\nLocal play · three heroes · open 9×9 arena." if balanced else "Original: 18 boss HP · Strike 1 · Brace 2\n1 starting Action Reroll per hero, once per fight.\nLocal play · three heroes · open 9×9 arena.",Vector2(886,692),13,MUTED)
 button("Starter gift: " + ("choose 1 of 3" if gifts[build_hero] < 0 else Model.FACES[gifts[build_hero]]),Vector2(884,601),Vector2(400,35),func(): draft_modal = true; rebuild(),Color("be9bdf"))
 var legal_builds := true
 for i in range(3):
  if Model.validate(builds[i],gifts[i]) != "" or gifts[i] < 0: legal_builds = false
 button("Enter the hollow   →",Vector2(884,773),Vector2(400,55),begin,GOLD,not legal_builds)

func retry(with_soul: bool = false) -> void:
 get_tree().root.set_meta("ash_restart", {"builds":builds.duplicate(true),"soul":with_soul or reward_soul,"muted":muted,"balanced":balanced,"gifts":gifts,"offers":offers})
 SceneLoader.load_scene("res://prototype/prototype.tscn")

func begin() -> void:
 draft_modal = false
 game.start(builds,0,reward_soul,balanced); page = "battle"; seen_roll = 0; snapshots.clear(); visual_positions.clear(); selected = -1; shove_target = -1
 hint = "Select a rolled die, then a highlighted cell or unit. Boss dice are public."
 rebuild()

func battle_ui() -> void:
 label_at("THE HOLLOW",Vector2(74,109),28,Color("ece6d9"),500,true)
 label_at("ROUND %02d   /   %s" % [game.round_no,"ENCOUNTER ENDED" if game.outcome != "" else ("THE HOLLOW’S TURN" if game.active == 3 else game.heroes[game.active].name + "’S TURN")],Vector2(76,151),12,GOLD)
 label_at("%d / %d HP    ·    %d BLOCK" % [game.boss.hp,game.boss.max_hp,game.boss.block],Vector2(408,119),13,Color("d78b83"))
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
  if h.weak or h.bulwark_weak: statuses += " WEAK"
  if not h.reaction.is_empty(): statuses += " REACTION ×"+str(h.reaction.size())
  label_at(statuses,Vector2(632,cy+53),10,GOLD,175)
  if not h.rolls.is_empty():
   var public_dice: Array[String] = []
   for d in range(3): public_dice.append(Model.FACES[game.face(i,d)].left(3) + ("·" if h.used[d] else ""))
   label_at(" / ".join(public_dice),Vector2(632,cy+75),10,MUTED,175)
 label_at("BOSS INTENT  /  CLICK AN ACTION TO EXPLAIN",Vector2(868,199),11,GOLD)
 for d in range(3):
  var action: String = game.boss_rolls[d]
  if game.active == 3:
   var col := GOLD if d == game.boss_index else MUTED
   label_at(["I","II","III"][d] + "   " + action + ("   ✓" if d < game.boss_index else ""),Vector2(870,235+d*109),17,col)
   label_at(game.boss_help(action),Vector2(870,266+d*109),13,MUTED,416,false,true)
  else:
   button(["I","II","III"][d] + "    " + action + "    ⓘ",Vector2(868,231+d*41),Vector2(420,34),func(): inspect_action = action; rebuild(),MUTED).tooltip_text = game.boss_help(action)
 if game.active < 3: label_at("ACTION DICE",Vector2(868,380),12,GOLD)
 if game.active < 3:
  var h: Dictionary = game.heroes[game.active]
  for d in range(3):
   var f: int = game.face(game.active,d)
   var text: String = ["I","II","III"][d] + "   " + Model.FACES[f] + ("  · spent" if h.used[d] else "")
   button(text,Vector2(868,416+d*61),Vector2(420,51),func():
    if selected >= 0 and game.face(game.active,selected) == 6 and selected != d:
     if game.hero_action(selected,d): selected = d if not game.heroes[game.active].used[d] else -1
    elif game.forced_die < 0 or game.forced_die == d: selected = d; shove_target = -1
    hint = face_help(game.face(game.active,d)); rebuild(),color_for_face(f),h.used[d] or not game.pending.is_empty() or game.outcome != "").tooltip_text = face_help(f)
  if selected >= 0 and not h.used[selected]:
   var f: int = game.face(game.active,selected)
   if f in [4,9,10,11,13,14,16,17,18,20,21,22,23,24,25,26,27,29,30,31,32,33,42,43,47,49,50,51,52,54,56] or (f == 0 and not game.reward):
    button("Resolve selected face",Vector2(868,609),Vector2(262,41),func(): game.hero_action(selected); selected = -1; rebuild())
   button("Decline",Vector2(1140,609),Vector2(148,41),func(): game.spend(selected); selected = -1; rebuild(),MUTED)
  button(("Reroll selected die" if selected >= 0 else "Select a die to reroll") + "   ·   " + str(h.rerolls) + " left",Vector2(868,737),Vector2(420,43),func():
   if game.action_reroll(selected): selected = -1; hint = "Reroll spent. Fresh result kept."
   rebuild(),Color("82c8b9"),selected < 0 or h.rerolls == 0 or not h.opening or (selected >= 0 and game.face(game.active,selected) in [9,11,15,56]) or not game.pending.is_empty() or game.outcome != "")
  label_at("Opening window only · no automatic refill",Vector2(875,784),10,MUTED)
  button("End hero turn   →",Vector2(868,674),Vector2(420,50),func(): game.finish_turn(); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 else:
  var last: String = "No action resolved yet." if game.last_action == "" else "LAST: " + game.last_action + (" → " + ", ".join(game.last_targets.map(func(id):return game.heroes[id].name)) if not game.last_targets.is_empty() else "")
  label_at(last,Vector2(870,574),14,Color("e1af9b"),420,false,true)
  label_at("Watch the board and chronicle for HP, Block,\nmovement and status changes.",Vector2(870,615),12,MUTED)
  button("Resolve " + (["I","II","III"][mini(game.boss_index,2)] if game.boss_index < 3 else "end of turn") + "   →",Vector2(868,674),Vector2(420,54),func(): game.boss_step(); selected = -1; rebuild(),GOLD,not game.pending.is_empty() or game.outcome != "")
 button("Chronicle / history",Vector2(676,774),Vector2(138,23),func(): show_history = true; rebuild(),MUTED).add_theme_font_size_override("font_size",10)
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
 if f >= 9: return Catalog.text(f)
 return ["Blank: no effect. The reward Soul unlocks Move 2.","Strike: %d damage to one adjacent unit. Weakness subtracts 1. Allies are legal targets." % (2 if balanced else 1),"Step: move up to 1 orthogonal space.","Stride: move up to 3 spaces in one straight orthogonal direction; no turning.","Guard: gain 1 Block. Block expires at your next turn start.","Tactical Defense: stored when rolled. On being targeted, gain 1 Block and optionally step 1 before the attack.","Focus: select another unresolved die to reroll it. Keep and resolve its new face.","First Aid: heal yourself or an adjacent hero for 1. Revives Downed heroes with Broken.","Shove: choose an adjacent unit, then a directly-away direction. Moves the full boss footprint. No collision penalty."][f]

func pending_ui() -> void:
 overlay()
 var p: Dictionary = game.pending
 label_at("A MOMENT TO RESPOND",Vector2(399,260),12,GOLD)
 if p.kind in ["channel","bind","ember","catalog_choice"]:
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
 label_at("First, each hero picks 1 bonus ability from 3 random offers drawn from 53 hero faces.\nEquip up to 9 abilities from your starter pool plus that gift. Each die needs 3+ Blanks.\nBroken Body: max 3 Movement, 3 Defense, 3 Skill. Gift cards label prototype variants.",Vector2(162,250),16,Color("d8dfe5"))
 label_at("02   ROLL & RESOLVE",Vector2(162,345),17,GOLD)
 label_at("Initiative is rolled once. All available dice roll together at each round boundary.\nEach hero starts with 1 Action Reroll: select a die and reroll BEFORE resolving any face.\nFocus is a separate exception. Dice animate without changing their final results.\nBoss I → II → III: effects are shown on each card. Click compact intent rows to inspect.",Vector2(162,380),16,Color("d8dfe5"))
 label_at("03   SURVIVE",Vector2(162,500),17,GOLD)
 label_at("Reactions store immediately and expire before the next round’s roll. Block is spent\non damage and expires at your next turn. First zero HP: Downed, protected through\nthe acting turn. First Aid revives with Broken and queues a full recovery turn.\nAt zero again, a Broken hero dies. All heroes Downed/dead means immediate defeat.",Vector2(162,535),16,Color("d8dfe5"))
 label_at("PROTOTYPE SCOPE",Vector2(162,660),13,GOLD)
 label_at("Tuned default: boss 12 HP, Basic Strike 2, Brace 1; an idle Advance grants no Block.\nSelect Original rulebook in the forge for 18 HP / Strike 1 / Brace 2.\nBonus faces use the printed playtest variants. The boss faces north for rear attacks.\nNo campaign Events or online multiplayer. Click Chronicle to review every result.",Vector2(162,696),14,MUTED)
 button("Return to the game",Vector2(1003,799),Vector2(255,51),func(): show_help = false; rebuild())

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion:
  hover = Vector2i((event.position-ORIGIN)/CELL)
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  if page != "battle" or show_help or show_history or inspect_action != "" or rolling_time > 0 or not game.pending.is_empty() or game.outcome != "" or game.active == 3 or selected < 0: return
  var c := Vector2i((event.position-ORIGIN)/CELL)
  if not Rect2(ORIGIN,Vector2.ONE*CELL*9).has_point(event.position): return
  var f: int = game.face(game.active,selected)
  var target := -1
  for u in range(4):
   if u < 3 and game.heroes[u].dead: continue
   if c in game.cells(u): target = u
  var done := false
  if f in [0,2,3,53,54]: done = game.hero_action(selected,-1,c)
  elif f == 8:
   if shove_target == -1 and target >= 0 and target != game.active and game.distance(game.active,target) == 1:
    shove_target = target; hint = "Choose a push direction from the arrows beside the board."; rebuild(); return
   elif shove_target >= 0:
    var tp: Vector2i = game.boss.pos if shove_target == 3 else game.heroes[shove_target].pos
    var delta := c-tp
    var dir := Vector2i(signi(delta.x),0) if absi(delta.x) >= absi(delta.y) else Vector2i(0,signi(delta.y))
    done = game.hero_action(selected,shove_target,dir)
  elif f in [1,7,12,15,19,34,35,36,37,38,39,40,41,55]: done = game.hero_action(selected,target)
  if done: selected = -1; shove_target = -1; hint = "Choose another die, or end this hero’s turn."
  else: hint = "That target or destination is not legal for this face."
  rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  selected = -1; shove_target = -1; show_help = false; inspect_action = ""; show_history = false; rebuild()

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
  panel(Rect2(846,180,477,615)); panel(Rect2(612,230,211,322)); panel(Rect2(67,768,757,112))
  draw_board()
  draw_effects()

func draw_board() -> void:
 var highlights: Array = []
 if selected >= 0 and game.active < 3 and game.pending.is_empty():
  var f: int = game.face(game.active,selected)
  if f in [2,3,54] or (f == 0 and game.reward): highlights = game.reachable(game.active,3 if f == 3 else (2 if f == 0 else 1),f == 3)
  if f == 53: highlights = game.leap_cells(game.active)
 for y in range(9):
  for x in range(9):
   var c := Vector2i(x,y); var p := ORIGIN+Vector2(c)*CELL
   var col := Color("222b34") if (x+y)%2 == 0 else Color("1d2630")
   if c in game.cells(3): col = Color("382d37")
   if c in highlights: col = Color("365550")
   draw_style_box(style(col,Color("303a42"),3),Rect2(p+Vector2.ONE*2,Vector2.ONE*(CELL-4)))
   var grain := float((x*17+y*31)%11)/110.0
   draw_line(p+Vector2(7,8),p+Vector2(23+grain*80,8),Color(0.5,0.55,0.6,0.12),1)
   if (x+y*3)%5 == 0:
    draw_polyline(PackedVector2Array([p+Vector2(39,4),p+Vector2(31,17),p+Vector2(34,22)]),Color(0.05,0.07,0.1,0.65),1)
   if c in highlights: draw_circle(p+Vector2.ONE*CELL/2,3,Color("82c5b0"))
   if c == hover: draw_rect(Rect2(p+Vector2.ONE*2,Vector2.ONE*(CELL-4)),Color(GOLD,0.5),false,1)
 for i in range(9):
  draw_string(BODY,ORIGIN+Vector2(i*CELL+23,-10),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
  draw_string(BODY,ORIGIN+Vector2(-20,i*CELL+32),char(65+i),HORIZONTAL_ALIGNMENT_LEFT,-1,11,MUTED)
 # A restrained ink-and-metal silhouette over the boss's four-cell seal.
 var bp: Vector2 = ORIGIN+Vector2(visual_positions.get(3,Vector2(game.boss.pos)))*CELL+Vector2.ONE*CELL
 draw_circle(bp+Vector2(0,27),38,Color(0.02,0.02,0.04,0.65))
 draw_arc(bp,48,t*0.03,t*0.03+TAU,64,Color("9b6974"),1.5)
 draw_arc(bp,43,0,TAU,64,Color("62454e"),1)
 for mark in range(8):
  var q := bp+Vector2.from_angle(mark*TAU/8)*46
  draw_line(q,q+Vector2.from_angle(mark*TAU/8)*5,Color("b28c78"),1)
 var sway := sin(t*1.7)*1.2
 draw_colored_polygon(PackedVector2Array([bp+Vector2(-29,36),bp+Vector2(-21,8),bp+Vector2(-17,-13),bp+Vector2(0,-21),bp+Vector2(18,-12),bp+Vector2(25,17),bp+Vector2(34,37),bp+Vector2(10,28),bp+Vector2(0,37),bp+Vector2(-10,29)]),Color("282230"))
 draw_polyline(PackedVector2Array([bp+Vector2(-30,35),bp+Vector2(-17,-13),bp+Vector2(0,-21),bp+Vector2(18,-12),bp+Vector2(33,36)]),Color("87616e"),2,true)
 draw_line(bp+Vector2(-13,-8),bp+Vector2(-7,23),Color("513b4a"),2)
 draw_line(bp+Vector2(14,-7),bp+Vector2(8,24),Color("513b4a"),2)
 draw_polyline(PackedVector2Array([bp+Vector2(-18,-7),bp+Vector2(-31,-1),bp+Vector2(-39,-22),bp+Vector2(-36,-33)]),Color("b2a299"),4,true)
 draw_polyline(PackedVector2Array([bp+Vector2(17,-8),bp+Vector2(31,-2),bp+Vector2(39,-20),bp+Vector2(42,-30)]),Color("b2a299"),4,true)
 draw_line(bp+Vector2(-39,-22),bp+Vector2(-45,-27),Color("d0bbb0"),1.5)
 draw_line(bp+Vector2(39,-20),bp+Vector2(46,-24),Color("d0bbb0"),1.5)
 draw_colored_polygon(PackedVector2Array([bp+Vector2(-10+sway,-26),bp+Vector2(-7+sway,-39),bp+Vector2(5+sway,-40),bp+Vector2(11+sway,-29),bp+Vector2(5+sway,-18),bp+Vector2(-5+sway,-18)]),Color("d0b9a3"))
 draw_polyline(PackedVector2Array([bp+Vector2(-7+sway,-34),bp+Vector2(-14+sway,-43),bp+Vector2(-10+sway,-49)]),Color("b99b81"),3,true)
 draw_polyline(PackedVector2Array([bp+Vector2(7+sway,-35),bp+Vector2(15+sway,-43),bp+Vector2(10+sway,-48)]),Color("b99b81"),3,true)
 draw_line(bp+Vector2(-8+sway,-30),bp+Vector2(8+sway,-30),Color("332334"),3)
 draw_circle(bp+Vector2(-4+sway,-30),1.7,Color("ffc49b")); draw_circle(bp+Vector2(4+sway,-30),1.7,Color("ffc49b"))
 draw_line(bp+Vector2(0+sway,-24),bp+Vector2(0+sway,-19),Color("755b58"),1)
 for rib in range(4): draw_line(bp+Vector2(-7,-7+rib*5),bp+Vector2(7,-7+rib*5),Color("ad8c86"),1.5)
 for i in range(3):
  var h: Dictionary = game.heroes[i]
  if h.dead: continue
  var p := ORIGIN+Vector2(visual_positions.get(i,Vector2(h.pos)))*CELL+Vector2.ONE*CELL/2
  if game.active == i:
   draw_arc(p,24,0,TAU,48,Color(COLORS[i],0.6+sin(t*3)*0.2),2)
  draw_circle(p,19,Color("111923")); draw_arc(p,19,0,TAU,48,COLORS[i],2)
  if h.hp == 0:
   draw_line(p+Vector2(-8,-8),p+Vector2(8,8),COLORS[i],3); draw_line(p+Vector2(8,-8),p+Vector2(-8,8),COLORS[i],3)
  else:
   draw_colored_polygon(PackedVector2Array([p+Vector2(-12,13),p+Vector2(-7,-4),p+Vector2(0,-12),p+Vector2(7,-4),p+Vector2(12,13),p+Vector2(0,9)]),COLORS[i].darkened(0.45))
   draw_polyline(PackedVector2Array([p+Vector2(-12,13),p+Vector2(-7,-4),p+Vector2(0,-12),p+Vector2(7,-4),p+Vector2(12,13)]),COLORS[i],1.5,true)
   draw_circle(p+Vector2(0,-3),4,Color("14202b"))
   draw_line(p+Vector2(-2,-3),p+Vector2(2,-3),Color("e5dac5"),1)
   draw_line(p+Vector2(0,4),p+Vector2(0,10),COLORS[i].lightened(0.2),1)
   if i == 0:
    draw_line(p+Vector2(12,15),p+Vector2(12,-13),Color("b9aa8b"),2)
    draw_circle(p+Vector2(12,-14),3,COLORS[i])
   elif i == 1:
    draw_line(p+Vector2(-12,9),p+Vector2(-13,-7),Color("e2d9d0"),2)
    draw_line(p+Vector2(-16,3),p+Vector2(-9,3),GOLD,1.5)
   else:
    draw_line(p+Vector2(8,8),p+Vector2(15,-4),Color("e2d9d0"),2)
    draw_arc(p+Vector2(10,3),7,-PI/2,PI/2,12,GOLD,1.5)
  for hp in range(6): draw_rect(Rect2(p+Vector2(-18+hp*6,24),Vector2(4,3)),COLORS[i] if hp < h.hp else Color("3d434b"))

func sync_presentation() -> void:
 if page != "battle": return
 if game.roll_serial != seen_roll:
  seen_roll = game.roll_serial
  rolling_time = 0.95
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
   elif bd < 0: floaters.append({"at":at,"text":"BLOCKED " + str(-bd),"color":Color("95c8ee"),"life":1.6})
   if bd > 0: floaters.append({"at":at,"text":"+"+str(bd)+" BLOCK","color":Color("95c8ee"),"life":1.6})
  snapshots[id] = {"hp":h.hp,"block":h.block}

func history_ui() -> void:
 overlay()
 label_at("THE CHRONICLE",Vector2(394,254),22,GOLD,600,true)
 var scroll := ScrollContainer.new(); scroll.position = Vector2(394,304); scroll.size = Vector2(570,270); ui.add_child(scroll)
 var lines := Label.new(); lines.add_theme_font_size_override("font_size",13); lines.text = "\n".join(game.log_lines); scroll.add_child(lines)
 scroll.set_deferred("scroll_vertical",99999)
 button("Back to battle",Vector2(399,591),Vector2(520,42),func(): show_history = false; rebuild())

func draw_effects() -> void:
 for f in floaters:
  draw_string(BODY,f.at+Vector2(-30,-20-(1.6-f.life)*35),f.text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color(f.color,minf(1,f.life)))
 if hit_time > 0:
  for id in game.last_targets:
   var p := ORIGIN+Vector2(game.heroes[id].pos)*CELL+Vector2.ONE*CELL/2
   draw_arc(p,23+(0.7-hit_time)*30,0,TAU,32,Color(0.95,0.5,0.35,hit_time),2)
 if rolling_time <= 0: return
 draw_style_box(style(Color(0.04,0.07,0.1,0.96),GOLD),Rect2(121,365,404,207))
 draw_string(TITLE,Vector2(156,401),"THE DICE ARE CAST",HORIZONTAL_ALIGNMENT_LEFT,-1,19,GOLD)
 for d in range(3):
  var center := Vector2(205+d*116,478+sin(t*18+d)*8)
  var angle := sin(t*13+d)*0.25*rolling_time
  draw_set_transform(center,angle)
  draw_style_box(style(Color("d8cbb3"),Color("f1e5ce"),9),Rect2(-34,-34,68,68))
  var n := (int(t*25)+d*7)%6+1
  for dot in range(n):
   var off := Vector2.ZERO
   if n > 1: off = Vector2(-16+32*(dot%2),-18+18*(dot/2))
   draw_circle(off,4,Color("35404b"))
  draw_set_transform(Vector2.ZERO)
 draw_string(BODY,Vector2(173,546),game.roll_context,HORIZONTAL_ALIGNMENT_LEFT,-1,14,MUTED)

func color_for_face(f: int) -> Color:
 if f < 9: return FACE_COLORS[f]
 match Catalog.category(f):
  "Attack": return FACE_COLORS[1]
  "Movement": return FACE_COLORS[2]
  "Defense": return FACE_COLORS[4]
  "Penalty": return Color("d87870")
 return FACE_COLORS[6]

func make_offers() -> void:
 var r := RandomNumberGenerator.new(); r.randomize()
 offers.clear()
 for hero in range(3):
  var pool: Array = Catalog.draft_ids()
  var choice: Array = []
  for n in range(3):
   var at := r.randi_range(0,pool.size()-1); choice.append(pool[at]); pool.remove_at(at)
  offers.append(choice)

func choose_gift(id: int) -> void:
 gifts[build_hero] = id
 builds[build_hero][2][2] = id
 var next := gifts.find(-1)
 if next >= 0: build_hero = next
 else: draft_modal = false
 rebuild()

func draft_ui() -> void:
 overlay()
 label_at("A GIFT FROM THE FULL HERO CATALOG",Vector2(381,254),12,GOLD)
 label_at(["VESPER","ROOK","WREN"][build_hero] + " · Choose one of three",Vector2(381,284),22,Color("ece6d9"),650,true)
 label_at("53 possible hero abilities · random offers · prototype variants shown below",Vector2(381,319),11,MUTED)
 for i in range(3):
  var id: int = offers[build_hero][i]
  var x := 379+i*211
  label_at(Model.FACES[id],Vector2(x,355),16,color_for_face(id),190,true,true)
  label_at(Catalog.category(id) + (" · PROTOTYPE VARIANT" if id >= 9 else " · STARTER"),Vector2(x,408),9,GOLD,190)
  label_at(face_help(id),Vector2(x,435),11,MUTED,186,false,true)
  button("Choose this face",Vector2(x,612),Vector2(194,38),func(): choose_gift(id),color_for_face(id))

func catalog_pending_ui(p: Dictionary) -> void:
 if p.kind == "channel":
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
    var action: String = Model.BOSS_DICE[d][side]
    button(str(d+1)+" · "+action,Vector2(377+side*101,379+d*70),Vector2(95,58),func(): game.choose_bind(d,action); rebuild(),GOLD).add_theme_font_size_override("font_size",10)
 else:
  label_at(Model.FACES[p.face] + " · Choose a die",Vector2(390,298),22,GOLD,620,true)
  label_at("Skip an unresolved die first; then choose a spent immediate face." if p.face == 23 else "Choose a valid source. Ineligible selections leave this window open.",Vector2(390,343),13,MUTED,570,false,true)
  if p.face == 16:
   for d in range(3):
    for side in range(6):
     var f: int = game.heroes[p.hero].build[d][side]
     button(str(d+1)+" · "+Model.FACES[f],Vector2(377+side*101,390+d*58),Vector2(95,48),func():
      if game.catalog_pick(p.hero,d,side): selected = game.forced_die
      rebuild(),color_for_face(f)).add_theme_font_size_override("font_size",10)
  else:
   for hero in range(3):
    for d in range(3):
     var h: Dictionary = game.heroes[hero]
     if h.results.is_empty(): continue
     var f: int = game.face(hero,d)
     button(h.name+" "+str(d+1)+" · "+Model.FACES[f],Vector2(387+d*202,390+hero*58),Vector2(195,48),func():
      if game.catalog_pick(hero,d): selected = game.forced_die
      rebuild(),color_for_face(f),hero != p.hero and p.face != 11).add_theme_font_size_override("font_size",10)
  button("Spend with no effect",Vector2(399,593),Vector2(520,42),func(): game.pending = {}; game.spend(p.die); selected = -1; rebuild(),MUTED)
