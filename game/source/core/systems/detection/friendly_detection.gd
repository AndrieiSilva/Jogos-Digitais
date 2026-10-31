class_name FriendlyDetection extends Area3D

var actor : FriendlyActor = null


func _ready() -> void:
	actor = owner
	var bodies_in_area : Array[Node3D] = get_overlapping_bodies()
	for body : Node3D in bodies_in_area:
		if body is PlayableActor:
			actor.current_enemy_target = body
			return
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_exited(body : Node3D) -> void:
	if body is PlayableActor:
		actor.detection_area_playable_actor_exited.emit(body)


func _on_body_entered(body : Node3D) -> void:
	if body is PlayableActor:
		actor.detection_area_playable_actor_entered.emit(body)
