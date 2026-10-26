class_name EnemyIdleState extends EnemyState


func _transition_to() -> void:
	if actor.actor_data.current_health <= 0:
		state_chart.send_event(States["dead"])
	
	if actor.current_enemy_target:
		if actor.position.distance_to(actor.current_enemy_target.position) > actor.current_weapon_data.range:
			state_chart.send_event(States["follow"])
		elif actor.position.distance_to(actor.current_enemy_target.position) <= actor.current_weapon_data.range:
			state_chart.send_event(States["baseAttack"])
	
	if not actor.velocity.is_zero_approx():
		state_chart.send_event(States["run"])

func _state_action(delta : float) -> void:
	animate(delta)

func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 0, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val


func _on_idle_state_entered() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	_state_action(delta)
	_transition_to()


func _on_idle_state_exited() -> void:
	pass # Replace with function body.
