class_name LeonKickState extends PlayerState

var actors_hit_array : Array[Actor] = []

func _transition_to() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/LeonShot/active")
	if not one_shot_active:
		state_chart.send_event(States["idle"])


func _state_action(delta : float) -> void:
	animate(delta)

func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 0, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val


func _on_area_entered(area : Area3D) -> void:
	if area is Hurtbox:
		if area.actor == actor:
			return
		
		if area.actor in actors_hit_array:
			return
		
		actors_hit_array.append(area.actor)
		area.receive_damage(actor.current_weapon_data.damage, actor)
		area.push_back(10, (area.actor.global_position - actor.global_position).normalized())


func _on_leon_kick_state_entered() -> void:
	actor.character_animated_model.foot_trails_particles.restart()
	actor.character_animated_model.foot_trails_particles.visible = true
	if not actor.area_hitbox.area_entered.is_connected(_on_area_entered):
		actor.area_hitbox.area_entered.connect(_on_area_entered)
	
	PlayerInputHelper.input_enabled = false
	actor.nav_agent.target_position = actor.position
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/LeonShot/active")
	#if not one_shot_active:
	player.set("parameters/LeonShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	var areas_in_hitbox : Array[Area3D] = actor.area_hitbox.get_overlapping_areas()
	if not areas_in_hitbox.is_empty():
		for area : Area3D in areas_in_hitbox:
			_on_area_entered(area)


func _on_leon_kick_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)


func _on_leon_kick_state_exited() -> void:
	actor.character_animated_model.foot_trails_particles.visible = false
	actor.character_animated_model.foot_trails_particles.restart()
	actor.actor_data.move_speed_mult = 1
	actor.nav_agent.target_position = actor.position
	PlayerInputHelper.input_enabled = true
	if actor.area_hitbox.area_entered.is_connected(_on_area_entered):
		actor.area_hitbox.area_entered.disconnect(_on_area_entered)
	actors_hit_array.clear()
