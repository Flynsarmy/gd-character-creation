class_name CharacterBody extends Node3D

@export var type:CharacterType

func get_skeleton() -> Skeleton3D:
	return $Skeleton3D


func get_mesh() -> MeshInstance3D:
	return $Skeleton3D/body


func get_sub_mesh(named:String) -> MeshInstance3D:
	return $Skeleton3D.find_child(named, false)


func get_sub_meshes(include_hair:bool = true) -> Array[MeshInstance3D]:
	var meshes:Array[MeshInstance3D] = []
	meshes.append(get_sub_mesh("eyebrow008"))
	meshes.append(get_sub_mesh("eyelashes01"))
	meshes.append(get_sub_mesh("teeth_shape05"))
	meshes.append(get_sub_mesh("tongue01"))
	if include_hair:
		meshes.append(get_hair().get_mesh())
	return meshes


func get_hair() -> CharacterHair:
	return get_head().get_node("Hair")


func get_eye_mesh_left() -> MeshInstance3D:
	return $Skeleton3D/EyeLeft/EyeGimbal/eye.get_mesh()


func get_eye_mesh_right() -> MeshInstance3D:
	return $Skeleton3D/EyeRight/EyeGimbal/eye.get_mesh()


func get_look_at_target():
	return $Skeleton3D/LookAtTarget


func get_pelvis() -> BoneAttachment3D:
	return $Skeleton3D/Pelvis


func get_head() -> BoneAttachment3D:
	return $Skeleton3D/Head


func get_bone_position(bone_name:String) -> Vector3:
	var bone_idx = get_skeleton().find_bone(bone_name)
	if bone_idx == -1:
		push_error("Unknown bone name " + bone_name + " for CharacterBody.")
		return Vector3()
	else:
		var tf = get_skeleton().get_bone_global_pose(bone_idx)
		return tf.origin


func apply_blendshape_to_body(blendshape:String, value:float, propagate:bool = true):
	var mesh = get_mesh()
	var blendshape_idx = mesh.find_blend_shape_by_name(blendshape)

	if blendshape_idx != -1:
		mesh.set_blend_shape_value(blendshape_idx, value)

	if propagate:
		var sub_meshes = get_sub_meshes()
		for sub_mesh in sub_meshes:
			if sub_mesh:
				blendshape_idx = sub_mesh.find_blend_shape_by_name(blendshape)
				if blendshape_idx != -1:
					sub_mesh.set_blend_shape_value(blendshape_idx, value)


func get_skin_material() -> ShaderMaterial:
	return get_mesh().get_surface_override_material(0)


func get_fingernails_material() -> StandardMaterial3D:
	return get_mesh().get_suface_override_material(1)


func get_toenails_material() -> StandardMaterial3D:
	return get_mesh().get_suface_override_material(2)


func set_skin_color(color:Color):
	var mat = get_skin_material()
	mat.set_shader_parameter("skin_color", color)


func set_skin_age_factor(factor:float):
	var mat = get_skin_material()
	mat.set_shader_parameter("age_factor", factor)


func set_eye_color(color):
	var left_mat:StandardMaterial3D = get_eye_mesh_left().get_surface_override_material(1)
	var right_mat:StandardMaterial3D = get_eye_mesh_right().get_surface_override_material(1)
	left_mat.albedo_color = color
	right_mat.albedo_color = color

func set_hair_color(color):
	get_hair().set_color(color, color)
