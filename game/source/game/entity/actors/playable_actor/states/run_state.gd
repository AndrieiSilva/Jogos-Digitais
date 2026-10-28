class_name RunState extends PlayerState

func _transition_to() -> void:
	if actor.current_enemy_target:
		if actor.position.distance_to(actor.current_enemy_target.position) > actor.current_weapon_data.range:
			state_chart.send_event(States["follow"])
		else:
			state_chart.send_event(States["baseAttack"])
		return
	
	if Input.is_action_just_pressed("spin_attack"):
		state_chart.send_event(States["spinAttack"])
		return
	
	if Input.is_action_just_pressed("leon_kick"):
		state_chart.send_event(States["leonKick"])
	
	if actor.velocity.is_zero_approx():
		state_chart.send_event(States["idle"])

func _state_action(delta : float) -> void:
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

func _on_run_state_entered() -> void:
	pass

func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 1, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val

func _on_run_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
	input()

func _on_run_state_exited() -> void:
	is_primary_button_pressed = false

var is_primary_button_pressed : bool = false

func input() -> void:
	if Input.is_action_pressed("primary_action") and is_primary_button_pressed:
		await get_tree().physics_frame
		PlayerInputHelper.handle_player_click(nav_agent, actor, get_viewport(), PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), actor, get_viewport()))

func _on_run_state_unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("primary_action"):
		is_primary_button_pressed = true
	elif Input.is_action_just_released("primary_action"):
		is_primary_button_pressed = false
