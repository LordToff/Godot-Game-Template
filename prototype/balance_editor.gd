extends Control
signal apply_requested(values: Dictionary)
signal closed
const Balance = preload("res://prototype/balance.gd")
const FONT = preload("res://prototype/assets/body.ttf")
var draft: Dictionary = {}
var tuned := true
var restart := false
var query := ""
var selected_group := "Soul · Blank movement"
var group_list: ItemList
var shown_groups: Array[String] = []
var rows: VBoxContainer
var summary: Label
var error_label: Label
var json_layer: Control
var json_text: TextEdit
var json_error: Label
func configure(values: Dictionary, balanced: bool, in_fight: bool) -> void:
 draft = values.duplicate(true);tuned = balanced;restart = in_fight
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter = Control.MOUSE_FILTER_STOP;z_index = 60
 var theme_res := Theme.new();theme_res.default_font = FONT;theme_res.default_font_size = 16;theme = theme_res
 build()
func box(bg: String, border: String) -> StyleBoxFlat:
 var result := StyleBoxFlat.new();result.bg_color = Color(bg);result.border_color = Color(border);result.set_border_width_all(1);result.content_margin_left = 12;result.content_margin_right = 12
 return result
func label(text: String, at: Vector2, dimensions: Vector2, size_px: int = 16, parent: Node = self) -> Label:
 var result := Label.new();result.text = text;result.position = at;result.size = dimensions;result.add_theme_font_size_override("font_size",size_px);result.add_theme_color_override("font_color",Color("dce6ee"));parent.add_child(result);return result
func button(text: String, at: Vector2, dimensions: Vector2, callback: Callable, parent: Node = self) -> Button:
 var result := Button.new();result.text = text;result.position = at;result.size = dimensions
 result.add_theme_stylebox_override("normal",box("20313d","58677a"));result.add_theme_stylebox_override("hover",box("304554","d5b87a"));result.add_theme_color_override("font_color",Color("e4c88f"));result.pressed.connect(callback);parent.add_child(result);return result
func build() -> void:
 for child in get_children():remove_child(child);child.queue_free()
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = Vector2(1440,900);add_child(shade)
 label("BALANCE WORKSHOP",Vector2(48,28),Vector2(900,42),29)
 button("Base: "+("Tuned" if tuned else "Original"),Vector2(1090,28),Vector2(302,40),func():tuned = not tuned;build())
 label("Edit whole-number values. Apply restarts the current fight / test. Profiles save locally in this browser.",Vector2(48,79),Vector2(1330,32),16)
 var search := LineEdit.new();search.name = "BalanceSearch";search.placeholder_text = "Find ability, boss, Soul or passive…";search.text = query;search.position = Vector2(48,134);search.size = Vector2(330,43);add_child(search)
 search.text_changed.connect(func(value):query = value;fill_groups())
 group_list = ItemList.new();group_list.name = "BalanceGroups";group_list.position = Vector2(48,193);group_list.size = Vector2(330,530);group_list.fixed_icon_size = Vector2i(0,0);add_child(group_list)
 group_list.item_selected.connect(func(index):selected_group = shown_groups[index];fill_rows())
 var fixed := label("Fixed: six-sided dice, the 9×9 board, one-die choices and one active Channel.",Vector2(48,735),Vector2(330,42),12)
 fixed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 var scroll := ScrollContainer.new();scroll.position = Vector2(415,218);scroll.size = Vector2(977,490);add_child(scroll)
 rows = VBoxContainer.new();rows.name = "BalanceRows";rows.custom_minimum_size.x = 945;rows.add_theme_constant_override("separation",12);scroll.add_child(rows)
 label("PARAMETER",Vector2(430,176),Vector2(550,30),14);label("VALUE",Vector2(1040,176),Vector2(130,30),14);label("DEFAULT",Vector2(1240,176),Vector2(140,30),14)
 button("Reset this section",Vector2(48,788),Vector2(220,44),func():
  for entry in Balance.DEFINITIONS:
   if entry.group == selected_group:draft.erase(entry.key)
  fill_rows())
 button("Reset all values",Vector2(280,788),Vector2(220,44),func():draft.clear();fill_rows())
 button("Import / export JSON",Vector2(512,788),Vector2(240,44),open_json)
 button("Apply & restart fight / test" if restart else "Save balance profile",Vector2(944,788),Vector2(448,44),func():
  var error := Balance.validate(draft)
  if error != "":set_error(error);return
  apply_requested.emit(draft.duplicate(true)))
 button("Cancel",Vector2(48,848),Vector2(220,39),func():closed.emit())
 summary = label("",Vector2(300,844),Vector2(700,38),15)
 error_label = label("",Vector2(415,718),Vector2(977,50),14);error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;error_label.add_theme_color_override("font_color",Color("eea394"))
 fill_groups();fill_rows()
