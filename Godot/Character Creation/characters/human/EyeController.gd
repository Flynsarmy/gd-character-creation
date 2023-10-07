@tool
extends Node3D

@export var min_rotation: Vector2 = Vector2(-45, -45)
@export var max_rotation: Vector2 = Vector2(45, 45)
@export var target: NodePath
@export var rotation_speed: float = 5.0
@onready var target_object: Node3D = get_node(target)

@export var animation_tree_node:NodePath
@export var eyelid_anim_path:String = "parameters/eyelids/blend_position"
var animTree:AnimationTree

func _ready():
	if animation_tree_node:
		animTree = get_node(animation_tree_node)

func get_mesh() -> MeshInstance3D:
	return $eye2

func _process(delta: float) -> void:
	if target_object != null:
		# Get target position in eye's local space
		var target_local_position = to_local(target_object.global_transform.origin)
		var look_at_position = -transform.origin.direction_to(target_local_position)
		var look_at_rotation = Basis()

		# Calculate look-at rotation and extract X/Y rotation angles
		if look_at_position.length_squared() > 0.00001:
			var z_axis = -look_at_position.normalized()
			var y_axis = Vector3.UP.cross(z_axis).normalized()
			var x_axis = z_axis.cross(y_axis)
			look_at_rotation.x = x_axis
			look_at_rotation.y = y_axis
			look_at_rotation.z = z_axis
		var x_rotation = look_at_rotation.get_euler().x
		var y_rotation = look_at_rotation.get_euler().y

		# Limit rotation angles
		x_rotation = clamp(x_rotation, deg_to_rad(min_rotation.x), deg_to_rad(max_rotation.x))
		y_rotation = clamp(y_rotation, deg_to_rad(min_rotation.y), deg_to_rad(max_rotation.y))

		# Apply limited rotation to transform
		var target_rotation = Basis().rotated(Vector3(0, 1, 0), y_rotation).rotated(Vector3(1, 0, 0), x_rotation)
		var current_quat = transform.basis.get_rotation_quaternion()
		var target_quat = target_rotation.get_rotation_quaternion()
		transform.basis = Basis(current_quat.slerp(target_quat, rotation_speed * delta))
	
	if animTree:
		#var angle = 0
		#var eye_pos = position
		#var target_pos = to_local(target_object.global_position)
		#eye_pos.x = 0
		#target_pos.x = 0
		
		var rot = rotation_degrees.y
		
		rot = clamp(rot * 2, -45, 45) / 45
		
		animTree.set(eyelid_anim_path, rot)

