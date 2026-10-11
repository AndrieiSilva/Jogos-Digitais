class_name AttackState extends PlayerState

func _transition_to() -> void:
	var player : AnimationPlayer = actor.character_animated_model.anim_player
	if not player.is_playing():
		actor.current_enemy_target = null
		state_chart.send_event(States["idle"])

func _state_action(delta : float) -> void:
	animate()
	lerped_look(delta)

func lerped_look(delta : float) -> void:
	var rotation_speed : float = 7
	
	if actor.current_enemy_target:
		var target_pos : Vector3 = actor.current_enemy_target.global_position
		target_pos.y = actor.global_transform.origin.y
		
		if actor.global_transform.origin.distance_to(target_pos) > 0.001:
			var temp_transform = actor.global_transform.looking_at(target_pos, Vector3.UP)
			actor.global_transform.basis = actor.global_transform.basis.slerp(temp_transform.basis, rotation_speed * delta)

func _on_base_attack_state_entered() -> void:
	animate()
	

func animate() -> void:
	var player : AnimationPlayer = actor.character_animated_model.anim_player
	
	if player.is_playing():
		if not player.current_animation == "slash_attack":
			player.play("slash_attack")
	else:
		player.play("slash_attack")

func _on_base_attack_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