func fill_groups() -> void:
 group_list.clear();shown_groups.clear()
 var direct: Array[String] = []
 var field_matches: Array[String] = []
 for group in Balance.groups():
  if query == "" or group.to_lower().contains(query.to_lower()):direct.append(group)
  elif Balance.DEFINITIONS.any(func(entry):return entry.group == group and entry.label.to_lower().contains(query.to_lower())):field_matches.append(group)
 shown_groups.append_array(direct);shown_groups.append_array(field_matches)
 for group in shown_groups:group_list.add_item(group)
 var index := shown_groups.find(selected_group)
 if index >= 0:group_list.select(index);group_list.ensure_current_is_visible()
 elif not shown_groups.is_empty():selected_group = shown_groups[0];group_list.select(0);fill_rows()

func fill_rows() -> void:
 for child in rows.get_children():rows.remove_child(child);child.queue_free()
 var heading := Label.new();heading.text = selected_group;heading.add_theme_font_size_override("font_size",24);heading.add_theme_color_override("font_color",Color("e4c88f"));rows.add_child(heading)
 var count := 0
 for entry in Balance.DEFINITIONS:
  if entry.group != selected_group:continue
  count += 1
  var row := HBoxContainer.new();row.custom_minimum_size = Vector2(945,57);row.add_theme_constant_override("separation",16);rows.add_child(row)
  var title := Label.new();title.text = entry.label;title.custom_minimum_size.x = 590;title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;row.add_child(title)
  var value := SpinBox.new();value.name = entry.key.replace(".","_");value.set_meta("balance_key",entry.key);value.min_value = entry.min;value.max_value = entry.max;value.step = 1;value.value = Balance.value(draft,entry.key,tuned);value.custom_minimum_size = Vector2(170,48);value.editable = not entry.get("inactive",false);row.add_child(value)
  value.tooltip_text = "Whole number: %d–%d. Changes apply on restart." % [entry.min,entry.max]
  var baseline: int = Balance.value({},entry.key,tuned)
  var reference := Label.new();reference.text = str(baseline);reference.custom_minimum_size.x = 140;reference.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;row.add_child(reference)
  value.value_changed.connect(func(n):
   if int(n) == baseline:draft.erase(entry.key)
   else:draft[entry.key] = int(n)
   refresh_summary())
 if count == 0:
  var note := Label.new();note.text = "This effect has no independent numeric parameter. Copy / choose operations stay one-die operations.\n\nBlank movement is in Soul · Blank movement.\nShared Numeric values are in Numeric die.\nHP, resources and repeated-Stun damage are in General & passives.\nBody limits and owned tile counts are in Body & owned tiles.";note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;note.custom_minimum_size.x = 940;rows.add_child(note)
 refresh_summary()
func refresh_summary() -> void:
 if is_instance_valid(summary):summary.text = "%d custom values · %d numeric fields in this prototype" % [draft.size(),Balance.DEFINITIONS.size()]
func set_error(message: String) -> void:
 error_label.text = message
func open_json() -> void:
 json_layer = Control.new();json_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(json_layer)
 var shade := ColorRect.new();shade.color = Color("101923");shade.size = Vector2(1440,900);json_layer.add_child(shade)
 label("BALANCE PROFILE JSON",Vector2(220,85),Vector2(1000,45),28,json_layer)
 label("Copy this text to keep / share a profile, or paste a saved profile here. Import does not apply until you press Apply.",Vector2(220,143),Vector2(1000,40),15,json_layer)
 json_text = TextEdit.new();json_text.position = Vector2(220,198);json_text.size = Vector2(1000,463);json_text.text = JSON.stringify({"format":"ash-and-oath-balance-v1","base_rules":"tuned" if tuned else "original","values":draft},"  ");json_layer.add_child(json_text)
 json_error = label("",Vector2(220,755),Vector2(1000,75),16,json_layer);json_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 button("Use this JSON",Vector2(220,693),Vector2(310,45),func():
  var decoded = JSON.parse_string(json_text.text)
  var values = decoded.get("values",decoded) if decoded is Dictionary else decoded
  var error := Balance.validate(values)
  if error != "":json_error.text = error;return
  if decoded is Dictionary and decoded.has("base_rules"):
   if decoded.base_rules not in ["tuned","original"]:json_error.text = "Base rules must be tuned or original.";return
   tuned = decoded.base_rules == "tuned"
  draft = values.duplicate(true);close_json();build(),json_layer)
 button("Copy JSON",Vector2(565,693),Vector2(310,45),func():DisplayServer.clipboard_set(json_text.text);json_error.text = "Copied. You can also select the text and press Ctrl+C.",json_layer)
 button("Back",Vector2(910,693),Vector2(310,45),close_json,json_layer)
func close_json() -> void:
 remove_child(json_layer);json_layer.queue_free();json_layer = null
