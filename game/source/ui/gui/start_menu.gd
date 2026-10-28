extends Node


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.


func _on_new_game_button_pressed() -> void:
	Bus.remove_scene_from_layer.emit(ResourceUID.path_to_uid(self.scene_file_path), UiLayersConstants.UiLayers["gui_layer"])
	Bus.add_scene_to_layer.emit(SceneUIDConstants.GameScenes["level_manager"], UiLayersConstants.UiLayers["game_layer"])


func _on_load_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)
