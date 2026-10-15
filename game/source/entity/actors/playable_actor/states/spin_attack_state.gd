class_name SpinAttackState extends PlayerState

@export var base_advance_distance : float = 8
var actors_hit_array : Array[Actor] = []

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


func _process(delta: float) -> void:
	sync_player_skeleton_pos(delta)

func sync_player_skeleton_pos(delta: float) -> void:
	var skeleton: Skeleton3D = actor.character_animated_model.skeleton
	if not skeleton:
		return
		
	var idx: int = skeleton.find_bone("mixamorig_Hips")
	if idx == -1:
		return
	
	var hip_pose: Transform3D = skeleton.get_bone_pose(idx)
	
	hip_pose.origin = Vector3(0.0, hip_pose.origin.y, 0.0)
	skeleton.set_bone_pose(idx, hip_pose)


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
		area.receive_damage(actor.current_weapon_data.damage)


func _on_spin_attack_state_entered() -> void:
	if not actor.hitbox.area_entered.is_connected(_on_area_entered):
		actor.hitbox.area_entered.connect(_on_area_entered)
	
	PlayerInputHelper.input_enabled = false
	actor.nav_agent.target_position = actor.position
	var player : AnimationTree = actor.character_animated_model.anim_tree
	var one_shot_active = player.get("parameters/SpinShot/active")
	if not one_shot_active:
		player.set("parameters/SpinShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	add_forward_offset_to_nav(-actor.global_basis.z)


func _on_spin_attack_state_physics_processing(delta: float) -> void:
	_transition_to()
	_state_action(delta)


func _on_spin_attack_state_exited() -> void:
	actor.nav_agent.target_position = actor.position
	PlayerInputHelper.input_enabled = true
	if actor.hitbox.area_entered.is_connected(_on_area_entered):
		actor.hitbox.area_entered.disconnect(_on_area_entered)
	actors_hit_array.clear()
