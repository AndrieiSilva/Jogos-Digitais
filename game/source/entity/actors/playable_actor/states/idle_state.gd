class_name IdleState extends PlayerState

var click_pressed : bool = true

func _unhandled_input(event: InputEvent) -> void:
	if actor.current_state != States["idle"]:
		return
	
	if Input.is_action_pressed("primary_action"):
		click_pressed = true
	elif Input.is_action_just_released("primary_action"):
		click_pressed = false


func handle_input() -> void:
	if not click_pressed:
		return
	
	if Input.is_action_pressed("primary_action"):
		await get_tree().physics_frame
		PlayerInputHelper.handle_player_click(nav_agent, actor, get_viewport(), PlayerInputHelper.calc_click_pos(get_viewport().get_mouse_position(), actor, get_viewport()))


func _transition_to() -> void:
	if actor.current_enemy_target:
		if actor.position.distance_to(actor.current_enemy_target.position) > actor.current_weapon_data.range:
			state_chart.send_event(States["follow"])
		else:
			state_chart.send_event(States["baseAttack"])
	
	if Input.is_action_just_pressed("spin_attack"):
		state_chart.send_event(States["spinAttack"])
	
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
	actor.current_state = States["idle"]


func _on_idle_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
	handle_input()
