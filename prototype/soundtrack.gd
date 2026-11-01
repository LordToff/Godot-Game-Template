extends Node
const CUES = {
 "forge":preload("res://prototype/assets/music/embers_at_the_forge.ogg"),
 "battle":preload("res://prototype/assets/music/oathbound.ogg"),
 "phase":preload("res://prototype/assets/music/the_crown_splinters.ogg")
}
const TITLES = {"forge":"Embers at the Forge","battle":"Oathbound","phase":"The Crown Splinters"}
const SETTINGS = "user://ash_audio.cfg"
var players: Array[AudioStreamPlayer] = []
var current := ""
var slot := 0
var started := false
var muted := false
var music_level := .75
var effects_level := .85
var fade: Tween
func _ready() -> void:
 for i in range(2):
  var player := AudioStreamPlayer.new();player.bus = &"Music";player.volume_db = -80;add_child(player);players.append(player)
 var cfg := ConfigFile.new()
 if cfg.load(SETTINGS) == OK:
  music_level = clampf(float(cfg.get_value("audio","music",.75)),0,1)
  effects_level = clampf(float(cfg.get_value("audio","effects",.85)),0,1)
  muted = bool(cfg.get_value("audio","muted",false))
 apply_levels()
 started = not OS.has_feature("web")
 set_cue("forge")
func set_cue(cue: String) -> void:
 if cue == current or not CUES.has(cue):return
 current = cue
 if is_instance_valid(fade):fade.kill()
 var old := slot;slot = 1-slot
 var stream = CUES[cue];stream.loop = true
 players[slot].stream = stream;players[slot].volume_db = -80
 if started:players[slot].play()
 players[slot].stream_paused = muted
 fade = create_tween().set_parallel(true)
 fade.tween_property(players[slot],"volume_linear",db_to_linear(-8.0),1.4)
 fade.tween_property(players[old],"volume_linear",.0001,1.4)
 # The outgoing player is reused only after a future cue change. It can finish
 # fading without callbacks that might stop a rapidly re-selected cue.
func unlock() -> void:
 if started:return
 started = true;players[slot].play();players[slot].stream_paused = muted
func apply_levels() -> void:
 for pair in [["Music",music_level],["SFX",effects_level]]:
  var index := AudioServer.get_bus_index(pair[0])
  if index >= 0:AudioServer.set_bus_volume_db(index,linear_to_db(maxf(.0001,pair[1])));AudioServer.set_bus_mute(index,muted or pair[1] <= 0)
 for player in players:player.stream_paused = muted
func save() -> void:
 var cfg := ConfigFile.new();cfg.set_value("audio","music",music_level);cfg.set_value("audio","effects",effects_level);cfg.set_value("audio","muted",muted);cfg.save(SETTINGS)
func set_level(bus: String, value: float) -> void:
 if bus == "Music":music_level = clampf(value,0,1)
 else:effects_level = clampf(value,0,1)
 apply_levels();save()
func set_muted(value: bool) -> void:
 muted = value;apply_levels();save()
func title() -> String:return TITLES.get(current,"")

func _exit_tree() -> void:
 if is_instance_valid(fade):fade.kill()
 for player in players:
  if is_instance_valid(player):player.stop();player.stream = null
