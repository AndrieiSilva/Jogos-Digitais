class_name Enemy extends Bot

const OUTLINE_MAT = preload("uid://ca7yc1o6y3bbl")

@export var model_node : Node3D
var meshes : Array[MeshInstance3D] = []


func _ready() -> void:
	recursive_mesh_search(model_node)

func set_outline_enabled(enabled : bool) -> void:
	for mesh : MeshInstance3D in meshes:
		if enabled:
			mesh.material_overlay = OUTLINE_MAT
		else:
			mesh.material_overlay = null

func recursive_mesh_search(node : Node3D) -> void:
	if not node:
		return
		
	if node is MeshInstance3D:
		meshes.append(node as MeshInstance3D)
		
	for child in node.get_children():
		if child is Node3D:
			recursive_mesh_search(child)
