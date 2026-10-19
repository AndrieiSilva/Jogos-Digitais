class_name EnemyFollowState extends EnemyState


func _transition_to() -> void:
	if actor.actor_data.current_health <= 0:
		state_chart.send_event(States["dead"])
	
	if actor.current_enemy_target:
		if actor.position.distance_to(actor.current_enemy_target.position) <= actor.current_weapon_data.range:
			state_chart.send_event(States["baseAttack"])
	else:
		state_chart.send_event(States["idle"])


func _state_action(delta : float) -> void:
	if not actor.current_enemy_target:
		nav_agent.target_position = actor.position
		return
	
	if actor.position.distance_to(actor.current_enemy_target.position) > actor.current_weapon_data.range:
		nav_agent.target_position = actor.current_enemy_target.position
	
	lerped_look(delta)
	animate(delta)


func lerped_look(delta : float) -> void:
	var look_dir : Vector3 = (actor.velocity * Vector3(1, 0, 1))
	var rotation_speed : float = 7
	
	if not look_dir.is_zero_approx():
		look_dir = look_dir.normalized()
		var target_pos = actor.global_transform.origin + look_dir
		var temp_transform = actor.global_transform.looking_at(target_pos, Vector3.UP)
		actor.global_transform.basis = actor.global_transform.basis.slerp(temp_transform.basis, rotation_speed * delta)


func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 1, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val


func _on_follow_state_entered() -> void:
	pass # Replace with function body.


func _on_follow_state_physics_processing(delta: float) -> void:
	_state_action(delta)
	_transition_to()


func _on_follow_state_exited() -> void:
	pass # Replace with function body.
