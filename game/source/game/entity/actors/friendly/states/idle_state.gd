class_name FriendlyIdleState extends FriendlyState

func _transition_to() -> void:
	state_chart.send_event(States["talk"])

func _state_action(delta : float) -> void:
	pass


func _on_idle_state_entered() -> void:
	actor = actor as FriendlyActor
	actor.detection_area_playable_actor_entered.connect(_transition_to.unbind(1))
	


func _on_idle_state_physics_processing(delta: float) -> void:
	_state_action(delta)
	#_transition_to()


func _on_idle_state_exited() -> void:
	actor = actor as FriendlyActor
	actor.detection_area_playable_actor_entered.disconnect(_transition_to.unbind(1))
