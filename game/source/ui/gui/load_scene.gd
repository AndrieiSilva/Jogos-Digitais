class_name LoadScene extends Node

var loading_scene_uid : String = ""
@export var load_label : Label = null

func _ready() -> void:
	Bus.scene_load_finished.connect(_on_scene_load_finished)
	get_tree().create_timer(.2).timeout.connect(_update_text)


var load_text : String = "."

func _update_text() -> void:
	load_label.text = load_text
	if load_text == "...":
		load_text = "."
	else:
		load_text += "."
	get_tree().create_timer(.2).timeout.connect(_update_text)

func _on_scene_load_finished(loaded_scene_uid) -> void:
	if loaded_scene_uid == loading_scene_uid:
		Bus.remove_scene_from_layer.emit(ResourceUID.path_to_uid(self.scene_file_path), UiLayersConstants.UiLayers["gui_layer"])


func set_loading_scene_uid(new_loading_scene_uid : String) -> void:
	loading_scene_uid = new_loading_scene_uid
	
