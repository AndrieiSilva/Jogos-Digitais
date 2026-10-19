class_name IdleState extends PlayerState

func _transition_to() -> void:
	if actor.current_enemy_target:
		if actor.position.distance_to(actor.current_enemy_target.position) > actor.current_weapon_data.range:
			state_chart.send_event(States["follow"])
		else:
			state_chart.send_event(States["baseAttack"])
	
	if Input.is_action_just_pressed("spin_attack"):
		state_chart.send_event(States["spinAttack"])
	
	if Input.is_action_just_pressed("leon_kick"):
		state_chart.send_event(States["leonKick"])
	
	if actor.velocity.is_zero_approx():
		pass
	elif not actor.velocity.is_zero_approx():
		state_chart.send_event(States["run"])

func _state_action(delta : float) -> void:
	animate(delta)

func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 0, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val

func _on_idle_state_entered() -> void:
	pass


func _on_idle_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
	input()

func _on_idle_state_exited() -> void:
	pass # Replace with function body.

var is_primary_button_pressed : bool = false

func input() -> void:
	if Input.is_action_pressed("primary_action"):
		await get_tree().physics_frame
		PlayerInputHelper.handle_player_click(nav_agent, actor, get_viewport(), PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), actor, get_viewport()))

func _on_idle_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("primary_action"):
		is_primary_button_pressed = true
	elif Input.is_action_just_released("primary_action"):
		is_primary_button_pressed = false
