extends Node

var itens_folder : String = "res://data/resource/itens/"
var all_itens : Array[ItemData] = []
var coin_itens : Array[ItemData] = []
var equipment_itens : Array[ItemData] = []

var equipments_common : Array[ItemData] = []
var equipments_uncommon : Array[ItemData] = []
var equipments_rare : Array[ItemData] = []
var equipments_legendary : Array[ItemData] = []

var equipment_by_rarity : Dictionary = {}

func _ready() -> void:
	_load_all_itens()
	equipment_by_rarity = {
		ItemData.Rarity.COMMON : equipments_common,
		ItemData.Rarity.UNCOMMON : equipments_uncommon,
	}

func _load_all_itens() -> void:
	all_itens.clear()
	
	var dir : DirAccess = DirAccess.open(itens_folder)
	if dir:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".remap"):
					file_name = file_name.trim_suffix(".remap")
				
				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var full_path : String = itens_folder + file_name
					var item : ItemData = load(full_path)
					if item:
						all_itens.append(item)
						_filter(item)
			
			file_name = dir.get_next()
		dir.list_dir_end()

func _filter(item : ItemData) -> void:
	var item_name : String = item.name.to_lower()
	
	if "coin" in item_name:
		coin_itens.append(item)
		return
	
	if "sword" in item_name or "armor" in item_name:
		equipment_itens.append(item)
		
		match item.rarity:
			ItemData.Rarity.COMMON:
				equipments_common.append(item)
			ItemData.Rarity.UNCOMMON:
				equipments_uncommon.append(item)
