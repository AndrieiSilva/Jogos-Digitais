extends Node

var itens_folder : String = "res://data/resource/itens/"
var all_itens : Array[ItemData] = []
var coin_itens : Array[ItemData] = []
var equipment_itens : Array[ItemData] = []

func _ready() -> void:
	_load_all_itens()

func _load_all_itens() -> void:
	all_itens.clear()
	coin_itens.clear()
	equipment_itens.clear()
	
	_recursive_load_itens(itens_folder)

# Função recursiva para varrer pastas e subpastas
func _recursive_load_itens(path : String) -> void:
	var dir : DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		
		while file_name != "":
			var full_path : String = path.path_join(file_name)
			
			if dir.current_is_dir():
				# Se for um diretório, chama a função recursivamente entrando nele
				_recursive_load_itens(full_path)
			else:
				# Tratamento do sufixo .remap para builds exportadas
				if file_name.ends_with(".remap"):
					file_name = file_name.trim_suffix(".remap")
					full_path = path.path_join(file_name)
				
				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var item : ItemData = load(full_path)
					if item:
						all_itens.append(item)
						_filter(item)
			
			file_name = dir.get_next()
		dir.list_dir_end()

func _filter(item : ItemData) -> void:	
	if item is CurrencyData:
		coin_itens.append(item)
		return
	
	if item is WeaponData or item is ArmorData:
		equipment_itens.append(item)
