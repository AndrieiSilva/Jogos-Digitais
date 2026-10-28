class_name SpinAttackState extends PlayerState

@export var base_advance_distance : float = 8
@export var move_speed_mult : float = 10
@export var damage_mult : float = 2

var actors_hit_array : Array[Actor] = []
var dest_reached : bool = false

func _transition_to() -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/SpinShot/active")
	if not one_shot_active:
		state_chart.send_event(States["idle"])


func _state_action(delta : float) -> void:
	animate(delta)

func animate(delta : float) -> void:
	var player : AnimationTree = actor.character_animated_model.anim_tree
	
	var run_val : float = player.get("parameters/BlendRun/blend_amount")
	run_val = lerpf(run_val, 0, actor.anim_lerp_speed * delta)
	player["parameters/BlendRun/blend_amount"] = run_val

func add_forward_offset_to_nav(direction: Vector3) -> void:
	var move_direction : Vector3 = direction.normalized()
	var current_target : Vector3 = actor.nav_agent.get_target_position()
	if current_target == Vector3.ZERO:
		current_target = actor.global_position
	actor.nav_agent.target_position = current_target + (move_direction * base_advance_distance)


func _on_area_entered(area : Area3D) -> void:
	if area is Hurtbox:
		if area.actor == actor:
			return
		
		if area.actor in actors_hit_array:
			return
		
		actors_hit_array.append(area.actor)
		area.receive_damage(actor.current_weapon_data.damage * damage_mult, actor)
		area.push_back(10, (area.actor.global_position - actor.global_position).normalized())


func _on_spin_attack_state_entered() -> void:
	actor.character_animated_model.weapon_trails_particles.restart()
	actor.character_animated_model.weapon_trails_particles.visible = true
	actor.actor_data.move_speed_mult = move_speed_mult
	if not actor.area_hitbox.area_entered.is_connected(_on_area_entered):
		actor.area_hitbox.area_entered.connect(_on_area_entered)
	
	PlayerInputHelper.input_enabled = false
	actor.nav_agent.target_position = actor.position
	var player : AnimationTree = actor.character_animated_model.anim_tree
	player.set("parameters/SpinShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	add_forward_offset_to_nav(-actor.global_basis.z)
	if not nav_agent.navigation_finished.is_connected(_on_dest_reached):
		nav_agent.navigation_finished.connect(_on_dest_reached)
	
	var areas_in_hitbox : Array[Area3D] = actor.area_hitbox.get_overlapping_areas()
	if not areas_in_hitbox.is_empty():
		for area : Area3D in areas_in_hitbox:
			_on_area_entered(area)

func _on_dest_reached() -> void:
	dest_reached = true


func _on_spin_attack_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)


func _on_spin_attack_state_exited() -> void:
	actor.character_animated_model.weapon_trails_particles.visible = false
	actor.character_animated_model.weapon_trails_particles.restart()
	actor.actor_data.move_speed_mult = 1
	actor.nav_agent.target_position = actor.position
	PlayerInputHelper.input_enabled = true
	dest_reached = false
	if actor.area_hitbox.area_entered.is_connected(_on_area_entered):
		actor.area_hitbox.area_entered.disconnect(_on_area_entered)
	if nav_agent.navigation_finished.is_connected(_on_dest_reached):
		nav_agent.navigation_finished.disconnect(_on_dest_reached)
	actors_hit_array.clear()
