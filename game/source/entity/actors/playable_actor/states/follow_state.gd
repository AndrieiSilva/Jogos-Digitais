class_name FollowState extends PlayerState

func _transition_to() -> void:
	if not actor.current_enemy_target:
		state_chart.send_event(States["idle"])
	elif actor.position.distance_to(actor.current_enemy_target.position) <= actor.min_attack_range:
		nav_agent.target_position = actor.position
		state_chart.send_event(States["baseAttack"])



func _state_action(delta : float) -> void:
	if not actor.current_enemy_target:
		nav_agent.target_position = actor.position
		return
	
	if actor.position.distance_to(actor.current_enemy_target.position) > actor.min_attack_range:
		nav_agent.target_position = actor.current_enemy_target.position
	
	lerped_look(delta)
	animate()

func lerped_look(delta : float) -> void:
	var look_dir : Vector3 = (actor.velocity * Vector3(1, 0, 1))
	var rotation_speed : float = 7
	
	if not look_dir.is_zero_approx():
		look_dir = look_dir.normalized()
		var target_pos = actor.global_transform.origin + look_dir
		var temp_transform = actor.global_transform.looking_at(target_pos, Vector3.UP)
		actor.global_transform.basis = actor.global_transform.basis.slerp(temp_transform.basis, rotation_speed * delta)

func animate() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree


func _on_follow_state_entered() -> void:
	pass # Replace with function body.


func _on_follow_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
