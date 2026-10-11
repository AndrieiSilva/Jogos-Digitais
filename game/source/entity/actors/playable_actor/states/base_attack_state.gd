class_name AttackState extends PlayerState



func _transition_to() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/SlashShot/active")
	if not one_shot_active:
		actor.current_enemy_target = null
		state_chart.send_event(States["idle"])

func _state_action(delta : float) -> void:
	lerped_look(delta)
	animate(delta)

func lerped_look(delta : float) -> void:
	var rotation_speed : float = 7
	
	if actor.current_enemy_target:
		var target_pos : Vector3 = actor.current_enemy_target.global_position
		target_pos.y = actor.global_transform.origin.y
		
		if actor.global_transform.origin.distance_to(target_pos) > 0.001:
			var temp_transform = actor.global_transform.looking_at(target_pos, Vector3.UP)
			actor.global_transform.basis = actor.global_transform.basis.slerp(temp_transform.basis, rotation_speed * delta)


func _on_base_attack_state_entered() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/SlashShot/active")
	if not one_shot_active:
		player.set("parameters/SlashShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 0, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val


func _on_base_attack_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
