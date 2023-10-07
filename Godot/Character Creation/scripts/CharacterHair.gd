class_name CharacterHair extends Node3D

func get_mesh():
	pass

func get_material():
	pass

func set_color(color_a, color_b):
	var mat: StandardMaterial3D = get_material()
	mat.albedo_color = color_a
