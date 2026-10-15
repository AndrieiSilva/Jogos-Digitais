class_name EnemyIdleState extends EnemyState


func _transition_to() -> void:
	if actor.actor_data.current_health <= 0:
		state_chart.send_event(States["dead"])

func _state_action(delta : float) -> void:
	pass


func _on_idle_state_entered() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	_state_action(delta)
	_transition_to()


func _on_idle_state_exited() -> void:
	pass # Replace with function body.
