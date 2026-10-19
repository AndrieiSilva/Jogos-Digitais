class_name Enemy extends Actor

const OUTLINE_MAT = preload("uid://ca7yc1o6y3bbl")

@export var model_node : Node3D = null
@export var life_label : Label3D = null
var meshes : Array[MeshInstance3D] = []


func _ready() -> void:
	super._ready()
	recursive_mesh_search(model_node)
	var rand_x : float = randf_range(-10, 10)
	var rand_z : float = randf_range(-10, 10)
	nav_agent.target_position = Vector3(rand_x + self.position.x, 0, rand_z + self.position.z)

func _process(delta: float) -> void:
	_on_move_requested()
	life_label.text = "HEALTH: " + str(actor_data.current_health)

func _physics_process(delta: float) -> void:
	if push_velocity.length() > 0.01:
		velocity = push_velocity
		move_and_slide()
		
		push_velocity = push_velocity.move_toward(Vector3.ZERO, 15.0 * delta)
		return



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
