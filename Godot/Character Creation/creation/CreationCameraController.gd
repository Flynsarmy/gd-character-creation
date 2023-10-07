extends Node3D

@export var rotation_target_node_path:NodePath
var rotation_target

var is_rotating:bool = false
var rotating_mouse_start := Vector2()
var rotating_rotation_y_start = 0
var target_rotation_degrees_y = 0

var zoom_pos_min: = 0.2
var zoom_pos_max: = 3.0
var zoom_target: = 1.0

var height_target

func _ready():
	# target character rotation
	if rotation_target_node_path:
		rotation_target = get_node(rotation_target_node_path)

	target_rotation_degrees_y = rotation_target.rotation_degrees.y

	# zooming
	zoom_target = position.z
	
	# height
	height_target = position.y


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not is_rotating:
			rotating_start(event)
		elif event.is_released() and is_rotating:
			rotating_stop(event)
	elif event is InputEventMouseMotion and is_rotating:
		rotating_update(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if event.is_pressed():
			zoom_target -= 0.1
			zoom_target = clamp(zoom_target, zoom_pos_min, zoom_pos_max)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if event.is_pressed():
			zoom_target += 0.1
			zoom_target = clamp(zoom_target, zoom_pos_min, zoom_pos_max)


func rotating_start(event:InputEventMouse):
	is_rotating = true
	rotating_mouse_start = event.position
	rotating_rotation_y_start = rotation_target.rotation_degrees.y
	

func rotating_stop(event:InputEventMouse):
	is_rotating = false


func rotating_update(event:InputEventMouse):
	var delta = rotating_mouse_start.x - event.position.x
	target_rotation_degrees_y = rotating_rotation_y_start - delta


func _process(delta):
	rotation_target.rotation_degrees.y = lerp(rotation_target.rotation_degrees.y, target_rotation_degrees_y, 0.2)
	
	position.z = lerp(position.z, zoom_target, 0.2)
	
	position.y = lerp(position.y, height_target, 0.1)
	
	# calculate horizontal offset
	var zoom_factor = (position.z - zoom_pos_min) / zoom_pos_max
	var horizontal_offset = 0.05 + (0.7 * zoom_factor)
	$Camera3D.position.x = lerp($Camera3D.position.x, horizontal_offset, 0.2)
