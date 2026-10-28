extends Node
@warning_ignore_start("unused_signal")

#region Actors
signal playable_actor_entered_level(actor : Actor)
#endregion

#region LevelManager
#endregion

#region GameManager
signal add_scene_to_layer(new_scene_uid : String, layer_name : String)
signal remove_scene_from_layer(new_scene_uid : String, layer_name : String)
signal clear_scenes_from_layer(layer_name : String)
signal scene_load_finished(loaded_scene_uid : String)
#endregion
