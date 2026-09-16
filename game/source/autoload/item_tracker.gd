extends Node

var itens_folder : String = "res://data/resource/itens/"
var all_itens : Array[ItemData] = []
var coin_itens : Array[ItemData] = []
var equipment_itens : Array[ItemData] = []

func _ready() -> void:
	_load_all_itens()

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
						if "coin" in file_name.to_lower():
							coin_itens.append(item)
						elif "sword" in file_name.to_lower():
							equipment_itens.append(item)
			
			file_name = dir.get_next()
		dir.list_dir_end()
