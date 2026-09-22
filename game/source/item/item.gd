class_name Item extends RigidBody3D

const MAX_ITENS : int = 10000

@export var item_label : Label3D
@export var particles : GPUParticles3D

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
	_apply_force()
	_control_item_limit()
	_load_model()
	_set_effects()
	
	if "coin" in item_data.name.to_lower():
		is_auto_collected = true


func _process(delta: float) -> void:
	item_label.global_position = self.global_position + Vector3(0, 1, 0)
	particles.global_position = self.global_position
	_auto_collect_control(delta)
	
var cool : float = 20.0
func _auto_collect_control(delta : float) -> void:
	if not is_auto_collected:
		return
	
	cool -= delta
	if cool <= 0:
		if self in current_itens:
			current_itens.erase(self)
			current_itens_count -= 1
			
			hide()
			set_process(false)
			set_physics_process(false)
			call_deferred("queue_free")

func _control_item_limit() -> void:
	current_itens_count += 1
	current_itens.append(self)
	
	if current_itens_count > MAX_ITENS:
		var item : Item = current_itens.pop_front()
		item.call_deferred("queue_free")
		current_itens_count -= 1

func _set_effects() -> void:
	item_label.text = ""
	particles.emitting = false
	if "coin" in item_data.name.to_lower():
		return
	
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


func _load_model() -> void:
	var path : String = ResourceUID.uid_to_path(item_data.model_uid)
	ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		var model_packed: PackedScene = ResourceLoader.load_threaded_get(path)
		var model_instance: Node3D = model_packed.instantiate() as Node3D
		add_child(model_instance)
