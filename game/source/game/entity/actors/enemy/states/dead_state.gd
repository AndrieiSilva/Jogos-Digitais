class_name EnemyDeadState extends EnemyState


func _transition_to() -> void:
	pass

func _state_action(delta : float) -> void:
	pass


func _on_dead_state_entered() -> void:
	actor.queue_free()


func _on_dead_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_dead_state_exited() -> void:
	pass # Replace with function body.
