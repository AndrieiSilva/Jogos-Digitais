class_name GameManager extends Node

const LOAD_SCENE = preload("uid://fhu30ch4x2st")

@export var game_layer: CanvasLayer = null
@export var hud_layer: CanvasLayer = null
@export var gui_layer: CanvasLayer = null


func _ready() -> void:
	connect_all_signals()
	Bus.add_scene_to_layer.emit(SceneUIDConstants.GuiScenes["start_menu"], UiLayersConstants.UiLayers["gui_layer"])


func connect_all_signals() -> void:
	#region Scenes
	Bus.add_scene_to_layer.connect(_on_add_scene_to_layer)
	Bus.remove_scene_from_layer.connect(_on_remove_scene_from_layer)
	Bus.clear_scenes_from_layer.connect(_on_clear_scenes_from_layer)
	#endregion
	
	#region PlayableCharacter
	Bus.playable_actor_entered_level.connect(
		func(_actor): 
			_on_add_scene_to_layer(
				SceneUIDConstants.HudScenes["hud"], 
				UiLayersConstants.UiLayers["hud_layer"]
			)
	)
	#endregion


func _on_add_scene_to_layer(new_scene_uid: String, layer_name: String) -> void:
	var layer_to_add: CanvasLayer = _get_layer_by_name(layer_name)
	
	if not layer_to_add:
		return
		
	if is_scene_already_loaded_in_layer(layer_to_add, new_scene_uid):
		return
	
	if not is_scene_already_loaded_in_layer(gui_layer, SceneUIDConstants.GuiScenes["load_scene"]):
		var load_scene_instance: LoadScene = LOAD_SCENE.instantiate()
		load_scene_instance.set_loading_scene_uid(new_scene_uid)
		gui_layer.add_child(load_scene_instance)
	
	var scene_packed: PackedScene = await load_scene(ResourceUID.uid_to_path(new_scene_uid))
	if not scene_packed:
		return
	
	Bus.scene_load_finished.emit(new_scene_uid)
	layer_to_add.call_deferred("add_child", scene_packed.instantiate())


func _on_remove_scene_from_layer(new_scene_uid: String, layer_name: String) -> void:
	var target_layer: CanvasLayer = _get_layer_by_name(layer_name)
	if not target_layer:
		return

	var scene_path: String = ResourceUID.uid_to_path(new_scene_uid)
	for child: Node in target_layer.get_children():
		if child.scene_file_path == scene_path:
			child.call_deferred("queue_free")
			return


func _on_clear_scenes_from_layer(layer_name: String) -> void:
	var target_layer: CanvasLayer = _get_layer_by_name(layer_name)
	if not target_layer:
		return

	for child: Node in target_layer.get_children():
		child.call_deferred("queue_free")


func load_scene(scene_path: String) -> PackedScene:
	var err = ResourceLoader.load_threaded_request(scene_path, "", true)
	if err != OK:
		push_error("Error while trying to load scene: ", scene_path)
		return null
	
	var progress = []
	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				return ResourceLoader.load_threaded_get(scene_path) as PackedScene
				
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Failed to load scene: ", scene_path)
				return null
				
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
				
		await get_tree().process_frame
	
	return null


func is_scene_already_loaded_in_layer(layer: CanvasLayer, scene_uid: String) -> bool:
	if not layer:
		return false
		
	var target_path: String = ResourceUID.uid_to_path(scene_uid)
	for child: Node in layer.get_children():
		if child.scene_file_path == target_path:
			return true
	
	return false


func _get_layer_by_name(layer_name: String) -> CanvasLayer:
	match layer_name:
		UiLayersConstants.UiLayers["game_layer"]:
			return game_layer
		UiLayersConstants.UiLayers["hud_layer"]:
			return hud_layer
		UiLayersConstants.UiLayers["gui_layer"]:
			return gui_layer
	return null
