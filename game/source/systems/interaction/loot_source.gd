class_name LootSource extends Interaction

@export var item_fly_strenght : float = 3

var item_packed_scene : PackedScene = preload("res://source/item/item.tscn")

var min_coin : int
var max_coin : int
var min_equipment : int
var max_equipment : int
#----------------------------
var rarity_array : Array[ItemData.Rarity] = [ItemData.Rarity.COMMON, ItemData.Rarity.UNCOMMON]
var rarity_weight_array : Array[float] = []

@export var source_tier : LootTiers.Tiers = LootTiers.Tiers.BRONZE

func _ready() -> void:
	super._ready()
	_setup_reward(source_tier)

func _setup_reward(tier : LootTiers.Tiers) -> void:
	var tier_data : Dictionary = LootTiers.TIER[source_tier]
	var coins_id : String = "coins"
	var equipment_id : String = "equipments"
	var min_id : String = "min"
	var max_id : String = "max"
	var eligible_rarity_id : String = "eligible_rarity"
	var common_id = "common"
	var uncommon_id = "uncommon"
	
	min_coin = tier_data[coins_id][min_id]
	max_coin = tier_data[coins_id][max_id]
	min_equipment = tier_data[equipment_id][min_id]
	max_equipment = tier_data[equipment_id][max_id]
	rarity_weight_array.append(tier_data[eligible_rarity_id].get(common_id, 0.0))
	rarity_weight_array.append(tier_data[eligible_rarity_id].get(uncommon_id, 0.0))

func _interact() -> void:
	_spawn_loot(ItemTracker.coin_itens, min_coin, max_coin)
	_spawn_loot(ItemTracker.equipment_itens, min_equipment, max_equipment)


func _select_rarity() -> ItemData.Rarity:
	var total_weight : float
	for w in rarity_weight_array:
		total_weight += w
	
	var random_val : float = randf() * total_weight
	var current_weight : float = 0
	var i : int = 0
	
	for rarity in rarity_array:
		current_weight += rarity_weight_array[i]
		if random_val <= current_weight:
			return rarity_array[i]
		i += 1
	
	return ItemData.Rarity.COMMON

func _spawn_loot(item_array : Array[ItemData], min : int, max : int) -> void:
	var item_qt : int = randi_range(min, max) 
	
	var total_weight : float = 0.0
	for item in item_array:
		total_weight += item.spawn_weight
	
	for i : int in range(item_qt):
		var dir : Vector3 = generate_dir()
		var item : Item = item_packed_scene.instantiate()
		item.item_data = _get_item_by_weight(total_weight, item_array)
		self.add_child(item)
		var force : Vector3 = dir * item_fly_strenght
		item.apply_impulse(force, Vector3.UP)

func _get_item_by_weight(total_weight : float, item_array : Array[ItemData]) -> ItemData:
	var random_val : float = randf() * total_weight
	var current_weight : float = 0.0
	
	for item in item_array:
		current_weight += item.spawn_weight
		if random_val <= current_weight:
			return item
			
	return item_array.front()

func generate_dir() -> Vector3:
	var dir : Vector3 = Vector3(randf_range(-1, 1), 1, randf_range(-1, 1))
	dir = dir.normalized()
	dir.y = 2
	return dir
