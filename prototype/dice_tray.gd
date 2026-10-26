extends Control
signal finished
const FONT = preload("res://prototype/assets/body.ttf")
const DURATION = 1.65
var queue: Array = []
var elapsed := 0.0
var fast := false
var cubes: Array = []
var landings: Array = []
var world: Node3D
var actor_label: Label
var results_label: Label
var viewport: SubViewport
var busy := false
const ROTATIONS = [Vector3.ZERO,Vector3(0,-PI/2,0),Vector3(0,PI,0),Vector3(0,PI/2,0),Vector3(PI/2,0,0),Vector3(-PI/2,0,0)]

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);z_index = 100;mouse_filter = Control.MOUSE_FILTER_STOP
 var shade := ColorRect.new();shade.color = Color("101923");shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
 actor_label = Label.new();actor_label.position = Vector2(300,185);actor_label.size = Vector2(840,90);actor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;actor_label.add_theme_font_override("font",FONT);actor_label.add_theme_font_size_override("font_size",25);add_child(actor_label)
 var container := SubViewportContainer.new();container.position = Vector2(300,290);container.size = Vector2(840,280);container.stretch = true;container.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(container)
 viewport = SubViewport.new();viewport.size = Vector2i(840,280);viewport.transparent_bg = true;viewport.own_world_3d = true;container.add_child(viewport)
 world = Node3D.new();viewport.add_child(world)
 var camera := Camera3D.new();camera.projection = Camera3D.PROJECTION_ORTHOGONAL;camera.keep_aspect = Camera3D.KEEP_WIDTH;camera.size = 5.5;camera.position = Vector3(0,0,8);world.add_child(camera);camera.current = true
 var light := DirectionalLight3D.new();light.rotation_degrees = Vector3(-25,-25,0);light.light_energy = 1.6;world.add_child(light)
 var fill := OmniLight3D.new();fill.position = Vector3(-3,2,4);fill.light_energy = 1.8;world.add_child(fill)
 results_label = Label.new();results_label.position = Vector2(260,580);results_label.size = Vector2(920,120);results_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;results_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;results_label.add_theme_font_override("font",FONT);results_label.add_theme_font_size_override("font_size",21);add_child(results_label)
 var skip := Button.new();skip.text = "Skip animation · keep results";skip.position = Vector2(795,735);skip.size = Vector2(345,48);skip.pressed.connect(finish);add_child(skip)
 var speed := CheckButton.new();speed.text = "Fast rolls";speed.position = Vector2(305,740);speed.button_pressed = fast;speed.toggled.connect(func(value):fast = value);add_child(speed)
 hide()

func play(batches: Array) -> void:
 if batches.is_empty():return
 queue.append_array(batches.duplicate(true))
 if not busy:busy = true;show();start_batch()

func start_batch() -> void:
 for cube in cubes:world.remove_child(cube);cube.queue_free()
 cubes.clear();landings.clear();elapsed = 0
 var batch: Dictionary = queue[0]
 actor_label.text = batch.actor+"\n"+batch.kind
 results_label.text = "Rolling…"
 var count: int = batch.faces.size()
 for index in range(count):
  var cube := Node3D.new();cube.position.x = (index-(count-1)*0.5)*1.7;world.add_child(cube);cubes.append(cube)
  var mesh := MeshInstance3D.new();var box := BoxMesh.new();box.size = Vector3.ONE*1.05;mesh.mesh = box
  var material := StandardMaterial3D.new();material.albedo_color = Color("324956");material.roughness = 0.4;material.metallic = 0.25;mesh.material_override = material;cube.add_child(mesh)
  for side in range(6):
   var face := Node3D.new();cube.add_child(face)
   match side:
    0:face.position.z = 0.534
    1:face.position.x = 0.534;face.rotation.y = PI/2
    2:face.position.z = -0.534;face.rotation.y = PI
    3:face.position.x = -0.534;face.rotation.y = -PI/2
    4:face.position.y = 0.534;face.rotation.x = -PI/2
    5:face.position.y = -0.534;face.rotation.x = PI/2
   var label := Label3D.new();label.text = str(batch.faces[index][side]).replace(" ","\n");label.font = FONT;label.font_size = 40;label.pixel_size = 0.005;label.outline_size = 5;label.modulate = Color("fff0c8");label.double_sided = false;face.add_child(label)
  landings.append(ROTATIONS[clampi(batch.sides[index],0,5)]+Vector3(0.16,-0.22,0.04))

func _process(delta: float) -> void:
 if not busy:return
 elapsed += delta*(2.2 if fast else 1.0)
 var progress := clampf(elapsed/1.05,0,1)
 var spin := 1.0-smoothstep(0.0,1.0,progress)
 for index in range(cubes.size()):
  cubes[index].rotation = landings[index]+Vector3(7+index,9-index,5)*spin
  cubes[index].position.y = sin(progress*PI)*0.25+sin(progress*PI*4)*0.07*spin
 if elapsed >= 1.05:
  var batch: Dictionary = queue[0];var names: Array[String] = []
  for i in range(batch.results.size()):names.append(("VALUE" if batch.kind.begins_with("Numeric") else "DIE "+str(batch.dice[i]+1))+" · "+str(batch.results[i]))
  results_label.text = "     |     ".join(names)
 if elapsed >= DURATION:
  queue.pop_front()
  if queue.is_empty():finish()
  else:start_batch()

func finish() -> void:
 busy = false;queue.clear();hide();finished.emit()
