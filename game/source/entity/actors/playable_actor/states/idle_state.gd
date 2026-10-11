class_name IdleState extends PlayerState

func handle_input() -> void:
	if Input.is_action_pressed("primary_action"):
		await get_tree().physics_frame
		var result : Dictionary = _calc_click_pos(get_viewport().get_mouse_position())
		if not result:
			return
		var collider : Node3D = result.collider
		
		if collider is Interaction:
			collider._interact()
		elif collider.get_parent().get_parent() is Interaction:
			collider.get_parent().get_parent()._interact()
			collider = collider as StaticBody3D
		elif collider is Enemy:
			actor.current_enemy_target = collider
		else:
			var target_pos : Vector3 = result.position
			nav_agent.target_position = target_pos

func _transition_to() -> void:
	if actor.current_enemy_target:
		if actor.position.distance_to(actor.current_enemy_target.position) > actor.min_attack_range:
			state_chart.send_event(States["follow"])
		else:
			state_chart.send_event(States["baseAttack"])
	
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
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)
	handle_input()

func _calc_click_pos(click_pos : Vector2) -> Dictionary:
	var space_state = actor.get_world_3d().direct_space_state
	var cam : Camera3D = get_viewport().get_camera_3d()
	var ray_lenght : float = 1000
	var ray_origin : Vector3 = cam.project_ray_origin(click_pos)
	var ray_normal : Vector3 = cam.project_ray_normal(click_pos) * ray_lenght
	var ray_end : Vector3 = ray_origin + ray_normal
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result : Dictionary = space_state.intersect_ray(query)
	
	return result
