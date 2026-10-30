extends Control
# Projected 3D cube; displays model-recorded sides without drawing random numbers.
signal finished
var busy := false
var batches: Array = []
var elapsed := 0.0
const DURATION := 1.15
const FONT = preload("res://prototype/assets/body.ttf")
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 z_index = 90
 hide()
func play(incoming: Array) -> void:
 batches.append_array(incoming)
 if not busy and not batches.is_empty():busy = true;elapsed = 0;show()
func _process(delta: float) -> void:
 if not busy:return
 elapsed += delta
 if elapsed >= DURATION:
  batches.pop_front();elapsed = 0
  if batches.is_empty():finish();return
 queue_redraw()
func finish() -> void:
 batches.clear();busy = false;hide();finished.emit()
func _draw() -> void:
 if not busy or batches.is_empty():return
 var roll: Dictionary = batches[0]
 var progress := clampf(elapsed/0.8,0,1)
 var spin := pow(1-progress,3)
 var transform := Basis.from_euler(Vector3(0.28+spin*TAU*2,-0.4+spin*TAU*2,spin*TAU))
 var center := Vector2(1264,465-sin(progress*PI)*24)
 draw_style_box(panel_style(),Rect2(1120,300,288,355))
 draw_string(FONT,Vector2(1134,333),str(roll.actor),HORIZONTAL_ALIGNMENT_LEFT,258,15,Color("edcf93"))
 draw_string(FONT,Vector2(1134,358),"NUMERIC ROLL",HORIZONTAL_ALIGNMENT_LEFT,258,13,Color("9eb6c8"))
 draw_ellipse_shadow(center+Vector2(0,76),progress)
 var vertices: Array[Vector3] = []
 for z in [-1,1]:
  for y in [-1,1]:
   for x in [-1,1]:vertices.append(transform*Vector3(x,y,z))
 var surfaces: Array = [[4,5,7,6],[1,0,2,3],[0,4,6,2],[5,1,3,7],[0,1,5,4],[6,7,3,2]]
 surfaces.sort_custom(func(a,b):return (vertices[a[0]].z+vertices[a[1]].z+vertices[a[2]].z+vertices[a[3]].z)<(vertices[b[0]].z+vertices[b[1]].z+vertices[b[2]].z+vertices[b[3]].z))
 for surface in surfaces:
  var normal: Vector3 = (vertices[surface[1]]-vertices[surface[0]]).cross(vertices[surface[2]]-vertices[surface[0]])
  if normal.z <= 0:continue
  var polygon := PackedVector2Array();var midpoint := Vector2.ZERO
  for index in surface:
   var p: Vector3 = vertices[index]
   var projected := center+Vector2(p.x,p.y)*47.0*(4.5/(4.5-p.z))
   polygon.append(projected);midpoint += projected/4
  var light := clampf(normal.normalized().dot(Vector3(-0.3,-0.5,1).normalized()),0.2,1)
  draw_colored_polygon(polygon,Color("eee0ba")*Color(light,light,light,1))
  var border := polygon.duplicate();border.append(polygon[0]);draw_polyline(border,Color("514535"),2,true)
  var side: int = int(roll.sides[0]) if surface[0] == 4 else (int(surface[0])+1)%6
  var label: String = str(roll.faces[0][side])
  draw_string(FONT,midpoint+Vector2(-17,10),label,HORIZONTAL_ALIGNMENT_CENTER,34,28,Color("252a35"))
 if progress >= 1:
  draw_string(FONT,Vector2(1134,579),"RESULT: "+str(roll.results[0]),HORIZONTAL_ALIGNMENT_CENTER,258,25,Color("ffe6a6"))
  draw_string(FONT,Vector2(1134,612),str(roll.kind),HORIZONTAL_ALIGNMENT_CENTER,258,12,Color("aec3d1"))
func panel_style() -> StyleBoxFlat:
 var box := StyleBoxFlat.new();box.bg_color = Color("182936");box.border_color = Color("c5a36a");box.set_border_width_all(2);box.set_corner_radius_all(8);return box
func draw_ellipse_shadow(at: Vector2, progress: float) -> void:
 var points := PackedVector2Array()
 for step in range(32):points.append(at+Vector2(cos(step*TAU/32)*52,sin(step*TAU/32)*10)*(0.8+progress*0.2))
 draw_colored_polygon(points,Color(0,0,0,0.35))
