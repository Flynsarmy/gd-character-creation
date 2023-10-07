extends CharacterHair

func get_mesh():
	return $hair_ponytail_physics/Skeleton3D/ponytail

func get_material():
	var mesh:MeshInstance3D = get_mesh()
	return mesh.get_surface_override_material(0)
