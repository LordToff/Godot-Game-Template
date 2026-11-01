extends RefCounted
const BODY = preload("res://prototype/assets/body.ttf")
static func box(bg: Color, border: Color, radius: int = 5) -> StyleBoxFlat:
 var s := StyleBoxFlat.new();s.bg_color = bg;s.border_color = border
 s.set_border_width_all(1);s.set_corner_radius_all(radius);s.corner_detail = 4
 s.shadow_color = Color(0,0,0,.22);s.shadow_size = 5;s.shadow_offset = Vector2(0,3)
 s.content_margin_left = 14;s.content_margin_right = 14;s.content_margin_top = 7;s.content_margin_bottom = 7
 return s
static func make() -> Theme:
 var t := Theme.new();t.default_font = BODY;t.default_font_size = 15
 var gold := Color("e6c58c");var text := Color("e6e6e3")
 for type in ["Button","OptionButton","MenuButton"]:
  t.set_stylebox("normal",type,box(Color("1b2935"),Color("43515b")))
  t.set_stylebox("hover",type,box(Color("2b3d49"),gold))
  t.set_stylebox("pressed",type,box(Color("354a54"),gold))
  t.set_stylebox("disabled",type,box(Color("141e28"),Color("303b46")))
  var focus := box(Color(0,0,0,0),gold);focus.set_border_width_all(2);focus.shadow_size = 0
  t.set_stylebox("focus",type,focus);t.set_color("font_color",type,text);t.set_color("font_hover_color",type,Color.WHITE)
  t.set_color("font_disabled_color",type,Color("7f8e9a"));t.set_constant("outline_size",type,0)
 for type in ["LineEdit","TextEdit"]:
  t.set_stylebox("normal",type,box(Color("101c27"),Color("52616a")))
  t.set_stylebox("focus",type,box(Color("172532"),gold));t.set_color("font_color",type,text)
  t.set_color("font_placeholder_color",type,Color("a1acb5"));t.set_color("caret_color",type,gold);t.set_color("selection_color",type,Color("43586b"))
 t.set_stylebox("panel","PopupMenu",box(Color("182631"),Color("a98d5e")))
 t.set_stylebox("hover","PopupMenu",box(Color("354a54"),gold,3));t.set_color("font_color","PopupMenu",text)
 t.set_constant("v_separation","PopupMenu",8)
 t.set_stylebox("panel","TooltipPanel",box(Color("192630"),Color("a98d5e")))
 t.set_color("font_color","TooltipLabel",text);t.set_font_size("font_size","TooltipLabel",14)
 for type in ["VScrollBar","HScrollBar"]:
  for item in [["scroll",Color("101923"),Color("1e2c36")],["grabber",Color("61717a"),Color("61717a")],["grabber_highlight",Color("b49d75"),gold]]:
   var scroll_box := box(item[1],item[2],3);scroll_box.content_margin_left = 4;scroll_box.content_margin_right = 4;scroll_box.content_margin_top = 0;scroll_box.content_margin_bottom = 0;scroll_box.shadow_size = 0;t.set_stylebox(item[0],type,scroll_box)
 t.set_stylebox("slider","HSlider",box(Color("101923"),Color("43515b"),3))
 t.set_stylebox("grabber_area","HSlider",box(Color("a48b5a"),gold,3))
 t.set_stylebox("grabber_area_highlight","HSlider",box(Color("cfb47c"),gold,3))
 t.set_color("default_color","RichTextLabel",text);t.set_constant("line_separation","RichTextLabel",4)
 t.set_stylebox("selected","ItemList",box(Color("324553"),gold))
 t.set_stylebox("panel","ItemList",box(Color("111d28"),Color("42515b")))
 return t
