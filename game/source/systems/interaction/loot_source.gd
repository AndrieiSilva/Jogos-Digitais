class_name LootSource extends Interaction

@export var item_fly_strenght : float = 2

var item_packed_scene : PackedScene = preload("res://source/item/item.tscn")

var min_qt : int = 100
var max_qt : int = 300

enum Tier {
	BRONZE,
	SILVER,
	GOLD,
	DIAMOND,
}

@export var source_tier : Tier = Tier.BRONZE

func _ready() -> void:
	super._ready()
	
	match source_tier:
		Tier.BRONZE:
			min_qt = 50
			max_qt = 100
		Tier.SILVER:
			min_qt = 100
			max_qt = 300
		Tier.GOLD:
			min_qt = 500
			max_qt = 1000
		Tier.DIAMOND:
			min_qt = 1000
			max_qt = 1500

func _interact() -> void:
	_spawn_loot()


func _spawn_loot() -> void:
	var item_qt : int = randi_range(min_qt, max_qt) 
	
	var total_weight : float = 0.0
	for item in ItemTracker.coin_itens:
		total_weight += item.spawn_weight
	
	for i : int in range(item_qt):
		var dir : Vector3 = generate_dir()
		var chosen_item : ItemData = _get_item_by_weight(total_weight)
		var model : Node3D = await instantiate_model(ResourceUID.uid_to_path(chosen_item.model_uid))
		var item : Item = item_packed_scene.instantiate()
		item.add_child(model)
		self.add_child(item)
		var force : Vector3 = dir * item_fly_strenght
		item.apply_impulse(force, Vector3.UP)

func _get_item_by_weight(total_weight : float) -> ItemData:
	var random_val : float = randf() * total_weight
	var current_weight : float = 0.0
	
	for item in ItemTracker.coin_itens:
		current_weight += item.spawn_weight
		if random_val <= current_weight:
			return item
			
	return ItemTracker.coin_itens.front()

func instantiate_item(path: String) -> Item:
	ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		var item_packed: PackedScene = ResourceLoader.load_threaded_get(path)
		var item_instance: Item = item_packed.instantiate() as Item
		return item_instance
		
	return null

func instantiate_model(path: String) -> Node3D:
	ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		var model_packed: PackedScene = ResourceLoader.load_threaded_get(path)
		var model_instance: Node3D = model_packed.instantiate() as Node3D
		return model_instance
		
	return null

func generate_dir() -> Vector3:
	var dir : Vector3 = Vector3(randf_range(-1, 1), 1, randf_range(-1, 1))
	dir = dir.normalized()
	return dir
