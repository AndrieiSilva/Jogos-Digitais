class_name Item extends RigidBody3D

const MAX_ITENS : int = 1000

const ITEM_PARTICLES = preload("uid://c0rvlvy876kpp")

const ITEM_MAT = preload("uid://dnbdr1jbbsg6d")
const OUTLINE_MAT = preload("uid://ca7yc1o6y3bbl")

const BRONZE_COIN = preload("uid://druluy16d6maa")
const SILVER_COIN = preload("uid://dq4736j7h30pl")
const GOLD_COIN = preload("uid://bk8vqy1v48i1e")


@export var item_label : Label3D
@export var particles : GPUParticles3D

@export var model_node : Node3D
var meshes : Array[MeshInstance3D] = []

var item_data : ItemData
static var current_itens_count : int = 0
static var current_itens : Array[Item] = []
var is_auto_collected : bool = false

func generate_dir() -> Vector3:
	var dir : Vector3 = Vector3(randf_range(-1, 1), 1, randf_range(-1, 1))
	dir = dir.normalized()
	dir.y = 2
	return dir

func _apply_force() -> void:
	var item_fly_strenght : float = 3
	var dir : Vector3 = generate_dir()
	var force : Vector3 = dir * item_fly_strenght
	apply_impulse(force, Vector3.UP)

func _ready() -> void:
	position.y += 1
	_apply_force()
	_load_model()
	_set_effects()
	
	if item_data is CurrencyData:
		is_auto_collected = true
		collision_layer = 0

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


func _process(delta: float) -> void:
	item_label.global_position = self.global_position + Vector3(0, 1, 0)
	if particles:
		particles.global_position = self.global_position


func _set_effects() -> void:
	if item_data is CurrencyData:
		item_label.text = ""
		return
	
	_create_gpu_particles()
	item_label.text = item_data.name.to_upper()
	particles.emitting = true
	
	var mat : StandardMaterial3D = particles.draw_pass_1.surface_get_material(0)
	
	if mat:
		var mat_unique = mat.duplicate()
		
		particles.draw_pass_1.surface_set_material(0, mat_unique)
		
		var color : Color
		match item_data.rarity:
			ItemData.Rarity.COMMON:
				color = Color(0.5, 0.5, 0.5)
			ItemData.Rarity.UNCOMMON:
				color = Color(0.0, 1.0, 0.0)
			ItemData.Rarity.RARE:
				color = Color(0.0, 0.0, 1.0)
			ItemData.Rarity.LEGENDARY:
				color = Color(1.0, 1.0, 0.0)
			
		mat_unique.albedo_color = color
	else:
		printerr("no mat")

func _create_gpu_particles() -> void:
	particles = ITEM_PARTICLES.instantiate()
	add_child(particles)


func _load_model() -> void:
	if item_data is CurrencyData:
		var item_name : String = item_data.name.to_lower()
		if "bronze" in item_name:
			model_node.add_child(BRONZE_COIN.instantiate())
		elif "silver" in item_name:
			model_node.add_child(SILVER_COIN.instantiate())
		elif "gold" in item_name:
			model_node.add_child(GOLD_COIN.instantiate())
		return
	
	var path : String = ResourceUID.uid_to_path(item_data.model_uid)
	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		var model_packed: PackedScene = ResourceLoader.load_threaded_get(path)
		var model_instance: Node3D = model_packed.instantiate() as Node3D
		model_node.add_child(model_instance)
		recursive_mesh_search(model_node)
